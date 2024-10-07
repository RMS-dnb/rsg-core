RSGCore.Functions = {}
RSGCore.Player_Buckets = {}
RSGCore.Entity_Buckets = {}
RSGCore.UsableItems = {}

-- Getters
-- Get your player first and then trigger a function on them
-- ex: local player = RSGCore.Functions.GetPlayer(source)
-- ex: local example = player.Functions.functionname(parameter)

---Gets the coordinates of an entity
---@param entity number
---@return vector4
function RSGCore.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return vector4(coords.x, coords.y, coords.z, heading)
end

---Gets player identifier of the given type
---@param source any
---@param idtype string
---@return string?
function RSGCore.Functions.GetIdentifier(source, idtype)
    return GetPlayerIdentifierByType(source, idtype or 'license')
end

---Gets a players server id (source). Returns 0 if no player is found.
---@param identifier string
---@return number
function RSGCore.Functions.GetSource(identifier)
    for src, _ in pairs(RSGCore.Players) do
        local idens = GetPlayerIdentifiers(src)
        for _, id in pairs(idens) do
            if identifier == id then
                return src
            end
        end
    end
    return 0
end

---Get player with given server id (source)
---@param source any
---@return table
function RSGCore.Functions.GetPlayer(source)
    if type(source) == 'number' then
        return RSGCore.Players[source]
    else
        return RSGCore.Players[RSGCore.Functions.GetSource(source)]
    end
end

---Get player by citizen id
---@param citizenid string
---@return table?
function RSGCore.Functions.GetPlayerByCitizenId(citizenid)
    for src in pairs(RSGCore.Players) do
        if RSGCore.Players[src].PlayerData.citizenid == citizenid then
            return RSGCore.Players[src]
        end
    end
    return nil
end

---Get offline player by citizen id
---@param citizenid string
---@return table?
function RSGCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
    return RSGCore.Player.GetOfflinePlayer(citizenid)
end

---Get player by license
---@param license string
---@return table?
function RSGCore.Functions.GetPlayerByLicense(license)
    return RSGCore.Player.GetPlayerByLicense(license)
end

---Get player by account id
---@param account string
---@return table?
function RSGCore.Functions.GetPlayerByAccount(account)
    for src in pairs(RSGCore.Players) do
        if RSGCore.Players[src].PlayerData.charinfo.account == account then
            return RSGCore.Players[src]
        end
    end
    return nil
end

---Get player passing property and value to check exists
---@param property string
---@param value string
---@return table?
function RSGCore.Functions.GetPlayerByCharInfo(property, value)
    for src in pairs(RSGCore.Players) do
        local charinfo = RSGCore.Players[src].PlayerData.charinfo
        if charinfo[property] ~= nil and charinfo[property] == value then
            return RSGCore.Players[src]
        end
    end
    return nil
end

---Get all players. Returns the server ids of all players.
---@return table
function RSGCore.Functions.GetPlayers()
    local sources = {}
    for k in pairs(RSGCore.Players) do
        sources[#sources + 1] = k
    end
    return sources
end

---Will return an array of RSG Player class instances
---unlike the GetPlayers() wrapper which only returns IDs
---@return table
function RSGCore.Functions.GetRSGPlayers()
    return RSGCore.Players
end

---Gets a list of all on duty players of a specified job and the number
---@param job string
---@return table, number
function RSGCore.Functions.GetPlayersOnDuty(job)
    local players = {}
    local count = 0
    for src, Player in pairs(RSGCore.Players) do
        if Player.PlayerData.job.name == job then
            if Player.PlayerData.job.onduty then
                players[#players + 1] = src
                count += 1
            end
        end
    end
    return players, count
end

---Returns only the amount of players on duty for the specified job
---@param job string
---@return number
function RSGCore.Functions.GetDutyCount(job)
    local count = 0
    for _, Player in pairs(RSGCore.Players) do
        if Player.PlayerData.job.name == job then
            if Player.PlayerData.job.onduty then
                count += 1
            end
        end
    end
    return count
end

--- @param source number source player's server ID.
--- @param coords vector The coordinates to calculate the distance from. Can be a table with x, y, z fields or a vector3. If not provided, the source player's Ped's coordinates are used.
--- @return string closestPlayer - The Player that is closest to the source player (or the provided coordinates). Returns -1 if no Players are found.
--- @return number closestDistance - The distance to the closest Player. Returns -1 if no Players are found.
function RSGCore.Functions.GetClosestPlayer(source, coords)
    local ped = GetPlayerPed(source)
    local players = GetPlayers()
    local closestDistance, closestPlayer = -1, -1
    if coords then coords = type(coords) == 'table' and vector3(coords.x, coords.y, coords.z) or coords end
    if not coords then coords = GetEntityCoords(ped) end
    for i = 1, #players do
        local playerId = players[i]
        local playerPed = GetPlayerPed(playerId)
        if playerPed ~= ped then
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - coords)
            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

--- @param source number source player's server ID.
--- @param coords vector The coordinates to calculate the distance from. Can be a table with x, y, z fields or a vector3. If not provided, the source player's Ped's coordinates are used.
--- @return number closestObject - The Object that is closest to the source player (or the provided coordinates). Returns -1 if no Objects are found.
--- @return number closestDistance - The distance to the closest Object. Returns -1 if no Objects are found.
function RSGCore.Functions.GetClosestObject(source, coords)
    local ped = GetPlayerPed(source)
    local objects = GetAllObjects()
    local closestDistance, closestObject = -1, -1
    if coords then coords = type(coords) == 'table' and vector3(coords.x, coords.y, coords.z) or coords end
    if not coords then coords = GetEntityCoords(ped) end
    for i = 1, #objects do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(objectCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestObject = objects[i]
            closestDistance = distance
        end
    end
    return closestObject, closestDistance
end

--- @param source number source player's server ID.
--- @param coords vector The coordinates to calculate the distance from. Can be a table with x, y, z fields or a vector3. If not provided, the source player's Ped's coordinates are used.
--- @return number closestVehicle - The Vehicle that is closest to the source player (or the provided coordinates). Returns -1 if no Vehicles are found.
--- @return number closestDistance - The distance to the closest Vehicle. Returns -1 if no Vehicles are found.
function RSGCore.Functions.GetClosestVehicle(source, coords)
    local ped = GetPlayerPed(source)
    local vehicles = GetAllVehicles()
    local closestDistance, closestVehicle = -1, -1
    if coords then coords = type(coords) == 'table' and vector3(coords.x, coords.y, coords.z) or coords end
    if not coords then coords = GetEntityCoords(ped) end
    for i = 1, #vehicles do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end

--- @param source number source player's server ID.
--- @param coords vector The coordinates to calculate the distance from. Can be a table with x, y, z fields or a vector3. If not provided, the source player's Ped's coordinates are used.
--- @return number closestPed - The Ped that is closest to the source player (or the provided coordinates). Returns -1 if no Peds are found.
--- @return number closestDistance - The distance to the closest Ped. Returns -1 if no Peds are found.
function RSGCore.Functions.GetClosestPed(source, coords)
    local ped = GetPlayerPed(source)
    local peds = GetAllPeds()
    local closestDistance, closestPed = -1, -1
    if coords then coords = type(coords) == 'table' and vector3(coords.x, coords.y, coords.z) or coords end
    if not coords then coords = GetEntityCoords(ped) end
    for i = 1, #peds do
        if peds[i] ~= ped then
            local pedCoords = GetEntityCoords(peds[i])
            local distance = #(pedCoords - coords)
            if closestDistance == -1 or closestDistance > distance then
                closestPed = peds[i]
                closestDistance = distance
            end
        end
    end
    return closestPed, closestDistance
end

-- Routing buckets (Only touch if you know what you are doing)

---Returns the objects related to buckets, first returned value is the player buckets, second one is entity buckets
---@return table, table
function RSGCore.Functions.GetBucketObjects()
    return RSGCore.Player_Buckets, RSGCore.Entity_Buckets
end

---Will set the provided player id / source into the provided bucket id
---@param source any
---@param bucket any
---@return boolean
function RSGCore.Functions.SetPlayerBucket(source, bucket)
    if source and bucket then
        local plicense = RSGCore.Functions.GetIdentifier(source, 'license')
        Player(source).state:set('instance', bucket, true)
        SetPlayerRoutingBucket(source, bucket)
        RSGCore.Player_Buckets[plicense] = { id = source, bucket = bucket }
        return true
    else
        return false
    end
end

---Will set any entity into the provided bucket, for example peds / vehicles / props / etc.
---@param entity number
---@param bucket number
---@return boolean
function RSGCore.Functions.SetEntityBucket(entity, bucket)
    if entity and bucket then
        SetEntityRoutingBucket(entity, bucket)
        RSGCore.Entity_Buckets[entity] = { id = entity, bucket = bucket }
        return true
    else
        return false
    end
end

---Will return an array of all the player ids inside the current bucket
---@param bucket number
---@return table|boolean
function RSGCore.Functions.GetPlayersInBucket(bucket)
    local curr_bucket_pool = {}
    if RSGCore.Player_Buckets and next(RSGCore.Player_Buckets) then
        for _, v in pairs(RSGCore.Player_Buckets) do
            if v.bucket == bucket then
                curr_bucket_pool[#curr_bucket_pool + 1] = v.id
            end
        end
        return curr_bucket_pool
    else
        return false
    end
end

---Will return an array of all the entities inside the current bucket
---(not for player entities, use GetPlayersInBucket for that)
---@param bucket number
---@return table|boolean
function RSGCore.Functions.GetEntitiesInBucket(bucket)
    local curr_bucket_pool = {}
    if RSGCore.Entity_Buckets and next(RSGCore.Entity_Buckets) then
        for _, v in pairs(RSGCore.Entity_Buckets) do
            if v.bucket == bucket then
                curr_bucket_pool[#curr_bucket_pool + 1] = v.id
            end
        end
        return curr_bucket_pool
    else
        return false
    end
end

---Server side vehicle creation with optional callback
---the CreateVehicle RPC still uses the client for creation so players must be near
---@param source any
---@param model any
---@param coords vector
---@param warp boolean
---@return number
function RSGCore.Functions.SpawnVehicle(source, model, coords, warp)
    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local heading = coords.w and coords.w or 0.0
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then
        while GetVehiclePedIsIn(ped) ~= veh do
            Wait(0)
            TaskWarpPedIntoVehicle(ped, veh, -1)
        end
    end
    while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
    return veh
end

--- New & more reliable server side native for creating vehicles
---comment
---@param source any
---@param model any
---@param vehtype any
-- The appropriate vehicle type for the model info.
-- Can be one of automobile, bike, boat, heli, plane, submarine, trailer, and (potentially), train.
-- This should be the same type as the type field in vehicles.meta.
---@param coords vector
---@param warp boolean
---@return number
function RSGCore.Functions.CreateVehicle(source, model, vehtype, coords, warp)
    model = type(model) == 'string' and joaat(model) or model
    vehtype = type(vehtype) == 'string' and tostring(vehtype) or vehtype
    if not coords then coords = GetEntityCoords(GetPlayerPed(source)) end
    local heading = coords.w and coords.w or 0.0
    local veh = CreateVehicleServerSetter(model, vehtype, coords, heading)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then TaskWarpPedIntoVehicle(GetPlayerPed(source), veh, -1) end
    return veh
end

---Paychecks (standalone - don't touch)
function PaycheckInterval()
    if next(RSGCore.Players) then
        for _, Player in pairs(RSGCore.Players) do
            if Player then
                local payment = RSGShared.Jobs[Player.PlayerData.job.name]['grades'][tostring(Player.PlayerData.job.grade.level)].payment
                if not payment then payment = Player.PlayerData.job.payment end
                if Player.PlayerData.job and payment > 0 and (RSGShared.Jobs[Player.PlayerData.job.name].offDutyPay or Player.PlayerData.job.onduty) then
                    if RSGCore.Config.Money.PayCheckSociety then
                        local account = exports['rsg-banking']:GetAccountBalance(Player.PlayerData.job.name)
                        if account ~= 0 then          -- Checks if player is employed by a society
                            if account < payment then -- Checks if company has enough money to pay society
                                TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {title = Lang:t('error.company_too_poor'), type = 'error', duration = 5000 })
                            else
                                Player.Functions.AddMoney('bank', payment, 'paycheck')
                                exports['rsg-banking']:RemoveMoney(Player.PlayerData.job.name, payment, 'Employee Paycheck')
                                TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {title = Lang:t('info.received_paycheck', { value = payment }), type = 'info', duration = 5000 })
                            end
                        else
                            Player.Functions.AddMoney('bank', payment, 'paycheck')
                            TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {title = Lang:t('info.received_paycheck', { value = payment }), type = 'info', duration = 5000 })
                        end
                    else
                        Player.Functions.AddMoney('bank', payment, 'paycheck')
                        TriggerClientEvent('ox_lib:notify', Player.PlayerData.source, {title = Lang:t('info.received_paycheck', { value = payment }), type = 'info', duration = 5000 })
                    end
                end
            end
        end
    end
    SetTimeout(RSGCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckInterval)
end

-- Callback Functions --

---Trigger Client Callback
---@param name string
---@param source any
---@param cb function
---@param ... any
function RSGCore.Functions.TriggerClientCallback(name, source, cb, ...)
    RSGCore.ClientCallbacks[name] = cb
    TriggerClientEvent('RSGCore:Client:TriggerClientCallback', source, name, ...)
end

---Create Server Callback
---@param name string
---@param cb function
function RSGCore.Functions.CreateCallback(name, cb)
    RSGCore.ServerCallbacks[name] = cb
end

---Trigger Serv er Callback
---@param name string
---@param source any
---@param cb function
---@param ... any
function RSGCore.Functions.TriggerCallback(name, source, cb, ...)
    if not RSGCore.ServerCallbacks[name] then return end
    RSGCore.ServerCallbacks[name](source, cb, ...)
end

-- Items

---Create a usable item
---@param item string
---@param data function
function RSGCore.Functions.CreateUseableItem(item, data)
    RSGCore.UsableItems[item] = data
end

---Checks if the given item is usable
---@param item string
---@return any
function RSGCore.Functions.CanUseItem(item)
    return RSGCore.UsableItems[item]
end

---Use item
---@param source any
---@param item string
function RSGCore.Functions.UseItem(source, item)
    if GetResourceState('rsg-inventory') == 'missing' then return end
    exports['rsg-inventory']:UseItem(source, item)
end

---Kick Player
---@param source any
---@param reason string
---@param setKickReason boolean
---@param deferrals boolean
function RSGCore.Functions.Kick(source, reason, setKickReason, deferrals)
    reason = '\n' .. reason .. '\n🔸 Check our Discord for further information: ' .. RSGCore.Config.Server.Discord
    if setKickReason then
        setKickReason(reason)
    end
    CreateThread(function()
        if deferrals then
            deferrals.update(reason)
            Wait(2500)
        end
        if source then
            DropPlayer(source, reason)
        end
        for _ = 0, 4 do
            while true do
                if source then
                    if GetPlayerPing(source) >= 0 then
                        break
                    end
                    Wait(100)
                    CreateThread(function()
                        DropPlayer(source, reason)
                    end)
                end
            end
            Wait(5000)
        end
    end)
end

---Check if player is whitelisted, kept like this for backwards compatibility or future plans
---@param source any
---@return boolean
function RSGCore.Functions.IsWhitelisted(source)
    if not RSGCore.Config.Server.Whitelist then return true end
    if RSGCore.Functions.HasPermission(source, RSGCore.Config.Server.WhitelistPermission) then return true end
    return false
end

-- Setting & Removing Permissions

---Add permission for player
---@param source any
---@param permission string
function RSGCore.Functions.AddPermission(source, permission)
    if not IsPlayerAceAllowed(source, permission) then
        ExecuteCommand(('add_principal player.%s rsgcore.%s'):format(source, permission))
        RSGCore.Commands.Refresh(source)
    end
end

---Remove permission from player
---@param source any
---@param permission string
function RSGCore.Functions.RemovePermission(source, permission)
    if permission then
        if IsPlayerAceAllowed(source, permission) then
            ExecuteCommand(('remove_principal player.%s rsgcore.%s'):format(source, permission))
            RSGCore.Commands.Refresh(source)
        end
    else
        for _, v in pairs(RSGCore.Config.Server.Permissions) do
            if IsPlayerAceAllowed(source, v) then
                ExecuteCommand(('remove_principal player.%s rsgcore.%s'):format(source, v))
                RSGCore.Commands.Refresh(source)
            end
        end
    end
end

-- Checking for Permission Level

---Check if player has permission
---@param source any
---@param permission string
---@return boolean
function RSGCore.Functions.HasPermission(source, permission)
    if type(permission) == 'string' then
        if IsPlayerAceAllowed(source, permission) then return true end
    elseif type(permission) == 'table' then
        for _, permLevel in pairs(permission) do
            if IsPlayerAceAllowed(source, permLevel) then return true end
        end
    end

    return false
end

---Get the players permissions
---@param source any
---@return table
function RSGCore.Functions.GetPermission(source)
    local src = source
    local perms = {}
    for _, v in pairs(RSGCore.Config.Server.Permissions) do
        if IsPlayerAceAllowed(src, v) then
            perms[v] = true
        end
    end
    return perms
end

---Get admin messages opt-in state for player
---@param source any
---@return boolean
function RSGCore.Functions.IsOptin(source)
    local license = RSGCore.Functions.GetIdentifier(source, 'license')
    if not license or not RSGCore.Functions.HasPermission(source, 'admin') then return false end
    local Player = RSGCore.Functions.GetPlayer(source)
    return Player.PlayerData.optin
end

---Toggle opt-in to admin messages
---@param source any
function RSGCore.Functions.ToggleOptin(source)
    local license = RSGCore.Functions.GetIdentifier(source, 'license')
    if not license or not RSGCore.Functions.HasPermission(source, 'admin') then return end
    local Player = RSGCore.Functions.GetPlayer(source)
    Player.PlayerData.optin = not Player.PlayerData.optin
    Player.Functions.SetPlayerData('optin', Player.PlayerData.optin)
end

---Check if player is banned
---@param source any
---@return boolean, string?
function RSGCore.Functions.IsPlayerBanned(source)
    local plicense = RSGCore.Functions.GetIdentifier(source, 'license')
    local result = MySQL.single.await('SELECT id, reason, expire FROM bans WHERE license = ?', { plicense })
    if not result then return false end
    if os.time() < result.expire then
        local timeTable = os.date('*t', tonumber(result.expire))
        return true, 'You have been banned from the server:\n' .. result.reason .. '\nYour ban expires ' .. timeTable.day .. '/' .. timeTable.month .. '/' .. timeTable.year .. ' ' .. timeTable.hour .. ':' .. timeTable.min .. '\n'
    else
        MySQL.query('DELETE FROM bans WHERE id = ?', { result.id })
    end
    return false
end

-- Retrieves information about the database connection.
--- @return table; A table containing the database information.
function RSGCore.Functions.GetDatabaseInfo()
    local details = {
        exists = false,
        database = "",
    }
    local connectionString = GetConvar("mysql_connection_string", "")

    if connectionString == "" then
        return details
    elseif connectionString:find("mysql://") then
        connectionString = connectionString:sub(9, -1)
        details.database = connectionString:sub(connectionString:find("/") + 1, -1):gsub("[%?]+[%w%p]*$", "")
        details.exists = true
        return details
    else
        connectionString = { string.strsplit(";", connectionString) }

        for i = 1, #connectionString do
            local v = connectionString[i]
            if v:match("database") then
                details.database = v:sub(10, #v)
                details.exists = true
                return details
            end
        end
    end
end

---Check for duplicate license
---@param license any
---@return boolean
function RSGCore.Functions.IsLicenseInUse(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local playerLicense = RSGCore.Functions.GetIdentifier(player, 'license')
        if playerLicense == license then return true end
    end
    return false
end

-- Utility functions

---Check if a player has an item [deprecated]
---@param source any
---@param items table|string
---@param amount number
---@return boolean
function RSGCore.Functions.HasItem(source, items, amount)
    if GetResourceState('rsg-inventory') == 'missing' then return end
    return exports['rsg-inventory']:HasItem(source, items, amount)
end

---???? ... ok
---@param source any
---@param data any
---@param pattern any
---@return boolean
function RSGCore.Functions.PrepForSQL(source, data, pattern)
    data = tostring(data)
    local src = source
    local player = RSGCore.Functions.GetPlayer(src)
    local result = string.match(data, pattern)
    if not result or string.len(result) ~= string.len(data) then
        TriggerEvent('rsg-log:server:CreateLog', 'anticheat', 'SQL Exploit Attempted', 'red', string.format('%s attempted to exploit SQL!', player.PlayerData.license))
        return false
    end
    return true
end
