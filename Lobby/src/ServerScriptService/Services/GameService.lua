local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local LevelService = require(SerServices.LevelService)

local DataBase = ReplicatedStorage.Database
local EventData = require(DataBase.EventData)
local LevelData = require(DataBase.LevelData)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)

local GameService = {}

local signBot = Instance.new("Animation")
signBot.AnimationId = "rbxassetid://14820795173"
signBot.Parent = script

function GameService:SetUpData()
    --set up level and upgrades in eventdata and signs in general

    local currentLevel = General.LevelMultiple
    local currentEvent = 1

    --copyOf
    for _, data in (EventData.Events) do
        if data.copyOf then
            for variable, value in (EventData.Events[data.copyOf]) do
                if not data[variable] then
                    data[variable] = value
                end
            end
        end
    end

    --apperance
    for _, event in (General.AppearanceOrder) do
        if not EventData.Events[event].blocked then
            EventData.Events[event].level = currentLevel

            if not General.Signs[currentLevel] then
                General.Signs[currentLevel] = EventData.Events[event].name .. "s will now appear"
            end

            currentLevel += General.LevelMultiple
        end
    end

    --upgrades
    for levelNum = currentLevel, General.Levels, General.LevelMultiple do
        local event = General.UpgradeOrder[currentEvent]
        if EventData.Events[event].blocked then
            repeat
                currentEvent += 1
                if currentEvent > #General.UpgradeOrder then
                    currentEvent = 1
                end
                event = General.UpgradeOrder[currentEvent]
            until not EventData.Events[event].blocked
        end

        if not EventData.Events[event].upgrades then EventData.Events[event].upgrades = {} end
        table.insert(EventData.Events[event].upgrades, currentLevel)

        if not General.Signs[currentLevel] then
            General.Signs[currentLevel] = EventData.Events[event].name .. "s have been upgraded"
        end

        currentLevel += General.LevelMultiple
        currentEvent += 1
        if currentEvent > #General.UpgradeOrder then
            currentEvent = 1
        end
    end
end

function GameService:SetUpLevels()
    local start = workspace.Levels:FindFirstChild("0")
    LevelService:SetUpLevelColor(0, start)

    local lastCFrame = start:GetPivot()
    local turnCooldown = 0

    for levelNum = 1, General.Levels do
        task.wait()

        LevelService.Levels[levelNum] = {Timer = General.TimerCalc(levelNum), Started = false, DoorOpened = false}

        local rng = Random.new(levelNum * 1000)
        local levelList = LevelData:getList()
        local name
        local data
        local level

        repeat
            local valid = true
            local num = rng:NextInteger(1, #levelList)

            name = levelList[num]
            data = LevelData.Levels[name]

            if data.turn then
                if turnCooldown ~= 0 then
                    valid = false
                end
            end

            if levelNum < data.level then
                valid = false
            end

            if valid then
                if General.LevelOrder[levelNum] then
                    name = General.LevelOrder[levelNum]
                end

                if level then level:Destroy() end
                level = Assets.Levels:FindFirstChild(name):Clone()
                level:PivotTo(lastCFrame)

                local door = Assets.Misc.Door:Clone()
                door:PivotTo(level.Floor.PrimaryPart.Attachment.WorldCFrame)
                door.Parent = level

                local cframe, size = EventService:getBoundingBox(level.Floor)
                local Params = OverlapParams.new()
                Params.FilterType = Enum.RaycastFilterType.Whitelist
                Params.FilterDescendantsInstances = {workspace.Levels:GetChildren()}
                Params.MaxParts = 1
                local touchingParts = workspace:GetPartBoundsInBox(cframe, size - Vector3.new(1,1,1), Params)
                if next(touchingParts) then
                    valid = false
                end
            end

            if not valid then
                table.remove(levelList, num)
            end
        until valid

        if data.elevationChange then
            turnCooldown = math.clamp(turnCooldown - 1, 0, 1)
        elseif data.turn then
            turnCooldown = 2
        end

        lastCFrame = level.Door.PrimaryPart.Attachment.WorldCFrame

        level.Name = levelNum
        level.Door.Level.Front.Label.Text = levelNum
        level.Door.Level.Back.Label.Text = levelNum

        LevelService:SetUpButton(levelNum, level)
        LevelService:SetUpDoor(levelNum, level)
        LevelService:SetUpLevelColor(levelNum, level)
        LevelService:SetUpAdvertisement(levelNum, level)

        level.Parent = workspace.Levels

        if General.Signs[levelNum] then
            level.Door.SignBot.Sign.Top.Label.Text = General.Signs[levelNum]
            local signBotTrack = level.Door.SignBot.AnimationController:LoadAnimation(signBot)
            signBotTrack:Play()
        else
            level.Door.SignBot:Destroy()
        end
    end

    local finish = Assets.Misc:FindFirstChild("Finish"):Clone()
    finish.Name = General.Levels + 1
    LevelService:SetUpLevelColor(General.Levels + 1, finish)
    LevelService:SetUpRestart(finish)

    finish:PivotTo(lastCFrame)
    finish.Parent = workspace.Levels
end

function GameService:SetUpGame()
    GameService:SetUpData()
    GameService:SetUpLevels()
end

return GameService

