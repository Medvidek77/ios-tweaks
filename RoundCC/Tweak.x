#import <UIKit/UIKit.h>

#define kIdentifier @"com.yourname.roundccprefs"
#define kSettingsChangedNotification (CFStringRef)@"com.yourname.roundccprefs/ReloadPrefs"

static BOOL enabled = YES;
static CGFloat cornerRadius = 19.0;

static void loadPrefs() {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kIdentifier];
    NSLog(@"[RoundCC] Loading Preferences...");
    if (prefs) {
        enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
        cornerRadius = [prefs objectForKey:@"cornerRadius"] ? [[prefs objectForKey:@"cornerRadius"] floatValue] : 19.0;
        NSLog(@"[RoundCC] Preferences loaded - Enabled: %d, Corner Radius: %f", enabled, cornerRadius);
    }
}

// Ensure the classes exist before we hook them, otherwise trigger a crash
static void verifyClass(NSString *className) {
    if (!NSClassFromString(className)) {
        NSLog(@"[RoundCC] CRITICAL ERROR: Class %@ not found! Crashing to safe mode.", className);
        // abort(); // Removed abort to prevent SpringBoard bootloops due to lazy framework loading
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

        // iOS 14 CC modules typically mask to bounds anyway, we force custom rounding here
        self.layer.cornerRadius = cornerRadius;
        [self.layer setCornerCurve:kCACornerCurveContinuous];
        self.clipsToBounds = YES;
    }
}

%end

// ---------------------------------------------------------
// 2. Base Sliders (Volume, Brightness)
// CCUIContinuousSliderView and CCUISteppedSliderView both inherit from CCUIBaseSliderView (which DOES exist on iOS 14)
// We will target the actual view components if the base class refuses to size correctly, but BaseSliderView is the proper root.
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
    NSLog(@"[RoundCC] Tweak initialized");
    loadPrefs();

    // Explicitly check for classes when the tweak loads
    verifyClass(@"CCUIContentModuleContainerView");
    verifyClass(@"CCUIBaseSliderView");
    verifyClass(@"CCUIRoundButton");

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}