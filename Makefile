TARGET = iphone:clang:16.5:15.0
ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0

TWEAK_NAME = XNotForMe
DISPLAY_NAME = Twitter
BUNDLE_ID = com.atebits.Tweetie2
INSTALL_TARGET_PROCESSES = Twitter

XNotForMe_FILES = Tweak.xm
XNotForMe_IPA = tmp/Payload/Twitter.app
XNotForMe_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-nullability-completeness -Wno-unused-function -Wno-unused-property-ivar -Wno-error
XNotForMe_FRAMEWORKS = UIKit Foundation AVFoundation AVKit CoreMotion GameController VideoToolbox Accelerate CoreMedia CoreImage CoreGraphics ImageIO Photos CoreServices SystemConfiguration SafariServices Security QuartzCore WebKit SceneKit

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
