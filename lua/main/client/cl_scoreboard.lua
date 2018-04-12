local nTag = "iin_ScoreboardInfo"


if LocalPlayer():IsAdmin() then print(nTag) end

SCOREBOARD_INFO = SCOREBOARD_INFO or {}

net.Receive(nTag, function(len, ply)
               print("Got " .. nTag .." update!")
               for k,v in pairs(net:ReadTable()) do
                  SCOREBOARD_INFO[k] = v
               end
end)

hook.Add('iin_Initialized',"InitTab",function()

local SetClipboardText=function(txt)
        local _,count=txt:gsub("\n","\n")
        txt=txt..('_'):rep(count)
 
        local b=vgui.Create('DTextEntry',nil,'ClipboardCopyHelper')
                b:SetVisible(false)
                b:SetText(txt)
                b:SelectAllText()
                b:CutSelected()
                b:Remove()
end
 
 
local ApiURL = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=C9E4E47AB57681D140D9924A16196EC8&steamids="

local LoadingMat = url_tex.Image'http://www.iguides.ru/forum/imagehosting/2011/05/08/853174dc624e58f3bd.png'

 
local draw = draw
local surface = surface
local table = table
local team = team
local math = math
local Material = Material
local vgui = vgui
local player = player
local Color = Color
local http = http

local list ={
  banni = -1,
  players = 5,
  admins = 228,
  devs = 1337,
  owners = math.huge,
}

local function SortPlys(players_sort)
  table.sort(players_sort,function(a,b)
          if not a or not b then return false      end
          if not list[a:GetUserGroup()] or not list[b:GetUserGroup()] then return false end
          --if a:Team() == b:Team() then return #TIME# end
          return list[a:GetUserGroup()] > list[b:GetUserGroup()]              
  end)
end
 
surface.CreateFont('WireTab',
{      
        font = "Lucida Console",
        size = 53,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
 
})
 
surface.CreateFont('WireTabMain',
{
        font = "Lucida Console",
        size = 13,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
})
 
local Scoreboard

_G.ScoreboardKill = function ()
   if IsValid(Scoreboard) then
      Scoreboard:Remove()
      Scoreboard=nil
   end
end

function ScoreboardDraw()
	
	if IsValid(Scoreboard) then
		
		Scoreboard:Show()
		Scoreboard:MakePopup()
		Scoreboard:SetKeyboardInputEnabled( false )
			
	else

		Scoreboard = vgui.Create'DPanel'
		Scoreboard:MakePopup()
		Scoreboard:SetKeyboardInputEnabled( false )
		Scoreboard:SetSize(800,480+25)
		Scoreboard:Center()
		Scoreboard.last_upd = ""
		Scoreboard.Paint = function(s,w,h) end
		
		
		Scoreboard._Update = function(self)
		
			local get_sorted = player.GetAll()
			
			SortPlys(get_sorted)
		
			local temp_sorter = ""
				
			for i,k in pairs(get_sorted) do
				temp_sorter = temp_sorter..tostring(k:UniqueID())
			end
			
			if temp_sorter == self.last_upd then return end
			
			self.last_upd = ""
			
			if self.plys then
				self.plys:Clear()
					
				for i,k in pairs(get_sorted) do
						
					local s_fix = k:GetNWString("gsapi_fixtime")
					
					k.TimePlayed = (s_fix=="" and k:GetNWInt("gsapi_playtime")) or (s_fix~="" and s_fix) or -1
					MakePlayerLine(k)
					self.last_upd = self.last_upd..tostring(k:UniqueID())
								
				end
						
						//print("scoreboard resorted")
			end
				
		end
			
		concommand.Add("scoreboard_update",function() Scoreboard:_Update() end)
			
		local p = vgui.Create('DPanel',Scoreboard)
		p:SetSize(800,480)
		--p:Center()
		p:SetPos(0,25)
		p.Paint = function(self,w,h)

			draw.RoundedBox(0,0,100,w,h,Color(142,202,112))
				
			draw.RoundedBox(0,0,100,w,20,Color(114,143,83))
				
			surface.SetDrawColor(Color(114,143,83))
			surface.DrawOutlinedRect(0,100,w,h-100)
			
			draw.SimpleText(player.GetCount().." #username","WireTabMain",5     ,100+10 ,Color(255,255,255),0,1)
			draw.SimpleText("#gmod_timeplayed","WireTabMain",400-40,100+10        ,Color(255,255,255),0,1)
			draw.SimpleText("#killos","WireTabMain",800-200,100+10  ,Color(255,255,255),0,1)
			draw.SimpleText("#dezes","WireTabMain",800-120,100+10   ,Color(255,255,255),0,1)
			draw.SimpleText("#pingas","WireTabMain",800-60,100+10   ,Color(255,255,255),0,1)
	
		end                    
			
		local yos = p:Add('DHTML')
		yos:SetPos(800-200,-8   )
		yos:SetSize(200,116     )
		yos:SetHTML([[ <img src="http://195.2.252.214/images/yo_bg2.png" height=100/> ]])
		
			local rest = yos:Add('DButton')
			rest:SetSize(200,116)
			rest:SetText("")
			rest.Paint = function() end
			rest.DoRightClick = function()
				local menu = DermaMenu()
				menu:AddSubMenu( "Restart (no changelevel)"):AddOption("ARE YOU SERIOUSLY",function() LocalPlayer():ConCommand("iin restart") end)
				menu:Open()
			end
		
		local yos_bg = p:Add('DHTML')
		yos_bg:SetPos(800-316-10,480-316-5)
		yos_bg:SetSize(316+16,316+16)
		yos_bg:SetHTML([[ <img src="http://195.2.252.214/images/yo_bg.png" width=316/> ]])
		
		
		
		local plys = p:Add'DPanelList'
		plys:SetSize(800,480-(100+20))
		plys:SetPos(0,100+20+1)
		plys:SetSpacing(1)
		plys:EnableVerticalScrollbar( true )

		Scoreboard.plys = plys
		
				local mats = {
		
				owners          = Material'icon16/server_chart.png',
				admins          = Material'icon16/shield.png',
				devs            = Material'icon16/script.png',
				banni           = Material'icon16/cancel.png',
				players         = Material'icon16/user.png',
				time_played   = Material'icon16/time.png',
				e2power         = Material'icon16/cog.png',
				film            = Material'icon16/film.png',
				monitor_link  = Material'icon16/monitor_link.png',
				telephone_link  = Material'icon16/telephone_link.png',
		}
			
		function MakePlayerLine(ply)
			local change = true
			local line = vgui.Create'DCollapsibleCategory'
			line:SetLabel''
			line:SetExpanded(ply.Expanded or false)
			line:SetSize(800,20)
					
			line.OnToggle = function(self,status)
				ply.Expanded = status
			end
					
			line.DoRightClick = function() iin.OpenClientMenu(ply) end 
					
			line.Paint = function(self,w,h)
				self:Think()
				draw.RoundedBox(0,0,0,w,h,team.GetColor(ply:Team())--[[Color(146,174,0)]])    
						
								
				draw.SimpleText(ply:Nick(),"WireTabMain",20+4+1,10+1,Color(0,0,0),0,1)
				draw.SimpleText(ply:Nick(),"WireTabMain",20+4,10,Color(255,255,255),0,1) --nick
				
				draw.SimpleText(ply:Frags(),"WireTabMain",800-200+8+1,10+1,Color(0,0,0),0,1) --kills
				draw.SimpleText(ply:Frags(),"WireTabMain",800-200+8,10,Color(255,255,255),0,1) --kills
				
				draw.SimpleText(ply:Deaths(),"WireTabMain",800-120+8+1,10+1,Color(0,0,0),0,1) --deth
				draw.SimpleText(ply:Deaths(),"WireTabMain",800-120+8,10,Color(255,255,255),0,1) --deth
				
				draw.SimpleText(ply:Ping(),"WireTabMain",800-60+8+1,10+1,Color(0,0,0),0,1) --ping
				draw.SimpleText(ply:Ping(),"WireTabMain",800-60+8,10,Color(255,255,255),0,1) --ping
				
				local fixtime = ply:GetNWString("gsapi_fixtime")
	
				if type(ply.TimePlayed)=="number" and ply.TimePlayed>=0 then
				
						surface.SetDrawColor(255,255,255)      
						surface.SetMaterial(mats['time_played'])
						surface.DrawTexturedRect(400-18,2,16,16)
					
						local hours_ = math.Round(ply.TimePlayed/60)..' hours'
						draw.SimpleText(hours_,"WireTabMain",400+1,10+1,Color(0,0,0),0,1)
						draw.SimpleText(hours_,"WireTabMain",400,10,Color(255,255,255),0,1) 
						
				elseif fixtime~="" then
						
						surface.SetDrawColor(255,255,255)      
						surface.SetMaterial(mats['time_played'])
						surface.DrawTexturedRect(400-18,2,16,16)
						
						local hours_ = fixtime..' hours'
						draw.SimpleText(hours_,"WireTabMain",400+1,10+1,Color(0,0,0),0,1)
						draw.SimpleText(hours_,"WireTabMain",400,10,Color(255,255,255),0,1) 

				else
					
					draw.SimpleText("Private Profile","WireTabMain",400+1-25,10+1,Color(0,0,0),0,1)
					draw.SimpleText("Private Profile","WireTabMain",400-25,10,Color(255,255,255),0,1)

				end
						
			end
			
			local mat_tags = {}
			
			table.insert(mat_tags,mats[ply:GetUserGroup() or "players"])
			if ply:GetNWBool('E2PowerAccess') then table.insert(mat_tags,mats["e2power"]) end               
			if ply:GetNWBool('PlayXAcсess') then table.insert(mat_tags,mats["film"]) end
			if #ply:GetNWString('discordid')>0 then table.insert(mat_tags,mats["telephone_link"]) end 
			if ply:IsBot() then table.insert(mat_tags,mats["monitor_link"]) end 
			
				
			local Property = vgui.Create('DPanel')
			
			Property:SetPos(0,20)
			Property:SetSize(800,40)
			Property.Paint = function(self,w,h)
			draw.RoundedBox(0,0,0,800,1,Color(255,255,255))
			draw.SimpleText("Tags: ","WireTabMain",10,10+20,Color(255,255,255),0,1) --ping
			
			for id,mat in next,mat_tags do
				
				surface.SetDrawColor(255,255,255)      
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(35+id*18,2+20,16,16)
			
			end
		end
				
		local AdminButPanel = Property:Add'DPanelList'
		AdminButPanel:EnableHorizontal(true)
		AdminButPanel:SetSpacing(1)
		AdminButPanel:SetSize(200,40)
		AdminButPanel:SetPos(10,5)
		
		local function AddAdminButton(name,func)
			local aButton = vgui.Create'DButton'
			--aButton:SetSize(30,15)
			aButton:SetText(name)
			aButton:SetSize(#name*10,15)
			aButton.Paint = function(self,w,h)
				draw.RoundedBox(0,0,0,w,h,Color(255,255,255))
				surface.SetDrawColor(Color(114,143,83))
					surface.DrawOutlinedRect(0,0,w,h)
			end
			
			aButton.DoClick = func
			aButton.DoRightClick = func
		
			AdminButPanel:AddItem(aButton)
		end
				
		AddAdminButton("goto",function() RunConsoleCommand('iin','goto',ply:EntIndex() )end)
		AddAdminButton("tp",function() RunConsoleCommand('iin','tp',ply:EntIndex())end)
		AddAdminButton("Admin",function() iin.OpenClientMenu(ply) end)
                AddAdminButton("info", function() RunConsoleCommand('sbu', ply:SteamID()) end)
                
		local Mute = vgui.Create("DImageButton",Property)
		Mute:SetSize(32,32)
		Mute:SetPos(800-32-4,6)
		Mute:SetTooltip("Заглушить/Разглушить")
		if ply:IsMuted() then
			Mute:SetImage("icon32/muted.png")
		else
			Mute:SetImage("icon32/unmuted.png")
		end    
			
		Mute.DoClick = function()
			ply:SetMuted(!ply:IsMuted())
			if ply:IsMuted() then Mute:SetImage("icon32/muted.png") else Mute:SetImage("icon32/unmuted.png") end  
		end
					
				// PROPERTYS
		line.Contents = Property
		Property:SetParent( line )
		line:InvalidateLayout()
					
					
		line.OnCursorEntered = function() line.Target = true end
		line.OnCursorExited = function() line.Target = false end
			
		local ava = vgui.Create('AvatarImage',line)
		ava:SetPlayer(ply,16)
		ply.vgui_avatar = ava
		ava:SetSize(20,20)
		ava:SetPos(0,0)
		
		local avabox = vgui.Create('DButton',ava)
		avabox:SetSize(28,28)
		avabox:SetText('')
		avabox.Paint = function() end
		avabox.DoRightClick = function()
			local a=DermaMenu()
			
			a:AddOption("Копировать SteamID",function() SetClipboardText(ply:SteamID()) end):SetIcon'icon16/computer.png'
			a:AddOption("Копировать ник",function() SetClipboardText(ply:Name()) end):SetIcon'icon16/color_swatch.png'
			a:AddOption("Индекс Ентити",function() chat.AddText(Color(255,187,0),"● ",ply,Color(255,255,255),'\'s EntIndex = ',Color(191,255,255),ply:EntIndex()) end):SetIcon'icon16/bin_closed.png'
			a:AddOption("Открыть профиль",function() ply:ShowProfile() end):SetIcon'icon16/book_open.png'
			a:AddOption("Копировать ссылку на профиль",function() SetClipboardText("http://steamcommunity.com/profiles/"..ply:SteamID64()) end):SetIcon'icon16/book.png'
			a:AddOption("Копировать cid",function() SetClipboardText(ply:SteamID64()) end):SetIcon'icon16/computer.png'
				
			a:Open()
		end
		avabox.DoClick = function()
				ply:ShowProfile()
		end
		
		avabox.OnCursorEntered = function()    
			
			avabox.Target = true
			Scoreboard.Tar_Ava_Ply = ply
		
			if not ply.AvatarURL and not ply:IsBot() then
			
				print("Fetching",ply,"avatar...")
				
				
				http.Fetch(ApiURL..(util.SteamIDTo64(ply:SteamID())),function(s)
					
					//if not IsValid(ply) then return end
					
					local json = util.JSONToTable(s)
					if type(json) == 'table' then
						json = json.response.players[1].avatarfull
						if json then
								ply.AvatarURL = url_tex.Image(json)
						end
					end
				end)
			
			end
		
		
		end
		
		avabox.OnCursorExited = function(self)
			avabox.Target = false
			Scoreboard.Tar_Ava_Ply = false
		end
		////ITEMS
		/////ITEMS
		line.Think = function()
				if not ply or not IsValid(ply) then    
						line:Remove()
				end
		end                    
		
	 	
		
		plys:AddItem(line)
			end
			
	end --if Scoreboard    
end

hook.Add('HUDPaint',"Scoreboard_AvatarGUI",function()
	if Scoreboard and Scoreboard.Tar_Ava_Ply and Scoreboard.Tar_Ava_Ply:IsPlayer() then
		surface.SetMaterial(Scoreboard.Tar_Ava_Ply.AvatarURL or LoadingMat)
		surface.DrawTexturedRect(gui.MouseX()-200-16,gui.MouseY()-200,200,200) 
	end
end)


hook.Add("ScoreboardShow","TabScoreboardDraw",function()
	ScoreboardDraw()
	Scoreboard:_Update()
	return false
end)

hook.Add("ScoreboardHide","TabScoreboardRemove",function()
	if IsValid(Scoreboard) then Scoreboard:Hide() end
end)





end)



local function recursiveCollect(tbl, acc, prefix)
   prefix = prefix or ""
   acc = acc or ""
   for k,v in pairs(tbl) do
      if type(v) == "table" then
         acc = acc .. prefix .. tostring(k) .. "     =\r\n" .. recursiveCollect(v, nil, prefix .. ">> ")
      else
         acc = acc .. prefix .. tostring(k) .. "     =     " .. tostring(v) .. "\r\n"
      end
   end

   return acc
end

concommand.Add("sbu", function (_,_,args)
                  local steamid = args[1] or "BOT"
                  local data = SCOREBOARD_INFO[steamid] or false

                  if data then
                     local data_txt = string.rep("-", 90) .. "\r\n surveillance @ " .. steamid .. "\r\n" .. string.rep("-",  90) .. "\r\n"
                     data_txt = data_txt .. recursiveCollect(data)
                     Derma_Message(data_txt, "Служба Безпеки України :: :: " .. steamid, "Спасибо, товарищ лейтенант.")
                  end
end)
