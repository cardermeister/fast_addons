local function urlencode(str) return string.gsub (string.gsub (string.gsub (str, "\n", "\r\n"), "([^%w ])",function (c) return string.format ("%%%02X", string.byte(c)) end), " ", "+") end
local function AddTextSS(ply,txt)
	ChatAddText(team.GetColor(ply:Team()),ply:GetName(),Color(255,255,255),": ",txt)	
end

hook.Add("PlayerSay","tes",function(ply,txt,chota)
 if ply.RuHax then
	http.Fetch("http://speller.yandex.net/services/spellservice.json/checkText?options=2068&text="..urlencode(txt),function(s)
                local json = util.JSONToTable(s)
               
                if not json or #json==0 then
                        AddTextSS (ply,txt)
                        return
                end
               
                for i,k in pairs(json) do
                        if (#k["s"]) == 0 then continue end
                        txt = string.gsub(txt,k["word"],k["s"][1])
                end
               
                AddTextSS (ply,txt)
               
		end)
	return ""
end
end)