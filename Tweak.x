#import <AVFoundation/AVFoundation.h>

static float rateFactor;
static float inverseRateFactor;

%hook AVPlayer

- (void)setRate:(float)rate
{
	%orig(rate * rateFactor);
}

- (float)rate
{
	return %orig() * inverseRateFactor;
}

%end

static void LoadSettings(void)
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpetrich.videopace.plist"];
	id temp = [settings objectForKey:@"VPRateFactor"];
	rateFactor = temp ? [temp floatValue] : 1.3f;
	inverseRateFactor = 1.0f / rateFactor;
}

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init();
	LoadSettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void *)LoadSettings, CFSTR("com.rpetrich.videopace.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool drain];
}
