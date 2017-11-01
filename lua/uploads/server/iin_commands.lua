local plys_wsm = {}
local f_slova = 
{
	zp = "869012672"
}

local function ws_model( ply, args )
	if !ply:IsSuperAdmin() then ply:ChatAddText(color_white, "ты не достоин") return end
	args =  iin.ParseArgs(args)
	
	local id_model = f_slova[args[1]] and f_slova[args[1]] or args[1]
	local number = args[2] and tonumber( args[2] ) or nil
	
	ply:SetWSModel( id_model, number )
	
	plys_wsm[ply:SteamID()] = {
		id_model = id_model,
		number = number
	}
	
	return false
end

local function remove_ws_model( ply )
	if !ply:IsSuperAdmin() then ply:ChatAddText(color_white, "ты не достоин") return end
	local pos = ply:GetPos()
	
	plys_wsm[ply:SteamID()] = nil
	
	ply:Spawn()
	ply:SetPos(pos)
	
	return false
end

iin.AddCommand("rwsmodel",remove_ws_model,nil,true)
iin.AddCommand("wsmodel",ws_model,nil,true)

local function do_wsmodel(ply)
	local info = plys_wsm[ply:SteamID()] or nil
	
	if info then
		timer.Simple(0.1, function()
			ply:SetWSModel( info.id_model, info.number )
		end)
	end
end

hook.Add('PlayerSpawn', 'WSM_plys_spawn', do_wsmodel)