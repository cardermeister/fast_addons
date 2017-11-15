local webhook = "https://discordapp.com/api/webhooks/378116447605620736/z8UAE5XXQMAlpLCbvM8gd25jh17Jopg6rVGNkvvfgvlbgc65J5cgJ69U--SRdkg5FCD8"

discord = discord or {}

function discord.print(...)
	local str = ""
	local args = {...}
	
	for i = 1,table.maxn(args) do
		str = str .. tostring(args[i]) .. "\t"
	end
	
	http.Post(webhook,{content = str})
	return print(...)
end

function discord.PrintTable(...)
	
	http.Post(webhook,{content = table.ToString(...,nil,true)})
	return PrintTable(...)	
end


concommand.Add("discord-lua-run",function(ply,cmd,arg,line)
	
	local luacode = file.Read("discord-lua.txt","DATA")
	
	luacode = "local E = easylua.FindEntity; " + luacode
	
	Msg"[discord] "print("running lua by",line or "god")
	
	local func = CompileString( luacode, line, false )
	if type(func) == "function" then
	
			local args = {pcall(func)}

			if args[1] == false then
				discord.print("ERROR: "+args[2])
			end

	else
		discord.print("ERROR: "+func)
	end


end)

discord.print("[INIT] discord.lua successfully loaded") 
