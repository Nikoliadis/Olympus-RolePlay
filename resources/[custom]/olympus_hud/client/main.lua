local isVisible = false
local currentCash = 0
local currentWeapon = `WEAPON_UNARMED`

local function nui(action, data)
    data = data or {}
    data.action = action
    SendNUIMessage(data)
end

-- ---------------------------------------------------
-- Emergency unstick: αν κάποιο resource αφήσει το NUI focus κολλημένο
-- (π.χ. login/character creation NUI που δεν έκλεισε σωστά), τα βελάκια/ESC
-- σταματούν να φτάνουν στο παιχνίδι. Διαθέσιμο ΚΑΙ ως keybind (F10) ώστε να
-- μη χρειάζεται να θυμάται κανείς να πληκτρολογήσει /fixui — δουλεύει πάντα,
-- ακόμα κι αν κάποιο NUI έχει το focus αυτή τη στιγμή.
-- ---------------------------------------------------
local function fixUi()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    lib.notify({
        title = 'Olympus RolePlay',
        description = 'NUI focus reset. Δοκίμασε ξανά τα βελάκια/ESC.',
        type = 'inform'
    })
end

RegisterKeyMapping('fixui', 'Olympus RolePlay: Emergency NUI focus reset', 'keyboard', 'F10')
RegisterCommand('fixui', fixUi, false)

-- ---------------------------------------------------
-- Health / Armor / Stamina — client-side statebags
-- (πολλαπλά resources μπορούν να διαβάσουν LocalPlayer.state.olympus* αν χρειαστεί)
-- ---------------------------------------------------
local function updateVitalsState()
    local ped = cache.ped
    if not ped or not DoesEntityExist(ped) then return end

    local maxHealth = GetEntityMaxHealth(ped) - 100
    local health = math.max(0, math.min(100, math.floor((GetEntityHealth(ped) - 100) / maxHealth * 100 + 0.5)))
    local armor = math.max(0, math.min(100, GetPedArmour(ped)))
    local stamina = math.max(0, math.min(100, math.floor(GetPlayerSprintStaminaRemaining(cache.playerId))))

    LocalPlayer.state:set('olympusHealth', health, false)
    LocalPlayer.state:set('olympusArmor', armor, false)
    LocalPlayer.state:set('olympusStamina', stamina, false)
end

AddStateBagChangeHandler('olympusHealth', ('player:%s'):format(cache.playerId), function(_, _, value)
    if not isVisible then return end
    nui('updateBar', { bar = 'health', value = value })
end)

AddStateBagChangeHandler('olympusArmor', ('player:%s'):format(cache.playerId), function(_, _, value)
    if not isVisible then return end
    nui('updateBar', { bar = 'armor', value = value })
end)

AddStateBagChangeHandler('olympusStamina', ('player:%s'):format(cache.playerId), function(_, _, value)
    if not isVisible then return end
    nui('updateBar', { bar = 'stamina', value = value })
end)

-- ---------------------------------------------------
-- Hunger / Thirst — τα statebags τα διαχειρίζεται ήδη το qbx_core
-- (Player(source).state:set('hunger'/'thirst', ..., true) server-side)
-- ---------------------------------------------------
AddStateBagChangeHandler('hunger', ('player:%s'):format(cache.playerId), function(_, _, value)
    if not isVisible then return end
    nui('updateBar', { bar = 'hunger', value = value })
end)

AddStateBagChangeHandler('thirst', ('player:%s'):format(cache.playerId), function(_, _, value)
    if not isVisible then return end
    nui('updateBar', { bar = 'thirst', value = value })
end)

-- ---------------------------------------------------
-- Money — qbx_core στέλνει dedicated event ακριβώς για HUD resources
-- ---------------------------------------------------
RegisterNetEvent('hud:client:OnMoneyChange', function(moneyType, amount, isRemove)
    if moneyType ~= 'cash' then return end

    currentCash = math.max(0, currentCash + (isRemove and -amount or amount))
    if isVisible then
        nui('updateCash', { value = currentCash })
    end
end)

-- ---------------------------------------------------
-- Job
-- ---------------------------------------------------
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
    if isVisible then
        nui('updateJob', { label = jobInfo.label, grade = jobInfo.grade.name })
    end
end)

-- ---------------------------------------------------
-- PlayerData — full resync (login, ή οτιδήποτε αλλάξει γενικά)
-- ---------------------------------------------------
local function syncFromPlayerData()
    local playerData = exports.qbx_core:GetPlayerData()
    if not playerData or not playerData.citizenid then return end

    currentCash = playerData.money and playerData.money.cash or 0

    nui('fullSync', {
        cash = currentCash,
        job = {
            label = playerData.job and playerData.job.label or '—',
            grade = playerData.job and playerData.job.grade.name or ''
        }
    })
end

RegisterNetEvent('QBCore:Player:SetPlayerData', function()
    if isVisible then syncFromPlayerData() end
end)

-- ---------------------------------------------------
-- Ammo — εμφανίζεται μόνο όταν κρατάς όπλο
-- ---------------------------------------------------
local function updateAmmo()
    local ped = cache.ped
    if not ped or not DoesEntityExist(ped) then return end

    local hasWeapon, weapon = GetCurrentPedWeapon(ped, true)

    if not hasWeapon or weapon == `WEAPON_UNARMED` then
        if currentWeapon ~= `WEAPON_UNARMED` then
            currentWeapon = `WEAPON_UNARMED`
            nui('updateAmmo', { visible = false })
        end
        return
    end

    local ammo = GetAmmoInPedWeapon(ped, weapon)
    currentWeapon = weapon
    nui('updateAmmo', { visible = true, value = ammo })
end

-- ---------------------------------------------------
-- Ρολόι server (24h format, πραγματική ώρα)
-- ---------------------------------------------------
local function updateClock()
    nui('updateClock', { value = os.date('%H:%M') })
end

-- ---------------------------------------------------
-- Voice / Mic — pma-voice integration (proximity mode + αν μιλάει τώρα)
-- ---------------------------------------------------
local lastTalking = nil
local lastVoiceMode = nil
local function updateVoice()
    local mode = 'Normal'
    local talking = false

    if GetResourceState('pma-voice') == 'started' then
        local t = MumbleIsPlayerTalking(cache.playerId)
        talking = t == true or t == 1
        local prox = LocalPlayer.state.proximity
        if prox and prox.mode then mode = prox.mode end
    end

    -- Στέλνουμε μόνο όταν αλλάζει κάτι (λιγότερα NUI messages).
    if talking ~= lastTalking or mode ~= lastVoiceMode then
        lastTalking = talking
        lastVoiceMode = mode
        nui('updateVoice', { mode = mode, talking = talking })
    end
end

-- ---------------------------------------------------
-- Show / Hide
-- ---------------------------------------------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isVisible = true
    nui('show')
    syncFromPlayerData()
    updateVitalsState()
    updateClock()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isVisible = false
    nui('hide')
end)

-- ---------------------------------------------------
-- Loops
-- ---------------------------------------------------
CreateThread(function()
    while true do
        Wait(500)
        if isVisible then
            updateVitalsState()
            updateAmmo()
        end
    end
end)

-- Το mic indicator πρέπει να είναι responsive (η ομιλία αλλάζει γρήγορα).
CreateThread(function()
    while true do
        Wait(150)
        if isVisible then
            updateVoice()
        end
    end
end)

CreateThread(function()
    while true do
        Wait(15000)
        if isVisible then
            updateClock()
        end
    end
end)

-- Αν το resource κάνει restart ενώ ο παίκτης είναι ήδη μέσα (π.χ. ensure hot-reload)
CreateThread(function()
    Wait(1000)
    local playerData = exports.qbx_core:GetPlayerData()
    if playerData and playerData.citizenid then
        isVisible = true
        nui('show')
        syncFromPlayerData()
        updateVitalsState()
        updateClock()
    end
end)
