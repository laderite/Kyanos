local scripts = {
    [6490954291] = "https://api.luarmor.net/files/v3/loaders/9968755f5ae02a057d9208671aa3576b.lua", --// GHOUL://RE
    [4127666953] = "https://api.luarmor.net/files/v3/loaders/e70c05e220610956e958ce7907e774df.lua", --// DEMON HUNTER
    [2132098792] = "https://api.luarmor.net/files/v3/loaders/44ce714e2ab46ba6769e5852c08209d8.lua", --// HOLLOWED
    [5147866763] = "https://api.luarmor.net/files/v3/loaders/6115fc7d9c941cf9f55a8d823873a76f.lua", --// NINJA
    [6473867634] = "https://api.luarmor.net/files/v3/loaders/7c760d77bb20da00e3e911fd496e2552.lua", --// VEIL
}

local GameId = game.GameId

if scripts[GameId] then
    local script = game:HttpGet(scripts[GameId])
    if script then
        loadstring(script)()
    end
end
