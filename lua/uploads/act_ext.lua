local t = {
	robot = 	'ACT_GMOD_TAUNT_ROBOT',
	salute = 	'ACT_GMOD_TAUNT_SALUTE',
	agree = 	'ACT_GMOD_GESTURE_AGREE',
	becon = 	'ACT_GMOD_GESTURE_BECON',
	bow = 	 	'ACT_GMOD_GESTURE_BOW',
	cheer = 	'ACT_GMOD_TAUNT_CHEER',
	dance = 	'ACT_GMOD_TAUNT_DANCE',
	disagree = 	'ACT_GMOD_GESTURE_DISAGREE',
	forward = 	'ACT_SIGNAL_FORWARD',
	group = 	'ACT_SIGNAL_GROUP',
	halt = 	 	'ACT_SIGNAL_HALT',
	laugh = 	'ACT_GMOD_TAUNT_LAUGH',
	muscle = 	'ACT_GMOD_TAUNT_MUSCLE',
	pers = 	 	'ACT_GMOD_TAUNT_PERSISTENCE',
	wave = 	 	'ACT_GMOD_GESTURE_WAVE',
	zombie = 	'ACT_GMOD_GESTURE_TAUNT_ZOMBIE',
	throw = 	'ACT_GMOD_GESTURE_ITEM_THROW',
	place = 	'ACT_GMOD_GESTURE_ITEM_PLACE',
	give = 	 	'ACT_GMOD_GESTURE_ITEM_GIVE',
	drop = 	 	'ACT_GMOD_GESTURE_ITEM_DROP',
	shove = 	'ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND',
	frenzy = 	'ACT_GMOD_GESTURE_RANGE_FRENZY',
	attack = 	'ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL',
	melee = 	'ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE',
	melee2 = 	'ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2',
	poke =  	'ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM',
	fist =  	'ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST',
	stab =  	'ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE',
}

for k,v in next,t do
	local num = _G[v]
	if not num then error"gmod update broke this" end
	t[k]={v,num}
	--if not me:LookupSequence(v) then print("fail",v) end
end

_G.actx_list=t

local function actx(pl,cmd,args,argline)
	if CLIENT then
		RunConsoleCommand("cmd",'actx',unpack(args))
		return
	end
	
	local what=args[1] or false
	local dat=t[what]
	local name=dat and dat[1]
	local id=dat and dat[2]

	if not id then pl:ChatPrint"invalid act name" return end
	
	if hook.Run("PlayerShouldTaunt",pl,id,true)==false then return end
	
	pl:DoAnimationEvent(id)
	
	local seq,len = pl:LookupSequence(name)
	if not id or id==-1 or id==0 then pl:ChatPrint"wtf" return end
	
	if args[1] != "wave" and args[1] != "salute" then return end
	local wander = pl:GetEyeTrace().Entity
	if wander:IsValid() and wander:GetClass() == "lua_npc_wander" and wander.OnPlayerGreeting then
		wander:OnPlayerGreeting(pl)
	end
	
	
end

local function ac(cmd,args)
	local ac={}
	
	for k,v in next,t do
		if k:find(args:sub(2,-1),1,true) or args:len()<2 then
			local k = "actx "..k
			table.insert(ac,k)
		end
	end
	return ac
end

concommand.Add("actx",actx,ac,"extended act gestures without taunt camera")
if SERVER then return end
concommand.Add("actt",actx,ac,"extended act gestures without taunt camera")

hook.Add("PopulateMenuBar", "actmenu", function(bar)

	local commands = {}
	
	for k,v in next,t do
		table.insert(commands,k)
	end
	
	table.sort(commands)
	
	
	local list = bar:AddOrGetMenu("Act")
	for _, str in pairs(commands) do
		list:AddOption(str:gsub("^%l", string.upper), function() RunConsoleCommand("actx", str) end )
	end
	
	--hook.Remove("PopulateMenuBar", "actmenu")
end)
 
 