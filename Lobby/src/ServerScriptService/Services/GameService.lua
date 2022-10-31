local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)
local LevelService = require(SerServices.LevelService)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)

local GameService = {}

local levels = {}

function GameService.FinishButton(levelNum, level, win)
    if win then
        LevelService.OpenDoors(level)
        levels[levelNum].DoorOpened = true

        local cframe, size = EventService.getBoundingBox(level.Floor)
        local playersInLevel = EventService.getPlayersInSize(cframe, size + Vector3.new(4, 100, 4))
        for _, playerInRoom in playersInLevel do
            DataManager:SetSpawn(playerInRoom, levelNum + 1)
        end

        task.wait(General.DoorTime)
    end

    levels[levelNum].DoorOpened = false
    levels[levelNum].Timer = General.TimerCalc(levelNum)
    levels[levelNum].Started = false
    level.Button.Button.Top.Label.Text = "start"
    level.Button.Button.BrickColor = BrickColor.new("Lime green")
end

function GameService.SetUpButton(levelNum, level)
    level.Button.Button.ClickDetector.MouseClick:connect(function(player)
        if General.playerCheck(player) and levels[levelNum].Started == false then
            levels[levelNum].Started = true

            LevelService.PressButton(level.Button.Button)
            level.Button.Button.Top.Label.Text = levels[levelNum].Timer
            level.Button.Button.BrickColor = BrickColor.new("Really red")

            for i = 1 , General.TimerCalc(levelNum) do
                for j = 1 , General.EventsPerSecond do
                    LevelService.ButtonEvent(levelNum, level, player)
                    task.wait(1/General.EventsPerSecond)
                end

                local cframe, size = EventService.getBoundingBox(level.Floor)
                local playersInLevel = EventService.getPlayersInSize(cframe, size + Vector3.new(4, 100, 4))
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
    local lastCFrame = workspace.Levels.Beginning:GetPivot()
    local lastLevel

    for levelNum = 1 , General.Levels do
        levels[levelNum] = {Timer = General.TimerCalc(levelNum), Started = false, DoorOpened = false}

        local rng = Random.new(levelNum * 1000)
        local totalLevels = Assets.Levels:GetChildren()
        local touching = false
        local level

        repeat
            local num = rng:NextInteger(1, #totalLevels)

            if level then level:Destroy() end
            level = totalLevels[num]:Clone()
            level:PivotTo(lastCFrame)

            table.remove(totalLevels, num)

            touching = false
            local Params = OverlapParams.new()
            Params.FilterType = Enum.RaycastFilterType.Whitelist
            Params.FilterDescendantsInstances = {workspace.Levels:GetChildren()}
            Params.MaxParts = 1
            local touchingParts = workspace:GetPartBoundsInBox(level.Door.PrimaryPart.Attachment.WorldCFrame, Vector3.new(5, 5, 5), Params)
            if next(touchingParts) then
                touching = true
            end
        until touching == false and level.Name ~= lastLevel

        lastCFrame = level.Door.PrimaryPart.Attachment.WorldCFrame
        lastLevel = level.Name
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

