TWEAK_NAME = VideoPace
VideoPace_FILES = Tweak.x
VIdeoPace_FRAMEWORKS = UIKit

ADDITIONAL_CFLAGS = -std=c99

IPHONE_ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.3
TARGET=:clang

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
