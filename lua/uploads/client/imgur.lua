local Tag = 'imgur'

local time = SysTime
-- put [IMGUR] on these
local P = function(...) chat.AddText(Color(255,255,0,255),...) end
local PSS = prints or easylua.Print or print
local PS = print -- function(...) print(...) PSS(...) end
local PE = function(...) P(...) PSS(...) end

local nodrawing = false

local mat_Screen		= Material( "pp/fb" )
local mat_MotionBlur	= Material( "pp/motionblur" )
local tex_MotionBlur	= render.GetMoBlurTex0()

local RealTime=RealTime
local startt = RealTime()
local f=1

local function RenderScene()
	
	local now = FrameNumber()
	
	f= (now-startt)*0.5
	f=f>1 and 1 or f<0 and 0 or f
	if f==0 then return end
	
	cam.Start2D()
		
		local sw,sh=ScrW(),ScrH()
		render.SetMaterial( mat_Screen )
		render.DrawScreenQuad()
		
		surface.SetDrawColor(Color(0, 0, 0, f*55))
		surface.DrawRect(0,0,sw,sh)
		--hook.Run("HUDPaint",sw,sh)
		
	cam.End2D()
	return true
end

local function donodraw(hideit)
	if hideit then
		if not nodrawing then
			timer.Simple(0.1, function()
				render.UpdateScreenEffectTexture()
				hook.Add("RenderScene",Tag,RenderScene)
				nodrawing = true
				startt = RealTime()
			end)
		end
	else
		hook.Remove("RenderScene",Tag)
		nodrawing = false
	end
end

local function onFailure(error)
	PE("Imgur upload failed: "..tostring(error))
end

local function onSuccess(code, body, headers)
	if code~=200 then
		onFailure("error code: "..code)
		print(body)
		return
	end
		
	local Begin = string.find(body, "http:")
	if not Begin then
		PE("Imgur upload failed2: "..tostring(code))
		print(body)
	else
		local End = string.find(body, ".jpg", Begin)
		if not End then
			PE("Imgur upload failed3: "..tostring(code))
			print(body)
			return
		end
		local URL = string.sub(body, Begin, End+3)
		local IMG = string.gsub(URL, "\\", "")
		P("Uploaded: "..tostring(IMG))
		SetClipboardText(IMG)
		print(body)
	end
end

local function sendToImgur(data)
	
	local capture = util.Base64Encode( data )

	local Parameters = {
		image = capture,
		type = "base64",
		name = tostring(os.time()),
		title = LocalPlayer():Nick().." - "..LocalPlayer():SteamID(),
		description = LocalPlayer():Nick().." ("..LocalPlayer():SteamID()..") on "..os.date("%d/%m/%Y at %H:%M"),
	}
	local Headers = {}
	Headers["Authorization"] = "Client-ID "..'dfeaeb61c742a1e'

	local HTTPArgs = {
		failed = onFailure,
		success = onSuccess,
		method = "post",
		url = "https://api.imgur.com/3/image.json",
		parameters = Parameters,
		headers = Headers,
	}
	HTTP(HTTPArgs)
	P("Sending picture ("..string.NiceSize(#capture)..") to imgur...")
	--PrintTable(HTTPArgs)
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
local function finishedSelection(x,y,xx,yy)
	if not x or not y or not xx or not yy then return end
	
	PS(x,y,xx,yy)
	
	local tx,ty = x,y
	local txx,tyy = xx,yy
	
	if tx>txx then local a=txx txx=tx tx=a end
	if ty>tyy then local a=tyy tyy=ty ty=a end
	
	local x,y,w,h = tx,ty,txx-tx+1,tyy-ty+1
	if w==1 and h==1 then return end
	
	
	
	local lt=time()
	local q = 90
	local cap = capture(x,y,w,h,q)
	
	
	-- cap = base64.encode(cap) -- :( let the send-ee decode :(
	PS(Format('Captured! (%0.2fs)',time()-lt))
	print(x,y,w,h)
	
	sendToImgur(cap)
	
	autosend=nil cap=nil
end

local wasdown
local x,y,xx,yy
local function drawCross(x,y)
	surface.SetDrawColor(Color(15,25,0,255))
	surface.DrawRect(x-3,0,3*2+1,ScrH()) -- wow that was hard
	surface.DrawRect(0,y-3,ScrW(),3*2+1)
end
local function PostRenderVGUI()
	if input.IsMouseDown(MOUSE_RIGHT) then
		-- Right click finishes the selection
		timer.Simple(0.1,
			function()
				finishedSelection(x,y,xx,yy)
			end
		)
		gui.EnableScreenClicker(false)
		timer.Simple(0.2, function() donodraw(false) end)
		hook.Remove('PostRenderVGUI', Tag)
		return
	end
	
	local isdown = input.IsMouseDown(MOUSE_LEFT)
	local mx,my = gui.MousePos()
	
	if not wasdown and isdown then wasdown=1 x,y,xx,yy=mx,my,nil,nil end -- set p1
	if wasdown and not isdown then wasdown=nil xx,yy=mx,my end -- set p2
	
	
	surface.SetFont'closecaption_bold'
	surface.SetTextColor(Color(255,255,255,100))
	local txt = 'Click and drag. Right click to finish.'
	local sx,sy = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW()/2-sx/2,sy)
	surface.DrawText(txt)
	
	
	if x and y then
		drawCross(x,y)
		
		drawCross(xx or mx,yy or my)
		local tx,ty = x,y
		local txx,tyy = xx or mx,yy or my
		
		if tx>txx then local a=txx txx=tx tx=a end
		if ty>tyy then local a=tyy tyy=ty ty=a end
		local w,h = txx-tx+1,tyy-ty+1
		surface.SetDrawColor(Color(255,255,0,20))
		surface.DrawRect(tx,ty,w,h)
		
		surface.SetFont'closecaption_bold'
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


hook.Add("ChatCommand","imgur",function(com,paramstr,msg)
	if com:lower()~="imgur" then return end
	LocalPlayer():ConCommand("imgur")
end)


concommand.Add('imgur',function(_,_,args)
	P'Click and drag. Right click to finish.'
	gui.EnableScreenClicker(true)
	
	wasdown=nil
	x,y,xx,yy=nil,nil,nil,nil
	hook.Add('PostRenderVGUI',Tag,PostRenderVGUI)
	donodraw(true)
end) 