concommand.Add('banni_list',function(ply)
local banni = luadata.ReadFile('iin/banni.txt')
    iin.MsgC(ply,Color(255,191,0),'\n////////////////////////////////////////////////////////\n')
	for i,k in pairs(banni) do
		iin.MsgC(ply,Color(191,255,0),'['..i..'] - ')
		iin.MsgC(ply,Color(0,255,191),k['name']..' - ')
		iin.MsgC(ply,Color(255,100,100),k['for']=='permanent' and 'permanent\n' or string.NiceTime(os.time()-k['for'])..'\n')
	end
	iin.MsgC(ply,Color(255,191,0),'////////////////////////////////////////////////////////\n')
	if !ply:IsAdmin() then return end
	iin.MsgC(ply,Color(191,255,150),'!unbanni')
	iin.MsgC(ply,Color(255,255,0),' "name/id/steamid"   <- UNBANNI\n')
		iin.MsgC(ply,Color(191,255,150),'!banni')
	iin.MsgC(ply,Color(255,255,0),' "name/id/steamid time"   <- BANNI\n')
	iin.MsgC(ply,Color(255,191,0),'////////////////////////////////////////////////////////\n')
end)


iin.AddCommand("banni",function(ply,args)
	args = iin.ParseArgs(args)
	local id = easylua.FindEntity(args[1])
	local time = string.DateFormat(args[2] or "permanent")

	if id && id:IsPlayer() && !id.IsBanned then
		if time~=false then
			iin.Msg(nil,Color(255,187,0),"● ",ply,Color(255,255,255),' jail\'ed ',id,Color(255,255,255)," for "..string.NiceTime(time)..".")
			id:SetUserGroup('banni')
			id:StripWeapons()
			id.IsBanned = true
			ply:ConCommand("FPP_Cleanup " .. id:UserID())
			local steamid = id:SteamID()
			local bannitxt = luadata.ReadFile('iin/banni.txt')
			bannitxt[steamid] = bannitxt[id:SteamID()] or {}
			bannitxt[steamid]['name'] = id:Nick():gsub("%A","*")
			bannitxt[steamid]['profile'] = "http://steamcommunity.com/profiles/"..id:SteamID64()
			bannitxt[steamid]['for'] = time~=0 and os.time()+time or 'permanent'
			luadata.WriteFile('iin/banni.txt',bannitxt)
					if time<60*60 and time~=0 then timer.Simple(time,function()
						if IsValid(id) then
							id:SetUserGroup('players')
							id.IsBanned = false
							id:Spawn()
						end
						local bannitxt = luadata.ReadFile('iin/banni.txt')
						bannitxt[steamid] = nil
						luadata.WriteFile('iin/banni.txt',bannitxt)
					end)
					
				end
			return
		else
			iin.error(ply,'??INVALID DATE ARGUMENT?? [!banni <Nick> <DateArgument>]')
			return
		end
	end
	print(id)
	if !id:IsPlayer() then
	iin.error(ply,'Not found [!banni <Nick> <DateArgument>]')
	end
end,'admins')

 
iin.AddCommand("unbanni",function(ply,args)
	args = iin.ParseArgs(args)
	local id = easylua.FindEntity(args[1])

	if id && id:IsPlayer() && id.IsBanned then
			iin.Msg(nil,Color(255,187,0),"● ",ply,Color(255,255,255),' unjail\'ed ',id,Color(255,255,255),".")
			id:SetUserGroup('players')
			id.IsBanned = false
			id:Spawn()
			local bannitxt = luadata.ReadFile('iin/banni.txt')
			bannitxt[id:SteamID()] = nil
			luadata.WriteFile('iin/banni.txt',bannitxt)
			return
	end
	if !id:IsPlayer() then
	iin.error(ply,'Not found [!unbanni <Nick>]')
	elseif !id.IsBanned then
	iin.error(ply,'Ply not banned [!unbanni <Nick>]')
	end
end,'admins')

hook.Add("PlayerInitialSpawn","banni",function(ply)
	local users = luadata.ReadFile('iin/banni.txt')
	
	local u = users[ply:SteamID()]
	
	if u then
		if u['for']~='permanent' and u['for'] < os.time() then
			u = nil
			luadata.WriteFile('iin/banni.txt',users)
		else
			timer.Simple(0,function()
			ply:SetUserGroup('banni') 
			ply.IsBanned = true
			ply:StripWeapons()
			end)
			timer.Simple(2,function() ply:SetUserGroup('banni')  end)
		end
	end
end)

hook.Add("PlayerNoClip", "banni",function(p) if p.IsBanned then return false end end)
hook.Add("PlayerLoadout","banni",function(p) if p.IsBanned then return false end end)
hook.Add("PlayerSpawnObject","banni",function(p) if p.IsBanned then return false end end)
hook.Add("PlayerSpawnNPC","banni",function(p) if p.IsBanned then return false end end)
hook.Add("PlayerSpawnSENT","banni",function(p) if p.IsBanned then return false end end)
hook.Add("PlayerSpawnVehicle","banni",function(p) if p.IsBanned then return false end end)
hook.Add("PlayerSpawnSWEP","banni",function(p) if p.IsBanned then return false end end)
hook.Add("PlayerGiveSWEP","banni",function(p) if p.IsBanned then return false end end)
hook.Add("CanPlayerSuicide","banni",function(p) if p.IsBanned then return false end end)