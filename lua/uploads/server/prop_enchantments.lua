FindMetaTable"Entity".MakeDeadly = function( ent1 )
	if not ent1 then return end
	
	ent1:AddCallback( "PhysicsCollide", function( ent, coldata ) 
		local t = coldata.HitEntity
		if t:GetClass() == "player" and coldata.OurOldVelocity:Length() > Vector( 950, 10, 10 ):Length() then 
			t:Kill() 
		end 
	end)
end

FindMetaTable"Entity".MakeBlunt = function( ent1, ragdolltime )
	if not ent1 then return end

	ent1:AddCallback( "PhysicsCollide", function( ent, coldata ) 
		local v = coldata.HitEntity
		if v:GetClass() == "player" and coldata.OurOldVelocity:Length() > Vector( 1000, 10, 10 ):Length() then 
			local ragdoll = ents.Create( "prop_ragdoll" )
			ragdoll.ragdolledPly = v
			v.ragdoll = ragdoll
			--https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban17.mp3
			--"https://raw.githubusercontent.com/OldOverusedMeme/gmod/master/magilu"..math.random(1,5)..".mp3"
			v:PlayURL( "https://raw.githubusercontent.com/OldOverusedMeme/yeban/master/ban17.mp3" )
			
			ragdoll:SetPos( v:GetPos() )
			ragdoll:SetAngles( v:GetAngles() )
			ragdoll:SetModel( v:GetModel() )
			ragdoll:Spawn()
			ragdoll:Activate()
			
			v:Spectate( OBS_MODE_CHASE )
			v:SpectateEntity( ragdoll )
			v:StripWeapons()
			v:DropObject()
				
			timer.Simple( ragdolltime or 5, function()
				v:Spawn()
				v:UnSpectate()
				if not IsValid( ragdoll ) then return end
				v:SetPos( ragdoll:GetPos() )
				ragdoll:Remove()
				
				v:ViewPunch( Angle( -50, 0, 0 ) )
			end)
			
			hook.Run( "CreateEntityRagdoll", v, ragdoll )
		end 
	end)
end