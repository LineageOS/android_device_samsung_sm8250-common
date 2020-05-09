# SPDX-License-Identifier: Apache-2.0
# Copyright (C) 2020 The LineageOS Project

LOCAL_PATH := hardware/samsung/hidl/fingerprint/inscreen

include $(CLEAR_VARS)

LOCAL_MODULE := vendor.lineage.biometrics.fingerprint.inscreen@1.0-service.samsung-sm8250
LOCAL_MODULE_TAGS := optional

LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT)/vendor_overlay/$(PLATFORM_VNDK_VERSION)/bin
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE_STEM := vendor.lineage.biometrics.fingerprint.inscreen@1.0-service.samsung

LOCAL_SRC_FILES := \
    FingerprintInscreen.cpp \
    service.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include

LOCAL_REQUIRED_MODULES := \
    vendor.lineage.biometrics.fingerprint.inscreen@1.0-service.samsung.rc

LOCAL_SHARED_LIBRARIES := \
    libbase \
    libhardware \
    libhidlbase \
    libhidltransport \
    liblog \
    libhwbinder \
    libutils \
    vendor.lineage.biometrics.fingerprint.inscreen@1.0

LOCAL_POST_INSTALL_CMD := mkdir -p $(TARGET_OUT_PRODUCT)/vendor_overlay/$(PLATFORM_VNDK_VERSION)/lib64
LOCAL_POST_INSTALL_CMD += ; touch $(TARGET_OUT_PRODUCT)/vendor_overlay/$(PLATFORM_VNDK_VERSION)/lib64/vendor.lineage.biometrics.fingerprint.inscreen@1.0.so

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_MODULE := vendor.lineage.biometrics.fingerprint.inscreen@1.0-service.samsung.rc
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC

LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT)/vendor_overlay/$(PLATFORM_VNDK_VERSION)/etc/init

LOCAL_SRC_FILES := $(LOCAL_MODULE)

include $(BUILD_PREBUILT)
