local meta = FindMetaTable( "Player" )

if SERVER then
	
	local function AllowedToSetName(ply,name)
		if not ply:IsAdmin() then
			if name then
				if utf8.len( name ) > 32 then
					ply:ChatPrint( "Слишком длинный ник." )
					return
				end
			end
			
			local cooldown = ply.namecldwn
			if not cooldown then ply.namecldwn = 0 end
			
			local curtime = CurTime()
			if curtime < ply.namecldwn then
				ply:ChatPrint( Format( "Подождите ещё %i сек., прежде чем изменить ник.", ply.namecldwn - curtime ) )
				return
			end
			
			ply.namecldwn = CurTime() + 30
		end
		
		return true
	end
	
	meta.SetName = function(ply,name,donotverb)
		if not name then return end
		name = name:gsub( "\n", "" )
		
		local FName = ply:GetNWString( "FName" )
		
		ply:SetNWString( "FName", name )
		
		if donotverb then return end
		
		all:ChatPrint( Format(
			"Player %s changed name to %s",
			FName ~= "" and FName or ply:DefaultName(),
			name
		) )
	end
	
	iin.AddCommand( "setname", function(ply,name)
		if AllowedToSetName(ply,name) then ply:SetName(name) end
	end, "players", true )
	
	iin.AddCommand( "defname", function(ply)
		if AllowedToSetName(ply) then ply:SetName(ply:DefaultName()) end
	end, "players", true )
	
end

if not meta.DefaultName then
	meta.DefaultName = meta.Nick	
end

meta.Nick = function( ply )
	local FName = ply:GetNWString( "FName" )

	if FName != "" then
		return FName
	else
		return ply:DefaultName()
	end
 end

meta.GetName = meta.Nick
meta.Name = meta.Nick

--[[meta.__tostring = function( self )
	return string.format( "Player [%d][%s]", self:EntIndex(), self:Nick() )
end]]