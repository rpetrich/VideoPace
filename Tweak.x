#import <AVFoundation/AVFoundation.h>

static float rateFactor;
static float inverseRateFactor;
static BOOL settingsArePrepared;

static void InvalidateSettings(void)
{
	settingsArePrepared = NO;
}

static void PrepareSettings(void)
{
	if (!settingsArePrepared) {
		NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpetrich.videopace.plist"];
		id temp = [settings objectForKey:@"VPRateFactor"];
		rateFactor = temp ? [temp floatValue] : 1.3f;
		inverseRateFactor = 1.0f / rateFactor;
		settingsArePrepared = YES;
	}
}

%hook AVPlayer

- (void)setRate:(float)rate
{
	PrepareSettings();
	%orig(rate * rateFactor);
}

- (float)rate
{
	PrepareSettings();
	return %orig() * inverseRateFactor;
}

%end

%ctor {
	%init();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void *)InvalidateSettings, CFSTR("com.rpetrich.videopace.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
