TARGET := iphone:clang:14.5:14.0
ARCHS = arm64

BUNDLE_NAME = RoundCCPrefs

RoundCCPrefs_FILES = RCPRootListController.m
RoundCCPrefs_FRAMEWORKS = UIKit
RoundCCPrefs_PRIVATE_FRAMEWORKS = Preferences
RoundCCPrefs_INSTALL_PATH = /Library/PreferenceBundles
RoundCCPrefs_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/RoundCC.plist$(ECHO_END)
