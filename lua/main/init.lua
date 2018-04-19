local usersfile = 'iin/users.txt'
local Tag = "iin"
iin = iin or {}

local hide_admins

hook.Add('Initialize','teams',function()

	hide_admins = CreateConVar( "hide_ranks","0", {FCVAR_ARCHIVE,FCVAR_REPLICATED,FCVAR_NOTIFY}, "Please do not watch on my team, nonono" )

	team.SetUp(10,"banni",Color(255,10,10))
	team.SetUp(20, "players",Color(68, 	112, 146))
	
	local color =  false//hide_admins:GetBool() and Color(68, 	112, 146) or false
	
	team.SetUp(30, "admins", color or Color(161, 161, 255))
	team.SetUp(40, "devs", color or Color(149, 255, 0))
	team.SetUp(50, "owners", color or Color(255, 140, 113))
	
	team.SetUp(1001, "bots", Color(68, 112, 146))

	//cvars.AddChangeCallback( "hide_ranks", function( convar_name, value_old, value_new )
	//	if value_new=="1" then
	//		for i=3,5 do
	//			team.SetColor(i,Color(68, 	112, 146))	
	//		end
	//	else
	//		team.SetColor(30,Color(161, 161,  255)	)
	//		team.SetColor(40,Color(138, 0, 255)		)
	//		team.SetColor(50,Color(255, 140, 113)	)
	//	end
	//end)
end)

//team.SetColor

local META = FindMetaTable'Player'
local luadata_ReadFile = luadata.ReadFile


function team.GetIDByName(name)
	for id, data in pairs(team.GetAllTeams()) do
		if data.Name == name then
			return id
		end
	end
	return 1
end


local list ={
	banni = -1,
	players = 5,
	bots = 5,
	admins = 228,
	devs = 1337,
	owners = math.huge,
}

function iin.GetValidGroups()
	return list
end


local function do_insert(ret,cut)
	if cut:Trim()~="" then table.insert(ret,cut:Trim()) end
end

function iin.ParseArgs(str)
	local cutting = false
	local ret = {}
	local cut = ""
	local char = ""
		
	for i=1,#str do
	char = str:GetChar(i)	
		if(char==" ") && (!cutting) then
			do_insert(ret,cut)
			cut=""
		elseif(char=="\"" or char=="'") then 
			do_insert(ret,cut)
			cutting=!cutting
			cut=""
		else 
			cut=cut..char
		end	
	end
	do_insert(ret,cut)
	return ret
end

function META:GetUserGroup()
	return IsValid(self) and self:GetNetworkedString(Tag.."_UserGroup"):lower() or "players"
end

function META:IsUserGroup(group)
	return self:GetUserGroup() == group or false
end


function META:CheckGroupPower(name)

	local ugroup=self:GetUserGroup()
	local a = list[ugroup]
	local b = list[name]
	return a and b and a >= b
	
end

function META:IsAdmin()
	return self:CheckGroupPower('admins') or false
end


function META:IsSuperAdmin()
	return self:CheckGroupPower('devs') or false
end

if SERVER then
util.AddNetworkString'iin_msg'
	function iin.Msg(ply,...)
		net.Start'iin_msg'
		net.WriteTable({...})
		if ply!=nil then net.Send(ply) else net.Broadcast() end
	end
	
	
util.AddNetworkString'iin_msgc_console'
	function iin.MsgC(ply,color,str)
		net.Start'iin_msgc_console'
		net.WriteTable({color,str})
		if ply!=nil then net.Send(ply) else net.Broadcast() end
	end
else
	net.Receive('iin_msg',function()
		chat.AddText(unpack(net.ReadTable()))
	end)
	
	net.Receive('iin_msgc_console',function()
		local Tbl=net.ReadTable()
		MsgC(Tbl[1],Tbl[2])
	end)
	
	function iin.Msg(...)
		chat.AddText(unpack({...}))
	end
end







if SERVER then

	local function clean_users(users, _steamid)

		for name, group in pairs(users) do
			name = name:lower()
			if not list[name] then
				users[name] = nil
			else
				for steamid in pairs(group) do
					if steamid:lower() == _steamid:lower() then
						group[steamid] = nil
					end
				end
			end
		end
		return users
	end	
	
	function META:SetUserGroup(name,write)
		name=name.Trim and name:Trim() or name
		
		self:SetTeam(team.GetIDByName(name))
		//self:SetNoCollideWithTeammates(false)
		
		self:SetNetworkedString(Tag.."_UserGroup", name)

		if write then
			local Users = luadata.ReadFile(usersfile)
			Users = clean_users(Users,self:SteamID())
			Users[name] = Users[name] or {}
			Users[name][self:SteamID()] = self:Nick():gsub("%A", "") or "???"
			luadata.WriteFile(usersfile,Users)
		end
	end
	
	
	local defweps = {}
	defweps['weapon_crowbar']	= true
	defweps['weapon_physcannon']= true
	defweps['weapon_physgun']	= true
	defweps['gmod_tool']		= true
	defweps['gmod_camera']		= true
	
	
	local function DefaultWeapons(ply)
		
		for i,k in pairs(defweps) do
			ply:Give(i)
		end
	
	end

hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
hook.Add("PlayerAuthed","PlayerAuthSpawn",function(ply)
	timer.Simple(0,function()
		ply:SetUserGroup('players')
		
		local users = luadata.ReadFile('iin/users.txt')
		
		for name, users in pairs(users) do
			for steamid in pairs(users) do
				if ply:SteamID() == steamid or ply:UniqueID() == steamid then
					ply:SetUserGroup(name)
				end
			end
		end
		
		if not list[ply:GetUserGroup()] then ply:SetUserGroup'players' end
		
		DefaultWeapons(ply)
		
	end)
end) --hook

end  --if SERVER 

do --modules
	if SERVER then
	include'modules/chatcommands.lua'
	include'modules/addchatcommands.lua'
	include'modules/banni.lua'
	include'modules/permission_playx.lua'
	include'modules/logs.lua'
	include'modules/playerpickup.lua'
	include'modules/sv_fix.lua'
	include'modules/hardbans.lua'
	end
end		
		
		
timer.Simple(1,function() hook.Call(Tag.."_Initialized") end) 
