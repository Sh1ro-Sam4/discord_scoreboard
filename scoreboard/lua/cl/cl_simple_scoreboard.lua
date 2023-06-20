MSBoard = {
    Title = "TestServer",
    Ranks = {
        ["superadmin"] = "</root>",
    },
    Theme = {
        frame = Color(0,0,0,200),
        panel = Color(0,0,0,200),
        theme = Color(219,219,219),
        gradient = Material("board/grad.png"),
        enable_gradient = true,
    },
    Padding = {
        x = ScrW() * .005,
        y = ScrH() * .01
    },
    SubTitle = {
        {title = "Игроков: ", getText = function() return player.GetCount() end},
        {title = "Сервер работает: ", getText = function() return string.FormattedTime(CurTime(), "%02i:%02i" ) end},
    },
    PlayerInformation = {
        {title = "Привилегия: ", getText = function(ply) local rank = ply:GetUserGroup() rank = MSBoard.Ranks[rank] or rank return rank end},
        {title = "Пинг: ", getText = function(ply) return ply:Ping() end},
    },
}

local fontSizes = {
    18,
    16,
    20,
    24,
    36,
}

for i = 1, #fontSizes do
    local size = fontSizes[i]
    surface.CreateFont( "MSBoard_" .. size, {
        font = "Roboto",
        extended = false,
        size = size,
        weight = 500,
    } )
    
end

surface.CreateFont( "MSBoard_time_16", {
        font = "Roboto",
        extended = false,
        size = 16,
        weight = 1000,
    } )

function MSBoard.Open()

    local scrw, scrh = ScrW(), ScrH()
    if IsValid(MSBoard.Menu) then 
        MSBoard.Menu:Remove()
    end
    MSBoard.Menu = vgui.Create("ScoreboardFrame")
    MSBoard.Menu:SetSize(scrw, scrh)
    MSBoard.Menu:Center()
    MSBoard.Menu:MakePopup()
    MSBoard.Menu:Show()
end



function MSBoard.Hide()
    if not IsValid(MSBoard.Menu) then return end
    if IsValid(MSBoard.fr) then MSBoard.fr:Remove() end
    MSBoard.Menu:Hide()
end

hook.Add("ScoreboardShow", "SimpleScoreboard_Open", function()
    MSBoard.Open()
    return true
end)

hook.Add("ScoreboardHide", "SimpleScoreboard_Close", function()
    MSBoard.Hide()
    return true
end)