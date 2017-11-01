function uploadluafile(code)
	if not LocalPlayer():IsUserGroup'devs' then return end
	local v = vgui.Create'DFrame'
	v:SetSize(250,60)
	v:Center()
	v:MakePopup()
	v:ShowCloseButton(false)
	v:SetTitle('')
	v.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(200,200,200))
		draw.SimpleText("addons/fast_addons/uploads/","DermaDefault",5,17+3-16,Color(0,0,0),0,0)
	end
	
	local x = v:Add'DButton'
	x:SetText'r'
	x:SetPos(250-20,0)
	x:SetSize(20,20)
	x:SetFont'Marlett'
	x.Paint = function(s,w,h) draw.SimpleTextOutlined('r', 'marlett', w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, color_black) end
	x.DoClick = function() v:Remove() end
	
	local srv = v:Add( "DComboBox" )
	srv:SetPos( 0, 15+3 )
	srv:SetSize( 60, 20 )
	srv:SetValue( "" )
	srv:AddChoice( "server/" )
	srv:AddChoice( "client/" )
	srv:AddChoice( "" )
	
	local lu = vgui.Create( "DTextEntry",v)
	lu:SetPos( 60, 15+3 )
	lu:SetSize( 175, 20 )
	lu:SetText( "default.lua" )
	lu.OnEnter = function( self )
		chat.AddText( srv:GetValue()..self:GetValue() )
	end
	lu:RequestFocus()
	
	local x = v:Add'DButton'
	local b = 'a'
	x:SetText('write')
	x:SetPos(250/2-25,60-20)
	x:SetSize(50,16)
	//x:SetFont'Marlett'
	x.Paint = function(s,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(255,255,255))
		draw.SimpleTextOutlined(b, 'marlett', w-10, h/2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, color_black)
	end
	x.DoClick = function()
		net.Start'cppUploadFile'
		net.WriteString(srv:GetValue()..lu:GetValue())
		net.WriteString(code)
		net.SendToServer()
		v:Remove()
	end
end