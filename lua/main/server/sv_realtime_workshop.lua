util.AddNetworkString'workshop_model'

local meta = FindMetaTable'Player'

MountedIDs = {}
local requested = {}
local mounters = {}

local function CLSetModel(ply,model)

	net.Start'workshop_model'
		net.WriteString(model)
		net.WriteString(ply:SteamID())
	net.Broadcast()

end

function meta:SetWSModel(id,num,force)
	
	if MountedIDs[id] and num and num>0 then self:SelectWSModel(id,num) return end
	//if MountedIDs[id] and not force then self:SelectWSModel(id,1) end
	
	net.Start'workshop_model'
		net.WriteString(id)
		net.WriteString(self:UniqueID())
		self.WantedModel = num or true
		requested[id] = true
	net.Broadcast()
	Msg"[WS_RealTime] "print(id,"start mounting.")
end

function meta:SelectWSModel(id,num)
	if MountedIDs[id] then
		local mdl = MountedIDs[id][num]
		if mdl then
			self:SetModel(mdl)
			--CLSetModel(self,mdl)
			Msg"[WS_RealTime] "print(id,self,"setted model.",mdl)
		else
			Msg"[WS_RealTime] "print(id,"model not found.")	
		end
	else
		Msg"[WS_RealTime] "print(id,"not found.")
	end
end

net.Receive('workshop_model',function(len,ply)

	local id = net.ReadString()
	
	if requested[id] then
		Msg"[WS_RealTime] "print(id,"succes mounted.")
		local idtab  = net.ReadTable()
		MountedIDs[id] = idtab
		requested[id] = nil
		if ply.WantedModel then
	
			local nubmerkek = 1
			if type(ply.WantedModel)=="number" then nubmerkek = ply.WantedModel end
			
			Msg"[WS_RealTime] "print(ply,"got new model. ",nubmerkek)
			
			ply:SetModel(idtab[nubmerkek])	
			--CLSetModel(ply,idtab[nubmerkek])
			mounters[ply:UniqueID()] = id
			ply.WantedModel = false
		end
	end
end)

hook.Add("PlayerDisconnected","WS_RealTime",function(ply)

	local userid = ply:UniqueID()
	local wsid = mounters[userid]
	
	if wsid then
		local found = false
		mounters[userid] = nil
		
		for uid,id in pairs(mounters) do
			if id == wsid then found = true break end
		end
		
		if not found then MountedIDs[wsid] = nil end
	end

end)

hook.Add("PlayerInitialSpawn","WS_RealTime",function(ply)
	timer.Simple(15,function()
		for id,mdl in pairs(MountedIDs) do
			net.Start'workshop_model'
				net.WriteString(id)
				net.WriteString("0")
			net.Send(ply)
		end
	end)
end)

concommand.Add("fetch_all_content",function(ply)
	if not ply.WSFetched then
		for i,id in pairs(workshop_content_list) do
			net.Start'workshop_model'
				net.WriteString(id)
				net.WriteString("content_fetching")
			net.Send(ply)
			ply.WSFetched = true
		end
	end
end)