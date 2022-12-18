local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local IsServer = RunService:IsServer()

local Assets = ReplicatedStorage.Assets
local Obstacles = Assets.Obstacles
local Obstacle = Obstacles:FindFirstChild(script.Name)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local DataBase = ReplicatedStorage.Database
local EventData = require(DataBase:WaitForChild("EventData"))
local data = EventData[script.Name]

local ServerScriptService
local SerServices
local DataManager
local LocalPlayer

local Signal
if IsServer then
    Signal = Instance.new("RemoteEvent")
    Signal.Name = "Signal"
    Signal.Parent = script

    ServerScriptService = game:GetService("ServerScriptService")
    SerServices = ServerScriptService.Services
    DataManager = require(SerServices.DataManager)
else
    Signal = script:WaitForChild("Signal")
    LocalPlayer = Players.LocalPlayer
end

local Event = {}

function Event.Main(levelNum, level)
    local rp = EventService:randomPoint(level)
    if rp then
        local cframe, size = EventService:getBoundingBox(level.Floor)
        local playersInLevel = EventService:getPlayersInSize(cframe, size + Vector3.new(5, 100, 5))

        for _, player in playersInLevel do
            Signal:FireClient(player, rp.Position, levelNum)
        end
    end
end

function Event.Server(player)
    DataManager:GiveCash(player, data.value)
end

function Event.Client(rp, levelNum)
    local coin = Obstacle.Coin:Clone()
    coin.Position = rp + Vector3.new(0, 3.5, 0)
    EventService:parentToObstacles(levelNum, coin)

    local goal = {Orientation = coin.Orientation + Vector3.new(0, 180, 0)}
    local properties = {Time = 1, Repeat = math.huge}
    TweenService.tween(coin, goal, properties)

    local touchConnection
    touchConnection = coin.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if General.playerCheck(player) then
            touchConnection:Disconnect()

            AudioService:Create(9125361557, coin.Position, {Pitch = math.random(10, 20) / 10, Volume = 0.15})

            coin:Destroy()

            Signal:FireServer(LocalPlayer)
        end
    end)

    if General.playerCheck(LocalPlayer) then
        if PlayerValues:GetValue(LocalPlayer, "Coin Magnet") then
            task.spawn(function()
                task.wait(0.5)
                if coin.Parent ~= nil then
                    local align = Instance.new("AlignPosition")
                    align.Attachment0 = coin.Attachment
                    align.Attachment1 = LocalPlayer.Character.PrimaryPart.RootRigAttachment
                    align.Parent = coin
                    coin.Anchored = false
                end
            end)
        end
    end

    task.wait(data.despawnTime)
    if coin.Parent ~= nil then
        touchConnection:Disconnect()
        coin:Destroy()
    end
end

if IsServer then
    Signal.OnServerEvent:Connect(function(...)
        Event.Server(...)
    end)
else
    Signal.OnClientEvent:Connect(function(...)
        Event.Client(...)
    end)
end

return Event