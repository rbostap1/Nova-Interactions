local pendingRequest = nil
local hostageState = {
    isAggressor = false,
    isVictim = false,
    otherServerId = nil
}

local function notify(message)
    TriggerEvent('chat:addMessage', {
        color = { 255, 204, 102 },
        multiline = false,
        args = { Config.NotifyPrefix, message }
    })
end

local function getSimpleInteractionNames()
    local names = {}

    for interactionName, _ in pairs(Config.SimpleInteractions) do
        names[#names + 1] = interactionName
    end

    table.sort(names)
    return names
end

local function sendInteractionListMessages()
    local names = getSimpleInteractionNames()
    local chunkSize = 12

    notify(('Total interactions: %s'):format(#names))

    for i = 1, #names, chunkSize do
        local chunk = {}

        for j = i, math.min(i + chunkSize - 1, #names) do
            chunk[#chunk + 1] = names[j]
        end

        notify('Interactions: ' .. table.concat(chunk, ', '))
    end
end

local function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then
        return true
    end

    RequestAnimDict(dict)
    local timeoutAt = GetGameTimer() + 5000

    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeoutAt then
            return false
        end

        Wait(50)
    end

    return true
end

local function getClosestPlayer(maxDistance)
    local localPed = PlayerPedId()
    local localCoords = GetEntityCoords(localPed)

    local closestPlayer = -1
    local closestDistance = maxDistance + 0.01

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(localCoords - targetCoords)

            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = playerId
            end
        end
    end

    return closestPlayer, closestDistance
end

local function isHoldingValidHostageWeapon()
    local playerPed = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(playerPed)

    for _, weaponName in ipairs(Config.Hostage.requiredWeapons) do
        if currentWeapon == GetHashKey(weaponName) then
            return true
        end
    end

    return false
end

local function clearHostageState()
    local ped = PlayerPedId()

    DetachEntity(ped, true, false)
    ClearPedTasks(ped)

    hostageState.isAggressor = false
    hostageState.isVictim = false
    hostageState.otherServerId = nil
end

local function performSimpleInteraction(interactionType, role, otherServerId)
    local interaction = Config.SimpleInteractions[interactionType]

    if not interaction then
        notify('Unknown interaction requested by server.')
        return
    end

    local animationName = interaction.initiatorAnim
    if role == 'target' then
        animationName = interaction.targetAnim
    end

    if not loadAnimDict(interaction.dict) then
        notify('Could not load animation for interaction.')
        return
    end

    local localPed = PlayerPedId()
    local otherPlayer = GetPlayerFromServerId(otherServerId)

    if otherPlayer ~= -1 then
        local otherPed = GetPlayerPed(otherPlayer)
        TaskTurnPedToFaceEntity(localPed, otherPed, 500)
        Wait(400)
    end

    TaskPlayAnim(localPed, interaction.dict, animationName, 8.0, -8.0, interaction.durationMs, 0, 0.0, false, false, false)

    CreateThread(function()
        Wait(interaction.durationMs + 100)
        if not hostageState.isAggressor and not hostageState.isVictim then
            ClearPedTasks(localPed)
        end
    end)
end

local function beginHostageAsAggressor(targetServerId)
    if hostageState.isAggressor or hostageState.isVictim then
        notify('You are already in an interaction state.')
        return
    end

    if not loadAnimDict(Config.Hostage.animDict) then
        notify('Could not load hostage animation.')
        return
    end

    hostageState.isAggressor = true
    hostageState.otherServerId = targetServerId

    local ped = PlayerPedId()
    TaskPlayAnim(ped, Config.Hostage.animDict, Config.Hostage.aggressorAnim, 8.0, -8.0, -1, 49, 0.0, false, false, false)

    notify('Hostage active. Press G to release, H to execute.')
end

local function beginHostageAsVictim(aggressorServerId)
    if hostageState.isAggressor or hostageState.isVictim then
        clearHostageState()
    end

    if not loadAnimDict(Config.Hostage.animDict) then
        notify('Could not load hostage animation.')
        return
    end

    hostageState.isVictim = true
    hostageState.otherServerId = aggressorServerId

    local ped = PlayerPedId()
    local aggressorPlayer = GetPlayerFromServerId(aggressorServerId)

    if aggressorPlayer == -1 then
        notify('Aggressor is not available.')
        clearHostageState()
        return
    end

    local aggressorPed = GetPlayerPed(aggressorPlayer)
    local attach = Config.Hostage.victimAttach

    AttachEntityToEntity(
        ped,
        aggressorPed,
        attach.bone,
        attach.xPos,
        attach.yPos,
        attach.zPos,
        attach.xRot,
        attach.yRot,
        attach.zRot,
        attach.useSoftPinning,
        attach.collision,
        attach.isPed,
        attach.vertexIndex,
        attach.fixedRot
    )

    TaskPlayAnim(ped, Config.Hostage.animDict, Config.Hostage.victimAnim, 8.0, -8.0, -1, 49, 0.0, false, false, false)
    notify('You are being held hostage.')
end

local function tryStartHostage()
    if not Config.Hostage.enabled then
        notify('Hostage interaction is disabled on this server.')
        return
    end

    if hostageState.isAggressor or hostageState.isVictim then
        notify('You are already in a hostage state.')
        return
    end

    if not isHoldingValidHostageWeapon() then
        notify('You must hold a configured pistol to take a hostage.')
        return
    end

    local targetPlayer, distance = getClosestPlayer(Config.Hostage.interactionDistance)

    if targetPlayer == -1 then
        notify('No player nearby to take hostage.')
        return
    end

    if distance > Config.Hostage.interactionDistance then
        notify('Target is too far away.')
        return
    end

    local targetServerId = GetPlayerServerId(targetPlayer)
    TriggerServerEvent('nova_interactions:hostageStart', targetServerId)
end

RegisterCommand('interact', function(_, args)
    local interactionType = string.lower(args[1] or '')

    if interactionType == '' then
        notify('Usage: /interact <interactionName> | /interact hostage')
        notify('Use /interactions to list all available interaction names.')
        return
    end

    if interactionType == 'hostage' then
        tryStartHostage()
        return
    end

    local interaction = Config.SimpleInteractions[interactionType]
    if not interaction then
        notify(('Unknown interaction: %s'):format(interactionType))
        notify('Use /interactions to list all available interaction names.')
        return
    end

    local targetPlayer, distance = getClosestPlayer(Config.DefaultInteractDistance)

    if targetPlayer == -1 or distance > Config.DefaultInteractDistance then
        notify('No player nearby for that interaction.')
        return
    end

    local targetServerId = GetPlayerServerId(targetPlayer)
    TriggerServerEvent('nova_interactions:request', targetServerId, interactionType)
end, false)

RegisterCommand('hostage', function()
    tryStartHostage()
end, false)

RegisterCommand('ia', function()
    if not pendingRequest then
        notify('You have no pending interaction request.')
        return
    end

    TriggerServerEvent('nova_interactions:acceptRequest')
    pendingRequest = nil
end, false)

RegisterCommand('id', function()
    if not pendingRequest then
        notify('You have no pending interaction request.')
        return
    end

    TriggerServerEvent('nova_interactions:declineRequest')
    pendingRequest = nil
end, false)

RegisterCommand('interactions', function()
    sendInteractionListMessages()
    notify('Other commands: /hostage, /ia, /id')
end, false)

RegisterNetEvent('nova_interactions:notify', function(message)
    notify(message)
end)

RegisterNetEvent('nova_interactions:incomingRequest', function(fromServerId, interactionType, timeoutMs)
    pendingRequest = {
        fromServerId = fromServerId,
        interactionType = interactionType,
        expiresAt = GetGameTimer() + timeoutMs
    }

    notify(('Player %s requests %s. Use /ia to accept or /id to decline.'):format(fromServerId, interactionType))
end)

RegisterNetEvent('nova_interactions:startSimpleInteraction', function(interactionType, role, otherServerId)
    performSimpleInteraction(interactionType, role, otherServerId)
end)

RegisterNetEvent('nova_interactions:hostageBeginAggressor', function(targetServerId)
    beginHostageAsAggressor(targetServerId)
end)

RegisterNetEvent('nova_interactions:hostageBeginVictim', function(aggressorServerId)
    beginHostageAsVictim(aggressorServerId)
end)

RegisterNetEvent('nova_interactions:endHostage', function(message)
    clearHostageState()
    if message and message ~= '' then
        notify(message)
    end
end)

RegisterNetEvent('nova_interactions:hostageExecuteVictim', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 0)
    clearHostageState()
end)

CreateThread(function()
    while true do
        Wait(0)

        if pendingRequest and GetGameTimer() > pendingRequest.expiresAt then
            pendingRequest = nil
            notify('Interaction request expired.')
        end

        if hostageState.isAggressor then
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 140, true)

            if IsControlJustPressed(0, Config.Hostage.controls.release) then
                TriggerServerEvent('nova_interactions:hostageRelease')
            end

            if IsControlJustPressed(0, Config.Hostage.controls.execute) then
                TriggerServerEvent('nova_interactions:hostageExecute')
            end
        elseif hostageState.isVictim then
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 23, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)

            local aggressorPlayer = GetPlayerFromServerId(hostageState.otherServerId or -1)
            if aggressorPlayer == -1 then
                TriggerServerEvent('nova_interactions:hostageRelease')
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    clearHostageState()
end)
