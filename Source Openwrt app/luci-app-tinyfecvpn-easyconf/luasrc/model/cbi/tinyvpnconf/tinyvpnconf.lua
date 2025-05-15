local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

local config = Map("tinyvpnconf", translate("TinyFEC Configuration"))
local view   = config:section(NamedSection, "Setup", "config", translate("General settings"))

-- Flag di abilitazione
local enabled = view:option(Flag, "enabled", translate("Enable"),
  translate("Enables TinyFEC vpn service."))
enabled.optional = false
enabled.rmempty  = false

function enabled.write(self, section, value)
  -- 1) Salva su disco via UCI
  uci:set("tinyvpnconf", section, "enabled", value)
  uci:save("tinyvpnconf")
  uci:commit("tinyvpnconf")

  -- 2) Toggle del servizio
  if value == "1" then
    sys.exec("/etc/init.d/tinyvpnconf enable")
    sys.exec("/etc/init.d/tinyvpnconf start")
  else
    sys.exec("/etc/init.d/tinyvpnconf stop")
    sys.exec("/etc/init.d/tinyvpnconf disable")
  end
end

-- Password
local pass = view:option(Value, "pass", translate("Password"),
  translate("The password defined on the server setup."))
pass.password = true
pass.optional = false
pass.rmempty  = false

-- Server IP Address
local server = view:option(Value, "dstAddr", translate("Server IP Address"),
  translate("The server IPv4."))
server.datatype = "ipaddr"
server.optional = false
server.rmempty  = false

-- Server Port
local port = view:option(Value, "dstPort", translate("Server Port"),
  translate("Port on which TinyFEC will connect to the server."))
port.datatype = "port"
port.default  = "4000"
port.optional = false
port.rmempty  = false

-- FEC Parameters
local fec = view:option(Value, "fecParam", translate("FEC Parameters"),
  translate("Forward error correction: send Y redundant packets for every X packets (format X:Y)."))
fec.optional = false
fec.rmempty  = false

-- Tunnel Subnet
local subnet = view:option(Value, "subnet", translate("Tunnel Subnet"),
  translate("Network address for the tunnel device, e.g. 10.22.22.0/24."))
subnet.datatype = "ipmask"
subnet.default  = "10.22.22.0/24"
subnet.optional = false
subnet.rmempty  = false

function config.on_commit(self)
  -- Riavvia il servizio quando si cambiano altri parametri (se abilitato)
  if uci:get("tinyvpnconf", "Setup", "enabled") == "1" then
    sys.exec("/etc/init.d/tinyvpnconf restart")
  end
end

return config

