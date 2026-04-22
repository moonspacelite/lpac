# SPDX-License-Identifier: AGPL-3.0-only
#
# lpac v2.3.0 - Override feed resmi (v2.2.1) dengan versi terbaru
# Target: arm_cortex-a7_neon-vfpv4 (ipq40xx, Linksys EA6350v3)
# Backend: AT (ttyACM) + MBIM

include $(TOPDIR)/rules.mk

PKG_NAME:=lpac
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/estkme-group/lpac/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=skip

PKG_MAINTAINER:=Custom build for EA6350v3
PKG_LICENSE:=AGPL-3.0-only LGPL-2.0-only

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# Definisi backend sebagai variabel agar tidak perlu Config.in
# Ini menghindari error "glob failed: No files found feeds/base/lpac/Config.in"
LPAC_WITH_AT:=ON
LPAC_WITH_MBIM:=ON
LPAC_WITH_PCSC:=OFF
LPAC_WITH_UQMI:=OFF

define Package/lpac
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=eUICC eSIM LPA written in C (v$(PKG_VERSION))
  DEPENDS:= +libmbim +libcurl
  URL:=https://github.com/estkme-group/lpac
endef

define Package/lpac/description
  lpac v$(PKG_VERSION) - eUICC eSIM LPA manager.
  Backend: AT (ttyACM/ttyUSB) dan MBIM (/dev/cdc-wdm*)
  Target: Fibocom L850-GL pada OpenWrt 24.10 ipq40xx.
endef

# Konfigurasi opsional via .config jika ada Config.in
# Fallback ke nilai hardcoded di atas jika tidak ada
ifdef CONFIG_LPAC_WITH_AT
  LPAC_WITH_AT:=$(if $(CONFIG_LPAC_WITH_AT),ON,OFF)
endif
ifdef CONFIG_LPAC_WITH_MBIM
  LPAC_WITH_MBIM:=$(if $(CONFIG_LPAC_WITH_MBIM),ON,OFF)
endif
ifdef CONFIG_LPAC_WITH_PCSC
  LPAC_WITH_PCSC:=$(if $(CONFIG_LPAC_WITH_PCSC),ON,OFF)
endif
ifdef CONFIG_LPAC_WITH_UQMI
  LPAC_WITH_UQMI:=$(if $(CONFIG_LPAC_WITH_UQMI),ON,OFF)
endif

TARGET_CFLAGS += $(FPIC)

CMAKE_OPTIONS += \
  -DLPAC_WITH_APDU_PCSC=$(LPAC_WITH_PCSC) \
  -DLPAC_WITH_APDU_AT=$(LPAC_WITH_AT) \
  -DLPAC_WITH_APDU_UQMI=$(LPAC_WITH_UQMI) \
  -DLPAC_WITH_APDU_MBIM=$(LPAC_WITH_MBIM) \
  -DLPAC_WITH_APDU_QMI_QRTR=OFF

define Package/lpac/conffiles
  /etc/config/lpac
endef

define Package/lpac/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/lpac.sh $(1)/usr/bin/lpac

	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/lpac.uci $(1)/etc/config/lpac

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpac $(1)/usr/lib/lpac
endef

$(eval $(call BuildPackage,lpac))
