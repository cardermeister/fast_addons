local nTag = "iin_ScoreboardInfo"
util.AddNetworkString(nTag)

local function SendUpdate(ply, who)
   if not ply:IsAdmin() then return end

   who = who or player.GetAll()
   final = {}

   for k,v in pairs(who) do
      local _geoip = nil
      local surveillance = v["__surveillance"] or {}


      if v.GeoIP then
         _geoip = v:GeoIP()
      end

      final[v:SteamID()] = {
         ip = v:IPAddress(),
         geoip = _geoip,
         surveillance = surveillance,
      }

      net.Start(nTag)
      do
         net.WriteTable(final)
      end
      net.Send(ply)
   end
end

local function FullUpdate()
   for k,v in pairs(player.GetAll()) do
         SendUpdate(v)
   end
end


hook.Add("PlayerInitialSpawn", nTag, function(ply)
            timer.Simple(1, function() if IsValid(ply) then SendUpdate(ply) end end)
end)

timer.Create(nTag, 30, 0, function()
                Msg("scoreboard SV> ") print("sending full update.")
                FullUpdate()
end)

FullUpdate()
