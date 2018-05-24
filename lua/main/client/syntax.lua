timer.Simple(0, function()

syntax = {}
local syntax = syntax

syntax.DEFAULT    = 1
syntax.KEYWORD    = 2
syntax.IDENTIFIER = 3
syntax.STRING     = 4
syntax.NUMBER     = 5
syntax.OPERATOR   = 6

syntax.types = {
	"default",
	"keyword",
	"identifier",
	"string",
	"number",
	"operator",
	"ccomment",
	"cmulticomment",
	"comment",
	"multicomment"
}

syntax.patterns = {
	[2]  = "([%a_][%w_]*)",
	[4]  = "(\".-\")",
	[5]  = "([%d]+%.?%d*)",
	[6]  = "([%+%-%*/%%%(%)%.,<>~=#:;{}%[%]])",
	[7]  = "(//[^\n]*)",
	[8]  = "(/%*.-%*/)",
	[9]  = "(%-%-[^%[][^\n]*)",
	[10] = "(%-%-%[%[.-%]%])",
	[11] = "(%[%[.-%]%])",
	[12] = "('.-')",
	[13] = "(!+)",
}

syntax.colors = {
	Color(255, 255, 255),
	Color(127, 159, 191),
	Color(223, 223, 223),
	Color(191, 127, 127),
	Color(127, 191, 127),
	Color(191, 191, 159),
	Color(159, 159, 159),
	Color(159, 159, 159),
	Color(159, 159, 159),
	Color(159, 159, 159),
	Color(191, 159, 127),
	Color(191, 127, 127),
	Color(255,   0,   0),
}

syntax.keywords = {
	["local"]    = true,
	["function"] = true,
	["return"]   = true,
	["break"]    = true,
	["continue"] = true,
	["end"]      = true,
	["if"]       = true,
	["not"]      = true,
	["while"]    = true,
	["for"]      = true,
	["repeat"]   = true,
	["until"]    = true,
	["do"]       = true,
	["then"]     = true,
	["true"]     = true,
	["false"]    = true,
	["nil"]      = true,
	["in"]       = true
}

function syntax.process(code)
	local output, finds, types, a, b, c = {}, {}, {}, 0, 0, 0

	while true do
		local temp = {}

		for k, v in pairs(syntax.patterns) do
			local aa, bb = code:find(v, b + 1)
			if aa then
				table.insert(temp, {k, aa, bb})
			end
		end

		if #temp == 0 then break end
		table.sort(temp, function(a, b) return (a[2] == b[2]) and (a[3] > b[3]) or (a[2] < b[2]) end)
		c, a, b = unpack(temp[1])

		table.insert(finds, a)
		table.insert(finds, b)

		table.insert(types, c == 2 and (syntax.keywords[code:sub(a, b)] and 2 or 3) or c)
	end

	for i = 1, #finds - 1 do
		local asdf = (i - 1) % 2
		local sub = code:sub(finds[i + 0] + asdf, finds[i + 1] - asdf)

		table.insert(output, asdf == 0 and syntax.colors[types[1 + (i - 1) / 2]] or Color(0, 0, 0, 255))
		table.insert(output, (asdf == 1 and sub:find("^%s+$")) and sub:gsub("%s", " ") or sub)
	end

	return output
end

local methods = {
	["l"]      = "server",
	["lb"]	   = "both",
	["lc"]     = "clients",
	["lm"]     = "self",
	["ls"]     = "shared",
	["print"]  = "print",
	["printb"] = "both",
	["printc"] = "clients",
	["printm"] = "self",
	["table"]  = "table",
	["table2"] = "table2",
	["keys"]   = "keys",
	["src"]    = "source"
}

local col_server = Color(191, 159, 127)
local col_client = Color(127, 191, 191)
local col_source = Color(207, 110, 90)

local colors = {
	["l"]      = col_server,
	["lc"]     = col_client,
	["print"]  = col_server,
	["printc"] = col_client,
	["table"]  = col_server,
	["table2"] = col_server,
	["keys"]   = col_server,
	["src"]    = col_source
}

local grey = Color(191, 191, 191)

hook.Add("OnPlayerChat", "syntax", function(player, message, team, dead)
--	if not player:IsSuperAdmin() then return end
	local method, color, silent -- for overrides
	local cmd, code = message:match("^!(l[bcms]?) (.*)$")

	if not code then cmd, code = message:match("^!(print[bcm]?) (.*)$") end
	if not code then cmd, code = message:match("^!(table2?) (.*)$") end
	if not code then cmd, code = message:match("^!(keys) (.*)$") end
	--- TODO: implement it on serverside
	-- if not code then cmd, code = message:match("^@(l[bcms]?) (.*)$") if code then silent=true end end
	if not code then cmd, code = message:match("^!(src) (.*)$") end
	
	if not code then
	
		method, code = message:match("^!lsc ([^,]-) (.*)$")
		color = colors["lc"]
		method = easylua.FindEntity(method)
		method = IsValid(method) and method:Nick() or tostring(method)

	end
	
	if not code then return end

	if not silent then
		chat.AddText(player, grey, "@", color or colors[cmd] or "", method or methods[cmd], grey, ": ", unpack(syntax.process(code)))
	end

	return true
end)

end)