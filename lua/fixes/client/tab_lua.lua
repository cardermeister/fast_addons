local Tag="chatbox"
module(Tag,package.seeall)

if SERVER then AddCSLuaFile() return end

pcall(include, "autorun/translation.lua") local L = translation and translation.L or function(s) return s end

local find=string.find
local function CountChars(str,chr)
    local pos=1--pos=pos or 1
	local count=0
    while true do -- will terminate
		local foundat=find(str,chr,pos,true)
		if not foundat then
			return count
		end
		pos=foundat + 1
		count=count + 1 --return 1+CountChars(str,chr,foundat+1)
	end
end

local luatab_highperf=CreateClientConVar("luatab_highperf","0",true,false)
local luatab_highperf_perref=CreateClientConVar("luatab_highperf_perref","0",true,false)
local luatab_highperf_drawhud=CreateClientConVar("luatab_highperf_drawhud","1",true,false)
local nodrawing = false
local ttimeout = 0

local T="highperf"





local mat_Screen		= Material( "pp/fb" )

local mat_MotionBlur	= Material( "pp/motionblur" )
local render=render
local surface=surface
local tex_MotionBlur	= render.GetMoBlurTex0()



local updated

local function RenderScreenspaceEffects()
	if updated then return end
	render.UpdateScreenEffectTexture()
end


local RealTime=RealTime
local startt = RealTime()
local f=1
local function RenderScene()
	
	local now = FrameNumber()
	
	if ttimeout<now or nodrawing==false then
		nodrawing = false
		
			hook.Remove("RenderScene",T)
			hook.Remove("PostRender",T)
			hook.Remove( "RenderScreenspaceEffects", T)
			
		return
	end
	
	if not updated then return end
	local now = RealTime()
	
	if updated<now then
		if luatab_highperf_perref:GetBool()  then
			updated = false
			return
		else
			updated = now + 2
		end
	end
	
	f= (now-startt)*0.5
	f=f>1 and 1 or f<0 and 0 or f
	if f==0 then return end
	
	cam.Start2D()
		
		local sw,sh=ScrW(),ScrH()
		render.SetMaterial( mat_Screen )
		render.DrawScreenQuad()
		
		surface.SetDrawColor(Color(0, 0, 0, f*55))
		surface.DrawRect(0,0,sw,sh)
		if luatab_highperf_drawhud:GetBool() then
			hook.Run("HUDPaint",sw,sh)
		end
		
	cam.End2D()
	return true
end

local function PostRender()
	if updated then return end
	updated = RealTime()+math.Rand(0.9,1.5)
	
end







local function donodraw(hideit)
	if hideit then
		ttimeout = FrameNumber()+2
		if not nodrawing then
			hook.Add("RenderScene",T,RenderScene)
			hook.Add("PostRender",T,PostRender)
			hook.Add( "RenderScreenspaceEffects", T, RenderScreenspaceEffects)
			
			nodrawing = true
			updated = false
			startt = RealTime()
		end
	else
		hook.Remove("RenderScene",T)
		hook.Remove("PostRender",T)
		hook.Remove( "RenderScreenspaceEffects", T)
		nodrawing = false
	end
	
end

local OpenLoadMenu do
	local function del(place)
		return place..(#place>0 and '/' or "")
	end
	local icons = {
		lua = 'page_code',
		png = 'image',
		jpg = 'image',
		txt = 'page',
		vpk = 'database',
		db  = 'database_edit',
	}
	local Menu
	Menu = function(place,cb,x,y)
			
		local m = DermaMenu()
		
			local back = place:match("^(.+)[\\/].-$") or ""
			if back and place~=back then
				m:AddOption(L"BACK",function()
					timer.Simple(0,function()
						Menu(back,cb,x,y)
					end)
				end):SetImage'icon16/arrow_left.png'
			end

		
			local files,folders = file.Find(del(place)..'*','GAME')
			for k,v in next,folders do
				m:AddOption(v,function()
					timer.Simple(0,function()
						Menu(del(place)..v,cb,x,y)
					end)
				end)
			end
			for k,v in next,files do
				local o = m:AddOption(v:gsub("%.txt$",""),function()
					local fp = 	del(place)..v
					cb(fp)
				end)
				local ext = v:match(".+%.(.-)$")
				local t = icons[ext or ""] or 'page_white'
				o:SetImage('icon16/'..t..'.png')
			end
		m:Open()
		if x and y then
		--	m:SetPos(x,y)
		else
			x,y = m:GetPos()
		end
	end
	OpenLoadMenu = Menu
end

------------------------------------------------------
-- Lua Chat Tab
------------------------------------------------------
	local PANEL={}

	local id = 0 -- Running ID.
	local function saveBackup(path, code)
		file.Write(path, code)
		local p = util.RelativePathToFull('data/'..path)
		LocalPlayer():ChatPrint("Backed up to: "..p)
		SetClipboardText(p)
	end
	local canlua = false
	local chat_tab_lua_legacyluadev = CreateClientConVar("chat_tab_lua_legacyluadev","0",true)
	local luadev=setmetatable({},{__index=function(self,key)
		local luadev = _G.luadev
		if chat_tab_lua_legacyluadev:GetBool() then
			luadev=package.loaded.luadev or luadev
		end
		return luadev[key]
	end})
	local buttons= {
		"up",
		"",
		"",
		{L"Run",'icon16/cog_go.png',
			function(code)
				id = id + 1
				luadev.RunOnSelf(code)
			end
		},
		{L"Server",'icon16/server.png',
			function(code)
				id = id + 1
				luadev.RunOnServer(code)
			end
		},
		{L"Clients",'icon16/group.png',
			function(code)
				id = id + 1
				luadev.RunOnClients(code)
			end
		},
		{L"Shared",'icon16/world.png',
			function(code)
				id = id + 1
				luadev.RunOnShared(code)
			end
		},
		"",
		{L"Player",'icon16/user.png',
			function(code)
				id = id + 1
				local menu = DermaMenu()
				local plys = player.GetAll()
				table.sort(plys, function(a, b) return a:Name():lower() < b:Name():lower() end)
				for k, v in pairs(plys) do
					menu:AddOption(v:GetName(), function()
						luadev.RunOnClient(code, nil, v)
					end)
				end
				menu:Open()
			end
		},
		{L"Devs",'icon16/user_gray.png',
			function(code)
				luadev.Run(code, {ply = LocalPlayer(), id = LocalPlayer():SteamID()})
				
				for k, v in pairs(player.GetAll()) do
					if v:IsAdmin() and v ~= LocalPlayer() then
						luadev.RunOnClient(code, nil, v)
					end
				end
			end
		},
		"",
		{L"Javascript",'icon16/script_gear.png',
			function(code,editor)
				editor.code.HTML:Call(code)
			end
		},
		
		"left",
		"",
		--[[{L"Upload",'icon16/transmit.png',
			function(code)
				id = id + 1
				luadev.ShowUploadMenu(code)
			end
		},--]]
		{L"Save",'icon16/script_save.png',
			function(code,editor)
				local path = "lua_editor"
				file.CreateDir(path,'DATA')
				path=path..'/'..os.date'%Y_%m'
				file.CreateDir(path,'DATA')
				
				local filepath
				local menu = DermaMenu()
				menu:AddOption("Name", function()
					Derma_StringRequest("Backup", "Name your backup", "",
					function(str)
						filepath = path.."/"..str..".txt"
						saveBackup(filepath, code)
					end,
					function() end,
					"Confirm", "Cancel")
				end)
				menu:AddOption("No name", function()
					local ver = 0

					while not filepath or file.Exists(filepath,'DATA') and ver<9000 do
						ver= ver + 1
						filepath = path.."/backup"..(ver <= 9 and "0" or "")..""..ver..'.txt'
					end

					saveBackup(filepath, code)
				end)
				menu:Open()
			end
		},
		{L"Load",'icon16/script_edit.png',
			function(code,editor)
				OpenLoadMenu ("data/lua_editor",function(p)
					editor.code:SetCode(file.Read(p,'GAME') or "FAILED LOADING"..tostring(p))
				end)
			end
		},
		{L"Open",'icon16/folder_explore.png',
			function(code)
				id = id + 1
				local menu = DermaMenu()
				menu:AddOption("Local", function()
					filebrowser.ShowTree(false)
				end):SetIcon'icon16/folder_explore.png'
				menu:AddOption("Server", function()
					filebrowser.ShowTree(true)
				end):SetIcon'icon16/server.png'
				menu:Open()
			end
		},
		"",
		{L"pastebin",'icon16/page_link.png',
			function(code,editor)
				local t={
					api_dev_key='df9eb1e9d83f595d31a64e8d03a083ae',
					api_paste_code=code,
					api_option='paste',
					api_paste_format="lua",
					api_paste_private=0,
					api_paste_expire_date='1D',
				}
				local function doit()
					http.Post("http://pastebin.com/api/api_post.php",t,
					function(url,_,head,code)
						LocalPlayer():ChatPrint("Paste URL: "..url)
						SetClipboardText(url)
					end,
					function(err)
						LocalPlayer():ChatPrint("Pastebin err: "..err)
					end)
				end
				local m = DermaMenu()
				local lengths={
					{"Month","1M"},
					{"Week","1W"},
					{"Day","1D"},
					{"Hour","1H"},
					{"10 Minutes","10M"},
				}
				for k,v in next,lengths do
					m:AddOption(v[1],function()
						t.api_paste_expire_date=v[2]
						doit()
					end)
				end
				
				m:Open()
			end
		},
		{L"Send",'icon16/email_go.png',
			function(code)
				
				local menu = DermaMenu()
				local pl = player.GetHumans()
				table.sort(pl,function(a,b)
					if a:GetFriendStatus()~=b:GetFriendStatus() then
						return a:GetFriendStatus()=="friend"
					else
						return a:Name():lower()<b:Name():lower()
					end
				end)
				for k, v in pairs(pl) do
					local m = menu:AddOption(v:GetName(), function()
						net.Start("sendcode")
							net.WriteFloat(v:UserID())
							net.WriteString(code)
						net.SendToServer()
					end)
					if v:GetFriendStatus()=="friend" then
						m:SetImage('icon16/user_add.png')
					end
				end
				menu:Open()
			end
		},
		{L"Receive",'icon16/email_open.png',
			function(code,editor)
				
				local menu = DermaMenu()
								
				for uid, _ in next,sendcode_list or {} do
					local name = player.UserIDToName(uid)
					
					local m = menu:AddOption(name, function()
						net.Start("sendcode")
							net.WriteFloat(uid)
							net.WriteString("f")
						net.SendToServer()
					end)
				end
				menu:Open()
			end
		},
		"",
		{L"Beautify",'icon16/style.png',
			function(code,editor)
				if not util.BeautifyLua then return end
				
				local ok,code2 = pcall(util.BeautifyLua,code)
				editor.code:SetCode(tostring(code2))
			end
		},
	}
	function PANEL:Think()
		if luatab_highperf:GetBool() then donodraw(true) end

		if self.nextresize and self.nextresize<RealTime() then
			self.nextresize = false
			local x,y=self.code_imitator:GetPos()
			local w,h=self.code_imitator:GetSize()
			self.code:SetPos(x,y)
			self.code:SetSize(w,h)

		end
	end
	
	function PANEL:PerformLayout()
		if not self.nextresize then
			self.nextresize = RealTime()+0.2
		end
	end
	
	
	function PANEL:OnActivatedPanel(prev)
		
		canlua = GetConVar"sv_allowcslua":GetBool()
		--canserver = LocalPlayer():IsSuperAdmin()
		
		if IsValid(self.code.HTML) then
			self.code.HTML:RequestFocus()
		end
	end
	
	function PANEL:Init()
		self.filename = "chatbox_lua_save.txt"
		
		local code_imitator = vgui.Create("EditablePanel", self)
		code_imitator:Dock(FILL)
		self.code_imitator=code_imitator
		
		local code = vgui.Create("lua_editor", self)
			
		self.code = code
		
		function code.OnCodeChanged(code, msg)

			if not code:GetReady() then return end

			
			hook.Run("ChatTextChanged", msg, true)
		end
		function code.OnFocus(code,gained)
			if not gained then return end
			self.code.OnCodeChanged(self.code, self.code:GetCode())
		end
			

		-- buttons

		self.container_top_wrapper=vgui.Create('DPanel',self)
			self.container_top_wrapper:SetTall(24)
			self.container_top_wrapper:Dock(TOP)
		
		self.container_top=vgui.Create('DHorizontalScroller',self.container_top_wrapper)
			local container_top=self.container_top
			container_top:Dock(FILL)
		
		local buttons_container=vgui.Create('DPanel',self)
			self.buttons_container = buttons_container
			buttons_container:SetWide(75)
			buttons_container:Dock(LEFT)
			function buttons_container.AddPanel(self,pnl)
				pnl:SetParent(self)
				pnl:Dock(TOP)
			end
			
		local b = vgui.Create("DButton", container_top)
			b:SetText( L"Menu" )
			b:SetIcon("icon16/application_edit.png")
			b:SetDrawBorder(false)
			b:SetDrawBackground( false )
			
			b.DoClick = function()
				local m =DermaMenu()
				
				m:AddOption(L"Configure",function()
					self.code:ShowMenu()
				end)
				m:AddOption(L"Show Help",function()
					self.code:ShowBinds()
				end)
				
				do
					local m=m:AddSubMenu("Fix")
						m:AddOption(L"Reopen URL",function()
							self.code:LoadURL()
						end)
						m:AddOption(L"Reload",function()
							self.code:ReloadPage()
						end)
						m:AddOption(L"Reload (empty cache)",function()
							self.code:ReloadPage(true)
						end)
						
				end
				
				do
					local m=m:AddSubMenu("Mode")
					
					for _,name in pairs(self.code.Modes) do
						local txt= name:sub(1,1):upper()..name:sub(2):gsub("_"," ")
						m:AddOption(txt,function()
							self.code:SetMode(name)
						end)
					end
					
				end
				
				do
					local m=m:AddSubMenu("Theme")
					
					for _,name in pairs(self.code.Themes) do
						local txt= name:sub(1,1):upper()..name:sub(2):gsub("_"," ")
						local cb = function()
							self.code:SetTheme(name)
						end
						
						local a = m:AddOption(txt,cb)
						local a_OnMousePressed = a.OnMousePressed
						function a.OnMousePressed( a, mousecode )
							cb()
							return a_OnMousePressed(a,mousecode)
						end
							
					end
					
				end
				
				do
					local m=m:AddSubMenu("Font Size")
					
					for i=9,24 do
						local txt= i..' px'
						m:AddOption(txt,function()
							self.code:SetFontSize(i)
						end)
					end
					
				end
				
				m:AddCVar(L"Legacy LuaDev","chat_tab_lua_legacyluadev","1","0",function() end)
			
				m:AddCVar(L"Performance","luatab_highperf","1","0",function() end)

				m:Open()
			end
	
			container_top:AddPanel( b )
			


		--local b = vgui.Create("DLabel", buttons_container)
		--	b:SetText( "      "..(L"Run on") )
		--	b:SizeToContents()
		--	buttons_container:AddPanel( b )
		local container = buttons_container
		for _,data in pairs(buttons) do
			if isstring(data) then
			
				if data=="" then
					local b = vgui.Create("EditablePanel", container)
					b:SetSize(16,8)
					b.ApplySchemeSettings=function()end
					container:AddPanel( b )
				elseif data=="-" then
					DMenu.AddSpacer(buttons_container)
				elseif data=="up" then
					container = container_top
				elseif data=="left" then
					container = buttons_container
				else
					error"uh"
				end
				
				continue
				
			end
			
			local b = vgui.Create("DButton", container)

			b:SetText( data[1] )
			b:SetDrawBorder(false)
			b:SetDrawBackground( false )
			
			if data[2] then
				
				b:SetImage( data[2] )
				b.m_Image2=b.m_Image
				b.m_Image=nil
				b.m_Image2:SetPos( 1, (b:GetTall() - b.m_Image2:GetTall()) * 0.5 )
				b:SetTextInset( b.m_Image2:GetWide() + 4, 0 )
				b:SetContentAlignment(4)
			end
			
			local h=b:GetTall()
			b:SizeToContents()
			b:SetTall(h)
			b:SetWide( b:GetWide() + 8 )
			b.DoClick = function()
				data[3](self.code:GetCode(),self)
			end
			
			b.Paint=function(b,w,h)
				if b.Hovered then
					surface.SetDrawColor(30,30,30,30)
					surface.DrawRect(0,0,w,h)
				end
				derma.SkinHook( "Paint", "Button", b, w, h )
				return false
			end
			
			
			if data[2]=="icon16/cog_go.png" then
			
				b.Paint=function(b,w,h)
								
					derma.SkinHook( "Paint", "Button", b, w, h )

					if b.Hovered then
						surface.SetDrawColor(30,30,30,30)
						surface.DrawRect(0,0,w,h)
					else
						
						surface.SetDrawColor(canlua and 50 or 255,canlua and 255 or 50,20,100)
						surface.DrawRect(0,0,w,h)
						
					end
					
					return false
				end
			end

			container:AddPanel( b )
		end
		
		-- Y U NO WORK :(
		--buttons_container:InvalidateLayout(true)
		--buttons_container:SizeToChildren(true,true)
	end


vgui.Register( Tag..'_lua', PANEL, "EditablePanel" )