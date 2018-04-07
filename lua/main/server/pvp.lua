local tag = "pvp"
local changeModeDelay = 5

game.ConsoleCommand("sbox_playershurtplayers 1\n")
game.ConsoleCommand("sbox_godmode 0\n")

if not OLD_UNLOCK then
	local PLAYER = FindMetaTable("Player")
	OLD_UNLOCK = PLAYER.UnLock
	
	function PLAYER:UnLock()
		OLD_UNLOCK(self)
		
		if not self.pvp then
			self:GodEnable()
		end
	end
end


local PLAYER = FindMetaTable("Player")
function PLAYER:SetPvP(state, silent)
	assert(IsValid(self) and self:IsPlayer(), "Should be used on a player")
	assert(isbool(state), "bad argument #2 to 'SetPvP' (boolean expected, got " .. type(state) .. ")")
	
	self.pvp = state
	
	if state then
		self:GodDisable()
		
		if self:GetMoveType() == MOVETYPE_NOCLIP then
			self:SetMoveType(MOVETYPE_WALK)
		end
		
		self:SetSolid(SOLID_BBOX)
		
		for i, chip in ipairs(ents.FindByClass "gmod_wire_expression2") do
			if chip.player == self then
				if not silent then
					chip:Error("Вы перешли в режим PvP")
				end
				chip:Remove()
			end
		end
	else
		self:GodEnable()
	end
end


iin.AddCommand("pvp", function(ply)
	if not ply.pvp and CurTime() >= ply.pvpNextChangeMode then
		ply.pvpNextChangeMode = CurTime() + changeModeDelay
		ply:SetPvP(true)
		
		local class = ply.m_CurrentPlayerClass
		
		ply:SetWalkSpeed(class.WalkSpeed)
		ply:SetRunSpeed(class.RunSpeed)
		ply:SetCrouchedWalkSpeed(class.CrouchedWalkSpeed)
		ply:SetDuckSpeed(class.DuckSpeed)
		ply:SetUnDuckSpeed(class.UnDuckSpeed)
		ply:SetJumpPower(class.JumpPower)
		ply:SetMaxHealth(class.MaxHealth)
		
		if ply:Health() > 100 then
			ply:SetHealth(100)
		end
		
		iin.Msg(
			nil,
			Color(255, 187, 0),
			" ● ",
			ply,
			color_white,
			" перешёл в ",
			Color(255, 0, 0),
			"PvP",
			color_white,
			" режим."
		)
	end
end, "players", true)


iin.AddCommand("build", function(ply)
	if ply.pvp and CurTime() >= ply.pvpNextChangeMode then
		ply.pvpNextChangeMode = CurTime() + changeModeDelay
		ply:SetPvP(false)
		
		iin.Msg(
			nil,
			Color(255, 187, 0),
			" ● ",
			ply,
			color_white,
			" перешёл в ",
			Color(0, 255, 0),
			"строительный",
			color_white,
			" режим."
		)
	end
end, "players", true)


hook.Add("PlayerInitialSpawn", tag, function(ply)
	ply.pvpNextChangeMode = 0
	ply.pvp = false
end)


hook.Add("PlayerSpawn", tag, function(ply)
	if not ply.pvp then
		ply:GodEnable()
	end
end)


hook.Add("PlayerNoClip", tag, function(ply, state)
	if state and ply.pvp then return false end
end)


hook.Add("CanTool", tag, function(ply, trace, tool)
	if ply.pvp and tool == "wire_expression2" then
		return false
	end
end)

hook.Add("EntityTakeDamage", tag, function(target, dmg)
	local attacker = dmg:GetAttacker()
	
	if not attacker:IsNPC() and target:IsPlayer() and not dmg:IsFallDamage() then
		if not attacker.pvp then return true end
		if not target.pvp then return true end
	end
end)