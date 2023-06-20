local me = LocalPlayer()

local PANEL = {}

function PANEL:Init()
    self:SetDraggable(false)
    self:SetTitle("")
    self:DockPadding(0,0,0,0)
    self:ShowCloseButton(false)
    self:CreateTitle()
    self:CreateBody()
    self:PopulatePlayers()
end

function PANEL:CreateTitle()
    self.titleBar = self:Add("DPanel")
    self.titleBar:Dock(TOP)
    self.titleBar.Paint = function(me,w,h)
        draw.SimpleText(MSBoard.Title, "MSBoard_36", w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self:CreateSubTitle()
end 

function PANEL:CreateSubTitle()
    self.subTitle = self:Add("DPanel")
    self.subTitle:Dock(TOP)
    self.subTitle.Paint = nil
    self.subTitleLabels = {}
    for k,v in pairs(MSBoard.SubTitle) do
        local label = self.subTitle:Add("DLabel")
        label:Dock(LEFT)
        label:SetFont("MSBoard_24")
        label:SetText(v.title .. " " ..v.getText())
        label:SetContentAlignment(5)
        self.subTitleLabels[label] = true
    end
end

function PANEL:CreateBody()
    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    local yPad = MSBoard.Padding.y
    self.scroll:DockMargin(0,0,0, yPad)
    local theme = MSBoard.Theme
    local barClr = theme.panel
    local bar = self.scroll:GetVBar()

    local buttH = 0
    function bar.btnUp:Paint( w, h )
        buttH = h
    end

    function bar:Paint( w, h )
        draw.RoundedBox( 8, w / 2 - w / 2, buttH, w / 2, h - buttH * 2, barClr )
    end

    function bar.btnDown:Paint( w, h )

    end
    function bar.btnGrip:Paint( w, h )
        draw.RoundedBox( 8, w / 2 - w / 2, 0, w / 2, h , theme.theme )
    end

end


function PANEL:PopulatePlayers()
    self.playerPanels = {}
    local sortedPlayers = player.GetAll()
    table.sort(sortedPlayers, function(a,b)
        return a:Team() > b:Team()
    end)
    local xPad, yPad = MSBoard.Padding.x, MSBoard.Padding.y
    for k,ply in pairs(sortedPlayers) do
        local playerPanel = self.scroll:Add("ScoreboardPlayer")
        playerPanel:Dock(TOP)
        playerPanel:SetPlayer(ply)
        playerPanel:DockMargin(xPad, yPad, xPad, 0)
        local but = vgui.Create("DButton", playerPanel)
        but:SetText("")
        but:Dock( FILL )
        but:SetWide(playerPanel:GetWide())
        but:SetTall(playerPanel:GetTall())
        but.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,0))
        end
        but.DoClick = function(self)
            file.CreateDir("board/banners")
            file.CreateDir("board/avatars")
            local x, y = gui.MousePos()
            if IsValid(MSBoard.fr) then MSBoard.fr:Remove() return end
            MSBoard = MSBoard or {}
            MSBoard.fr = vgui.Create("DPanel")
            MSBoard.fr:MakePopup()
            MSBoard.fr:SetPos(x-10, y-10)
            MSBoard.fr:SetSize(310, 390)
            local url = ply:IsBot() and 'https://i.imgur.com/gaoHKlq.jpg' or ply:GetNWString("ply_MS_banner")
            local pattern = "^https?://i%.imgur%.com/(%w+)%.%w+$"
            local id = string.match(url, pattern)
            local mat
            print(url)
            print(id)
            http.DownloadMaterial(url, ply:IsBot() and 'bot.png' or id .. '.png', function(m)
                mat = m
                print(url)
                print(id)
                print(mat)
                print(ply:IsBot() and 'bot.png' or id .. '.png')
            end)
            MSBoard.fr.Paint = function(self,w,h)
                draw.RoundedBox(10, 0, 0, w, h, Color(47, 49, 54))
                draw.RoundedBox(10, 4.5, 4.5, w-9, h-9, Color(54, 57, 63))
                if mat ~= nil then
                    surface.SetMaterial(mat)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawTexturedRect(4.5, 4.5, w-9, 107)
                end
                draw.RoundedBox(100, 9, 64, 75, 75, Color(54,57,63))
                draw.RoundedBox(10, 9, 139, w-18, h-139-9, Color(47,49,54))
                draw.SimpleText(ply:Name(), "MSBoard_20", 9 + 9, 139 + 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(ply:Name() .. "#0001", "MSBoard_16", 9 + 9, 139 + 20 + 2 + 16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(ply:GetNWString("ply_MS_status"), "MSBoard_16", 9 + 9, 139 + 20 + 5 + 16 + 5 + 16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                surface.SetDrawColor(200, 200, 200, 200)
                surface.DrawOutlinedRect(9 + 9, 139 + 20 + 5 + 16 + 10 + 16 + 10, w-36, 1)
                draw.SimpleText("About me", "MSBoard_time_16", 9 + 9, 139 + 20 + 5 + 16 + 10 + 16 + 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(ply:GetNWString("ply_MS_about"), "MSBoard_16", 9 + 9, 139 + 20 + 5 + 16 + 10 + 16 + 30 + 16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("Among the players with", "MSBoard_time_16", 9 + 9, 139 + 20 + 5 + 16 + 10 + 16 + 30 + 16 + 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(ply:GetNWString("ply_MS_time") .. " | " .. ply:GetNWString("ply_MS_register_date"), "MSBoard_time_16", 9 + 9, 139 + 20+5+16+10+16+30+16+30+16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            if me == ply then
                MSBoard.banner_but = vgui.Create("DButton", MSBoard.fr)
                MSBoard.banner_but:SetPos(MSBoard.fr:GetWide() - 4.5 - 4 - 16, 4.5 + 4)
                MSBoard.banner_but:SetSize(16, 16)
                MSBoard.banner_but:SetText("")
                MSBoard.banner_but.Paint = function(self,w,h)
                    surface.SetMaterial(Material("icon16/cog_go.png"))
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawTexturedRect(0, 0, w, h)
                end
                MSBoard.banner_but.DoClick = function(self)
                    MSBoard.temp = vgui.Create("DFrame")
                    MSBoard.temp:SetSize(310, 107)
                    MSBoard.temp:Center()
                    MSBoard.temp:MakePopup()
                    MSBoard.temp:SetTitle("")
                    MSBoard.temp.Paint = function(self,w,h)
                        draw.RoundedBox(10, 0, 0, w, h, Color(47, 49, 54))
                        draw.RoundedBox(10, 4.5, 4.5, w-9, h-9, Color(54, 57, 63))
                    end
                    MSBoard.text_entry = vgui.Create("DTextEntry", MSBoard.temp)
                    MSBoard.text_entry:Dock( TOP )
                    MSBoard.text_entry:DockMargin(0, 5, 0, 0)
                    MSBoard.text_entry:SetPlaceholderText("Give me IMGUR link")
                    MSBoard.text_entry.OnEnter = function(self)
                        local lildata = self:GetValue()
                        print(lildata)
                        net.Start("ply_MS_need_new_stuff")
                            net.WriteInt(3, 3)
                            net.WriteEntity( me )
                            net.WriteString( lildata )
                        net.SendToServer()
                        MSBoard.temp:Remove()
                    end
                end
                MSBoard.status_but = vgui.Create("DButton", MSBoard.fr)
                MSBoard.status_but:SetPos(MSBoard.fr:GetWide() - 9 - 4 - 16 - 7, 139 + 20 + 5 + 16 + 10 + 5)
                MSBoard.status_but:SetSize(16, 16)
                MSBoard.status_but:SetText("")
                MSBoard.status_but.Paint = function(self,w,h)
                    surface.SetMaterial(Material("icon16/pencil.png"))
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawTexturedRect(0, 0, w, h)
                end
                MSBoard.status_but.DoClick = function(self)
                    MSBoard.temp_1 = vgui.Create("DFrame")
                    MSBoard.temp_1:SetSize(310, 107)
                    MSBoard.temp_1:Center()
                    MSBoard.temp_1:MakePopup()
                    MSBoard.temp_1:SetTitle("")
                    MSBoard.temp_1.Paint = function(self,w,h)
                        draw.RoundedBox(10, 0, 0, w, h, Color(47, 49, 54))
                        draw.RoundedBox(10, 4.5, 4.5, w-9, h-9, Color(54, 57, 63))
                    end
                    MSBoard.text_entry = vgui.Create("DTextEntry", MSBoard.temp_1)
                    MSBoard.text_entry:Dock( TOP )
                    MSBoard.text_entry:DockMargin(0, 5, 0, 0)
                    MSBoard.text_entry:SetPlaceholderText("Give me your new status")
                    MSBoard.text_entry.OnEnter = function(self)
                        local lildata = self:GetValue()
                        print(lildata)
                        net.Start("ply_MS_need_new_stuff")
                            net.WriteInt(1, 3)
                            net.WriteEntity( me )
                            net.WriteString( lildata )
                        net.SendToServer()
                        MSBoard.temp_1:Remove()
                    end
                end

                MSBoard.aboutme_but = vgui.Create("DButton", MSBoard.fr)
                MSBoard.aboutme_but:SetPos(MSBoard.fr:GetWide() - 9 - 4 - 16 - 7, 139 + 20 + 5 + 16 + 10 + 16 + 23 + 16)
                MSBoard.aboutme_but:SetSize(16, 16)
                MSBoard.aboutme_but:SetText("")
                MSBoard.aboutme_but.Paint = function(self,w,h)
                    surface.SetMaterial(Material("icon16/pencil.png"))
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawTexturedRect(0, 0, w, h)
                end
                MSBoard.aboutme_but.DoClick = function(self)
                    MSBoard.temp_2 = vgui.Create("DFrame")
                    MSBoard.temp_2:SetSize(310, 107)
                    MSBoard.temp_2:Center()
                    MSBoard.temp_2:MakePopup()
                    MSBoard.temp_2:SetTitle("")
                    MSBoard.temp_2.Paint = function(self,w,h)
                        draw.RoundedBox(10, 0, 0, w, h, Color(47, 49, 54))
                        draw.RoundedBox(10, 4.5, 4.5, w-9, h-9, Color(54, 57, 63))
                    end
                    MSBoard.text_entry = vgui.Create("DTextEntry", MSBoard.temp_2)
                    MSBoard.text_entry:Dock( TOP )
                    MSBoard.text_entry:DockMargin(0, 5, 0, 0)
                    MSBoard.text_entry:SetPlaceholderText("Give me your new bio")
                    MSBoard.text_entry.OnEnter = function(self)
                        local lildata = self:GetValue()
                        print(lildata)
                        net.Start("ply_MS_need_new_stuff")
                            net.WriteInt(2, 3)
                            net.WriteEntity( me )
                            net.WriteString( lildata )
                        net.SendToServer()
                        MSBoard.temp_2:Remove()
                    end
                end
            end
            MSBoard.fr_avatar = vgui.Create("RoundedAvatar", MSBoard.fr)
            MSBoard.fr_avatar:SetMaskSize(32)
            if ply:IsBot() or not IsValid(ply) then
                MSBoard.fr_avatar:SetSteamID("76561198125082967", 128)
            else
                MSBoard.fr_avatar:SetSteamID(ply:SteamID64(), 128)
            end
            MSBoard.fr_avatar:SetPos(9, 64)
            MSBoard.fr_avatar:SetSize(75, 75)
        end
        self.playerPanels[playerPanel] = true
    end

end

function PANEL:OnSizeChanged(w,h)
    if self.titleBar then
        self.titleBar:SetTall(h * .05)
    end 
    if self.subTitle then
        self.subTitle:SetTall(h * .025)
    end 
    if self.playerPanels then
        for panel,v in pairs(self.playerPanels) do
            if not IsValid(panel) then
                self.playerPanels[panel] = nil
            end
            panel:SetTall(h * .06)
        end
    end 
    if self.subTitleLabels then
        for label,v in pairs(self.subTitleLabels) do
            label:SetWide(w / table.Count(self.subTitleLabels))
        end
    end 
end

local blur = Material( "pp/blurscreen" )
function PANEL:BlurMenu( layers, density, alpha )
    local x, y = self:LocalToScreen( 0, 0 )

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )

    for i = 1, 5 do
        blur:SetFloat( "$blur", ( i / 4 ) * 4 )
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end

function PANEL:Paint(w,h)
    local theme = MSBoard.Theme
    self:BlurMenu( me, 16, 16, 255 )
    draw.RoundedBox(0, 0, 0, w, h, Color(35,37,65,100))
end

vgui.Register("ScoreboardFrame", PANEL, "DFrame")