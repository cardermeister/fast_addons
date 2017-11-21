function GetFunctionRaw( func )
	assert( isfunction( func ), "bad argument #1 to 'GetFunctionRaw' (function expected, got " .. type( func ) .. ")" )
	
	local ret = {}
	
	local info = debug.getinfo( func, "S" )
	if info.what ~= "Lua" then return "[C]" end
	
	local src = info.short_src

	local fileRaw = file.Read( src, "GAME" ) or file.Read( src, "LUA" )
	if fileRaw == nil then return end
	
	
	local lines = string.Explode( "\n", fileRaw )
	local minIndentations
	
	for i = info.linedefined, info.lastlinedefined do
		local line = lines[i]
		local _, tabs = line:gsub("^\t*", "")
		
		if tabs ~= 0 then
			if minIndentations then
				minIndentations = math.min(tabs, minIndentations)
			else
				minIndentations = tabs
			end
		end
		
		ret[#ret +1] = line
	end
	
	
	if minIndentations then
		local removePattern = "^" .. string.rep("\t", minIndentations)
		
		for i, line in ipairs(ret) do
			ret[i] = line:gsub(removePattern, "")
		end
	end
	
	
	table.insert(ret, 1, string.format("--[%i:%i] %s", info.linedefined, info.lastlinedefined, src))
	
	return table.concat( ret, "\n" )
end