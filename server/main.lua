local pendingRequests = {}
local requestCooldowns = {}
local hostagesByAggressor = {}
local hostagesByVictim = {}

local function notify(playerId, message)
    TriggerClientEvent('nova_interactions:notify', playerId, message)
end

local function isSimpleInteractionValid(interactionType)
    return Config.SimpleInteractions[interactionType] ~= nil
end

local function isPlayerOnline(playerId)
    return GetPlayerName(playerId) ~= nil
end

local function clearPendingFromPlayer(playerId)
    pendingRequests[playerId] = nil

    for targetId, request in pairs(pendingRequests) do
        if request.from == playerId then
            pendingRequests[targetId] = nil
        end
    end
end

local function releaseHostagePair(aggressorId, reasonForAggressor, reasonForVictim)
    local victimId = hostagesByAggressor[aggressorId]
    if not victimId then
        return
    end

    hostagesByAggressor[aggressorId] = nil
    hostagesByVictim[victimId] = nil

    if isPlayerOnline(aggressorId) then
        TriggerClientEvent('nova_interactions:endHostage', aggressorId, reasonForAggressor or 'Hostage ended.')
    end

    if isPlayerOnline(victimId) then
        TriggerClientEvent('nova_interactions:endHostage', victimId, reasonForVictim or 'Hostage ended.')
    end
end

local function releaseByPlayer(playerId, reason)
    if hostagesByAggressor[playerId] then
        releaseHostagePair(playerId, reason or 'You released the hostage.', 'You were released.')
        return
    end

    local aggressorId = hostagesByVictim[playerId]
    if aggressorId then
        releaseHostagePair(aggressorId, reason or 'Hostage ended.', 'Hostage ended.')
    end
end

RegisterNetEvent('nova_interactions:request', function(targetId, interactionType)
    local sourceId = source

    if type(targetId) ~= 'number' or not isPlayerOnline(targetId) then
        notify(sourceId, 'Target player not found.')
        return
    end

    if sourceId == targetId then
        notify(sourceId, 'You cannot interact with yourself.')
        return
    end

    if not isSimpleInteractionValid(interactionType) then
        notify(sourceId, 'Invalid interaction type.')
        return
    end

    local now = GetGameTimer()
    if requestCooldowns[sourceId] and requestCooldowns[sourceId] > now then
        notify(sourceId, 'Please wait before sending another interaction request.')
        return
    end

    requestCooldowns[sourceId] = now + Config.RequestCooldownMs

    pendingRequests[targetId] = {
        from = sourceId,
        interactionType = interactionType,
        expiresAt = now + Config.RequestTimeoutMs
    }

    TriggerClientEvent('nova_interactions:incomingRequest', targetId, sourceId, interactionType, Config.RequestTimeoutMs)

    notify(sourceId, ('Request sent to player %s for %s.'):format(targetId, interactionType))
    notify(targetId, ('Player %s requested %s.'):format(sourceId, interactionType))
end)

RegisterNetEvent('nova_interactions:acceptRequest', function()
    local targetId = source
    local request = pendingRequests[targetId]

    if not request then
        notify(targetId, 'No pending interaction request.')
        return
    end

    pendingRequests[targetId] = nil

    if GetGameTimer() > request.expiresAt then
        notify(targetId, 'This interaction request expired.')
        if isPlayerOnline(request.from) then
            notify(request.from, 'Your interaction request expired.')
        end
        return
    end

    if not isPlayerOnline(request.from) then
        notify(targetId, 'Requester is no longer online.')
        return
    end

    TriggerClientEvent('nova_interactions:startSimpleInteraction', request.from, request.interactionType, 'initiator', targetId)
    TriggerClientEvent('nova_interactions:startSimpleInteraction', targetId, request.interactionType, 'target', request.from)

    notify(request.from, ('Player %s accepted your %s request.'):format(targetId, request.interactionType))
    notify(targetId, ('You accepted %s from player %s.'):format(request.interactionType, request.from))
end)

RegisterNetEvent('nova_interactions:declineRequest', function()
    local targetId = source
    local request = pendingRequests[targetId]

    if not request then
        notify(targetId, 'No pending interaction request.')
        return
    end

    pendingRequests[targetId] = nil

    notify(targetId, 'Interaction declined.')
    if isPlayerOnline(request.from) then
        notify(request.from, ('Player %s declined your %s request.'):format(targetId, request.interactionType))
    end
end)

RegisterNetEvent('nova_interactions:hostageStart', function(targetId)
    local sourceId = source

    if not Config.Hostage.enabled then
        notify(sourceId, 'Hostage interaction is disabled.')
        return
    end

    if type(targetId) ~= 'number' or not isPlayerOnline(targetId) then
        notify(sourceId, 'Target player not found.')
        return
    end

    if sourceId == targetId then
        notify(sourceId, 'You cannot target yourself.')
        return
    end

    if hostagesByAggressor[sourceId] or hostagesByVictim[sourceId] then
        notify(sourceId, 'You are already involved in a hostage interaction.')
        return
    end

    if hostagesByAggressor[targetId] or hostagesByVictim[targetId] then
        notify(sourceId, 'Target is already in a hostage interaction.')
        return
    end

    hostagesByAggressor[sourceId] = targetId
    hostagesByVictim[targetId] = sourceId

    TriggerClientEvent('nova_interactions:hostageBeginAggressor', sourceId, targetId)
    TriggerClientEvent('nova_interactions:hostageBeginVictim', targetId, sourceId)

    notify(sourceId, ('You took player %s hostage.'):format(targetId))
    notify(targetId, ('Player %s took you hostage.'):format(sourceId))
end)

RegisterNetEvent('nova_interactions:hostageRelease', function()
    local sourceId = source

    if not hostagesByAggressor[sourceId] and not hostagesByVictim[sourceId] then
        return
    end

    releaseByPlayer(sourceId, 'Hostage released.')
end)

RegisterNetEvent('nova_interactions:hostageExecute', function()
    local sourceId = source
    local victimId = hostagesByAggressor[sourceId]

    if not victimId then
        notify(sourceId, 'You are not holding anyone hostage.')
        return
    end

    if isPlayerOnline(victimId) then
        TriggerClientEvent('nova_interactions:hostageExecuteVictim', victimId)
    end

    releaseHostagePair(sourceId, 'You executed the hostage.', 'You were executed.')
end)

AddEventHandler('playerDropped', function()
    local playerId = source

    clearPendingFromPlayer(playerId)
    releaseByPlayer(playerId, 'Hostage ended because one player disconnected.')

    requestCooldowns[playerId] = nil
end)

CreateThread(function()
    while true do
        Wait(5000)

        local now = GetGameTimer()

        for targetId, request in pairs(pendingRequests) do
            if now > request.expiresAt then
                pendingRequests[targetId] = nil

                if isPlayerOnline(targetId) then
                    notify(targetId, 'Interaction request expired.')
                end

                if isPlayerOnline(request.from) then
                    notify(request.from, 'Your interaction request expired.')
                end
            end
        end
    end
end)
