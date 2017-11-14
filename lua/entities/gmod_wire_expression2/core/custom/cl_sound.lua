-- made by [G-moder]FertNoN

local mr = math.Round
local net = net

CreateClientConVar( "wire_expression2_soundurl_enable", "1", true, false )  
CreateClientConVar( "wire_expression2_soundurl_maxPerSecond", "3", true, false )  
CreateClientConVar( "wire_expression2_soundurl_maxSoundCount", "5", true, false )  
CreateClientConVar( "wire_expression2_soundurl_block", "SteamID,", false, false ) 
local tempSound = 0
local E2SoundParToEnt=nil

local function ClearSoundURL(ent)
	for i,k in pairs(ent.E2PAudStreams) do
		if E2SoundParToEnt!=nil then E2SoundParToEnt[k]=nil end
		k:Stop()
		k = nil
	end
	ent.E2PAudStreams = {}
end 
 
concommand.Add( "wire_expression2_soundurl", function(ply,cmd,argm)
	if tonumber(argm[1]) == 0 then 
		RunConsoleCommand("wire_expression2_soundurl_enable","0")
		RunConsoleCommand("wire_expression2_soundurl_stopall")
	else
		RunConsoleCommand("wire_expression2_soundurl_enable","1")
	end
end )

concommand.Add( "wire_expression2_soundurl_stopall", function(ply,cmd,argm)
	timer.Destroy( "e2ParentSoundURL" ) E2SoundParToEnt = nil
	local expression2 = ents.FindByClass("gmod_wire_expression2")
	for k,v in pairs(expression2) do
		ClearSoundURL(v)
	end
end )

local function StartTimer()
	timer.Create("e2ParentSoundURL",0.1,0,function() 
		if table.Count(E2SoundParToEnt) == 0 then E2SoundParToEnt=nil timer.Destroy( "e2ParentSoundURL" ) return end 
		for k,v in pairs(E2SoundParToEnt) do
			if v:IsValid() then 
				k:SetPos(v:GetPos())
			end
		end
	end) 
end

local function SoundURL(msg)
	local ent =		msg:ReadEntity()
	local fft =		msg:ReadEntity()
	local ply =		msg:ReadEntity()
	local id = 		msg:ReadString()
	if id:len()==0 then id = msg:ReadLong() end
	local cmd = 	msg:ReadChar()
	
	local Block = GetConVarString("wire_expression2_soundurl_block") 
	if Block:len()>10 then 
		Block = string.Explode(',',Block) 
		for k=1,#Block do
			if ply:SteamID()==Block[k] then return end
		end
	end
		
	if cmd==1 then
		if  GetConVarNumber( "wire_expression2_soundurl_enable" )==0 then return end
		if tempSound>GetConVarNumber( "wire_expression2_soundurl_maxPerSecond" ) then return end
		tempSound=tempSound+1
		if tempSound==1 then timer.Simple( 1, function() tempSound=0 end) end
		
		local volume = 	msg:ReadChar()
		local url = 	msg:ReadString()
		local noplay = 	msg:ReadChar()
		local pos = 	msg:ReadVector()
		local tar = 	msg:ReadEntity()
		local param = "3d"

		if noplay!=0 then param = "3d noplay" end
		if pos==Vector(0,0,0) and tar==nil then param = " "
			if noplay!=0 then param = "noplay" end 
		end

		sound.PlayURL(url,param,function(AudStream) 
			if AudStream==nil then return end
			if ent==nil then AudStream:Stop() return end
			if not ent:IsValid() then AudStream:Stop() return end
			if ent.E2PAudStreams==nil then ent.E2PAudStreams={} end
			if ent.E2PAudStreams[id]!=nil then 
				if ent.E2PAudStreams[id]:IsValid() then ent.E2PAudStreams[id]:Stop() end end
			if table.Count(ent.E2PAudStreams)>GetConVarNumber("wire_expression2_soundurl_maxSoundCount")-2 then AudStream:Stop() return end
			if LocalPlayer()==fft then
				local index = ent:EntIndex()
				local tname = 'SoundFFT'..id..index
				timer.Create(tname,0.1,0,function()
					if !ent or !ent.E2PAudStreams or !ent.E2PAudStreams[id] then
						timer.Destroy(tname)
					else
						local tblfft = {}
						ent.E2PAudStreams[id]:FFT(tblfft,0)
						local count = #tblfft
						local str = ""
						for i=1,count do
							local roundd = mr(tblfft[i]*255)
							if i!=count then
								str = str..roundd..' '
							else
								str = str..roundd
							end
						end
						net.Start('FFTSendToServer')
						net.WriteTable({index,id,str})
						net.SendToServer()
					end
				end)
			end
			ent.E2PAudStreams[id]=AudStream
			AudStream=nil
			ent:CallOnRemove("ClearSoundURL", ClearSoundURL,ent)
			if tar!=nil then if tar:IsValid() then 	
				if E2SoundParToEnt==nil then StartTimer() E2SoundParToEnt={} end
				if E2SoundParToEnt[ent.E2PAudStreams[id]]==nil then E2SoundParToEnt[ent.E2PAudStreams[id]]={} end
				E2SoundParToEnt[ent.E2PAudStreams[id]]=tar
				pos = tar:GetPos()
			end end
			ent.E2PAudStreams[id]:SetPos(pos)
		end)
		return
	end
	
	if cmd==0 then
		if ent.E2PAudStreams!=nil then  
			ClearSoundURL(ent) return
		end
	end
	
	if ent.E2PAudStreams==nil then return end
	if ent.E2PAudStreams[id]==nil then return end
	if not ent.E2PAudStreams[id]:IsValid() then return end
	
	if cmd==2 then
		ent.E2PAudStreams[id]:Play() return
	end
	
	if cmd==3 then
		ent.E2PAudStreams[id]:Pause() return
	end
	
	if cmd==4 then
		ent.E2PAudStreams[id]:SetVolume(msg:ReadChar()/100) return
	end
	
	if cmd==5 then
		ent.E2PAudStreams[id]:SetPos(msg:ReadVector()) return
	end
	
	if cmd==6 then
		if E2SoundParToEnt!=nil then E2SoundParToEnt[ent.E2PAudStreams[id]]=nil end
		ent.E2PAudStreams[id]:Stop()
		ent.E2PAudStreams[id]=nil
		return
	end
	
	if cmd==7 then
		if E2SoundParToEnt==nil then StartTimer() E2SoundParToEnt={} end
		if E2SoundParToEnt[ent.E2PAudStreams[id]]==nil then E2SoundParToEnt[ent.E2PAudStreams[id]]={} end
		E2SoundParToEnt[ent.E2PAudStreams[id]] = msg:ReadEntity()
	end
end

usermessage.Hook("e2soundURL", SoundURL )