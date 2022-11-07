local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.Events
local DataBase = ReplicatedStorage.Database
local EventData = require(DataBase:WaitForChild("EventData"))

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local LevelService = {}

local ButtonPositionSaver = {}
function LevelService.PressButton(button)
    if not ButtonPositionSaver[button] then ButtonPositionSaver[button] = button.Position end

    button.Position = ButtonPositionSaver[button]
    local goal = {Position = ButtonPositionSaver[button] - Vector3.new(0, 0.99, 0)}
    local properties = {Time = 0.1, Reverse = true}
    TweenService.tween(button, goal, properties)
end

function LevelService.OpenDoors(level)
    task.spawn(function()
        local DoorR = level.Door.DoorR
        local DoorL = level.Door.DoorL

        task.spawn(function()
            for i = 1 , General.DoorTime do
                level.Door.Timer.Front.Label.Text = General.DoorTime - i
                level.Door.Timer.Back.Label.Text = General.DoorTime - i

                level.Door.Timer.Front.Enabled = true
                level.Door.Timer.Back.Enabled = true

                task.wait(1)
            end

            level.Door.Timer.Front.Enabled = false
            level.Door.Timer.Back.Enabled = false
        end)

        local tweenInfo = TweenInfo.new(2)

        ModelTweenService.TweenModulePosition(DoorR, tweenInfo, DoorR.PrimaryPart.Position + DoorR.PrimaryPart.CFrame.RightVector * -9)
        ModelTweenService.TweenModulePosition(DoorL, tweenInfo, DoorL.PrimaryPart.Position + DoorL.PrimaryPart.CFrame.RightVector * 9)

        task.wait(General.DoorTime - 2)

        ModelTweenService.TweenModulePosition(DoorR, tweenInfo, DoorR.PrimaryPart.Position + DoorR.PrimaryPart.CFrame.RightVector * 9)
        ModelTweenService.TweenModulePosition(DoorL, tweenInfo, DoorL.PrimaryPart.Position + DoorL.PrimaryPart.CFrame.RightVector * -9)
    end)
end

local lastPrimaryColor
function LevelService.SetUpLevelColor(levelNum, level)
    local rng = Random.new(levelNum * 1000)

    local PrimaryColor
    repeat
        PrimaryColor = General.Colors[rng:NextInteger(1, #General.Colors)]
    until lastPrimaryColor ~= PrimaryColor
    lastPrimaryColor = PrimaryColor

    local SecondaryColor = PrimaryColor:Lerp(Color3.fromRGB(255,255,255), General.SecondaryColorLerp)

    for _, part in pairs(level:GetDescendants()) do
        if CollectionService:HasTag(part, "PrimaryColor") then
            part.Color = PrimaryColor
        elseif CollectionService:HasTag(part, "SecondaryColor") then
            part.Color = SecondaryColor
        elseif CollectionService:HasTag(part, "SupportColor") then
            part.Color = General.SupportColor
        elseif CollectionService:HasTag(part, "ObstacleSpawner") then
            part.Transparency = 1
        end
    end
end

local requiredEvents = {}
function LevelService.ButtonEvent(levelNum, level, player)
    local rng = Random.new()

    for key, data in pairs(EventData) do
        if levelNum < data.levels.min or levelNum > data.levels.max then
            continue
        end

        if rng:NextNumber(0, data.chance) <= 1 then
            task.spawn(function()
                if not requiredEvents[key] then
                    requiredEvents[key] = require(Events:FindFirstChild(key))
                end

                requiredEvents[key].Main(levelNum, level, data)
            end)

            break
        end
    end
end

return LevelService