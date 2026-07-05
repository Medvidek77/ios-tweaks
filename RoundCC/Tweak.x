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


// CCUIControlCenterSlider confirmed real class (ControlCenterUIKit symbol dump)
@interface CCUIControlCenterSlider : UIControl
@end

%hook CCUIControlCenterSlider

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

// CCUIModuleSliderView also confirmed real, some iOS versions use this one instead
@interface CCUIModuleSliderView : UIControl
@end

%hook CCUIModuleSliderView

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

// CCUIRoundButton is used for standard circular buttons like toggles
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

// CCUILabeledRoundButton confirmed real (PowerModule source), covers labeled variants
@interface CCUILabeledRoundButton : UIControl
@end

%hook CCUILabeledRoundButton

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
}// Reverting to specific class hooks based on the user's latest findings,
// avoiding global UIView hooks to prevent massive SpringBoard lag.
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
