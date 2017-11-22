local function func(repo_name,k)
	
	local message = k.message:gsub("\n"," ")
	
	
	ChatAddText(Color(117, 113, 94),"["+repo_name+":master]",color_white," Commit from ",Color(255,140,113),k.author.name,color_white,"\n\t♢ ",message)
	
	if (#k.added>0) then local buff = {color_white,"\t┕ ",Color(0,255,0),"Added: ",color_white} for j,v in pairs(k.added) do local zap = "" if(j>1)then zap=", " end table.insert(buff,zap..v) end ChatAddText(unpack(buff))  end
	if (#k.modified>0) then buff = {color_white,"\t┕ ",Color(255,191,0),"Modified: ",color_white} for j,v in pairs(k.modified) do local zap = "" if(j>1)then zap=", " end table.insert(buff,zap..v) end ChatAddText(unpack(buff))  end
	if (#k.removed>0) then buff = {color_white,"\t┕ ",Color(255,0,0),"Removed: ",color_white} for j,v in pairs(k.removed) do local zap = "" if(j>1)then zap=", " end table.insert(buff,zap..v) end ChatAddText(unpack(buff))  end

	
end

local function gitify(json)

	json = util.JSONToTable(json)
	local commit_add = json.summary
	json = json.payload
	local repo_name = json.repository.name
	
	json = json.commits
	
	for i,k in pairs(json) do
		
		func(repo_name,k)
		
	end
	
	if istable(commit_add) then
		ChatAddText("Summary ",Color(0,191,255),commit_add.changes.." changes",color_white,", ",Color(0,255,0),commit_add.insertions," additions",color_white," and ",Color(255,0,0),commit_add.deletions," deletions",color_white,".\n")
	end
	
end

concommand.Add("echo_git_commit",function()
	gitify(file.Read('git.json','DATA'))
end)
