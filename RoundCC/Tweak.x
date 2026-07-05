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

// CCUIContentModuleContentContainerView (iOS 14) manages the actual background platter
@interface CCUIContentModuleContentContainerView : UIView
@property (assign,nonatomic) double compactContinuousCornerRadius;
@property (assign,nonatomic) double expandedContinuousCornerRadius;
@property (assign,nonatomic) BOOL moduleProvidesOwnPlatter;
@end

%hook CCUIContentModuleContentContainerView

- (void)layoutSubviews {
    %orig;

    if (enabled && !self.moduleProvidesOwnPlatter) {
        CGFloat minDim = MIN(self.bounds.size.width, self.bounds.size.height);
        CGFloat maxRadius = minDim / 2.0;
        CGFloat safeRadius = MIN(cornerRadius, maxRadius);

        self.compactContinuousCornerRadius = safeRadius;

        // Ensure the expanded radius is proportional or also capped properly
        // In expanded view, the module is larger, so maxRadius is larger.
        // We will apply the requested cornerRadius, capped by the NEW bounds.
        self.expandedContinuousCornerRadius = safeRadius;
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
        CGFloat maxRadius = minDim / 2.0;
        self.layer.cornerRadius = MIN(cornerRadius, maxRadius);
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
        CGFloat maxRadius = minDim / 2.0;
        self.layer.cornerRadius = MIN(cornerRadius, maxRadius);
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
        CGFloat maxRadius = minDim / 2.0;
        self.layer.cornerRadius = MIN(cornerRadius, maxRadius);
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
        CGFloat maxRadius = minDim / 2.0;
        self.layer.cornerRadius = MIN(cornerRadius, maxRadius);
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
    NSLog(@"[RoundCC] CCUIContentModuleContentContainerView: %d", NSClassFromString(@"CCUIContentModuleContentContainerView") != nil);
    NSLog(@"[RoundCC] CCUIRoundButton: %d", NSClassFromString(@"CCUIRoundButton") != nil);
    NSLog(@"[RoundCC] CCUILabeledRoundButton: %d", NSClassFromString(@"CCUILabeledRoundButton") != nil);
    NSLog(@"[RoundCC] CCUIControlCenterSlider: %d", NSClassFromString(@"CCUIControlCenterSlider") != nil);
    NSLog(@"[RoundCC] CCUIModuleSliderView: %d", NSClassFromString(@"CCUIModuleSliderView") != nil);
    #endif

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
