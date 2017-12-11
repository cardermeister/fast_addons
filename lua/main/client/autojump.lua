local autojump       = CreateClientConVar("autojump", 0, true, false)
local autojump_speed = CreateClientConVar("autojump_speed", 1000, true, false)

local LocalPlayer=LocalPlayer
local wasonground=0

local bit=bit
if not bit then error"You need http://luaforge.net/projects/bit/ OR https://dl.dropbox.com/u/1910689/gmod/bit.lua for Garry's Mod 12!" end

hook.Add("CreateMove", "autojump", function(cmd)
	local pl=LocalPlayer()

	if pl:GetMoveType() ~= MOVETYPE_WALK or pl:WaterLevel()~=0 or not autojump:GetBool() then return end

	if bit.band(cmd:GetButtons() , IN_JUMP) ~= 0 then
		local boost = bit.band(cmd:GetButtons() , IN_SPEED) ~= 0 and 4 or 1

		if pl:IsOnGround() and pl:GetVelocity():Length() < autojump_speed:GetFloat() * boost then
			if wasonground > 100 then
				wasonground=0
				cmd:SetButtons(cmd:GetButtons() - IN_JUMP)
			else
				wasonground=wasonground+1
				cmd:SetButtons(bit.bor(cmd:GetButtons() , IN_JUMP))
			end
		else
			wasonground=0
			cmd:SetButtons(cmd:GetButtons() - IN_JUMP)
		end
	end
end)