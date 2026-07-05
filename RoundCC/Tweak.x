#import <UIKit/UIKit.h>

#define kIdentifier @"com.medvidek77.roundccprefs"
#define kSettingsChangedNotification (CFStringRef)@"com.medvidek77.roundccprefs/ReloadPrefs"

static BOOL enabled = YES;
static CGFloat cornerRadius = 19.0;

static void loadPrefs() {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kIdentifier];
    if (prefs) {
        enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
        cornerRadius = [prefs objectForKey:@"cornerRadius"] ? [[prefs objectForKey:@"cornerRadius"] floatValue] : 19.0;
    }
}

// Ensure the class inherits from UIView so the compiler knows about layer and clipsToBounds
@interface CCUIContentModuleContainerView : UIView
@end

%hook CCUIContentModuleContainerView

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        self.layer.cornerRadius = cornerRadius;
        self.layer.masksToBounds = YES;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
        self.clipsToBounds = YES;
    }
}

%end

@interface CCUIControlCenterSlider : UIControl
@end

%hook CCUIControlCenterSlider

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        self.layer.cornerRadius = minDim / 2.0;
        self.layer.masksToBounds = YES;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
        self.clipsToBounds = YES;
    }
}

%end

@interface CCUIModuleSliderView : UIControl
@end

%hook CCUIModuleSliderView

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        self.layer.cornerRadius = minDim / 2.0;
        self.layer.masksToBounds = YES;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
        self.clipsToBounds = YES;
    }
}

%end

@interface CCUIRoundButton : UIControl
@end

%hook CCUIRoundButton

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        self.layer.cornerRadius = minDim / 2.0;
        self.layer.masksToBounds = YES;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
    }
}

%end

@interface CCUILabeledRoundButton : UIControl
@end

%hook CCUILabeledRoundButton

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        self.layer.cornerRadius = minDim / 2.0;
        self.layer.masksToBounds = YES;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
    }
}

%end

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
}


%ctor {
    loadPrefs();

    #ifdef DEBUG
    NSLog(@"[RoundCC] Tweak initialized");
    // Runtime existence check - let the device tell us which classes actually exist
    NSLog(@"[RoundCC] CCUIContentModuleContainerView: %d", NSClassFromString(@"CCUIContentModuleContainerView") != nil);
    NSLog(@"[RoundCC] CCUIRoundButton: %d", NSClassFromString(@"CCUIRoundButton") != nil);
    NSLog(@"[RoundCC] CCUILabeledRoundButton: %d", NSClassFromString(@"CCUILabeledRoundButton") != nil);
    NSLog(@"[RoundCC] CCUIControlCenterSlider: %d", NSClassFromString(@"CCUIControlCenterSlider") != nil);
    NSLog(@"[RoundCC] CCUIModuleSliderView: %d", NSClassFromString(@"CCUIModuleSliderView") != nil);
    #endif

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
