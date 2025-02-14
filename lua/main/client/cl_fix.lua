CreateClientConVar("allowgoto", "1", true, true, "Allows players to do !goto to you")

local ScrColTab={
	["$pp_colour_addr"]=0,
	["$pp_colour_addg"]=0,
	["$pp_colour_addb"]=0,
	["$pp_colour_brightness"]=0,
	["$pp_colour_contrast"]=1,
	["$pp_colour_colour"]=1.2,
	["$pp_colour_mulr"]=0,
	["$pp_colour_mulg"]=0,
	["$pp_colour_mulb"]=0
}
hook.Add("RenderScreenspaceEffects","WeatherOverlay",function()
	DrawColorModify(ScrColTab)
end)

function FixGrass()

	timer.Simple(1,function()
		timer.Simple(4,function()RunConsoleCommand("stopsound")end)
	
		local grass=Material("DE_CBBLE/GRASSFLOOR01")
		--grass:SetString("$bumpmap","")
		grass:SetTexture("$basetexture",Material("nature/grassfloor002a"):GetTexture("$basetexture"))
		--grass:SetTexture("$basetexture",Material("nature/snowfloor001a"):GetTexture("$basetexture"))
		grass:SetVector("$color",Vector(1,1,1))
	end)
end

hook.Add( "OnEntityCreated", "LocalPlayerValidating", function (ent)

	if LocalPlayer():IsValid() then
		FixGrass()
		hook.Remove( "OnEntityCreated", "LocalPlayerValidating")
	end
end)

function fast_html(w,h)
	
	w,h = w or ScrW()*3/4, h or ScrH()*3/4 
	local panel = vgui.Create"DFrame"	
	local html = vgui.Create("DHTML",panel)
	panel:SetSize(w,h)
	panel:Center()
	html:SetSize(w,h-25)
	html:SetPos(0,25)
	panel:MakePopup()
	
	return html
	
end

_chatAddText = _chatAddText or chat.AddText
function chat.AddText(...)
	chat.PlaySound()
	return _chatAddText(...)
end

concommand.Add("vgui_cleanup", function()
	for k, v in pairs( vgui.GetWorldPanel():GetChildren() ) do
		if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then
			v:Remove()
		end
	end
end, nil, "Removes every panel that you have left over (like that errored DFrame filling up your screen)")

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

concommand.Add("fixchat",function()
	chatbox.chatgui:SetSize(ScrW()*1/2.5,ScrH()*1/2.5)
	chatbox.chatgui:SetPos(110,230)
end)


hook.Add("Think", "SF.console.command", function()
	if not SF then return end
	if not SF.Permissions then return end
	if not SF.Permissions.privileges then return end
	if not SF.Permissions.privileges["console.command"] then return end
	
	local P = {}
	P.id = "owneronly"
	P.name = "Console Commands"
	P.settingsoptions = {"Only You", "No one"}
	P.defaultsetting = 2

	P.checks = {
		function(instance, target, key)
			return LocalPlayer() == instance.player
		end,
		function() return false end
	}

	SF.Permissions.registerCustomProvider(P, {"console.command"}, true)

	hook.Remove("Think", "SF.console.command")
end)
