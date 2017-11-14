/// E2Power Control Menu
/// Made by SkyAngeLoL
/// 
if SERVER then return end
///
local BackColor=Color(0,170,255,255)
/// Don't Change this font! it my font lib !
surface.CreateFont("SkyDermaArial_I_17",{
	font="Arial",
	size=17,
	weight=1000,
	antialias=true,
	italic=true,
})
///
function GetPlyAccess(ply)
	if not ply:IsValid() then return end
	return ply:GetNWBool("E2PowerAccess",false)
end
///
local function E2Power_BuildPanel(Panel)
	Panel:ClearControls()
	//
	if not LocalPlayer():IsSuperAdmin() then
		Panel.NonAdminText=vgui.Create("DLabel")
		Panel.NonAdminText:SetColor(BackColor)
		Panel.NonAdminText:SetFont("SkyDermaArial_I_17")
		Panel.NonAdminText:SetText("You're not admin :C")
		Panel.NonAdminText:SizeToContents()
	Panel:AddItem(Panel.NonAdminText)
		return
	end
	////////////////////
	/// Player panel
	Panel.PlayerText=vgui.Create("DLabel")
		Panel.PlayerText:SetColor(BackColor)
		Panel.PlayerText:SetFont("SkyDermaArial_I_17")
		Panel.PlayerText:SetText("Click on line and chose an option")
		Panel.PlayerText:SizeToContents()
	Panel:AddItem(Panel.PlayerText)
	//
	Panel.PlayerPanel=vgui.Create('DPanelList')
		Panel.PlayerPanel:SetPadding(1)
		Panel.PlayerPanel:SetSpacing(1)
		Panel.PlayerPanel:SetAutoSize(true)
		Panel.PlayerPanel.Paint=function()
			draw.RoundedBox(0,0,0,Panel.PlayerPanel:GetWide(),Panel.PlayerPanel:GetTall(),BackColor)
		end
	Panel:AddItem(Panel.PlayerPanel)
	//
	Panel.PlyList=vgui.Create('DListView')
		Panel.PlyList:SetSize(100,150)
		Panel.PlyList:AddColumn("EntIndex")
		Panel.PlyList:AddColumn("Nick")
		Panel.PlyList:AddColumn("Access"):SetFixedWidth(60)
		Panel.PlyList:SetMultiSelect(false)
		Panel.PlyList.LoadPlyList=function(self)
			Panel.PlyList:Clear()
			for _,ply in pairs(player.GetAll()) do
				Panel.PlyList:AddLine(ply:EntIndex(),ply:Nick(),tostring(GetPlyAccess(ply)))
			end
		end
		Panel.PlyList.OnClickLine=function(parent,line,isselected)
			local Pl=line:GetValue(1)
			local Stat=tobool(line:GetValue(3))
			local ContMenu=DermaMenu()
				if not Stat then
					ContMenu:AddOption("Give Access",function()  
						LocalPlayer():ConCommand('l33t give_e2power '..Pl)
						timer.Simple(0.2,function() Panel.PlyList.LoadPlyList() end)
					end)
				else
					ContMenu:AddOption("Remove Access",function()  
						LocalPlayer():ConCommand('l33t take_e2power '..Pl)
						timer.Simple(0.2,function() Panel.PlyList.LoadPlyList() end)
					end)
				end
			ContMenu:Open()
		end
	Panel.PlyList.LoadPlyList()
	Panel.PlayerPanel:AddItem(Panel.PlyList)
	//
	Panel.RemoveAllBut=vgui.Create("DButton")
		Panel.RemoveAllBut:SetText("Remove access for all players")
		Panel.RemoveAllBut:SetSize(200,18)
		Panel.RemoveAllBut.DoClick=function()
			RunConsoleCommand('e2power_all_remove_access')
			timer.Simple(0.2,function() Panel.PlyList.LoadPlyList() end)
		end
	Panel.PlayerPanel:AddItem(Panel.RemoveAllBut)
	/////////////////////
	/// Version and Logo
	local E2PVersion=GetGlobalString("E2PowerVersion")
	Panel.VersionText=vgui.Create("DLabel")
		Panel.VersionText:SetColor(BackColor)
		Panel.VersionText:SetFont("SkyDermaArial_I_17")
		Panel.VersionText:SetText("E2Power version: "..E2PVersion)
		Panel.VersionText:SizeToContents()
	Panel:AddItem(Panel.VersionText)
	//
	Panel.LogoPanel=vgui.Create('DPanelList')
		Panel.LogoPanel:SetNoSizing(true)
		Panel.LogoPanel:SetAutoSize(true)
		Panel.LogoPanel.Paint=nil
	Panel:AddItem(Panel.LogoPanel)
	//
	Panel.Logo=vgui.Create('DPanel')
		Panel.Logo:SetSize(250,250)
		Panel.Logo.Paint=function()
			surface.SetTexture(surface.GetTextureID("expression 2/cog"))
			surface.SetDrawColor(BackColor)
			surface.DrawTexturedRectRotated(Panel.Logo:GetWide()/2,Panel.Logo:GetTall()/2,Panel.Logo:GetWide()-2,Panel.Logo:GetTall()-2,RealTime()*20)
		end
	Panel.LogoPanel:AddItem(Panel.Logo)
	//
	local CrosLine=vgui.Create('DPanelList')
		CrosLine:SetSize(200,2)
		CrosLine.Paint=function() draw.RoundedBox(0,0,0,CrosLine:GetWide(),CrosLine:GetTall(),BackColor) end
	Panel:AddItem(CrosLine)
	//
	Panel.VersionText=vgui.Create("DLabel")
		Panel.VersionText:SetColor(BackColor)
		Panel.VersionText:SetFont("SkyDermaArial_I_17")
		Panel.VersionText:SetText(" Menu by SkyAngeLoL\n")
		Panel.VersionText:SizeToContents()
	Panel:AddItem(Panel.VersionText)
	////////
	///////
	if !E2Power_Panel then
		E2Power_Panel=Panel
	end
end
///
function E2Power_SMO()
	if E2Power_Panel then
		E2Power_BuildPanel(E2Power_Panel)
	end
end
hook.Add("SpawnMenuOpen","E2Power_SpawnMenuOpen",E2Power_SMO)
///
hook.Add("PopulateToolMenu","E2Power_PopulateToolMenu",function()
	spawnmenu.AddToolMenuOption("Utilities","E2Power","Menu","E2Power","","",E2Power_BuildPanel)
end)