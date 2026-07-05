#import <UIKit/UIKit.h>

#define kIdentifier @"com.yourname.roundccprefs"
#define kSettingsChangedNotification (CFStringRef)@"com.yourname.roundccprefs/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.yourname.roundccprefs.plist"

static BOOL enabled = YES;
static CGFloat cornerRadius = 19.0;
static NSString *moduleColorHex = @"";
static UIColor *parsedModuleColor = nil;

// Helper function to convert hex string to UIColor
static UIColor *colorFromHexString(NSString *hexString) {
    if (!hexString || [hexString isEqualToString:@""]) return nil;

    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                        [cleanString substringWithRange:NSMakeRange(0, 1)], [cleanString substringWithRange:NSMakeRange(0, 1)],
                        [cleanString substringWithRange:NSMakeRange(1, 1)], [cleanString substringWithRange:NSMakeRange(1, 1)],
                        [cleanString substringWithRange:NSMakeRange(2, 1)], [cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if ([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }

    unsigned int baseValue = 0;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];

    float red = ((baseValue >> 24) & 0xFF) / 255.0f;
    float green = ((baseValue >> 16) & 0xFF) / 255.0f;
    float blue = ((baseValue >> 8) & 0xFF) / 255.0f;
    float alpha = ((baseValue >> 0) & 0xFF) / 255.0f;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

static void loadPrefs() {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:kIdentifier];
    if (prefs) {
        enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
        cornerRadius = [prefs objectForKey:@"cornerRadius"] ? [[prefs objectForKey:@"cornerRadius"] floatValue] : 19.0;
        moduleColorHex = [prefs objectForKey:@"moduleColor"] ? [prefs objectForKey:@"moduleColor"] : @"";
        parsedModuleColor = colorFromHexString(moduleColorHex);
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

        // Apply custom background color if set
        UIColor *customColor = parsedModuleColor;
        if (customColor) {
            self.backgroundColor = customColor;
        }
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

        UIColor *customColor = parsedModuleColor;
        if (customColor) {
            self.backgroundColor = customColor;
        }
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

        UIColor *customColor = parsedModuleColor;
        if (customColor) {
            self.backgroundColor = customColor;
        }
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