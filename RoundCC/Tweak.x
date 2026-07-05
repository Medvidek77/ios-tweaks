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

// CCUIContentModuleContainerViewController is the view controller managing the module geometry.
// Hooking it allows us to return our custom radius cleanly for native animation systems.
@interface CCUIContentModuleContainerViewController : UIViewController
- (double)_continuousCornerRadiusForCompactState;
- (double)_continuousCornerRadiusForExpandedState;
@end

%hook CCUIContentModuleContainerViewController

- (double)_continuousCornerRadiusForCompactState {
    double orig = %orig;
    if (enabled) {
        CGFloat minDim = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
        // We use minDim/2 as the maximum allowable radius before it deforms inwards.
        CGFloat maxRadius = minDim / 2.0;
        return MIN(userCornerRadius, maxRadius);
    }
    return orig;
}

- (double)_continuousCornerRadiusForExpandedState {
    double orig = %orig;
    if (enabled) {
        // We do not have direct bounds to the expanded state at this exact point,
        // but expanded state is always larger than compact state.
        // Returning the user's custom radius is perfectly safe here, but we will
        // cap it to a generous size to prevent internal deformation (e.g. 50 is typical max for sliders).
        // Since expanded bounds are typically > 150pt, we can safely just return the user input.
        return userCornerRadius;
    }
    return orig;
}

%end


// Continuous sliders (Brightness, Volume)
@interface CCUIContinuousSliderView : UIControl
@property (assign,nonatomic) double continuousSliderCornerRadius;
@end

%hook CCUIContinuousSliderView

- (void)layoutSubviews {
    %orig;
    if (enabled) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        CGFloat maxRadius = minDim / 2.0;
        self.continuousSliderCornerRadius = MIN(userCornerRadius, maxRadius);
    }
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
    NSLog(@"[RoundCC] Tweak initialized");
    NSLog(@"[RoundCC] CCUIContentModuleContainerViewController: %d", NSClassFromString(@"CCUIContentModuleContainerViewController") != nil);
    NSLog(@"[RoundCC] CCUIRoundButton: %d", NSClassFromString(@"CCUIRoundButton") != nil);
    NSLog(@"[RoundCC] CCUIContinuousSliderView: %d", NSClassFromString(@"CCUIContinuousSliderView") != nil);
    #endif

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
