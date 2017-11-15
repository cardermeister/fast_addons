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
wl['weapon_crowbar']	 = true
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