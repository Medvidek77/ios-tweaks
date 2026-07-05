export LDFLAGS += -Xlinker -no_fixup_chains
export TARGET := iphone:clang:14.5:14.0
export ARCHS = arm64

INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = RoundCC
RoundCC_FILES = Tweak.x
RoundCC_CFLAGS = -fobjc-arc

SUBPROJECTS += Prefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
