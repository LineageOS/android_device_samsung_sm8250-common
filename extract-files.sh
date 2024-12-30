#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_FIRMWARE=
ONLY_TARGET=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common)
            ONLY_COMMON=true
            ;;
        --only-firmware)
            ONLY_FIRMWARE=true
            ;;
        --only-target)
            ONLY_TARGET=true
            ;;
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

    if [ -z "${SRC}" ]; then
        SRC="adb"
    fi

function blob_fixup() {
    case "${1}" in
        vendor/lib64/libsec-ril.so)
            [ "$2" = "" ] && return 0
            # Replace SlotID prop
            sed -i 's/ril.dds.call.ongoing/vendor.calls.slot_id/g' "${2}"
            # Pass an empty value to SecRil::RequestComplete in OnGetSmscAddressDone (mov x3,x20 -> mov,x3,#0x0)
            xxd -p -c0 "${2}" | sed "s/600e40f9820c805224008052e10315aa080040f9e30314aa/600e40f9820c805224008052e10315aa080040f9030080d2/g" | xxd -r -p > "${2}".patched
            mv "${2}".patched "${2}"
            ;;
        vendor/lib64/hw/com.qti.chi.override.so)
            [ "$2" = "" ] && return 0
            xxd -p "${2}" | tr -d \\n > "${2}".hex
            # NOP CONNECT_RILD
            sed -i "s/a00640f96d66009480010034a2eaffd043ecff9065ebfff0e603002a/1f2003d51f2003d51f2003d51f2003d51f2003d51f2003d51f2003d5/g" "${2}".hex
            sed -i "s/42503d91633c1391a5743191e40e8052e0031f2a2100805265d8ff97a00640f9/1f2003d51f2003d51f2003d51f2003d51f2003d51f2003d51f2003d5a00640f9/g" "${2}".hex
            xxd -r -p "${2}".hex > "${2}"
            rm "${2}".hex
            ;;
        vendor/lib64/hw/gatekeeper.mdfpp.so|vendor/lib64/libskeymaster4device.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libcrypto.so" "libcrypto-v33.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR_COMMON:-$VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../../${VENDOR}/${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    if [ -z "${ONLY_FIRMWARE}" ]; then
        extract "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
    fi

    if [ -z "${SECTION}" ] && [ -f "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-firmware.txt" ]; then
        extract_firmware "${MY_DIR}/../../${VENDOR}/${DEVICE}/proprietary-firmware.txt" "${SRC}"
    fi
fi

"${MY_DIR}/setup-makefiles.sh"
