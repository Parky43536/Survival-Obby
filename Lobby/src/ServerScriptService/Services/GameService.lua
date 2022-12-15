local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)
local LevelService = require(SerServices.LevelService)

local DataBase = ReplicatedStorage.Database
local EventData = require(DataBase.EventData)
local LevelData = require(DataBase.LevelData)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local AudioService = require(Utility.AudioService)

local GameService = {}

local levels = {}

function GameService.FinishButton(levelNum, level, win)
    EventService.CleanLevel(levelNum, level)

    if win then
        AudioService:Create(1846252166, level.Button.Button, {Volume = 0.25})

        LevelService.OpenDoors(level)
        levels[levelNum].DoorOpened = true

        local cframe, size = EventService.getBoundingBox(level.Floor)
        local playersInLevel = EventService.getPlayersInSize(cframe, size + Vector3.new(10, 200, 10))
        for _, playerInRoom in playersInLevel do
            DataManager:SetSpawn(playerInRoom, levelNum + 1)
        end

        task.wait(General.DoorTime)
    else
        AudioService:Create(9113085663, level.Button.Button, {Volume = 0.5})
    end

    levels[levelNum].DoorOpened = false
    levels[levelNum].Timer = General.TimerCalc(levelNum)
    levels[levelNum].Started = false
    level.Button.Button.Top.Label.Text = "start"
    level.Button.Button.BrickColor = BrickColor.new("Lime green")
end

function GameService.SetUpButton(levelNum, level)
    level.Button.Button.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if player and General.playerCheck(player) and levels[levelNum].Started == false then
            levels[levelNum].Started = true

            LevelService.PressButton(level.Button.Button)
            level.Button.Button.Top.Label.Text = levels[levelNum].Timer
            level.Button.Button.BrickColor = BrickColor.new("Really red")

            for i = 1 , General.TimerCalc(levelNum) do
                for j = 1 , General.EventsPerSecond do
                    LevelService.ButtonEvent(levelNum, level, player)
                    task.wait(1 / General.EventsPerSecond)
                end

                local cframe, size = EventService.getBoundingBox(level.Floor)
                local playersInLevel = EventService.getPlayersInSize(cframe, size + Vector3.new(10, 200, 10))
                if #playersInLevel == 0 then
                    GameService.FinishButton(levelNum, level, false)
                    return
                end

                levels[levelNum].Timer = math.clamp(levels[levelNum].Timer - 1, 0, 99e99)
                level.Button.Button.Top.Label.Text = levels[levelNum].Timer
            end

            GameService.FinishButton(levelNum, level, true)
        end
    end)
end

function GameService.SetUpSpawn(levelNum, level)
    level.Door.Checkpoint.Touched:Connect(function(hit)
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	    if player and levels[levelNum].DoorOpened then
            DataManager:SetSpawn(player, levelNum + 1)
        end
    end)
end

function GameService.SetUpGame()
    --set up level and upgrades in eventdata and signs in general
    local currentLevel = General.LevelMultiple
    local currentEvent = 1

    for _, event in pairs(General.AppearanceOrder) do
        if not EventData[event].blocked then
            EventData[event].level = currentLevel

            if not General.Signs[currentLevel] then
                General.Signs[currentLevel] = EventData[event].name .. "s will now appear"
            end

            currentLevel += General.LevelMultiple
        end
    end

    for levelNum = currentLevel, General.Levels, General.LevelMultiple do
        local event = General.UpgradeOrder[currentEvent]
        if EventData[event].blocked then
            repeat
                currentEvent += 1
                if currentEvent > #General.UpgradeOrder then
                    currentEvent = 1
                end
                event = General.UpgradeOrder[currentEvent]
            until not EventData[event].blocked
        end
        table.insert(EventData[event].upgrades, currentLevel)

        if not General.Signs[currentLevel] then
            General.Signs[currentLevel] = EventData[event].name .. "s have been upgraded"
        end

        currentLevel += General.LevelMultiple
        currentEvent += 1
        if currentEvent > #General.UpgradeOrder then
            currentEvent = 1
        end
    end

    --set up physical levels
    local lastCFrame = workspace.Levels.Beginning:GetPivot()
    local turnsDisabled = false

    for levelNum = 1, General.Levels do
        task.wait()

        levels[levelNum] = {Timer = General.TimerCalc(levelNum), Started = false, DoorOpened = false}

        local rng = Random.new(levelNum * 1000)
        local levelList = LevelData.getList()
        local name
        local data
        local level

        --check if its valid
        repeat
            local valid = true
            local num = rng:NextInteger(1, #levelList)

            name = levelList[num]
            data = LevelData.Levels[name]

            if data.turn then
                if turnsDisabled == true then
                    valid = false
                end
            end

            if levelNum < data.level then
                valid = false
            end

            if valid then
                if level then level:Destroy() end
                level = Assets.Levels:FindFirstChild(name):Clone()
                level:PivotTo(lastCFrame)

                local door = Assets.Misc.Door:Clone()
                door:PivotTo(level.Floor.PrimaryPart.Attachment.WorldCFrame)
                door.Parent = level

                local cframe, size = EventService.getBoundingBox(level.Floor)
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
            turnsDisabled = false
        elseif data.turn then
            turnsDisabled = true
        end

        lastCFrame = level.Door.PrimaryPart.Attachment.WorldCFrame

        level.Name = levelNum
        level.Door.Level.Front.Label.Text = levelNum
        level.Door.Level.Back.Label.Text = levelNum

        if General.Signs[levelNum] then
            level.Door.Sign.Top.Label.Text = General.Signs[levelNum]
        else
            level.Door.Sign:Destroy()
        end

        GameService.SetUpButton(levelNum, level)
        GameService.SetUpSpawn(levelNum, level)
        LevelService.SetUpLevelColor(levelNum, level)

        level.Parent = workspace.Levels
    end
end

return GameService

