net.Receive("discord.msg", function()
	local username = net.ReadString()
	local clr = net.ReadColor()
	local msg = net.ReadString()

	chat.AddText(Color(161,161,255), "> ", clr, username, color_white, ": ", msg)

	local url = urlimg.get_image_link(msg)

	if url then
		urlimg.queue_image(url, clr, username)
	end
end)
