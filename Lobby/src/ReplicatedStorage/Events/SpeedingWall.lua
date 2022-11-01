local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local Event = {}

function Event.Main(levelNum, level, data)
    local rp = EventService.randomPoint(level, {offset = 6})
    if rp then
        local rng = Random.new()
        local position1
        local position2
        local originCFrame = CFrame.new(rp.Position - Vector3.new(0, 1, 0), rp.Position + rp.Normal) * CFrame.Angles(math.rad(-90), 0, 0)

        if rng:NextInteger(1, 2) == 1 then
            originCFrame *= CFrame.Angles(0, math.rad(90), 0)
        end

        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Whitelist
        Params.FilterDescendantsInstances = {EventService.getFloorGroup(rp.Instance)}

        local RayOrigin = (originCFrame + originCFrame.LookVector * 100).Position
        local RayDirection = originCFrame.LookVector * -1000
        local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
        if Result then
            position1 = Result.Position
        end

        RayOrigin = (originCFrame + originCFrame.LookVector * -100).Position
        RayDirection = originCFrame.LookVector * 1000
        Result = workspace:Raycast(RayOrigin, RayDirection, Params)
        if Result then
            position2 = Result.Position
        end

        if position1 and position2 then
            local wall = Assets.Obstacles.SpeedingWall:Clone()

            position1 += Vector3.new(0, 1 + wall.Size.Y/2, 0)
            position2 += Vector3.new(0, 1 + wall.Size.Y/2, 0)

            wall.BrickColor = BrickColor.random()
            wall.CFrame = CFrame.new(position1, position2)
            wall.Parent = workspace.Misc

            local timeToTarget = (position1 - position2).Magnitude / data.speed
            local goal = {CFrame = wall.CFrame + wall.CFrame.LookVector * (position1 - position2).Magnitude}
            local properties = {Time = timeToTarget}
            TweenService.tween(wall, goal, properties)

            task.wait(timeToTarget)

            if wall.Parent ~= nil then
                wall:Destroy()
            end
        end
    end
end

return Event