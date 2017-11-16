Tag = "gsapi"
module(Tag,package.seeall)

apikey = "C9E4E47AB57681D140D9924A16196EC8"

local jdec = util.JSONToTable // futile attempt to make things faster
local jenc = util.TableToJSON // futile attempt to make things faster

local function callbackCheck(code)
    assert(code~=401,"Authorization error (Is your key valid?)")
    assert(code~=500,"It seems the steam servers are having a hard time.") 
    assert(code~=404,"Not found.")
    assert(code~=400,"Bad module request.")
end

function GetPlayTime(cid,game,callback)
	assert(#cid==17,"Community id is not valid")
	http.Fetch(string.format("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=%s&format=json&input_json={%%22appids_filter%%22:[%s],%%22steamid%%22:%s}",
		apikey,
		game,
		cid
	),
	function( body, _, _, code )
		callbackCheck(code)
		callback(jdec(body).response)
	end)
end


function IsFamily(cid,game,callback)
	assert(#cid==17,"Community id is not valid")
	http.Fetch(string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&steamid=%s&appid=%s&format=json",
		apikey,
		cid,
		game
	),
	function( body, _, _, code )
		callbackCheck(code)
		callback(jdec(body).response)
	end)
end

function GetAvatar(cid,callback)
	assert(#cid==17,"Community id is not valid")
	http.Fetch(string.format("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s&format=json",
		apikey,
		cid
	),
	function( body, _, _, code )
		callbackCheck(code)
		callback(jdec(body).response.players[1].avatarfull)
	end)
end

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
_playtime = _playtime or {}
_isfamily = _isfamily or {}
_avatarurl = _avatarurl or {}

local META = FindMetaTable("Player")

META.GetGTime = function(self)
	return _playtime[self:SteamID64()] or -1
end

META.AvatarURL = function(self)
	if _avatarurl[self:SteamID64()] then
		return _avatarurl[self:SteamID64()]
	end
	
	GetAvatar(cid,function(url)
		if url:match('https?://.+%.jpg') then
			_avatarurl[cid] = url
		end
	end)
	
	return false
end

META.IsFamily = function(self)
	return _isfamily[self:SteamID64()] or false
end

hook.Add("CheckPassword",Tag,function(cid,_,_,_,name)

	GetAvatar(cid,function(url)
		if url:match('https?://.+%.jpg') then
			_avatarurl[cid] = url
		end
	end)

	GetPlayTime(cid,4000,function(tab)
		
		if table.Count(tab) ~= 0 then 
	
			local tab = tab.games
	
			if tab then
				local t = tab[1].playtime_forever
				MsgC(Color(255,0,255),"[gsapi] ")print(name,"has only",t/60,'hours.')
				_playtime[cid] = t
			end
			
		else

			http.Fetch("http://steamcommunity.com/profiles/"..cid.."/games/?tab=recent&xml=1",function(s)

				for i,k in s:gmatch("<appID>(%d-)</appID>.-<hoursOnRecord>(.-)</hoursOnRecord>") do
					if i=="4000" then
						local t = tonumber(k:gsub(",",""),10)
						MsgC(Color(255,0,255),"[gsapi]v2 ")print(name,"has only",t,'hours.')
						_playtime[cid] = t*60
						break
					end
				end
			
			end)
			
		end
		
	end)

end)

util.AddNetworkString('time_achiv')
net.Receive("time_achiv",function(len,ply)
	
	local N = math.Round(net.ReadInt(32)/60)
	
	if N>250 and ply:GetModel()~="models/player/kleiner.mdl" then
		ply:SetCheater(true)
	end
	
	MsgC(Color(255,0,255),"[gsapi_fix] ")print(ply,"has only",N,'hours.')
	ply:SetNWString("gsapi_fixtime",'>'..N)
	ply.GMODTIME = N*60

end)

local function check(ply)

	timer.Simple(0.5,function()
		if IsValid(ply) and ply:GetNWString("gsapi_fixtime")=="" then
			ply:SendLua[[
			net.Start'time_achiv'
				net.WriteInt(achievements.GetCount(5),32)
			net.SendToServer()
			]]
			check()
		end
	end)
	
end

hook.Add("PlayerInitialSpawn",Tag,function(ply)
	if _playtime and ply:GetGTime()~=-1 then
		  
		ply.GMODTIME = ply:GetGTime()
		ply:SetNWInt(Tag.."_playtime",ply.GMODTIME)
		
		if ply.GMODTIME>15000 and ply:GetModel()~="models/player/kleiner.mdl" then
			ply:SetCheater(true)
		end
	
	elseif not ply.GMODTIME or ply.GMODTIME==-1  then
		check(ply)
	end
end) 

