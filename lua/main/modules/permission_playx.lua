hook.Add("PlayerInitialSpawn","PlayXPermissionedGroup",function(ply)
	timer.Simple(2,function()
		if luadata.ReadFile('iin/permissions.txt')['PlayX'][ply:SteamID()] or ply:IsAdmin() then
			ply:SetNWString("PlayXAcсess",true)
			iin.Msg(ply,Color(255,187,0)," ● ",Color(0,255,255),'PlayX',Color(255,255,255)," access was given.")
		end
	end)
end)

concommand.Add('playx_list',function(ply)
local permissions = luadata.ReadFile('iin/permissions.txt')["PlayX"]
    iin.MsgC(ply,Color(255,191,0),'\n////////////////////////////////////////////////////////\n')
	for i,k in pairs(permissions) do
		iin.MsgC(ply,Color(191,255,0),'['..i..'] - ')
		iin.MsgC(ply,Color(0,255,191),k..'\n')
	end
	iin.MsgC(ply,Color(255,191,0),'////////////////////////////////////////////////////////\n')
	if !ply:IsAdmin() then return end
	iin.MsgC(ply,Color(191,255,150),'!give_playx')
	iin.MsgC(ply,Color(255,255,0),' "name/id/steamid"   <- GIVE ACCESS\n')
		iin.MsgC(ply,Color(191,255,150),'!take_playx')
	iin.MsgC(ply,Color(255,255,0),' "name/id/steamid"   <- TAKE ACCESS\n')
	iin.MsgC(ply,Color(255,191,0),'////////////////////////////////////////////////////////\n')
	
end)

iin.AddCommand('give_playx',function(ply,args)
args = iin.ParseArgs(args)
id = easylua.FindEntity(args[1])

if id:IsPlayer() then
	local permissions = luadata.ReadFile('iin/permissions.txt')
	if !permissions["PlayX"] then permissions["PlayX"] = {} end
	permissions["PlayX"][id:SteamID()] = id:Name()
	luadata.WriteFile('iin/permissions.txt',permissions)
	id:SetNWString("PlayXAcсess",true)
	iin.Msg(nil,Color(255,187,0),"● ",ply,Color(255,255,255),' give access to playx ',id,Color(255,255,255),'.')
else
	iin.error(ply,'Player not found.')
end

end,'devs')

iin.AddCommand('take_playx',function(ply,args)
args = iin.ParseArgs(args)
id = easylua.FindEntity(args[1])


if id:IsPlayer() then
	local permissions = luadata.ReadFile('iin/permissions.txt')
	permissions["PlayX"][id:SteamID()] = nil
	luadata.WriteFile('iin/permissions.txt',permissions)
	id:SetNWString("PlayXAcсess",false)
	iin.Msg(nil,Color(255,187,0),"● ",ply,Color(255,255,255),' took access to playx ',id,Color(255,255,255),'.')
else
	iin.error(ply,'Player not found.')
end

end,'devs')
