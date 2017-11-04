function string.gitify(json)

	json = util.JSONToTable(json).payload.commits
	
	for i,k in pairs(json) do
		
		ChatAddText(Color(117, 113, 94),"[fast_addons:master]",color_white," Commit from ",Color(255,140,113),k.author.name,color_white,"\n\t♢ ",k.message)
		
		if (#k.added>0) then local buff = {color_white,"\t┕ ",Color(0,255,0),"Added: ",color_white} for j,v in pairs(k.added) do table.insert(buff,v) end ChatAddText(unpack(buff))  end
		if (#k.modified>0) then buff = {color_white,"\t┕ ",Color(255,191,0),"Modified: ",color_white} for j,v in pairs(k.modified) do table.insert(buff,v) end ChatAddText(unpack(buff))  end
		if (#k.removed>0) then buff = {color_white,"\t┕ ",Color(255,0,0),"Removed: ",color_white} for j,v in pairs(k.removed) do table.insert(buff,v) end ChatAddText(unpack(buff))  end
		ChatAddText("")
	
	end
		
	
end