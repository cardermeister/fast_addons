function DiffLog(txt)
	if not isstring(txt) then return end
	local l = file.Open("e2p_logs.txt", "a", "DATA")
	if l then
		l:Write("[" .. os.date("%Y/%m/%d %H:%M:%S") .. "] " .. txt .. "\n")
		l:Close()
	end
	Msg"[E2P-Diff.lua] " print(txt)
end

if not list.HasEntry then
	local i = 1
	local g_Lists

	while true do
		local name, value = debug.getupvalue(list.Contains, i)
		if not name then break end

		if name == "g_Lists" then
			g_Lists = value
			break
		end

		i = i + 1
	end

	if g_Lists then
		function list.HasEntry( list, key )

			if ( !g_Lists[ list ] ) then return false end
			return g_Lists[ list ][ key ] ~= nil

		end
	end
end

__e2setcost(5)
e2function number entity:isPhysics()
	return validPhysics(this) and 1 or 0
end

e2function number entity:isExist()
	return IsValid(this) and 1 or 0
end

e2function string entity:getUserGroup()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetUserGroup()
end

__e2setcost(20)
e2function void entity:remove()
	if not IsValid(this) then return end
	if not isOwner(self, this) then return end
	if this:IsPlayer() then return end

	this:Remove()
end

e2function void entity:remove(number delay)
	if not IsValid(this) then return end
	if not isOwner(self, this) then return end
	if this:IsPlayer() then return end

	timer.Simple(delay, function()
		if IsValid(this) then
			this:Remove()
		end
	end)
end

e2function void runOnLast(number status, entity ent)
	if not IsValid(ent) then return end
	if ent == self.entity then return end

	if status ~= 0 then
		ent:CallOnRemove("e2ExL" .. tostring(ent:EntIndex()), function()
			if IsValid(self.entity) then
				self.lastClkEnt = ent
				self.entity:Execute()
				self.lastClkEnt = nil
			end
		end)
	else
		ent:RemoveCallOnRemove("e2ExL" .. tostring(ent:EntIndex()))
	end
end

__e2setcost(5)
e2function number last(entity ent)
	return self.lastClkEnt == ent and 1 or 0
end

e2function entity lastEnt()
	return self.lastClkEnt
end

__e2setcost(20)

----------------------------------------------------Wire
e2function void entity:setInput(string input, ...)
	if not IsValid(this) then return end
	if not isOwner(self, this) then return end

	if this.TriggerInput then
		this:TriggerInput(input, select(1, ...))
	end
end

e2function array entity:getOutput(string output)
	if not IsValid(this) then return end
	if not istable(this.Outputs) then return end

	output = this.Outputs[output]

	if output then
		return {output.Value}
	end
end

e2function angle entity:getOutputAngle(string output)
	if not IsValid(this) then return end
	if not istable(this.Outputs) then return end

	output = this.Outputs[output]

	if output then
		local value = output.Value

		if isangle(value) then
			return {value.p, value.y, value.r}
		end
	end
end

e2function string entity:getOutputType(string output)
	if not IsValid(this) then return end
	if not istable(this.Outputs) then return end

	output = this.Outputs[output]

	if output then
		return type(output.Value)
	end
end

e2function string entity:getInputType(string input)
	if not IsValid(this) then return end
	if not istable(this.Inputs) then return end

	input = this.Inputs[input]

	if input then
		return type(input.Value)
	end
end

e2function array entity:getInputsList()
	if not IsValid(this) then return end
	if not istable(this.Inputs) then return end

	return table.GetKeys(this.Inputs)
end

e2function array entity:getOutputsList()
	if not IsValid(this) then return end
	if not istable(this.Outputs) then return end

	return table.GetKeys(this.Outputs)
end
------------------------------------------------------------
__e2setcost(100)
local Blocked = {}
Blocked["kill"] = true
Blocked["runpassedcode"] = true
Blocked["runcode"] = true
Blocked["break"] = true
Blocked["addoutput"] = true
Blocked["Dissolve"] = true
Blocked["setteam"] = true
Blocked["run_lua"] = true
Blocked["point_servercommand"] = true
Blocked["*"] = true
Blocked["env_screenoverlay"] = true
Blocked["onhealthchanged"] = true
Blocked["onplayerpickup"] = true
Blocked["game_end"] = true
Blocked["lua_run"] = true
Blocked["point_commentary_node"] = true
Blocked["code"] = true
Blocked["angles"] = true
Blocked["origin"] = true
Blocked["setparent"] = true
Blocked["modelscale"] = true


__e2setcost(100)

e2function void entity:setKeyValue(string key, ...)
	if not IsValid(this) then return end
	if not isOwner(self, this) then return end

	local value = select(1, ...)
	if not isstring(value) and not isnumber(value) then return end

	-- DiffLog("{KValue} " .. key .. " > " .. value)

	key = string.lower(key)

	for keyvalue in pairs(Blocked) do
		if string.find(key, keyvalue, nil, true) then return end
	end

	if isstring(value) then
		local valueLower = string.lower(value)
		for keyvalue in pairs(Blocked) do
			if string.find(valueLower, keyvalue, nil, true) then return end
		end
	end

	this:SetKeyValue(key, value)
end

e2function void entity:setFire(string input, string param, number delay)
	if not IsValid(this) then return end
	if not isOwner(self, this) then return end

	local inputLower = string.lower(input)
	local paramLower = string.lower(param)

	-- DiffLog("{SetFire} " .. input .. " > " .. param)

	if this:GetClass() == "lua_run" then return end

	for keyvalue in pairs(Blocked) do
		if string.find(paramLower, keyvalue, nil, true) then return end
		if string.find(inputLower, keyvalue, nil, true) then return end
	end

	this:Fire(input, param, delay)
end


__e2setcost(20)

local defaults = {
	String = function() return "" end,
	Entity = function() return NULL end,
	Vector = function() return {0, 0, 0} end, --
	Angle  = function() return {0, 0, 0} end, -- As they're reference types, we need these generators
	Array  = function() return {} end         --
}

local typemaps = {
	String = "s",
	Entity = "e",
	Vector = "v",
	Angle  = "a",
	Array  = "r"
}

for typename, shortname in pairs(typemaps) do
	registerFunction("setVar" .. typename, "e:s" .. shortname, "", function(self, args)
		local op1, op2, op3 = args[2], args[3], args[4]
		local this, name, value = op1[1](self, op1), op2[1](self, op2), op3[1](self, op3)

		if not IsValid(this) then return end
		if not this.e2data then this.e2data = {} end

		this.e2data[name] = value
	end, 20, {"name", "value"})

	registerFunction("getVar" .. typename, "e:s", shortname, function(self, args)
		local op1, op2 = args[2], args[3]
		local this, name = op1[1](self, op1), op2[1](self, op2)

		if not IsValid(this) or not this.e2data then
			return defaults[typename]()
		end

		local value = this.e2data[name]
		local typecheck = wire_expression_types2[shortname][6]

		if typecheck and typecheck(value) then
			return defaults[typename]() -- When typecheck failed
		end

		return value
	end, 20, {"name"})
end

e2function void entity:setVar(string name, ...)
	if not IsValid(this) then return end
	if not this.e2data then this.e2data = {} end

	this.e2data[name] = {...}
end

e2function array entity:getVar(string name)
	if not IsValid(this) then return {} end
	if not this.e2data then return {} end

	local value = this.e2data[name]

	return istable(value) and value or {value}
end

e2function array array:getArrayFromArray(number index)
	if this then return this[index] end
end

e2function void entity:setVarNum(string name, number value)
	if not IsValid(this) then return end
	if not isOwner(self, this) then return end
	if not this.e2data then this.e2data = {} end

	this.e2data[name] = value
end

e2function number entity:getVarNum(string name)
	if not IsValid(this) then return 0 end
	if not this.e2data then return 0 end

	local value = this.e2data[name]

	return isnumber(value) and value or 0
end

e2function void setUndoName(string name)
	if not IsValid(self.player) then return end

	undo.Create(string.JavascriptSafe(name))
		undo.AddEntity(self.entity)
		undo.SetPlayer(self.player)
	undo.Finish()
end

e2function void entity:setUndoName(string name)
	if not IsValid(this) then return end
	if not IsValid(self.player) then return end
	if not isOwnerOld(self, this) then return end

	undo.Create(string.JavascriptSafe(name))
		undo.AddEntity(this)
		undo.SetPlayer(self.player)
	undo.Finish()
end

e2function void array:setUndoName(string name)
	if not IsValid(self.player) then return end

	undo.Create(string.JavascriptSafe(name))
		for k, v in pairs(this) do
			if isentity(v) and IsValid(v) and isOwnerOld(self, v) then
				undo.AddEntity(v)
			end
			self.prf = self.prf + 20
		end

		undo.SetPlayer(self.player)
	undo.Finish()
end

e2function void noDuplications()
	self.entity.original = "selfDestruct()"
	self.entity.buffer = "selfDestruct()"
	self.entity._original = "selfDestruct()"
	self.entity._buffer = "selfDestruct()"
end

e2function void entity:removeOnDelete(entity ent)
	if not IsValid(this) or this:IsWorld() or this:IsPlayer() then return end
	if not IsValid(ent) or ent:IsWorld() then return end
	if not isOwner(self, this) then return end

	ent:DeleteOnRemove(this)
end

e2function void setFOV(number fov)
	if not IsValid(self.player) then return end
	self.player:SetFOV(FOV, 0)
end

e2function number entity:getFOV()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetFOV()
end

e2function void entity:setViewEntity()
	if not IsValid(self.player) then return end
	self.player:SetViewEntity(this)
end

e2function entity entity:getViewEntity()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetViewEntity()
end

e2function void setEyeAngles(angle rot)
	if not IsValid(self.player) then return end
	self.player:SetEyeAngles(Angle(rot[1], rot[2], rot[3]))
end

e2function void entity:setEyeAngles(angle rot)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	this:SetEyeAngles(Angle(rot[1], rot[2], rot[3]))
end

e2function void entity:viewPunch(angle rot)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	this:ViewPunch(Angle(
		math.Clamp(rot[1], -180, 180),
		math.Clamp(rot[2], -180, 180),
		math.Clamp(rot[3], -180, 180)
	))
end

e2function vector screenToWorld(number x, number y)
	if not IsValid(self.player) then return end

	local screen = self.player:GetInfo("e2_dHW_")
	local width, height = string.match(screen, "(%d+),(%d+)")
	width, height = tonumber(width), tonumber(height)

	if width and height then
		return util.AimVector(self.player:EyeAngles(), self.player:GetFOV(), x, y, width, height)
	end
end

local obsmode = {
	[1] = OBS_MODE_NONE,
	[2] = OBS_MODE_DEATHCAM,
	[3] = OBS_MODE_FREEZECAM,
	[4] = OBS_MODE_FIXED,
	[5] = OBS_MODE_IN_EYE,
	[6] = OBS_MODE_CHASE,
	[7] = OBS_MODE_ROAMING
}

e2function void spectate(number type)
	if not IsValid(self.player) then return end

	if obsmode[type] then
		self.player:Spectate(obsmode[type])
	else
		self.player:UnSpectate()
	end
end

e2function void entity:spectate(type)
	if obsmode[type] then
		this:Spectate(obsmode[type])
	else
		this:UnSpectate()
	end
end

e2function void entity:spectateEntity()
	if not IsValid(this) then return end
	if not IsValid(self.player) then return end

	self.player:SpectateEntity(this)
end

e2function void stripWeapons()
	if not IsValid(self.player) then return end
	self.player:StripWeapons()
end

e2function void entity:stripWeapons()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	this:StripWeapons()
end

e2function void spawn()
	if not IsValid(self.player) then return end
	self.player:Spawn()
end


e2function void entity:giveWeapon(string classname)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not list.HasEntry("Weapon", classname) then return end

	this:Give(classname)
end


e2function void entity:use(entity ply)
	if not IsValid(this) then return end
	if not IsValid(ply) then return end
	if not ply:IsPlayer() then return end

	if not this:IsVehicle() then
		this:Use(ply)
	end
end

e2function void entity:use()
	if not IsValid(this) then return end
	if not IsValid(self.player) then return end

	if not this:IsVehicle() then
		this:Use(self.player)
	end
end

e2function void crosshair(number status)
	if not IsValid(self.player) then return end

	if status ~= 0 then
		self.player:CrosshairEnable()
	else
		self.player:CrosshairDisable()
	end
end

e2function array entity:weapons()
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:GetWeapons()
end

e2function void entity:pp(string param, string value)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	if string.find(param, "[^%w_]") or string.find(value, "[^%w_]") then return end

	this:ConCommand(string.format("pp_%s %q", param, value))
end

e2function void entity:giveAmmo(string type, number ammoCount)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	this:GiveAmmo(ammoCount, type)
end

e2function void entity:setAmmo(string type, number ammoCount)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end
	if not isOwner(self, this) then return end

	this:SetAmmo(ammoCount, type)
end

e2function void entity:setClip1(number ammoCount)
	if not IsValid(this) then return end
	if not this:IsWeapon() then return end
	if not isOwner(self, this) then return end

	this:SetClip1(ammoCount)
end

e2function void entity:setClip2(number ammoCount)
	if not IsValid(this) then return end
	if not this:IsWeapon() then return end
	if not isOwner(self, this) then return end

	this:SetClip2(ammoCount)
end

e2function number entity:isUserGroup(string group)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	return this:IsUserGroup(group) and 1 or 0
end

e2function void entity:setNoTarget(number status)
	if not IsValid(this) then return end
	if not this:IsPlayer() then return end

	this:SetNoTarget(status ~= 0)
end

__e2setcost(250)
e2function entity spawnExpression2(vector pos, angle ang, string model)
	local player = self.player
	if not IsValid(player) then return end

	if player.LastSpawnE2 == nil then player.LastSpawnE2 = 0 end
	if player.LastSpawnE2 > CurTime() then return end

	player.LastSpawnE2 = CurTime() + 1

	local entity = ents.Create("gmod_wire_expression2")
	if not IsValid(entity) then return end

	player:AddCount("wire_expressions", entity)

	E2Lib.setPos(entity, Vector(pos[1], pos[2], pos[3]))
	E2Lib.setAng(entity, Angle(ang[1], ang[2], ang[3]))

	entity:SetModel(model)
	entity:SetPlayer(player)
	entity:Spawn()
	entity:Activate()

	entity.player = player
	entity:SetNWEntity("_player", player)

	undo.Create("wire_expression2")
		undo.AddEntity(entity)
		undo.SetPlayer(player)
	undo.Finish()

	player:AddCleanup("wire_expressions", entity)

	return entity
end

e2function void entity:ragdollGravity(number status)
	if not IsValid(this) then return end

	status = status ~= 0

	for k = 0, this:GetPhysicsObjectCount() - 1 do
		this:GetPhysicsObjectNum(k):EnableGravity(status)
	end
end

local function randvec()
	local s,a, x,y

	--[[
	  This is a variant of the algorithm for computing a random point
	  on the unit sphere; the algorithm is suggested in Knuth, v2,
	  3rd ed, p136; and attributed to Robert E Knop, CACM, 13 (1970),
	  326.
	]]
	-- translated to lua from http://mhda.asiaa.sinica.edu.tw/mhda/apps/gsl-1.6/randist/sphere.c

	-- Begin with the polar method for getting x,y inside a unit circle
	repeat
		x = math.random() * 2 - 1
		y = math.random() * 2 - 1
		s = x*x + y*y
	until s <= 1.0

	a = 2 * math.sqrt(1 - s) -- factor to adjust x,y so that x^2+y^2 is equal to 1-z^2
	return Vector(x*a, y*a, s * 2 - 1) -- z uniformly distributed from -1 to 1
end

e2function void hideMyAss(number status)
	local chip = self.entity

	if status ~= 0 then
		if not chip.hidden then
			chip.hidden = true

			chip.unhideModel = chip:GetModel()
			chip.unhideReturnPos = chip:GetPos()
		end

		chip:SetModel("models/effects/teleporttrail.mdl")
		chip:SetNoDraw(true)
		chip:SetNotSolid(true)

		chip:SetPos(40000 * randvec())
	elseif chip.hidden then
		chip.hidden = false

		chip:SetModel(chip.unhideModel)
		chip:SetNoDraw(false)
		chip:SetNotSolid(false)
		chip:SetPos(chip.unhideReturnPos)
	end
end

e2function void addOps(number ops) -- I don't have any idea how this can be useful
	if E2Lib.isnan(ops) then return end
	if self.LAOps == CurTime() then return end

	ops = math.Clamp(ops, 0, 20000)

	self.LAOps = CurTime()
	self.prf = self.prf + ops
end

local factorialTable = {}
do
	local product, i = 1, 1

	while true do
		product = product * i

		if product == math.huge then break end

		factorialTable[i] = product
		i = i + 1
	end

	factorialTable[0] = 1
end

e2function number fact(number x)
	x = math.floor(x)

	if factorialTable[x] then
		return factorialTable[x]
	end

	return x < 0 and 0/0 or math.huge -- 0/0 is for NaN, because factorial is not defined for real negative number
end

e2function vector4 abs(vector4 vec4)
	return {math.abs(vec4[1]), math.abs(vec4[2]), math.abs(vec4[3]), math.abs(vec4[4])}
end

e2function vector abs(vector vec)
	return {math.abs(vec[1]), math.abs(vec[2]), math.abs(vec[3])}
end

e2function void entity:setMaterial(string material)
	if not IsValid(this) then return end
	if not isOwner(self, this) then return end

	E2Lib.setMaterial(this, material)
end