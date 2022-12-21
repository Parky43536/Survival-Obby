local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IsServer = RunService:IsServer()

local Utility = ReplicatedStorage:WaitForChild("Utility")
local TweenService = require(Utility.TweenService)
local AudioService = require(Utility.AudioService)

local Signal
if IsServer then
    Signal = Instance.new("RemoteEvent")
    Signal.Name = "Signal"
    Signal.Parent = script
else
    Signal = script:WaitForChild("Signal")
end

local Event = {}

function Event.Main(player, levelNum, despawnTime)
    Signal:FireClient(player, levelNum, despawnTime)
end

function Event.Client(levelNum, despawnTime)
    local level = workspace.Levels:FindFirstChild(levelNum)
    if not level then
        repeat
            level = workspace.Levels:FindFirstChild(levelNum)
            task.wait()
        until level
    end

    local chest = level:FindFirstChild("Chest"):FindFirstChild("Chest")
    if not chest then
        repeat
            chest = level:FindFirstChild("Chest"):FindFirstChild("Chest")
            task.wait()
        until chest
    end

    chest.BillboardGui:Destroy()
    chest.Parent.Effect:Destroy()
    chest.Parent.Touch:Destroy()

    local goal = {Orientation = chest.Orientation + Vector3.new(0, 180, 0)}
    local properties = {Time = 1/despawnTime, Repeat = despawnTime * despawnTime}
    TweenService.tween(chest, goal, properties)

    local goal2 = {Position = chest.Position + Vector3.new(0, 10, 0), Transparency = 1}
    local properties2 = {Time = despawnTime}
    TweenService.tween(chest, goal2, properties2)

    if despawnTime > 0 then
        AudioService:Create(9048777613, chest.Position, {Volume = 0.5})
        AudioService:Create(9125361557, chest.Position, {Pitch = math.random(10, 20) / 10, Volume = 0.15})
    end

    task.wait(despawnTime)
    chest:Destroy()
end

if not IsServer then
    Signal.OnClientEvent:Connect(function(...)
        Event.Client(...)
    end)
end

return Event