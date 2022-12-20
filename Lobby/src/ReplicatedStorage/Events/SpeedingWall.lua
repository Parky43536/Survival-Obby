local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Obstacles = Assets.Obstacles
local Obstacle = Obstacles:FindFirstChild(script.Name)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local Event = {}

local function RV(levelNum, data, value)
    local upgrades = EventService:totalUpgrades(levelNum, data.upgrades)

    if value == "size" then
        return data.size + data.sizeIncrease * upgrades
    end
end

function Event.Main(levelNum, level, data)
    local rpController = EventService:randomPoint(level)
    if rpController then
        local rp = EventService:randomPoint(level, {offset = RV(levelNum, data, "size") / 2, model = {rpController.Instance}})
        if rp then
            local rng = Random.new()
            local position1
            local position2
            local originCFrame = CFrame.new(rp.Position, rp.Position + rp.Normal) * CFrame.Angles(math.rad(-90), 0, 0)
            originCFrame += originCFrame.UpVector * -0.1

            if rng:NextInteger(1, 2) == 1 then
                originCFrame *= CFrame.Angles(0, math.rad(90), 0)
            end

            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Whitelist
            Params.FilterDescendantsInstances = {EventService:getFloorGroup(rp.Instance)}

            local directions = {0, 180}
            for i, direction in (directions) do
                local directionCFrame = originCFrame * CFrame.Angles(0, math.rad(direction), 0)
                local RayOrigin = (directionCFrame + directionCFrame.LookVector * 100).Position
                local RayDirection = directionCFrame.LookVector * -1000
                local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                if Result then
                    if i == 1 then
                        position1 = Result.Position
                    else
                        position2 = Result.Position
                    end
                end
            end

            if position1 and position2 then
                local wall = Obstacle.SpeedingWall:Clone()
                wall.BrickColor = BrickColor.random()
                wall.Size = Vector3.new(RV(levelNum, data, "size"), RV(levelNum, data, "size"), 2)
                wall.CFrame = CFrame.new(position2, position1)
                wall.CFrame = (originCFrame - originCFrame.Position) + wall.Position
                wall.CFrame += wall.CFrame.UpVector * (wall.Size.Y/2 + 0.1)
                EventService:parentToObstacles(levelNum, wall)

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
end

return Event