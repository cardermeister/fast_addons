local mat=Material"models/debug/debugwhite"
local render=render
local banned = false
local Tag = 'banni'
local function isbanned(ply)
	return ply:IsUserGroup'banni' or false
end

hook.Add("PrePlayerDraw",Tag,function(pl)
	if isbanned(pl) then
		render.MaterialOverride(mat)
		render.ModelMaterialOverride(mat)
		render.SuppressEngineLighting(true)
		render.ResetModelLighting(55,0,0)
		banned = true
	end
end)

hook.Add("PostPlayerDraw",Tag,function(pl)
	if banned then
		render.MaterialOverride(0)
		render.ModelMaterialOverride(0)
		render.SuppressEngineLighting(false)
		banned = false
	end
end)