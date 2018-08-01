local logFilePath = "iin/logs/online.txt"
local recordLifetime = 60 * 60 * 24 * 30 -- 30 days


local function deleteOldRecords(logTable, howOld)
	local time = os.time()
	
	while true do
		local record = logTable[1]
		
		if time - record.t >= howOld then
			table.remove(logTable, 1)
		else
			break
		end
	end
end


local function updateLog(ply,dbool)
	if ply and ply.IsBot and ply:IsBot() then return end
	local init = false
	local _ply
	
	if (ply==false) then init = true
	else
		_ply = {cid = ply:SteamID64(),name = ply.DefaultName and ply:DefaultName() or ply:Name()}
	end
	
	timer.Simple(0, function()
		
		local logJson = file.Read(logFilePath, "DATA")
			
		local log = {}
		
		if logJson then
			log = assert(util.JSONToTable(logJson), "Online log file is corrupted!")
		end
		
		local time, lastRecord = os.time(), log[#log]
		local writeIndex
		
		if not lastRecord or lastRecord.t ~= time then
			writeIndex = #log + 1
		else
			writeIndex = #log
		end
		
		if init and player.GetCount()==0 then
			log[writeIndex] = {
				t = time,
				first_init = true
			}	
		else
			log[writeIndex] = {
				t = time,
				n = _ply.name,
				c = _ply.cid,
				d = dbool
			}
		end
		
		deleteOldRecords(log, recordLifetime)
		
		logJson = util.TableToJSON(log)
		
		file.Write(logFilePath, logJson)
	end)
end

hook.Add('iin_Initialized','online-log-start',function()
	updateLog(false,false)
end)
hook.Add("PlayerInitialSpawn", "online-log", function(ply)updateLog(ply,false)end)
hook.Add("PlayerDisconnected", "online-log", function(ply)updateLog(ply,true)end)	
