export THEOS ?= /opt/theos
export THEOS_MAKE_PATH = $(THEOS)/makefiles
export TARGET = iphone:clang:14.5:13.0
export ARCHS = arm64

include $(THEOS_MAKE_PATH)/common.mk

TWEAK_NAME = WXReadQRTweak
WXReadQRTweak_FILES = Tweak.x
WXReadQRTweak_FRAMEWORKS = UIKit Foundation AVFoundation WebKit
WXReadQRTweak_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
