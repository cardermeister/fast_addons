--
-- collision02
--

function bugat(pos)
   local proj = ents.Create("npc_grenade_bugbait")

   assert(IsValid(proj))

   proj:SetPos(pos)
   proj:Spawn()

   return proj
end

function bugply(ply)
   local xOffset, yOffset, zOffset = math.random(-150, 150), math.random(-150, 150), math.random(40, 200)
   local pos = ply:GetPos() + Vector(xOffset, yOffset, zOffset)
   local proj = bugat(pos)
   proj:SetAngles(proj:GetAngles() - ply:GetAngles())
   proj:SetVelocity((ply:GetPos() - pos + Vector(0, 0, 73)) * 2.5)


   local startSize, endSize = 5, 20
   local trailMaterial = "trails/smoke.vmt"
   local trail_entity = util.SpriteTrail(proj, 0, Color(89, 48, 1), false, startSize, endSize, 2, 1 / ((startSize + endSize) * 0.5), trailMaterial)
   ent.SToolTrail = trail_entity


   proj:SetModelScale(1.5)
   return proj
end

BUGBAIT_COOLDOWN = 2
bugged = bugged or {}

hook.Add("Think", "bugbait", function()
            for k,v in pairs(player.GetAll()) do
               if bugged[v] then
                  local cd = v["bugbaitCooldown"] or 0
                  local bugEnts = v["bugbaitProj"] or {}
                  local proj
                  if CurTime() >= cd then
                     proj = bugply(v)
                     v.bugbaitCooldown = CurTime() + BUGBAIT_COOLDOWN
                  end

                  for _, plyEnt in pairs(bugEnts) do
                     if IsValid(plyEnt) then
                        plyEnt:SetVelocity((v:GetPos() - plyEnt:GetPos() + Vector(0, 0, 73)) * 2.5)
                     else
                        table.remove(bugEnts, _)
                     end
                  end
                  table.insert(bugEnts, proj)
                  v["bugbaitProj"] = bugEnts

               end
            end
end)
