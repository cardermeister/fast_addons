local workfile = 'iin/bans.txt'

local tInsert = table.insert

function iin.LoadBans()
	
	iin.BannedUsers = {}

	local file_read = file.Read(workfile,"DATA")
	
	local lines = string.Explode("\n",file_read)
	
	for i,k in next,lines do
		local cid,reason = k:match("(%d-) (.+)") 
		tInsert(iin.BannedUsers,{cid=cid,reason=reason})
	end

end

iin.LoadBans()	
	

function iin.Ban(cid,reason)


	local l = file.Open(workfile, "a", "DATA")
	if l then
		l:Write(cid..' '..reason.."\n")
		l:Close()
	end
	
	tInsert(iin.BannedUsers,{cid=cid,reason=reason})
		
	iin.Msg(nil,Color(255,187,0),"● ",Color(0,0,0),"(Console)",Color(0,0,0)," banned ",Color(161,255,161),cid,Color(255,255,255),' with reason: '..reason)
	
end


local to_cid = util.SteamIDTo64

local function log(txt)
	if not isstring(txt) then return end
	local l = file.Open("hardbans_log.txt", "a", "DATA")
	if l then
		l:Write("["..os.date("%Y/%m/%d %H:%M:%S").."] "..txt.."\n")
		l:Close()
	end
	Msg"[Hardban] " ErrorNoHalt(txt)
end


iin.AddCommand("ban",function(ply,args)

	args = iin.ParseArgs(args)
	if #args ~= 2 then iin.error(ply,"Недостаточно аргументов функции {[1]=ply [2]=reason}") return end
	
	local reason = args[2]
	local pcolor
	local name_line = args[1]
	local player = easylua.FindEntity(name_line)
	local cid
	
	if player and player:IsPlayer() then
		
		pcolor = team.GetColor(player:Team())
		
		cid = to_cid( player:SteamID() )
		
		player:Kick("Getting ban.")
		
		
	else
		
		if name_line:find("STEAM_0:") then
			
			cid = to_cid( name_line )
			
		elseif #name_line==17 then
			
			cid = name_line
		
		end
	
	end


	if not cid then iin.error(ply,"CID не найден.") return end
	
	local txt = tostring(cid).." "..reason
 
	local l = file.Open(workfile, "a", "DATA")
	if l then
		l:Write(txt.."\n")
		l:Close()
	end
	
	log(ply:Name()..' banned '..txt)
	
	tInsert(iin.BannedUsers,{cid=cid,reason=reason})
		
	iin.Msg(nil,Color(255,187,0),"● ",ply,Color(0,0,0)," banned ",pcolor or Color(161,255,161),cid,Color(255,255,255),' with reason: '..reason)
	
end,'admins')


hook.Add("CheckPassword","RainbowBans",function( cid,_,_,_, name )

	for i,k in pairs(iin.BannedUsers) do
		
		if k.cid == cid then
			log(name.." try to join")
			return false,k.reason	
		end
		
	end

	

end)


local BanTable = iin.BannedUsers
 
function Unban( cid )
    assert( isstring( cid ), "bad argument #1 to 'Unban' (string expected, got " .. type( cid ) .. ")" )
 
    if string.match( cid, "^STEAM_%d:%d:%d+$" ) then
        cid = util.SteamIDTo64( cid )
    end
   
    if not string.match( cid, "^%d+$" ) then
        error( "Incorrect cid to unban" )
    end
   
    local BanFile = file.Read( "iin/bans.txt" )
    local BanFile_table = string.Explode( "\n", BanFile )
   
    for i, line in pairs( BanFile_table ) do
        local Player64ID = string.match( line, "^%d+" )
       
        if Player64ID == cid then
            table.remove( BanFile_table, i )
            for j, ply in pairs( BanTable ) do
                if ply.cid == cid then
                    table.remove( BanTable, j )
                    break
                end
            end
           
            local BanFile = table.concat( BanFile_table, "\n" )
           
            file.Write( "iin/bans.txt", BanFile )
           
            print( cid .. " has been unbanned" )
           
            return
        end
    end
   
    print( "Player with cid " .. cid .. " not found in ban list" )
end