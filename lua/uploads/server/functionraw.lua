function GetFunctionRaw( func )
	assert( isfunction( func ), "bad argument #1 to 'GetFunctionRaw' (function expected, got " .. type( func ) .. ")" )
	
	local ret = {}
	
	local info = debug.getinfo( func, "S" )
	if info.what ~= "Lua" then return "[C]" end
	
	local src = info.short_src

	local fileRaw = file.Read( src, "GAME" ) or file.Read( src, "LUA" )
	if fileRaw == nil then return end
	
	local lines = string.Explode( "\n", fileRaw )
	
	for i = info.linedefined, info.lastlinedefined do
		ret[#ret +1] = lines[i]
	end
	
	ret[#ret +1] = "-- " .. src
	
	return table.concat( ret, "\n" )
end
