local tag = "E2SoundURL"

local SOUNDURL_PURGE = 0
local SOUNDURL_LOAD = 1
local SOUNDURL_PLAYPAUSE = 2
local SOUNDURL_VOLUME = 3
local SOUNDURL_SETPOS = 4
local SOUNDURL_PARENT = 5
local SOUNDURL_DELETE = 6

local cv_enable = CreateClientConVar("wire_expression2_soundurl_enable", "1", true, false)
local cv_maxPerSecond = CreateClientConVar("wire_expression2_soundurl_maxPerSecond", "3", true, false)
local cv_maxSoundCount = CreateClientConVar("wire_expression2_soundurl_maxSoundCount", "5", true, false)
local cv_blocked = CreateClientConVar("wire_expression2_soundurl_block", "SteamID,", false, false)


local ParentedSounds = {}
local fftTable = {}


local URLSound
do
	local IGModAudioChannel = FindMetaTable("IGModAudioChannel")
	local META = {}

	function META:__index(key)
		local ret = META[key]

		if ret ~= nil then
			return ret
		end

		return IGModAudioChannel[key]
	end

	function META:Play()
		if self.audio then
			self.audio:Play()
		else
			self.play = true
		end
	end

	function META:Pause()
		if self.audio then
			self.audio:Pause()
		else
			self.play = false
		end
	end

	function META:SetVolume(volume)
		if self.audio then
			self.audio:SetVolume(volume)
		else
			self.volume = volume
		end
	end

	function META:SetPos(pos)
		if self.audio then
			self.audio:SetPos(pos)
		else
			self.pos = pos
		end
	end

	function META:SetParent(targ)
		if self.audio then
			ParentedSounds[self] = targ
		else
			self.parent = targ
		end
	end

	function META:Stop()
		if self.audio then
			self.audio:Stop()
		else
			self.stop = true
		end
	end

	function META:FFT(dest, samples)
		if self.audio then
			self.audio:FFT(dest, samples)
		end
	end

	function META:IsValid()
		return IsValid(self.audio)
	end

	function META:AttachAudio(audio)
		self.audio = audio
	end

	function META:AttachOldAudio(audio)
		self.oldaudio = audio
	end

	function META:ApplyParameters()
		local audio = self.audio
		if not audio then return end

		if self.stop then
			audio:Stop()
		else
			if self.play ~= nil then
				if self.play then
					audio:Play()
				else
					audio:Pause()
				end
			end

			if self.volume then
				audio:SetVolume(self.volume)
			end

			if self.pos then
				audio:SetPos(self.pos)
			end

			if self.parent then
				ParentedSounds[self] = self.parent
			end
		end
	end

	function URLSound()
		return setmetatable({}, META)
	end
end


local function ReadCompressedString()
	local isCompressed = net.ReadBool()

	return isCompressed
		and util.Decompress( net.ReadData(net.ReadUInt(16)) )
		or net.ReadString()
end


local function ClearURLSounds(soundTable)
	for id, audio in pairs(soundTable) do
		audio:Stop()
		ParentedSounds[audio] = nil
	end
end

local function ClearURLSoundsAll()
	local chips = ents.FindByClass("gmod_wire_expression2")

	for i, chip in ipairs(chips) do
		ClearURLSounds(chip.E2URLSounds)
	end
end


concommand.Add("wire_expression2_soundurl_stopall", ClearURLSoundsAll)

concommand.Add("wire_expression2_soundurl", function(ply, cmd, args)
	if tonumber(args[1]) == 0 then 
		cv_enable:SetBool(false)
		ClearURLSoundsAll()
	else
		cv_enable:SetBool(true)
	end
end)



net.Receive(tag, function()
	local operation = net.ReadUInt(3)
	local chip = net.ReadEntity()


	if operation == SOUNDURL_PURGE then
		local soundTable = chip.E2URLSounds
		if soundTable then ClearURLSounds(chip.E2URLSounds) end

		return
	end

	local id = net.ReadString()

	if operation == SOUNDURL_LOAD then
		if not chip:IsValid() then return end
		if not chip.E2URLSounds then chip.E2URLSounds = {} end
		local soundTable = chip.E2URLSounds

		local owner = net.ReadEntity()


		do -- Limit checks
			-- enable
			if not cv_enable:GetBool() then return end


			-- MaxSoundCount
			local soundCount = table.Count(soundTable)
			if soundTable[id] then soundCount = soundCount-1 end
			if soundCount >= cv_maxSoundCount:GetInt() then return end


			-- MaxPerSecond
			local soundBurst = chip.E2URLSoundBurst or 0
			if soundBurst >= cv_maxPerSecond:GetInt() then return end
			chip.E2URLSoundBurst = soundBurst + 1

			timer.Simple(1, function()
				if chip:IsValid() and chip.E2URLSoundBurst then
					chip.E2URLSoundBurst = chip.E2URLSoundBurst - 1
				end
			end)


			-- Blocked SteamID's
			local blocked = cv_blocked:GetString()
			if #blocked > 10 then
				blocked = string.Explode(",", blocked)

				for i, SteamID in ipairs(blocked) do
					if SteamID == owner:SteamID() then return end
				end
			end
		end


		local url = ReadCompressedString()
		local volume = net.ReadFloat()
		local noplay = net.ReadBool()

		local targIsEntity = net.ReadBool()
		local targ = targIsEntity and net.ReadEntity() or net.ReadVector()

		local urlSound = URLSound()
		if soundTable[id] then
			urlSound:AttachOldAudio(soundTable[id])
		end
		soundTable[id] = urlSound


		sound.PlayURL(url, noplay and "3d noplay" or "3d", function(audio)
			if not audio then return end

			urlSound:AttachAudio(audio)
			if urlSound.oldaudio then urlSound.oldaudio:Stop() end

			if not chip:IsValid() then
				urlSound:Stop()
				return
			end


			urlSound:SetVolume(volume)


			if targIsEntity then
				urlSound:SetParent(targ)
			else
				urlSound:SetPos(targ)
			end


			urlSound:ApplyParameters()


			chip:CallOnRemove(tag, function()
				local soundTable = chip.E2URLSounds

				timer.Simple(0, function() -- Full update message fix (can be sent to client due to lags)
					if not chip:IsValid() then
						ClearURLSounds(soundTable)
					end
				end)
			end)


			if LocalPlayer() == owner then
				local timername = string.format("%s.%i.%s", tag, chip:EntIndex(), id)

				timer.Create(timername, 0.1, 0, function()
					if not chip.E2URLSounds or not chip.E2URLSounds[id] then
						timer.Remove(timername)
						return
					end

					chip.E2URLSounds[id]:FFT(fftTable, 0)
					if not fftTable[1] then return end

					net.Start(tag)
						net.WriteEntity(chip)
						net.WriteString(id)
						
						for i = 1, 128 do
							net.WriteUInt(math.Round(fftTable[i]*255), 8)
						end
					net.SendToServer()

					fftTable[1] = nil -- Invalidate fft table for next use
				end)
			end
		end)
	else
		local sounds = chip.E2URLSounds
		if not sounds then return end

		local audio = sounds[id]
		if not IsValid(audio) then return end


		if operation == SOUNDURL_PLAYPAUSE then
			local play = net.ReadBool()

			if play then audio:Play()
			else audio:Pause() end

		elseif operation == SOUNDURL_VOLUME then
			local volume = net.ReadFloat()
			audio:SetVolume(volume)

		elseif operation == SOUNDURL_SETPOS then
			local pos = net.ReadVector()
			audio:SetPos(pos)

		elseif operation == SOUNDURL_PARENT then
			local targ = net.ReadEntity()
			audio:SetParent(targ)

		elseif operation == SOUNDURL_DELETE then
			audio:Stop()
			ParentedSounds[audio] = nil

		end
	end
end)


hook.Add("Tick", tag .. ".ParentSounds", function()
	for audio, parent in pairs(ParentedSounds) do
		if parent:IsValid() then
			audio:SetPos(parent:GetPos())
		end
	end
end)



E2Helper.Descriptions["soundURLPurge"] = "Stop all the URL sounds"
E2Helper.Descriptions["soundURLload"] = "Load the URL sound"
E2Helper.Descriptions["soundURLplay"] = "Play the URL sound"
E2Helper.Descriptions["soundURLpause"] = "Pause the URL sound"
E2Helper.Descriptions["soundURLvolume"] = "Set the URL sound volume, from 0 to 2 (200%)"
E2Helper.Descriptions["soundURLpos"] = "Set the URL sound position"
E2Helper.Descriptions["soundURLparent"] = "Parent the URL sound"
E2Helper.Descriptions["soundURLdelete"] = "Delete/stop the URL sound"

E2Helper.Descriptions["soundFFT"] =
	"Returns an FFT (Fast Fourier transform) array of the URL sound with 128 samples.\n" ..
	"Entity is a chip that created the URL sound.\n" ..
	"http://wiki.garrysmod.com/page/IGModAudioChannel/FFT"

E2Helper.Descriptions["soundPlayAll(snn)"] = "Emits the sound on every player entity"
E2Helper.Descriptions["soundPlayWorld(svnnn)"] = "Play sound at specific position"