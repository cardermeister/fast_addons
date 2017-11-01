local last_votekick

iin.AddCommand('votekick',function(ply,line,name,reason)
	
	if last_votekick and CurTime()-last_votekick<120 then return end
	
	name = easylua.FindEntity(name)
	
	reason = reason or "Minge!"
	
	if name and name:IsPlayer() then
		GVote.Vote("Kick "..name:GetName().."? ("..reason..")","yes","noo!",function(p)
			if #p["yes"] > #p["noo!"] then
				name:Kick(reason)
			end
		end)	
		last_votekick = CurTime()
	end

end)