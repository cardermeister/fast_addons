local nTag = "iin_ScoreboardInfo"
util.AddNetworkString(nTag)

local function SendUpdate(ply, who)
   who = who or player.GetAll()
   final = {}

   for k,v in pairs(who) do
      if not IsValid(v) then continue end
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

local function FullUpdate(who)
  local tab = {}
   for k,v in pairs(player.GetAll()) do
         if v:IsAdmin() then
           tab[#tab + 1] = v
         end
   end

   SendUpdate(tab, who)
end


hook.Add("PlayerInitialSpawn", nTag, function(ply)
            timer.Simple(1, function() if IsValid(ply) and ply:IsAdmin() then SendUpdate({ply}) end end)
end)

hook.Add(nTag, nTag, function(ply)
    Msg("scoreboard SBU> ") print("received first databatch from player ", ply)
    FullUpdate({ply})
end)

--[[
timer.Create(nTag, 30, 0, function()
                Msg("scoreboard SV> ") print("sending full update.")
                FullUpdate()
end)]]--

FullUpdate()
