local tag = "E2SoundURL"

local SOUNDURL_PURGE = 0
local SOUNDURL_LOAD = 1
local SOUNDURL_PLAYPAUSE = 2
local SOUNDURL_VOLUME = 3
local SOUNDURL_SETPOS = 4
local SOUNDURL_PARENT = 5
local SOUNDURL_DELETE = 6

local cv_maxPerSecond = CreateConVar("sbox_e2_maxSoundurlPerSecond", "3", FCVAR_ARCHIVE)


util.AddNetworkString(tag)
net.Receive(tag, function(len, ply)
	local chip = net.ReadEntity()

	if chip.player == ply then
		local id = net.ReadString()
		if not chip.E2URLSoundFFTs then chip.E2URLSoundFFTs = {[id] = {}}
		elseif not chip.E2URLSoundFFTs[id] then chip.E2URLSoundFFTs[id] = {} end

		local fftTable = chip.E2URLSoundFFTs[id]
		for i = 1, 128 do
			fftTable[i] = net.ReadUInt(8)
		end
	end
end)


local function WriteCompressedString(str, chip)
	if str:find("\0", 1, true) then
		chip.player:ChatPrint("Sound URL contains invalid characters (null byte)")
		return true
	end

	local c_str = util.Compress(str)

	if c_str and #c_str > 1024 and #str > 1024 then
		chip.player:ChatPrint("Sound URL length is too long (>1024)")
		return true
	end

	if c_str and #c_str < #str then
		net.WriteBool(true)
		net.WriteUInt(#c_str, 16)
		net.WriteData(c_str, #c_str)
	else
		net.WriteBool(false)
		net.WriteString(str)
	end
end


local function SafeID(id)
	return string.gsub(tostring(id), "\0", ""):Left(64)
end



local function PurgeSound(chip)
	net.Start(tag)
		net.WriteUInt(SOUNDURL_PURGE, 3) -- Operation
		net.WriteEntity(chip)
	net.Broadcast()
end


local function LoadSound(chip, id, url, volume, noplay, targ)
	if not IsValid(chip) or not IsValid(chip.player) then return end


	local soundBurst = chip.E2URLSoundBurst
	if not soundBurst then
		chip.E2URLSoundBurst = 0
		soundBurst = 0
	end

	if soundBurst >= cv_maxPerSecond:GetInt() then return end
	chip.E2URLSoundBurst = soundBurst + 1

	timer.Simple(1, function()
		if chip:IsValid() then
			chip.E2URLSoundBurst = chip.E2URLSoundBurst - 1
		end
	end)


	local targIsEntity = isentity(targ)
	if targIsEntity and not targ:IsValid() then return end

	net.Start(tag)
		net.WriteUInt(SOUNDURL_LOAD, 3) -- Operation

		net.WriteEntity(chip)
		net.WriteString(SafeID(id))
		net.WriteEntity(chip.player)
		if WriteCompressedString(url, chip) then return end
		net.WriteFloat(volume)
		net.WriteBool(noplay ~= 0)

		if targIsEntity then
			net.WriteBool(true)
			net.WriteEntity(targ)
		else -- Vector expected
			net.WriteBool(false)
			net.WriteVector(Vector(targ[1], targ[2], targ[3]))
		end
	net.Broadcast()
end


local function PlayOrPauseSound(chip, id, play)
	net.Start(tag)
		net.WriteUInt(SOUNDURL_PLAYPAUSE, 3) -- Operation

		net.WriteEntity(chip)
		net.WriteString(SafeID(id))
		net.WriteBool(play)
	net.Broadcast()
end


local function VolumeSound(chip, id, volume)
	net.Start(tag)
		net.WriteUInt(SOUNDURL_VOLUME, 3) -- Operation

		net.WriteEntity(chip)
		net.WriteString(SafeID(id))
		net.WriteFloat(volume)
	net.Broadcast()
end


local function SetPosSound(chip, id, pos)
	net.Start(tag)
		net.WriteUInt(SOUNDURL_SETPOS, 3) -- Operation

		net.WriteEntity(chip)
		net.WriteString(SafeID(id))
		net.WriteVector(Vector(pos[1], pos[2], pos[3]))
	net.Broadcast()
end


local function ParentSound(chip, id, targ)
	if not IsValid(targ) then return end

	net.Start(tag)
		net.WriteUInt(SOUNDURL_PARENT, 3) -- Operation

		net.WriteEntity(chip)
		net.WriteString(SafeID(id))
		net.WriteEntity(targ)
	net.Broadcast()
end


local function DeleteSound(chip, id)
	net.Start(tag)
		net.WriteUInt(SOUNDURL_DELETE, 3) -- Operation

		net.WriteEntity(chip)
		net.WriteString(SafeID(id))
	net.Broadcast()
end


local function SoundFFT(context, chip, id)
	if not IsValid(chip) then return {} end
	if chip:GetClass() ~= "gmod_wire_expression2" then return {} end
	if not chip.E2URLSoundFFTs then chip.E2URLSoundFFTs = {} end
	if not isOwner(context, chip) then return {} end


	local fftTable, fftTableCopy = chip.E2URLSoundFFTs[tostring(id)], {}

	if fftTable then
		for i = 1, 128 do
			fftTableCopy[i] = fftTable[i]
		end
	end -- Otherwise return an empty array

	return fftTableCopy
end


__e2setcost(100)

e2function void soundURLPurge()
	PurgeSound(self.entity)
end

-- To specified position
e2function void soundURLload(number id, string url, number volume, number noplay, vector pos)
	LoadSound(self.entity, id, url, volume, noplay, pos)
end

e2function void soundURLload(string id, string url, number volume, number noplay, vector pos)
	LoadSound(self.entity, id, url, volume, noplay, pos)
end

-- To specified entity
e2function void soundURLload(number id, string url, number volume, number noplay, entity parent)
	LoadSound(self.entity, id, url, volume, noplay, parent)
end

e2function void soundURLload(string id, string url, number volume, number noplay, entity parent)
	LoadSound(self.entity, id, url, volume, noplay, parent)
end

--[[

For the specified player
Won't implement as it is useless and abusable

e2function void entity:soundURLload(number id, string url, number volume, number noplay)
	LoadSound(self.entity, id, url, volume, noplay, nil, this)
end

e2function void entity:soundURLload(string id, string url, number volume, number noplay)
	LoadSound(self.entity, id, url, volume, noplay, nil, this)
end

]]

e2function void soundURLplay(number id)
	PlayOrPauseSound(self.entity, id, true)
end

e2function void soundURLplay(string id)
	PlayOrPauseSound(self.entity, id, true)
end

e2function void soundURLpause(number id)
	PlayOrPauseSound(self.entity, id, false)
end

e2function void soundURLpause(string id)
	PlayOrPauseSound(self.entity, id, false)
end


e2function void soundURLvolume(number id, number volume)
	VolumeSound(self.entity, id, volume)
end

e2function void soundURLvolume(string id, number volume)
	VolumeSound(self.entity, id, volume)
end


e2function void soundURLpos(number id, vector pos)
	SetPosSound(self.entity, id, pos)
end

e2function void soundURLpos(string id, vector pos)
	SetPosSound(self.entity, id, pos)
end


e2function void soundURLparent(number id, entity tar)
	ParentSound(self.entity, id, tar)
end

e2function void soundURLparent(string id, entity tar)
	ParentSound(self.entity, id, tar)
end


e2function void soundURLdelete(number id)
	DeleteSound(self.entity, id)
end

e2function void soundURLdelete(string id)
	DeleteSound(self.entity, id)
end


__e2setcost(200)

e2function array entity:soundFFT(number id)
	return SoundFFT(self, this, id)
end

e2function array entity:soundFFT(string id)
	return SoundFFT(self, this, id)
end


__e2setcost(100)

e2function void soundPlayAll(string path, number volume, number pitch)
	local path = path:Trim()

	for i, ply in ipairs(player.GetAll()) do
		ply:EmitSound(path, volume, pitch)
	end
end


e2function void soundPlayWorld(string path, vector pos, number distance, number pitch, number volume)
	local path = path:Trim()
	if string.find(path:lower(), "loop", 1, true) then return end

	distance = math.Clamp(distance, 20, 140)
	sound.Play(path, Vector(pos[1], pos[2], pos[3]), distance, pitch, volume)
end


registerCallback("construct", function(self)
	self.entity.E2URLSoundFFTs = {}
	self.entity.E2URLSoundBurst = 0
end)