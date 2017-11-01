local shutkatbl = {
  "потомучьто захотелос",
  "привецтвую насервере егрок",
  "windus заблокирован отправте собщение на номер 88005553535",
  "jet fuel can't melt steel memes",
  "тролиш",
  "dinah",
  "оцстан",
  "pasyryc dong",
  "увас spine vhite",
  "podrochite and calm down",
  "где здес текст писат",
  "бу че обосрался чьмо",
  "бонц",
  "убю",
  "АААаааААА",
  "продам гараш 8 800 555 35 35",
  "%generic_kick_reason%",
  "удоли",
  "поздровляем вы 100000миленыи посетител нашего сервера",
  "почемуто блин незнаю",
  "воли",
  "Я_пРо_Ты_НуБ-______________-",
  "шок путин обосался в премом ефире",
  "блин пора уроки делать всем пока",
  "расдватри four пят я крутой",
  "ejji",
  "це мое болото",
  "цдоровя егрок",
  "я убидся",
  "прикол нАеКрАнЕ",
  "да привет",
  "ще не вмерла украiна"
}

local banwhitelist = { "STEAM_0:0:82089886", "STEAM_0:0:40468303", "STEAM_0:1:33175566", "STEAM_0:0:27208569", "STEAM_0:0:89032865", "STEAM_0:1:60337465" }

FindMetaTable'Player'.eban = function( ply, kickreason )
	if !ply:IsPlayer() then return end
	math.randomseed( CurTime() )
	local randi = math.random( 1, 66 )
	
	if not kickreason then
		ply:Kick( table.Random( shutkatbl ) )
	else 
		ply:Kick( kickreason ) 
	end
	
	for k, prop in pairs( ents.FindByClass( "prop_physics" ) ) do
		if prop:CPPIGetOwner() == ply then
			prop:Remove()
		end
	end

	PlayURL( "https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban" .. randi .. ".mp3" )
end

hook.Add( "EntityTakeDamage", "rban_takedamage", function( target, cdmg )
	local attacker = cdmg:GetAttacker()
    
	if not IsValid( target ) or not target:IsPlayer() or target:IsSuperAdmin() then return end
	if not IsValid( attacker ) or not attacker:IsPlayer() then return end
	if not table.HasValue( banwhitelist, attacker:SteamID() ) then return end

	local wep = attacker:GetActiveWeapon()
    
    if IsValid( wep ) and wep:GetClass() == "weapon_stunstick" then
    	local effectdata = EffectData()
		effectdata:SetOrigin( target:GetPos() )
		util.Effect( "ManhackSparks", effectdata )
		target:eban()
    end
end )