# Overlays
PRODUCT_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay-lineage

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += $(COMMON_PATH)/overlay-lineage/lineage-sdk

# Camera
PRODUCT_PACKAGES += \
    Snap

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += $(COMMON_PATH)/overlay-lineage/packages/apps/Snap

# Fingerprint Inscreen
PRODUCT_PACKAGES += \
    vendor.lineage.biometrics.fingerprint.inscreen@1.0-service.samsung-sm8250

PRODUCT_COPY_FILES += \
    vendor/lineage/config/permissions/vendor.lineage.biometrics.fingerprint.inscreen.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/vendor.lineage.biometrics.fingerprint.inscreen.xml
