local uci = luci.model.uci.cursor()

local nav = require "luci.tools.freifunk-wizard.nav"

local f = SimpleForm("hostname", "Name deines Freifunkknotens", "Als \
n&auml;chstes solltest du deinem Freifunkger&auml;t einen individuellen\
Namen geben. Dieser hilft dir und auch uns den &Uuml;berblick zu behalten.")
f.template = "freifunk-wizard/wizardform"

hostname = f:field(Value, "hostname", "Ger&auml;tname")
hostname.value = uci:get_first("system", "system", "hostname")
hostname.rmempty = false

function hostname.validate(self, value, section)
  return value
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    local stat = true
    uci:foreach("system", "system", function(s)
        stat = stat and uci:set("system", s[".name"], "hostname", 
data.hostname)
      end
    )

    stat = stat and uci:save("system")
    stat = stat and uci:commit("system")

    if stat then
      nav.maybe_redirect_to_successor()
            f.message = "Ger&auml;tname ge&auml;ndert!"
    else
      f.errmessage = "Fehler!"
    end
  end

  return true
end

return f
