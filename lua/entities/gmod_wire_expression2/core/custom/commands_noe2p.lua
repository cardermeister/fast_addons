__e2setcost(10)

e2function array entity:geoIP()
	if !IsValid(this) then return {} end
	if !this:IsPlayer() then return {} end
	local ret = this:GeoIP()
	if not ret then return {} end
	if type(ret)=="table" then return ret else return {} end
end