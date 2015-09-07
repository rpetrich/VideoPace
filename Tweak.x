#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

#define ROCKETBOOTSTRAP_LOAD_DYNAMIC
#import "LightMessaging/LightMessaging.h"

static LMConnection connection = {
	MACH_PORT_NULL,
	"com.rpetrich.videopace"
};

static float rateFactor;
static float inverseRateFactor;
static BOOL settingsArePrepared;

static void InvalidateSettings(void)
{
	settingsArePrepared = NO;
}

static NSDictionary *ReadSettings(void)
{
	if (kCFCoreFoundationVersionNumber > 1000) {
		if (!objc_getClass("SpringBoard")) {
			LMResponseBuffer buffer;
			if (LMConnectionSendTwoWay(&connection, 0, NULL, 0, &buffer) == 0) {
				return LMResponseConsumePropertyList(&buffer);
			}
		}
		CFArrayRef keys = CFPreferencesCopyKeyList(CFSTR("com.rpetrich.videopace"), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		if (!keys) {
			return [NSDictionary dictionary];
		}
		CFDictionaryRef result = CFPreferencesCopyMultiple(keys, CFSTR("com.rpetrich.videopace"), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
		CFRelease(keys);
		return [(id)result autorelease];
	}
	return [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpetrich.videopace.plist"];
}

static void PrepareSettings(void)
{
	if (!settingsArePrepared) {
		NSDictionary *settings = ReadSettings();
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

static void machPortCallback(CFMachPortRef port, void *bytes, CFIndex size, void *info)
{
	LMMessage *request = bytes;
	if (size >= sizeof(LMMessage)) {
		if (request->head.msgh_id == 0) {
			LMSendPropertyListReply(request->head.msgh_remote_port, ReadSettings());
		}
	}
	LMResponseBufferFree(bytes);
}

%ctor {
	%init();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void *)InvalidateSettings, CFSTR("com.rpetrich.videopace.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	if (kCFCoreFoundationVersionNumber > 1000) {
		kern_return_t err = LMStartService(connection.serverName, CFRunLoopGetCurrent(), machPortCallback);
		if (err) {
			NSLog(@"VideoPace: Unable to register mach server with error %x", err);
		}
	}
}
