include $(TOPDIR)/rules.mk

PKG_NAME:=tinyfecvpn-easyconf
PKG_VERSION:=1.1
PKG_RELEASE:=2

include $(INCLUDE_DIR)/package.mk

define Package/tinyfecvpn-easyconf
	SECTION:=VPN
	CATEGORY:=Network
	TITLE:=tinyFecVPN with Easy UCI/LuCI Configuration
	DEPENDS:=+kmod-tun
endef

define Package/tinyfecvpn-easyconf/description
	Wrapper for tinyFecVPN: includes UCI config, init.d script, hotplug and LuCI app.
endef

define Build/Compile
	@true
endef

define Package/tinyfecvpn-easyconf/install
	# 1) Install the VPN binary
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) files/usr/bin/tinyfec $(1)/usr/bin/tinyfec

	# 2) UCI configuration
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) files/etc/config/tinyvpnconf $(1)/etc/config/tinyvpnconf

	# 3) init.d service script
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/etc/init.d/tinyvpnconf $(1)/etc/init.d/tinyvpnconf

	# 4) Hotplug interface script
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) files/etc/hotplug.d/iface/30-tinyfec $(1)/etc/hotplug.d/iface/30-tinyfec
endef

$(eval $(call BuildPackage,tinyfecvpn-easyconf))

