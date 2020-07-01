# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Proprietary blobs
$(call inherit-product-if-exists, vendor/samsung/sm8250-common/sm8250-common-vendor.mk)

COMMON_PATH := device/samsung/sm8250-common
TARGET_COPY_OUT_VENDOR_OVERLAY ?= $(TARGET_COPY_OUT_PRODUCT)/vendor_overlay/$(PLATFORM_VNDK_VERSION)

# Soong Namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(COMMON_PATH)

# Dynamic Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Overlays
PRODUCT_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay

PRODUCT_ENFORCE_RRO_TARGETS := *

# GSI AVB Public Keys
PRODUCT_PACKAGES += \
    q-gsi.avbpubkey \
    r-gsi.avbpubkey \
    s-gsi.avbpubkey

# Init Resources
PRODUCT_PACKAGES += \
    init.qcom.rc \
    fstab.qcom

# Recovery
PRODUCT_PACKAGES += \
    init.recovery.qcom.rc \
    fastbootd

# Skip Mount
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/skip_mount.cfg:system/etc/init/config/skip_mount.cfg

# HIDL
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/vendor_override_manifest.xml:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/vintf/manifest/vendor_override_manifest.xml

# Audio
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/audio_policy_configuration.xml

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.1-service.samsung-sm8250

# NFC
PRODUCT_PACKAGES += \
    libnfc-nci \
    libnfc_nci_jni \
    NfcNci \
    Tag

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/libnfc-nci.conf:system/etc/libnfc-nci.conf

# Power
PRODUCT_PACKAGES += \
    android.hardware.power@1.3-service.samsung-sm8250

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/configs/powerhint.json:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/powerhint.json

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl.samsung-sm8250

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.hifi_sensors.xml:system/etc/permissions/android.hardware.sensor.hifi_sensors.xml

# Vendor Services - DISABLED
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/init.vendor.qti.spu@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/pa_daemon_qsee.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.biometrics.face@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.media.converter@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.miscpower@2.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.snap@1.1-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.soter@3.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.tlc.arcounter@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.tlc.atn@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.tlc.ddar@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.tlc.hdm@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.tlc.iccc@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.tlc.payment@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.tlc.tima@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vendor.samsung.hardware.tlc.ucm@1.0-service.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vk_common.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/vk_qsee.rc \
    $(COMMON_PATH)/etc/empty:$(TARGET_COPY_OUT_VENDOR_OVERLAY)/etc/init/wsm-service.rc \
    $(COMMON_PATH)/etc/excluded_hardware.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/excluded_hardware.xml

# Properties
-include $(COMMON_PATH)/vendor_prop.mk

# Lineage
ifneq ($(LINEAGE_BUILD),)
-include $(COMMON_PATH)/sm8250_lineage.mk
endif
