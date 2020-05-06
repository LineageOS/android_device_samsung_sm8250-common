LOCAL_PATH := $(call my-dir)

ifneq ($(filter x1q y2q z3q,$(TARGET_DEVICE)),)

include $(call all-makefiles-under,$(LOCAL_PATH))

endif
