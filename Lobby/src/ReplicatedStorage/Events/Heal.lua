local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local IsServer = RunService:IsServer()

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local DataBase = ReplicatedStorage.Database
local EventData = require(DataBase:WaitForChild("EventData"))
local data = EventData[script.Name]

local LocalPlayer

local Signal
if IsServer then
    Signal = Instance.new("RemoteEvent")
    Signal.Name = "Signal"
    Signal.Parent = script
else
    Signal = script:WaitForChild("Signal")
    LocalPlayer = Players.LocalPlayer
end

local Event = {}

function Event.Main(levelNum, level)
    local rp = EventService.randomPoint(level)
    if rp then
        local cframe, size = EventService.getBoundingBox(level.Floor)
        local playersInLevel = EventService.getPlayersInSize(cframe, size + Vector3.new(4, 100, 4))

        for _, player in playersInLevel do
            Signal:FireClient(player, rp.Position)
        end
    end
end

function Event.Server(player)
    if General.playerCheck(player) then
        player.Character.Humanoid.Health += data.heal
    end
end

function Event.Client(rp)
    local heal = Assets.Obstacles.Heal:Clone()
    heal.Position = rp + Vector3.new(0, 3.5, 0)
    heal.Parent = workspace.Misc

    local goal = {CFrame = heal.CFrame * CFrame.Angles(0, math.rad(180), 0)}
    local properties = {Time = 1, Repeat = math.huge}
    TweenService.tween(heal, goal, properties)

    local touchConnection
    touchConnection = heal.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if General.playerCheck(player) then
            touchConnection:Disconnect()
            heal:Destroy()

            Signal:FireServer(LocalPlayer)
        end
    end)

    task.wait(data.despawnTime)
    if heal.Parent ~= nil then
        touchConnection:Disconnect()
        heal:Destroy()
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