local Tag="AFKMon"
local Now=SysTime

local MAX_AFK = CreateConVar("mp_afktime","90",{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL },"Seconds until flagged as afk")
local LocalPlayer=LocalPlayer

local ignoreinput=false

local function inp()
	ignoreinput=false
end

local tstamp = {}
local function ModeChanged(id,isafk)
	local pl
	if SERVER then
		pl=id
		id=pl:UserID()
	else
		for k,v in pairs(player.GetAll()) do
			if v:UserID()==id then
				pl=v
			end
		end
	end
	
	local tstamp_old = tstamp[ id ] and (Now()-tstamp[ id ]) or 0
	local tstamp_new = Now() - (isafk and MAX_AFK:GetInt() or 0)
	tstamp[ id ] = tstamp_new
	
	-- to make any AFK inputs go away
	if CLIENT and pl==LocalPlayer() then
		ignoreinput=true
		timer.Simple(0.1,inp)
	end
	hook.Call('AFK',nil,pl,isafk,id,tstamp_old,tstamp_new)
end

local function SetAFKMode(pl,afk)
	pl:SetNetData(Tag,(afk and true) or false)
end

FindMetaTable("Player").IsAFK = function(s) return s:GetNetData(Tag) or false end
FindMetaTable("Player").AFKTime = function(s) return Now() - (tstamp[s:UserID() or -1] or Now()) end

hook.Add("NetData",Tag,function(pl,k,isafk)
	if k==Tag and (isafk==true or isafk==false or isafk==nil) then
		ModeChanged(pl,isafk)

		if SERVER then return true end
		
	end
end)


hook.Add('AFK',Tag,function(pl,afk,id,len)
	if SERVER then
		if afk then
			pl:EmitSound("replay/cameracontrolmodeexited.wav")
		else
			pl:EmitSound("replay/cameracontrolmodeentered.wav")
		end
		return
	end
	
	Msg"[AFK] "
	local name = (IsValid( pl ) and pl:Name() or id)
	if afk then
		print(name..' is now afk (was present for '..string.NiceTime(len or 0)..')')
	else
		print(name..' is no longer afk (was away for '..string.NiceTime(len or 0)..')')
	end
	

	if pl~=LocalPlayer() then return end
	
	if not afk then
		chat.AddText(Color(100,255,100,255),"Welcome back",Color(50,200,50,255),'!',Color(255,255,255,255)," You were away for ",Color(200,200,255,255),string.NiceTime(len or 0),Color(100,255,100,255),".")
	end

end)

if CLIENT then
		
	if system.IsLinux() then return end	
	
	local local_afk

----- Input tracking ----
	
	local last_input=Now()+5 -- mouse coords
	local last_focus = Now() + 5
	local function InputReceived()
		if ignoreinput then return end
		last_input=Now()
	end


	local last_mouse=Now()+5


	local oldmouse=1
	local mx,my= gui.MouseX,gui.MouseY
	local function Think()

		-- Check for mouse movement
		local newmouse=mx()+my()
		if newmouse ~= oldmouse then
			oldmouse = newmouse
			last_mouse=Now()
			--Msg"!"
		end
		if system.HasFocus() then
			last_focus = Now()
		end
	
		local max=MAX_AFK:GetInt()
		local var=Now()-max
		local me=LocalPlayer()
		if (last_mouse < var and last_input < var) or last_focus < Now()-5 then
			if not local_afk then
				local_afk = true
				SetAFKMode(me, true )
			end
		elseif local_afk then
			local_afk = false
			SetAFKMode(me, false )
		end

	end
	timer.Simple(10,function() -- waiting a bit
		timer.Create(Tag,0.2,0,Think)
	end)

	-- The following is for view input
	hook.Add( "KeyPress", Tag, InputReceived )
	hook.Add( "KeyRelease", Tag, InputReceived )
	hook.Add( "PlayerBindPress", Tag, InputReceived )

	do -- some hacky key checking
		local oldkeys =nil
		local old_y   =nil
		local last_32 = false
		local last_33 = false
		local last_27 = false
		local last_29 = false
		local last_31 = false
		local last_19 = false
		local last_11 = false
		local last_14 = false
		local last_15 = false
		local last_25 = false
		local last_79 = false
		local last_65 = false
		--local keyarray,newarray,lastarray ={},{},{}
		--for _,x in pairs{"KEY_A","KEY_E","KEY_I","KEY_O","KEY_U","KEY_Q","KEY_W","KEY_S","KEY_D"} do keyarray[x]=true lastarray[x]=false end
		local isdown=input.IsKeyDown
		local function CheckStuff(UCMD)

			if oldkeys~=UCMD:GetButtons() then
				InputReceived()
				oldkeys = UCMD:GetButtons()
			end

			if old_y~=UCMD:GetMouseX( ) then
				InputReceived()
				old_y = UCMD:GetMouseX( )
			end

			-- Unrolled loop for maximum efficiency
			-- Checking only some keys so we don't bloat the game with these.
			if isdown(33)~=last_33 then
				last_33 = isdown(33)
				InputReceived()
				return
			end
			if isdown(27)~=last_27 then
				last_27 = isdown(27)
				InputReceived()
				return
			end
			if isdown(29)~=last_29 then
				last_29 = isdown(29)
				InputReceived()
				return
			end
			if isdown(31)~=last_31 then
				last_31 = isdown(31)
				InputReceived()
				return
			end
			if isdown(19)~=last_19 then
				last_19 = isdown(19)
				InputReceived()
				return
			end
			if isdown(11)~=last_11 then
				last_11 = isdown(11)
				InputReceived()
				return
			end
			if isdown(14)~=last_14 then
				last_14 = isdown(14)
				InputReceived()
				return
			end
			if isdown(15)~=last_15 then
				last_ = isdown(15)
				InputReceived()
				return
			end
			if isdown(25)~=last_25 then
				last_25 = isdown(25)
				InputReceived()
				return
			end
			if isdown(32)~=last_32 then
				last_32 = isdown(32)
				InputReceived()
				return
			end
			if isdown(79)~=last_79 then
				last_79 = isdown(79)
				InputReceived()
				return
			end
			if isdown(65)~=last_65 then
				last_65 = isdown(65)
				InputReceived()
				return
			end
		end
		hook.Add("CreateMove", Tag, CheckStuff)
	end


	
end