local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local EventService = require(Utility.EventService)
local TweenService = require(Utility.TweenService)
local ModelTweenService = require(Utility.ModelTweenService)
local AudioService = require(Utility.AudioService)

local Event = {}

local touchCooldown = {}

function Event.Main(levelNum, level, data)
    local rpController = EventService.randomPoint(level)
    if rpController then
        local rp = EventService.randomPoint(level, {model = {rpController.Instance}})
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
                local lava = Assets.Obstacles.Lava:Clone()
                lava.Size = Vector3.new(lava.Size.X, lava.Size.Y, (position1 - position2).Magnitude)
                lava.CFrame = CFrame.new(position1, position2) + CFrame.new(position1, position2).LookVector * lava.Size.Z / 2
                lava.CFrame = (originCFrame - originCFrame.Position) + lava.Position
                lava.CFrame += lava.CFrame.UpVector * 0.1
                lava.Size -= Vector3.new(0.01, 0, 0.01)
                lava.Parent = workspace.Misc

                local goal = {Transparency = 0.1}
                local properties = {Time = data.delayTime}
                TweenService.tween(lava, goal, properties)

                task.wait(data.delayTime)

                lava.LavaParticle.Enabled = true

                local touchConnection
                touchConnection = lava.Touched:Connect(function(hit)
                    local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                    if player and player.Character then
                        if not touchCooldown[player] then
                            touchCooldown[player] = tick() - EventService.TouchCooldown
                        end
                        if tick() - touchCooldown[player] > EventService.TouchCooldown then
                            touchCooldown[player] = tick()
                            player.Character.Humanoid:TakeDamage(data.damage)
                        end
                    end
                end)

                task.wait(data.despawnTime)
                if lava.Parent ~= nil then
                    touchConnection:Disconnect()
                    lava:Destroy()
                end
            end
        end
    end
end

return Event