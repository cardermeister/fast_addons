-- Ability to remove players by remover tool on a right click
-- Player should have admin rights

hook.Add( "Initialize", "players_remover", function()

	local wep = weapons.GetStored( "gmod_tool" )
	local TOOL = wep.Tool.remover
	
	local function DoRemoveEntity( tool, ent, isRightClicking )
		
		-- Validate an entity and check for admin rights if trying to remove player
		if not IsValid( ent ) or ( ent:IsPlayer() and not tool:GetOwner():IsAdmin() ) then return false end
	
		-- Nothing for the client to do here
		if CLIENT then return true end
	
		-- Remove all constraints (this stops ropes from hanging around)
		constraint.RemoveAll( ent )
	
		-- Remove it properly in 1 second
		timer.Simple( 1, function()
			
			if IsValid( ent ) then
				if ent:IsPlayer() then
					ent:Kick( "" )
				else
					ent:Remove()
				end
			end
			
		end )
	
		-- Make it non solid
		ent:SetNotSolid( true )
		ent:SetMoveType( MOVETYPE_NONE )
		ent:SetNoDraw( true )
	
		-- Send Effect
		local ed = EffectData()
			ed:SetOrigin( ent:GetPos() )
			ed:SetEntity( ent )
		util.Effect( "entity_remove", ed, true, true )
	
		return true
	
	end
	
	--
	-- Remove this entity and everything constrained
	--
	function TOOL:RightClick( trace )
	
		local Entity = trace.Entity
	
		if not IsValid( Entity ) then return false end
	
		-- Client can bail out now.
		if CLIENT then return true end
	
		local ConstrainedEntities = constraint.GetAllConstrainedEntities( trace.Entity )
		local Count = 0
	
		-- Loop through all the entities in the system
		for _, Entity in pairs( ConstrainedEntities ) do
	
			if DoRemoveEntity( self, Entity, true ) then
				Count = Count + 1
			end
	
		end
	
		return true
	
	end
	
	weapons.Register( wep, "gmod_tool" )
	
	hook.Remove( "Initialize", "players_remover" )

end )