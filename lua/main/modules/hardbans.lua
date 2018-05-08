local workfile = "iin/bans.txt"


local function log(txt)
	if not isstring(txt) then return end

	local l = file.Open("hardbans_log.txt", "a", "DATA")

	if l then
		l:Write("[" .. os.date("%Y/%m/%d %H:%M:%S") .. "] " .. txt .. "\n")
		l:Close()
	end

	Msg"[Hardban] " ErrorNoHalt(txt)
end

local function unixTimeToHuman(time)
	return os.date("%Y/%m/%d %H:%M:%S", time)
end

local function isplayer(any)
	return type(any) == "Player"
end

local function findEntity(identifier)
	if isentity(identifier) then
		return identifier
	end

	identifier = tostring(identifier)
	local entity = easylua.FindEntity(identifier)

	if not IsValid(entity) or #identifier == 17 then
		entity = player.GetBySteamID64(identifier) or NULL
	end

	return entity
end


function iin.LoadBans()
	local bans = assert(file.Read(workfile, "DATA"), "File reading failed!")
	iin.BannedUsers = assert(util.JSONToTable(bans), "JSON parsing failed!")
end


function iin.UpdateBans()
	local bans = util.TableToJSON(iin.BannedUsers)
	file.Write(workfile, bans)
end


function iin.Ban(identifier, reason, by)
	assert(
		isstring(identifier) or isplayer(identifier),
		"bad argument #1 to 'Ban' (string or Player expected, got " .. type(identifier) .. ")"
	)

	assert(
		isstring(reason),
		"bad argument #2 to 'Ban' (string expected, got " .. type(reason) .. ")"
	)

	if by ~= nil then
		assert(
			isplayer(by),
			"bad argument #3 to 'Ban' (nil or Player expected, got " .. type(by) .. ")"
		)

		if isplayer(by) and not by:IsValid() then
			error("bad argument #3 to 'Ban' (Tried to use a NULL entity!)")
		end
	end


	local pcolor = Color(161, 255, 161)
	local player = findEntity(identifier)
	local cid


	if isplayer(player) and player:IsValid() then
		pcolor = team.GetColor(player:Team())
		cid = player:SteamID64()

		player:Kick("Getting ban.")
	elseif isstring(identifier) then
		if string.find(identifier, "^STEAM_%d:%d:%d+$") then
			cid = util.SteamIDTo64(identifier)
		elseif #identifier == 17 then
			cid = identifier
		end
	end

	if not cid then
		return false, "Игрок не найден"
	end


	if iin.BannedUsers["_" .. cid] then return end

	iin.BannedUsers["_" .. cid] = {
		reason = reason,
		by = by and by:SteamID64() or "(Console)",
		date = os.time()
	}
	
	iin.UpdateBans()
	log(string.format("%s banned %s %s", by and by:Name() or "(Console)", cid, reason))

	if by then
		iin.Msg(
			nil,
			Color(255, 187, 0),
			"● ",
			by,
			color_black,
			" banned ",
			pcolor,
			cid,
			color_white,
			" with reason: ",
			reason
		)
	else
		iin.Msg(
			nil,
			Color(255, 187, 0),
			"● ",
			color_black,
			"(Console) banned ",
			pcolor,
			cid,
			color_white,
			" with reason: ",
			reason
		)
	end

	return true, cid .. " has been banned"
end


function iin.Unban(cid, by)
	assert(
		isstring(cid),
		"bad argument #1 to 'Unban' (string expected, got " .. type(cid) .. ")"
	)

	if by ~= nil then
		assert(
			isplayer(by),
			"bad argument #2 to 'Unban' (nil or Player expected, got " .. type(by) .. ")"
		)

		if isplayer(by) and not by:IsValid() then
			error("bad argument #2 to 'Unban' (Tried to use a NULL entity!)")
		end
	end


	if string.find(cid, "^STEAM_%d:%d:%d+$") then
		cid = util.SteamIDTo64(cid)
	elseif #cid ~= 17 or not string.find(cid, "^%d+$") then
		return false, "Неправильный ID"
	end


	if iin.BannedUsers["_" .. cid] then
		iin.BannedUsers["_" .. cid] = nil
		iin.UpdateBans()
		log(string.format("%s unbanned %s", by and by:Name() or "(Console)", cid))

		return true, cid .. " разбанен"
	else
		return false, cid .. " не найден в списке банов"
	end
end


function iin.BanInfo(cid)
	assert(
		isstring(cid),
		"bad argument #1 to 'BanInfo' (string expected, got " .. type(cid) .. ")"
	)

	local ban = iin.BannedUsers["_" .. cid]

	if ban then
		return {
			reason = ban.reason,
			by = ban.by or "n/a",
			date = ban.date and unixTimeToHuman(ban.date) or "n/a"
		}
	end
end


iin.AddCommand("ban", function(ply, args)
	args = iin.ParseArgs(args)
	
	if #args < 2 then
		iin.error(ply, "Недостаточно аргументов функции {[1]=ply [2]=reason}")
		return
	end

	local identifier = args[1]
	local reason = args[2]
	
	local ok, msg = iin.Ban(identifier, reason, ply)

	if not ok then
		iin.error(ply, msg)
	end
end, "admins", true)


iin.AddCommand("unban", function(ply, args)
	args = iin.ParseArgs(args)
	
	if #args < 1 then
		iin.error(ply, "Недостаточно аргументов функции {[1]=cid}")
		return
	end

	local cid = args[1]
	
	local ok, msg = iin.Unban(cid, ply)

	if ok then
		iin.Msg(
			ply,
			Color(255, 187, 0),
			"● ",
			color_white,
			msg
		)
	else
		iin.error(ply, msg)
	end
end, "devs", true)


iin.AddCommand("baninfo", function(ply, args)
	args = iin.ParseArgs(args)
	
	if #args < 1 then
		iin.error(ply, "Недостаточно аргументов функции {[1]=cid}")
		return
	end

	local cid = args[1]
	
	local info = iin.BanInfo(cid)

	if info then
		iin.Msg(
			ply,
			Color(255, 187, 0), "● ", color_white, "Информация о бане:",
			Color(117, 113, 94), "\n\t♢ ", color_white, "Кем забанен: ", Color(161, 161, 255), info.by,
			Color(117, 113, 94), "\n\t♢ ", color_white, "Причина: ", Color(127, 127, 127), info.reason,
			Color(117, 113, 94), "\n\t♢ ", color_white, "Дата: ", Color(255, 127, 0), info.date
		)
	else
		iin.error(ply, cid .. " не найден в списке банов")
	end
end, "admins", true)


hook.Add("CheckPassword", "RainbowBans", function(cid, _, _, _, name)
	local ban = iin.BannedUsers["_" .. cid]

	if ban then
		log(name .. " try to join - " .. cid)
		return false, ban.reason
	end
end)


iin.LoadBans()