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

    if value == "damage" then
        return data.damage + data.damageIncrease * upgrades
    end
    if value == "size" then
        return data.size + data.sizeIncrease * upgrades
    end
    if value == "speed" then
        return data.speed + data.speedIncrease * upgrades
    end
end

local function destroyRocket(rocket, touchConnection, levelNum, data)
    if rocket.Parent ~= nil then
        if touchConnection then
            touchConnection:Disconnect()
        end

        for _,player in (EventService:getPlayersInRadius(rocket.Position, RV(levelNum, data, "size") / 2)) do
            if General.playerCheck(player) then
                player.Character.Humanoid:TakeDamage(RV(levelNum, data, "damage"))
            end
        end

        local particle = Obstacle.Explosion:Clone()
        particle:PivotTo(rocket.CFrame)
        particle.Parent = workspace

        AudioService:Create(16433289, rocket.Position, {Volume = 0.8})

        local growsize = Vector3.new(1, 1, 1) * RV(levelNum, data, "size")
        local goal = {Transparency = 0.9, Size = growsize}
        local properties = {Time = 0.15}
        TweenService.tween(particle, goal, properties)

        local goal = {Transparency = 1}
        local properties = {Time = 1.35}
        TweenService.tween(particle, goal, properties)

        game.Debris:AddItem(particle, 1.5)

        rocket:Destroy()
    end
end

local function homingRocket(rocket, targetPlayer, levelNum, data)
    local target = targetPlayer.Character.PrimaryPart.Position + rocket.CFrame.LookVector * (data.distance / 2)
    local timeToTarget = (rocket.Position - target).Magnitude / RV(levelNum, data, "speed")

    rocket.CFrame = CFrame.new(rocket.Position, target)

    local goal = {Position = target}
    local properties = {Time = timeToTarget}
    local travelTween = TweenService.tween(rocket, goal, properties)

    return travelTween
end

function Event.Main(levelNum, level, data, name)
    local rOS = EventService:randomObstacleSpawner(levelNum, level)
    if rOS then
        local rocket = Obstacle:FindFirstChild(name):Clone()
        rocket:SetPrimaryPartCFrame(rOS.CFrame)

        local cframe, size = EventService:getBoundingBox(level.Floor)
        local playersInLevel = EventService:getPlayersInSize(cframe, size + Vector3.new(5, 100, 5))
        local targetPlayer = EventService:getClosestPlayer(rocket.Stand.PrimaryPart.Position, playersInLevel)
        local touchConnection = false

        if targetPlayer then
            EventService:parentToObstacles(levelNum, rocket)

            for _ = 1 , data.rate do
                if rocket.Parent ~= nil and General.playerCheck(targetPlayer) then
                    local rocketPos = rocket.Stand.PrimaryPart.Position
                    local targetPos = targetPlayer.Character.PrimaryPart.Position
                    targetPos = targetPos - Vector3.new(0, rocket.Stand.Rocket.Position.Y - rocket.Stand.PrimaryPart.Position.Y, 0)
                    rocket.Stand:SetPrimaryPartCFrame(CFrame.new(rocketPos, targetPos))
                end

                task.wait(data.delayTime/data.rate)
            end

            if rocket.Parent ~= nil then
                local realRocket = rocket.Stand.Rocket
                EventService:parentToObstacles(levelNum, realRocket)
                rocket:Destroy()
                rocket = realRocket
                rocket.Attachment.Fire.Enabled = true

                local target = rocket.CFrame + rocket.CFrame.LookVector * data.distance
                local timeToTarget = (rocket.Position - target.Position).Magnitude / RV(levelNum, data, "speed")

                local Params = RaycastParams.new()
                Params.FilterType = Enum.RaycastFilterType.Whitelist
                Params.FilterDescendantsInstances = {workspace.Levels:GetChildren()}

                local RayOrigin = rocket.Position
                local RayDirection = rocket.CFrame.LookVector * data.distance
                local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                if Result then
                    target = Result
                    timeToTarget = (rocket.Position - target.Position).Magnitude / RV(levelNum, data, "speed")
                end

                local goal = {Position = target.Position}
                local properties = {Time = timeToTarget}
                local travelTween = TweenService.tween(rocket, goal, properties)

                touchConnection = rocket.Touched:Connect(function()
                    destroyRocket(rocket, touchConnection, levelNum, data)
                end)

                Params = RaycastParams.new()
                Params.FilterType = Enum.RaycastFilterType.Blacklist
                Params.FilterDescendantsInstances = {rocket}
                for _ = 1 , data.rate do
                    if rocket.Parent ~= nil then
                        if name == "HomingRocket" and General.playerCheck(targetPlayer) then
                            travelTween:Pause()
                            travelTween = homingRocket(rocket, targetPlayer, levelNum, data)
                        end

                        RayOrigin = rocket.Position
                        RayDirection = rocket.CFrame.LookVector * rocket.Size.Z
                        Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                        if Result then
                            destroyRocket(rocket, touchConnection, levelNum, data)
                        end

                        task.wait(timeToTarget / data.rate)
                    else
                        break
                    end
                end
            end
        end

        destroyRocket(rocket, touchConnection, levelNum, data)

        EventService:toggleObstacleSpawner(levelNum, rOS, false)
    end
end

return Event