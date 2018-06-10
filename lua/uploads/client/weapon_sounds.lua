local weapon_sounds = CreateClientConVar("weapon_sounds", "0")

local weaponsounds = {
	["ar2"] = {
		"https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/bum1.mp3",
		"https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/bum3.mp3"
	},

	["shotgun"] = {
		"https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/zvuki_seksa.mp3"
	},

	["crossbow"] = {
		"https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/nya.mp3"
	},

	["iceaxe"] = {
		"https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/kus.mp3"
	},

	["rpg"] = {
		"https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/ooop.mp3"
	}
}

weaponsounds["pistol"] = weaponsounds["ar2"]

local function weaponSounds(data)
	if not weapon_sounds:GetBool() then return end

	local ent = data.Entity
	local soundname = data.SoundName
	local wepname = string.match(soundname, "^%)weapons/(%w+)")
	
	if weaponsounds[wepname] and ent and ent:IsPlayer() and ent:IsAdmin() then
		local rand = table.Random(weaponsounds[wepname])
		ent:PlayURL(rand)
		
		return false
	end
end

hook.Add("EntityEmitSound", "weaponSounds", weaponSounds)