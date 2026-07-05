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

// CCUIContentModuleContentContainerView is often used for the container of modules
@interface CCUIContentModuleContentContainerView : UIView
@property (assign,nonatomic) double compactContinuousCornerRadius;
@property (assign,nonatomic) double expandedContinuousCornerRadius;
@end

%hook CCUIContentModuleContentContainerView

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        // Apply custom continuous corner radius for compact state (the normal view)
        // If the CC module uses compactContinuousCornerRadius we set it
        if ([self respondsToSelector:@selector(setCompactContinuousCornerRadius:)]) {
            self.compactContinuousCornerRadius = cornerRadius;
        }

        // As a fallback or addition, apply to the layer
        self.layer.cornerRadius = cornerRadius;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
        self.clipsToBounds = YES;
    }
}

%end

// CCUIBaseSliderView is used for the brightness and volume sliders
@interface CCUIBaseSliderView : UIControl
@end

%hook CCUIBaseSliderView

- (void)layoutSubviews {
    %orig;

    if (enabled) {
        // Force fully rounded 'pill' shape for sliders
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
        // Ensure standard toggle buttons are perfectly circular
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