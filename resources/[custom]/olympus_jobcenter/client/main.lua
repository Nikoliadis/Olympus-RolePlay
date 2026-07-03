local JOB_CENTER_COORDS = vec4(-169.0, -1640.0, 33.0, 240.0)
local PED_MODEL = `a_m_m_business_01`

local npc = nil
local blip = nil

local function openJobMenu()
    local options = {}

    for i = 1, #OlympusJobs do
        local job = OlympusJobs[i]

        options[i] = {
            title = job.label,
            description = ('%s — €%s/ώρα'):format(job.description, job.wage),
            icon = job.icon,
            onSelect = function()
                lib.callback('olympus_jobcenter:server:selectJob', false, function(success)
                    if success then
                        lib.notify({
                            title = 'Job Center',
                            description = ('Έγινες %s!'):format(job.label),
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'Job Center',
                            description = 'Κάτι πήγε στραβά, δοκίμασε ξανά.',
                            type = 'error'
                        })
                    end
                end, job.name)
            end
        }
    end

    lib.registerContext({
        id = 'olympus_jobcenter_menu',
        title = 'Job Center',
        options = options
    })

    lib.showContext('olympus_jobcenter_menu')
end

local function spawnNpc()
    lib.requestModel(PED_MODEL, 10000)

    npc = CreatePed(4, PED_MODEL, JOB_CENTER_COORDS.x, JOB_CENTER_COORDS.y, JOB_CENTER_COORDS.z - 1.0, JOB_CENTER_COORDS.w, false, true)

    SetEntityHeading(npc, JOB_CENTER_COORDS.w)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_CLIPBOARD', 0, true)
    SetModelAsNoLongerNeeded(PED_MODEL)

    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'olympus_jobcenter_interact',
            icon = 'briefcase',
            label = 'Επιλογή Δουλειάς',
            distance = 2.5,
            onSelect = openJobMenu
        }
    })
end

local function createBlip()
    blip = AddBlipForCoord(JOB_CENTER_COORDS.x, JOB_CENTER_COORDS.y, JOB_CENTER_COORDS.z)
    SetBlipSprite(blip, 407)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.85)
    SetBlipColour(blip, 5) -- κίτρινο/χρυσό
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Job Center')
    EndTextCommandSetBlipName(blip)
end

CreateThread(function()
    createBlip()
    spawnNpc()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    if npc and DoesEntityExist(npc) then
        DeleteEntity(npc)
    end

    if blip then
        RemoveBlip(blip)
    end
end)
