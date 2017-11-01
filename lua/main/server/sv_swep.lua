ChatAddText(Color(255,255,255),"MODDED",debug.getinfo(1,"S").source)

local META = FindMetaTable'Player'
function META:IsCheater() 
	return self:GetNWBool('cheater') or false
end

function META:SetCheater(bool) 
	self:SetNWBool('cheater',bool)
end

local m = FindMetaTable'Weapon'

function m:SetAmmo(c,secondary)
		
	self.Owner:SetAmmo(c or 100, secondary and self:GetSecondaryAmmoType() or self:GetPrimaryAmmoType())
	
end

local wl = {}
wl['weapon_crowbar']	 = false
wl['weapon_physcannon']	 = true
wl['weapon_physgun']	 = true
wl['gmod_tool']			 = true
wl['gmod_camera']		 = true
wl['laserpointer']		 = true
wl['remotecontroller']	 = true

hook.Add('PlayerSpawnSWEP','spawnswep1337',function( ply, class, wep )
	if ply.IsBanned then return false end
	if wl[class] then return true end
	return ply:IsCheater()
end)

hook.Add('PlayerGiveSWEP','spawnswep1337',function( ply, class, wep )
	if ply.IsBanned then return false end
	if wl[class] then return true end
	return ply:IsCheater()
end)

hook.Add("PlayerCanPickupWeapon", "Grabbin.Peelz1337", function(ply,wep)
	if ply.IsBanned then return false end
	if wl[wep:GetClass()] then return true end
	return ply:IsCheater() 
end)



hook.Add("PlayerSpawnProp","sdas",function(ply)
	if ply:IsCheater() then return end
	if ply.AdvDupe2 and ply.AdvDupe2.Pasting then return end
	//if ply~=me then return end
	
	ply.counter = (ply.counter or 0)+1
	
	if ply.counter>7 then
		ChatAddText(Color(255,0,0),"SPAM BY "..ply:GetName())
		ChatAddText(Color(255,0,0),ply:GetName().." обезврежен на 60 секунд.")
		RunConsoleCommand('FPP_Cleanup',ply:UserID())
		ply.oldgroup = ply:GetUserGroup''
		ply:SetUserGroup('banni')
		ply:StripWeapons()
		ply.IsBanned = true
		ply.counter = 0
		timer.Simple(60,function()
			if IsValid(ply) then
				ply:SetUserGroup(ply.oldgroup)
				ChatAddText(Color(0,255,0),ply:GetName().." освобожден.")
				ply.IsBanned = false
				ply.oldgroup = nil
			end
		end)
		return false
	end 
	
	timer.Create("counter_pidor_"..ply:UniqueID(),0.4,1,function()
		if IsValid(ply) then ply.counter = 0 end
	end)

end)