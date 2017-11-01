hook.Add('iin_Initialized','AddCLFuncs',function()


function iin.ShowPushImg(link,time)

	--local pnl= vgui.Create('DFrame')
	--pnl:SetTitle('PushedImg:')
	--pnl:SetPos(30,30)
	--pnl:SetSize(ScrW()/2-150,ScrH()/2-10)

	local ImgPanel = vgui.Create('DHTML')
	ImgPanel:SetPos(10,10)
	--ImgPanel:SetSize(pnl:GetWide(),pnl:GetTall()-25)
	ImgPanel:SetSize(ScrW()/2-150,ScrH()/2-10)

	ImgPanel:SetHTML([[
	<html><head><style type="text/css">body {
	margin: 0px;
	padding: 0px;
	border: 0px;
	#overflow: hidden;
	background-color: #000;
	-webkit-background-size: contain;
	background: url("]]..link..[[") no-repeat left top fixed;
	}</head><body></body></html>]])

	timer.Simple(time or 4,function() ImgPanel:Remove() end)

end


end) --end HOOK.ADD

-- SCOREBOARD =>
/*
local PANEL = vgui.Register("iin_scoreboard", {}, "DPanel")

function PANEL:Init()

self:SetSize(650,ScrH()/2*1.2)
self:Center()

self.list = self:Add("DPanelList")
self.list:SetSpacing(3)
self.list:Dock(FILL)
self.list:EnableVerticalScrollbar(true)

end --INIT

function PANEL:Think()
local PlyS = player.GetAll()
k = {}
for i,k in pairs(PlyS) do
	if !IsValid(k.ScoreLine) then
		k.ScoreLine = self:CreatePlayerLine(k)
		self.list:AddItem(k.ScoreLine)
	end
end

end


function PANEL:CreatePlayerLine(ply)


local Line = vgui.Create('DPanel')
Line:SetSize(640,40)
Line.Player = ply
--if !Line.Player then Line:Remove() end

local avatar = vgui.Create('DHTML',Line)
avatar:SetSize(32,32)

local commid = ply:SteamID64()
http.Fetch("http://steamcommunity.com/profiles/" .. commid .. "?xml=1", function(content)
local ret = content:match("<avatarIcon><!%[CDATA%[(.-)%]%]></avatarIcon>")
end)
avatar:SetHTML([[
<html><head><style type="text/css">body {
	margin: 0px;
	padding: 0px;
	border: 0px;
	#overflow: hidden;
	background-color: #000;
	-webkit-background-size: cover;
	background: url("http://media.steampowered.com/steamcommunity/public/images/avatars/93/9399fce55b8d0eb7b23ff411df7c408ba8ed9d33_full.jpg") no-repeat left top fixed;
	}</head><body></body></html>
]])
avatar:SetPos(4,4)
-- ]]..ret..[[
print(ret)
local AvaButton = vgui.Create('DButton',avatar)
AvaButton:SetSize(32,32)
AvaButton:SetText('')
AvaButton.Paint = function() end
AvaButton.DoClick = function()

local a=DermaMenu()
					
a:AddOption("Копировать SteamID",function() 
	SetClipboardText(ply:SteamID())
end)
a:AddOption("Копировать ник",function() 
	SetClipboardText(ply:Name())
end)
a:AddOption("Открыть профиль",function() 
	local url="http://steamcommunity.com/profiles/" .. ply:SteamID64()
	gui.OpenURL(url)
end)
a:AddOption("Копировать ссылку на профиль",function() 
	SetClipboardText("http://steamcommunity.com/profiles/"..ply:SteamID64())
end)


a:Open()


end

return Line
end



score = {}

function score.ScoreboardShow()

if not score.panel then 
score.panel = vgui.Create("iin_scoreboard")
return true
end

score.panel:SetVisible(true)


return true
end
hook.Add("ScoreboardShow", "scoreboard_ScoreboardShow", score.ScoreboardShow)

function score.ScoreboardHide()

score.panel:SetVisible(false)
gui.EnableScreenClicker(false)

return true
end
hook.Add("ScoreboardHide", "scoreboard_ScoreboardHide", score.ScoreboardHide)


function score.PlayerBindPress(ply, bind, pressed)
	if not score.panel then
		return
	end

	if score.panel:IsVisible() and pressed and bind == "+attack2" then
		gui.EnableScreenClicker(true)
		return true
	end
end
hook.Add("PlayerBindPress", "scoreboard_PlayerBindPress", score.PlayerBindPress)

-- FUCK THE SCOREBOARD ~ GOING SLEEP 