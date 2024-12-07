local Players = game:GetService("Players")

local Player = {}

-- Get the LocalPlayer instance
function Player.getLocalPlayer()
    return Players.LocalPlayer
end

-- Get the player's character with optional wait
function Player.getCharacter(waitForCharacter: boolean?)
    local player = Player.getLocalPlayer()
    if not player then
        return nil
    end

    if waitForCharacter then
        return player.Character or player.CharacterAdded:Wait()
    end
    return player.Character
end

-- Get the player's humanoid with optional wait
function Player.getHumanoid(waitForHumanoid: boolean?)
    local character = Player.getCharacter(waitForHumanoid)
    if not character then
        return nil
    end

    if waitForHumanoid then
        return character:WaitForChild("Humanoid")
    end
    return character:FindFirstChild("Humanoid")
end

-- Get the player's HumanoidRootPart with optional wait
function Player.getRootPart(waitForRootPart: boolean?)
    local character = Player.getCharacter(waitForRootPart)
    if not character then
        return nil
    end

    if waitForRootPart then
        return character:WaitForChild("HumanoidRootPart")
    end
    return character:FindFirstChild("HumanoidRootPart")
end

-- Check if player is alive (has character, humanoid, and rootpart)
function Player.isAlive(): boolean
    local humanoid = Player.getHumanoid()
    if not humanoid then
        return false
    end

    return humanoid.Health > 0
end

-- Get player's current position (returns Vector3 or nil)
function Player.getPosition(): Vector3?
    local rootPart = Player.getRootPart()
    if not rootPart then
        return nil
    end

    return rootPart.Position
end

-- Get player's current CFrame (returns CFrame or nil)
function Player.getCFrame(): CFrame?
    local rootPart = Player.getRootPart()
    if not rootPart then
        return nil
    end

    return rootPart.CFrame
end

-- Wait for player to spawn/respawn
function Player.waitForSpawn()
    local player = Player.getLocalPlayer()
    if not player then
        return
    end

    if not player.Character then
        player.CharacterAdded:Wait()
    end

    local humanoid = Player.getHumanoid(true)
    if humanoid then
        if humanoid.Health <= 0 then
            player.CharacterAdded:Wait()
        end
    end
end

return Player
