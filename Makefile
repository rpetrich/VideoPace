TWEAK_NAME = VideoPace
VideoPace_FILES = Tweak.x
VIdeoPace_FRAMEWORKS = UIKit

ADDITIONAL_CFLAGS = -std=c99

SDKVERSION := 5.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION := 4.3

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
