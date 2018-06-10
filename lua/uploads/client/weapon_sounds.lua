local weapon_sounds = CreateClientConVar("weapon_sounds", "0")

local weaponsounds = {
	['ar2'] = {
		'https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/bum1.mp3',
		'https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/bum3.mp3'
	},
	['shotgun'] = {
		'https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/zvuki_seksa.mp3'
	},
	['crossbow'] = {
		'https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/nya.mp3'
	},

	['iceaxe'] = {
		'https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/kus.mp3'
	},

	['rpg'] = {
		'https://raw.githubusercontent.com/OldOverusedMeme/cancer/master/ooop.mp3'
	}
}

weaponsounds['pistol'] = weaponsounds["ar2"]

local function zvuki_nah(tabl)
	if not weapon_sounds:GetBool() then return end
	local Ent = tabl.Entity
	local SName = tabl.SoundName
	local wepname = string.Explode('/',SName)[2]
	
	if Ent and Ent:IsPlayer() and Ent:IsAdmin() then
		
		if string.find( SName, 'weapons/' ) and weaponsounds[ wepname ] then
			local rand = table.Random(weaponsounds[ wepname ])
			
			Ent:PlayURL( rand )
			
			return false
		end
		
	end
end

hook.Add( 'EntityEmitSound', 'tak_pososi_se4asje', zvuki_nah )