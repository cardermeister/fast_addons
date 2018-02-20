local BanTable = iin.BannedUsers


function Unban(cid)
	assert(isstring(cid), "bad argument #1 to 'Unban' (string expected, got " .. type(cid) .. ")")

	if string.match(cid, "^STEAM_%d:%d:%d+$") then
		cid = util.SteamIDTo64(cid)
	end
	
	if not string.match(cid, "^%d+$") then
		error("Incorrect cid to unban")
	end
	
	BanFile = file.Read("iin/bans.txt")
	local BanFile_table = string.Explode("\n", BanFile)
	
	for i, line in ipairs(BanFile_table) do
		local Player64ID = string.match(line, "^%d+")
		
		if Player64ID == cid then
			table.remove(BanFile_table, i)
			for j, ply in ipairs(BanTable) do
				if ply.cid == cid then
					table.remove(BanTable, j)
					break
				end
			end
			
			local BanFile = table.concat(BanFile_table, "\n")
			
			file.Write("iin/bans.txt", BanFile)
			
			print(cid .. " has been unbanned")
			
			return
		end
	end
	
	print("Player with cid " .. cid .. " not found in ban list")
end


function BanReason(cid)
	assert(isstring(cid), "bad argument #1 to 'Unban' (string expected, got " .. type(cid) .. ")")

	if string.match(cid, "^STEAM_%d:%d:%d+$") then
		cid = util.SteamIDTo64(cid)
	end
	
	if not string.match(cid, "^%d+$") then
		error("Incorrect cid to unban")
	end
	
	BanFile = file.Read("iin/bans.txt")
	local BanFile_table = string.Explode("\n", BanFile)
	
	for i, line in ipairs(BanFile_table) do
		local Player64ID, reason = string.match(line, "^(%d+)%s(.*)")
		
		if Player64ID == cid then
			return reason
		end
	end
end
