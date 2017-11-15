local function func(repo_name,k,commit_add)
	
	local message = k.message:gsub("\n"," ")
	
	
	ChatAddText(Color(117, 113, 94),"["+repo_name+":master]",color_white," Commit from ",Color(255,140,113),k.author.name,color_white,"\n\t♢ ",message)
	
	if (#k.added>0) then local buff = {color_white,"\t┕ ",Color(0,255,0),"Added: ",color_white} for j,v in pairs(k.added) do local zap = "" if(j>1)then zap=", " end table.insert(buff,zap..v) end ChatAddText(unpack(buff))  end
	if (#k.modified>0) then buff = {color_white,"\t┕ ",Color(255,191,0),"Modified: ",color_white} for j,v in pairs(k.modified) do local zap = "" if(j>1)then zap=", " end table.insert(buff,zap..v) end ChatAddText(unpack(buff))  end
	if (#k.removed>0) then buff = {color_white,"\t┕ ",Color(255,0,0),"Removed: ",color_white} for j,v in pairs(k.removed) do local zap = "" if(j>1)then zap=", " end table.insert(buff,zap..v) end ChatAddText(unpack(buff))  end

	if istable(commit_add) then
		ChatAddText("Total: ",Color(0,255,0),commit_add.stats.additions," additions",color_white," and ",Color(255,0,0),commit_add.stats.deletions," deletions",color_white,".")
	end

	ChatAddText("")
	
end

local function gitify(json)

	json = util.JSONToTable(json).payload
	local repo_name = json.repository.name
	local projectid = json.project_id
	json = json.commits
	
	for i,k in pairs(json) do
		
		local sha = k.id
		
		http.Fetch(("https://gitlab.com/api/v4/projects/%s/repository/commits/%s"):format(projectid,sha),
		function(a)
			func(repo_name,k,util.JSONToTable(a))
		end,function(s)
		func(repo_name,k)
		end,{["Private-Token"]="9BtwmHamzRwiLdsijELR"})
		
	end
	
	
end

concommand.Add("echo_git_commit",function()
	gitify(file.Read('git.json','DATA'))
end)
