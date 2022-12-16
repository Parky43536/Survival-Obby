local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

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
    local goal = {Position = ButtonPositionSaver[button] - Vector3.new(0, button.Size.Y - 0.01, 0)}
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

---------------------------------------------------------------

function round(num, val)
	return math.floor(val / num) * num
end

local function shallowCopy(list)
	local newList = {}
	for i,v in pairs(list) do
		newList[i] = v
	end

	return newList
end

local possibleColors = shallowCopy(General.Colors)
local lastRounding = 0
local lastPick
function LevelService.SetUpLevelColor(levelNum, level)
    local rounding = round(General.LevelMultiple, levelNum)

    if lastRounding ~= rounding then
        table.remove(possibleColors, lastPick)
        if next(possibleColors) == nil then
            possibleColors = shallowCopy(General.Colors)
        end
        lastRounding = rounding
    end

    local rng = Random.new(rounding * 1000)
    local pick = rng:NextInteger(1, #possibleColors)
    local PrimaryColor = possibleColors[pick]
    lastPick = pick
 
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

        if CollectionService:HasTag(part, "Wall") then
            PhysicsService:SetPartCollisionGroup(part, "Wall")
        end
    end
end

local requiredEvents = {}
function LevelService.ButtonEvent(levelNum, level)
    local rng = Random.new()

    for key, data in pairs(EventData) do
        if data.blocked or levelNum < data.level then
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