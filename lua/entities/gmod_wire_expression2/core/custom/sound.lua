-- made by [G-moder]FertNoN

local nrd=net.ReadTable
local sexp = string.Explode
local tonumber = tonumber
local IsValid = IsValid
local Entity = Entity

local MaxSoundPerSecond = CreateConVar( "sbox_e2_maxSoundurlPerSecond", "3", FCVAR_ARCHIVE )
local tempSound = 0

util.AddNetworkString('FFTSendToServer')
net.Receive('FFTSendToServer',function(len,ply)
	local tbl = nrd()
	local ent = Entity(tbl[1])
	if ent.FFTStreamer!=ply then return end
	ent[tbl[2]]=tbl[3]
end)
	
__e2setcost(200)

e2function array entity:soundFFT(string id)
	if !IsValid(this) or !this[id] then return {} end
	local fft = sexp(' ',this[id])
	local result = {}
	for i=1,#fft do
		result[i]=tonumber(fft[i])
	end
	return result
end

e2function array entity:soundFFT(id)
	if !IsValid(this) or !this[id] then return {} end
	local fft = sexp(' ',this[id])
	local result = {}
	for i=1,#fft do
		result[i]=tonumber(fft[i])
	end
	return result
end

local function SoundURL(cmd, ent, id, volume, pos, url, noplay, tar, ply)	
	plys = RecipientFilter()
	local sgetplayer = ent:GetPlayer()
	local fft = sgetplayer
	if ply==nil then plys:AddAllPlayers() else plys:AddPlayer(ply) fft=ply end
	ent.FFTStreamer = fft
	umsg.Start("e2soundURL", plys)
		umsg.Entity(ent)
		umsg.Entity(fft)
		umsg.Entity(sgetplayer)
		if type(id)=="string" then 
			umsg.String(id)
		else 
			umsg.String("")
			umsg.Long(id) 
		end
		
		if cmd=="load" then 
			if !IsValid(tar) and (pos==nil || (pos[1]==0 and pos[2]==0 and pos[3]==0)) then umsg.Char(-1) umsg.End() return end
			if tempSound>MaxSoundPerSecond:GetInt() then umsg.Char(-1) umsg.End() return end
			tempSound=tempSound+1
			if tempSound==1 then timer.Simple( 1, function() tempSound=0 end) end
			umsg.Char(1)
			umsg.Char(volume)
			umsg.String(url)
			umsg.Char(noplay)
			if pos!=nil then umsg.Vector(Vector(pos[1],pos[2],pos[3])) else umsg.Vector(Vector(0,0,0)) end
			umsg.Entity(tar)
		end
		
		if cmd=="play" then 
			umsg.Char(2) 
		end
		
		if cmd=="stop" then 
			umsg.Char(3)
		end
		
		if cmd=="volume" then 
			umsg.Char(4)
			umsg.Char(math.Clamp(volume,0,1)*100)
		end
		
		if cmd=="pos" then 
			umsg.Char(5)
			umsg.Vector(Vector(pos[1],pos[2],pos[3]))
		end		
		
		if cmd=="del" then 
			umsg.Char(6)
		end	
		
		if cmd=="par" then 
			umsg.Char(7)
			umsg.Entity(tar)
		end	
		
		if cmd=="cls" then 
			umsg.Char(0)
		end		
	umsg.End() 
end

__e2setcost(100)

e2function void soundURLload(id,string url,volume, noplay, vector pos)
	SoundURL("load", self.entity, id, volume, pos, url, noplay)
end

e2function void soundURLload(string id,string url,volume, noplay, vector pos)
	SoundURL("load", self.entity, id, volume, pos, url, noplay)
end

e2function void soundURLload(id,string url,volume, noplay, entity tar)
	SoundURL("load", self.entity, id, volume, nil, url, noplay, tar)
end

e2function void soundURLload(string id,string url, volume, noplay, entity tar)
	SoundURL("load", self.entity, id, volume, nil, url, noplay, tar)
end

e2function void entity:soundURLload(id,string url,volume, noplay)
	SoundURL("load", self.entity, id, volume, nil, url, noplay, nil, this)
end

e2function void entity:soundURLload(string id,string url, volume, noplay)
	SoundURL("load", self.entity, id, volume, nil, url, noplay, nil, this)
end

e2function void soundURLplay(id)
	SoundURL("play", self.entity, id)
end

e2function void soundURLplay(string id)
	SoundURL("play", self.entity, id)
end

e2function void soundURLpause(id)
	SoundURL("stop", self.entity, id)
end

e2function void soundURLpause(string id)
	SoundURL("stop", self.entity, id)
end

e2function void soundURLvolume(id, volume)
	SoundURL("volume", self.entity, id, volume)
end

e2function void soundURLvolume(string id, volume)
	SoundURL("volume", self.entity, id, volume)
end

e2function void soundURLpos(id, vector pos)
	SoundURL("pos", self.entity, id, nil, pos)
end

e2function void soundURLpos(string id, vector pos)
	SoundURL("pos", self.entity, id, nil, pos)
end

e2function void soundURLparent(id, entity tar)
	SoundURL("par", self.entity, id, nil, nil, nil, nil, tar)
end

e2function void soundURLparent(string id, entity tar)
	SoundURL("par", self.entity, id, nil, nil, nil, nil, tar)
end

e2function void soundURLdelete(id)
	SoundURL("del", self.entity, id)
end

e2function void soundURLdelete(string id)
	SoundURL("del", self.entity, id)
end

e2function void soundURLPurge()
	SoundURL("clr", self.entity,0)
end

e2function void soundPlayAll(string path,volume,pitch)
	local path=path:Trim()
	for _, ply in ipairs( player.GetAll() ) do
		ply:EmitSound(path,volume,pitch)
	end
end

e2function void soundPlayWorld(string path,vector pos,distance,pitch,volume)
	local path=path:Trim()
	if string.find(path:lower(),"loop",1,true) then return end
	distance=math.Clamp(distance,20,140)
	sound.Play(path,Vector(pos[1],pos[2],pos[3]),distance,pitch,volume)
end