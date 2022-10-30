local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerValues = require(ServerScriptService.ServerValues)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)
local ClientService = require(SerServices.ClientService)

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
        ClientService.InitializeClient(newPlayer, profile)
	else
        warn("Could not load player profile")
    end

    local function loadPlayer()
        local currentLevel = DataManager:GetValue(newPlayer, "Level")
        --PlayerValues:SetValue(newPlayer, "CurrentLevel", currentLevel)

        task.spawn(function()
            if not newPlayer.Character then
                repeat task.wait(1) until newPlayer.Character
            end

            if currentLevel ~= 1 then
                local level = workspace.Levels:FindFirstChild(currentLevel)

                if not level then
                    repeat
                        level = workspace.Levels:FindFirstChild(currentLevel)
                        task.wait()
                    until level
                end

                repeat
                    newPlayer.Character:PivotTo(level.Floor.Spawn.CFrame)
                    task.wait()
                until (newPlayer.Character:GetPivot().Position - level.Floor.Spawn.Position).Magnitude < 10
            end
        end)
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

for _,currentPlayers in pairs(Players:GetChildren()) do
    playerAdded(currentPlayers)
end