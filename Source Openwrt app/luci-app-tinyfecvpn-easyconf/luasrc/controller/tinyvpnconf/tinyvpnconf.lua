module("luci.controller.tinyvpnconf.tinyvpnconf", package.seeall)

local sys = require "luci.sys"

function index()
    local e = entry({"admin", "vpn", "tinyvpnconf"}, firstchild(), _("TinyFEC"), 70)
    e.acl_depends = { "luci-app-tinyfecvpn-easyconf" }
    e.dependent = false

    -- unica tab rimasta: Configuration
    entry(
      {"admin", "vpn", "tinyvpnconf", "config"},
      cbi("tinyvpnconf/tinyvpnconf"),
      _("Configuration"),
      2
    )
end

