local ESPModule = {}
local espObjects = {}
local espGroups = {}
local instanceConnections = {}
local validationHeartbeat = nil
local objectsToValidate = {}
local lastValidationTime = 0
local VALIDATION_INTERVAL = 0.1

local function cleanupInstance(instanceId)
    if espObjects[instanceId] then
        for groupId, group in pairs(espGroups) do
            group.instances[instanceId] = nil
        end
        
        if instanceConnections[instanceId] then
            for _, connection in ipairs(instanceConnections[instanceId]) do
                connection:Disconnect()
            end
            instanceConnections[instanceId] = nil
        end

        espObjects[instanceId] = nil
    end
end

function ESPModule:Init(sense)
    self.Sense = sense
end

function ESPModule:CreateESP(instance, groupId, customOptions, validateFn)
    if not instance or not groupId then return end
    
    local instanceId = tostring(instance:GetDebugId())
    
    -- Initialize or get the group
    local group = self:InitGroup(groupId)
    
    local options = table.clone(group.options)
    options.enabled = group.enabled
    
    if customOptions then
        for k, v in pairs(customOptions) do
            options[k] = v
            group.options[k] = v
        end
    end
    
    local espObject = self.Sense.AddInstance(instance, options)
    espObject.options.enabled = group.enabled
    
    espObjects[instanceId] = {
        part = instance,
        esp = espObject,
        validateFn = validateFn,
        groupId = groupId,
        lastValidation = true -- Cache the last validation result
    }
    
    group.instances[instanceId] = true
    
    if validateFn then
        objectsToValidate[instanceId] = true
        if not validationHeartbeat then
            validationHeartbeat = game:GetService("RunService").Heartbeat:Connect(function()
                local currentTime = tick()
                if currentTime - lastValidationTime < VALIDATION_INTERVAL then return end
                lastValidationTime = currentTime
                
                for id in pairs(objectsToValidate) do
                    local obj = espObjects[id]
                    if not obj then
                        objectsToValidate[id] = nil
                    else
                        local isValid = obj.validateFn(obj.part)
                        if isValid ~= obj.lastValidation then
                            obj.lastValidation = isValid
                            local group = espGroups[obj.groupId]
                            if group then
                                obj.esp.options.enabled = isValid and group.enabled
                            end
                        end
                    end
                end
            end)
        end
    end
    
    if not instanceConnections[instanceId] then
        instanceConnections[instanceId] = {}
    end
    
    -- Add cleanup logic for validation
    local ancestryConnection
    ancestryConnection = instance.AncestryChanged:Connect(function(_, parent)
        if not parent then
            objectsToValidate[instanceId] = nil
            cleanupInstance(instanceId)
            ancestryConnection:Disconnect()
        end
    end)
    table.insert(instanceConnections[instanceId], ancestryConnection)
    
    return instanceId
end

function ESPModule:InitGroup(groupId, enabled)
    if not espGroups[groupId] then
        espGroups[groupId] = {
            instances = {},
            enabled = enabled or false,
            options = {
                text = "{name}",
                textColor = { Color3.new(1,1,1), 1 },
                textOutline = true,
                textOutlineColor = Color3.new(),
                textSize = 13,
                textFont = 2,
                limitDistance = false,
                maxDistance = 150
            }
        }
    end
    return espGroups[groupId]
end

function ESPModule:SetGroupEnabled(groupId, enabled)
    -- Initialize the group if it doesn't exist
    local group = self:InitGroup(groupId, enabled)
    group.enabled = enabled
    
    for instanceId in pairs(group.instances) do
        if espObjects[instanceId] then
            espObjects[instanceId].esp.options.enabled = enabled
        end
    end

    --CustomDevConsole:Log("esp: " .. tostring(group.enabled) .. " " .. tostring(enabled))
end

function ESPModule:RemoveESP(instanceId)
    cleanupInstance(instanceId)
end

function ESPModule:RemoveGroup(groupId)
    if not espGroups[groupId] then return end
    
    for instanceId in pairs(espGroups[groupId].instances) do
        cleanupInstance(instanceId)
    end
    
    espGroups[groupId] = nil
end

function ESPModule:UpdateGroupOptions(groupId, options)
    if not espGroups[groupId] then return end
    
    -- Store the new options in the group's options table
    for k, v in pairs(options) do
        espGroups[groupId].options[k] = v
    end
    
    -- Apply to all existing instances
    for instanceId in pairs(espGroups[groupId].instances) do
        if espObjects[instanceId] then
            for k, v in pairs(options) do
                espObjects[instanceId].esp.options[k] = v
            end
        end
    end
end

function ESPModule:Cleanup()
    if validationHeartbeat then
        validationHeartbeat:Disconnect()
        validationHeartbeat = nil
    end
    
    objectsToValidate = {}
    
    for _, connections in pairs(instanceConnections) do
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
    end
    
    espObjects = {}
    espGroups = {}
    instanceConnections = {}
end

return ESPModule
