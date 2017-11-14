--Oh my god I can sit anywhere! by Xerasin--
local NextUse = setmetatable({},{__mode='k'})
--[[local SitOnEnts = CreateConVar("sitting_can_sit_on_ents","1",{FCVAR_NOTIFY})
local PlayerEnts = CreateConVar("sitting_can_sit_on_player_ents","1",{FCVAR_NOTIFY})
local PlayerOtherEnts = CreateConVar("sitting_can_sit_on_other_player_ents","1",{FCVAR_NOTIFY})]]
local SitOnEntsMode = CreateConVar("sitting_ent_mode","3", {FCVAR_NOTIFY})
--[[
	0 - Can't sit on any ents
	1 - Can't sit on any player ents
	2 - Can only sit on your own ents
	3 - Any
]]
local SittingOnPlayer = CreateConVar("sitting_can_sit_on_players","1",{FCVAR_NOTIFY})
local SittingOnPlayer2 = CreateConVar("sitting_can_sit_on_player_ent","0",{FCVAR_NOTIFY})
local PlayerDamageOnSeats = CreateConVar("sitting_can_damage_players_sitting","1",{FCVAR_NOTIFY})

local META = FindMetaTable("Player")
local EMETA = FindMetaTable("Entity")




local function Sit(ply, pos, ang, parent, parentbone,  func, exit)
	ply:ExitVehicle()
	local vehicle = ents.Create("prop_vehicle_prisoner_pod")
	vehicle:SetAngles(ang)
	pos = pos + vehicle:GetUp()*16
	vehicle:SetPos(pos)
	
	vehicle.playerdynseat=true
	vehicle.oldpos = vehicle:WorldToLocal(ply:GetPos())
	vehicle.oldang = ply:EyeAngles()
	ply:SetAllowWeaponsInVehicle(true)
	vehicle:SetModel("models/nova/airboat_seat.mdl") -- DO NOT CHANGE OR CRASHES WILL HAPPEN
	
	vehicle:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	vehicle:SetKeyValue("limitview","0")
	vehicle:Spawn()
	vehicle:Activate()
	
	-- Let's try not to crash
	vehicle:SetMoveType(MOVETYPE_PUSH)
	vehicle:GetPhysicsObject():Sleep()	
	vehicle:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	vehicle:SetNotSolid(true)
	vehicle:GetPhysicsObject():Sleep()	
	vehicle:GetPhysicsObject():EnableGravity(false)
	vehicle:GetPhysicsObject():EnableMotion(false)
	vehicle:GetPhysicsObject():EnableCollisions(false)
	vehicle:GetPhysicsObject():SetMass(1)
	
	-- Visibles
	vehicle:DrawShadow(false)
	vehicle:SetColor(Color(0,0,0,0))
	vehicle:SetRenderMode(RENDERMODE_TRANSALPHA)

	
	if parent and parent:IsValid() then
		local r = math.rad(ang.yaw+90)
		vehicle.plyposhack = vehicle:WorldToLocal(pos + Vector(math.cos(r)*2,math.sin(r)*2,2))
		
		vehicle:SetParent(parent)
		vehicle.parent=parent
		parent._PlyUser = ply
		vehicle._PlyUser = ply	
		
	else
		vehicle.OnWorld = true
	end
	
	ply:EnterVehicle(vehicle)
	
	if PlayerDamageOnSeats:GetBool() then
		ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	end
	--print("VEHICLE",vehicle,"<-",ply,"PARENT:",vehicle:GetParent(),"D:",vehicle:GetPos():Distance(ply:GetPos()))
	
	vehicle.removeonexit = true
	vehicle.exit = exit
	--print("enter vehicle",ply,vehicle)
	
	local ang = vehicle:GetAngles()
	ply:SetEyeAngles(Angle(0,90,0))
	if func then 
		func(ply) 
	end 
	
	return vehicle
end

local d=function(a,b) return math.abs(a-b) end

local SittingOnPlayerPoses =
{

	{
		Pos = Vector(-33,13,7),
		Ang = Angle(0,90,90),
		FindAng = 90,
	},
	{
		Pos = Vector(33,13,7),
		Ang = Angle(0,270,90),
		Func = function(ply) 
			if(not ply:LookupBone("ValveBiped.Bip01_R_Thigh")) then return end
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Angle(0,90,0)) 
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Angle(0,90,0)) 
		end,
		OnExitFunc = function(ply)
			if(not ply:LookupBone("ValveBiped.Bip01_R_Thigh")) then return end
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Angle(0,0,0)) 
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Angle(0,0,0))
		end,
		FindAng = 270,
	},
	{
		Pos = Vector(0, 16, -15),
		Ang = Angle(0, 180, 0),
		Func = function(ply) 
			if(not ply:LookupBone("ValveBiped.Bip01_R_Thigh")) then return end
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Angle(45,0,0)) 
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Angle(-45,0,0)) 
		end,
		OnExitFunc = function(ply)
			if(not ply:LookupBone("ValveBiped.Bip01_R_Thigh")) then return end
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_R_Thigh"), Angle(0,0,0)) 
			ply:ManipulateBoneAngles(ply:LookupBone("ValveBiped.Bip01_L_Thigh"), Angle(0,0,0))
		end,
		FindAng = 0,		
	},
	{
		Pos = Vector(0, 8, -18),
		Ang = Angle(0, 0, 0),
		FindAng = 180,
	},
	
}

local lookup={}
for k,v in pairs(SittingOnPlayerPoses) do
	table.insert(lookup,{v.FindAng,v})
	table.insert(lookup,{v.FindAng+360,v})
end

local function FindPose(this,me)
	local avec=me:GetAimVector()
		avec.z=0
		avec:Normalize()
	local evec=this:GetRight()
		evec.z=0
		evec:Normalize()
	local derp=avec:Dot(evec)
	
	local avec=me:GetAimVector()
		avec.z=0
		avec:Normalize()
	local evec=this:GetForward()
		evec.z=0
		evec:Normalize()
	local herp=avec:Dot(evec)
	local v=Vector(derp,herp,0)
	local a=v:Angle()
	
	local ang=a.y
	assert(ang>=0)
	assert(ang<=360)
	ang=ang+90
	ang=ang%360
	
	table.sort(lookup,function(aa,bb)
		return 	d(ang,aa[1])<d(ang,bb[1])
	end)
	return lookup[1][2]
end


local blacklist = { ["gmod_wire_keyboard"] = true }
local model_blacklist = {  -- I need help finding out why these crash
	--[[["models/props_junk/sawblade001a.mdl"] = true, 
	["models/props_c17/furnitureshelf001b.mdl"] = true,
	["models/props_phx/construct/metal_plate1.mdl"] = true,
	["models/props_phx/construct/metal_plate1x2.mdl"] = true,
	["models/props_phx/construct/metal_plate1x2_tri.mdl"] = true,
	["models/props_phx/construct/metal_plate1_tri.mdl"] = true,
	["models/props_phx/construct/metal_plate2x2.mdl"] = true,
	["models/props_phx/construct/metal_plate2x2_tri.mdl"] = true,
	["models/props_phx/construct/metal_plate2x4.mdl"] = true,
	["models/props_phx/construct/metal_plate2x4_tri.mdl"] = true,
	["models/props_phx/construct/metal_plate4x4.mdl"] = true,
	["models/props_phx/construct/metal_plate4x4_tri.mdl"] = true,]]
}

function META.Sit(ply, EyeTrace, ang, parent, parentbone, func, exit)
	if(EyeTrace == nil) then
		EyeTrace = ply:GetEyeTrace()
	end
	if(type(EyeTrace)=="Vector") then
		return Sit(ply, EyeTrace, ang or Angle(0,0,0), parent, parentbone or 0, func, exit)
	end
	if(not EyeTrace.Hit) then return end
	--[[Player on player]]
	if(EyeTrace.HitPos:Distance(EyeTrace.StartPos) > 100) then return end
	if(SittingOnPlayer:GetBool()) then
		for k,v in pairs(ents.FindInSphere(EyeTrace.HitPos, 5)) do 
			
			local safe=256 -- maxplayers engine supports anyway
			while IsValid(v.SittingOnMe) and safe>0 do
				safe=safe - 1
				v=v.SittingOnMe
			end
			
			if(v:GetClass() == "prop_vehicle_prisoner_pod" and v:GetModel() ~= "models/vehicles/prisoner_pod_inner.mdl" and v:GetDriver() and v:GetDriver():IsValid() and not v.PlayerSitOnPlayer) then
				local pose = FindPose(v,ply) -- SittingOnPlayerPoses[math.random(1, #SittingOnPlayerPoses)]
				local pos = v:GetDriver():GetPos()
				if(v.plyposhack) then
					pos = v:LocalToWorld(v.plyposhack)
				end
				local vec,ang = LocalToWorld(pose.Pos, pose.Ang, pos, v:GetAngles())
				local ent = Sit(ply, vec, ang, v, 0, pose.Func, pose.OnExitFunc)
				--print("sit",ply,ent,v:GetDriver(),v)
				ent.PlayerOnPlayer = true
				v.SittingOnMe = ent
				return ent
			end
		end
	else
		for k,v in pairs(ents.FindInSphere(EyeTrace.HitPos, 5)) do 
			if(v.removeonexit) then
				return
			end
		end
	end
	
	if(not EyeTrace.HitWorld and SitOnEntsMode:GetInt() == 0) then return end
	if(not EyeTrace.HitWorld and blacklist[string.lower(EyeTrace.Entity:GetClass())]) then return end
	if(not EyeTrace.HitWorld and EyeTrace.Entity:GetModel() and model_blacklist[string.lower(EyeTrace.Entity:GetModel())]) then return end
	if(EMETA.CPPIGetOwner) then
		--print(SitOnEntsMode:GetInt())
		if(SitOnEntsMode:GetInt() >= 1) then
			if(SitOnEntsMode:GetInt() == 1) then
				if(not EyeTrace.HitWorld) then
					local owner = EyeTrace.Entity:CPPIGetOwner()
					if(owner ~= nil and owner:IsValid() and owner:IsPlayer()) then
						return
					end
				end
			end
			if(SitOnEntsMode:GetInt() == 2) then
				if(not EyeTrace.HitWorld) then
					local owner = EyeTrace.Entity:CPPIGetOwner()
					if(owner ~= nil and owner:IsValid() and owner:IsPlayer() and owner ~= ply) then
						return
					end
				end
			end
		end
	end
	local ang = EyeTrace.HitNormal:Angle() + Angle(-270, 0, 0)
	if(math.abs(ang.pitch) <= 15) then
		local ang = Angle()
		local filter = player.GetAll()
		local dists = {}
		local distsang = {}
		local ang_smallest_hori = nil
		local smallest_hori = 90000
		for I=0,360,15 do 
			local rad = math.rad(I)
			local dir = Vector(math.cos(rad), math.sin(rad), 0)
			local trace = util.QuickTrace(EyeTrace.HitPos + dir*20 + Vector(0,0,5), Vector(0,0,-15000), filter)
			trace.HorizontalTrace = util.QuickTrace(EyeTrace.HitPos + Vector(0,0,5), (dir) * 1000, filter)
			trace.Distance  =  trace.StartPos:Distance(trace.HitPos)
			trace.Distance2 = trace.HorizontalTrace.StartPos:Distance(trace.HorizontalTrace.HitPos)
			trace.ang = I
			
			if((not trace.Hit or trace.Distance > 14) and (not trace.HorizontalTrace.Hit or trace.Distance2 > 20)) then
				table.insert(dists,trace)
				
			end
			if(trace.Distance2 < smallest_hori and (not trace.HorizontalTrace.Hit or trace.Distance2 > 3)) then
				smallest_hori = trace.Distance2
				ang_smallest_hori = I
			end
			distsang[I] = trace
		end
		local infront = ((ang_smallest_hori or 0) + 180) % 360
		
		if(ang_smallest_hori and distsang[infront].Hit and distsang[infront].Distance > 14 and smallest_hori <= 16) then
			local hori = distsang[ang_smallest_hori].HorizontalTrace
			ang.yaw = (hori.HitNormal:Angle().yaw - 90)
			local ent = nil
			if not EyeTrace.HitWorld then
				ent = EyeTrace.Entity
				if ent:IsPlayer() and not SittingOnPlayer2:GetBool() then return end
			end
			local vehicle = Sit(ply, EyeTrace.HitPos-Vector(0,0,20), ang, ent, EyeTrace.PhysicsBone or 0)
			--print("sit3",ply,"->",vehicle,ply:GetPos():Distance(EyeTrace.Entity:GetPos()))
			return vehicle
		else
			table.sort(dists, function(a,b) return b.Distance < a.Distance end)
			local wants = {}
			local eyeang = ply:EyeAngles() + Angle(0,180,0)
			for I=1,#dists do 
				local trace = dists[I]
				local behind = distsang[(trace.ang + 180) % 360]
				if behind.Distance2 > 3 then
					local cost = 0
					if(trace.ang % 90 ~= 0) then cost = cost + 12 end


					if(math.abs(eyeang.yaw - trace.ang) > 12) then
						cost = cost + 30
					end
					local tbl = {
						cost = cost,
						ang = trace.ang,
					}
					table.insert(wants, tbl)
				end
			end
			table.sort(wants,function(a,b) return b.cost > a.cost end)
			if(#wants == 0) then return end
			ang.yaw = (wants[1].ang - 90)
			local ent = nil
			if not EyeTrace.HitWorld then
				ent = EyeTrace.Entity
				if ent:IsPlayer() and not SittingOnPlayer2:GetBool() then return end
			end
			local vehicle = Sit(ply, EyeTrace.HitPos - Vector(0,0,20), ang, ent, EyeTrace.PhysicsBone or 0)
			
			return vehicle
		end
		
	end

end


local function sitcmd(ply)
	if ply:InVehicle() then return end
	//if !ply:IsVip() and ply:Team()!=TEAM_PUTANAOWN and (ply.GetUTime and ply:GetUTime()<=86400) then return end
	local now=CurTime()
	
	local nextuse = NextUse[ply] or now
	
	if nextuse>now then
		--ply:ChatPrint("Can not sit again that fast")
		return
	end
	
	-- do want to prevent player getting off right after getting in but how :C
	if ply:Sit() then
		--ply:ChatPrint("You sat down")
		nextuse=now + 1
	end
	
	NextUse[ply] = nextuse + 0.1
	
end


hook.Add("CanExitVehicle","noinstaleave",function(veh,ply) 
	
	if not veh.playerdynseat then return end
	
	//print(ply.UseLocker)
	//if ply:GetActiveWeapon():GetClass()=="weapon_physgun" and ply:IsVip() then
	//	return false
	//end
	
	local now=CurTime()
	
	local nextuse = NextUse[ply] or now
	
	if nextuse > now then
		--ply:ChatPrint("Can not leave just yet")
			return false
		--else
		--ply:ChatPrint("You stopped sitting")
	end
end)

concommand.Add("sit",function(ply, cmd, args)
sitcmd(ply)
end)

hook.Add("KeyPress","seats_use",function(ply,key)
	
	//if ply:InVehicle() then 
	//	if key==IN_WALK then
	//		ply:ExitVehicle()	
	//	end
	//end

	if key ~= IN_USE then return end

	local walk=ply:KeyDown(IN_WALK)
	
	
	if not walk then return end
	
	sitcmd(ply)
	
end)


hook.Add("PlayerLeaveVehicle","Remove_Seat",function(ply,self)
	if(self.removeonexit and self:GetClass()=="prop_vehicle_prisoner_pod") then
		NextUse[ply] = CurTime() + 1
		if(self.exit) then
			self.exit(ply)
		end

		ply:SetPos(self:LocalToWorld(self.oldpos))
		ply:SetEyeAngles(self.oldang)
		ply:SetAllowWeaponsInVehicle(false)
		self:Remove()
	end
end)


hook.Add("AllowPlayerPickup","Nopickupwithalt",function(ply) 
	if(ply:KeyDown(IN_WALK)) then 
		return false 
	end 
end)

hook.Add("PlayerDeath","SitSeat",function(pl) 
	for k,v in next, player.GetAll() do
		local veh = v:GetVehicle()
		if veh:IsValid() and veh.playerdynseat and veh:GetParent()==pl then
			veh:Remove()
		end
	end 
end)


timer.Create("RemoveSeats",15,0,function() 
	for k,v in pairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do 
		if(v.removeonexit and (v:GetDriver() == nil or not v:GetDriver():IsValid() or v:GetDriver():GetVehicle() ~= v --[[???]])) then
			v:Remove()
		end
	end
end)
