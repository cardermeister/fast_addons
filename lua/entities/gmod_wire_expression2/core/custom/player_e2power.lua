local abs = math.abs

local function isInvalid(number)
	return number ~= number or abs(number) > 1e20
end

__e2setcost(20)
e2function void entity:playerFreeze()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	this:Lock()
end

e2function void entity:playerUnFreeze()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	this:UnLock()
end

e2function void entity:playerNoclip(number status)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	if status ~= 0 then
		this:SetMoveType(MOVETYPE_NOCLIP)
	else
		this:SetMoveType(MOVETYPE_WALK)
	end
end

e2function void entity:playerSetAlpha(number alpha)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	local clr = this:GetColor()
	clr.a = math.Clamp(alpha, 0, 255)
	this:SetColor(clr)
end

e2function number entity:playerIsRagdoll()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return IsValid(this.ragdoll) and 1 or 0
end

__e2setcost(100)
e2function void entity:playerModel(string model)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	local modelname = player_manager.TranslatePlayerModel(model)
	util.PrecacheModel(modelname)
	this:SetModel(modelname)
end

e2function vector entity:playerBonePos(number index)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	local bonepos = this:GetBonePosition(this:TranslatePhysBoneToBone(index))
	return bonepos
end

e2function angle entity:playerBoneAng(number index)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	local _, boneang = this:GetBonePosition(this:TranslatePhysBoneToBone(index))
	return boneang
end

e2function vector entity:playerBonePos(string boneName)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	local bonepos = this:GetBonePosition(this:LookupBone(boneName) or -1)
	return bonepos
end

e2function angle entity:playerBoneAng(string boneName)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	local _, boneang = this:GetBonePosition(this:LookupBone(boneName) or -1)
	return boneang
end

e2function number entity:lookUpBone(string boneName)
	if not IsValid(this) then return -1 end
	return this:LookupBone(boneName) or -1
end

e2function void entity:playerSetBoneAng(number index, angle ang)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	if isInvalid(ang[1]) or isInvalid(ang[2]) or isInvalid(ang[3]) then return end

	this:ManipulateBoneAngles(index, Angle(ang[1], ang[2], ang[3]))
end

e2function void entity:playerSetBoneAng(string boneName, angle ang)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	if isInvalid(ang[1]) or isInvalid(ang[2]) or isInvalid(ang[3]) then return end

	local index = this:LookupBone(boneName)

	if index then
		this:ManipulateBoneAngles(index, Angle(ang[1], ang[2], ang[3]))
	end
end

e2function void playerSetBoneAng(number index, angle ang)
	if not IsValid(self.player) then return end
	if isInvalid(ang[1]) or isInvalid(ang[2]) or isInvalid(ang[3]) then return end

	self.player:ManipulateBoneAngles(index, Angle(ang[1], ang[2], ang[3]))
end

e2function void playerSetBoneAng(string boneName, angle ang)
	if not IsValid(self.player) then return end
	if isInvalid(ang[1]) or isInvalid(ang[2]) or isInvalid(ang[3]) then return end

	local index = self.player:LookupBone(boneName)

	if index then
		self.player:ManipulateBoneAngles(index, Angle(ang[1], ang[2], ang[3]))
	end
end

local function ragdollPlayer(ply)
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll.ragdolledPly = ply
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:SetModel(ply:GetModel())
	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:CPPISetOwner(ply)

	ply:SetParent(ragdoll)

	local velocity = ply:GetVelocity()

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local phys = ragdoll:GetPhysicsObjectNum(i)
		phys:SetVelocity(velocity)
	end

	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(ragdoll)
	ply:StripWeapons()

	ply.ragdoll = ragdoll
	ply.ragdolledWithE2 = true

	return ragdoll
end

local function unragdollPlayer(ply, respawn)
	ply:SetParent()
	ply:UnSpectate()

	local ragdoll = ply.ragdoll
	ply.ragdoll = nil
	ply.ragdolledWithE2 = false
	ragdoll.ragdolledPly = nil -- To make EntityRemoved not be called

	if respawn then
		local pos = ragdoll:GetPos()
		pos.z = pos.z + 10

		ply:Spawn()
		ply:SetPos(pos)
		local yaw = ragdoll:GetAngles().yaw
		ply:SetAngles(Angle(0, yaw, 0))
		ply:SetVelocity(ragdoll:GetVelocity())
	end

	ragdoll:Remove()
end

__e2setcost(1500)
e2function entity entity:playerRagdoll()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end
	if not this:Alive() then return end

	if this:InVehicle() then this:ExitVehicle() end

	if not IsValid(this.ragdoll) then
		return ragdollPlayer(this)
	else
		unragdollPlayer(this, true)
		return this
	end
end

__e2setcost(20)

e2function void entity:plyRunSpeed(number speed)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	speed = math.Clamp(speed, 0, 90000)

	if speed > 0 then
		this:SetRunSpeed(speed)
	else -- Zero or NaN
		local class = this.m_CurrentPlayerClass
		ply:SetRunSpeed(class and class.RunSpeed or 400)
	end
end

e2function void entity:plyWalkSpeed(number speed)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	speed = math.Clamp(speed, 0, 90000)

	if speed > 0 then
		this:SetWalkSpeed(speed)
	else
		local class = this.m_CurrentPlayerClass
		ply:SetWalkSpeed(class and class.WalkSpeed or 200)
	end
end

e2function void entity:plyJumpPower(number power)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	power = math.Clamp(power, 0, 90000)

	if power > 0 then
		this:SetJumpPower(power)
	else
		local class = this.m_CurrentPlayerClass
		ply:SetJumpPower(class and class.JumpPower or 200)
	end
end

e2function void entity:plyCrouchWalkSpeed(number speed)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	speed = math.Clamp(speed, 0, 10)

	if speed > 0 then
		this:SetCrouchedWalkSpeed(speed)
	else
		local class = this.m_CurrentPlayerClass
		this:SetCrouchedWalkSpeed(class and class.CrouchedWalkSpeed or 0.3)
	end
end

e2function number entity:plyGetMaxSpeed()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetMaxSpeed()
end

e2function number entity:plyGetJumpPower()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetJumpPower()
end

hook.Add("EntityRemoved", "UnragdollPlayer", function(ent)
	if ent:GetClass() ~= "prop_ragdoll" then return end
	if not IsValid(ent.ragdolledPly) then return end

	unragdollPlayer(ent.ragdolledPly, true)
end)

hook.Add("PlayerDisconnected", "RemoveRagdoll", function(ply)
	if IsValid(ply.ragdoll) then
		ply.ragdoll:Remove()
	end
end)

hook.Add("PostPlayerDeath", "UnragdollPlayer", function(ply)
	if IsValid(ply.ragdoll) and ply.ragdolledWithE2 then
		unragdollPlayer(ply, false)
	end
end)

hook.Add("PlayerSpawn", "UnragdollPlayer", function(ply)
	if IsValid(ply.ragdoll) then
		unragdollPlayer(ply, false)
	end
end)