local isVisible = false
local currentCash = 0
local currentWeapon = `WEAPON_UNARMED`

local function nui(action, data)
    data = data or {}
    data.action = action
    SendNUIMessage(data)
end

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
