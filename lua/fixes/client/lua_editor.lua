local PANEL = {}

PANEL.url="http://metastruct.github.io/lua_editor/index.html"
function PANEL:LoadURL()
	--<base href="http://svn.metastruct.org:20080/lua_editor/" target="_blank" />

	self.HTML:OpenURL(self.url)
	
	self.loading:SetVisible(true)

	-- magic fix
	/*timer.Simple(0.3,function()
		local dh = vgui.Create'DHTML'
		timer.Simple(2,function() dh:Remove() end)
	end)*/
	
end

AccessorFunc(PANEL,"m_bReady","Ready",FORCE_BOOL)
AccessorFunc(PANEL,"m_bSaving","Saving",FORCE_BOOL)
PANEL.Modes = {
	"lua",
	"javascript",
	"json",
	"text",
	"plain_text",
	"sql",
	"xml",
	"",
	"ada",
	"assembly_x86",
	"autohotkey",
	"batchfile",
	"c9search",
	"c_cpp",
	"csharp",
	"css",
	"diff",
	"html",
	"html_ruby",
	"ini",
	"java",
	"jsoniq",
	"jsp",
	"luapage",
	"lucene",
	"makefile",
	"markdown",
	"mysql",
	"perl",
	"pgsql",
	"php",
	"powershell",
	"properties",
	"python",
	"rhtml",
	"ruby",
	"sh",
	"snippets",
	"svg",
	"vbscript",
}

PANEL.Themes = {
"ambiance",
"chaos",
"chrome",
"clouds",
"clouds_midnight",
"cobalt",
"crimson_editor",
"dawn",
"dreamweaver",
"eclipse",
"github",
"idle_fingers",
"katzenmilch",
"kr",
"kuroir",
"merbivore",
"merbivore_soft",
"mono_industrial",
"monokai",
"pastel_on_dark",
"solarized_dark",
"solarized_light",
"terminal",
"textmate",
"tomorrow",
"tomorrow_night",
"tomorrow_night_blue",
"tomorrow_night_bright",
"tomorrow_night_eighties",
"twilight",
"vibrant_ink",
"xcode",
}

--UGH
PANEL.FontSizes = {8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28,28,29,30}

function PANEL:Init()
	self.Content = ""
	self.filename = "lua_editor_save.txt"
	self.m_bSaving = true
	local Error = vgui.Create( "DTextEntry", self )
	self.Error=Error
	Error:SetEnterAllowed(false)
	Error:SetDrawBorder(false)
	Error.AllowInput=function() return false end
	
	--Error:SetMouseInputEnabled( true )
	--Error:SetKeyboardInputEnabled( true )
	Error:Dock( BOTTOM )
	Error:DockMargin(-1,-1,-1,-1)
	
	-- hide dat stuff
	Error:SetText''
	Error:SetDrawBorder( false )
	Error:SetDrawBackground( false )
	local Paint=Error.Paint
	function Error.Paint(Error,w,h)
		local ret = Paint(Error,w,h)
		if Error:GetDrawBackground() then
			surface.SetDrawColor(255,0,0,50)
			surface.DrawRect(0,0,w,h)
		end
		return ret
	end
	
	Error:SetEditable( false )
	
	Error.can_select_time=0
	--Error:SetVisible( false )
	function Error.OnMousePressed(Error,mc)
		if Error.can_select_time>CurTime() then
			Error.can_select_time = math.huge
		end
	end

	function Error.OnMouseReleased(Error,mc)
		if mc==MOUSE_RIGHT or Error.can_select_time>CurTime() then
			Error.can_select_time = CurTime() + 1.1
			return
		end
		
		self:GoErrorLine()
		
		Error.can_select_time = CurTime() + 1.1
		
	end
	self:SetCookieName("lua_editor")
	local theme = self:GetCookie("theme")
	self.theme = theme and theme~="" and theme or "default"

	-- TODO: How to remove if the panel gets removed?
	hook.Add( "ShutDown", self,function()
		if not ValidPanel(self) or not self.HTML then return end
		self:Save()
	end )

end


function PANEL:InitRest()
	
	local loading = vgui.Create('DButton',self)
		self.loading = loading
		loading:SetText"Loading HTML | Click me to retry"
		loading:SizeToContents()
		loading:SetPos(4,1)
		loading:SetSize(loading:GetWide()+10,loading:GetTall()+5)
		loading.DoClick = function()
			self:LoadURL()
		end
		loading:SetZPos(1000)
		
	local HTML = vgui.Create( "DHTML", self )
		self.HTML = HTML
		function HTML.Paint(HTML,w,h) end

		HTML:Dock( FILL )
			
		HTML.OnKeyCodePressed=function(HTML,code)
			if code==KEY_F5 then
				local full=input.IsButtonDown(KEY_LCONTROL)
				self:ReloadPage(full)
			end
		end

		function HTML.OnFocusChanged(HTML,gained)
			--print("focus",gained)
			self:OnFocus(gained)
		end
		
		--[[
		function HTML:OnMouseReleased(...)
			print("OnMouseReleased",...)
		end
		function HTML:OnMousePressed(...)
			print("OnMousePressed",...)
		end
		function HTML:ActionSignal(...)
			print("ActionSignal",...)
		end
		function HTML:ActionSignal(...)
			print("ActionSignal",...)
		end
		
		
		local HTML_OnCallback= HTML.OnCallback
		HTML.OnCallback=function(HTML,obj,func,...)
			print("CB",obj,func)
			return HTML_OnCallback(HTML,obj,func,...)
		end--]]
		
		-- Bind shit
		local function bind(name)
			local func = self[name]
			if not func then error"???" end
			--print("ADDFUNC",name)
			HTML:AddFunction("gmodinterface", name, function(...)
				func(self,HTML,...)
			end)
		end
		
		bind "OnReady"
		bind "OnCode"
		bind "OnLog"
		bind "onmousedown"
		--bind "nop"
	
	self:InvalidateLayout()
	self.HTML:InvalidateLayout(true)
	self:LoadURL()
	self.HTML:RequestFocus()
	
	
end


function PANEL:onmousedown()
	self.mdown = true
end

function PANEL:nop()end
function PANEL:ReloadPage(full)
	local str = 'console.log("Reloading..."); location.reload('
	
	if full then str=str..'true' end
	str=str..');'
	
	self.HTML:Call(str)
	
end
function PANEL:OnLog(html,...)
	Msg"Editor: "print(...)
end

function PANEL:OnCode(html,code)
	self.__nextvalidate=RealTime()+0.2 -- now using delay on OnKeyCodePressed
	
	local tid = 'save'..tostring(self.filename)
	if not self._timercreated then
		self._timercreated = true
		timer.Create(tid,0.7,1,function()
			self._timercreated = false
			if self.Save then
				self:Save()
			end
		end)
	end
	
	self.Content = code
	self:OnCodeChanged(code)
end


function PANEL:Paint() -- hacky delayed loading..
	if self.__loaded then return end
	self.__loaded = true
	self.Paint=self._Paint
	self:InitRest()
end
function PANEL:_Paint(w,h)
	local HTML=self.HTML
	if not HTML then return end
	
	if not self:GetReady() then
		self.loading:SetTextColor(Color(100+100*math.sin(CurTime()*10),50,50,255))
	end
end

function PANEL:Think()
	local HTML=self.HTML
	if not HTML then return end

	

	if self.mdown then
		if input.IsMouseDown(MOUSE_LEFT) then
			local mrx,mry = HTML:CursorPos()
			local pw,ph=HTML:GetSize()
			if mrx<0 or mry<0 or mrx>pw or mry>ph then
				local fx,fy = math.Clamp(mrx,1,pw-1),math.Clamp(mry,1,ph-1)
				local sx,sy = HTML:LocalToScreen(fx,fy)
				-- not all the commands go through so we spam this shit
				input.SetCursorPos(sx,sy)
				gui.InternalCursorMoved(sx,sy)
				--input.InternalMouseReleased(MOUSE_LEFT)
			end
		else
			local mrx,mry = HTML:CursorPos()
			local pw,ph=HTML:GetSize()
			if mrx<0 or mry<0 or mrx>pw or mry>ph then
				local fx,fy = math.Clamp(mrx,1,pw-1),math.Clamp(mry,1,ph-1)
				local sx,sy = HTML:LocalToScreen(fx,fy)
				--print("OUT OF BOUNDS RELEASE",fx,fy,CurTime())
				input.SetCursorPos(sx,sy)
				gui.InternalCursorMoved(sx,sy) -- Takes absolute position, not delta
				gui.InternalMouseReleased(MOUSE_LEFT)
				HTML:PostMessage("MouseReleased","code",MOUSE_LEFT)
			end
			--print"mdown <- false"
			self.mdown = false
		end
	end

	if self.__nextvalidate and self.__nextvalidate<RealTime() then
		self.__nextvalidate=false
		self:ValidateCode()
	end
end

function PANEL:OnCodeChanged(code) end

function PANEL:ValidateCode()
	local prof=SysTime()
	local code=self:GetCode()
	
	if not code or code=="" then
		self:SetError(false)
		return
	end
	
	local var = CompileString(code, "lua_editor", false)
	local took=SysTime()-prof

	if type(var) == "string" then
		self:SetError(var)
	elseif took>0.25 then
		self:SetError("Compiling took "..math.Round(took*1000).." ms")
	else
		self:SetError(false)
	end
end

function PANEL:GetCode()
	return self.Content
end


local function encode(str)
	return str:gsub('\\',[[\\]]):gsub('"',[[\"]]):gsub('\r',[[\r]]):gsub('\n',[[\n]])
end

---------------------------------
function PANEL:SetCode(content)
	if not content then error("No code provided!",2) end
	if not self:GetReady() then
		self.__delayed_code = content
	end

	self.Content = content

	if not self.HTML or not self:GetReady() then return end
	local encoded = encode(content)
	local str = 'SetContent("' .. encoded .. '");'

	self.HTML:Call(str)


end

function PANEL:SetErr(line,err)

	if not self.HTML or not self:GetReady() then return end
	local encoded = encode(err)
	local str = 'SetErr('..tonumber(line)..',"' .. encoded .. '");'
	self.seterr = true
	self.HTML:Call(str)
end

function PANEL:ClearErr()
	
	self.Error:SetText ''
	self.Error:SetDrawBorder( false )
	self.Error:SetDrawBackground( false )
	self.Error:SetEditable( false )

	if not self.seterr or not self.HTML or not self:GetReady() then return end
	self.seterr = false
	self.HTML:Call 'ClearErr();'
end

function PANEL:OnReady()
	if self.loading:IsVisible() then
		self.loading:SetVisible(false)
	end
	
	self:SetReady(true)
	if self.__delayed_code then
		self:SetCode(self.__delayed_code)
		self.__delayed_code=nil
	else
		self:Load()
	end
	
	self:SetTheme( self.theme )
	if self.font_size then
		self:SetFontSize( self.font_size )
	end
	
	self.HTML:Call[[
		document.body.onmousedown = function(evt) {
		  if (evt.button==0 || evt.button==1) {
			gmodinterface.onmousedown(evt.button);
		  };
		}
	]]
	
	self:OnLoaded()

	self:InvalidateLayout()
	--self:TellParentAboutSizeChanges()
	self.HTML:InvalidateLayout()
	self:GetParent():InvalidateLayout()
	--self.HTML:TellParentAboutSizeChanges()
	
	
end

function PANEL:OnFocus(gained) end
function PANEL:OnLoaded() end

function PANEL:SetTheme( theme )
	if table.HasValue(self.Themes,theme) then
		self.theme = theme
		self:SetCookie("theme",theme)
		if not self:GetReady() then return true end
		if not self.HTML then return false end
		self.HTML:Call("SetTheme(\"" .. theme .. "\")") -- Add escaping if necessary..
		return true
	end
	return false
end

function PANEL:SetFontSize( font_size )
	font_size=tonumber(font_size)
	if not font_size then return false end
	self.font_size = font_size
	self:SetCookie("font_size",font_size)
	if not self:GetReady() then return true end
	if not self.HTML then return false end
	self.HTML:Call("SetFontSize(" .. font_size .. ")")
	return true
end


function PANEL:ShowBinds(  )
	self.HTML:Call("ShowBinds()")
end
function PANEL:ShowMenu(  )
	self.HTML:Call("ShowMenu()")
end

function PANEL:SetMode( mode )
	if table.HasValue(self.Modes,mode) then
		self.mode = mode
		if not self:GetReady() then return true end
		if not self.HTML then return false end
		self.HTML:Call("SetMode(\"" .. mode .. "\")") -- Add escaping if necessary..
		return true
	end
	return false
end


function PANEL:GoErrorLine(errorline,nofocus)
	errorline = errorline or self.errorline
	errorline = tonumber(errorline)
	
	if not self.HTML or not errorline then return false end
	local str=("GotoLine(%d);"):format(errorline)
	self.HTML:Call(str)
	if not nofocus then
		self.HTML:RequestFocus()
	end
end

function PANEL:SetError( err )
	if err then
		if not self.Error:IsVisible() then
			--self.Error:SetVisible( true )
			--self:InvalidateLayout()
		end
		local matchage, txt=err:match("^lua_editor%:(%d+)%:(.*)")
		
		local text = matchage and txt and ('Line '..matchage..':'..txt) or err or ""
		
		text=text:gsub("\r","\\r"):gsub("\n","\\n")
		
		self.Error:SetText( text )
		self.Error:SetDrawBorder( true )
		self.Error:SetDrawBackground( true )
		self.Error:SetEditable( true )
			
		local match=err:match(" at line (%d)%)") or matchage
		self.errorline=match and tonumber(match) or 1
		self:SetErr(self.errorline,err)
	else
		self.errorline=0
		self:ClearErr()
	end
	
	
end


function PANEL:Save( )
	if self:GetReady() then
		local code=self:GetCode()
		self:Store( code )
	end
end

function PANEL:Store( code )
	if code and code:len()>=1 and true then
		file.Write(self.filename,code)
		return true
	elseif file.Exists(self.filename, "DATA") then
		file.Delete(self.filename)
		return false
	end
	return false

end

function PANEL:Load()

	local data = file.Read(self.filename)
	if data and #data>0 then
		self:SetCode( data )
	end
end

vgui.Register("lua_editor", PANEL, "EditablePanel")
