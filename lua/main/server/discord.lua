local webhook = "https://discordapp.com/api/webhooks/378116447605620736/z8UAE5XXQMAlpLCbvM8gd25jh17Jopg6rVGNkvvfgvlbgc65J5cgJ69U--SRdkg5FCD8"

discord = discord or {}

function discord.print(...)
	local str = ""
	local args = {...}
	
	for i = 1,table.maxn(args) do
		str = str .. tostring(args[i]) .. "\t"
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

local env = {
	print = discord.print,
	PrintTable = discord.PrintTable,
	GetFunctionRaw = function(...) local ret,num = string.gsub(GetFunctionRaw(...),"```","` ` `") return ret end
}
local meta = {}
meta.__index = _G
setmetatable(env, meta)

concommand.Add("discord-lua-run",function(ply,cmd,arg,line)
	
	local luacode = file.Read("discord-lua.txt","DATA")
	
	luacode = "local E = easylua.FindEntity; " + luacode
	
	Msg"[discord] "print("running lua by",line or "god")
	
	local func = CompileString( luacode, line, false )
	if type(func) == "function" then
			setfenv(func, env)
			local args = {pcall(func)}

			if args[1] == false then
				discord.print("ERROR: "+args[2])
			end

	else
		discord.print("ERROR: "+func)
	end


end)

discord.print("[INIT] discord.lua successfully loaded") 
