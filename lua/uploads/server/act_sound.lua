util.AddNetworkString"URLSound"

local plys_cd = {}

FindMetaTable"Player".PlayURL = function( self ,url, pitch, vol )
	net.Start'URLSound'
		net.WriteEntity(self)
		net.WriteString(url)
		net.WriteFloat( pitch or 1 )
		net.WriteFloat( vol or 1 )
	net.Broadcast()
end

PlayURL = function( url, pitch, vol )
	net.Start'URLSound'
		net.WriteEntity( game.GetWorld() )
		net.WriteString( url )
		net.WriteFloat( pitch or 1 )
		net.WriteFloat( vol or 1 )
	net.Broadcast()
end

soundid = soundid or {}

local sounds = {
    [55] = {
    "https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/acthalt1loud.mp3",
    "https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/acthalt2loud.mp3",
    "https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/acthalt3loud.mp3"
    },
    [54] = "https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/actgroup1.mp3",
    [1611] = {
    "https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/actbecon1loud.mp3",
    "https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/actbecon2loud.mp3"
    },
    [1642] = 'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/ve4erinka.mp3',
    [1641] = {
    'https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban5.mp3',
    'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/zombik.mp3',
	'https://raw.githubusercontent.com/ZpyduCat/sas/master/Sas/zombie_act.mp3'
    },
    [53] = 'https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban6.mp3',
    [1613] = 'https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban28.mp3',
    [1610] = 'https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban24.mp3',
    [1615] = {
    	'https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban11.mp3',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/allahu_akbar01.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/allahu_akbar02.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam01.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam02.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam03.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam04.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam05.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam06.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam07.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam08.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam09.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam10.ogg',
    	'https://raw.githubusercontent.com/Daimyo21/Insurgency-dy-sourcemod/master/allahuakbar/roam11.ogg'
    },
    [1618] = {
        'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/eblanlaugh.mp3',
        'https://aww.moe/oqmuk0.mp3',
        'https://aww.moe/mkskyu.mp3',
		'https://raw.githubusercontent.com/ZpyduCat/sas/master/Sasi/laugh_actick.mp3'
    },
    [1617] = 'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/%D1%86%D0%BF.mp3',
    [1612] = 'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/kalnawel.mp3',
    [1620] = 'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/etomoidom.mp3',
    [1643] = {
        'https://aww.moe/r28qix.mp3',
        'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/ro6at2.mp3'
    },
    [1614] = 'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/hivariant1.mp3',
    [1616] = {
	'https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/skare.mp3',
	'https://raw.githubusercontent.com/ZpyduCat/sas/master/Sas/magak.mp3'
	},
	[2020] = 'https://raw.githubusercontent.com/ZpyduCat/sas/master/Sas/give_pizdi.mp3',
	[2023] = 'https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban60.mp3'
}


local function nebidlakod(ply,act)
	local tbl = sounds[act]
	local id = soundid[ply]
	
	if plys_cd[ply:SteamID()] then return end
	
	if id and tbl[id] and istable(tbl) then
		ply:PlayURL( tbl[id] )
	elseif istable(tbl) then
		local rand,_ = table.Random(tbl)
		ply:PlayURL( rand )
	elseif sounds[act] then
		ply:PlayURL( tbl )
	end
	
	plys_cd[ply:SteamID()] = true
	timer.Create("sasi." .. ply:SteamID(), 0.1, 1, function() plys_cd[ply:SteamID()] = nil end)
	soundid[ply] = nil
end

local function tojnonebidlakod(ply,args)
	args =  iin.ParseArgs(args)
	local name = args[1]
	local id = args[2] and tonumber(args[2]) or nil
		
	if id then
		soundid[ply] = id
	end
	
	ply:SendLua( string.format("RunConsoleCommand('act','%s')",name))
	return false
end

iin.AddCommand("act",tojnonebidlakod,nil,true)

hook.Add("PlayerShouldTaunt","tauntpricol",nebidlakod)