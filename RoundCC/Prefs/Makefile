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
