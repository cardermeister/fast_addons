local isOwner = E2Lib.isOwner
local IsValid = IsValid
registerCallback("e2lib_replace_function", function(funcname, func, oldfunc)
	if funcname == "isOwner" then
		isOwner = func
	elseif funcname == "IsValid" then
		IsValid = func
	end
end)

-- faster access to some math library functions
local abs = math.abs
local atan2 = math.atan2
local sqrt = math.sqrt
local asin = math.asin
local Clamp = math.Clamp

local rad2deg = 180 / math.pi

local function getBone(entity, index)
	local bone = {ent=entity:EntIndex(), index=index}
	if not bone then return nil end

	return bone
end
E2Lib.getAtt = getBone

-- checks whether the bone is valid. if yes, returns the bone's entity and bone index; otherwise, returns nil.
local function isValidBone(b)
	if type(b) ~= "table" or not b then return nil, 0 end
	local ent = Entity(b.ent)
	if not IsValid(ent) then
		return nil, 0
	end
	return ent, b.index
end
E2Lib.isValidBBone = isValidBone

--[[************************************************************************]]--

registerType("attachment", "xat", nil,
	nil,
	nil,
	function(retval)
		if retval == nil then return end
		if type(retval) ~= "table" then error("Return value is neither nil nor a table, but a "..type(retval).."!",0) end
	end,
	function(b)
		return not isValidBone(b)
	end
)

--[[************************************************************************]]--

__e2setcost(1)

--- if (B)
e2function number operator_is(attachment b)
	if not isValidBone(b) then return 0 else return 1 end
end

--- B = B
registerOperator("ass", "xat", "xat", function(self, args)
	local op1, op2, scope = args[2], args[3], args[4]
	local      rv2 = op2[1](self, op2)
	self.Scopes[scope][op1] = rv2
	self.Scopes[scope].vclk[op1] = true
	return rv2
end)

--- B == B
e2function number operator==(attachment lhs, attachment rhs)
	if lhs == rhs then return 1 else return 0 end
end

--- B != B
e2function number operator!=(attachment lhs, attachment rhs)
	if lhs ~= rhs then return 1 else return 0 end
end

--[[************************************************************************]]--
__e2setcost(3)

--- Returns <this>'s <index>th bone.
e2function attachment entity:bBone(index)
	if not IsValid(this) then return nil end
	if index < 0 then return nil end
	return getBone(this, index)
end

--[[Returns an array containing all of <this>'s bones. This array's first element has the index 0!
e2function array entity:bBones()
	if not IsValid(this) then return {} end
	local ret = {}
	local maxn = this:GetPhysicsObjectCount()-1
	for i = 0,maxn do
		ret[i] = getBone(this, i)
	end
	return ret
end]]--

--- Returns <this>'s number of bones.
e2function number entity:bBoneCount()
	if not IsValid(this) then return 0 end
	return this:GetBoneCount()
end

__e2setcost(1)

--- Returns an invalid bone.
e2function attachment nobBone()
	return nil
end

--- Returns the entity <this> belongs to
e2function entity attachment:entity()
	return isValidBone(this)
end

--- Returns <this>'s index in the entity it belongs to. Returns -1 if the bone is invalid or an error occured.
e2function number attachment:index()
	if not isValidBone(this) then return -1 end
	return this.index
end

--[[************************************************************************]]--

--- Returns <this>'s position.
e2function vector attachment:pos()
	if not isValidBone(this) then return {0, 0, 0} end
	return ({Entity(this.ent):GetBonePosition(this.index)})[1] or {0,0,0}
end

e2function number attachment:length()
	if not isValidBone(this) then return 0 end
	return Entity(this.ent):BoneLength(this.index) or 1
end

--- Returns a vector describing <this>'s forward direction.
e2function vector attachment:forward()
	if not isValidBone(this) then return {0, 0, 0} end
	return ({Entity(this.ent):GetBonePosition(this.index)})[2]:Forward() or {0,0,0}
end

--- Returns a vector describing <this>'s right direction.
e2function vector attachment:right()
	if not isValidBone(this) then return {0, 0, 0} end
		return ({Entity(this.ent):GetBonePosition(this.index)})[2]:Right() or {0,0,0}
end

--- Returns a vector describing <this>'s up direction.
e2function vector attachment:up()
	if not isValidBone(this) then return {0, 0, 0} end
	return ({Entity(this.ent):GetBonePosition(this.index)})[2]:Up() or {0,0,0}
end

e2function array attachment:getChildren()
	if not isValidBone(this) then return {} end
	local t = Entity(this.ent):GetChildBones(this.index)
	for k,v in pairs(t) do
	  t[k] = getBone(Entity(this.ent),v)
	end
	return t or {}
end

e2function attachment attachment:getParent()
	if not isValidBone(this) then return this end
	return getBone(Entity(this.ent), Entity(this.ent):GetBoneParent(this.index) or this.index)
end

--[[************************************************************************]]--

--- Transforms <pos> from local coordinates (as seen from <this>) to world coordinates.
e2function vector attachment:toWorld(vector pos)
	if not isValidBone(this) then return {0, 0, 0} end
	return ({LocalToWorld(Vector(pos[1],pos[2],pos[3]),Angle(0,0,0),({Entity(this.ent):GetBonePosition(this.index)})[1],({Entity(this.ent):GetBonePosition(this.index)})[2])})[1]
end

--- Transforms <pos> from world coordinates to local coordinates (as seen from <this>).
e2function vector attachment:toLocal(vector pos)
	if not isValidBone(this) then return {0, 0, 0} end
	return ({WorldToLocal(Vector(pos[1],pos[2],pos[3]),Angle(0,0,0),({Entity(this.ent):GetBonePosition(this.index)})[1],({Entity(this.ent):GetBonePosition(this.index)})[2])})[1]
end

--[[************************************************************************]]--


--- Returns <this>'s pitch, yaw and roll angles.
e2function angle attachment:angles()
	if not isValidBone(this) then return {0, 0, 0} end
	local ang = Entity(this.ent):GetBoneMatrix(this.index):GetAngles() or Angle(0,0,0)
	return { ang.p, ang.y, ang.r }
end

e2function matrix4 attachment:matrix()
	if not isValidBone(this) then return {0, 0, 0} end
	local mat = Entity(this.ent):GetBoneMatrix(this.index) or Matrix(0)
	local matt = (mat:ToTable())
	return {unpack(matt[1]),unpack(matt[2]),unpack(matt[3]),unpack(matt[4])}
end

e2function void entity:parentBBone(attachment bone)
 if not isValidBone(bone) then return end
 if not IsValid(this) then return end
 --print(this.owner,self.player)
 if not isOwner(self, this) then return end
 this:FollowBone(Entity(bone.ent), bone.index)
end

e2function void unparentBBone(entity ent)
end

--[[************************************************************************]]--


-- helper function for invert(T) in table.lua
function e2_tostring_attachment(b)
	local ent = isValidBone(b)
	if not ent then return "(null)" end
	return string.format("%s:bone(%d)", tostring(ent), b.index)
end

--- Returns <b> formatted as a string. Returns "<code>(null)</code>" for invalid bones.
e2function string toString(attachment b)
	local ent = isValidBone(b)
	if not ent then return "(null)" end
	return string.format("%s:bone(%d)", tostring(ent), b.index)
end

WireLib.registerDebuggerFormat("BBONE", e2_tostring_bone)

--[[************************************************************************]]--
