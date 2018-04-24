util.AddNetworkString("discord.msg")

local webhook = "https://discordapp.com/api/webhooks/378116447605620736/z8UAE5XXQMAlpLCbvM8gd25jh17Jopg6rVGNkvvfgvlbgc65J5cgJ69U--SRdkg5FCD8"

local discord_auth = "discord_auth.txt"
if not file.Exists(discord_auth,"DATA") then file.Write(discord_auth,util.TableToJSON({})) end

local discord_auth_json = util.JSONToTable(file.Read(discord_auth,"DATA"))

discord = discord or {}

discord.apikey = "Mzc3ODkwNjA0MTk5MzEzNDA4.Db2ohQ.mMGodUNrG_09E8PyRwpuwL2FBnw"

local dev_chan = "378129058317336576"
local ans_channel = dev_chan
function discord.setchannel(chan) ans_channel=chan end
function discord.getchannel() return ans_channel end


function hex2rgb(hex)
    hex = hex:gsub("#","")
    return Color(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end

local function do_say_from_ds(username, msg, hexcolor, attachments)
	if hexcolor == "#000000" then hexcolor = "#447092" end
	
	if attachments then
		msg=attachments.." "..msg	
	end

	net.Start("discord.msg")
		net.WriteString(username)
		net.WriteColor(hex2rgb(hexcolor))
		net.WriteString(msg)
	net.Broadcast()
end

function discord.get_relay()

	local t = util.JSONToTable(file.Read('discord-chat.txt'))
	do_say_from_ds(t.author,t.content,t.hexcolor,t.attachments)
		
end

function discord.send(msg,tab)
	tab = istable(tab) and table.Add({content = msg},tab) or {content = msg}
	local channel = discord.getchannel()
	http.Post(Format("https://discordapp.com/api/channels/%s/messages",channel),tab,function()end,function()end,{Authorization = "Bot "..discord.apikey})
end

local function ReadFuncClose(callback)

	discord_auth_json = util.JSONToTable(file.Read(discord_auth,"DATA"))
		callback()
	file.Write(discord_auth,util.TableToJSON(discord_auth_json))

end

function discord.auth_flush() file.Write(discord_auth,util.TableToJSON({})) discord_auth_json = {} end

function discord.auth_request(ply)
	
	local isauthed = discord_auth_json[ply:SteamID()]
	
	if ( (not isauthed) or (#isauthed~=18) ) then
		
		local token = "KEY-"..util.CRC(ply:SteamID():gsub("STEAM","AUTHD")).."-END"
		
		ReadFuncClose(function()
			discord_auth_json[ply:SteamID()] = token
		end)
		
		ply:ChatPrint("discord: !auth "..token)
			
		Msg"[discord] "print(ply,"request discord auth with token:",token)
		return
	end
		
	Msg"[discord] "print(ply,"already linked to discordid:",discord_auth_json[ply:SteamID()])
end

function discord.auth_apply(token,discordid)
	
	local finded = table.KeyFromValue(discord_auth_json,token)
	
	if finded then
		
		ReadFuncClose(function()
			discord_auth_json[finded] = discordid
		end)
		
		Msg"[discord] "print(finded,"successfully linked own account to discord:",discordid)
		return
	end
	
	Msg"[discord] "print("auth error",discordid)
	
end


function discord.send_tab(tab)
	file.Write("discord-tab.txt",util.TableToJSON(tab))
end

hook.Add("PlayerInitialSpawn","discord.online",function()timer.Simple(0,function()discord.send_tab({action="setgame",count=player.GetCount()})end)end)
gameevent.Listen"player_disconnect"
hook.Add("player_disconnect","discord.online",function()timer.Simple(0,function()discord.send_tab({action="setgame",count=player.GetCount()})end)end)


function discord.print(...)
	local str = ""
	local args = {...}
	local maxn = table.maxn(args)
	
	if maxn==1 and type(args[1])=="table" then 
		return discord.PrintTable(args[1])
	end
	
	if maxn>0 then
		
		for i = 1,maxn do
			local val = args[i]
			if type(val) == "function" then
			
				local info = debug.getinfo(val, "S")
				if not info or info.what == "C" then
					val = "function:([C])"
				else
					val = ("function:(%s : %s-%s)"):format(info.short_src, info.linedefined, info.lastlinedefined)
				end
			
			end
			
			str = str .. tostring(val) .. "\t"
		end
		
	else
		
		str = 'nil'
	
	end
	
	local func = CompileString( str, "", false )
	if type(func)=='function' then str='```lua\n'..str:Left(1980)..'\n```' else str='```Markdown\n'..str:Left(1980)..'\n```' end
	
	//http.Post(webhook,{content = str})
	discord.send(str)
	return print(...)
end

function discord.status()

	local str = "```lua\n{\n"
	
	for i,k in pairs(player.GetAll()) do
		
		str = str + "\t" + "[" + k:EntIndex() + "] " + k:GetName() + " --" + k:SteamID() + "\n"
			
	end
	
	str = str + "}\n``` steam://connect/195.2.252.214:27015"
	//http.Post(webhook,{content = str})
	discord.send(str)
end

function discord.PrintTable(...)
	
	local str = "```Markdown\n"..table.ToString(...,nil,true):Left(1980).."\n```"
	//http.Post(webhook,{content = str})
	discord.send(str)
	return PrintTable(...)	
end

discord.relay = true
discord.relay_prefix = discord.relay_prefix or ""

function discord.relay_func(ply, text)
	
	if text == "!auth" then discord.auth_request(ply) return end
	if not discord.relay then return end

    if !ply then return end
	if !ply:AvatarURL() then return end
	
	local post_params = {
		content = string.gsub(text, "[\\`*_~]", "\\%1"),
		username = discord.relay_prefix.." "..(ply:Nick() or "Unknown"),
		avatar_url = ply:AvatarURL()
	}
	
	local t_struct = {
		failed = function( err ) MsgC( Color(255,0,0), "HTTP error: " .. err ) end,
		method = "post",
		url = webhook,
		parameters = post_params,
		type = "application/json; charset=utf-8"
	}
	
	HTTP( t_struct )
    	
end
hook.Add("PlayerSay","discord_relay_chat", discord.relay_func)	



do 
	local meta = {}
	
	local env = {
		print = discord.print,
		PrintTable = discord.PrintTable,
		GetFunctionSource = function(...) local ret,num = string.gsub(GetFunctionSource(...),"```","") return ret end
	}
	
	function meta:__index(key)
		local var = _G[key]

		if var ~= nil then
			return var
		end

		var = easylua.FindEntity(key)
		if var:IsValid() then
			return var
		end

		return nil
	end
	
	
	function meta:__newindex(key, value)
		_G[key] = value
	end
	
	discord.metatable = setmetatable(env, meta)
	
end

hook.Add("PlayerInitialSpawn","discord_auth_icon",function(ply)
	ply:SetNWString("discordid",discord_auth_json[ply:SteamID()])
end)

concommand.Add("discord-auth-key",function(ply,c,arg)
	if IsValid(ply) then return end
	discord.auth_apply(arg[1],arg[2])
end)

concommand.Add("discord-lua-run",function(ply,cmd,arg,line)
	
	if IsValid(ply) then return end
	local linejson = util.JSONToTable(line)
	local line = linejson[1]
	local answer_chan = linejson[2]
	local luacode = file.Read("discord-lua.txt","DATA")
	local steamid_user = table.KeyFromValue(discord_auth_json,line)

	if not steamid_user then Msg"[discord] "print("please link your profile to run lua.") return end
	
	luacode = "local me = easylua.FindEntity('"+steamid_user+"'); if me:IsPlayer() then local this = me:GetEyeTrace().Entity end; local suki = player.GetAll; " + luacode
	
	Msg"[discord] "print("running lua by",steamid_user or "1337","/ Answer:",answer_chan)
	
	local func = CompileString( luacode, line, false )
	discord.setchannel(answer_chan)
	if type(func) == "function" then
			setfenv(func, discord.metatable)
			local args = {pcall(func)}

			if args[1] == false then
				discord.print("ERROR: "+args[2])
			end

	else
		discord.print("ERROR: "+func)
	end
	discord.setchannel(dev_chan)

end)

discord.print("[INIT] discord.lua successfully loaded") 

hook.Add('iin_Initialized','serverstartdiscordnotify',function()
	discord.print("[SERVER] Successfully Initialized") 
end)
