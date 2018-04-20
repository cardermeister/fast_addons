local ParticlesThisSecond   = {}
local Grav                  = {}
local Particles             = {}
local ParticlesLookup       = {}
local rad2deg               = 180 / math.pi
local asin                  = math.asin
local atan2                 = math.atan2
local AlwaysRender          = 1
local MaxParticlesPerSecond = CreateConVar( "sbox_e2_maxParticlesPerSecond", "100", FCVAR_ARCHIVE )

local function bearing(pos, plyer)
	pos = plyer:WorldToLocal(Vector(pos[1],pos[2],pos[3]))
	return rad2deg*-atan2(pos.y, pos.x)
end

local function elevation(pos, plyer)
	pos = plyer:WorldToLocal(Vector(pos[1],pos[2],pos[3]))
	local len = pos:Length()
	if len < delta then return 0 end
	return rad2deg*asin(pos.z / len)
end

local function message(Duration, StartSize, EndSize, RGB, Position, Velocity, String, nom, Pitch, RollDelta, StartAlpha, EndAlpha)
	local eplayers = RecipientFilter()
	if(AlwaysRender==0) then
		for k, v in pairs(player.GetAll()) do
			local ply = v
			if(IsValid(ply)) then 
				if(Grav[nom]==nil) then Grav[nom] = Vector(0,0,-9.8) end
				Gravi = Vector(Grav[nom][1],Grav[nom][2],Grav[nom][3])
				local Posi = Vector(Position[1],Position[2],Position[3])
				for i=1,5 do
					local Velo = Vector(Velocity[1],Velocity[2],Velocity[3])-(Gravi*i)
					local P = bearing(Posi+(Velo*i),ply)
					local Y = elevation(Posi+(Velo*i),ply)
					if (math.abs(Y) < 100) then
						if (math.abs(P) < 100) then
							eplayers:AddPlayer(ply)
							break
						end
					end
				end
			end
		end
	else
		eplayers:AddAllPlayers()
	end
	
	umsg.Start("e2p_pm",eplayers)
		umsg.Entity(nom)
		umsg.Char(RollDelta)
		umsg.Char(StartAlpha)
		umsg.Char(EndAlpha)
		umsg.Short(StartSize)
		umsg.Float(Duration)
		umsg.Float(EndSize)
		umsg.Float(Pitch)
		umsg.Vector(Vector(Position[1],Position[2],Position[3]))
		umsg.Vector(Vector(RGB[1],RGB[2],RGB[3]))
		umsg.Vector(Vector(Velocity[1],Velocity[2],Velocity[3]))
		umsg.String(String)
	umsg.End()
	eplayers:RemoveAllPlayers()
end
 
local function SetMaxE2Particles( player, command, arguments)
		if(player:IsSuperAdmin()) then
				MaxParticlesPerSecond = tonumber(arguments[1])
		end
end

local function SetAlwaysRenderParticles( player, command, arguments)
		if(player:IsSuperAdmin()) then
				AlwaysRender = tonumber(arguments[1])
		end
end

local function ParticlesTimer(timerName,PlyID)
		timer.Destroy(timerName)
		ParticlesThisSecond[PlyID] = 0
end

concommand.Add("wire_e2_SetAlwaysRenderParticles",SetAlwaysRenderParticles)
concommand.Add("wire_e2_maxParticlesPerSecond",SetMaxE2Particles)

for i = 1, game.MaxPlayers() do ParticlesThisSecond[i] = 0 end

local function SpawnParticle(self, Duration, StartSize, EndSize, Mat, RGB, Position, Velocity, Pitch, RollDelta, StartAlpha, EndAlpha)
	if not IsValid(self.player) then return end
	if not ParticlesLookup[Mat] then return end

	local PlyID = self.player:EntIndex()

	if ParticlesThisSecond[PlyID] <= MaxParticlesPerSecond:GetInt() then
		if not Pitch then Pitch = 0 end
		if not RollDelta then RollDelta = 0 end
		if not StartAlpha then StartAlpha = 255 end
		if not EndAlpha then EndAlpha = StartAlpha end

		message(Duration, StartSize, EndSize, RGB, Position, Velocity, Mat, self.entity, Pitch, RollDelta, StartAlpha - 128, EndAlpha - 128)
		ParticlesThisSecond[PlyID] = ParticlesThisSecond[PlyID] + 1

		local timerName = "e2p_" .. PlyID
		if not timer.Exists(timerName) then
			timer.Create(timerName, 1, 0, function() ParticlesTimer(timerName, PlyID) end)
		end
	end
end

__e2setcost(20)

e2function void particle(Duration, StartSize, EndSize, string Mat, vector RGB, vector Position, vector Velocity, Pitch, RollDelta, StartAlpha, EndAlpha)
	SpawnParticle(self, Duration, StartSize, EndSize, Mat, RGB, Position, Velocity, Pitch, RollDelta, StartAlpha, EndAlpha)
end

e2function void particle(Duration, StartSize, EndSize, string Mat, vector RGB, vector Position, vector Velocity, Pitch, RollDelta)
	SpawnParticle(self, Duration, StartSize, EndSize, Mat, RGB, Position, Velocity, Pitch, RollDelta)
end

e2function void particle(Duration, StartSize, EndSize, string Mat, vector RGB, vector Position, vector Velocity, Pitch)
	SpawnParticle(self, Duration, StartSize, EndSize, Mat, RGB, Position, Velocity, Pitch)
end

e2function void particle(Duration, StartSize, EndSize, string Mat, vector RGB, vector Position, vector Velocity)
	SpawnParticle(self, Duration, StartSize, EndSize, Mat, RGB, Position, Velocity)
end





__e2setcost(5)

e2function void particleBounce(Bounce)
	umsg.Start("e2p_bounce")
	umsg.Entity(self.entity)
	umsg.Long(math.Round(Bounce))
	umsg.End()
end

e2function void particleGravity(vector Gravity)
	umsg.Start("e2p_gravity")
	umsg.Entity(self.entity)
	umsg.Vector(Vector(Gravity[1],Gravity[2],Gravity[3]))
	umsg.End()
	Grav[self.entity] = Gravity
end

e2function void particleCollision(Number)
	umsg.Start("e2p_collide")
	umsg.Entity(self.entity)
	umsg.Long(Number)
	umsg.End()
end

e2function array particlesList()
	local result = {[0] = Particles[0]}

	for k, v in ipairs(Particles) do
		result[k] = v
	end

	return result
end

__e2setcost(nil)

Particles = {
	[0] = "effects/blooddrop",
	"effects/bloodstream",
	"effects/laser_tracer",
	"effects/select_dot",
	"effects/select_ring",
	"effects/tool_tracer",
	"effects/wheel_ring",
	"effects/base",
	"effects/blood",
	"effects/blood2",
	"effects/blood_core",
	"effects/blood_drop",
	"effects/blood_gore",
	"effects/blood_puff",
	"effects/blueblackflash",
	"effects/blueblacklargebeam",
	"effects/blueflare1",
	"effects/bluelaser1",
	"effects/bluemuzzle",
	"effects/bluespark",
	"effects/bubble",
	"effects/combinemuzzle1",
	"effects/combinemuzzle1_dark",
	"effects/combinemuzzle2",
	"effects/combinemuzzle2_dark",
	"effects/energyball",
	"effects/energysplash",
	"effects/exit1",
	"effects/fire_cloud1",
	"effects/fire_cloud2",
	"effects/fire_embers1",
	"effects/fire_embers2",
	"effects/fire_embers3",
	"effects/fleck_glass1",
	"effects/fleck_glass2",
	"effects/fleck_glass3",
	"effects/fleck_tile1",
	"effects/fleck_tile2",
	"effects/fleck_wood1",
	"effects/fleck_wood2",
	"effects/fog_d1_trainstation_02",
	"effects/gunshipmuzzle",
	"effects/gunshiptracer",
	"effects/hydragutbeam",
	"effects/hydragutbeamcap",
	"effects/hydraspinalcord",
	"effects/laser1",
	"effects/laser_citadel1",
	"effects/mh_blood1",
	"effects/mh_blood2",
	"effects/mh_blood3",
	"effects/muzzleflash1",
	"effects/muzzleflash2",
	"effects/muzzleflash3",
	"effects/muzzleflash4",
	"effects/redflare",
	"effects/rollerglow",
	"effects/slime1",
	"effects/spark",
	"effects/splash1",
	"effects/splash2",
	"effects/splash3",
	"effects/splash4",
	"effects/splashwake1",
	"effects/splashwake3",
	"effects/splashwake4",
	"effects/strider_bulge_dudv",
	"effects/strider_muzzle",
	"effects/strider_pinch_dudv",
	"effects/strider_tracer",
	"effects/stunstick",
	"effects/tracer_cap",
	"effects/tracer_middle",
	"effects/tracer_middle2",
	"effects/water_highlight",
	"effects/yellowflare",
	"effects/muzzleflashX",
	"effects/ember_swirling001",
	"shadertest/eyeball",
	"sprites/bloodparticle",
	"sprites/animglow02",
	"sprites/ar2_muzzle1",
	"sprites/ar2_muzzle3",
	"sprites/ar2_muzzle4",
	"sprites/flamelet1",
	"sprites/flamelet2",
	"sprites/flamelet3",
	"sprites/flamelet4",
	"sprites/flamelet5",
	"sprites/glow03",
	"sprites/light_glow02",
	"sprites/orangecore1",
	"sprites/orangecore2",
	"sprites/orangeflare1",
	"sprites/plasmaember",
	"sprites/redglow1",
	"sprites/redglow2",
	"sprites/rico1",
	"sprites/strider_blackball",
	"sprites/strider_bluebeam",
	"sprites/tp_beam001",
	"sprites/yellowflare",
	"sprites/frostbreath",
	"sprites/sent_ball",
	"sun/overlay",
	"particle/fire"
}

for i, path in pairs(Particles) do
	ParticlesLookup[path] = i
end