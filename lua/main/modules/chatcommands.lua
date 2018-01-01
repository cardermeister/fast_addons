
local Tag = "iin"
iin = iin or {}

iin.Prefix = "!"
local EchoCmds=CreateConVar( Tag.."_echo_luacmds", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE,FCVAR_NOTIFY} )

function iin.AddCommand(cmd,callback,group,hidechat)
	iin.cmds = iin.cmds or {}
	iin.cmds[cmd] = {callback = callback, group = group or "players", cmd = cmd, hidechat = hidechat or false}
end


function iin.CallCommand(ply,cmd,line,args)
cmd = iin.cmds[cmd]
	local ok,err = pcall(function()
		cmd.callback(ply,line,unpack(args))
	end)

	if not ok then
		ply:EmitSound("buttons/button8.wav", 100, 120)
		ErrorNoHalt(err)
	end
end


function iin.ChatCommands(ply,txt)
	if txt:sub(1, 1) == iin.Prefix then
		local cmd = txt:match("^" .. iin.Prefix .. "(%S*)") or ""
		local line = txt:match(iin.Prefix .. ".- (.+)")
		
		cmd = cmd:lower()
		local iincmd = iin.cmds[cmd]
		if iincmd then
			if ply:CheckGroupPower(iincmd.group) then
				iin.CallCommand(ply, cmd, line, line and iin.ParseArgs(line))
				if iincmd.hidechat then return "" end
			end
		end
	end
end
hook.Add("PlayerSay", "chatcmd", iin.ChatCommands)
 
concommand.Add(Tag,function(ply, _, _, args)
	args = iin.ParseArgs(args)

	local cmd = table.remove(args, 1) or ""
	local line = table.concat(args, " ")
	
	cmd = cmd:lower()
	local iincmd = iin.cmds[cmd]
	if iincmd then
		if ply:CheckGroupPower(iincmd.group) then
			iin.CallCommand(ply, cmd, line, line and iin.ParseArgs(line))
		end
	end
end)

iin.AddCommand("say", function(player, line)
	if not line or line=="" then return end
	timer.Simple(0,function()luadev.RunOnClients("Say(" .. line .. ")") end)
end, "devs", true) 
