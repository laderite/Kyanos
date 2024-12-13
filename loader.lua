local scripts = {
	[6490954291] = "https://api.luarmor.net/files/v3/loaders/9968755f5ae02a057d9208671aa3576b.lua",
	[69] = "https://example.com/script2.lua",
}

local GameId = game.GameId

if scripts[GameId] then
	local scriptContent = game:HttpGet(scripts[GameId])
	if scriptContent then
		local success, result = pcall(function()
			loadstring(scriptContent)()
		end)
	end
end
