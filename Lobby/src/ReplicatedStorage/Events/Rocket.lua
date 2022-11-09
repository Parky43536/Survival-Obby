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

local function destroyRocket(rocket, touchConnection, data)
    if rocket.Parent ~= nil then
        if touchConnection then
            touchConnection:Disconnect()
        end

        for _,player in pairs(EventService.getPlayersInRadius(rocket.Position, data.size / 2)) do
            if General.playerCheck(player) then
                player.Character.Humanoid:TakeDamage(data.damage)
            end
        end

        local particle = Obstacle.Explosion:Clone()
        particle:PivotTo(rocket.CFrame)
        particle.Parent = workspace

        AudioService:Create(16433289, rocket.Position, {Volume = 0.8})

        local growsize = Vector3.new(1, 1, 1) * data.size
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

function Event.Main(levelNum, level, data)
    local rOS = EventService.randomObstacleSpawner(levelNum, level)
    if rOS then
        local rocket = Obstacle.Rocket:Clone()
        rocket:SetPrimaryPartCFrame(rOS.CFrame)

        local cframe, size = EventService.getBoundingBox(level.Floor)
        local playersInLevel = EventService.getPlayersInSize(cframe, size + Vector3.new(10, 100, 10))
        local targetPlayer = EventService.getClosestPlayer(rocket.Stand.PrimaryPart.Position, playersInLevel)
        local touchConnection = false

        if targetPlayer then
            EventService.parentToObstacles(levelNum, rocket)

            for i = 1 , data.faceRate do
                if rocket.Parent ~= nil and General.playerCheck(targetPlayer) then
                    local rocketPos = rocket.Stand.PrimaryPart.Position
                    local targetPos = targetPlayer.Character.PrimaryPart.Position
                    targetPos = targetPos - Vector3.new(0, rocket.Stand.Rocket.Position.Y - rocket.Stand.PrimaryPart.Position.Y, 0)
                    rocket.Stand:SetPrimaryPartCFrame(CFrame.new(rocketPos, targetPos))
                end

                task.wait(data.delayTime/data.faceRate)
            end

            if rocket.Parent ~= nil then
                local realRocket = rocket.Stand.Rocket
                EventService.parentToObstacles(levelNum, realRocket)
                rocket:Destroy()
                rocket = realRocket
                rocket.Attachment.Fire.Enabled = true

                local target = rocket.CFrame + rocket.CFrame.lookVector * 100
                local timeToTarget = (rocket.Position - target.Position).Magnitude / data.speed

                local RayOrigin = rocket.Position
                local RayDirection = rocket.CFrame.lookVector * 100

                local Params = RaycastParams.new()
                Params.FilterType = Enum.RaycastFilterType.Whitelist
                Params.FilterDescendantsInstances = {workspace.Levels:GetChildren()}

                local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                if Result then
                    target = Result
                    timeToTarget = (rocket.Position - target.Position).Magnitude / data.speed
                end

                local goal = {Position = target.Position}
                local properties = {Time = timeToTarget}
                TweenService.tween(rocket, goal, properties)

                touchConnection = rocket.Touched:Connect(function()
                    destroyRocket(rocket, touchConnection, data)
                end)

                task.wait(timeToTarget)
            end
        end

        destroyRocket(rocket, touchConnection, data)

        EventService.toggleObstacleSpawner(levelNum, rOS, false)
    end
end

return Event