local UniversalBuilder = {
    Maid = nil,
    Library = nil,
}

local Player = loadstring(
        game:HttpGet("https://raw.githubusercontent.com/laderite/Kyanos/refs/heads/main/modules/Player.lua")
    )()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local camera = workspace.CurrentCamera

function UniversalBuilder:SetMaid(maid)
    self.Maid = maid
end

function UniversalBuilder:SetLibrary(library)
    self.Library = library
end

function UniversalBuilder:Cleanup()
    self.Maid:DoCleaning()
end

function UniversalBuilder:Build(Tab)
    local Options = self.Library.Options

    local PlayerSection = Tab:AddSection({ Title = "PLAYER" })

    PlayerSection:AddToggle("InfiniteJump", {
        Title = "Infinite Jump",
        Description = "Allows you to jump in mid-air",
        Default = false,
        Callback = function(Value)
            if not Value then
                self.Maid.infiniteJump = nil
                return
            end

            self.Maid.infiniteJump = UserInputService.JumpRequest:Connect(function()
                local Humanoid = Player.getHumanoid()
                if Humanoid then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end,
    })

    PlayerSection:AddSlider("HipHeight", {
        Title = "Hip Height",
        Description = "Adjust your character's hip height",
        Default = 0,
        Min = -20,
        Max = 200,
        Rounding = 0,
        Callback = function(Value)
            local Humanoid = Player.getHumanoid()
            if Humanoid then
                Humanoid.HipHeight = Value
            end
        end,
    })

    PlayerSection:AddToggle("NoClip", {
        Title = "NoClip",
        Description = "Allows you to pass through solid objects",
        Default = false,
        Callback = function(Value)
            if not Value then
                self.Maid.noClip = nil
                local character = Player.getCharacter()
                if character and self.originalCollisions then
                    for part, originalCanCollide in pairs(self.originalCollisions) do
                        if part and part.Parent then
                            part.CanCollide = originalCanCollide
                        end
                    end
                end
                self.originalCollisions = nil
                return
            end

            self.originalCollisions = {}
            local character = Player.getCharacter()
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        self.originalCollisions[part] = part.CanCollide
                    end
                end
            end

            self.Maid.noClip = RunService.Heartbeat:Connect(function()
                local character = Player.getCharacter()
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end,
    })

    local MovementSection = Tab:AddSection({ Title = "MOVEMENT" })
    MovementSection:AddToggle("Speedhack", {
        Title = "Speed",
        Description = "Enables speed modification for your character using different methods",
        Default = false,
        Callback = function(Value)
            if not Value then
                self.Maid.speedHack = nil

                local Humanoid = Player.getHumanoid()
                if Humanoid then
                    Humanoid.WalkSpeed = 16
                end

                local RootPart = Player.getRootPart()
                if RootPart then
                    RootPart.Velocity = Vector3.new(0, RootPart.Velocity.Y, 0)
                end

                return
            end

            self.Maid.speedHack = RunService.Heartbeat:Connect(function()
                local Humanoid, HumanoidRootPart = Player.getHumanoid(), Player.getRootPart()
                if not Humanoid or not HumanoidRootPart then
                    return
                end

                local method = Options.SpeedMethod.Value
                local speed = Options.Speed.Value

                if not UserInputService:GetFocusedTextBox() then
                    local moveDirection = Humanoid.MoveDirection

                    if moveDirection.Magnitude > 0 then
                        moveDirection = moveDirection.Unit
                    end

                    if method == "CFrame" then
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + moveDirection * speed / 50
                    elseif method == "Humanoid" then
                        Humanoid.WalkSpeed = speed
                    elseif method == "Velocity" then
                        HumanoidRootPart.Velocity =
                            Vector3.new(moveDirection.X * speed, HumanoidRootPart.Velocity.Y, moveDirection.Z * speed)
                    end
                else
                    if method == "Humanoid" then
                        Humanoid.WalkSpeed = 16
                    elseif method == "Velocity" then
                        HumanoidRootPart.Velocity = Vector3.new(0, HumanoidRootPart.Velocity.Y, 0)
                    end
                end
            end)
        end,
    })

    MovementSection:AddKeybind("SpeedKeybind", {
        Title = "Speedhack Keybind",
        Description = "Hotkey to toggle the speed modification on/off",
        Mode = "Toggle",
        Default = "LeftBracket",
        Callback = function(Value)
            Options.Speedhack:SetValue(Value)
        end,
    })

    MovementSection:AddDropdown("SpeedMethod", {
        Title = "Speedhack Method",
        Description = "Select how speed modification is applied",
        Values = { "CFrame", "Velocity", "Humanoid" },
        Default = "CFrame",
    })

    MovementSection:AddSlider("Speed", {
        Title = "Speedhack Speed",
        Description = "Adjust how fast your character moves (in studs per second)",
        Default = 16,
        Min = 0,
        Max = 100,
        Rounding = 0,
    })

    MovementSection:AddSeperator()

    MovementSection:AddToggle("Flyhack", {
        Title = "Fly",
        Description = "Enables free flight movement in any direction",
        Default = false,
        Callback = function(Value)
            if not Value then
                if self.Maid.flyBv then
                    self.Maid.flyBv:Destroy()
                end
                self.Maid.flyHack = nil
                self.Maid.flyBv = nil
                return
            end

            -- Create BodyVelocity once
            self.Maid.flyBv = Instance.new("BodyVelocity")
            self.Maid.flyBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            CollectionService:AddTag(self.Maid.flyBv, "AllowedBM")

            -- Cache keyboard state functions
            local isKeyDown = UserInputService.IsKeyDown
            local KeyCode = Enum.KeyCode

            self.Maid.flyHack = RunService.Heartbeat:Connect(function()
                -- Use Player module's utility functions
                local rootPart = Player.getRootPart()
                if not rootPart or not camera then
                    return
                end

                -- Update parent only when needed
                if self.Maid.flyBv.Parent ~= rootPart then
                    self.Maid.flyBv.Parent = rootPart
                end

                -- Optimized move vector calculation
                local moveVector = Vector3.new(
                    (isKeyDown(UserInputService, KeyCode.D) and 1 or 0)
                        - (isKeyDown(UserInputService, KeyCode.A) and 1 or 0),
                    (isKeyDown(UserInputService, KeyCode.Space) and 1 or 0)
                        - (isKeyDown(UserInputService, KeyCode.LeftShift) and 1 or 0),
                    (isKeyDown(UserInputService, KeyCode.S) and 1 or 0)
                        - (isKeyDown(UserInputService, KeyCode.W) and 1 or 0)
                )

                -- Only update velocity if there's movement
                if moveVector.Magnitude > 0 then
                    self.Maid.flyBv.Velocity = camera.CFrame:VectorToWorldSpace(moveVector * Options.FlySpeed.Value)
                else
                    self.Maid.flyBv.Velocity = Vector3.zero
                end
            end)
        end,
    })

    MovementSection:AddKeybind("FlyKeybind", {
        Title = "Fly Keybind",
        Description = "Hotkey to toggle flying ability on/off",
        Default = "RightBracket",
        Mode = "Toggle",
        Callback = function(Value)
            Options.Flyhack:SetValue(Value)
        end,
    })

    MovementSection:AddSlider("FlySpeed", {
        Title = "Fly Speed",
        Description = "Adjust how fast you move while flying (in studs per second)",
        Default = 50,
        Min = 0,
        Max = 200,
        Rounding = 0,
    })

    MovementSection:AddToggle("ClickTP", {
        Title = "Click Teleport",
        Description = "Click to teleport to mouse position",
        Default = false,
        Callback = function(Value)
            if not Value then
                self.Maid.clickTp = nil
                return
            end

            self.Maid.clickTp = UserInputService.InputBegan:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                then
                    local RootPart = Player.getRootPart()
                    if not RootPart then
                        return
                    end

                    local ray = camera:ScreenPointToRay(
                        UserInputService:GetMouseLocation().X,
                        UserInputService:GetMouseLocation().Y
                    )
                    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000)

                    if raycastResult then
                        RootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
                    end
                end
            end)
        end,
    })

    local VisualsSection = Tab:AddSection({ Title = "VISUALS" })
    VisualsSection:AddToggle("Fullbright", {
        Title = "Fullbright",
        Description = "Removes all darkness",
        Default = false,
        Callback = function(Value)
            if not Value then
                self.Maid.fullbright = nil
                local lighting = game:GetService("Lighting")
                lighting.Brightness = 2
                lighting.ClockTime = 14
                lighting.GlobalShadows = true
                lighting.Ambient = Color3.fromRGB(0, 0, 0)
                return
            end

            self.Maid.fullbright = RunService.RenderStepped:Connect(function()
                local lighting = game:GetService("Lighting")
                lighting.Brightness = 2
                lighting.ClockTime = 14
                lighting.GlobalShadows = false
                lighting.Ambient = Color3.fromRGB(255, 255, 255)
            end)
        end,
    })

    VisualsSection:AddToggle("NoFog", {
        Title = "No Fog",
        Description = "Removes fog from the game",
        Default = false,
        Callback = function(Value)
            if not Value then
                self.Maid.noFog = nil
                local lighting = game:GetService("Lighting")
                lighting.FogStart = 0
                lighting.FogEnd = 100000
                lighting.FogColor = Color3.fromRGB(192, 192, 192)
                return
            end

            self.Maid.noFog = RunService.RenderStepped:Connect(function()
                local lighting = game:GetService("Lighting")
                lighting.FogStart = 100000
                lighting.FogEnd = 100000
                lighting.FogColor = Color3.fromRGB(255, 255, 255)
            end)
        end,
    })
end

return UniversalBuilder
