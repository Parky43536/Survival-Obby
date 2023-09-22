local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local Assets = ReplicatedStorage.Assets
local Tools = Assets.Tools

local Events = ReplicatedStorage.Events
local DataBase = ReplicatedStorage.Database
local EventData = require(DataBase.EventData)
local ShopData = require(DataBase.ShopData)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)
local EventService = require(Utility.EventService)

local Remotes = ReplicatedStorage.Remotes
local ShopPopConnection = Remotes.ShopPopConnection
local UpgradeConnection = Remotes.UpgradeConnection

local LevelService = {}

LevelService.Levels = {}
local touchCooldown = {}

---------------------------------------------------------------

function round(num, val)
	return math.floor(val / num) * num
end

local function shallowCopy(list)
	local newList = {}
	for i,v in (list) do
		newList[i] = v
	end

	return newList
end

---------------------------------------------------------------

local ButtonPositionSaver = {}
function LevelService:PressButton(button)
    if not ButtonPositionSaver[button] then ButtonPositionSaver[button] = button.Position end

    button.Position = ButtonPositionSaver[button]
    local goal = {Position = ButtonPositionSaver[button] - Vector3.new(0, button.Size.Y - 0.01, 0)}
    local properties = {Time = 0.1, Reverse = true}
    TweenService.tween(button, goal, properties)
end

function LevelService:OpenDoors(level)
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

function LevelService:FinishButton(levelNum, level, win)
    EventService:CleanLevel(levelNum, level)

    if win then
        AudioService:Create(1846252166, level.Button.Button, {Volume = 0.25})

        LevelService:OpenDoors(level)
        LevelService.Levels[levelNum].DoorOpened = true

        local cframe, size = EventService:getBoundingBox(level.Floor)
        local playersInLevel = EventService:getPlayersInSize(cframe, size + Vector3.new(5, 100, 5))
        for _, playerInRoom in playersInLevel do
            DataManager:SetSpawn(playerInRoom, levelNum + 1)
        end

        task.wait(General.DoorTime)
    else
        AudioService:Create(9113085663, level.Button.Button, {Volume = 0.5})
    end

    LevelService.Levels[levelNum].DoorOpened = false
    LevelService.Levels[levelNum].Timer = General.TimerCalc(levelNum)
    LevelService.Levels[levelNum].Started = false
    level.Button.Button.Top.Label.Text = "start"
    level.Button.Button.BrickColor = BrickColor.new("Lime green")
end

function LevelService:SetUpButton(levelNum, level)
    level.Button.Button.Touched:Connect(function(hit)
        local hitPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
        if hitPlayer and General.playerCheck(hitPlayer) and LevelService.Levels[levelNum].Started == false then
            LevelService.Levels[levelNum].Started = true
            PlayerValues:SetValue(hitPlayer, "CurrentLevel", levelNum, "playerOnly")

            LevelService:PressButton(level.Button.Button)
            level.Button.Button.Top.Label.Text = LevelService.Levels[levelNum].Timer
            level.Button.Button.BrickColor = BrickColor.new("Really red")

            local noPlayers = 0
            for i = 1 , General.TimerCalc(levelNum) do
                LevelService:ButtonEvent(levelNum, level)
                task.wait(1)

                --area check
                local cframe, size = EventService:getBoundingBox(level.Floor)
                local playersInLevel = EventService:getPlayersInSize(cframe, size + Vector3.new(5, 100, 5))
                if #playersInLevel == 0 then
                    noPlayers += 1
                    if noPlayers == 5 then
                        LevelService:FinishButton(levelNum, level, false)
                        return
                    end
                else
                    noPlayers = 0
                end

                --health check
                local playersAlive = {}
                for _, player in (Players:GetChildren()) do
                    if PlayerValues:GetValue(player, "CurrentLevel") == levelNum and General.playerCheck(player) then
                        table.insert(playersAlive, player)
                    end
                end
                if #playersAlive == 0 then
                    LevelService:FinishButton(levelNum, level, false)
                    return
                end

                LevelService.Levels[levelNum].Timer = math.clamp(LevelService.Levels[levelNum].Timer - 1, 0, 99e99)
                level.Button.Button.Top.Label.Text = LevelService.Levels[levelNum].Timer
            end

            LevelService:FinishButton(levelNum, level, true)
        end
    end)
end

function LevelService:SetUpDoor(levelNum, level)
    level.Door.Checkpoint.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if player and LevelService.Levels[levelNum].DoorOpened then
            if not touchCooldown[player] then
                touchCooldown[player] = tick() - EventService.TouchCooldown
            end
            if tick() - touchCooldown[player] > EventService.TouchCooldown then
                touchCooldown[player] = tick()

                DataManager:SetSpawn(player, levelNum + 1)
                UpgradeConnection:FireClient(player, "check")
            end
        end
    end)
end

function LevelService:SetUpRestart(level)
    level.Floor.Restart.Restart.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            if not touchCooldown[player] then
                touchCooldown[player] = tick() - EventService.TouchCooldown
            end
            if tick() - touchCooldown[player] > EventService.TouchCooldown then
                touchCooldown[player] = tick()

                DataManager:Restart(player)
            end
        end
    end)
end

function LevelService:SetUpAdvertisement(levelNum, level)
    local rng = Random.new(levelNum * 1000)

    for _, advertisement in (level:GetChildren()) do
        if advertisement.Name == "Advertisement" then
            local item = advertisement:FindFirstChild("Item")
            if item then
                item = item.Value
            else
                local shopList = ShopData:getList()
                local num = rng:NextInteger(1, #shopList)
                item = shopList[num]
            end

            local data = ShopData.Items[item]
            advertisement.Main.BillboardGui.Label.Text = item
            advertisement.Main.Front.Texture = "rbxassetid://".. data.image
            advertisement.Main.Back.Texture = "rbxassetid://".. data.image

            local goal = {CFrame = advertisement.Main.CFrame * CFrame.Angles(0, math.rad(180), 0)}
            local properties = {Time = 1, Repeat = math.huge}
            TweenService.tween(advertisement.Main, goal, properties)

            advertisement.Touch.Touched:Connect(function(hit)
                local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                if player then
                    if not touchCooldown[player] then
                        touchCooldown[player] = tick() - EventService.TouchCooldown
                    end
                    if tick() - touchCooldown[player] > EventService.TouchCooldown then
                        touchCooldown[player] = tick()

                        ShopPopConnection:FireClient(player, item)
                    end
                end
            end)
        end
    end
end

local possibleColors = shallowCopy(General.Colors)
local lastRounding = 0
local lastPick
function LevelService:SetUpLevelColor(levelNum, level)
    local rounding = round(General.LevelMultiple, levelNum)

    if lastRounding ~= rounding then
        table.remove(possibleColors, lastPick)
        if next(possibleColors) == nil then
            possibleColors = shallowCopy(General.Colors)
        end
        lastRounding = rounding
    end

    local rng = Random.new(rounding * 1000)
    local pick = 1--rng:NextInteger(1, #possibleColors)
    local PrimaryColor = possibleColors[pick]
    lastPick = pick
 
    local SecondaryColor = PrimaryColor:Lerp(Color3.fromRGB(255,255,255), General.SecondaryColorLerp)

    for _, part in (level:GetDescendants()) do
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
            part.CollisionGroup = "Wall"
        end
    end
end

local requiredEvents = {}
function LevelService:ButtonEvent(levelNum, level)
    local rng = Random.new()
    local eventList = EventData:getList()
    local name
    local data
    local scriptName

    repeat
        local valid = true
        local num = rng:NextInteger(1, #eventList)

        name = eventList[num]
        data = EventData.Events[name]
        scriptName = name

        if data.copyOf then
            scriptName = data.copyOf
        end

        if data.blocked or levelNum < data.level then
            valid = false
        end

        if valid then
           task.spawn(function()
                if not requiredEvents[scriptName] then
                    requiredEvents[scriptName] = require(Events:FindFirstChild(scriptName))
                end

                requiredEvents[scriptName].Main(levelNum, level, data, name)
            end)
        end

        if not valid then
            table.remove(eventList, num)
        end
    until valid

    local num = rng:NextInteger(1, 2)
    if num == 1 then
        task.spawn(function()
            if not requiredEvents["Coin"] then
                requiredEvents["Coin"] = require(Events:FindFirstChild("Coin"))
            end

            requiredEvents["Coin"].Main(levelNum, level, EventData.Events["Coin"])
        end)
    end
end

return LevelService