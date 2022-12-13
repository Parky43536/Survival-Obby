local Players = game:GetService("Players")

local General = {}

--Variables---------------------------------------------

General.Levels = 200
General.DoorTime = 20
General.LevelReward = 50
General.LevelMultiple = 5
General.EventsPerSecond = 12

function General.TimerCalc(levelNum)
    return math.clamp(4 + (2 * levelNum), 0, 40)
end

--Stats---------------------------------------------

General.PlayerHealth = 100
General.PlayerSpeed = 16
General.PlayerJump = 50.145

General.HealthCost = 125
General.HealthIncrease = 125
General.HealthDefault = 0
General.HealthValue = 5

General.SpeedCost = 100
General.SpeedIncrease = 100
General.SpeedDefault = 0
General.SpeedValue = 0.5

General.JumpCost = 100
General.JumpIncrease = 100
General.JumpDefault = 0
General.JumpValue = 1.5

General.CMultiCost = 150
General.CMultiIncrease = 150
General.CMultiDefault = 0
General.CMultiValue = 0.1

function General.getCost(typer, current)
    if typer == "Health" then
        return General.HealthCost + General.HealthIncrease * (current or General.HealthDefault)
    elseif typer == "Speed" then
        return General.SpeedCost + General.SpeedIncrease * (current or General.SpeedDefault)
    elseif typer == "Jump" then
        return General.JumpCost + General.JumpIncrease * (current or General.JumpDefault)
    elseif typer == "CMulti" then
        return General.CMultiCost + General.CMultiIncrease * (current or General.CMultiDefault)
    end
end

function General.getValue(typer, current)
    if typer == "Health" then
        return General.PlayerHealth + (General.HealthValue * (current or General.HealthDefault))
    elseif typer == "Speed" then
        return General.PlayerSpeed + (General.SpeedValue * (current or General.SpeedDefault))
    elseif typer == "Jump" then
        return General.PlayerJump + (General.JumpValue * (current or General.JumpDefault))
    elseif typer == "CMulti" then
        return 1 + (General.CMultiValue * (current or General.CMultiDefault))
    end
end

--Lists---------------------------------------------

General.Signs = {
    [1] = "Step on the button and survive to open the door",
    [2] = "Collect coins to buy upgrades and tools in the shop",
    [3] = "One person must be alive or the button will start over",
}

General.AppearanceOrder = {
    [1] = "SpeedingWall",
    [2] = "Spinner",
    [3] = "Landmine",
    [4] = "LaserWall",
    [5] = "AcidPuddle",
    [6] = "Rocket",
    [7] = "TeslaCoil",
    [8] = "Nuke",
}

General.UpgradeOrder = {
    [1] = "Bomb",
    [2] = "Spike",
    [3] = "LavaLine",
    [4] = "FallingRock",
    [5] = "SpeedingWall",
    [6] = "Spinner",
    [7] = "Landmine",
    [8] = "LaserWall",
    [9] = "AcidPuddle",
    [10] = "Rocket",
    [11] = "TeslaCoil",
}

--Colors---------------------------------------------

General.SecondaryColorLerp = 0.2
General.SupportColor = Color3.fromRGB(0, 0, 0)
General.Colors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 150, 0),
    Color3.fromRGB(255, 0, 150),
    Color3.fromRGB(0, 150, 255),
    Color3.fromRGB(150, 0, 255),
    Color3.fromRGB(150, 255, 0),
    Color3.fromRGB(0, 255, 150),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(150, 150, 150),
}

--Functions---------------------------------------------

function General.playerCheck(player)
    if player and
    player.Character and
    player.Character.PrimaryPart and
    player.Character.PrimaryPart.Parent ~= nil and
    player.Character.Humanoid.Health > 0 then
        return true
    end
end

return General