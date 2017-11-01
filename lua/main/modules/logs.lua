local log_file
local function init()

log_file = os.date( "iin/logs/" .. "%m-%d-%y" .. ".txt" )
if !file.Read(log_file,'DATA') then file.Write(log_file,'') end

file.Append(log_file , "\r\n\r\n".."New map: " .. game.GetMap())

iin = iin or {}

end

init()


function iin.logspawn(str,send)

local date = os.date( "*t" )
file.Append(log_file ,'\n'..string.format( "[%02i:%02i:%02i] ", date.hour, date.min, date.sec ) .. str )

if send && send==true then
iin.MsgC(nil,Color(191,255,0),str..'\n')
end

end


local function playerDeath( victim, weapon, killer )
		if not killer:IsPlayer() then
			iin.logspawn( string.format( "%s was killed by %s", victim:Nick(), killer:GetClass() ) )
		elseif weapon == nil or not weapon:IsValid() then
			iin.logspawn( string.format( "%s killed %s", killer:Nick(), victim:Nick() ) )
		elseif victim ~= killer then
			iin.logspawn( string.format( "%s killed %s using %s", killer:Nick(), victim:Nick(), weapon:GetClass() ) )
		else
			iin.logspawn( string.format( "%s suicided!", victim:Nick() ) )
		end
end
hook.Add( "PlayerDeath", "iinLogDeath", playerDeath)

function iin.FixModel( model ) -- This will convert all model strings to be of the same type, using linux notation and single dashes.
	model = model:lower()
	model = model:gsub( "\\", "/" )
	model = model:gsub( "/+", "/" ) -- Multiple dashes
	return model
end


local function propSpawn( ply, model, ent )
	iin.logspawn( string.format( "%s<%s> spawned model %s", ply:Nick(), ply:SteamID(), iin.FixModel( model ) ) , true)
end
hook.Add( "PlayerSpawnedProp", "iinLogPropSpawn", propSpawn)

local function ragdollSpawn( ply, model, ent )
	iin.logspawn( string.format( "%s<%s> spawned ragdoll %s", ply:Nick(), ply:SteamID(), iin.FixModel( model ) ) , true)
end
hook.Add( "PlayerSpawnedRagdoll", "iinLogRagdollSpawn", ragdollSpawn )

local function effectSpawn( ply, model, ent )
	iin.logspawn( string.format( "%s<%s> spawned effect %s", ply:Nick(), ply:SteamID(), iin.FixModel( model ) ) , true)
end
hook.Add( "PlayerSpawnedEffect", "iinLogEffectSpawn", effectSpawn)

local function vehicleSpawn( ply, ent )
	iin.logspawn( string.format( "%s<%s> spawned vehicle %s", ply:Nick(), ply:SteamID(), iin.FixModel( ent:GetModel() or "unknown" ) ) , true)
end
hook.Add( "PlayerSpawnedVehicle", "iinLogVehicleSpawn", vehicleSpawn )

local function sentSpawn( ply, ent )
	iin.logspawn( string.format( "%s<%s> spawned sent %s", ply:Nick(), ply:SteamID(), ent:GetClass() ) , true)
end
hook.Add( "PlayerSpawnedSENT", "iinLogSentSpawn", sentSpawn )

local function NPCSpawn( ply, ent )
	iin.logspawn( string.format( "%s<%s> spawned NPC %s", ply:Nick(), ply:SteamID(), ent:GetClass() ) , true)
end
hook.Add( "PlayerSpawnedNPC", "iinLogNPCSpawn",NPCSpawn )


local function playerSay( ply, text, private )
		if private then
			iin.logspawn( string.format( "(TEAM) %s: %s", ply:Nick(), text ) )
		else
			iin.logspawn( string.format( "%s: %s", ply:Nick(), text ) )
		end
end
hook.Add( "PlayerSay", "iinLogSay", playerSay )

local joinTimer = {}
local mapStartTime = os.time()
local function playerConnect( name, address )
	joinTimer[address] = os.time()
		iin.logspawn( string.format( "Client \"%s\" connected.", name ) )
end
hook.Add( "PlayerConnect", "iinLogConnect", playerConnect )

local function playerInitialSpawn( ply )

	local ip = ply:IPAddress()
	local seconds = os.time() - (joinTimer[ip] or mapStartTime)
	joinTimer[ip] = nil
	
	local txt = string.format( "Client \"%s\" spawned in server <%s> (took %i seconds).", ply:Nick(), ply:SteamID(), seconds , true)
		iin.logspawn( txt )
end
hook.Add( "PlayerInitialSpawn", "iinLogInitialSpawn", playerInitialSpawn)