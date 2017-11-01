
local IHAVEIT = {}
local queue = {}
local busy = false
//local nowdownload

local function WSDownload(id,uid)

	steamworks.FileInfo( id, function( result )
		if not result.fileid then 
			queue = {}
			busy = false
			return
		end
		steamworks.Download( result.fileid, true, function( name )
			if not name then return end
			local t , tab = game.MountGMA( name )
			if t then
				IHAVEIT[id] = true
				if LocalPlayer():UniqueID()==uid then
					net.Start'workshop_model'
					net.WriteString(id)
					local mdltab = {}
					for i,k in pairs(tab) do
						if k:Right(4) == ".mdl" then
							table.insert(mdltab,k)
						end
					end
					net.WriteTable(mdltab)
					net.SendToServer()
				end	
				if table.Count(queue)>0 then
					local id = table.GetFirstKey( queue )
					print(id,"Downloading...",result.title)
					WSDownload(id,queue[id])
					queue[id] = nil
				else
					busy = false
					print"Queue ended."
				end
				surface.PlaySound("garrysmod/content_downloaded.wav")
				//chat.AddText(Color(255,255,0),"[WS_RealTime] ",Color(255,255,255),"Mounting id <",id,">",Color(0,195,255)," (Remaining: "..(6)..")")
			end
		end )
	end )	


end

net.Receive('workshop_model',function(len,ply)
	local id = net.ReadString()
	local uid = net.ReadString()
	
	
	if not id or id=="" then return end
	local ply = player.GetBySteamID( uid )
	if string.Right(id,4)==".mdl" and ply:IsPlayer() then ply:SetModel(id) return end
	
	if IHAVEIT[id] and LocalPlayer():UniqueID()~=uid then return end
	if busy then queue[id] = uid return end
	busy = id	
	
	WSDownload(id,uid)
	print(id,"Downloading...")
			
end) 

local wss = {
	
	{ x = ScrW()-10, y = 10 },
	{ x = ScrW()-10-20, y = 10+20 },
	{ x = ScrW()-10-20-400, y = 10+20 },
	{ x = ScrW()-10-400, y = 10 },

}

local stripes = surface.GetTextureID("vgui/alpha-back")
//local busy = "1231231"
//local queue = {["123123"]=123,["555555"]=10}
local t = 0

hook.Add( "HUDPaint", "Downloading_queue", function()

	if busy then
		local c = HSVToColor( 100+math.sin(CurTime()/3)*100,1,1 )
		//surface.SetDrawColor( c.r,c.g,c.b, 220 )
		surface.SetDrawColor( 10,10,10, 220 )
		draw.NoTexture()
		surface.DrawPoly( wss )
		
		surface.SetTexture(stripes)
		surface.SetDrawColor(200,50,255)
		surface.DrawTexturedRectUV(ScrW()-400-10-20,30,400-1,5,t+1,0,t,1)
		t=t+FrameTime()/5
		
		local Left = ""
		if table.Count(queue)>0 then
			busy = table.GetFirstKey( queue )
			Left = " Remaining: "..table.Count(queue)
		end
		draw.SimpleText("Realtime Workshop mounting content id: "..busy..Left,"Trebuchet18",ScrW()-400-10,20,c,0,1)
		

	end
end ) 