local Tag = 'scap'

local FindPlayer = easylua.FindEntity -- :/

local ands = function(a)
	local s=''
	for k,v in next,a do
		
		local n = tostring(v)
		
		if k==1 then s = n
		else         s = s..' and '..n
		end
		
	end 
	
	return s
end


local quota = setmetatable({}, {__mode = 'k'})
local quota_n = setmetatable({}, {__mode = 'k'})

if SERVER then
	util.AddNetworkString'scap'

	net.Receive('scap',function(_,p)
		local a,b,c=net.ReadTable(),net.ReadBit(),net.ReadUInt(32) local d=net.ReadData(c)
		if c~=0 then
			Msg'[SCAP] 'print(p,'->',ands(a))
			p:ChatPrint(Format('Sent to %s!',ands(a)))
			--p:UnlockAchievement('scap')
		end
		for k,v in next,a do
			if IsValid(v) then
				if quota[p] then 
					if (SysTime() - quota[p]) < 1 then 
						quota_n[p] = (quota_n[p] or 0) + 1
						
						if quota_n[p] > 5 then 
							p:Kick('SYN SOBAKI MENYA UBIVAYT BLYAT SHO TI NEVIDISH SHTOLE EBANIY VROT')
							return 
						end
					else
						quota_n[p] = 0
					end
				end
			
				net.Start'scap'
				net.WriteEntity(p)
				net.WriteBit(tobool(b))
				net.WriteUInt(c,32)
				net.WriteData(d,c)
				net.Send(v)
				
				quota[p] = SysTime()
			else
				print('SCAP',v,'not valid')
			end
		end
	end)



	return
end


local key = 'gm_showspare2'
local function translatekey(onlykey) -- hooolyyy jeeesuuus
	local a = input.LookupBinding(key)
	if a and onlykey then return key end
	if not a then
		a = input.LookupBinding'slot1'
	end
	if a and onlykey then return 'slot1' end
	if not a then
		if onlykey then return false end
		return 'type "scap view" in your console! (because your binds are wack)'
	end
	
	return Format('press the %s key to view',a)
end


local time = SysTime
-- put [SCAP] on these
local P = function(...) chat.AddText(Color(255,255,0,255),...) end
local PSS = prints or easylua.Print or print
local PS = print -- function(...) print(...) PSS(...) end
local PE = function(...) P(...) PSS(...) end

local function show(data,title,ply)
	
	PS(Format('[BASE64] Decoding... (%u)',string.len(data)))
	local cap = util.Base64Encode(data)
	data=nil -- does this even free memory -_-
	cap = cap:gsub('\n','')
	PS(Format('[BASE64] Done! (%u)',string.len(cap)))
	
	local f=vgui.Create'DFrame'
	f:SetTitle(Format('SCAP (%s)',title))
	f:SetPos(0,0)
	f:SetSize(64*3,64*3)
	
	f:SetVisible(true)
	f:MakePopup()
	f:SetKeyboardInputEnabled(false)
	f:SetMouseInputEnabled(true)
	
	f.OnClose = function(s,...)  end
	
	-- f.btnMinim:SetDisabled(false)
	-- f.btnMinim.DoClick = function(s) s:GetParent():SetMouseInputEnabled(false) end
	
	local aa = vgui.Create('DHTML',f)
	aa.Paint=function()end
	aa:SetPos(4,24)
	aa:SetSize(64,64)
	
	-- because why not
	aa:AddFunction('gmod','size',function(w,h) f:SetSize(math.Clamp(w+8,30,ScrW()),math.Clamp(h+24+4,30,ScrH())) aa:SetSize(math.Clamp(w,20,ScrW()),math.Clamp(h,20,ScrH())) f:Center() end)
	aa:SetHTML( "<body style=\"background-color:black;padding:0;margin:0;\"><img src=\"data:image/jpeg;base64,"..cap.."\" onload=\"gmod.size(this.width,this.height)\"></body>" )
	
	
	if IsValid(ply) then -- opened
		net.Start(Tag)
		net.WriteTable({ply})
		net.WriteBit(false)
		net.WriteUInt(0,32)
		net.WriteData('',0)
		net.SendToServer()
	end
	
	
end
local function sendto(data,who)
	if not data then PE'!!! no data???' return end
	if not who or (#who<1) then PE'!!! uuhh noone to send to???' return end -- really should assert
	
	local ll = string.len(data)
	local c = util.Compress(data)
	local cl = string.len(c)
	local cmp = false
	if cl<ll then data=c c=nil cmp=true end
	
	local len = string.len(data)
	net.Start(Tag)
	net.WriteTable(who)
	net.WriteBit(cmp)
	net.WriteUInt(len,32)
	net.WriteData(data,len)
	net.SendToServer()
	PS(Format('Sent to %s %u'..(cmp and '*' or '')..' (%0.2f)',ands(who),len,cmp and (cl/ll) or (ll/cl)))
	P(Format('Sending to %s...',ands(who)))
end

local function capture(x,y,w,h,q)
	x = math.Clamp(x,0,ScrW())
	y = math.Clamp(y,0,ScrH())
	w = math.Clamp(w,0,ScrW())
	h = math.Clamp(h,0,ScrH())
	return render.Capture({
		['format'] = 'jpeg',
		['quality'] = q or 50,
		['x'] = x,
		['y'] = y,
		['w'] = w,
		['h'] = h
	})
end

local autosend
local function done(x,y,xx,yy)
	if not x or not y or not xx or not yy then return end
	
	PS(x,y,xx,yy)
	
	local tx,ty = x,y
	local txx,tyy = xx,yy
	
	if tx>txx then local a=txx txx=tx tx=a end
	if ty>tyy then local a=tyy tyy=ty ty=a end
	
	local x,y,w,h = tx,ty,txx-tx+1,tyy-ty+1
	if w==1 and h==1 then return end
	
	
	
	local lt=time()
	local q = 80
	hook.Add("PostRender", tag, function()
		hook.Remove("PostRender", tag)
		local cap = capture(x,y,w,h,q)
		
		local okay=true
		while string.len(cap) > (2^16-1) do
			if (time()-lt)>1 then PE'TIME EXCEEDED UGH!!1 BAILING OUT!!1' okay=false break end
			q=q-10
			PS('trying lower res... ',q)
			cap = capture(x,y,w,h,q)
		end
		
		if not okay then PE(Format('NOT SENDING, TOO HUGE (%u)(%0.2fs)',string.len(cap),time()-lt)) cap=nil return end
		
		-- cap = base64.encode(cap) -- :( let the send-ee decode :(
		PS(Format('Captured! (%0.2fs)',time()-lt))
		print(x,y,w,h)
		
		if autosend and (#autosend>0) then
			sendto(cap,autosend) autosend=nil cap=nil
		else
			local frame = vgui.Create("SCAP_SendToFrame")
			local cap = cap -- uh, variable scope fix?

			function frame:OnPlayerSelected(ply)
				frame:Remove()
				sendto(cap, {ply}) -- TODO multiple - selection
			end
		end
		
		autosend=nil cap=nil
	end)
end

local wasdown
local x,y,xx,yy
local function cross(x,y)
	surface.SetDrawColor(Color(15,25,0,255))
	surface.DrawRect(x-3,0,3*2+1,ScrH()) -- wow that was hard
	surface.DrawRect(0,y-3,ScrW(),3*2+1)
end
local function paint()
	if input.IsMouseDown(MOUSE_RIGHT) then
		-- Right click finishes the selection
		timer.Simple(0.1,
			function()
				done(x,y,xx,yy)
			end
		)
		gui.EnableScreenClicker(false)
		hook.Remove('PostRenderVGUI', Tag)
		return
	end
	
	local isdown = input.IsMouseDown(MOUSE_LEFT)
	local mx,my = gui.MousePos()
	
	if not wasdown and isdown then wasdown=1 x,y,xx,yy=mx,my,nil,nil end -- set p1
	if wasdown and not isdown then wasdown=nil xx,yy=mx,my end -- set p2
	
	/* -- nah
	local pct = ((SysTime())%1)
	local sx = math.floor( pct *100)
	local sy = sx
	local clr = math.max(255*(1-(pct+0.5)),0)
	draw.SimpleText(Format('%0.1f',clr),'DermaLarge',ScrW()/2,20,Color(255,255,255,150),1,1)
	surface.SetDrawColor(Color(0,0,0,clr))
	surface.DrawRect(mx-sx,0,sx*2+1,ScrH()) -- wow that was hard
	surface.DrawRect(0,my-sy,ScrW(),sy*2+1)*/
	
	
	surface.SetFont(Tag.."Font")
	surface.SetTextColor(Color(255,255,255,100))
	local txt = 'Click and drag. Right click to finish.'
	local sx,sy = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW()/2-sx/2,sy)
	surface.DrawText(txt)
	
	
	if x and y then
		cross(x,y)
		
		cross(xx or mx,yy or my)
		local tx,ty = x,y
		local txx,tyy = xx or mx,yy or my
		
		if tx>txx then local a=txx txx=tx tx=a end
		if ty>tyy then local a=tyy tyy=ty ty=a end
		local w,h = txx-tx+1,tyy-ty+1
		surface.SetDrawColor(Color(255,255,0,20))
		surface.DrawRect(tx,ty,w,h)
		
		surface.SetFont(Tag.."Font")
		surface.SetTextColor(Color(0,0,0,255))
		
		local txt = Format('%s x %s',w,h)
		local sx,sy = surface.GetTextSize(txt)
		surface.SetTextPos(tx+w/2,ty+h/2)
		surface.DrawText(txt)
		
	end
end

local animationStart = -1
local waiting=false
local function cleanupread()
	hook.Remove('PlayerBindPress',Tag)
	animationStart = -1
	waiting=false
end

local queue = {}
local function view()
	local cur = queue[1]
	if not cur then cleanupread() return end
	
	local cap,who,ply = cur[1],cur[2],cur[3]
	show(cap,who,ply)
	table.remove(queue,1)
	
	if table.Count(queue)<=0 then cleanupread() return true end
	
	P(Format('%u unseen SCAPs! ( %s )',table.Count(queue),translatekey()))
	
	return true
end

local function bindhook(ply,bind,pressed)
	if not pressed or bind~=translatekey(true) then return end
	
	return view()
end

surface.CreateFont(Tag.."PopupFont", {
	font = "Tahoma",
	size = 90,
	weight = 1000,
})

surface.CreateFont(Tag.."SmallPopupFont", {
	font = "Tahoma",
	size = 25,
	weight = 1000,
})

surface.CreateFont(Tag.."Font", {
	font = "Tahoma",
	size = 40,
	weight = 1000,
})

local function SimpleTextShadow(a, b, x, y, c, ...)
	draw.SimpleText(a, b, x + 2, y + 2, color_black, ...)
	local w, h = draw.SimpleText(a, b, x, y, c, ...)
	return h, w
end

hook.Add("PostDrawHUD", Tag, function()
	if animationStart < 0 then return end

	local mx = Matrix()
	
	mx:Translate(Vector(
		ScrW()/2,
		0,
		0
	))

	local t = RealTime() - animationStart
	local s = t < math.pi/2 and math.sin(t) * 1.2 or 1.2 - .2 * math.min(1, (t - math.pi/2))
	mx:Scale(Vector(s, s, 1))
	
	cam.PushModelMatrix(mx)
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	
		local offy = 0
		offy = offy + SimpleTextShadow("NEW SCAP", Tag.."PopupFont", 0, 0, color_white, 1, 0)
		offy = offy + SimpleTextShadow(translatekey():upper(), Tag.."SmallPopupFont", 0, offy, color_white, 1, 0)
		
		render.PopFilterMag()
		render.PopFilterMin()
	cam.PopModelMatrix()
end)

net.Receive(Tag,function(lleennggtthh)
	local who = net.ReadEntity()
	local cmp = tobool(net.ReadBit())
	local len = net.ReadUInt(32)
	local cap = net.ReadData(len)
	
	if len==0 then -- opened
		local name = who and who.Name and who:Name() or tostring(who)
		P(Format('%s opened your SCAP!',name))
		return
	end
	
	
	local name = IsValid(who) and who:Name() or '???'
	PS(Format('Got %u%s from %s',string.len(cap),cmp and '*' or '',name))
	if cmp then cap = util.Decompress(cap) end
	
	table.insert(queue,{cap,name,who}) -- who for later, maybe like reply?
	P(Format('SCAP from %s! ( %s )',name,translatekey()))
	if not waiting then
		hook.Add('PlayerBindPress',Tag,bindhook)
		animationStart = RealTime()
		waiting=true
	end
end)

hook.Add("ChatCommand","scap",function(com,paramstr,msg)
	if com:lower()~="scap" then return end
	LocalPlayer():ConCommand("scap " .. (paramstr or "") .. "")
end)

concommand.Add('scap',function(_,_,args)
	
	if args[1]=='view' then view() return end
	
	
	local whos = {}
	local multi = (args[1] or ''):Split'+' -- !scap "Pugsworth+Michael+me"
	for k,v in next,multi do
		local a = string.Trim(v)
		if (not a or a=='') then continue end
		if (a:match'^#?me$') then table.insert(whos,LocalPlayer()) continue end
		local who = FindPlayer(a)
		if IsValid(who) and who:IsPlayer() then table.insert(whos,who) continue end
	end
	
	autosend = whos
	if (whos and (#whos>0)) then P(Format('Selected %s!',ands(whos))) end
	
	
	if args[2] and args[3] and args[4] and args[5] then
		done(tonumber(args[2]),tonumber(args[3]),tonumber(args[4]),tonumber(args[5]))
		return
	end
	
	
	
	P'Click and drag. Right click to finish.'
	gui.EnableScreenClicker(true)
	
	wasdown=nil
	x,y,xx,yy=nil,nil,nil,nil
	hook.Add('PostRenderVGUI',Tag,paint)
end)


list.Set("DesktopWindows", Tag, {
	title		= "Capture'n'Send",
	icon		= "icon64/tool.png",
	width		= 1,
	height		= 1,
	onewindow	= false,
	init		= function( icon, window )
		window:GetParent():Close()
		window:Remove()
		RunConsoleCommand("scap")
	end
})

do -- SCAP Send to Frame

	local PANEL = vgui.Register( "SCAP_SendToFrame", {}, "DFrame" )
	
	function PANEL:Init()
		self:SetSize(200, ScrH() * 0.5)
		self:Center()
		self:MakePopup()
		self:SetSizable(true)
		self:SetTitle("Send to...")
		
		self.scrolling = vgui.Create("DScrollPanel", self)
		self.scrolling:Dock(FILL)
		
		self.layout = vgui.Create("DIconLayout", self.scrolling)
		self.layout:Dock(FILL)
		self.layout:DockMargin(0, 0, 2, 0)
		self.layout:SetSpaceX(4)
		self.layout:SetSpaceY(4)
		
		local list = player.GetHumans()

		-- sort by name
		table.sort(list, function(a, b)
			return a:Name() < b:Name()
		end)

		-- sort by friendlist
		local priority = {
			["friend"] = 1,
			["requested"] = 2,
			["none"] = 3,
			["blocked"] = 4,
		}
		table.sort(list, function(a, b)
			return (priority[a:GetFriendStatus()] or 5) < (priority[b:GetFriendStatus()] or 5)
		end)

		for k, v in pairs(list) do
			local buttn = self.layout:Add("SCAP_PlayerButton")
			buttn.Frame = self
			buttn:SetPlayer(v)
			self:SetWidth(math.max(self:GetWide(), buttn:GetWide() + 32))
		end
	end

	function PANEL:OnPlayerSelected(ply)
		print(ply)
	end

end

do -- SCAP Player Button

	local PANEL = vgui.Register( "SCAP_PlayerButton", {}, "DButton" )
	
	function PANEL:Init()
		self:DockPadding(2, 2, 2, 2)
		self:SetText("")
		
		self.avatar = vgui.Create("AvatarImage", self)
		self.avatar:SetSize(32, 32)
		self.avatar:Dock(LEFT)
		self.avatar:SetMouseInputEnabled(false)
		
		self.label = vgui.Create("DLabel", self)
		self.label:SetColor(color_black)
		self.label:SizeToContents()
		self.label:Dock(LEFT)
		self.label:DockMargin(4, 0, 0, 0)
		
		self:SetHeight(36)
		self:SetWidth(2 + 32 + 4 + self.label:GetWide() + 6) --
	end
	
	function PANEL:SetPlayer(ply)
		self.Player = ply
		
		self.avatar:SetPlayer(ply, 32)
		self.label:SetText(ply:GetName())
		self.label:SizeToContents()
		self:SetWidth(2 + 32 + 4 + self.label:GetWide() + 6)
	end

	function PANEL:DoClick()
		self.Frame:OnPlayerSelected(self.Player)
	end
	
end