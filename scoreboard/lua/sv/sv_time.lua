MSBoard = MSBoard or {}

util.AddNetworkString("ply_MS_need_new_stuff")

net.Receive("ply_MS_need_new_stuff", function()
    local type = net.ReadInt(3)
    local ply = net.ReadEntity()
    local lildata = net.ReadString()
    if type == 1 then
        MSBoard.SaveToDB(ply, lildata, MSBoard.GetAboutMe(ply), MSBoard.GetBanner(ply))
        ply:SetNWString("ply_MS_status", MSBoard.GetStatus(ply))
    elseif type == 2 then
        MSBoard.SaveToDB(ply, MSBoard.GetStatus(ply), lildata, MSBoard.GetBanner(ply))
        ply:SetNWString("ply_MS_about", MSBoard.GetAboutMe(ply))
    elseif type == 3 then
        MSBoard.SaveToDB(ply, MSBoard.GetStatus(ply), MSBoard.GetAboutMe(ply), lildata)
        ply:SetNWString("ply_MS_banner", lildata)
    end
end)

sql.Query( "CREATE TABLE IF NOT EXISTS MSBoard ( SteamID TEXT, status TEXT, aboutme TEXT, banner TEXT )" )

function MSBoard.SaveToDB(ply, status, aboutme, banner)
    local data = sql.Query( "SELECT status, aboutme, banner FROM MSBoard WHERE SteamID = " .. sql.SQLStr(ply:SteamID()) .. ";" )
    print(status, aboutme, banner)
    if ( data ) then
        sql.Query(("UPDATE MSBoard SET status = %s, aboutme = %s, banner = %s WHERE SteamID = %s;")
        :format(sql.SQLStr(status), sql.SQLStr(aboutme), sql.SQLStr(banner), sql.SQLStr(ply:SteamID())))

        print(("INSERT INTO MSBoard ( SteamID, status, aboutme, banner ) VALUES( %s, %s, %s, %s )")
        :format(ply:SteamID(), sql.SQLStr(status), sql.SQLStr(aboutme), sql.SQLStr(banner)))
    else
        sql.Query(("INSERT INTO MSBoard ( SteamID, status, aboutme, banner ) VALUES( %s, %s, %s, %s )")
        :format(sql.SQLStr(ply:SteamID()), sql.SQLStr(status), sql.SQLStr(aboutme), sql.SQLStr(banner)))

        print(("INSERT INTO MSBoard ( SteamID, status, aboutme, banner ) VALUES( %s, %s, %s, %s )")
        :format(ply:SteamID(), sql.SQLStr(status), sql.SQLStr(aboutme), sql.SQLStr(banner)))
    end
    print(MSBoard.GetStatus(ply), MSBoard.GetAboutMe(ply), MSBoard.GetBanner(ply))
end

function MSBoard.GetStatus(ply)
    local val = sql.QueryValue( "SELECT status FROM MSBoard WHERE SteamID = " .. sql.SQLStr(ply:SteamID()) .. ";")
    return val
end

function MSBoard.GetAboutMe(ply)
    local val1 = sql.QueryValue( "SELECT aboutme FROM MSBoard WHERE SteamID = " .. sql.SQLStr(ply:SteamID()) .. ";")
    return val1
end

function MSBoard.GetBanner(ply)
    local val2 = sql.QueryValue( "SELECT banner FROM MSBoard WHERE SteamID = " .. sql.SQLStr(ply:SteamID()) .. ";")
    return val2
end

hook.Add("PlayerInitialSpawn", "MSBoard.TimeString", function(ply)
    if (not file.Exists("board/time/" .. ply:SteamID64() .. ".txt", "DATA")) then
        local timestamp = os.time()
        local time = os.date( "%d/%m/%Y" , timestamp )
        file.Write("board/time/" .. ply:SteamID64() .. ".txt", time)
        ply:SetNWString("ply_MS_time", file.Read("board/time/" .. ply:SteamID64() .. ".txt"))
    else
        ply:SetNWString("ply_MS_time", file.Read("board/time/" .. ply:SteamID64() .. ".txt"))
    end
end)

hook.Add("PlayerAuthed", "MSBoard.RegisterDate", function(ply)
    if ply:IsPlayer() and IsValid(ply) then
        http.Fetch("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9DD0B760ED10121AE39EB36A78F9177A&steamids=" .. ply:SteamID64(), function(a)
                local json = util.JSONToTable(a)
                local timestamp = json.response.players[1].timecreated
                local time = os.date( "%d/%m/%Y" , timestamp )
                ply:SetNWString("ply_MS_register_date", time)
            end
        )
    elseif ply:IsBot() then
        ply:SetNWString("ply_MS_register_date", "a long time ago")
    else
        ply:SetNWString("ply_MS_register_date", "bad user")
    end
end)

hook.Add("PlayerSay", "MSBoard.Commands", function(ply, text)
    if (text:sub(1,8) == "/status ") then
        local bigdata = text:sub(9)
        if utf8.len(bigdata) > 40 then
            ply:ChatPrint("Status cant be too big")
            return ""
        end
        MSBoard.SaveToDB(ply, bigdata, MSBoard.GetAboutMe(ply), MSBoard.GetBanner(ply))
        ply:SetNWString("ply_MS_status", MSBoard.GetStatus(ply))
        return ""
    end

    if (text:sub(1,9) == "/aboutme ") then
        local bigdata = text:sub(9)
        if utf8.len(bigdata) > 40 then
            ply:ChatPrint("About me cant be too big")
            return ""
        end
        MSBoard.SaveToDB(ply, MSBoard.GetStatus(ply), bigdata, MSBoard.GetBanner(ply))
        ply:SetNWString("ply_MS_about", MSBoard.GetAboutMe(ply))
        return ""
    end

    if (text:sub(1,8) == "/banner ") then
        local bigdata = text:sub(9)
        if utf8.len(bigdata) > 45 then
            ply:ChatPrint("Please send FULL URL. Example: /banner https://i.imgur.com/rKQXAuv.png")
            return ""
        end
        MSBoard.SaveToDB(ply, MSBoard.GetStatus(ply), MSBoard.GetAboutMe(ply), bigdata)
        ply:SetNWString("ply_MS_banner", bigdata)
        return ""
    end
end)

hook.Add("PlayerInitialSpawn", "MSBoard.Banners", function(ply)
    ply:SetNWString("ply_MS_banner", MSBoard.GetBanner(ply) or "https://i.imgur.com/rKQXAuv.png")
end)