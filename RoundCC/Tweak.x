#import <UIKit/UIKit.h>

#define kIdentifier @"com.yourname.roundccprefs"
#define kSettingsChangedNotification (CFStringRef)@"com.yourname.roundccprefs/ReloadPrefs"

static BOOL enabled = YES;
static CGFloat cornerRadius = 19.0;

static void loadPrefs() {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kIdentifier];
    if (prefs) {
        enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
        cornerRadius = [prefs objectForKey:@"cornerRadius"] ? [[prefs objectForKey:@"cornerRadius"] floatValue] : 19.0;
    }
}

// ---------------------------------------------------------
// 1. Module Container (The outer boxes of modules)
// ---------------------------------------------------------
@interface CCUIContentModuleContainerView : UIView
@end

%hook CCUIContentModuleContainerView

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        self.layer.cornerRadius = cornerRadius;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
        self.clipsToBounds = YES;
    }
}

%end

// ---------------------------------------------------------
// 2. Base Sliders (Volume, Brightness)
// ---------------------------------------------------------
@interface CCUIBaseSliderView : UIControl
@end

%hook CCUIBaseSliderView

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        self.layer.cornerRadius = minDim / 2.0;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
        self.clipsToBounds = YES;
    }
}

%end

// ---------------------------------------------------------
// 3. Round Buttons (Toggles like Wi-Fi, Bluetooth)
// ---------------------------------------------------------
@interface CCUIRoundButton : UIControl
@end

%hook CCUIRoundButton

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        self.layer.cornerRadius = minDim / 2.0;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
    }
}

%end


static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
}

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}