local zvuki = {}

--[функция звучка]--
FindMetaTable"Entity".PlayURL = function( self ,url, pitch, vol )
	
	sound.PlayURL(url, "3d", function(station) 
		if !IsValid( station ) or !IsValid( self ) then return end 
		
		station:SetPos( self:GetPos() )
		station:SetPlaybackRate( pitch or 1 )
		station:SetVolume( vol or 1 )
		
		zvuki[station] = self
		
	end)
	
end

PlayURL = function( url, pitch, vol )
	
	sound.PlayURL(url, "mono", function(station) 
		if !IsValid(station) then return end 
		
		station:SetPlaybackRate( pitch or 1 )
		station:SetVolume( vol or 1 )
		
	end)
	
end

--[ловим url с сервреа]--
local function lovli_url( )
	local ent = net.ReadEntity()
	local url = net.ReadString()
	local pitch = net.ReadFloat()
	local vol = net.ReadFloat()
	
	if ent == game.GetWorld() then
		PlayURL( url, pitch, vol )
	else
		ent:PlayURL( url, pitch, vol )
	end
	
end

--[сетпозим звук чтобi не убежала]--
local function Parent_Sound()
	for s, ply in pairs(zvuki) do
		if s:GetLength() != s:GetTime() and IsValid(ply) then
			s:SetPos(ply:GetPos())
		else
			zvuki[s] = nil
		end
	end
end


hook.Add( "Think", "ne_udew", Parent_Sound )
net.Receive( 'URLSound', lovli_url )