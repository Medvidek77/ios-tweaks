export TARGET := iphone:clang:14.5:14.0
export ARCHS = arm64
FINALPACKAGE = 1
export LDFLAGS += -Xlinker -no_fixup_chains

INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = RoundCC
RoundCC_FILES = Tweak.x
RoundCC_CFLAGS = -fobjc-arc
RoundCC_FRAMEWORKS = UIKit QuartzCore

SUBPROJECTS += Prefs

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
