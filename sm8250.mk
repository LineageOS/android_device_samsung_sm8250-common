# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Proprietary blobs
$(call inherit-product-if-exists, vendor/samsung/sm8250-common/sm8250-common-vendor.mk)

COMMON_PATH := device/samsung/sm8250-common

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

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.1-service.samsung-sm8250

# Properties
-include $(COMMON_PATH)/vendor_prop.mk

# Lineage
ifneq ($(LINEAGE_BUILD),)
-include $(COMMON_PATH)/sm8250_lineage.mk
endif
