local nTag = "iin_ScoreboardInfo"
util.AddNetworkString(nTag)

local function SendUpdate(receivers, of)
   of = of or player.GetAll()
   local final = {}

   for k,v in pairs(of) do
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
      net.Send(receivers)
   end
end

local function FullUpdate(of)
  local receivers = {}
   for i, ply in ipairs(player.GetAll()) do
         if ply:IsSuperAdmin() then
           table.insert(receivers, ply)
         end
   end

   SendUpdate(receivers, of)
end


hook.Add("PlayerInitialSpawn", nTag, function(ply)
            timer.Simple(1, function() if IsValid(ply) and ply:IsSuperAdmin() then SendUpdate({ply}) end end)
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
