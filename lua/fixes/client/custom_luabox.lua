chatgui = {}
function ShowLuabox()
	if IsValid(luabox) then
		luabox:Show()
	--	luabox:Remove()
	--end
	else
		luabox = vgui.Create'DFrame'
		luabox:SetSize(800,500)
		luabox:SetSizable(true)
		luabox:SetTitle'Luabox GUI'
		luabox:MakePopup()
		luabox.btnClose:Hide()
		luabox.btnMaxim:Hide()
		luabox.btnMinim:Hide()
		luabox:Center()
		
		
		local BClose = vgui.Create("DButton", luabox)
		
		BClose:SetSize(42, 16)
		
		BClose.Paint = function(self, w, h)
			
			local bg = (self.Depressed and Color(128, 32, 32)) or (self:IsHovered() and Color(255, 0, 0)) or Color(255, 64, 64)

			draw.RoundedBoxEx(4, 0, 0, w, h, bg, false, false, true, true)
			draw.SimpleTextOutlined("r", "marlett", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
			return true
		end
		BClose.DoClick = function()
			RememberCursorPosition()
			luabox:Hide()
		end
		BClose.PerformLayout = function(BClose, w, h)
			
			BClose:SetPos(luabox:GetWide() - BClose:GetWide() - 4, 0)
			
			return true
		end
		
		local _lua = luabox:Add('chatbox_lua')
		chatgui.Lua = _lua
		_lua:SetPos(0,25)
		_lua:SetSize(luabox:GetWide()-1,luabox:GetTall()-30)
		
		_lua.PerformLayout_over = function(self)
			_lua:SetSize(luabox:GetWide()-1,luabox:GetTall()-30)
		end
		
		
		luabox.Paint = function(s,w,h)
			draw.RoundedBox(1,0,0,w,h,Color(0,193,63))
			
			if input.IsKeyDown(KEY_ESCAPE) then
				s:Hide()
				
				if gui and gui.HideGameUI then
					timer.Simple(0,gui.HideGameUI)
				end
				
			end
			
			if s.Sizing then
				if IsValid(_lua) and IsValid(BClose) then
					BClose:PerformLayout()
					_lua.PerformLayout_over()
				end	
			end
		end
		
	end
	
end


