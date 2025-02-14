local chathud_image_enable = CreateClientConVar("chathud_image_enable", "1")

hook.Add("Initialize", "chathud_image_html_override", function()

urlimg = {}

if _G.chathud_image_html and _G.chathud_image_html:IsValid() then
	_G.chathud_image_html:Remove()
end
	
_G.chathud_image_html = NULL
local chathud_image_sender = NULL



local function url_encode(str)
  if (str) then
	str = string.gsub (str, "\n", "\r\n")
	str = string.gsub (str, "([^%w %-%_%.%~])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
	str = string.gsub (str, " ", "+")
  end
  return str	
end



local urlRewriters =
{
	{ "^https?://imgur%.com/([a-zA-Z0-9_]+)$",      "http://i.imgur.com/%1.png" },
	{ "^https?://www%.imgur%.com/([a-zA-Z0-9_]+)$", "http://i.imgur.com/%1.png" },
	{ "^https?://www%.dropbox.com/([a-zA-Z0-9_]/[a-zA-Z0-9_]+/[^%s?]+)%??.*", "https://www.dropbox.com/%1" },
}

local allowed = {
	gif  = true,
	jpg  = true,
	jpeg = true,
	png  = true,
	svg  = true,
}

-- Image URL queue
local queue = {}

local function is_image_queued(url)
	for _, v in pairs(queue) do
		if v == url then return true end
	end
	return false
end

function urlimg.queue_image(url, clr, sendername)
	if not chathud_image_enable:GetBool() then return end
	if is_image_queued(url) then return end
	
	table.insert(queue, {url, clr, sendername})
end

local busy

local chathud_image_slideduration = CreateClientConVar("chathud_image_slideduration","0.5")
local chathud_image_holdduration  = CreateClientConVar("chathud_image_holdduration","5")


local function show_image(url, clr, sendername)
	busy = true
	if chathud_image_sender:IsValid() then
		chathud_image_sender:Remove()
	end
	
	chathud_image_sender = vgui.Create("RichText")
	chathud_image_sender:SetVisible(false)
	
	--chathud_image_sender:SetFontInternal("chathud_image")
	
	chathud_image_sender:InsertColorChange( clr.r, clr.g, clr.b, clr.a )
	chathud_image_sender:AppendText(sendername)
	chathud_image_sender:InsertColorChange( 255, 255, 255, 255 )
	chathud_image_sender:AppendText(": " .. url)
	
	chathud_image_sender:SetSize(1024, 30)
	chathud_image_sender:ParentToHUD()
	chathud_image_sender:SetVerticalScrollbarEnabled(false)
	
	function chathud_image_sender:PerformLayout()
		self:SetFontInternal("BudgetLabel")
	end
	
	if chathud_image_html:IsValid() then
		chathud_image_html:Remove()
	end
	
	chathud_image_html = vgui.Create("DHTML")
	chathud_image_html:SetVisible(false)
	chathud_image_html:SetSize(ScrW(), ScrH())
	chathud_image_html:ParentToHUD()
	chathud_image_html:SetHTML(
		[[
<!DOCTYPE html>
<html>
	<head>
		<style>
		body,html {
			padding: 0;
			margin: 0;
			overflow: hidden;
		}
		img {
			max-width: 100%;
			max-height: 30%;
		
		}
		</style>
	</head><body>
		<img id="img" />
	<script>
		var url = "]]..string.JavascriptSafe(url)..[[";
		document.getElementById("img").src = url;
	</script>
	</body>
</html>
		]]
	)
	
	-- Animation parameters
	local slideDuration = chathud_image_slideduration:GetFloat()
	local holdDuration  = chathud_image_holdduration:GetFloat()
	local totalDuration = slideDuration * 2 + holdDuration
	
	-- Returns a value from 0 to 1
	-- 0: Fully off-screen
	-- 1: Fully on-screen
	local function getPositionFraction(t)
		if t < slideDuration then
			-- Slide in
			local normalizedT = t / slideDuration
			return math.cos((1 - normalizedT) * math.pi / 4)
		elseif t < slideDuration + holdDuration then
			-- Hold
			return 1
		else
			-- Slide out
			local t = t - slideDuration - holdDuration
			local normalizedT = t / slideDuration
			return math.cos(normalizedT * math.pi / 4)
		end
	end
	
	local start = nil
	hook.Add("Think", "chathud_image_url", function()
		if not chathud_image_html:IsValid() or chathud_image_html:IsLoading() then return end
		
		if not chathud_image_html:IsVisible() then
			start = RealTime()
			chathud_image_html:SetVisible(true)
			chathud_image_sender:SetVisible(true)
		end
		
		local t = RealTime() - start
		if t > totalDuration then
			if chathud_image_sender:IsValid() then
				chathud_image_sender:Remove()
			end
			if chathud_image_html:IsValid() then
				chathud_image_html:Remove()
			end
			hook.Remove("Think", "chathud_image_url")
			table.remove(queue, 1)
			busy = false
			return
		end
		
		local posx = ScrW() * (getPositionFraction(t) - 1)
		chathud_image_html:SetPos(posx, 200)
		chathud_image_sender:SetPos(posx, 185)
	end)
end

timer.Create("chathud_image_url_queue", 0.25, 0, function()
	if busy then return end
	if queue[1] then
		local url, clr, sendername = queue[1][1], queue[1][2], queue[1][3]
		show_image(url, clr, sendername)
	end
end)

//local chathud_image_url = CreateClientConVar("chathud_image_url", "0")

//local bans = file.Read('chat_image_bans.txt',"DATA") or ""
//bans = string.Explode("\n",bans)
local t_bans = {}
//for k,v in pairs(bans) do
//	t_bans[v] = true
//end
t_bans["STEAM_0:1:123511712"] = true

function urlimg.get_image_link(text)
	if string.find(text, "http") then
		text = string.gsub(text, "https:", "http:")
		
		-- Look for URL
		text = text .. " "
		local url = string.match(text, "(http://.-)%s")
		if not url then return end
		
		-- Apply URL rewriting rules
		for _, rewriteRule in ipairs(urlRewriters) do
			url = string.gsub(url, rewriteRule[1], rewriteRule[2])
		end
		
		-- Determine URL extension
		local ext = string.match(url, ".+%.(.+)")
		if ext then ext = string.lower (ext) end

		if string.match(url, "[/w.]+dropbox.com") then -- (www.) or https?:(//)
			-- Support for Dropbox screenshots (dl=* should have been replaced by the rewriter by now)
			if not ext then return end
			if not allowed[ext] then return end
			return url .. "?dl=1"
		elseif string.match(url, "steamusercontent.com/ugc/") then
			-- Support for Steam Community screenshots (could probably have a better match but this works)
			return url
		else
			if not ext then return end
			if not allowed[ext] then return end
			
			return url
		end
	end
end

hook.Add("OnPlayerChat", "chathud_image_url", function(ply, str)
	if not IsValid(ply) or str=="" then return end
	
	//local chathud_image_url = chathud_image_url:GetInt()	
	//if chathud_image_url == 0 then return end
	//if chathud_image_url == 1 and ply.IsFriend and not ply:IsFriend(LocalPlayer()) and ply ~= LocalPlayer() then
	//	return
	//end
	if t_bans[ply:SteamID()] then return end
	
	if str == "sh" then
		if chathud_image_sender:IsValid() then
			chathud_image_sender:Remove()
		end
		if chathud_image_html:IsValid() then
			chathud_image_html:Remove()
		end
		busy = false
		hook.Remove("Think", "chathud_image_url")
		queue = {}
		
		return
	end
	
	local url = urlimg.get_image_link(str)

	if url then
		urlimg.queue_image(url, team.GetColor(ply:Team()), ply:Nick())
	end
end)


end)
