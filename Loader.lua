local loader = Instance.new("ScreenGui")
loader.Name = "Loader"
loader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local holder = Instance.new("Frame")
holder.Name = "Holder"
holder.AnchorPoint = Vector2.new(0.5, 0.5)
holder.AutomaticSize = Enum.AutomaticSize.XY
holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
holder.BackgroundTransparency = 1
holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
holder.BorderSizePixel = 0
holder.Position = UDim2.fromScale(0.5, 0.5)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.FontFace = Font.new(
    "rbxassetid://12187365364",
    Enum.FontWeight.Heavy,
    Enum.FontStyle.Normal
)
title.Text = "ETHOS SUITE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 100
title.TextTransparency = 0.5
title.TextWrapped = true
title.AutomaticSize = Enum.AutomaticSize.XY
title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.BorderColor3 = Color3.fromRGB(0, 0, 0)
title.BorderSizePixel = 0
title.Size = UDim2.fromOffset(200, 50)
title.Parent = holder

local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "UIListLayout"
uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uIListLayout.Parent = holder

local status = Instance.new("TextLabel")
status.Name = "Status"
status.FontFace = Font.new(
    "rbxassetid://12187365364",
    Enum.FontWeight.SemiBold,
    Enum.FontStyle.Normal
)
status.Text = "loading..."
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextSize = 48
status.TextTransparency = 0.5
status.TextWrapped = true
status.AutomaticSize = Enum.AutomaticSize.XY
status.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
status.BackgroundTransparency = 1
status.BorderColor3 = Color3.fromRGB(0, 0, 0)
status.BorderSizePixel = 0
status.Size = UDim2.fromOffset(200, 50)
status.Parent = holder

holder.Parent = loader

local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
uIAspectRatioConstraint.AspectRatio = 3.71
uIAspectRatioConstraint.Parent = loader

local EthosLoader = {}
local last_status_update_time = tick()

function EthosLoader.set_status(text)
	local current_time = tick()
	local time_diff_ms = math.floor((current_time - last_status_update_time) * 1000)
	last_status_update_time = current_time
	status.Text = text
    warn('Loader: ' .. text .. ' (' .. time_diff_ms .. 'ms)')
end

function EthosLoader.destroy()
	if loader and loader.Parent then
		loader:Destroy()
	end
	getgenv().EthosLoader = nil
end

getgenv().EthosLoader = EthosLoader

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

loader.Archivable = false
loader.Parent = game:GetService("CoreGui")

ProtectGui(loader)

task.delay(30, function()
	pcall(function()
		EthosLoader.destroy()
	end)
end)

local scripts = {
    [6490954291] = "https://api.luarmor.net/files/v3/loaders/9968755f5ae02a057d9208671aa3576b.lua", --// GHOUL://RE
    [4127666953] = "https://api.luarmor.net/files/v3/loaders/e70c05e220610956e958ce7907e774df.lua", --// DEMON HUNTER
    [2132098792] = "https://api.luarmor.net/files/v3/loaders/44ce714e2ab46ba6769e5852c08209d8.lua", --// HOLLOWED
    [5147866763] = "https://api.luarmor.net/files/v3/loaders/6115fc7d9c941cf9f55a8d823873a76f.lua", --// NINJA
    [6473867634] = "https://api.luarmor.net/files/v3/loaders/7c760d77bb20da00e3e911fd496e2552.lua", --// VEIL
    [7508907071] = "https://api.luarmor.net/files/v3/loaders/bacf24972a79b268ea547360c4c1418d.lua", --// TYPE://RUNE
    [5504799010] = "https://api.luarmor.net/files/v3/loaders/e68579a3c33c252c6341e4074366a9eb.lua", --// SORCERY
    [5091734860] = "https://api.luarmor.net/files/v3/loaders/ac70401440c41b42d7e56b727877f505.lua", --// HEIAN
}

local GameId = game.GameId

if scripts[GameId] then
    local script = game:HttpGet(scripts[GameId])
    if script then
        loadstring(script)()
    end
end
