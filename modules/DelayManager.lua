local DelayManager = {}

-- Internal state
local delays = {} -- Store active delays
local nextId = 1 -- Counter for generating unique IDs
local validators = {} -- Store validator functions for each delay

-- Give a new task.delay to manage
function DelayManager:Give(delayTime: number, callback: () -> (), validator: (() -> boolean)?)
    local id = nextId
    nextId += 1

    -- Store the validator if provided
    if validator then
        validators[id] = validator
    end

    -- Store the delay information
    delays[id] = task.delay(delayTime, function()
        callback()
        -- Remove the delay from our tracking once it completes
        delays[id] = nil
        validators[id] = nil
    end)

    return id
end

-- Cancel a specific delay by ID
function DelayManager:Cancel(id: number)
    if delays[id] then
        task.cancel(delays[id])
        delays[id] = nil
        validators[id] = nil
    end
end

-- Cancel all active delays
function DelayManager:CancelAll()
    for id, delay in pairs(delays) do
        task.cancel(delay)
        delays[id] = nil
        validators[id] = nil
    end
end

-- Get count of active delays that pass their validator check
function DelayManager:GetActiveCount()
    local count = 0
    for id in pairs(delays) do
        -- Only count if there's no validator or if validator returns true
        if not validators[id] or validators[id]() then
            count += 1
        end
    end
    return count
end

return DelayManager
