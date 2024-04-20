-- Available Print
print("\27[1;46m[FiveM-Helper]\27[0m \27[1;37m The FiveM Helper ^3Fraction Integration^7\27[1;37m is now available ✅^7")

-- Variables
local APIBaseURL = 'http://api.fivem-helper.eu' -- The base URL of the API

-- Get Player Stamp
local StampCache = {}
lib.callback.register('fivemhelper_fraction:server:getLastStamp', function(_, data)
    local TargetPlayerId = data.player or source
    local DiscordId = GetDiscordId(TargetPlayerId)
    if not DiscordId then
        print(('\27[1;46m[FiveM-Helper]\27[0m \27[1;37m The player ^3%s^7 does not have a Discord ID!'):format(TargetPlayerId))
        return
    end

    -- Use Cache instead
    if StampCache[DiscordId] then
        if StampCache[DiscordId][data.fractionId] then
            if StampCache[DiscordId][data.fractionId].lastStamp then
                return StampCache[DiscordId][data.fractionId].lastStamp
            end
        end
    end

    -- Send the request to the API
    local APIRoute = ('%s/%s/lastStamp'):format(data.fractionId, DiscordId)
    local Response = FiveMHelperAPIRequest(APIRoute, "GET")

    if Response.status == 200 then
        -- Cache
        if not StampCache[DiscordId] then StampCache[DiscordId] = {} end
        if not StampCache[DiscordId][data.fractionId] then StampCache[DiscordId][data.fractionId] = {} end

        StampCache[DiscordId][data.fractionId].lastStamp = Response.data
        SetTimeout(10000, function()
            if StampCache[DiscordId] then
                if StampCache[DiscordId][data.fractionId] then
                    StampCache[DiscordId][data.fractionId].lastStamp = nil
                end
            end
        end)

        return Response.data
    else
        return nil
    end
end)

-- Get Player Previous Stamp
lib.callback.register('fivemhelper_fraction:server:getPreviousStamps', function(_, data)
    local TargetPlayerId = data.player or source
    local DiscordId = GetDiscordId(TargetPlayerId)
    if not DiscordId then
        print(('\27[1;46m[FiveM-Helper]\27[0m \27[1;37m The player ^3%s^7 does not have a Discord ID!'):format(TargetPlayerId))
        return
    end

    -- Use Cache instead
    if StampCache[DiscordId] then
        if StampCache[DiscordId][data.fractionId] then
            if StampCache[DiscordId][data.fractionId].previousStamp then
                return StampCache[DiscordId][data.fractionId].previousStamp
            end
        end
    end

    -- Send the request to the API
    local APIRoute = ('%s/%s/previousStamps'):format(data.fractionId, DiscordId)
    local Response = FiveMHelperAPIRequest(APIRoute, "GET")

    if Response.status == 200 then
        -- Format Time
        for k, v in pairs(Response.data) do
            Response.data[k].stampTime = os.date('%d.%m.%Y %H:%M:%S', ParseISODateString(v.stampTime))
        end

        -- Cache
        if not StampCache[DiscordId] then StampCache[DiscordId] = {} end
        if not StampCache[DiscordId][data.fractionId] then StampCache[DiscordId][data.fractionId] = {} end
        StampCache[DiscordId][data.fractionId].previousStamp = Response.data
        SetTimeout(10000, function()
            if StampCache[DiscordId] then
                if StampCache[DiscordId][data.fractionId] then
                    StampCache[DiscordId][data.fractionId].previousStamp = nil
                end
            end
        end)

        return Response.data
    else
        return nil
    end
end)

-- Player Stamp
lib.callback.register('fivemhelper_fraction:server:stamp', function(_, data)
    local TargetPlayerId = data.player or source
    local DiscordId = GetDiscordId(TargetPlayerId)
    if not DiscordId then
        print(('\27[1;46m[FiveM-Helper]\27[0m \27[1;37m The player ^3%s^7 does not have a Discord ID!'):format(TargetPlayerId))
        return
    end

    -- Change Cache
    if StampCache[DiscordId] then
        if StampCache[DiscordId][data.fractionId] then
            StampCache[DiscordId][data.fractionId].lastStamp = nil
            StampCache[DiscordId][data.fractionId].previousStamp = nil
        end
    end

    -- Send the stamp request to the API
    local APIRoute = ('%s/%s/stamp'):format(data.fractionId, DiscordId)
    local Response = FiveMHelperAPIRequest(APIRoute, "POST", { Type = data.type })
    return Response
end)

-- Player Leaves Server
AddEventHandler('playerDropped', function(reason)
    local DiscordId = GetDiscordId(source)

    if DiscordId then
        if StampCache[DiscordId] then
            for k, v in pairs(StampCache[DiscordId]) do
                if v.lastStamp then
                    if v.lastStamp.stampType == 'IN' then
                        -- Send the request to the API
                        local APIRoute = ('%s/%s/stamp'):format(k, DiscordId)
                        FiveMHelperAPIRequest(APIRoute, "POST", { Type = 'OUT' })
                        print(('\27[1;46m[FiveM-Helper]\27[0m \27[1;37m Player ^3%s^7\27[1;37m has stamped out automatically'):format(DiscordId))
                    end
                else
                    local Response = FiveMHelperAPIRequest(('%s/%s/lastStamp'):format(k, DiscordId), "GET")

                    if Response.status == 200 then
                        if Response.data.stampType == 'IN' then
                            -- Send the request to the API
                            local APIRoute = ('%s/%s/stamp'):format(k, DiscordId)
                            FiveMHelperAPIRequest(APIRoute, "POST", { Type = 'OUT' })
                            print(('\27[1;46m[FiveM-Helper]\27[0m \27[1;37m Player ^3%s^7\27[1;37m has stamped out automatically'):format(DiscordId))
                        end
                    end
                end
            end
        end

        -- Clear the cache
        StampCache[DiscordId] = nil
    end
end)

--- Sends an API request to the specified route using the specified method and data.
--- @param APIRoute The route of the API.
--- @param Method The HTTP method to use for the request (e.g., "GET", "POST").
--- @param Data The data to send with the request (optional).
--- @return The response data from the API.
function FiveMHelperAPIRequest(APIRoute, Method, Data)
    local APIEndpoint = ('%s/%s'):format(APIBaseURL, APIRoute)
    local IsReady = false
    local ResponseData = {}
    PerformHttpRequest(APIEndpoint, function(Code, Response, Headers, ErrorResponse)
        -- Alert when API is unreachable
        if Code == 0 then
            print(('\27[1;46m[FiveM-Helper]\27[0m \27[1;37m The FiveM Helper API is unreachable! Tried Endpoint: ^3%s^7'):format(APIEndpoint))
        end

        if Code >= 200 and Code < 300 then
            ResponseData = Response
        else
            ResponseData = ErrorResponse:gsub('HTTP %d+: (.+)', '%1')
        end
        ResponseData = json.decode(ResponseData)
        IsReady = true
    end, Method, Data and json.encode(Data) or nil, { ['Content-Type'] = 'application/json', ['Authorization'] = Config.AuthorizationKey })

    while not IsReady do
        Citizen.Wait(150)
    end

    return ResponseData
end

--- Retrieves the Discord ID associated with a player.
--- @param PlayerId The player's ID.
--- @return The Discord ID, or nil if not found.
function GetDiscordId(PlayerId)
    for k, v in ipairs(GetPlayerIdentifiers(PlayerId)) do
        if string.find(v, "discord") then
            return v:gsub("discord:", "")
        end
    end
end

--- Parses an ISO date string and returns the corresponding Unix timestamp.
--- @param IsoString The ISO date string to parse.
--- @return The Unix timestamp representing the parsed date and time.
function ParseISODateString(IsoString)
    local year, month, day, hour, min, sec = IsoString:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
end

-- local response = FiveMHelperAPIRequest("4/796509779123765268/stamp", "POST", { Type = 'IN' })
-- print(response.message)

-- local response2 = FiveMHelperAPIRequest("4/796509779123765268/info", "GET")
-- print(response2.data.id)
