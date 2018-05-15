local function DermaStringReq(title,help,callback)
	
	local Pnl = vgui.Create('DFrame')
	Pnl:SetTitle(title)
	Pnl:SetSize(300,25*3)
	Pnl:Center()
	Pnl:MakePopup()
	Pnl.Paint = function(self,w,h)
		draw.RoundedBox( 0,0,0,w,h, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0,0, w,25, Color( 25, 25, 25, 150 ) )
	end
	
	local entry = Pnl:Add('DTextEntry')
	entry:SetPos(0,25)
	entry:SetSize(Pnl:GetWide(),25)	
	entry:SetAllowNonAsciiCharacters(true)
	
	local Btn = Pnl:Add('DButton')
	Btn:SetSize(100,25)
	Btn:SetPos(0,50)
	Btn:CenterHorizontal()
	Btn:SetText'OKAY - > LET\'S GO'
	Btn.Paint = function(self,w,h)
		draw.RoundedBox( 0,0,0,w,h, Color( 25, 25, 25, 150 ) )
	end
	
	Btn.DoClick = function()
		callback('"'..entry:GetValue()..'"')
	end
end

function iin.OpenClientMenu(k)
	local Menu=DermaMenu()
	Menu:AddOption("Телепортироваться",function() LocalPlayer():ConCommand("iin goto ".."\""..k:SteamID().."\"") end):SetIcon'icon16/car.png'
	if LocalPlayer():IsAdmin() then
--	if (--[[(LocalPlayer():GetUserGroup()~=k:GetUserGroup()) and ]]LocalPlayer():CheckGroupPower(k:GetUserGroup())) --[[and k~=LocalPlayer()]] then
	--Menu:AddOption("Телепортироваться",function() LocalPlayer():ConCommand("iin goto ".."\""..k:SteamID().."\"") end):SetIcon'icon16/car.png'
	Menu:AddOption("Телепортировать",function() LocalPlayer():ConCommand("iin tp ".."\""..k:SteamID().."\"") end):SetIcon'icon16/arrow_right.png'
	Menu:AddSpacer( )
	
	Menu:AddOption("Кикнуть",function() DermaStringReq("Причина","",function(text) LocalPlayer():ConCommand("iin kick ".."\""..k:SteamID().."\"".." '"..text.."'") end) end):SetIcon'icon16/eye.png'
	local Ban = Menu:AddSubMenu("Забанить на")
	Ban:AddOption("Навсегда",function() DermaStringReq("Причина","",function(text) LocalPlayer():ConCommand("iin ban ".."\""..k:SteamID().."\"".." '"..text.."' 0") end) end):SetIcon'icon16/lock.png'
	Ban:AddOption("5 мин",function() DermaStringReq("Причина","",function(text) LocalPlayer():ConCommand("iin ban ".."\""..k:SteamID().."\"".." '"..text.."' 5m") end) end):SetIcon'icon16/lock.png'
	Ban:AddOption("15 мин",function() DermaStringReq("Причина","",function(text) LocalPlayer():ConCommand("iin ban ".."\""..k:SteamID().."\"".." '"..text.."' 15m") end) end):SetIcon'icon16/lock.png'
	Ban:AddOption("30 мин",function() DermaStringReq("Причина","",function(text) LocalPlayer():ConCommand("iin ban ".."\""..k:SteamID().."\"".." '"..text.."' 30m") end) end):SetIcon'icon16/lock.png'
	Ban:AddOption("1 час",function() DermaStringReq("Причина","",function(text) LocalPlayer():ConCommand("iin ban ".."\""..k:SteamID().."\"".." '"..text.."' 1h") end) end):SetIcon'icon16/lock.png'
	Ban:AddOption("2 часа",function() DermaStringReq("Причина","",function(text) LocalPlayer():ConCommand("iin ban ".."\""..k:SteamID().."\"".." '"..text.."' 2h") end) end):SetIcon'icon16/lock.png'
	Ban:AddOption("1 день",function() DermaStringReq("Причина","",function(text) LocalPlayer():ConCommand("iin ban ".."\""..k:SteamID().."\"".." '"..text.."' 1d") end) end):SetIcon'icon16/lock.png'
	
	local Banni = Menu:AddSubMenu("Банни на")
	Banni:AddOption("Навсегда",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"") end):SetIcon'icon16/lock.png'
	Banni:AddOption("15 сек",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"".." 15s") end):SetIcon'icon16/lock.png'
	Banni:AddOption("30 сек",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"".." 30s") end):SetIcon'icon16/lock.png'
	Banni:AddOption("1 мин",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"".." 1m") end):SetIcon'icon16/lock.png'
	Banni:AddOption("2 мин",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"".." 2m") end):SetIcon'icon16/lock.png'
	Banni:AddOption("5 мин",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"".." 5m") end):SetIcon'icon16/lock.png'
	Banni:AddOption("10 мин",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"".." 10m") end):SetIcon'icon16/lock.png'
	Banni:AddOption("30 мин",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"".." 30m") end):SetIcon'icon16/lock.png'
	Banni:AddOption("60 мин",function() LocalPlayer():ConCommand("iin banni ".."\""..k:SteamID().."\"".." 60m") end):SetIcon'icon16/lock.png'
	Menu:AddOption("АнБанни",function() LocalPlayer():ConCommand("iin unbanni ".."\""..k:SteamID().."\"") end):SetIcon'icon16/lock_open.png'
	
	Menu:AddSpacer( )
	
	local Freeze = Menu:AddSubMenu("Заморозить на")
	Freeze:AddOption("Навсегда",function() LocalPlayer():ConCommand("iin freeze ".."\""..k:SteamID().."\"") end):SetIcon'icon16/weather_lightning.png'
	Freeze:AddOption("15 сек",function() LocalPlayer():ConCommand("iin freeze ".."\""..k:SteamID().."\"".." 15s") end):SetIcon'icon16/weather_clouds.png'
	Freeze:AddOption("30 сек",function() LocalPlayer():ConCommand("iin freeze ".."\""..k:SteamID().."\"".." 30s") end):SetIcon'icon16/weather_cloudy.png'
	Freeze:AddOption("1 мин",function() LocalPlayer():ConCommand("iin freeze ".."\""..k:SteamID().."\"".." 1m") end):SetIcon'icon16/weather_sun.png'
	Freeze:AddOption("2 мин",function() LocalPlayer():ConCommand("iin freeze ".."\""..k:SteamID().."\"".." 2m") end):SetIcon'icon16/weather_rain.png'
	Freeze:AddOption("5 мин",function() LocalPlayer():ConCommand("iin freeze ".."\""..k:SteamID().."\"".." 5m") end):SetIcon'icon16/weather_cloudy.png'
	Freeze:AddOption("10 мин",function() LocalPlayer():ConCommand("iin freeze ".."\""..k:SteamID().."\"".." 10m") end):SetIcon'icon16/weather_clouds.png'
	Freeze:AddOption("30 мин",function() LocalPlayer():ConCommand("iin freeze ".."\""..k:SteamID().."\"".." 30m") end):SetIcon'icon16/weather_rain.png'
	Menu:AddOption("Разморозить",function() LocalPlayer():ConCommand("iin unfreeze ".."\""..k:SteamID().."\"") end):SetIcon'icon16/water.png'
	
	Menu:AddSpacer( )
	
	local Hp = Menu:AddSubMenu("Жизни")
	Hp:AddOption("0",function() LocalPlayer():ConCommand("iin hp ".."\""..k:SteamID().."\"".." 0") end):SetIcon'icon16/add.png'
	Hp:AddOption("1",function() LocalPlayer():ConCommand("iin hp ".."\""..k:SteamID().."\"".." 1") end):SetIcon'icon16/add.png'
	Hp:AddOption("100",function() LocalPlayer():ConCommand("iin hp ".."\""..k:SteamID().."\"".." 100") end):SetIcon'icon16/add.png'
	Hp:AddOption("228",function() LocalPlayer():ConCommand("iin hp ".."\""..k:SteamID().."\"".." 228") end):SetIcon'icon16/add.png'
	Hp:AddOption("666",function() LocalPlayer():ConCommand("iin hp ".."\""..k:SteamID().."\"".." 666") end):SetIcon'icon16/add.png'
	Hp:AddOption("1337",function() LocalPlayer():ConCommand("iin hp ".."\""..k:SteamID().."\"".." 1337") end):SetIcon'icon16/add.png'
	Hp:AddOption("Много",function() LocalPlayer():ConCommand("iin hp ".."\""..k:SteamID().."\"".." 999999999") end):SetIcon'icon16/add.png'
	
	Menu:AddSpacer( )
	
	Menu:AddOption("Включить бессмертие",function() LocalPlayer():ConCommand("iin god ".."\""..k:SteamID().."\"") end):SetIcon'icon16/emoticon_waii.png'
	Menu:AddOption("Выключить бессмертие",function() LocalPlayer():ConCommand("iin ungod ".."\""..k:SteamID().."\"") end):SetIcon'icon16/emoticon_unhappy.png'
	
	Menu:AddSpacer( )
	
	
	Menu:AddOption("Крашнуть",function() LocalPlayer():ConCommand("iin crash ".."\""..k:SteamID().."\"") end):SetIcon'icon16/shading.png'
	Menu:AddOption("Убить",function() LocalPlayer():ConCommand("iin kill ".."\""..k:SteamID().."\"") end):SetIcon'icon16/user_female.png'
	Menu:AddOption("Удалить пропы",function() LocalPlayer():ConCommand("FPP_Cleanup "..k:UserID()) end):SetIcon'icon16/shape_group.png'
	Menu:AddOption("Консоль",function() DermaStringReq("Комманда","",function(text) LocalPlayer():ConCommand("iin cexxec ".."\""..k:SteamID().."\"".." '"..text.."'") end) end):SetIcon'icon16/application_osx_terminal.png'
	
	Menu:AddSpacer()
	
	local Gag = Menu:AddSubMenu("Заглушить на")
	Gag:AddOption("Навсегда",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"") end):SetIcon'icon16/sound_mute.png'
	Gag:AddOption("15 сек",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"".." 15s") end):SetIcon'icon16/sound_mute.png'
	Gag:AddOption("30 сек",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"".." 30s") end):SetIcon'icon16/sound_mute.png'
	Gag:AddOption("1 мин",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"".." 1m") end):SetIcon'icon16/sound_mute.png'
	Gag:AddOption("2 мин",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"".." 2m") end):SetIcon'icon16/sound_mute.png'
	Gag:AddOption("5 мин",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"".." 5m") end):SetIcon'icon16/sound_mute.png'
	Gag:AddOption("10 мин",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"".." 10m") end):SetIcon'icon16/sound_mute.png'
	Gag:AddOption("30 мин",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"".." 30m") end):SetIcon'icon16/sound_mute.png'
	Gag:AddOption("60 мин",function() LocalPlayer():ConCommand("iin gag ".."\""..k:SteamID().."\"".." 60m") end):SetIcon'icon16/sound_mute.png'
	Menu:AddOption("Разглушить",function() LocalPlayer():ConCommand("iin ungag ".."\""..k:SteamID().."\"") end):SetIcon'icon16/sound.png'
	
	Menu:AddSpacer()
	
	local Ragdoll = Menu:AddSubMenu("Зарэгдолить на")
	Ragdoll:AddOption("Навсегда",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"") end):SetIcon'icon16/joystick_add.png'
	Ragdoll:AddOption("15 сек",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"".." 15s") end):SetIcon'icon16/joystick_add.png'
	Ragdoll:AddOption("30 сек",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"".." 30s") end):SetIcon'icon16/joystick_add.png'
	Ragdoll:AddOption("1 мин",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"".." 1m") end):SetIcon'icon16/joystick_add.png'
	Ragdoll:AddOption("2 мин",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"".." 2m") end):SetIcon'icon16/joystick_add.png'
	Ragdoll:AddOption("5 мин",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"".." 5m") end):SetIcon'icon16/joystick_add.png'
	Ragdoll:AddOption("10 мин",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"".." 10m") end):SetIcon'icon16/joystick_add.png'
	Ragdoll:AddOption("30 мин",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"".." 30m") end):SetIcon'icon16/joystick_add.png'
	Ragdoll:AddOption("60 мин",function() LocalPlayer():ConCommand("iin ragdoll ".."\""..k:SteamID().."\"".." 60m") end):SetIcon'icon16/joystick_add.png'
	Menu:AddOption("Разрэгдоллить",function() LocalPlayer():ConCommand("iin unragdoll ".."\""..k:SteamID().."\"") end):SetIcon'icon16/joystick.png'
	end --isadmin
	Menu:Open()
--	end
	
end
