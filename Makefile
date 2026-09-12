THEOS_PACKAGE_SCHEME = rootless

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

FINALPACKAGE = 1

INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AccountRemover

AccountRemover_FILES = Tweak.x
AccountRemover_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
AccountRemover_FRAMEWORKS = Foundation
AccountRemover_PRIVATE_FRAMEWORKS = Accounts

include $(THEOS_MAKE_PATH)/tweak.mk
