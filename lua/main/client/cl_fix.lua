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
		grass:SetString("$bumpmap","")
		--grass:SetTexture("$basetexture",Material("nature/grassfloor002a"):GetTexture("$basetexture"))
		grass:SetTexture("$basetexture",Material("nature/snowfloor001a"):GetTexture("$basetexture"))
		--grass:SetVector("$color",Vector(1))
		grass:SetVector("$color",Vector(.5,.5,.5))
	end)
end

hook.Add( "OnEntityCreated", "LocalPlayerValidating", function (ent)

	if LocalPlayer():IsValid() then
		FixGrass()
		hook.Remove( "OnEntityCreated", "LocalPlayerValidating")
	end
end)


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