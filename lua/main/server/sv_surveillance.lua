local nTag = "__surveillance"
util.AddNetworkString(nTag)

net.Receive(nTag, function(_, ply)
               if not ply[nTag] then
                 timer.Simple(1, function() hook.Run("iin_ScoreboardInfo", ply) end)
               end
               ply[nTag] = net.ReadTable()
               Msg("SBU >") print("got update from", ply)
end)

local function FullUpdate()
   net.Start(nTag)
   net.Broadcast()
end

timer.Create(nTag, 5 * 60, 0, function()
                Msg("SBU >") print("requesting full update.")
                FullUpdate()
end)

hook.Add("PlayerInitialSpawn", nTag, function(ply)
    net.Start(nTag)
    net.Send(ply)
end)

FullUpdate()
