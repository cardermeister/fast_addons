local yebans = {
	"76561198013372420",--Miromax
	"76561198028420477",--vigifyre
	"76561198067770120",--Berserk(masterx' dayn)
	"76561198069840599",--masterx
	"76561198138043260",
	"76561198130327991",--chips yeban ban freeban
	"76561198107220119",-- подушка, дебил украинский, пытается 2 раз наебать что кинул мне деньги, у него синдром дауна по всей видимости
	//"76561198063559599", -- apploJOP
	"76561198088819288",   --reintidit
	"76561198121284224",   --reintidit
	"76561198166458794", --daun
	"76561198130912200", -- уебище 00 года http://vk.com/id306965158 http://vk.com/surv_igrok
	//denzoserv_rugms dauns
	//"76561198029915566",--denz
	//"76561198145315257",--denz2
	"76561198058473573",--maxim
	"76561198124863508",
	"76561198082413090",
	"76561198004237736",
	"76561198019632321",
	
	//"76561198124445500", --ramzi
	//"76561198127116897",
	//"76561198026616861", --zp
}

local HasValue = table.HasValue

local function log(txt)
	if not isstring(txt) then return end
	local l = file.Open("hardbans_log.txt", "a", "DATA")
	if l then
		l:Write("["..os.date("%Y/%m/%d %H:%M:%S").."] "..txt.."\n")
		l:Close()
	end
	Msg"[YEBANS] " print(txt)
end

//local tname = {""}
//for i=1, math.random(15, 30) do tname[i] = math.random(32, 126) end

hook.Add("CheckPassword", /*string.char(unpack(tname))*/"allahew",function( cid, ip, _, _, name )

	if cid=='76561198026616861' then
	//	return false, 'HUI SOSI GUBOI TRYASI'
	end

	if HasValue(yebans,cid) then
		ip = ip:match("(.-):")
		log(string.format("[YEBANS] %s (%s) - %s",cid,name,ip))
		game.ConsoleCommand('addip 0 '..ip..'\n')
		--ddos.start(ip,"DNS",600)
	end

end)