# The TARGET variable determines what target system the application is
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling
TARGET = xp-skc-su1.xn

# The APP_NAME variable determines the name of the final .xe file. It should
# not include the .xe postfix. If left blank the name will default to
# the project name
APP_NAME = app_printer_demo

# The USED_MODULES variable lists other module used by the application.
USED_MODULES = module_logging module_usb_device module_usb_shared module_usb_tile_support module_xud

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
# XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to
# xcc for the final link (mapping) stage
BUILD_FLAGS = -Wall -O3 -report -fsubword-select -DTEST_MODE_SUPPORT -Xmapper --wno226

# U8 - DJ kit
XCC_FLAGS_u8_dj = $(BUILD_FLAGS) -DUSE_XSCOPE=1 -fxscope
INCLUDE_ONLY_IN_u8_dj =

# U16 - Slicekit
XCC_FLAGS_u16_sk = $(BUILD_FLAGS) -DU16=1 -DUSE_XSCOPE=1 -fxscope
INCLUDE_ONLY_IN_u16_sk =

# The XCORE_ARM_PROJECT variable, if set to 1, configures this
# project to create both xCORE and ARM binaries.
XCORE_ARM_PROJECT = 0

# The VERBOSE variable, if set to 1, enables verbose output from the make system.
VERBOSE = 0

# Build two versions of this code - one for U8 kit and one for U16 kit
ifeq ($(CONFIG), u8_dj)
TARGET = xp-skc-su1.xn
	MODULE_LIBRARIES = xud_u
endif

ifeq ($(CONFIG), u16_sk)
TARGET = SLICEKIT-U16
	MODULE_LIBRARIES = xud_u
endif

XMOS_MAKE_PATH ?= ../..
-include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common
