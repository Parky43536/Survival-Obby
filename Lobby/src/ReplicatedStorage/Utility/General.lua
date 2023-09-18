local Players = game:GetService("Players")

local General = {}

--Variables---------------------------------------------

General.Levels = 200
General.DoorTime = 20
General.LevelReward = 50
General.LevelMultiple = 5
General.EventsPerSecond = 1

General.MusicScale = 0.1
General.SoundScale = 0.2

function General.TimerCalc(levelNum)
    return math.clamp(8 + (2 * levelNum), 0, 30)
end

--Stats---------------------------------------------

General.PlayerHealth = 100
General.PlayerSpeed = 16
General.PlayerJump = 50.145

General.HealthCost = 100
General.HealthIncrease = 100
General.HealthDefault = 0
General.HealthValue = 10
General.HealthMax = 300
General.HealthColor = Color3.fromRGB(255, 0, 0)

General.SpeedCost = 100
General.SpeedIncrease = 100
General.SpeedDefault = 0
General.SpeedValue = 1
General.SpeedMax = 35
General.SpeedColor = Color3.fromRGB(0, 187, 255)

General.JumpCost = 100
General.JumpIncrease = 100
General.JumpDefault = 0
General.JumpValue = 2
General.JumpMax = 75
General.JumpColor = Color3.fromRGB(212, 0, 255)

General.IncomeCost = 100
General.IncomeIncrease = 100
General.IncomeDefault = 0
General.IncomeValue = 0.2
General.IncomeMax = 4
General.IncomeColor = Color3.fromRGB(4, 255, 0)

function General.getCost(typer, current)
    if typer == "Health" then
        if General.getValue(typer, current) == General.HealthMax then
            return false
        else
            return General.HealthCost + General.HealthIncrease * (current or General.HealthDefault)
        end
    elseif typer == "Speed" then
        if General.getValue(typer, current) == General.SpeedMax then
            return false
        else
            return General.SpeedCost + General.SpeedIncrease * (current or General.SpeedDefault)
        end
    elseif typer == "Jump" then
        if General.getValue(typer, current) == General.JumpMax then
            return false
        else
            return General.JumpCost + General.JumpIncrease * (current or General.JumpDefault)
        end
    elseif typer == "Income" then
        if General.getValue(typer, current) == General.IncomeMax then
            return false
        else
            return General.IncomeCost + General.IncomeIncrease * (current or General.IncomeDefault)
        end
    end
end

function General.getValue(typer, current)
    if typer == "Health" then
        return math.clamp(General.PlayerHealth + (General.HealthValue * (current or General.HealthDefault)), General.PlayerHealth, General.HealthMax)
    elseif typer == "Speed" then
        return math.clamp(General.PlayerSpeed + (General.SpeedValue * (current or General.SpeedDefault)), General.PlayerSpeed, General.SpeedMax)
    elseif typer == "Jump" then
        return math.clamp(General.PlayerJump + (General.JumpValue * (current or General.JumpDefault)), General.PlayerJump, General.JumpMax)
    elseif typer == "Income" then
        return math.clamp(1 + (General.IncomeValue * (current or General.IncomeDefault)), 1, General.IncomeMax)
    end
end

function General.getColor(typer)
    if typer == "Health" then
        return General.HealthColor
    elseif typer == "Speed" then
        return General.SpeedColor
    elseif typer == "Jump" then
        return General.JumpColor
    elseif typer == "Income" then
        return General.IncomeColor
    end
end

--Lists---------------------------------------------

General.Signs = {
    [1] = "Step on the button and survive to open the door",
    [2] = "Collect coins to buy upgrades and tools in the shop",
    [3] = "One person must be alive or the button will start over",
}

General.LevelOrder = {
    [2] = "Advertiser",
}

General.AppearanceOrder = {
    [1] = "Rocket",
    [2] = "SpeedingWall",
    [3] = "FallingRock",
    [4] = "Landmine",
    [5] = "LaserWall",
    [6] = "AcidPuddle",
    [7] = "TeslaCoil",
    [8] = "Nuke",
}

General.UpgradeOrder = {
    [1] = "Bomb",
    [2] = "Spike",
    [3] = "LavaLine",
    [4] = "Spinner",
    [5] = "ButtonBot",
    [6] = "Rocket",
    [7] = "SpeedingWall",
    [8] = "FallingRock",
    [9] = "Landmine",
    [10] = "LaserWall",
    [11] = "AcidPuddle",
    [12] = "TeslaCoil",
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