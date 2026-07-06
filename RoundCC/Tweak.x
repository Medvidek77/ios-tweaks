#import <UIKit/UIKit.h>

#define kIdentifier @"com.medvidek77.roundccprefs"
#define kSettingsChangedNotification (CFStringRef)@"com.medvidek77.roundccprefs/ReloadPrefs"

static BOOL enabled = YES;
static CGFloat userCornerRadius = 19.0;

static void loadPrefs() {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kIdentifier];
    if (prefs) {
        enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
        userCornerRadius = [prefs objectForKey:@"cornerRadius"] ? [[prefs objectForKey:@"cornerRadius"] floatValue] : 19.0;
    }
}

// CCUIContentModuleContainerViewController manages module geometry directly.
@interface CCUIContentModuleContainerViewController : UIViewController
- (double)_continuousCornerRadiusForCompactState;
- (double)_continuousCornerRadiusForExpandedState;
@end

%hook CCUIContentModuleContainerViewController

- (double)_continuousCornerRadiusForCompactState {
    double orig = %orig;
    if (enabled) {
        // Fallback size for standard CC modules if they haven't laid out yet (e.g. 68x68 for 1x1 modules on small iPhones)
        CGFloat minDim = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
        if (minDim <= 0.0) {
            minDim = 68.0;
        }
        CGFloat maxRadius = minDim / 2.0;
        return MIN(userCornerRadius, maxRadius);
    }
    return orig;
}

- (double)_continuousCornerRadiusForExpandedState {
    double orig = %orig;
    if (enabled) {
        // Expanded is always large, just use user setting.
        // We will assume 150+ width, so 150/2 = 75 is max anyway.
        return MIN(userCornerRadius, 50.0); // Safety cap at 50 for expanded modules
    }
    return orig;
}

%end


// For continuous sliders (Brightness, Volume)
@interface CCUIContinuousSliderView : UIControl
@property (assign,nonatomic) double continuousSliderCornerRadius;
@end

%hook CCUIContinuousSliderView

// The property is asked for when expanding/collapsing.
// We will intercept the getter instead of setting it continuously in layoutSubviews.
- (double)continuousSliderCornerRadius {
    double orig = %orig;
    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        if (minDim <= 0.0) {
            minDim = 68.0;
        }
        CGFloat maxRadius = minDim / 2.0;
        return MIN(userCornerRadius, maxRadius);
    }
    return orig;
}

%end

// Round buttons inside modules (e.g. WiFi, Bluetooth, Flashlight)
@interface CCUIRoundButton : UIControl
- (double)_cornerRadius;
@end

%hook CCUIRoundButton

- (double)_cornerRadius {
    double orig = %orig;
    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        if (minDim <= 0.0) {
            minDim = 54.0; // Round buttons are usually ~54 on small iPhones
        }
        CGFloat maxRadius = minDim / 2.0;
        return MIN(userCornerRadius, maxRadius);
    }
    return orig;
}

%end


static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
}

%ctor {
    loadPrefs();

    #ifdef DEBUG
    NSLog(@"[RoundCC] Tweak initialized (v1.0.3)");
    #endif

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
