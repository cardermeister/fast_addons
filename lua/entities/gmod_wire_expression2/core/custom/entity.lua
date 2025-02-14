/******************************************************************************\
Entity Core by Informatixa and MetaGamerz Team
\******************************************************************************/

hook.Add("PlayerInitialSpawn", "wire_expression2_entitycore", function(ply)
	ply:SendLua('language.Add("Undone_e2_spawned_entity", "E2 Spawned Entity")')
end)

local sbox_e2_maxentitys = CreateConVar( "sbox_e2_maxentitys", "-1", FCVAR_ARCHIVE )
local sbox_e2_maxentitys_persecond = CreateConVar( "sbox_e2_maxentitys_persecond", "12", FCVAR_ARCHIVE )
local sbox_e2_entitycore = CreateConVar( "sbox_e2_entitycore", "2", FCVAR_ARCHIVE )

local E2totalspawnedentitys = 0
local E2tempSpawnedEntitys = 0

local function ValidSpawn()
	if E2tempSpawnedEntitys >= sbox_e2_maxentitys_persecond:GetInt() then return false end
	if sbox_e2_maxentitys:GetInt() <= -1 then
		return true
	elseif E2totalspawnedentitys >= sbox_e2_maxentitys:GetInt() then
		return false
	end
	return true
end

local function ValidAction(ply)
	if not IsValid(ply) then return false end
	if sbox_e2_entitycore:GetInt() == 2 then return true end
	
	return sbox_e2_entitycore:GetInt() == 1 and ply:IsAdmin()
end

local Blent = {
	"game_end",
	"lua_run",
	"point_commentary_node",
	"combine_mine",
	"env_entity_dissolver",
	"prop_vehicle_crane"
}

--sql.Query([[CREATE TABLE IF NOT EXISTS 2somethingtest1337(Ply,Val)]])
--globalentsss = {}

local function createentitysfromE2(self,entity,pos,angles,freeze)
	if not ValidSpawn() then return nil end
	for k=1,#Blent do 
		if entity:lower()==Blent[k] then return end 
	end 
	if entity:lower():Left(5)=="func_" then return end
	
	if not self.player.entitySpawnCount then self.player.entitySpawnCount = 1 end 
	if self.player.entitySpawnCount > 50 then return end
	
	local ent = ents.Create(entity)
	--sql.Query([[INSERT INTO 2somethingtest1337(Ply,Val) VALUES(]]..self.player:UniqueID()..[[,']]..entity..[[')]])
	if not IsValid(ent) then return nil end
	ent:SetPos(pos)
	ent:CPPISetOwner(self.player)
	ent:SetAngles(angles)
	if not ent:IsNPC() then
		ent:SetOwner(self.player)
	end
	ent:Spawn()
	ent.e2co = true 
	self.player:AddCleanup( "props", ent )
	
	
	self.player.entitySpawnCount=self.player.entitySpawnCount+1
	ent:CallOnRemove("Remove_entitySpawnCount",function() self.player.entitySpawnCount=self.player.entitySpawnCount-1 end)
	
	undo.Create("e2_Ent("..tostring(ent:GetClass())..")")
		undo.AddEntity( ent )
		undo.SetPlayer( self.player )
	undo.Finish()
	local phys = ent:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		if freeze then phys:EnableMotion( false ) end
	end
	--ent.OnDieFunctions.GetCountUpdate.Function2 = ent.OnDieFunctions.GetCountUpdate.Function
	--ent.OnDieFunctions.GetCountUpdate.Function =  function(self,player,class)
	--	if CLIENT then return end
	--	E2totalspawnedentitys=E2totalspawnedentitys-1
	--	self.OnDieFunctions.GetCountUpdate.Function2(self,player,class)
	--end
	E2totalspawnedentitys = E2totalspawnedentitys+1
	E2tempSpawnedEntitys = E2tempSpawnedEntitys+1
	if E2tempSpawnedEntitys==1 then
		timer.Simple( 1, function()
			E2tempSpawnedEntitys=0
		end)
	end
	return ent
end

--------------------------------------------------------------------------------
__e2setcost(200)
e2function entity entitySpawn(string entity, number frozen)
	if not ValidAction(self.player) then return nil end
	return createentitysfromE2(self,entity,self.entity:GetPos()+self.entity:GetUp()*25,self.entity:GetAngles(),frozen)
end

e2function entity entitySpawn(entity template, number frozen)
	if not ValidAction(self.player) then return nil end
	if not IsValid(template) then return nil end
	return createentitysfromE2(self,template:GetClass(),self.entity:GetPos()+self.entity:GetUp()*25,self.entity:GetAngles(),frozen)
end

e2function entity entitySpawn(string entity, vector pos, number frozen)
	if not ValidAction(self.player) then return nil end
	return createentitysfromE2(self,entity,Vector(pos[1],pos[2],pos[3]),self.entity:GetAngles(),frozen)
end

e2function entity entitySpawn(entity template, vector pos, number frozen)
	if not ValidAction(self.player) then return nil end
	if not IsValid(template) then return nil end
	return createentitysfromE2(self,template:GetClass(),Vector(pos[1],pos[2],pos[3]),self.entity:GetAngles(),frozen)
end

e2function entity entitySpawn(string entity, angle rot, number frozen)
	if not ValidAction(self.player) then return nil end
	return createentitysfromE2(self,entity,self.entity:GetPos()+self.entity:GetUp()*25,Angle(rot[1],rot[2],rot[3]),frozen)
end

e2function entity entitySpawn(entity template, angle rot, number frozen)
	if not ValidAction(self.player) then return nil end
	if not IsValid(template) then return nil end
	return createentitysfromE2(self,template:GetClass(),self.entity:GetPos()+self.entity:GetUp()*25,Angle(rot[1],rot[2],rot[3]),frozen)
end

e2function entity entitySpawn(string entity, vector pos, angle rot, number frozen)
	if not ValidAction(self.player) then return nil end
	return createentitysfromE2(self,entity,Vector(pos[1],pos[2],pos[3]),Angle(rot[1],rot[2],rot[3]),frozen)
end

e2function entity entitySpawn(entity template, vector pos, angle rot, number frozen)
	if not ValidAction(self.player) then return nil end
	if not IsValid(template) then return nil end
	return createentitysfromE2(self,template:GetClass(),Vector(pos[1],pos[2],pos[3]),Angle(rot[1],rot[2],rot[3]),frozen)
end

__e2setcost(100)
e2function void entity:setModel(string model)
	if not ValidAction(self.player) then return end
	if not IsValid(this) then return end
	if !isOwner(self, this) then return end
	if this:IsWeapon() then return end
	
	this:SetModel(model)
end

e2function void entity:setOwnerNoEntity()
	if !IsValid(this) then return end
	if !isOwner(self, this) then return end
	if !this.e2co then return end
	
	this:SetOwner(nil)
end