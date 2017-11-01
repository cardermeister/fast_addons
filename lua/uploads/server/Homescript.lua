HOME = {}
HOME.Homes = {}

local function Notify(ply,text)
	if type(ply) ~= "Player" then return end
	
	ply:SendLua('chat.AddText(Color(200,200,255),"' .. text .. '")')
end

local function GoHome(ply)
	if type(ply) ~= "Player" then return end
	
	plysi = ply:SteamID()
	if type(HOME.Homes[plysi]) == "table" then
		ply:SetPos(HOME.Homes[plysi][1])
		ply:SetEyeAngles(HOME.Homes[plysi][2])
		if HOME.Homes[plysi][3] then
			ply:SendLua('RunConsoleCommand("+duck") timer.Simple(0.1,function() RunConsoleCommand("-duck") end)')
		end
	end
end

hook.Add("PlayerSpawn","HOME_spawnhook",function(ply)
	GoHome(ply)
end)

hook.Add("PlayerSay","HOME_chathook",function(ply,mes)
	if type(ply) ~= "Player" then return end
	
	local plysi = ply:SteamID()
	
	if mes == "!sethome" then
		HOME.Homes[plysi] = {ply:GetPos(),ply:EyeAngles(),ply:Crouching()}
		Notify(ply,"Home set.")
	elseif mes == "!home" then
		GoHome(ply)
	elseif mes == "!removehome" then
		HOME.Homes[plysi] = nil
		Notify(ply,"Home removed.")
	elseif mes == "!spawn" then
		ply:Spawn()
	end
end)