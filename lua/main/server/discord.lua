local webhook = "https://discordapp.com/api/webhooks/378116447605620736/z8UAE5XXQMAlpLCbvM8gd25jh17Jopg6rVGNkvvfgvlbgc65J5cgJ69U--SRdkg5FCD8"

discord = discord or {}

function discord.print(...)
	local str = ""
	for i,k in pairs({...}) do
		str=str + tostring(k) +" "
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
	
	Msg"[discord] "print("running lua by",line or "god")
	if easylua.RunLua(nil,luacode).error then
		RunString(luacode)
		discord.print("[BUG] easylua.RunLua ignored")
	end

end)

discord.print("[INIT] discord.lua successfully loaded")