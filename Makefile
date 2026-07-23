#Download realtek r8125 linux driver from official site
#Unpack source file
#Replace orginal Makefile with this file
#Put this source to 'package' folder of OpenWRT SDK
#Build(make menuconfig, make defconfig, make)

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=r8125
PKG_VERSION:=9.016.01
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
#PKG_CAT:=bzcat

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# 安全处理：索引阶段 LINUX_VERSION 可能未定义，此时不调用 AutoProbe
AUTOLOAD_VALUE = $(if $(LINUX_VERSION),$(call AutoProbe,r8125),)

define KernelPackage/r8125
  SUBMENU:=Network Devices
  TITLE:=Driver for Realtek r8125 chipsets
  # 使用固定的版本格式，避免依赖未定义变量
  VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  FILES:= $(PKG_BUILD_DIR)/r8125.ko
  AUTOLOAD:=$(AUTOLOAD_VALUE)
  DEFAULT:=y
endef

define Package/r8125/description
 This package contains a driver for Realtek r8125 chipsets.
endef

R8125_MAKEOPTS= -C $(PKG_BUILD_DIR) \
                PATH="$(TARGET_PATH)" \
                ARCH="$(LINUX_KARCH)" \
                CROSS_COMPILE="$(TARGET_CROSS)" \
                TARGET="$(HAL_TARGET)" \
                TOOLPREFIX="$(KERNEL_CROSS)" \
                TOOLPATH="$(KERNEL_CROSS)" \
                KERNELPATH="$(LINUX_DIR)" \
                KERNELDIR="$(LINUX_DIR)" \
                LDOPTS=" " \
                DOMULTI=1

define Build/Prepare
        mkdir -p $(PKG_BUILD_DIR)
        $(CP) ./src/* $(PKG_BUILD_DIR)
endef

define Build/Compile
        $(MAKE) $(R8125_MAKEOPTS) modules
endef

$(eval $(call KernelPackage,r8125))
