--// ghoul re ac lazy fix
local ContentService = game:GetService("ContentProvider")
local original_metacall

original_metacall = hookmetamethod(game, "__namecall", function(instance, ...)
    local called_method = getnamecallmethod()
    
    if instance == ContentService and (called_method == "GetAssetFetchStatus" or called_method == "GetAssetFetchStatusChangedSignal") then
        return task.wait(9e9)
    end
    
    return original_metacall(instance, ...)
end)

local scripts = {
    [6490954291] = "https://api.luarmor.net/files/v3/loaders/9968755f5ae02a057d9208671aa3576b.lua", --// GHOUL://RE
    [4127666953] = "https://api.luarmor.net/files/v3/loaders/e70c05e220610956e958ce7907e774df.lua", --// DEMON HUNTER
    [2132098792] = "https://api.luarmor.net/files/v3/loaders/44ce714e2ab46ba6769e5852c08209d8.lua", --// HOLLOWED
    [5147866763] = "https://api.luarmor.net/files/v3/loaders/6115fc7d9c941cf9f55a8d823873a76f.lua", --// NINJA
    [6473867634] = "https://api.luarmor.net/files/v3/loaders/7c760d77bb20da00e3e911fd496e2552.lua", --// VEIL
    [7508907071] = "https://api.luarmor.net/files/v3/loaders/bacf24972a79b268ea547360c4c1418d.lua", --// TYPE://RUNE
    [5504799010] = "https://api.luarmor.net/files/v3/loaders/e68579a3c33c252c6341e4074366a9eb.lua", --// SORCERY
}

local GameId = game.GameId

if scripts[GameId] then
    local script = game:HttpGet(scripts[GameId])
    if script then
        loadstring(script)()
    end
end
