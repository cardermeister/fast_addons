function GetFunctionSource(func)
	assert(isfunction(func), "bad argument #1 to 'GetFunctionSource' (function expected, got " .. type(func) .. ")")
	
	local ret = {}
	
	local info = debug.getinfo(func, "S")
	if info.what ~= "Lua" then return end
	
	local src = info.short_src

	local fileRaw = file.Read(src, "GAME") or file.Read(src, "LUA")
	if fileRaw == nil then return end
	
	
	local lines = string.Explode("\n", fileRaw)
	local minIndents = math.huge
	local needToTrimIndents = true
	
	for i = info.linedefined, info.lastlinedefined do
		local line = lines[i]
		
		-- if [we need to trim] and [the line isn't empty]
		if needToTrimIndents and line:Trim(" ") ~= "" then
			-- Match the first tabs sequence
			local tabs = line:match("^\t+")
			
			-- If we have indentation on this line
			if tabs then
				-- Then choose between shortest tab sequence and save its length
				minIndents = math.min(#tabs, minIndents)
			else
				-- Otherwase abort indentation fix
				needToTrimIndents = false
			end
		end
		
		ret[#ret +1] = line
	end
	
	
	-- If indentation fix wasn't aborted
	if needToTrimIndents then
		-- Tab sequence we need to remove
		local removePattern = "^" .. string.rep("\t", minIndents)
		
		for i, line in ipairs(ret) do
			ret[i] = line:gsub(removePattern, "")
		end
	end

	
	-- Insert the first/last line and the source file path
	table.insert(ret, 1, string.format("-- [%i:%i] %s", info.linedefined, info.lastlinedefined, src))
	if (src:Left(19)=="addons/fast_addons/") then
		table.insert(ret, 2, string.format("-- [https://github.com/cardermeister/fast_addons/blob/master/%s]", string.gsub(src,"addons/fast_addons/","")))
	end
	
	return table.concat(ret, "\n")
end
