local Tag = "loadingscreen"

local joinTimer = {}
local mapStartTime = os.time()

local function playerConnect( name, address )
	joinTimer[address] = os.time()
	//Msg"[Join] "print(name,"-",address)
end
hook.Add( "PlayerConnect",Tag, playerConnect)

local function playerInitialSpawn( ply )
	local ip = ply:IPAddress()
	local seconds = os.time() - (joinTimer[ip] or mapStartTime)
	joinTimer[ip] = nil
	/*
	ply:SendLua(
	[=[
		file.Write("quadparty_speedjoin.txt","LOADINGSPEED = ]=]..tostring(seconds)..[=[;")
	]=])
	*/
	ply.JoinTime = seconds
	Msg"[Spawn] "print(ply,"has spawned after "..seconds.." seconds.")
end
hook.Add( "PlayerInitialSpawn", Tag, playerInitialSpawn )