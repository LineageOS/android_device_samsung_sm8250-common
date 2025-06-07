/*
 * SPDX-FileCopyrightText: 2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "vendor.lineage.touch-service.samsung_sm8250"

#include "GloveMode.h"

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/strings.h>

using ::android::base::ReadFileToString;
using ::android::base::Trim;
using ::android::base::WriteStringToFile;

namespace aidl {
namespace vendor {
namespace lineage {
namespace touch {

ndk::ScopedAStatus GloveMode::getEnabled(bool* _aidl_return) {
    std::string buf;
    if (!ReadFileToString(TSP_CMD_RESULT_NODE, &buf)) {
        LOG(ERROR) << "Failed to read current GloveMode state";
        return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    *_aidl_return = Trim(buf) == "glove_mode,1:OK";
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus GloveMode::setEnabled(bool enabled) {
    if (!WriteStringToFile(enabled ? "glove_mode,1" : "glove_mode,0", TSP_CMD_NODE)) {
        LOG(ERROR) << "Failed to write GloveMode state";
        return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    return ndk::ScopedAStatus::ok();
}

}  // namespace touch
}  // namespace lineage
}  // namespace vendor
}  // namespace aidl
