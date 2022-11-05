local Players = game:GetService("Players")

local General = {}

--Variables---------------------------------------------

General.Levels = 100
General.DoorTime = 20
General.RewardCash = 50
General.EventsPerSecond = 10

function General.TimerCalc(levelNum)
    return math.clamp(4 + (2 * levelNum), 0, 60)
end

--Stats---------------------------------------------

General.PlayerHealth = 100
General.PlayerSpeed = 16
General.PlayerJump = 50.145

General.HealthCost = 150
General.HealthIncrease = 100
General.HealthDefault = 0
General.HealthValue = 5

General.SpeedCost = 150
General.SpeedIncrease = 100
General.SpeedDefault = 0
General.SpeedValue = 0.5

General.JumpCost = 150
General.JumpIncrease = 100
General.JumpDefault = 0
General.JumpValue = 2

General.CMultiCost = 150
General.CMultiIncrease = 150
General.CMultiDefault = 0

General.LuckCost = 100
General.LuckIncrease = 100
General.LuckDefault = 0

function General.getCost(typer, current)
    if typer == "Health" then
        return General.HealthCost + General.HealthIncrease * (current or General.HealthDefault)
    elseif typer == "Speed" then
        return General.SpeedCost + General.SpeedIncrease * (current or General.SpeedDefault)
    elseif typer == "Jump" then
        return General.JumpCost + General.JumpIncrease * (current or General.JumpDefault)
    elseif typer == "CMulti" then
        return General.CMultiCost + General.CMultiIncrease * (current or General.CMultiDefault)
    elseif typer == "Luck" then
        return General.LuckCost + General.LuckIncrease * (current or General.LuckDefault)
    end
end

--Signs---------------------------------------------

General.Signs = {
    [1] = "Click the button and survive to open the door",
    [2] = "Complete levels and collect coins to buy upgrades",
    [3] = "One person must be alive or the button will reset",
    [5] = "Speeding Walls will now appear",
    [10] = "Laser Walls will now appear",
    [20] = "Heals will now appear",
    [30] = "Acid Puddles will now appear",
    [40] = "Coins have become Super Coins",
    [50] = "Rockets will now appear",
    [60] = "Tesla Coils will now appear",
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