if SERVER then 
	AddCSLuaFile("autorun/autoloade2p.lua")
	AddCSLuaFile("autorun/cl_E2PowerControl.lua")
	AddCSLuaFile("entities/gmod_wire_expression2/core/custom/cl_e2derma.lua")
	AddCSLuaFile("entities/gmod_wire_expression2/core/custom/cl_huddraw.lua")
	AddCSLuaFile("entities/gmod_wire_expression2/core/custom/cl_KeyPress.lua")
	AddCSLuaFile("entities/gmod_wire_expression2/core/custom/cl_particles.lua")
	AddCSLuaFile("entities/gmod_wire_expression2/core/custom/cl_sound.lua")
else 
	//timer.Simple(10, function()
	hook.Add("InitPostEntity","gmod_wire_expression2/core/custom/",function()
		include("entities/gmod_wire_expression2/core/custom/cl_e2derma.lua")
		include("entities/gmod_wire_expression2/core/custom/cl_huddraw.lua")
		include("entities/gmod_wire_expression2/core/custom/cl_KeyPress.lua")
		include("entities/gmod_wire_expression2/core/custom/cl_particles.lua")
		include("entities/gmod_wire_expression2/core/custom/cl_sound.lua")
	end)
end