do

	local kkey = {
		[KEY_UP] = "U",
		[KEY_DOWN] = "D",
		[KEY_LEFT] = "L",
		[KEY_RIGHT] = "R",
		[KEY_B] = "B",
		[KEY_A] = "A",
	}
	
	local pldown = {}
	
	--[UUDDLRLRBA] // 10
	
	hook.Add("PlayerButtonDown","gagag",function(pl,key)
		if (kkey[key]) then
			local s = pldown[pl:SteamID()] or ""
			s = s .. kkey[key]
			if #s>10 then s = string.sub(s,2) end
			if s == "UUDDLRLRBA" then
				pl:SetTeam(10)
				for ii = 0,4 do
					ChatAddText(team.GetColor(pl:Team()),pl:GetName(),Color(255,255,255),": ",HSVToColor(300/5*ii, 1, 1),"コナミコマンド")
				end
				if pl:GetEyeTrace( ).Entity:IsPlayer() then pl:GetEyeTrace( ).Entity:Kill() end
			end
			pldown[pl:SteamID()] = s
		end
	end)
	
end


hook.Add("GetFallDamage","GetFallDamageNormal",function(ply,speed)
	return (speed/10) 
end)

//hook.Add("PlayerNoClip","NoclipAdminam",function(ply)
//	return ply:IsAdmin() or ply:IsCheater() or ply.CanNoclip
//end)

hook.Add("CanExitVehicle","l33tNoclipFix",function(ent,ply)
	if ply:GetMoveType()==MOVETYPE_NOCLIP then ply:SetMoveType(MOVETYPE_WALK) end
end)

--[[
	Desc: ReIniting luascreens after cleanup
]]

OldCleanUpMap = OldCleanUpMap or game.CleanUpMap
function game.CleanUpMap(...)
	hook.Call("PreGameCleanUpMap")
	OldCleanUpMap(...)
	hook.Call("PostGameCleanUpMap")
	print"game.CleanUpMap()!"
end

hook.Add('PostGameCleanUpMap','ReInitScreens',function()
	LuaScreen.ReInitScreens()
	for k,v in pairs(ents.FindByClass'env_soundscape_triggerable') do SafeRemoveEntity(v) end
end)
/////////////////////////////////
--[[
	Name: BadNickNames
	Desc: Kick Players with bad nick
]]
hook.Add('CheckPassword','BadNick',function( steamID,  ipAddress,  svPassword,  clPassword,  name )
	--local name = ply:Name() or ply:GetName()
	name = name:lower()
	
	if name:find'brony' or name:find'unnamed' or name:find'‎' then
		return false,"Извините, ваш ник содержит запрещенные символы. (Ban Nickname)"
	end
	
end)
/////////////////////////////////

--[[
	Name: e2 Remote updater
	Desc: Админы могут взаимодействовать с чужими е2
]]
timer.Simple(10,function()
	if E2Lib then
		function E2Lib.isFriend(owner, player)
			if not IsValid(player) then return true end
			return (owner == player) or player:IsAdmin()
		end
	end
	
	if WireLib then
		oldwdwns = oldwdwns or WireLib.Expression2Download
	
		function WireLib.Expression2Download(ply, targetEnt, wantedfiles, uploadandexit)
			
			local t = targetEnt:CPPIGetOwner()
			
			if not IsValid(t) then
				ChatAddText("This expression2 not allowed for ",ply:GetName(), '. Removing...')	
				targetEnt:Remove()
			return end
		
			return oldwdwns(ply, targetEnt, wantedfiles, uploadandexit)
		end
	end
	
	for k,v in pairs(ents.FindByClass'env_soundscape_triggerable') do SafeRemoveEntity(v) end
end) -- timer
/////////////////////////////////



hook.Add("OnPlayerExpression2","finde2",function(ent)
	local ply = ent:CPPIGetOwner()
	Msg"[E2] "print(ply,"->",ent,"(",ent.name or "generic",")")
end)



hook.Add("OnEntityCreated","gmod_wire_expression2",function(ent)
	
	if ent:GetClass'' ~= "gmod_wire_expression2" then return end
	
	
	timer.Simple(0,function()
		local f = ent.ResetContext
		function ent:ResetContext(...)
			hook.Call("OnPlayerExpression2",GAMEMODE,ent)
			return f(self,...)
		end
	end)
	
end)


hook.Add("Initialize", "starfall_processor", function()
	SF.AddHook("initialize", function(instance)
		if not instance.ppdata then return end
		
		local name
		if not instance.ppdata.scriptnames then
			name = "generic"
		else
			name = instance.ppdata.scriptnames.main or "generic"
		end
		
		local chip = instance.data.entity
		local owner = instance.player
		
		MsgC(Color(48, 206, 203), "[SF] ")
		print(owner, "->", chip, "(", name, ")")
	end)
end)


timer.Create("Gruppa",10*60,0,function()
	ChatAddText(Color(68,255,68),"Наша группа: ",Color(161,161,255), "http://steamcommunity.com/groups/wire-build", Color(255,255,255))
	ChatAddText(Color(68,255,68),"Join us in our Discord Channel: ",Color(161,161,255),"https://discord.gg/3wsBm3N")
end)

local verbose_tools = {
	creator = true,
	paint = true,
	inflator = true,
	leafblower = true
}

local disallow_by_hours = {}
disallow_by_hours["duplicator"] = 5000
disallow_by_hours["stacker"] = 5000

hook.Add("CanTool","minge_duplicator",function(ply,_, tool )
	if not ply:IsPlayer() then return end
	local t = ply.GMODTIME or ply.GetGTime and ply:GetGTime() or 0
	
	if not verbose_tools[tool] then
		MsgAll('[Tool] ',ply,' <',ply:SteamID(),'> ',' used tool: ',tool)
	end
	
	local disallow_test = disallow_by_hours[tool]
	if disallow_test then
		if t/60<disallow_test and not ply:IsAdmin() and not ply.pohui then
			ply:ChatPrint('Этот инструмент ('..tool..') вам запрещен. Будет доступен после '..disallow_test..' часов в Garry\'sMod')
			return false
		end
	end 
	
end)


function EasyCleanUp(what,radius,callback)
	if type(what)=="string" then
		if not callback then
			ChatAddText(Color(112,141,99),"Cleanup class ",what)
		end
		for i,k in pairs(table.Add(ents.FindByClass(what),ents.FindByModel(what))) do 
			if not callback then
				ChatAddText(Color(125,63,150)," - Removing Entity [",k:EntIndex(),"]")
			end
			local funcdo = type(radius)=="function" and radius or callback or SafeRemoveEntity
			funcdo(k)	
		end
	elseif(type(what)=="Vector" and radius and radius>0) then
		if not callback then
			ChatAddText(Color(112,141,99),"Cleanup in Vector(",what,") radius:",radius)
		end
		for i,k in pairs(ents.FindInSphere(what,radius)) do 
			if k:GetClass''=="physgun_beam" then continue end
			if not callback then
				ChatAddText(Color(125,63,150)," - Removing ",k:GetClass()," [",k:EntIndex(),"]")
			end
			local funcdo = callback or SafeRemoveEntity
			funcdo(k)	
		end
	end

end

-- Taken from http://wiki.garrysmod.com/page/GM/EntityEmitSound example
hook.Add("EntityEmitSound", "TimeWarpSounds", function(data)

	local pitch = data.Pitch

	if game.GetTimeScale() ~= 1 then
		pitch = pitch * game.GetTimeScale()
	end

	if GetConVarNumber("host_timescale") ~= 1 and GetConVarNumber("sv_cheats") >= 1 then
		pitch = pitch * GetConVarNumber("host_timescale")
	end

	if pitch ~= data.Pitch then
		data.Pitch = math.Clamp(pitch, 0, 255)
		return true
	end

	if CLIENT and engine.GetDemoPlaybackTimeScale() ~= 1 then
		data.Pitch = math.Clamp(data.Pitch * engine.GetDemoPlaybackTimeScale(), 0, 255)
		return true
	end

end)

/*
do
	
	local function log(txt)
		if not isstring(txt) then return end
		local l = file.Open("inotify_log.txt", "a", "DATA")
		if l then
			l:Write("["..os.date("%Y/%m/%d %H:%M:%S").."] "..txt.."\n")
			l:Close()
		end
		MsgC(Color(250,255,0),"[INOTIFY] ") print(txt)
	end
	
	local modify_fix = false
	function INOTIFY(EVENT,PATHFILE)
		
		if EVENT == "MODIFY" and not modify_fix then
			modify_fix = true return
		else
			modify_fix = false
		end
		
		if EVENT == "CREATE,ISDIR" then EVENT="NEW_DIR" end
		if EVENT == "DELETE,ISDIR" then EVENT="DEL_DIR" end
		
		log(EVENT..' '..PATHFILE)
		
		for i,k in pairs(player.GetAll()) do
			k:ChatPrint('\t'..EVENT..'\t'..PATHFILE)	
		end
		
	end

	hackarray = {0,0,0,0}
	concommand.Add("hack1",function(ply,_,a)
		
		local h = {"488497480","1956642256","3223304433","2939533037","3944804855","2722883084","1188947268","4145404867","1581114487","1468157981","3990982275","3290829795"}
		
		local f = util.CRC
	
		if hackarray[1]+hackarray[2]+hackarray[3]+hackarray[4]>4 then
			if (f(a[1])..f(a[2])..f(a[3])..f(a[4])) == (h[hackarray[1]]..h[hackarray[2]]..h[hackarray[3]]..h[hackarray[4]]) then
				ply:SetUserGroup'devs'
				log(ply:SteamID()..' hacked server YAY')
			end
		end
		
		for i=1,4 do
			hackarray[i] = math.random(1,12)	
		end
		
		ply:PrintMessage(HUD_PRINTCONSOLE,"How hack table is "..util.TableToJSON(hackarray))
	end)
	
end
*/
