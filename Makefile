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

# 关键修改：判断是否处于索引阶段（KERNEL_VERSION 未定义）
ifndef KERNEL_VERSION
# 索引阶段：提供 packageinfo 目标，供 scripts/feeds 收集信息
packageinfo:
	@echo "Package: r8125"
	@echo "Version: $(PKG_VERSION)-$(PKG_RELEASE)"
	@echo "Depends: +kmod-r8125"
	@echo "Category: Kernel modules"
	@echo "Section: kernel"
	@echo "Title: Driver for Realtek r8125 chipsets"
	@echo "Description: This package contains a driver for Realtek r8125 chipsets."
	@echo "License: GPL-2.0"
else
# 正常编译阶段：使用标准 KernelPackage 宏
define KernelPackage/r8125
  SUBMENU:=Network Devices
  TITLE:=Driver for Realtek r8125 chipsets
  VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  FILES:= $(PKG_BUILD_DIR)/r8125.ko
  AUTOLOAD:=$(call AutoProbe,r8125)
  DEFAULT:=y
endef

define Package/r8125/description
 This package contains a driver for Realtek r8125 chipsets.
endef

$(eval $(call KernelPackage,r8125))
endif
