setfenv(1, _G)

local META = FindMetaTable("Player")

if CLIENT then
	local font_name = "NameTags"
	local font_scale = 0.1
	local surface = surface
	
	surface.CreateFont(
		font_name, 
		{
			font 		= "Tahoma",
			size 		= 500,
			weight 		= 800,
			antialias 	= true,
			additive 	= true,
		} 
	)

	local font_name_blur = font_name.."_blur"

	local afk_phrases = {
		"Пьет чаек",
		"Заглянул в сон",
		"Отошел",
		"Зева-а-а-ет",
		"Zzz",
		"Сладкий сон",
	}

	surface.CreateFont(
		font_name_blur, 
		{
			font 		= "Tahoma",
			size 		= 500,
			weight 		= 800,
			antialias 	= true,
			additive 	= false,
			blursize 	= 10,
		} 
	)

	net.Receive("CustomTitle", function() 
		local data = net.ReadTable()

		local ply = data.ply or NULL
		local title = data.title

		if ply:IsValid() then
			ply.CustomTitle = title

			if ply == LocalPlayer() then
				file.Write("custom_title.txt", title)
			end
		end
	end)

	hook.Add("PopulateToolMenu", "NameTags", function()
		spawnmenu.AddToolMenuOption("Options", "Player", "Custom Title", "Custom Title", "", "", function(panel)
			local entry = panel:TextEntry("Статус")
			entry:SetTall(150)
			entry:SetMultiline(true)
			entry:SetEditable(true)
			entry:SetAllowNonAsciiCharacters(true)

			local button = panel:Button("Set Title")
			button:SetText("Сменить статус")
			button.DoClick = function()
				net.Start("CustomTitle")
					net.WriteString(entry:GetValue())
				net.SendToServer()
			end
			entry.OnEnter = button.DoClick
		end)
	end)

	local inited=false
	local function Init()
		if inited then return end
		inited=true

		local title = file.Read("custom_title.txt","DATA")

		net.Start("CustomTitle")
			net.WriteString(title or "")
		net.SendToServer()

	end

	hook.Add("InitPostEntity", "NameTags", Init)
	if LocalPlayer():IsValid() then Init() end

	local angles = Angle(0,0,90)	
	local cl_shownametags = CreateClientConVar("cl_shownametags", "1", true)	

	local offset = 20
	local eyepos = Vector()
	local eyeang = Vector()

	hook.Add("RenderScene", "NameTags", function(pos, ang) eyepos = pos eyeang = ang end)

	local function get_head_pos(ent)
		local pos, ang
		local bone = ent:LookupBone("ValveBiped.Bip01_Head1")

		if bone then 
			pos, ang = ent:GetBonePosition(bone)
		else
			pos, ang = ent:EyePos(), ent:EyeAngles()
		end

		pos = pos + Vector(0,0,1) * offset

		return pos, ang
	end

	local function draw_text(text, color, x, y)		
		surface.SetFont(font_name_blur)
		surface.SetTextColor(color_black)

		for i=1, 5 do
			surface.SetTextPos(x,y)
			surface.DrawText(text)
		end

		surface.SetFont(font_name)
		surface.SetTextColor(color)
		surface.SetTextPos(x,y)
		surface.DrawText(text)
	end

	local spacing = 1.5
	local white = Color(255, 255, 255, 255)
	local function draw_nametag(ply, alpha)		
		surface.SetFont(font_name)
		local time = RealTime()

		angles.y = eyeang.y - 90

		local ent = ply.GetRagdollEntity and IsValid(ply:GetRagdollEntity()) and ply:GetRagdollEntity() or ply
		local head_pos, head_ang = get_head_pos(ent)

		local scale = ply:GetModelScale()
		local h_offset = 0

		local text = ply:Name()
		local w, h = surface.GetTextSize(text)	
		text = text:gsub("%^%d", "") --- !?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?!?
		local size = 0.3 * scale * font_scale
		local c = team.GetColor(ply:Team())
		cam.Start3D2D(head_pos, angles, size)
			draw_text(text, c, -(w/2), 0)
		cam.End3D2D()
		h_offset = h_offset + (h * spacing)

		local title = ply.CustomTitle
		if title then
			local w, h = surface.GetTextSize(title)
			cam.Start3D2D(head_pos, angles, 0.2 * scale * font_scale)	
				draw_text(title, white, -(w/2), h_offset)
			cam.End3D2D()
			h_offset = h_offset + (h * spacing)
		end

		if META.IsAFK and ply:IsAFK() then			
			local s = afk_phrases[math.floor((CurTime()/4 + ply:EntIndex())%#afk_phrases) + 1]
			local ts = os.date("%M:%S",ply:AFKTime())
			
			local w, h = surface.GetTextSize(s)
			local tsw, tsh = surface.GetTextSize(ts)

			cam.Start3D2D(head_pos, angles, 0.3 * scale * font_scale)
				draw_text(ts, Color(102, 204, 102), -(tsw/2), -spacing * tsh / spacing - 110)
				draw_text(s..("."):rep(math.Round(math.abs(math.sin(CurTime()*1.2)*3))), Color(102, 102, 204), -(w/2), -spacing * h / spacing)
			cam.End3D2D()
		end
	end

	local drawables=setmetatable({},{__mode='k'})
	hook.Add("PostDrawTranslucentRenderables", "NameTags", function()
		if not cl_shownametags:GetBool() then return end

		for key, ply in pairs(player.GetAll()) do
			if not drawables[ply] then continue end 
			drawables[ ply ] = false
			ply.nametag_pixvis = ply.nametag_pixvis or util.GetPixelVisibleHandle()
			if util.PixelVisible(ply:EyePos(), 32, ply.nametag_pixvis) > 0 then
				draw_nametag(ply)
			end
		end		
	end)

	--THIS IS HERE FOR PLAYER TELEPORTING SINCE THE PREVIOUS POSITION IS WHERE THEY LEFT IF THEY LEFT YOUR PVS
	hook.Add("PostPlayerDraw", "NameTags", function(pl)
		drawables[pl] = true
	end)

else -- server

	util.AddNetworkString("CustomTitle")

	local function send(ply, target)
		net.Start("CustomTitle")
		net.WriteTable({title = ply.CustomTitle, ply = ply})

		if target then
			net.Send(target)
		else
			net.Broadcast()
		end
	end

	function META:SetCustomTitle(title)
		self.CustomTitle = title or ""
		send(self)
	end

	local init={}
	net.Receive("CustomTitle", function(len, ply)
		local title = net.ReadString()

		if not init[ply] then
			init[ply] = true
			for k, v in ipairs(player.GetAll()) do
				if v.CustomTitle and v ~= ply then
					send(v, ply)
				end
			end
			if #title == 0 then
				return
			end
		end
 
		ply:SetCustomTitle(string.Left(title, 256))
	end)
	
end
