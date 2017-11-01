local Tag = "php_geoip"

local apiurl = "http://195.2.252.214/files/phps/sxgeo/?ip="
geoip = {}

local Fetch = http.Fetch
local curtime = CurTime


local Lang = "ru"

local PLAYER = FindMetaTable'Player'

/*
local OldAddress = PLAYER.IPAddress

function PLAYER:IPAddress()
	if self:IsCard() then
		return "133.87.155.227:8080"
	end
	return OldAddress(self)
end
*/

function PLAYER:GeoipString(Lang)

	local ip = self:IPAddress():match("(.-):")
	local json = geoip[ip]

	if not json then
		return "Not determined"
	end

	local country 	= json.country["name_"..Lang]
	local region 	= json.region["name_"..Lang]
	local city 		= json.city["name_"..Lang]
	local crctxt = 	(#country>0 and country or "N/A")..
					(#region>0 and ', '..region or "")..
					(#city>0 and ', '..city or "")	
	return crctxt

end


function PLAYER:GeoIP()
	local ip = self:IPAddress():match("(.-):")
	local json = geoip[ip]
	
	if json then
		return json
	else
		ErrorNoHalt("Can't find this location of this IP: "..ip)
	end
end

function GetIP(name,ip_port)
	
	local ip = ip_port:match("(.-):")
	local startfetch = curtime()

	Fetch(apiurl..ip,function(s)
		if #s < 10 then return end
		local json = util.JSONToTable(s)

		if not json then return end
		geoip[ip] = json

		local country 	= json.country["name_"..(Lang or "ru")]
		local region 	= json.region["name_"..(Lang or "ru")]
		local city 	= json.city["name_"..(Lang or "ru")]
		local crctxt = 	(#country>0 and country or "N/A")..
						(#region>0 and ', '..region or "")..
						(#city>0 and ', '..city or "")	
		
		local delta = curtime()-startfetch
		
		Msg"[Geoip] "print(name,"-",crctxt,"(Δ"..tostring(delta)..")")	
		
	end)
	
end

--GetIP(me:Name(),me:IPAddress())


hook.Add( "PlayerConnect",Tag, function(name,address)
	
	if address == "none" then return end

	GetIP(name,address)
end)

hook.Add("PlayerInitialSpawn",Tag,function(ply)
	local ip = ply:IPAddress():match("(.-):")
	local str = geoip[ip]
	
	ply:SetNWString("location",string.format("%s <%s>",ply:GeoipString("ru"),ip))
	
	if str and str.country and str.country.iso then
		ply:SetNWString("ISO",str.country.iso or "NR")
	end
end)


