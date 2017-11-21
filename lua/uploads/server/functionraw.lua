function GetFunctionRaw( func, src )
	assert( isfunction( func ), "bad argument #1 to 'GetFunctionRaw' (function expected, got " .. type( func ) .. ")" )
	
	local ret = {}
	
	local info = debug.getinfo( func, "S" )
	if info.what ~= "Lua" then return end
	
	if not src then
		src = info.short_src
	end
	
	local fileRaw = file.Read( src, "GAME" )
	if fileRaw == nil then return end
	
	local lines = string.Explode( "\n", fileRaw )
	
	for i = info.linedefined, info.lastlinedefined do
		ret[#ret +1] = lines[i]
	end
	
	ret[#ret +1] = "-- "..src
	
	return table.concat( ret, "\n" )
end
