local PLAYER = FindMetaTable("Player")


if SERVER then
	local function CanChangeName(ply, name)
		local oldname = ply:Nick()
		local newname = (name == "" or name == nil) and ply:DefaultName() or name
		if oldname == newname then return false end
		
		if not ply:IsAdmin() then
			if name then
				if (utf8.len(name) or #name) > 32 then
					ply:ChatPrint("Слишком длинный ник.")
					return false
				end
			end
			
			local cooldown = ply.nameCooldown
			if not cooldown then cooldown = 0 end
			
			local curtime = CurTime()
			if curtime < cooldown then
				ply:ChatPrint(Format(
					"Подождите ещё %i сек., прежде чем изменить ник.",
					ply.nameCooldown - curtime
				))
				
				return false
			end
			
			ply.nameCooldown = curtime + 30
		end
		
		return true
	end
	
	function PLAYER:SetName(name, verbose)
		local oldname = self:Nick()
		local newname
		
		if not name then
			self:SetNWString("FName", "")
			newname = self:DefaultName()
		else
			name = name:gsub("\n", "")
			self:SetNWString("FName", name)
			
			newname = name == "" and self:DefaultName() or name
		end
		
		if verbose then
			all:ChatPrint(Format(
				"Player %s changed name to %s",
				oldname,
				newname
			))
		end
	end
	
	iin.AddCommand("setname", function(ply, name)
		if CanChangeName(ply, name) then
			ply:SetName(name, true)
		end
	end, "players", true)
	
	iin.AddCommand("defname", function(ply)
		if CanChangeName(ply, name) then
			ply:SetName("", true)
		end
	end, "players", true)
end


if not PLAYER.DefaultName then
	PLAYER.DefaultName = PLAYER.Nick	
end

function PLAYER:Nick()
	local name = self:GetNWString("FName")

	if name ~= "" then
		return name
	else
		return self:DefaultName()
	end
end


PLAYER.GetName = PLAYER.Nick
PLAYER.Name = PLAYER.Nick

function PLAYER:__tostring()
	if IsValid(self) then
		return string.format("Player [%d][%s]", self:EntIndex(), self:Nick())
	end
	
	return "Player [NULL]"
end