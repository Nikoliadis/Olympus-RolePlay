local JOB_CENTER = vec4(-169.0, -1640.0, 33.0, 240.0)
local DATE_MIN = '1900-01-01'
local DATE_MAX = '2006-12-31'

local creationPromise = nil

-- ---------------------------------------------------
-- Character creation NUI
-- Καλείται από το qbx_core (patched characterDialog) όταν χρειάζεται νέος χαρακτήρας.
-- Επιστρέφει { firstname, lastname, gender = 'male'|'female', birthdate = 'YYYY-MM-DD' } ή nil αν ακυρωθεί.
-- ---------------------------------------------------
exports('openCharacterCreation', function()
    if creationPromise then return nil end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openCreation',
        dateMin = DATE_MIN,
        dateMax = DATE_MAX
    })

    local p = promise.new()
    creationPromise = p

    local result = Citizen.Await(p)
    creationPromise = nil
    return result
end)

RegisterNUICallback('olympus_spawn:submitCreation', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeCreation' })

    if creationPromise then
        creationPromise:resolve(data)
    end

    cb('ok')
end)

RegisterNUICallback('olympus_spawn:cancelCreation', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeCreation' })

    if creationPromise then
        creationPromise:resolve(nil)
    end

    cb('ok')
end)

-- ---------------------------------------------------
-- Lua-level fallback για ESC: αν για οποιονδήποτε λόγο το NUI (JS) δεν
-- απαντήσει (π.χ. σφάλμα πριν προλάβει να ανοίξει σωστά το overlay), αυτό
-- εγγυάται ότι το NUI focus δεν μένει κολλημένο για πάντα, μπλοκάροντας
-- βελάκια/ESC στο υπόλοιπο παιχνίδι (π.χ. vMenu, pause menu).
-- INPUT_FRONTEND_PAUSE = 200, INPUT_FRONTEND_PAUSE_ALTERNATE = 322
-- ---------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)
        if creationPromise then
            if IsDisabledControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 322)
                or IsControlJustPressed(0, 200) or IsControlJustPressed(0, 322) then
                SetNuiFocus(false, false)
                SendNUIMessage({ action = 'closeCreation' })
                local p = creationPromise
                creationPromise = nil
                p:resolve(nil)
            end
        else
            Wait(500)
        end
    end
end)

-- ---------------------------------------------------
-- Cinematic spawn στο Job Center
-- Καλείται από το qbx_core (patched createCharacter) αμέσως μετά τη δημιουργία χαρακτήρα.
-- ---------------------------------------------------
RegisterNetEvent('olympus_spawn:client:spawnAtJobCenter', function()
    local ped = cache.ped

    DoScreenFadeOut(400)
    while not IsScreenFadedOut() do Wait(0) end

    DisplayRadar(false)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    SetEntityCoordsNoOffset(ped, JOB_CENTER.x, JOB_CENTER.y, JOB_CENTER.z, false, false, false)
    SetEntityHeading(ped, JOB_CENTER.w)

    -- Establishing shot: κάμερα λίγο ψηλότερα/πλάγια από τον χαρακτήρα, βλέποντας
    -- προς το Job Center, πριν αποκαλυφθεί ο παίκτης.
    local camCoords = GetOffsetFromEntityInWorldCoords(ped, 6.0, -6.0, 4.0)
    local cam = CreateCamWithParams(
        'DEFAULT_SCRIPTED_CAMERA',
        camCoords.x, camCoords.y, camCoords.z,
        -18.0, 0.0, JOB_CENTER.w - 135.0,
        45.0, false, 0
    )
    PointCamAtEntity(cam, ped, 0.0, 0.0, 0.6, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)

    DoScreenFadeIn(800)
    Wait(3200)

    -- Reveal: ο χαρακτήρας γίνεται ορατός, η κάμερα επιστρέφει ομαλά στον παίκτη.
    SetEntityVisible(ped, true, false)
    RenderScriptCams(false, true, 800, true, true)
    Wait(850)

    SetCamActive(cam, false)
    DestroyCam(cam, true)
    FreezeEntityPosition(ped, false)
    DisplayRadar(true)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)
