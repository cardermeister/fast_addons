local PLAYER = FindMetaTable("Player")
__OLDGEOIP = __OLDGEOIP or PLAYER.GeoIP
__GEOIPCACHE = __GEOIPCACHE or {}

PLAYER.GeoIP = function (self)
   local ip = self:IPAddress():split(":")[1]
   if not __GEOIPCACHE[ip] then
      __GEOIPCACHE[ip] = __OLDGEOIP(self)
      return {error=true}
   end

   return __GEOIPCACHE[ip]
end
