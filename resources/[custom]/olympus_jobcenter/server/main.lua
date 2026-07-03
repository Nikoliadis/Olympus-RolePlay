local validJobs = {}

for i = 1, #OlympusJobs do
    validJobs[OlympusJobs[i].name] = true
end

lib.callback.register('olympus_jobcenter:server:selectJob', function(source, jobName)
    if not validJobs[jobName] then
        lib.print.warn(('%s attempted to select an invalid job center job: %s'):format(source, tostring(jobName)))
        return false
    end

    local success = exports.qbx_core:SetJob(source, jobName, 0)
    return success and true or false
end)
