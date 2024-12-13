local scripts = {
    [6490954291] = "https://api.luarmor.net/files/v3/loaders/9968755f5ae02a057d9208671aa3576b.lua", --// GHOUL://RE
    [4127666953] = "https://api.luarmor.net/files/v3/loaders/e70c05e220610956e958ce7907e774df.lua", --// DEMON HUNTER
    [2132098792] = "https://api.luarmor.net/files/v3/loaders/44ce714e2ab46ba6769e5852c08209d8.lua", --// HOLLOWED
}

local GameId = game.GameId

if scripts[GameId] then
    local script = game:HttpGet(scripts[GameId])
    if script then
        loadstring(script)()
    end
end
