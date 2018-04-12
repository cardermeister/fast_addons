local weapon_sounds = false
local otwTag = "weapon_sounds_onetimewarning"
local warned = false
concommand.Add("weapon_sounds_enabled", function(_,_,a)
                  local yes = nil
                  if #a > 0 then
                     yes = tobool(a[1])
                  end

                  if yes and not warned then
                     chat.AddText(Color(255, 128, 128), "ВНИМАНИЕ! Включена переменная weapon_sounds!")
                     chat.AddText(Color(255, 128, 128), "Звуки будут хуёвые так что лучше выключи её обратно!")
                     chat.AddText(Color(255, 255, 128), "Для подтверждения того что вы еблан вам нужно еще раз ввести weapon_sounds 1")
                     chat.AddText(Color(128, 128, 128), "Это предупреждение больше показываться не будет.")
                     yes = nil
                     warned = true
                  end

                  if yes == nil then
                     chat.AddText(Color(128,128,255), "weapon_sounds: "..(weapon_sounds and "on" or "off"))
                     return
                  end

                  weapon_sounds = yes
end)

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
	if not weapon_sounds then return end
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
