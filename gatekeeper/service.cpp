/*
 * SPDX-FileCopyrightText: 2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "android.hardware.gatekeeper@1.0-service-mdfpp"

#include <android-base/logging.h>
#include <android/hardware/gatekeeper/1.0/IGatekeeper.h>
#include <hidl/LegacySupport.h>

#include "Gatekeeper.h"

using android::hardware::gatekeeper::V1_0::IGatekeeper;
using android::hardware::gatekeeper::V1_0::implementation::Gatekeeper;

int main() {
  ALOGI("Gatekeeper MDFPP service is starting");

  ::android::hardware::configureRpcThreadpool(1, true /* willJoinThreadpool */);

  android::sp<IGatekeeper> gatekeeper = new Gatekeeper();

  const char *instance = nullptr;
  if (static_cast<Gatekeeper *>(gatekeeper.get())
          ->isMdfppInstance()) {
    instance = "mdfpp";
  } else {
    instance = "default";
  }

  android::status_t status = gatekeeper->registerAsService(instance);

  if (status != android::OK) {
    ALOGE("Could not register Gatekeeper MDFPP service");
  }

  ::android::hardware::joinRpcThreadpool();
  return -1; // Should never get here.
}
