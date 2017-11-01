local function is_dancing(ply)
	return ply:GetNetData("dancing")
end

if CLIENT then
	--local bpm = CreateClientConVar("dance_bpm", 120, true, true)

	hook.Add("ShouldDrawLocalPlayer", "dance", function(ply)
		if is_dancing(ply) then
			return true
		end
	end)

	hook.Add("CalcView", "dance", function(ply, pos)
		if not is_dancing(ply) then return end

		local pos = pos + ply:GetAimVector() * -100
		local ang = (ply:EyePos() - pos):Angle()

		return {
			origin = pos,
			angles = ang,
		}
	end)

	local suppress = false
	local beats = {}
	local lastBPM = 0
	local lastTime

	hook.Add("CreateMove", "dance", function(cmd) end)

	local IN_JUMP	 = IN_JUMP
	local IN_ATTACK = IN_ATTACK
	local IN_ATTACK2 = IN_ATTACK2
	local IN_DUCK = IN_DUCK

	local t = {
		[IN_JUMP]		= false,
		[IN_ATTACK]		= false,
		[IN_ATTACK2]	= false,
		[IN_DUCK]		= false,
	}
	local set = {

	}
	local function Set(n) local is = set[n] if is then set[n]=false end return is end

	hook.Add("StartCommand", "dance", function(pl,cmd)
		if is_dancing(pl) then
			for k,v in next, t do
				local state = cmd:KeyDown(k)

				if state~=v then
					t[k]=state
					if state then
						set[k]=true
					end
				end
			end

			cmd:SetButtons(0)
			--cmd:ClearMovement()
		end
	end)


	hook.Add("Think", "dance", function()

		for k,ply in next,player.GetAll() do
			if is_dancing(ply) then
				local bpm = (ply:GetNetData("dance_bpm") or 120) / 94
				local add =  FrameTime()*bpm*0.1

				local t = (ply.dance_state or 0) + add
				ply.dance_state = t
			end
		end


		local ply = LocalPlayer()
		if not is_dancing(ply) then return end



		if Set(IN_JUMP) then

			local time = RealTime()

			if lastTime then
				if time - lastTime > 5 or ( lastBPM > 0 and math.abs(60/(time-lastTime) - lastBPM) > 20 ) then
					beats = {}
					lastBPM = 0
				else
					table.insert(beats, time - lastTime)
					if #beats > 5 then table.remove(beats, 1) end
					local tempo = 0
					for _,diff in pairs(beats) do tempo = tempo + diff end
					lastBPM = 60/(tempo/#beats)

					--RunConsoleCommand("dance_bpm", lastBPM)
					RunConsoleCommand("dance_setrate", lastBPM)

				end
			end

			lastTime = time
		end
		if Set(IN_ATTACK) then
			print"actx group"
			RunConsoleCommand("actx","group")
		end
		if Set(IN_ATTACK2) then
			print"stopping dancing"
			RunConsoleCommand("dance_stop")

		end
		if Set(IN_DUCK) then
			print"stopping dancing"
			RunConsoleCommand("actx","halt")

		end

	end)

	hook.Add("PlayerThink","dance",function(ply) end)


	hook.Add("CalcMainActivity", "dance", function(ply)
		if is_dancing(ply) then
			--local bpm = (ply:GetNetData("dance_bpm") or 120) / 94
			--local time = (RealTime() / 10) * bpm

			local time = ply.dance_state or RealTime()*0.1*(120/94)

			time = time%2
			if time > 1 then
				time = -time + 2
			end

			time = time * 0.8
			time = time + 0.11

			ply:SetCycle(time)

			return 0, ply:LookupSequence("taunt_dance")
		end
	end)
end

if SERVER then
	concommand.Add("dance_setrate", function(ply, _, args)
		local bpm = tonumber(args[1])
		ply:SetNetData("dance_bpm", bpm)
		if bpm and bpm>0  then
			ply:PrintMessage(HUD_PRINTCENTER,"BPM: "..math.Round(bpm))
		end
		timer.Create('bpm'..ply:EntIndex(),3,1,function()
			if not ply:IsValid() then return end
			ply:ChatPrint("BPM: "..math.Round(bpm))
		end)
	end)
	concommand.Add("dance_stop", function(ply, _, args)
		if ply:GetNetData("dancing") then
			ply:SetNetData("dancing", nil)
			ply:SetNetData("dance_bpm", nil)
		end
	end)

	local function addcmd()
		iin.AddCommand("dance", function(ply,bpm)
			if tonumber(bpm) == nil then
				bpm = ply:GetNetData("dance_bpm") or 120
			end
			bpm = bpm and math.Clamp(tonumber(bpm), 0, 100000000)
			if not ply:GetNetData("dancing") then
				ply:SetNetData("dancing", true)
				if bpm then
					ply:SetNetData("dance_bpm",bpm)
				end
			else
				ply:SetNetData("dancing", nil)
				ply:SetNetData("dance_bpm", nil)
			end
		end)
	end

	if iin then
		addcmd()
	else
		hook.Add("iin_Initialized", "dance", function()
			addcmd()
			hook.Remove("iin_Initialized", "dance")
		end)
	end

	hook.Add("PlayerDeath", "DancingDeath", function(ply)
		if ply:GetNetData("dancing") then
			ply:SetNetData("dancing", nil)
			ply:SetNetData("dance_bpm", nil)
		end
	end)
end 

