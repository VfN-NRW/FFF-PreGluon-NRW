local uci = luci.model.uci.cursor()

local nav = require "luci.tools.freifunk-wizard.nav"

local f = SimpleForm("hostname", "Name deines Freifunkger&auml;ts", "Als \
n&auml;chstes solltest du deinem Freifunkger&auml;t einen individuellen\
Namen geben. Dieser hilft dir und auch uns den &Uuml;berblick zu behalten.")
local f = SimpleForm("hostname", "Name deines Freifunkger&auml;ts", " \
<p>Als n&auml;chstes solltest du deinem Freifunkger&auml;t einen individuellen Namen geben. Dieser hilft dir und auch uns den &Uuml;berblick zu behalten.</p> \
<p>Eine Kontaktadresse erm&ouml;glicht es uns, im Falle eines Problems mit deinem Ger&auml;t, dich per Email zu erreichen. Wenn wir die Adresse &ouml;ffentlich \
anzeigen d&uuml;rfen, musst du dies explizit aktivieren.</p> \
<p>Bitte trag die Position deines Ger&auml;ts hier ein, mit gesetztem Haken wird dein Ger&auml;t auf unserer Karte angezeigt. Die Koordinaten f&uuml;r dein \
Ger&auml;t findest du <a target=\"_blank\" href=\"http://wk.freifunk.net/map-lev/\">hier</a> heraus.</p> \
<p>Solltest du die Position nicht eintragen, werden wir versuchen die Position deines Freifunkger&auml;ts automatisch zu ermitteln. Dies ist notwendig \
um das Ger&auml;t auf der Karte darzustellen. Wenn du nicht m&ouml;chtest das wir das tun, entferne den Haken bei \"Position automatisch ermitteln\".</p>")
f.template = "freifunk-wizard/wizardform"

hostname = f:field(Value, "hostname", "Ger&auml;tname")
hostname.value = uci:get_first("system", "system", "hostname")
hostname.rmempty = false

contact_mail = f:field(Value, "contact_mail", "Kontakt-Email-Adresse")
contact_mail.value = uci:get_first("system", "system", "contact_mail")
contact_mail.rmempty = false

contact_mail_pub = f:field(Flag, "contact_mail_pub", "Email-Adresse ver&ouml;ffentlichen")
contact_mail_pub.default = string.format("%d", uci:get_first("system", "system", "contact_mail_pub", "0"))
contact_mail_pub.rmempty = false

position_automatic = f:field(Flag, "position_automatic", "Position automatisch ermitteln")
position_automatic.default = string.format("%d", uci:get_first("system", "position", "automatic", "1"))
position_automatic.rmempty = false

position_lat = f:field(Value, "position_lat", "Latitude (Breitengrad)")  
position_lat.value = uci:get_first("system", "position", "lat", "0")

position_lon = f:field(Value, "position_lon", "Longitude (L&auml;ngengrad)")
position_lon.value = uci:get_first("system", "position", "lon", "0")

position_public = f:field(Flag, "position_public", "Position ver&ouml;ffentlichen")
position_public.default = string.format("%d", uci:get_first("system", "position", "public", "1"))
position_public.rmempty = false

function hostname.validate(self, value, section)
  return value
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		
		uci:foreach("system", "system", function(s)
			uci:set("system", s[".name"], "hostname", data.hostname)
			uci:set("system", s[".name"], "contact_mail", data.contact_mail)
			uci:set("system", s[".name"], "contact_mail_pub", data.contact_mail_pub)
			end
		)
		
		uci:foreach("system", "position", function(s)
			if type(data.position_automatic) ~= "nil" then
				uci:set("system", s[".name"], "automatic", data.position_automatic)
			else
				uci:set("system", s[".name"], "automatic", "0")
				end
			if type(data.position_lat) ~= "nil" then
				uci:set("system", s[".name"], "lat", data.position_lat)
			else
				uci:set("system", s[".name"], "lat", "0")
				end
			if type(data.position_lon) ~= "nil" then
				uci:set("system", s[".name"], "lon", data.position_lon)
			else
				uci:set("system", s[".name"], "lon", "0")
				end
			if type(data.position_public) ~= "nil" then
				uci:set("system", s[".name"], "public", data.position_public)
			else
				uci:set("system", s[".name"], "public", "0")
				end
			end
		)
		
		uci:save("system")
		uci:commit("system")
		
		
		nav.maybe_redirect_to_successor()
		f.message = "Ger&auml;tname ge&auml;ndert!"
	end

	return true
end

return f
