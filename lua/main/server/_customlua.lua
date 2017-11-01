util.AddNetworkString'cppUploadFile'

net.Receive('cppUploadFile',function(len,ply)
	if (ply:IsUserGroup'devs') then
		local filename = net.ReadString()
		local code = net.ReadString()
		if filename:Left(4)~="kuda" then
			Msg'[UploadLua] 'print('uploading',filename)
			if not cpp then require'wbcpp1337' end
			cpp.UploadLua(filename,code)
			Msg("\t∟")
			if file.Exists('uploads/'..filename,"LUA") then
				MsgC(Color(0,255,0),'Success\n')
			else
				MsgC(Color(255,0,0),'Error\n')
			end

		end
	end
end)