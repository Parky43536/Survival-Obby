local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerValues = require(ServerScriptService.ServerValues)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Utility = ReplicatedStorage.Utility
local General = require(Utility.General)
local AudioService = require(Utility.AudioService)

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)
local ClientService = require(SerServices.ClientService)
local ShopService = require(SerServices.ShopService)

local PlayerProfiles = {}

local function getPlayerProfile(player)
    return DataManager:Initialize(player, ServerValues.DATASTORE_NAME)
end

local function loadPlayerProfile(player, profile)
    PlayerProfiles[player] = profile
end

local function playerAdded(newPlayer)
    local profile = getPlayerProfile(newPlayer)
	if profile ~= nil then
		loadPlayerProfile(newPlayer, profile)
        ClientService:InitializeClient(newPlayer, profile)
        AudioService:Music(newPlayer)
	else
        warn("Could not load player profile")
    end

    local function loadPlayer()
        local loadCooldown = 2
        if not PlayerValues:GetValue(newPlayer, "LifeId") then
            PlayerValues:SetValue(newPlayer, "LifeId", tick()- loadCooldown)
        end
        if tick() - PlayerValues:GetValue(newPlayer, "LifeId") > loadCooldown then
            PlayerValues:SetValue(newPlayer, "LifeId", tick())

            local currentLevel = PlayerValues:GetValue(newPlayer, "CurrentLevel") or DataManager:GetValue(newPlayer, "Level")

            task.spawn(function()
                if not newPlayer.Character then
                    repeat task.wait() until newPlayer.Character
                end

                if currentLevel ~= 0 then
                    local level = workspace.Levels:FindFirstChild(currentLevel)

                    if not level then
                        repeat
                            level = workspace.Levels:FindFirstChild(currentLevel)
                            task.wait()
                        until level
                    end

                    repeat
                        newPlayer.Character:PivotTo(level.Door.PlayerSpawn.CFrame)
                        task.wait()
                    until General.playerCheck(newPlayer) and (newPlayer.Character:GetPivot().Position - level.Door.PlayerSpawn.Position).Magnitude < 10
                else
                    repeat
                        task.wait()
                    until General.playerCheck(newPlayer)
                end

                ClientService:InitializeLife(newPlayer)
                ClientService:SetPlayerStats(newPlayer)
                ShopService:InitializePurchases(newPlayer)
                ShopService:InitializeTools(newPlayer)
            end)
        end
    end

    loadPlayer()

    newPlayer.CharacterAdded:Connect(function()
        loadPlayer()
    end)
end

local function playerRemoved(player)
	local profile = PlayerProfiles[player]
	if profile ~= nil then
		profile:Release()
        PlayerProfiles[player] = nil
	end
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoved)

for _,currentPlayers in (Players:GetChildren()) do
    playerAdded(currentPlayers)
end