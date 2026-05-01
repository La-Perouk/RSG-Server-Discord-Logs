-- ==== Adding discord logs to a script ==== -- 

-- Config.DiscordWebhook = ''     

local webhook = Config.DiscordWebhook or 'YOUR_DISCORD_WEBHOOK_URL'

local function ParseIdentifiers(src)
    local identifiers = GetPlayerIdentifiers(src)
    local discordId, discordName = 'N/A', 'N/A'
    local steamId, steamName, steamProfile = 'N/A', GetPlayerName(src), 'N/A'

    for i = 1, #identifiers do
        local id = identifiers[i]
        if string.find(id, 'discord:') then
            discordId = string.sub(id, 9)
            discordName = '<@' .. discordId .. '>'
        elseif string.find(id, 'steam:') then
            steamId = id
            local steamHex = tonumber(steamId:gsub("steam:", ""), 16) or 0
            steamProfile = steamHex ~= 0 and string.format("https://steamcommunity.com/profiles/%d", steamHex) or "N/A"
        end
    end

    return discordId, discordName, steamId, steamName, steamProfile
end

local function GetPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        return string.format('%.1f, %.1f, %.1f', coords.x, coords.y, coords.z)
    end
    return 'Unknown'
end 

-- RegisterServerEvent('rsg-add_your_script_name')
            local src = source
            local Player = RSGCore.Functions.GetPlayer(src)
            if not Player then return end

            -- Adding Discord Logs 
            local discordId, discordName, steamId, steamName, steamProfile = ParseIdentifiers(src)
            local coords = GetPlayerCoords(src)
            local playerName = 'Unknown'
            if Player and Player.PlayerData.charinfo then
                playerName = (Player.PlayerData.charinfo.firstname or '') .. ' ' .. (Player.PlayerData.charinfo.lastname or '')
            end
            if playerName == '' then playerName = 'No Character' end

            local jobLabel = "Unknown"
            if Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name then
                jobLabel  = Player.PlayerData.job.label
            end
            
            local citizenId = Player.PlayerData.citizenid or 'N/A'
            local serverId = tostring(src)  
            local profileLink = steamProfile ~= 'N/A' and ('[Click Here To View](' .. steamProfile .. ')') or 'N/A'

            local embed = {
                title = "......",
                color = 65280,  
                fields = {
                    { name = 'Player ID', value = tostring(serverId), inline = true },
                    { name = "Player Name", value=playerName, inline=true},
                    { name = 'CitizenID', value = citizenId, inline = true },
                    { name = 'Job', value = jobLabel, inline = true },
                    { name = 'Discord Name', value = discordName, inline = true },
                    { name = 'Discord ID', value = discordId, inline = true },
                    { name = 'Steam Name', value = steamName, inline = true },
                    { name = 'Steam ID', value = steamId, inline = true },
                    { name = 'Steam Profile', value = profileLink, inline = false },
                    
                    -- Any other discord logs to be added between Steam Profile and Coordinates !!!
                    { name = 'Reward', value = '$ ' .. tostring(payout), inline = true },

                    { name = 'Coordinates', value = coords, inline = true }
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")  
            }
            PerformHttpRequest(webhook, function() end, 'POST', json.encode({embeds={embed}}), {['Content-Type']='application/json'})
            -- End of Discord Logs
