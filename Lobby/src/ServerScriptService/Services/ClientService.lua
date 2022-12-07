local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local PhysicsService = game:GetService("PhysicsService")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Utility = ReplicatedStorage.Utility
local General = require(Utility.General)

local Remotes = ReplicatedStorage.Remotes
local ClientConnection = Remotes.ClientConnection
local UpgradeConnection = Remotes.UpgradeConnection
local SettingsConnection = Remotes.SettingsConnection

local ClientService = {}

function ClientService.HealPlayer(player)
    if General.playerCheck(player) then
        local humanoid = player.Character.Humanoid
        humanoid.Health = humanoid.MaxHealth
    end
end

function ClientService.SetPlayerStats(player)
    if General.playerCheck(player) then
        local humanoid = player.Character.Humanoid

        if not PlayerValues:GetValue(player, "UpgradesOff") then
            humanoid.WalkSpeed = General.getValue("Speed", PlayerValues:GetValue(player, "Speed"))
            humanoid.JumpPower = General.getValue("Jump", PlayerValues:GetValue(player, "Jump"))

            if PlayerValues:GetValue(player, "GodHealthOn") then
                humanoid.MaxHealth = 1000000
                humanoid.Health = humanoid.MaxHealth
            else
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                humanoid.MaxHealth = General.getValue("Health", PlayerValues:GetValue(player, "Health"))
                humanoid.Health = humanoid.MaxHealth * healthPercent
            end
        else
            humanoid.WalkSpeed = General.PlayerSpeed
            humanoid.JumpPower = General.PlayerJump

            if PlayerValues:GetValue(player, "GodHealthOn") then
                humanoid.MaxHealth = 1000000
                humanoid.Health = humanoid.MaxHealth
            else
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                humanoid.MaxHealth = General.PlayerHealth
                humanoid.Health = humanoid.MaxHealth * healthPercent
            end
        end
    end
end

function ClientService.InitializeCharacter(player)
    for _, characterPart in pairs(player.Character:GetChildren()) do
        if characterPart:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(characterPart, "Player")
        end
    end
end

function ClientService.InitializeClient(player, profile)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    local stage = Instance.new("NumberValue")
    stage.Name = "Level"
    stage.Value = profile.Data.Level
    stats.Parent = player
    stage.Parent = stats

    PlayerValues:SetValue(player, "Level", profile.Data.Level, "playerOnly")
    PlayerValues:SetValue(player, "Cash", profile.Data.Cash, "playerOnly")
    PlayerValues:SetValue(player, "Health", profile.Data.Health, "playerOnly")
    PlayerValues:SetValue(player, "Speed", profile.Data.Speed, "playerOnly")
    PlayerValues:SetValue(player, "Jump", profile.Data.Jump, "playerOnly")
    PlayerValues:SetValue(player, "CMulti", profile.Data.CMulti, "playerOnly")

	for setting,_ in profile.Data.Settings do
        print(player, setting)
        PlayerValues:SetValue(player, setting, true, "playerOnly")
    end

    ClientConnection:FireClient(player)
    UpgradeConnection:FireClient(player)
    SettingsConnection:FireClient(player)
end

return ClientService