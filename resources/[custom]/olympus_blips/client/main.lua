-- Olympus RolePlay — Map blips
-- Καθαρό Lua-only resource (χωρίς NUI/focus), ώστε να μην υπάρχει κίνδυνος για
-- ESC/NUI-stuck bug. Πρόσθεσε νέα blips στον πίνακα `blips` παρακάτω.

local blips = {
    {
        title  = 'Job Center',
        coords = vec3(-169.0, -1640.0, 33.0),
        sprite = 480, -- briefcase
        color  = 6,   -- χρυσό
        scale  = 0.9,
    },
    -- Πρόσθεσε κι άλλα εδώ με το ίδιο pattern:
    -- { title = 'Νοσοκομείο', coords = vec3(...), sprite = 61, color = 1, scale = 0.9 },
}

CreateThread(function()
    for i = 1, #blips do
        local b = blips[i]
        local blip = AddBlipForCoord(b.coords.x, b.coords.y, b.coords.z)
        SetBlipSprite(blip, b.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, b.scale or 0.9)
        SetBlipColour(blip, b.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(b.title)
        EndTextCommandSetBlipName(blip)
    end
end)
