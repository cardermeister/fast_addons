
local tag = 'Anti-Crash'


local function tagprint(txt)

	MsgC( Color(200,255,0), Format( "[%s] ", tag ) ) 
	print(txt)

end 


local function parseE2Args(self,args)

	local tab = {}

	for i = 2, #args-1 do

		local op = args[i]
		tab[#tab + 1] = op[1](self,op) 

	end

	return unpack(tab)

end

local function isOwner_fix( self, entity, checkOwner )
	local ret = isOwner( self, entity )
	
	if checkOwner then
		return ret and getOwner( self, entity ) == self.player
	end
	
	return ret
end


local e2replaces = {}
local function replaceFunctions()
	if not wire_expression2_funcs then return end

	for prototype, func in pairs( e2replaces ) do
		local intable = wire_expression2_funcs[ prototype ]
		
		if intable then
			intable[3] = func
		end
	end
end


local ParticlesThisSecond   = {}
local e2ragdolls = {}
local MaxParticlesPerSecond


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


local function ParticlesTimer(timerName,PlyID)
	timer.Destroy(timerName)
    ParticlesThisSecond[PlyID] = 0
end


for k=1, game.MaxPlayers() do ParticlesThisSecond[k]=0 end


local function SpawnParticle(self, Duration, StartSize, EndSize, Mat, RGB, Position, Velocity, Pitch, RollDelta, StartAlpha, EndAlpha)
	if not MaxParticlesPerSecond then MaxParticlesPerSecond = GetConVar"sbox_e2_maxParticlesPerSecond" end
	
    local PlyID     = self.player:EntIndex()
    local timerName = "e2p_"..PlyID

    if  ParticlesThisSecond[PlyID] <= MaxParticlesPerSecond:GetInt() then
		if Pitch==nil then Pitch=0 end
		if string.find(Mat:lower(),"pp",1,true) then return end
		if string.find(Mat:lower(),"comshieldwall",1,true) then return end
		if string.find(Mat:lower(),"altfire1") then
			tagprint( Format('игрок %s хотел всех крашнуть!',tostring(self.player)) )
			self.player:Kick'крашер1337'	
			return
		end
		if RollDelta==nil then RollDelta=0 end
		if StartAlpha==nil then StartAlpha=255 end
		if EndAlpha==nil then EndAlpha=StartAlpha end
        message(Duration, StartSize, EndSize, RGB, Position, Velocity, Mat, self.entity, Pitch, RollDelta, StartAlpha-128, EndAlpha-128)
        ParticlesThisSecond[PlyID] = ParticlesThisSecond[PlyID] + 1
        if !timer.Exists(timerName) then
            timer.Create(timerName, 1, 0, function() ParticlesTimer(timerName,PlyID) end)
        end
    end

end


local function parent_check( child, parent, self )
	while IsValid( parent ) do
		if (child == parent) then
			return false
		end
		parent = parent:GetParent()
		self.prf = self.prf + 10
	end
	return true
end


e2replaces['pp(e:ss)'] = function( self, args )

	local this, param, value = parseE2Args(self,args)

	if !IsValid(this) then return end
	if !this:IsPlayer() then return end
	if !isOwner(self,this)  then return end

	if string.find(param:lower(),";") or string.find(value:lower(),";") or string.find(value:lower(),"\n") or string.find(value:lower()," ") then return end
	this:ConCommand( Format( 'pp_%s "%s"', param, value ) )

end

e2replaces['addOps(n)'] = function( self, args )

	local Ops = parseE2Args(self,args)

	if tostring(Ops) == "nan" then return end
	if self.LAOps == CurTime() then return end 
	if E2Power.PlyHasAccess(self.player) then 
		if math.abs(Ops)>20000 then return end
	else 
		Ops = math.Clamp(Ops,0,20000)
	end
	self.LAOps = CurTime()
	self.prf = self.prf+Ops

end


e2replaces['playerRagdoll(e:)'] = function( self, args )

	local this = parseE2Args(self,args)

	if !IsValid(this) then return end
	if !isOwner_fix(self, this, true) then return end
	if !this:IsPlayer() then return end 
	if !this:Alive() then return end
	if this:InVehicle() then this:ExitVehicle()	end
	local v = this

	if !IsValid(v.ragdoll) then

		local ragdoll = ents.Create( "prop_ragdoll" )
		ragdoll.ragdolledPly = v
		ragdoll.kaker = self.player
		ragdoll:SetPos( v:GetPos() )
		local velocity = v:GetVelocity()
		ragdoll:SetAngles( v:GetAngles() )
		ragdoll:SetModel( v:GetModel() )
		ragdoll:Spawn()
		ragdoll:Activate()
		v:SetParent( ragdoll )
			
		local j = 0
		while true do 
			local phys_obj = ragdoll:GetPhysicsObjectNum( j )
			if phys_obj then
				phys_obj:SetVelocity( velocity )
				j = j + 1
			else
				break
			end
		end 

		v:Spectate( OBS_MODE_CHASE )
		v:SpectateEntity( ragdoll )
		v:StripWeapons() 

		v.ragdoll = ragdoll
		
		return ragdoll
	else
		v:SetParent()
		v:UnSpectate()

		local ragdoll = v.ragdoll
		ragdoll.kaker = nil
		v.ragdoll = nil 

		if ragdoll:IsValid() then 
			
			local pos = ragdoll:GetPos()
			pos.z = pos.z + 10 

			v:Spawn()
			v:SetPos( pos )
			v:SetVelocity( ragdoll:GetVelocity() )
			local yaw = ragdoll:GetAngles().yaw
			v:SetAngles( Angle( 0, yaw, 0 ) )

			ragdoll:Remove()
		end
	
		return v
	end

end


e2replaces['setParent(e:e)'] = function( self, args )
	
	local this, ent = parseE2Args(self,args)
	
	if !IsValid(this) then return end
	if !isOwner(self,this)  then return end
	if !IsValid(ent) then return end
	if !isOwner(self,ent)  then return end
	if this:IsPlayer() then return end
	if !parent_check( this, ent, self ) then return end
	this:SetParent( ent )
	
end


e2replaces['particle(nnnsvvv)'] = function( self, args )

	SpawnParticle( self, parseE2Args(self,args)  )

end


e2replaces['particle(nnnsvvvn)'] = function( self, args )

	SpawnParticle( self, parseE2Args(self,args)  )

end


e2replaces['particle(nnnsvvvnn)'] = function( self, args )

	SpawnParticle( self, parseE2Args(self,args)  )

end


e2replaces['particle(nnnsvvvnnnn)'] = function( self, args )

	SpawnParticle( self, parseE2Args(self,args)  )

end

e2replaces['setUndoName(e:s)'] = function( self, args )
	local this, name = parseE2Args(self,args)
	
	if !IsValid(this) then return end
	if !isOwner_fix(self,this,true) then return end

	undo.Create( name )
	undo.AddEntity( this )
	undo.SetPlayer( self.player )
	undo.Finish()
end


e2replaces['setUndoName(r:s)'] = function( self, args )
	local this, name = parseE2Args(self,args)
	
	undo.Create( name )
	
	for k,v in pairs(this) do
		if IsValid(v) and isOwner_fix(self,v, true) then undo.AddEntity( v ) end
		self.prf = self.prf + 20
	end

	undo.SetPlayer( self.player )
	undo.Finish()
end


-- For some reason functions can be restored back, so we check for it
timer.Create( "anti-crash check replaces", 1, 0, replaceFunctions )

hook.Add( "Initialize", "fix_e2_crash", replaceFunctions)

hook.Add('EntityRemoved','CheckE2Ragdoll',function(ent)

	if !ent.kaker or !IsValid(ent.kaker) then return end
	if !IsValid(ent.ragdolledPly) then return end
	if ent.kaker == ent.ragdolledPly then return end

	ent.ragdolledPly:SetParent()
	ent.kaker:SetParent(ent)
	tagprint( Format('%s пытался удалить >> %s!',tostring(ent.kaker),tostring(ent.ragdolledPly)) )

end)