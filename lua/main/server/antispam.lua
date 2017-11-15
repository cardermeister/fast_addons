local function banni( ply, time, unbanni_clb )
	if not IsValid( ply ) or not ply:IsPlayer() then return end
	if ply.IsBanned or not isnumber( time ) then return end
	
	
	local oldGroup = ply:GetUserGroup()
	local isbot = ply:IsBot()
	
	local steamid
	if not isbot then
		steamid = ply:SteamID()
		local bannitxt = luadata.ReadFile( "iin/banni.txt" )
		local bannifield = {}
		
		bannifield["name"] = ply:Nick():gsub( "%A", "*" )
		bannifield["profile"] = "http://steamcommunity.com/profiles/" .. ply:SteamID64()
		bannifield["for"] = time ~= 0 and os.time()+time or "permanent"
		bannifield["oldgroup"] = oldGroup
		
		bannitxt[steamid] = bannifield
		luadata.WriteFile( "iin/banni.txt", bannitxt )
		
		timer.Simple( 0, function()
			if IsValid( ply ) then
				ply:CleanUp()
			else
				sv_PProtect.Cleanup( "disc" )
				sv_PProtect.Cleanup( "unowned" )
			end
		end )
	end
	
	
	ply:SetUserGroup( "banni" )
	ply:StripWeapons()
	ply.IsBanned = true
	
	if not ply:IsInWorld() then
		ply:Spawn()
	end
	
	if ply:GetMoveType() == MOVETYPE_NOCLIP then
		ply:SetMoveType( MOVETYPE_WALK )
	end
	-- ply:ConCommand("FPP_Cleanup "..ply:UserID())
	
	
	if time <= 60*60 and time ~= 0 then
		local function unbanni( ply )
			if not ply.IsBanned then return end
			
			ply:SetUserGroup( oldGroup )
			ply.IsBanned = false
			ply:Spawn()
			
			if isfunction( unbanni_clb ) then
				unbanni_clb( ply )
			end
		end
		
		
		local timername = "unbanni_" .. ( isbot and ply:UserID() or steamid )
		timer.Create( timername, time, 1, function()
			
			
			if not isbot then
				local bannitxt = luadata.ReadFile( "iin/banni.txt" )
				bannitxt[steamid] = nil
				luadata.WriteFile( "iin/banni.txt", bannitxt )
			end
			
			if IsValid( ply ) then
				unbanni( ply )
			elseif not isbot then
				
				ply = player.GetBySteamID( steamid )
				
				if ply then
					unbanni( ply )
				end
				
			end
		
		end )
			
	end
end


local punishments = {
	{ time = 60,    inwords = "60 секунд" },
	{ time = 600,   inwords = "10 минут" },
	{ time = 14400, inwords = "4 часа" } -- and kick
}

local banLevels = {}

FindMetaTable( "Player" ).BanniLevel = function( self )
	return banLevels[ self:SteamID() ] or 0
end

local t = RealTime()
local lags = 0

hook.Add( "Tick", "LagCheck", function()
	local curtime = RealTime()
	local tickrate = 1 / (curtime-t)
	
	if tickrate < 30 then
		lags = lags+1
		
		timer.Simple( 2, function()
			lags = lags-1
		end )
	end
	
	t = curtime
	
	
	if lags ~= 0 then
		for _, ply in ipairs( player.GetHumans() ) do
			local counter = ply.counter
			
			if not ply.IsBanned and counter and counter >= 15 then
				ply.counter = 0
				
				local id = ply:SteamID()
				local banLevel = math.min( ( banLevels[id] or 0 ) + 1, 3 )
				banLevels[id] = banLevel
				local punishment = punishments[ banLevel ]
				
				
				ChatAddText( Color( 255, 0, 0 ),"SPAM BY " .. ply:Nick() )
				ChatAddText( Color( 255, 0, 0 ), Format( "%s обезврежен на %s.", ply:Nick(), punishment.inwords ) )
				banni( ply, punishment.time, function( ply )
					ChatAddText( Color( 0, 255, 0 ), ply:GetName() .. " освобожден." )
				end )
				
				
				if banLevel == 3 then
					ply:Kick( "Prop spam" )
				end
				
				
				timer.Create( "banni.decrease_level_" .. id, 1800, 1, function() -- 30 minutes
					local level = banLevels[id]
					
					if level then
						if level == 1 then
							banLevels[id] = nil
						else
							banLevels[id] = level-1
						end
					end
				end )
				
			end
		end
	end
end )


hook.Add( "PlayerSpawnProp", "banni_counter", function( ply )
	
	if ply:IsCheater() then return end
	if ply.AdvDupe2 and ply.AdvDupe2.Pasting then return end
	
	ply.counter = (ply.counter or 0)+1
	
	timer.Simple( 15, function()
		if IsValid(ply) then
			ply.counter = math.max( 0, ply.counter-1 )
		end
	end )

end )