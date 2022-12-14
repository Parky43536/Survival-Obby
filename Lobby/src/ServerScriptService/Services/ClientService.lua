local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage.Utility
local General = require(Utility.General)
local AudioService = require(Utility.AudioService)

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

function ClientService.UpgradePlayer(player, upgrade)
    if General.playerCheck(player) then
        AudioService:Create(9048769867, player.Character.PrimaryPart, {Pitch = math.random(10, 20) / 10, Volume = 0.5})

        local particles = Assets.Misc.Upgrade.Attachment:Clone()
        particles.Parent = player.Character.PrimaryPart

        particles.Flare.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, General.getColor(upgrade)), ColorSequenceKeypoint.new(1, General.getColor(upgrade))}
        particles.Ray.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, General.getColor(upgrade)), ColorSequenceKeypoint.new(1, General.getColor(upgrade))}

        particles.Flare:Emit(1)
        particles.Ray:Emit(1)

        task.wait(2)
        particles:Destroy()
    end
end

function ClientService.SetPlayerStats(player)
    if General.playerCheck(player) then
        local humanoid = player.Character.Humanoid

        if PlayerValues:GetValue(player, "GodHealth") then
            humanoid.MaxHealth = 1000000
            humanoid.Health = humanoid.MaxHealth
        elseif not PlayerValues:GetValue(player, "HealthOff") then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            humanoid.MaxHealth = General.getValue("Health", PlayerValues:GetValue(player, "Health"))
            humanoid.Health = humanoid.MaxHealth * healthPercent
        else
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            humanoid.MaxHealth = General.PlayerHealth
            humanoid.Health = humanoid.MaxHealth * healthPercent
        end

        if not PlayerValues:GetValue(player, "SpeedOff") then
            humanoid.WalkSpeed = General.getValue("Speed", PlayerValues:GetValue(player, "Speed"))
        else
            humanoid.WalkSpeed = General.PlayerSpeed
        end

        if not PlayerValues:GetValue(player, "JumpOff") then
            humanoid.JumpPower = General.getValue("Jump", PlayerValues:GetValue(player, "Jump"))
        else
            humanoid.JumpPower = General.PlayerJump
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

	for setting, value in profile.Data.Settings do
        PlayerValues:SetValue(player, setting, value, "playerOnly")
    end

    ClientConnection:FireClient(player)
    UpgradeConnection:FireClient(player)
    SettingsConnection:FireClient(player)
end

return ClientService