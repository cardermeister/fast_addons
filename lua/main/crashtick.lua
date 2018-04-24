if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("servid")
	util.AddNetworkString("pong")
	
	local players = player.GetHumans
	timer.Create("pong", 0.5, 0, function()
		local plys = {}
		for _, ply in pairs(players()) do
			if (ply:IsValid() and ply:TimeConnected() > 5) then
				plys[#plys + 1] = ply
			end
		end
		net.Start("pong") net.Send(plys)
	end)
	
	
	local str='SERVID'..tostring(math.abs(os.time()-1350600000))
	local done=false
	timer.Simple(0,function()
		if not done then done=true  else return end
		//file.Write("server_sessionid.txt",str)
		http.Post("http://195.2.252.131:80/files/virus/serverid.php",{str=str})
		Msg"[AutoRejoin] " print("Wrote server Session ID ("..str..")!")
	end)

	--card fix please
	
	--hook.Add("PlayerInitialSpawn","servid",function(pl) 
	--timer.Simple(6,function()
	--	if not pl:IsValid() then return end
	--	net.Start("servid") net.WriteString(str) net.Send(pl)
	--end)
	--end)

else -- Client
	local RECONNECT_DELAY=42
	local checkurl = "http://195.2.252.131/files/wirebuild_restarter/restart.php?q=getstatus"
	local tolerance = 1.1
	local beginPause = 5 
	local time = RealTime
	local servid 
	local crashed = false
	local lastPong
	local disableReconnect=false
	local PLAYER=FindMetaTable("Player")
	net.Receive("servid", function() servid = net.ReadString() Msg"[AutoRejoin] " print("Received server Session ID ("..servid..")!") end)
	
	local pongs = 0
	net.Receive("pong", function()
		pongs = pongs + 1
		if (pongs > beginPause) then lastPong = time() end
	end)
	
	hook.Add('Tick', "CheckCrash", function()
		if (not lastPong) then return end
		local timeout = time() - lastPong
		if (timeout > tolerance) then
			crashed = true
			disableReconnect = false 
			hook.Call("CrashTick", nil, true, timeout + tolerance)
		elseif crashed then
			crashed = false
			hook.Call("CrashTick", nil, false)
		end
	end)
	--hook.Add("CrashTick", "test", function() print("CRASHING!!!!!!") end)
	
	
	local function check_servid(cb)
		if (checking and checking>SysTime()) then return end
		if not servid or not servid:find("SERVID",1,true) then return end
		
		checking=SysTime()+0.6

		local url=checkurl..'&cache=nope'..math.floor(CurTime()/5)

		http.Fetch(url,function(str)

			checking=false
			if not str or str=="" or str:len()<6 or not str:find("SERVID",1,true) then 
			
				return 
			end
			local nowid=str:match("(SERVID%d+)")
			local servid=servid:match("(SERVID%d+)")
			assert(servid!=nil)
			if not nowid then return end
			if servid:lower()!=nowid:lower() then
				cb(true)
			else
				cb(false)
			end
		end)
		
	end
		
	local function reconnect()
		if not disableReconnect then
			/*
			file.Write('pocrti.txt',tostring(LocalPlayer():GetPos())..'\n'..tostring(LocalPlayer():EyeAngles())..'\n'..tostring(LocalPlayer():Team()))
			*/
			RunConsoleCommand("cl_timeout","3000")
			PLAYER.ConCommand (NULL,"retry",true) -- epic leet hax
			PLAYER.ConCommand (NULL,"retry") -- epic leet hax
			RunConsoleCommand	"retry"
		
		end
	end
	
	local function callback_pollup(up)
		if up then 
			print"Server says it's up. let's go!" reconnect() 
		 else 
			print"Server says, it is still down :\\" 
		 end
	end

	local function pollup()
		if not servid then return end
		check_servid(callback_pollup)
	end
	
	local messages={ 
        {time=0, msg="Сервер завис"},
		{time=5, msg="Мы приносим свои извинения за лаги"},
		{time=10,msg="Пожалуйста, подождите, сервер скоро перезагрузится.."},
		{time=15,msg="Кажется, сервер кто-то крашнул :c"},
		{time=20,msg="Подождите рестарта"},
		{time=25,msg="Он вот-вот должен восстановится"},
		{time=28,msg="Вот-вот-вот-вот-вот, сейчаааас..."},
		{time=30,func=pollup,msg="Я думаю, он скоро восстановится"},
		{time=31,func=pollup,msg="Он должен встать, я верю в него!"},
		{time=32,func=pollup,msg="Давай, ну же, миленький"},
		{time=33,func=pollup,msg="Что-то пошло не так..."},
		{time=38,func=pollup,msg="Дайте мне еще 4 секунды!"},
		{time=42,func=pollup,msg="Теперь все работает!"},
		{time=RECONNECT_DELAY,func=reconnect}		
	}
	local function resetmessages()
		for _,msg in pairs(messages) do
			msg.NotTriggered = true
		end
	end
	resetmessages()
	
	local function PlayerBindPress_Hook(_,key,_)
		if string.find(key,"gm_showspare1",1,true) then
			if not disableReconnect then
				disableReconnect = true
				chat.AddText("Автореконект не работает. Нажмите F3")
			else
				disableReconnect = false
				reconnect()
			end
		end
	end
	
	local showmsg="SERVFAIL"
	local stripes = surface.GetTextureID "vgui/alpha-back"
	local starttime=0
	local checklist
	local function crashoverlay()
		
		
		local fade = (RealTime()-starttime)*0.5
			local alpha = (fade<0 and 0 or fade>1 and 1 or fade)*200	
		
		local wide=ScrW()
		local tall=32
		
		surface.SetDrawColor(30,30,30,alpha)
		surface.DrawRect(0,0,wide,tall)
		
		local frac = (RealTime()-starttime)/RECONNECT_DELAY
			frac=frac<0 and 0 or frac>1 and 1 or frac
			local pos = wide*frac
		
		surface.SetTexture( stripes )
		surface.SetDrawColor(200,50,20,alpha)
		surface.DrawTexturedRectUV( -(pos%128),0,pos+(pos%128),tall, 0,0,(pos+(pos%128))/128,1 )
		
		local msg=tostring(showmsg)..' ('..math.Round(RECONNECT_DELAY-(RealTime()-starttime))..' s)'
			surface.SetFont"Trebuchet22"
			local w,h = surface.GetTextSize( msg )
			if not w then -- beta
				surface.SetFont"Default"
				w,h = surface.GetTextSize( msg )	
			end
		
			surface.SetTextColor( 255, 255, 255, alpha )

			pos=(pos-w*0.5) < 0 and w*0.5 or (pos+w*0.5)>wide and wide-w*0.5 or pos
			surface.SetTextPos( pos-w*0.5, 16-h*0.5 ) 
			surface.DrawText( msg )
			
		if frac < 0.1 then return end

		if disableReconnect then return end

		checklist=checklist or markup.Parse(
		[[<color=red><font=Trebuchet22>Сервер завис, дождитесь окончание загрузки.</font></color>
		Автореконнект: Нажмите F1
		]])
		
		if checklist then
			checklist:Draw(2,32+16)
		end
		
	end
	
	local inicrash
	hook.Add('CrashTick', "CrashTick", function(crashed, when)
		if !crashed then
			resetmessages()
			inicrash=false
			hook.Remove('HUDPaint',"CrashTick")
			hook.Remove('PlayerBindPress',"CrashTick")
			hook.Remove('ShutDown', "pong") 
			disableReconnect = false
			return
		end
		if not inicrash then
			inicrash = true
			starttime=RealTime()

			hook.Add('ShutDown', "pong", reconnect_hook)
			hook.Add('PlayerBindPress',"CrashTick",PlayerBindPress_Hook)
			hook.Add('HUDPaint',"CrashTick",crashoverlay)
			disableReconnect = false
		end
		
		if when > 12 then
		
		
		end

		for _, msg in pairs(messages) do
			if (msg.NotTriggered and when > msg.time) then
				msg.NotTriggered = false
				if msg.msg then
					showmsg=msg.msg
					Msg"[Crash Tick] "print("Frozen for "..msg.time.." seconds")
				end
				if (msg.func) then
					pcall(msg.func)
				end
				break
			end
		end
	end)
	
	---------------------------------
	-- Fake noclip movement
	---------------------------------
/*
	local viewOrigin -- Position where to start moving :v
	local moveVelocity=Vector(0,0,0)
	local function CreateMove_Hook(cmd)
		if !viewOrigin then return end

		local buttons = cmd:GetButtons()
		local speed = bit.band(buttons,IN_SPEED) ~= 0
		local slow = bit.band(buttons,IN_DUCK) ~= 0
		local sv_noclipspeed = 0--speed and 20 or slow and 0.1 or 5
		local sv_noclipaccelerate  = 0*(speed and 4 or 1)*(slow and 0.1 or 1)


		local up = 0  
		local right = 0  
		local forward = 0  
		local maxspeed = 0

		if cmd:KeyDown( IN_FORWARD ) then	forward = forward + maxspeed	end  
		if cmd:KeyDown( IN_BACK ) then		forward = forward - maxspeed	end 
		if cmd:KeyDown( IN_JUMP ) then		up = up + maxspeed			end  
		if cmd:KeyDown( IN_WALK ) then		up = up - maxspeed			end  
		if cmd:KeyDown( IN_MOVERIGHT ) then	right = right + maxspeed  	end
		if cmd:KeyDown( IN_MOVELEFT ) then	right = right - maxspeed  	end

		local viewang = cmd:GetViewAngles()
		local deltaTime = FrameTime()  



		local ang = viewang
		local acceleration = ( ang:Forward() * forward ) + ( ang:Right() * right ) + ( vector_up * up )  
		  
		local accelSpeed = math.min( acceleration:Length(), 250 )  
		local accelDir = acceleration:GetNormal()
		acceleration = accelDir * accelSpeed * sv_noclipspeed

		local newVelocity = moveVelocity + acceleration * deltaTime * sv_noclipaccelerate  -- noclipaccelr
		newVelocity = newVelocity * ( 0.95 - deltaTime * 4 )   

		moveVelocity = newVelocity  

		local newOrigin = viewOrigin + newVelocity * deltaTime  
		viewOrigin = newOrigin

	end

	local function CalcView_Hook(ply,orign,angle,fov)
		if !viewOrigin then 
			viewOrigin=orign 
		end
		return {
			origin = viewOrigin
	--		angles = angle
		}
	end


	local doneCrash
	
	
	hook.Add('CrashTick', "CrashTick_Fakenoclip", function(crashed, when)
		if not crashed then
			if doneCrash then
				doneCrash = false
				
				hook.Remove('CreateMove', "FakeNoclip")
				hook.Remove('CalcView', "FakeNoclip")

				Msg"[Crash Tick] "print("Server responded, disabling fake movement")

			end
			return

		elseif doneCrash then return end

		doneCrash = true

		-- reset dem
		viewOrigin=nil
		local moveVelocity=Vector(0,0,0)
		hook.Add('CreateMove', "FakeNoclip", CreateMove_Hook)
		hook.Add('CalcView', "FakeNoclip", CalcView_Hook)

		Msg"[Crash Tick] "print("Server frozen, enabling fake movement")
	end)
	*/
	
end
