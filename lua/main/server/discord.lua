local webhook = "https://discordapp.com/api/webhooks/378116447605620736/z8UAE5XXQMAlpLCbvM8gd25jh17Jopg6rVGNkvvfgvlbgc65J5cgJ69U--SRdkg5FCD8"

local discord_auth = "discord_auth.txt"
if not file.Exists(discord_auth,"DATA") then file.Write(discord_auth,util.TableToJSON({})) end

local discord_auth_json = util.JSONToTable(file.Read(discord_auth,"DATA"))
PrintTable(discord_auth_json)

discord = discord or {}



function discord.auth_request(ply)
	
	local isauthed = discord_auth_json[ply:SteamID()]
	//util.Base64Encode(me:SteamID():gsub("STEAM","AUTHD")) // QVVUSERfMDoxOjIyNDc3OTc2
	
	if ( (not isauthed) or (#isauthed~=18) ) then
		
		local token = util.Base64Encode(ply:SteamID():gsub("STEAM","AUTHD"))
		
		discord_auth_json[ply:SteamID()] = token
		file.Write(discord_auth,util.TableToJSON(discord_auth_json))
			
		Msg"[discord] "print(ply,"request discord auth with token:",token)
		return
	end
		
	Msg"[discord] "print(ply,"already link profile with id:",discord_auth_json[ply:SteamID()])
end

function discord.auth_apply(token,discordid)
	
	local finded = table.KeyFromValue(discord_auth_json,token)
	
	if finded then
		
		discord_auth_json[finded] = discordid
		file.Write(discord_auth,util.TableToJSON(discord_auth_json))
		
		Msg"[discord] "print(finded,"successfuly linked profile to discord:",discordid)
		return
	end
	
	Msg"[discord] "print("auth error",discordid)
	
end



function discord.print(...)
	local str = ""
	local args = {...}
	local maxn = table.maxn(args)
	
	if maxn>0 then
		
		for i = 1,maxn do
			str = str .. tostring(args[i]) .. "\t"
		end
		
	else
		
		str = 'nil'
	
	end
	
	local func = CompileString( str, "", false )
	if type(func)=='function' then str='```lua\n'..str:Left(1980)..'\n```' else str='```Markdown\n'..str:Left(1980)..'\n```' end
	
	http.Post(webhook,{content = str})
	return print(...)
end

function discord.PrintTable(...)
	
	http.Post(webhook,{content = "```Markdown\n"..table.ToString(...,nil,true):Left(1980).."\n```"})
	return PrintTable(...)	
end

discord.relay = false
discord.relay_prefix = discord.relay_prefix or "[G]"

function discord.relay_func(ply, text)
	
	if not discord.relay then return end

    if !ply then return end
	if !ply:AvatarURL() then return end
	
	local post_params = {
		content = text,
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
		GetFunctionRaw = function(...) local ret,num = string.gsub(GetFunctionRaw(...),"```","") return ret end
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

concommand.Add("discord-lua-run",function(ply,cmd,arg,line)
	
	local luacode = file.Read("discord-lua.txt","DATA")
	
	luacode = "local E = easylua.FindEntity; " + luacode
	
	Msg"[discord] "print("running lua by",line or "god")
	
	local func = CompileString( luacode, line, false )
	if type(func) == "function" then
			setfenv(func, discord.metatable)
			local args = {pcall(func)}

			if args[1] == false then
				discord.print("ERROR: "+args[2])
			end

	else
		discord.print("ERROR: "+func)
	end


end)

discord.print("[INIT] discord.lua successfully loaded") 
