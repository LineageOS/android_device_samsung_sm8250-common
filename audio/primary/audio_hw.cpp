/*
 * SPDX-FileCopyrightText: 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "audio_hw_sm8250"

#include <dlfcn.h>
#include <string.h>

#include <string>

#include <cutils/properties.h>
#include <cutils/str_parms.h>
#include <hardware/audio.h>
#include <hardware/hardware.h>
#include <log/log.h>
#include <tinyalsa/asoundlib.h>

namespace {

constexpr char kStockLibPath[] = "/vendor/lib/hw/audio.primary.kona.so";

constexpr int kSlotPositions0[] = {0, 1, 0, 1};
constexpr int kSlotPositions90[] = {1, 1, 0, 0};
constexpr int kSlotPositions180[] = {1, 0, 1, 0};
constexpr int kSlotPositions270[] = {0, 0, 1, 1};

hw_module_t* gStockModule;
int (*gStockSetParameters)(audio_hw_device*, const char*);
int (*gStockSetMode)(audio_hw_device*, audio_mode_t);
int (*gStockOpenOutputStream)(audio_hw_device*, audio_io_handle_t, audio_devices_t,
                              audio_output_flags_t, audio_config*, audio_stream_out**, const char*);

void setMixerValueByName(mixer* mixer, const char* name, int value) {
    const auto ctl = mixer_get_ctl_by_name(mixer, name);

    if (ctl == nullptr) {
        ALOGE("Failed to find mixer ctl for %s", name);
        return;
    }

    if (mixer_ctl_set_value(ctl, 0, value) < 0) {
        ALOGE("Failed to set ctl value %d for %s", value, name);
    }
}

void setSlotPositions(const int* values) {
    const auto mixer = mixer_open(0);

    if (mixer == nullptr) {
        ALOGE("Failed to open mixer");
        return;
    }

    setMixerValueByName(mixer, "FL ASPRX1 Slot Position", values[0]);
    setMixerValueByName(mixer, "FR ASPRX1 Slot Position", values[1]);
    setMixerValueByName(mixer, "RL ASPRX1 Slot Position", values[2]);
    setMixerValueByName(mixer, "RR ASPRX1 Slot Position", values[3]);

    mixer_close(mixer);
}

int adevSetParameters(audio_hw_device* dev, const char* kvpairs) {
    const auto parms = str_parms_create_str(kvpairs);

    if (parms == nullptr) {
        return gStockSetParameters(dev, kvpairs);
    }

    std::string params = kvpairs;
    char value[32];

    if (str_parms_get_str(parms, "rotation", value, sizeof(value)) >= 0) {
        if (!strcmp(value, "0")) {
            setSlotPositions(kSlotPositions0);
        } else if (!strcmp(value, "90")) {
            setSlotPositions(kSlotPositions90);
        } else if (!strcmp(value, "180")) {
            setSlotPositions(kSlotPositions180);
        } else if (!strcmp(value, "270")) {
            setSlotPositions(kSlotPositions270);
        }

        // Rotation is handled entirely here, don't forward it to the stock HAL.
        str_parms_del(parms, "rotation");
        const auto str = str_parms_to_str(parms);
        params = str;
        free(str);
    }

    if (str_parms_get_str(parms, "bt_wbs", value, sizeof(value)) >= 0) {
        params += ";g_sco_samplerate=";
        params += !strcmp(value, "on") ? "16000" : "8000";
    }

    str_parms_destroy(parms);

    return gStockSetParameters(dev, params.c_str());
}

int adevSetMode(audio_hw_device* dev, audio_mode_t mode) {
    // On stock ROM Samsung sets the g_call_sim_slot audio parameter in the framework.
    // vendor.calls.slot_id{0,1} report 1 while that SIM is in a call, 0 otherwise.
    char simSlot1[PROPERTY_VALUE_MAX], simSlot2[PROPERTY_VALUE_MAX];

    property_get("vendor.calls.slot_id0", simSlot1, "");
    property_get("vendor.calls.slot_id1", simSlot2, "");

    // Wait until one SIM slot reports a call.
    if (mode == AUDIO_MODE_IN_CALL) {
        while (!strcmp(simSlot1, "0") && !strcmp(simSlot2, "0")) {
            property_get("vendor.calls.slot_id0", simSlot1, "");
            property_get("vendor.calls.slot_id1", simSlot2, "");
        }
    }

    if (!strcmp(simSlot1, "1")) {
        gStockSetParameters(dev, "g_call_sim_slot=0x01");
    } else if (!strcmp(simSlot2, "1")) {
        gStockSetParameters(dev, "g_call_sim_slot=0x02");
    }

    return gStockSetMode(dev, mode);
}

int adevOpenOutputStream(audio_hw_device* dev, audio_io_handle_t handle, audio_devices_t devices,
                         audio_output_flags_t flags, audio_config* config,
                         audio_stream_out** stream_out, const char* address) {
    // HIDL versions before 7.1 represent spatializer outputs as FAST | DEEP_BUFFER.
    // The stock HAL prioritizes FAST, whose short buffers cannot sustain the
    // software spatializer. Select its buffered PCM path instead.
    if ((flags & (AUDIO_OUTPUT_FLAG_FAST | AUDIO_OUTPUT_FLAG_DEEP_BUFFER)) ==
        (AUDIO_OUTPUT_FLAG_FAST | AUDIO_OUTPUT_FLAG_DEEP_BUFFER)) {
        flags = static_cast<audio_output_flags_t>(flags & ~AUDIO_OUTPUT_FLAG_FAST);
    }

    return gStockOpenOutputStream(dev, handle, devices, flags, config, stream_out, address);
}

int adevOpen(const hw_module_t* /* module */, const char* name, hw_device_t** device) {
    if (gStockModule == nullptr) {
        const auto handle = dlopen(kStockLibPath, RTLD_NOW);

        if (handle == nullptr) {
            ALOGE("Failed to dlopen %s: %s", kStockLibPath, dlerror());
            return -EINVAL;
        }

        gStockModule = static_cast<hw_module_t*>(dlsym(handle, HAL_MODULE_INFO_SYM_AS_STR));

        if (gStockModule == nullptr) {
            ALOGE("Failed to find %s in %s", HAL_MODULE_INFO_SYM_AS_STR, kStockLibPath);
            dlclose(handle);
            return -EINVAL;
        }

        gStockModule->dso = handle;
    }

    const auto ret = gStockModule->methods->open(gStockModule, name, device);

    if (ret != 0) {
        return ret;
    }

    // The stock HAL casts the device back to its private struct in every callback,
    // so hook the function pointers in place rather than wrapping the device.
    const auto adev = reinterpret_cast<audio_hw_device*>(*device);

    gStockSetParameters = adev->set_parameters;
    gStockSetMode = adev->set_mode;
    gStockOpenOutputStream = adev->open_output_stream;
    adev->set_parameters = adevSetParameters;
    adev->set_mode = adevSetMode;
    adev->open_output_stream = adevOpenOutputStream;

    return 0;
}

hw_module_methods_t gModuleMethods = {
        .open = adevOpen,
};

}  // namespace

audio_module HAL_MODULE_INFO_SYM = {
        .common =
                {
                        .tag = HARDWARE_MODULE_TAG,
                        .module_api_version = AUDIO_MODULE_API_VERSION_0_1,
                        .hal_api_version = HARDWARE_HAL_API_VERSION,
                        .id = AUDIO_HARDWARE_MODULE_ID,
                        .name = "sm8250 audio HAL wrapper",
                        .author = "The LineageOS Project",
                        .methods = &gModuleMethods,
                },
};
