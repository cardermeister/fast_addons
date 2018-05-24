hook.Add('iin_Initialized','AddSVCommands',function()

local FindEntity = easylua.FindEntity
local iin_Msg = iin.Msg

function iin.error(ply,str)
	iin_Msg(ply,Color(255,187,0),"✖ ",Color(255,15,15),'[ERROR] ',Color(25,255,52),str)
	print("( "..ply:Nick(),'<'..ply:SteamID()..'> )',"✖[ERROR]",str)
	--log.file_append need plugin faka
end
 
iin.AddCommand("title",function(ply,line)ply:SetCustomTitle(line,true)end, nil, true)

iin.AddCommand('stats',function()

	if not cpp then require'wbcpp1337' end
	//string.match(s,"S%s-(%d+%.%d+)%s-(%d+%.%d+)")
	local d,h,m = cpp.OS_Uptime()
	local total,free = cpp.OS_Swap()
	local swap_per = math.Round((1-free/total)*100)
	local m1,m5,m15 = cpp.OS_Load()
	local cpu_per = math.Round(m1 * 100)
	ChatAddText(Color(191,0,255),"[stats] ",Color(255,255,255),string.format("Server up %d days, %d hours, %d minutes. Map: %d hours. Used: %d%% mem, %d%% cpu.",d,h,m,math.Round(CurTime()/3600),swap_per,cpu_per))

end, "admins", true)

iin.AddCommand("kick",function(ply,args,target,reason)

	local ent = FindEntity(target)
	
	if ent && ent:IsPlayer() then
	
		if cleanup and cleanup.CC_Cleanup then
			cleanup.CC_Cleanup(ent,"gmod_cleanup",{})
		end
	
		local fx = { c = team.GetColor(ent:Team()), n = ent:GetName() }
		
		reason = reason or "byebye!!"
		
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' kicked ',fx.c,fx.n,Color(255,255,255),' with reason ('..reason..').')
		
		ent:Kick(reason)
		
		return
	end
	
	iin.error(ply,'Ply not found [!kick <Nick> <Reason>]')
	
end,'admins',true) 

iin.AddCommand("rcon",function(ply,line)
	if line and #line>0 then
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),'@',Color(207, 110, 90),'rcon',Color(255,255,255),': '..line)
		game.ConsoleCommand(line..'\n')
		return
	end
	iin.error(ply,' #arg == 0 ')
end,'devs',true)

iin.AddCommand('rank',function(ply,args)
	args = iin.ParseArgs(args)
	local id = FindEntity(args[1])
	local group = args[2]
	local validgruop = iin.GetValidGroups()[group]
	local write = args[3] and args[3]=='true' or false
	if id:IsPlayer() then
		if validgruop then
			id:SetUserGroup(group,write)
			iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' set usergroup of ',id,Color(255,255,255),' to '..group..(write and " and save to file" or "")..'.')
	
		else
			iin.error(ply,'This group is not valid :c')	
		end
	else
		iin.error(ply,'Ply not found.')	
	end
end,'owners', true)

iin.AddCommand("hp",function(ply,args)
	args = iin.ParseArgs(args)
	local id = FindEntity(args[1])
	local hp = tonumber(args[2])

	if id && id:IsPlayer() && hp then
		id:SetHealth(hp)
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' set ',id,Color(255,255,255),' health to '..hp..".")
		return
	end
	if !id:IsPlayer() then
	iin.error(ply,'Ply not found [!hp <Nick> <Hp>]')
	elseif !hp then
	iin.error(ply,'??WHERE HEALTH ARGs MAFAKA?? [!hp <Nick> <Hp>]')	
	end
end,'admins', true)


iin.AddCommand("decals",function(ply)
BroadcastLua([[
	print("Clean decals...")
	RunConsoleCommand("r_cleardecals")
	RunConsoleCommand("stopsound")
	for k, v in pairs (ents.GetAll()) do
		if ( v:GetClass() == "class C_ClientRagdoll" ) then
			v:Remove()
		end
	end
]])
iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' cleanup decals.')
end,'admins', true)

iin.AddCommand('goto',function(ply,line)
    if ply.pvp then return end
    if ply.time_to_goto and ply.time_to_goto >= CurTime() then return end
    
    ply.iin_tpprevious = ply:GetPos()
    if not ply:Alive() then ply:Spawn() end
    if !line then return end
    
    local x,y,z = line:match("(%-?%d+%.*%d*)[,%s]%s-(%-?%d+%.*%d*)[,%s]%s-(%-?%d+%.*%d*)")
    if x and y and z then
    	x, y, z =
    		math.Clamp(tonumber(x), -32767, 32768),
    		math.Clamp(tonumber(y), -32767, 32768),
    		math.Clamp(tonumber(z), -32767, 32768)

    	ply:SetPos(Vector(x, y, z))
    	iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' goto Vector('..x..','..y..','..z..')',Color(255,255,255),'.')
    	ply.time_to_goto = CurTime()+1
    	return
    end

    local ent = FindEntity(line)

	if ent:IsPlayer() then
		if ent:GetInfo("allowgoto") ~= "0" or ply:Team() > ent:Team() then
			local dir = ent:GetAngles(); dir.p = 0; dir.r = 0; dir = (dir:Forward() * -100)
			ply:SetPos(ent:GetPos() + dir)	
			ply:SetEyeAngles((ent:EyePos() - ply:EyePos()):Angle())
			ply:EmitSound("buttons/button15.wav")
		else
			ply:ChatPrint("The player has restricted !goto")
			return
		end
	else
		iin.error(ply,'Ply not found.')
		return 
	end
	iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' goto ',ent:IsPlayer() and ent,Color(255,255,255),'.')
	
	ply.time_to_goto = CurTime()+1
end, nil, true)

iin.AddCommand('return',function(ply)
	if ply.preventSpawn then return end
	if not ply:Alive() then ply:Spawn() end
	if ply.iin_tpprevious then
		ply:SetPos(ply.iin_tpprevious)
		ply:EmitSound("buttons/button15.wav")
	else
		iin.error(ply,'Last position not found.')
	end
end, nil, true)

iin.AddCommand('tp',function(ply,line)
	if not ply:Alive() then ply:Spawn() end
	local id = FindEntity(line)
	if id:IsPlayer() && !id:Alive() then id:Spawn() end
 	if id:IsPlayer() then
	id.iin_tpprevious = id:GetPos()
	if id:InVehicle() then id:ExitVehicle() end
	id:SetPos(ply:GetEyeTrace().HitPos)
	ply:EmitSound("buttons/button15.wav")

	elseif(!line) then

	ply.iin_tpprevious = ply:GetPos()
	ply:SetPos(ply:GetEyeTrace().HitPos)
	ply:EmitSound("buttons/button15.wav")

	else 
		iin.error(ply,'Ply not found.')
		return
	end
	iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' teleported ',id:IsPlayer() and id or ply,Color(255,255,255),'.')
end,'admins', true) 

iin.AddCommand('freeze',function(ply,args)
args=iin.ParseArgs(args)
local id = FindEntity(args[1])
local time = string.DateFormat(args[2] or "0") or false
if id:IsPlayer() then
	id:Lock()
	if time and time>0 then timer.Simple(time,function() id:UnLock() end)
	iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' freeze ',id,Color(255,255,255)," for "..string.NiceTime(time)..'.')
	return
	end
	iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' freeze ',id,Color(255,255,255),'.')
else
	iin.error(ply,'Ply not found.')
end 
end,'admins', true)

iin.AddCommand('unfreeze',function(ply,args)
local id = FindEntity(args)
if id:IsPlayer() then
	id:UnLock()
	iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' unfreeze ',id,Color(255,255,255),'.')
else
	iin.error(ply,'Ply not found.')
end 
end,'admins', true)


iin.AddCommand('crash',function(ply,args)
	local id = FindEntity(args)
	if id:IsPlayer() then
		id:SendLua([[::g:: goto g]])
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' crash ',id,Color(255,255,255),'.')
	else
		iin.error(ply,'Ply not found.')
	end 
end,'admins', true)

iin.AddCommand('kill',function(ply,args)
	local id = FindEntity(args)
	if id:IsPlayer() then
		id:Kill()
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' slay ',id,Color(255,255,255),'.')
	else
		iin.error(ply,'Ply not found.')
	end 
end,'admins', true)

iin.AddCommand('cleanup',function(ply,args)
	local id = FindEntity(args)
	if id:IsPlayer() then
		id:ConCommand("gmod_cleanup")
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' remove ',id,Color(255,255,255),' props.')
	else
		iin.error(ply,'Ply not found.')
	end 
end,'admins', true)

iin.AddCommand("restart",function(ply)
	for i=1,5 do 
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' restarted server.')
	end
	timer.Simple(5,function()
		RunConsoleCommand("_restart")
	end)
end,'admins', true)

iin.AddCommand("spawn",function(ply)
	if not ply.preventSpawn then
		ply:Spawn()
	end
end)

iin.AddCommand("votekick",function(ply,line,target,reason)
	
	target = easylua.FindEntity(target)
	
	if target:IsPlayer() then
		
		reason = reason or "Minge"
		
		GVote.Vote("Kick "..target:GetName().."? Reason: "..reason,"yes","no",function(p)
			if #p["yes"] > #p["no"] then target:Kick(reason) end
		end)
		
			
	end
	
end)

iin.AddCommand("weps",function(ply,line,target,bool)

	target = easylua.FindEntity(target)

	if target:IsPlayer() then
		target:SetCheater(tobool(bool))
	end
	
end,'admins')

iin.AddCommand('ragdoll',function(ply,args)
args=iin.ParseArgs(args)
local id = FindEntity(args[1])
local time = string.DateFormat(args[2] or "0") or false
if id:IsPlayer() then
	local v = id
	if !v:Alive() then return end
	if v:InVehicle() then v:ExitVehicle() end
	if !IsValid(v.ragdoll) then
		local ragdoll = ents.Create("prop_ragdoll")
		ragdoll.ragdolledPly = v
		ragdoll:SetPos(v:GetPos())
		local velocity = v:GetVelocity()
		ragdoll:SetAngles(v:GetAngles())
		ragdoll:SetModel(v:GetModel())
		ragdoll:Spawn()
		ragdoll:Activate()
		ragdoll:CPPISetOwner(ply)
		ragdoll:SetOwner(v)

		v.preventSpawn = true
		v:SetParent(ragdoll)
		for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			local phys_obj = ragdoll:GetPhysicsObjectNum(i)
			phys_obj:SetVelocity(velocity)
		end
		v:Spectate(OBS_MODE_CHASE)
		v:SpectateEntity(ragdoll)
		v:StripWeapons() 
		v.ragdoll = ragdoll
	end
	if time and time>0 then timer.Simple(time,function() 
		local v = id
		if IsValid(v.ragdoll) then
			v.preventSpawn = false
			v:SetParent()
			v:UnSpectate()
			local ragdoll = v.ragdoll
			v.ragdoll = nil
			ragdoll.ragdolledPly = nil

			local pos = ragdoll:GetPos()
			pos.z = pos.z + 10 
			v:Spawn()
			v:SetPos(pos)
			v:SetVelocity(ragdoll:GetVelocity())
			local yaw = ragdoll:GetAngles().yaw
			v:SetAngles(Angle(0,yaw,0))
			ragdoll:Remove()
		end
	end)
	iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' ragdolled ',id,Color(255,255,255)," for "..string.NiceTime(time)..'.')
	return
	end
	iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' ragdolled ',id,Color(255,255,255),'.')
else
	iin.error(ply,'Ply not found.')
end 
end,'admins', true)

iin.AddCommand('unragdoll',function(ply,args)
	local id = FindEntity(args)
	if id:IsPlayer() then
		local v = id
		if IsValid(v.ragdoll) then
			v.preventSpawn = false
			v:SetParent()
			v:UnSpectate()
			local ragdoll = v.ragdoll
			v.ragdoll = nil 
			ragdoll.ragdolledPly = nil

			local pos = ragdoll:GetPos()
			pos.z = pos.z + 10 
			v:Spawn()
			v:SetPos(pos)
			v:SetVelocity(ragdoll:GetVelocity())
			local yaw = ragdoll:GetAngles().yaw
			v:SetAngles(Angle(0,yaw,0))
			ragdoll:Remove()
		end		
		
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' unragdolled ',id,Color(255,255,255),'.')
	else
		iin.error(ply,'Ply not found.')
	end 
end,'admins', true)

hook.Add("PlayerDeathThink", "iinPreventSpawn", function(ply)
	if ply.preventSpawn then return false end
end)

hook.Add("PlayerSpawn", "iinPreventSpawn", function(ply)
	ply.preventSpawn = false
end)

iin.AddCommand('gag',function(ply,args)
	args = iin.ParseArgs(args)
	local id = FindEntity(args[1])
	local time = string.DateFormat(args[2] or "0")
	
	if id:IsPlayer() then
	
		id.gagged = true
	
		if time and time~=0 and time<60*60 then
		timer.Simple(time,function()
			id.gagged = false
		end)
	
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' gagged ',id,Color(255,255,255)," for "..string.NiceTime(time)..'.')

		else

			iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' gagged ',id,Color(255,255,255))

		end
	else

	iin.error(ply,'Player not found')

	end

end,'admins', true)

iin.AddCommand('ungag',function(ply,args)
	local id = FindEntity(args)
	if id:IsPlayer() then
		id.gagged = false
		
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),' ungagged ',id,Color(255,255,255),'.')
	else
		iin.error(ply,'Ply not found.')
	end 
end,'admins', true)

iin.AddCommand("mute", function(ply, args)
	args = iin.ParseArgs(args)
	local id = FindEntity(args[1])
	local time = string.DateFormat(args[2] or "0")

	if id:IsPlayer() then
		id.muted = true

		if time and time ~= 0 and time < 60*60 then
			timer.Simple(time, function()
				id.muted = false
			end)

			iin_Msg(nil, Color(255, 187, 0), " ● ", ply, Color(255, 255, 255), " muted ", id, Color(255, 255, 255), " for " .. string.NiceTime(time) .. ".")
		else
			iin_Msg(nil, Color(255, 187, 0), " ● ", ply, Color(255, 255, 255), " muted ", id, Color(255, 255, 255))
		end
	else
		iin.error(ply, "Player not found")
	end
end, "admins", true)

iin.AddCommand("unmute", function(ply, args)
	args = iin.ParseArgs(args)
	local id = FindEntity(args[1])
	local time = string.DateFormat(args[2] or "0")

	if id:IsPlayer() then
		id.muted = false
		iin_Msg(nil, Color(255, 187, 0), " ● ", ply, Color(255, 255, 255), " unmuted ", id, Color(255, 255, 255), ".")
	else
		iin.error(ply, "Player not found")
	end
end, "admins", true)

hook.Add("PlayerSay", "iinMute", function(ply)
	if ply.muted then return "" end
end)


local function gagHook( listener, talker )
	if talker.gagged then
		return false
	end
end
hook.Add( "PlayerCanHearPlayersVoice", "iinGag", gagHook )


local function cexec(ply,args)
	args = iin.ParseArgs(args)
	local id = FindEntity(args[1])
	local str = args[2] or ""
	if id && id:IsPlayer() then
		iin_Msg(nil,Color(255,187,0)," ● ",ply,Color(255,255,255),'@',id,Color(255,255,255),': '..str)
		id:ConCommand(str)
		return
	end
	iin.error(ply,'Ply not found [!console <Nick> <Command>]')
end

iin.AddCommand("cexxec",cexec,'devs', true) -- why do we have this?
iin.AddCommand("cexec",cexec,'devs', true)

iin.AddCommand("lua",function(ply) ply:SendLua[[ShowLuabox()]] end) -- Throws an error

--[==[ [0:1:22477976]Card STEAM_0:1:22477976 ran this script at 01/26/15 19:03:43 ]==] 
local function urlencode(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",
			function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str
end
	
iin.AddCommand("w",function(ply,line)

	--if ply~= me then return end
	print(urlencode(line))
	http.Fetch("http://api.wolframalpha.com/v2/query?input="..urlencode(line).."&appid=K677A9-RYWJPVUUJK",function(s)
		s = string.gsub(s, [[\:([%da-f][%da-f][%da-f][%da-f])]], function(code)
			return utf8.char(tonumber(code, 16))
		end)
		
		local found = false
		for i,k in string.gmatch( s,"<plaintext>(.-)</plaintext>") do 
			all:ChatPrint(i)
			found = true
		end
		
		if not found then

			for i,k in string.gmatch( s,"desc=%'(.-)%'") do 
				all:ChatPrint(i)
				found = true
			end
		
			if not found then
				
				for i,k in string.gmatch( s,"<tip text=%'(.-)%'") do 
					all:ChatPrint(i)
					found = true
				end
				
				if not found then 
						
						local mean = s:match("<didyoumeans count=%'(.-)%'>")
						if mean and tonumber(mean)>0 then	
							for i=1,mean do
								local strmean = s:match("<didyoumean score=.->(.-)</didyoumean>")
								all:ChatPrint("Did you mean: "..strmean)
							end
							--found = true
						end
						
						if not found then
						--	print(s)
							all:ChatPrint("Your search returns no results.")
						end
				end
			end
		end
		
	end)
	
end)


iin.AddCommand("timescale", function(ply, line)
	if line then
		local timescale = tonumber(line:match"^%s*(%S+)")

		if timescale then
			timescale = math.Clamp(timescale, 0.1, 10)

			iin.Msg(nil, Color(255,187,0), " ● ", ply, color_white, " set the timescale to ", Color(0, 230, 255), timescale)
			game.SetTimeScale(timescale)
			
			return
		end
	end

	iin.error(ply, "Enter time scale.")
end, "devs", true)


iin.AddCommand("src",function(ply,line)
	if line and #line > 0 then
		iin.Msg(nil, Color(255, 187, 0), " ● ", ply, color_white, "@", Color(207, 110, 90), "src", color_white, ": " .. line)
		RunString("print(GetFunctionSource(" .. line .. "))")
		return
	end

	iin.error(ply, " #arg == 0 ")
end,'devs',true)


end) -- end HOOK.ADD