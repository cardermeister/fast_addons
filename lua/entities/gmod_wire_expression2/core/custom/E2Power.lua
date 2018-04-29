-- E2Power by [G-moder]|-|u3505

if !E2Power then
	timer.Simple( 10, wire_expression2_reload)
	E2Power = {}
	E2Power.FirstLoad = true
else 
	if E2Power.FirstLoad then 
		E2Power.FirstLoad = nil
		E2Power.Inite2commands()
		return
	end
end

local function printMsg(ply,msg)
	if ply:IsValid() then ply:PrintMessage( HUD_PRINTCONSOLE , msg) else MsgN(msg) end
end

local function findPlayer(tar)
	if not tar then return NULL end
	tar = tar:lower()
	local players = player.GetAll()
	for _, ply in ipairs( players ) do
		if string.find(ply:Nick():lower(),tar,1,true) then
			return ply
		end
	end
	for _, ply in ipairs( players ) do
		if ply:SteamID():lower() == tar then
			return ply
		end
	end
	for _, ply in ipairs( players ) do
		if tostring(ply:EntIndex()) == tar then
			if ply:IsPlayer() then return ply end
		end
	end
	return NULL
end 

	
local PlyAccess = {}
//local Version = tonumber(file.Read( "version/E2power_version.txt", "GAME"))
local SVNVersion = 0

//SetGlobalString("E2PowerVersion",tostring(Version))
--SetGlobalBool("E2PowerFreeStatus", tobool(Free:GetInt()) )

local function checkPly(ply) 
	if !IsValid(ply) then return true end
	if ply:IsSuperAdmin() or ply:IsAdmin() then return true end
end

local function PlyHasAccess(ply)
	return PlyAccess[ply]
end

local function GiveAccess(ply,who)
	if !checkPly(who) then return {false,0,"You don`t have access"} end
	if !IsValid(ply) then return {false,0,"Player not found"} end
	PlyAccess[ply]=true
	ply:SetNWBool("E2PowerAccess",true)
	ply:SetCheater(true)
	return {true,1,"Access was given"}
end

local function RemoveAccess(ply,who)
	if !checkPly(who) then return {false,0,"You don`t have access"} end
	if !IsValid(ply) then return {false,0,"Player not found"} end
	PlyAccess[ply]=nil
	ply:SetNWBool("E2PowerAccess",false)
	return {true,1,"Access was removed"}
end

--hook.Add('iin_Initialized','e2p_iin_lol',function()
concommand.Add('e2power_list',function(ply)
local permissions = luadata.ReadFile('iin/permissions.txt')["E2Power"]
	iin.MsgC(ply,Color(255,191,0),'////////////////////////////////////////////////////////\n')
	local t = {}
	for i,k in pairs(player.GetHumans()) do t[k:SteamID()] = true end
	for i,k in pairs(permissions) do
		local online = Color(255,0,0)
		if t[i] then
			online =  Color(0,255,0)
		end
		iin.MsgC(ply,online,' ● ')
		iin.MsgC(ply,Color(191,255,0),'['..i..'] - ')
		iin.MsgC(ply,Color(0,255,191),k..'\n')
	end
	iin.MsgC(ply,Color(255,191,0),'////////////////////////////////////////////////////////\n')
	if !ply:IsAdmin() then return end
	iin.MsgC(ply,Color(191,255,0),'!give_e2power')
	iin.MsgC(ply,Color(255,255,0),' "name/id/steamid"   <- GIVE ACCESS\n')
	iin.MsgC(ply,Color(191,255,0),'!take_e2power')
	iin.MsgC(ply,Color(255,255,0),' "name/id/steamid"   <- TAKE ACCESS\n')
	iin.MsgC(ply,Color(255,191,0),'////////////////////////////////////////////////////////\n')
end)

iin.AddCommand('give_e2power',function(ply,args)

	args = iin.ParseArgs(args)
	local id = easylua.FindEntity(args[1])

	if id:IsPlayer() then
		local permissions = luadata.ReadFile('iin/permissions.txt')
		GiveAccess(id)
		if !permissions["E2Power"] then permissions["E2Power"] = {} end
		permissions["E2Power"][id:SteamID()] = id:Name()
		luadata.WriteFile('iin/permissions.txt',permissions)
		iin.Msg(nil,Color(255,187,0),"● ",ply,Color(255,255,255),' give e2power access ',id,Color(255,255,255),'.')
	else
		iin.error(ply,'Player not found.')
	end

end,'devs')

iin.AddCommand('take_e2power',function(ply,args)
args = iin.ParseArgs(args)

if args[1]:find('STEAM_') then
	local steamid = args[1]
	
	local permissions = luadata.ReadFile('iin/permissions.txt')
	permissions["E2Power"][steamid] = nil
	luadata.WriteFile('iin/permissions.txt',permissions)
	iin.Msg(nil,Color(255,187,0),"● ",ply,Color(255,255,255),' took e2power access ',steamid,Color(255,255,255),'.')
	return
end


local id = easylua.FindEntity(args[1])

if id:IsPlayer() then
	local permissions = luadata.ReadFile('iin/permissions.txt')
	RemoveAccess(id)
	permissions["E2Power"][id:SteamID()] = nil
	luadata.WriteFile('iin/permissions.txt',permissions)
	iin.Msg(nil,Color(255,187,0),"● ",ply,Color(255,255,255),' took e2power access ',id,Color(255,255,255),'.')
else
	iin.error(ply,'Player not found.')
end

end,'devs')
--end)



hook.Add("PlayerInitialSpawn", "E2Power_CheckPlayer", function(ply)	
	
	if ply:IsBot() then return end
	
	timer.Simple(5,function()
		if IsValid(ply) then
			local permissions = luadata.ReadFile('iin/permissions.txt')

			if permissions['E2Power'][ply:SteamID()] then
				GiveAccess(ply)
				iin.Msg(ply,Color(255,187,0)," ● ",Color(0,255,255),'E2power ',Color(255,255,255),'access was given.')
			end
		end
	end)
end)


if not E2Power.isOwnerOld then
	E2Power.isOwnerOld = isOwner
	isOwnerOld = isOwner
end


function isOwner(self, entity)
	local player = self.player
	if PlyAccess[player] then return true end

	local owner = getOwner(self, entity)
	if not IsValid(owner) then return false end

	return owner == player
end


E2Power.PlyHasAccess = PlyHasAccess
E2Power.findPlayer = findPlayer
------------------------------------------------------------CONSOLE COMMAND
concommand.Add("e2power_all_remove_access", function(who)
	for _, ply in ipairs(player.GetAll()) do
		RemoveAccess(ply, who)
	end
end)

	

	
-------------------------------------------------------------E2 COMMAND
function E2Power.Inite2commands()
	__e2setcost(20)
end
E2Power.Inite2commands()
