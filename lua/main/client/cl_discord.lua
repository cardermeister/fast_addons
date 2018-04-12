net.Receive("discord.img", function()
	local username = net.ReadString()
	local clr = net.ReadColor()
	local url = net.ReadString()

	chathud.queue_image(url, clr, username)
end)
