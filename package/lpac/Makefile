# SPDX-License-Identifier: AGPL-3.0-only
#
# lpac v2.3.0 - eUICC eSIM LPA written in C
# Target: arm_cortex-a7_neon-vfpv4 (ipq40xx/generic, Linksys EA6350v3)
# Backends enabled: AT (ttyACM) + MBIM
#
# CATATAN libcurl:
#   libcurl di OpenWrt 24.10 di-compile dengan mbedTLS yang tidak support
#   TLS handshake ke GSMA provisioning server (ecdsa-with-SHA256 + TLSv1.3).
#   Workaround: lpac di-link ke libcurl yang dibundle oleh CMake dengan OpenSSL,
#   dikontrol via -DLPAC_USE_SYSTEM_HTTP=OFF dan build curl internal.
#   Jika SDK kamu sudah punya libcurl-openssl, ganti ke system http.

include $(TOPDIR)/rules.mk

PKG_NAME:=lpac
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/estkme-group/lpac/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=661dffbd1e9e5732dab4a0bb0a9837d4906c8c66bd748bda262fe3e8d3e420f6

# Jika hash sudah diketahui, ganti baris di atas dengan:
# PKG_HASH:=<sha256sum dari tarball>

PKG_MAINTAINER:=Custom build for EA6350v3
PKG_LICENSE:=AGPL-3.0-only LGPL-2.0-only

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lpac
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=eUICC eSIM LPA written in C (v$(PKG_VERSION))
  # AT backend: tidak perlu dependensi tambahan (langsung baca /dev/ttyACM*)
  # MBIM backend: butuh libmbim
  DEPENDS:= \
    +LPAC_WITH_MBIM:libmbim \
    +libcurl
  URL:=https://github.com/estkme-group/lpac
endef

define Package/lpac/description
  lpac adalah eUICC LPA manager written in C, v$(PKG_VERSION).
  Build ini mengaktifkan backend AT (ttyACM/ttyUSB) dan MBIM
  untuk Fibocom L850-GL pada OpenWrt 24.10 ipq40xx.
endef

define Package/lpac/config
  source "$(SOURCE)/Config.in"
endef

define Package/lpac/conffiles
  /etc/config/lpac
endef

# ---- Compiler flags ----
TARGET_CFLAGS += $(FPIC)

# ---- CMake options ----
CMAKE_OPTIONS += \
  -DLPAC_WITH_APDU_PCSC=OFF \
  -DLPAC_WITH_APDU_AT=ON \
  -DLPAC_WITH_APDU_UQMI=OFF \
  -DLPAC_WITH_APDU_MBIM=$(if $(CONFIG_LPAC_WITH_MBIM),ON,OFF) \
  -DLPAC_WITH_APDU_QMI_QRTR=OFF

# Workaround libcurl/mbedTLS: gunakan HTTP driver internal lpac yang
# membundle curl sendiri dengan OpenSSL (jika upstream mendukung),
# atau fallback ke libcurl system (sesuai kondisi SDK).
# Uncomment baris berikut jika lpac v2.3.0 mendukung bundled curl:
# CMAKE_OPTIONS += -DLPAC_USE_SYSTEM_HTTP=OFF

define Package/lpac/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/lpac.sh $(1)/usr/bin/lpac

	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/lpac.uci $(1)/etc/config/lpac

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpac $(1)/usr/lib/lpac
endef

$(eval $(call BuildPackage,lpac))
