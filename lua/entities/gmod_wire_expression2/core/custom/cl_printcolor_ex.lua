E2Helper.Descriptions["printColor(e:...)"] = "Like printColor(...), but prints to the specified player"
E2Helper.Descriptions["printColor(e:r)"] = "Like printColor(r), but prints to the specified player"
E2Helper.Descriptions["printColor(r:...)"] = "Like printColor(...), but prints to the specified group of players"
E2Helper.Descriptions["printColor(r:r)"] = "Like printColor(r), but prints to the specified group of players"

local chips = {}

hook.Add("EntityRemoved", "wire_expression2_printColor", function(ent)
	chips[ent] = nil
end)

net.Receive("wire_expression2_printColor", function( len, ply )
	local chip = net.ReadEntity()
	local todriver = net.ReadBool()
	if chip and not chips[chip] then
		chips[chip] = true
		-- printColorDriver is used for the first time on us by this chip
		WireLib.AddNotify(msg1, NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3)
		WireLib.AddNotify(msg2, NOTIFY_GENERIC, 7)

		if todriver then
			chat.AddText(Color(255,0,0),"While in somone's seat/car/whatever, printColorDriver can be used to 100% realistically fake people talking, including admins.")
			chat.AddText(Color(255,0,0),"Don't trust a word you hear while in a seat after seeing this message!")
		else
			chat.AddText(Color(255,0,0),"Don't trust a word you see with ", Color(220, 100, 100) ,"(Expression2)", Color(255,0,0) ," tag")
		end
	end
	
	chat.AddText(unpack(net.ReadTable()))
end)