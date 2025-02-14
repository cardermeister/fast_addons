local PLAYER = FindMetaTable("Player")
local WEAPON = FindMetaTable("Weapon")

function PLAYER:IsCheater()
	return self:GetNWBool("cheater") or false
end

function PLAYER:SetCheater(bool)
	self:SetNWBool("cheater", bool)
end

function WEAPON:SetAmmo(count, isSecondary)
	self.Owner:SetAmmo(count, isSecondary and self:GetSecondaryAmmoType() or self:GetPrimaryAmmoType())
end

local wepWhitelist = {
	weapon_crowbar    = true,
	weapon_physcannon = true,
	weapon_physgun    = true,
	gmod_tool         = true,
	gmod_camera       = true,
	laserpointer      = true,
	remotecontroller  = true
}

hook.Add("PlayerSpawnSWEP", "spawnswep1337", function(ply, class, wep)
	if ply.IsBanned then return false end
	
	if not wepWhitelist[class] then
		if not ply:IsCheater() and not ply.pvp then return false end
	end
end)

hook.Add("PlayerGiveSWEP", "spawnswep1337", function(ply, class, wep)
	if ply.IsBanned then return false end

	if not wepWhitelist[class] then
		if not ply:IsCheater() and not ply.pvp then return false end
	end
end)

hook.Add("PlayerCanPickupWeapon", "Grabbin.Peelz1337", function(ply, wep)
	if ply.IsBanned then return false end

	if not wepWhitelist[wep:GetClass()] then
		if not ply:IsCheater() and not ply.pvp then return false end
	end
end)