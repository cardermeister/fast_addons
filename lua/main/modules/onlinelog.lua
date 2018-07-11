local logFilePath = "iin/logs/online.txt"
local recordLifetime = 60 * 60 * 24 * 2 -- 5 days


local function getPlayers()
	local players = {}
	
	for i, ent in ipairs(player.GetHumans()) do
		table.insert(players, {
			cid = ent:SteamID64(),
			name = ent.DefaultName and ent:DefaultName() or ent:Name()
		})
	end
	
	return players
end


local function deleteOldRecords(logTable, howOld)
	local time = os.time()
	
	while true do
		local record = logTable[1]
		
		if time - record.time >= howOld then
			table.remove(logTable, 1)
		else
			break
		end
	end
end


local function updateLog(ply)
	if ply:IsBot() then return end
	
	timer.Simple(0, function()
		local logJson = file.Read(logFilePath, "DATA")
		local log = {}
		
		if logJson then
			log = assert(util.JSONToTable(logJson), "Online log file is corrupted!")
		end
		
		local time, lastRecord = os.time(), log[#log]
		local writeIndex
		
		if not lastRecord or lastRecord.time ~= time then
			writeIndex = #log + 1
		else
			writeIndex = #log
		end
		
		log[writeIndex] = {
			time = time,
			players = getPlayers()
		}
		
		deleteOldRecords(log, recordLifetime)
		
		logJson = util.TableToJSON(log)
		
		file.Write(logFilePath, logJson)
	end)
end


hook.Add("PlayerInitialSpawn", "online-log", updateLog)
hook.Add("PlayerDisconnected", "online-log", updateLog)
