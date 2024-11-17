local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    local self = setmetatable({
        _connections = {},
        _objects = {},
        _tasks = {}
    }, ConnectionManager)
    return self
end

-- Add a connection to be managed
function ConnectionManager:connect(connection)
    table.insert(self._connections, connection)
    return connection
end

-- Add an object with a cleanup method (like Destroy or Disconnect)
function ConnectionManager:add(object, cleanupMethod)
    table.insert(self._objects, {
        instance = object,
        cleanup = cleanupMethod or "Destroy"
    })
    return object
end

-- Add a task/function to be executed during cleanup
function ConnectionManager:addTask(task)
    if type(task) == "function" then
        table.insert(self._tasks, task)
    end
    return task
end

-- Cleanup everything
function ConnectionManager:cleanup()
    -- Disconnect all connections
    for _, connection in ipairs(self._connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    
    -- Clean up objects
    for _, obj in ipairs(self._objects) do
        local instance = obj.instance
        local cleanup = obj.cleanup
        
        if instance and typeof(instance) == "table" and instance[cleanup] then
            instance[cleanup](instance)
        end
    end
    
    -- Execute cleanup tasks
    for _, task in ipairs(self._tasks) do
        task()
    end
    
    -- Clear all tables
    table.clear(self._connections)
    table.clear(self._objects)
    table.clear(self._tasks)
end

return ConnectionManager
