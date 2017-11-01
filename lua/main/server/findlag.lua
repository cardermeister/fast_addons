local function findlag()
	local nums = {}
	local ids = {}
	FindMetaTable("Entity").IsBlacklisted = function(ob)
		local badents = {
			"player",
			"gmod_hands",
			"physgun_beam",
			"info_null",
			"crossbow_bolt"
			}
		for i=1,table.Count(badents) do
			if ob:GetClass() == badents[i] then
				return true
			end
		end
	end

	for k,v in pairs(ents.FindByClass("*")) do
		local plyent = v:IsWeapon() or v:IsBlacklisted() == true
		local owner = (not plyent) and v:CPPIGetOwner() or nil
		local ownerprops = (not plyent) and v:GetClass() == "prop_physics" or false
		local velocity = v:GetVelocity()
		local moving = (not plyent) and velocity ~= Vector(0,0,0) or false
		if IsValid(owner) then
			if not ids[owner] then
				local id = table.insert(nums, { owner = owner, all = 1, allprops = ownerprops and 1 or 0, moving = moving and 1 or 0})
				ids[owner] = id
			else
				local id = ids[owner]
				if not plyent then nums[id].all = nums[id].all + 1 end
				if ownerprops then nums[id].allprops = nums[id].allprops + 1 end
				if moving then nums[id].moving = nums[id].moving + 1 end
			end
		end
	end
	
	table.sort(nums,function(a,b) return a.all > b.all end)
	all:ChatPrint("FindLag Report:")
	for _,v in pairs(nums) do
		all:ChatPrint("["..v.owner:EntIndex().."] '"..v.owner:Nick().."': "..v.all.." total entities, "..v.allprops.." props, "..v.moving.." moving ents")
	end
end

hook.Add("PlayerSay","findlag",function(ply,txt)
	if not ply:IsAdmin() then return end
	local cmd = string.match(string.lower(txt),"^([!/~.]findlag)")
	if cmd then timer.Simple(0,findlag) end
end)