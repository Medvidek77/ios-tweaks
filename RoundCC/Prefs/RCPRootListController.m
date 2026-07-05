#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface RCPRootListController : PSListController
@end

@implementation RCPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
