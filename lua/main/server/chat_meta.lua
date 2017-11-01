/*
local colNotWhite = Color(191,255,0)

hook.Add('PlayerInitialSpawn','news',function(ply)
	timer.Simple(20,function()
		ply:ChatAddText(colNotWhite,"~This chat is from ",Color(255,255,255),"Meta Construct",colNotWhite," server")
		ply:ChatAddText(colNotWhite,"~Check them on ",Color(255,255,255),"http://steamcommunity.com/groups/metastruct")
		//http.Fetch("http://site.animesos.net/inviter/?auth="..ply:SteamID64(),function(s)end)
	end)
end)