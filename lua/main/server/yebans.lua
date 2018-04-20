yebans = {
	["76561198013372420"] = "Miromax",
	["76561198028420477"] = "vigifyre",
	["76561198067770120"] = "Berserk(masterx' dayn)",
	["76561198069840599"] = "masterx",
	["76561198138043260"] = "unknown",
	--["76561198063559599"], -- apploJOP
	["76561198088819288"] = "reintidit",
	["76561198121284224"] = "reintidit",
	["76561198166458794"] = true, --daun
	["76561198130912200"] = true, -- уебище 00 года http://vk.com/id306965158 http://vk.com/surv_igrok
	--["76561198029915566"],--denz
	--["76561198145315257"],--denz2
	["76561198058473573"] = "maxim",
	["76561198124863508"] = true,
	["76561198082413090"] = true,
	["76561198004237736"] = true,
	["76561198019632321"] = true,
	--["76561198124445500"], --ramzi
	--["76561198127116897"],
}

local function log(txt)
	if not isstring(txt) then return end
	local l = file.Open("hardbans_log.txt", "a", "DATA")
	if l then
		l:Write("["..os.date("%Y/%m/%d %H:%M:%S").."] "..txt.."\n")
		l:Close()
	end
	Msg"[YEBANS] " print(txt)
end

hook.Add("CheckPassword", "na_banan" ,function( cid, ip, _, _, name )
	if cid == "76561198133277560" then
		return false, "#GameUI_RefreshLogin_InfoTicketExpired"
	end
	if yebans[cid] then
		ip = ip:match("(.-):")
		log(string.format("[YEBANS] %s [%s] (%s) - %s",cid,yebans[cid],name,ip))
		game.ConsoleCommand('addip 0 '..ip..'\n')
                return false, "#VAC_ConnectionRefusedDetails"
		--ddos.start(ip,"DNS",600)
	end

end)
