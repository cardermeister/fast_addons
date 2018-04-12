local nTag = "__surveillance"
util.AddNetworkString(nTag)

net.Receive(nTag, function(_, ply)
               ply[nTag] = net.ReadTable()
               Msg("SBU >") print("got update from", ply)
end)

local function FullUpdate()
   net.Start(nTag)
   net.Broadcast()
end

timer.Create(nTag, 120, 0, function()
                Msg("SBU >") print("requesting full update.")
                FullUpdate()
end)

FullUpdate()
