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

            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Whitelist
            Params.FilterDescendantsInstances = {rp.Instance}

            local lava = Assets.Obstacles.Lava:Clone()

            if rng:NextInteger(1, 2) == 1 then
                local RayOrigin = Vector3.new(rp.Position.X, rp.Instance.Position.Y + 100, rp.Instance.Position.Z)
                local RayDirection = Vector3.new(0, -1000, 0)
                local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                if Result then
                    local hitPoint = Vector3.new(rp.Position.X, Result.Position.Y, rp.Instance.Position.Z)
                    lava.CFrame = CFrame.new(hitPoint, hitPoint + rp.Normal) * CFrame.Angles(math.rad(90), 0, 0)

                    RayOrigin = (lava.CFrame + lava.CFrame.RightVector * 100).Position
                    RayDirection = lava.CFrame.RightVector * -1000
                    Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                    if Result then
                        lava.Size = Vector3.new((lava.Position - Result.Position).Magnitude * 2, lava.Size.Y, lava.Size.Z) - Vector3.new(0.01, 0, 0.01)
                        lava.CFrame *= CFrame.Angles(0, 0, math.rad(180))
                        lava.Parent = workspace.Misc
                    end
                end
            else
                local RayOrigin = Vector3.new(rp.Instance.Position.X, rp.Instance.Position.Y + 100, rp.Position.Z)
                local RayDirection = Vector3.new(0, -1000, 0)
                local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                if Result then
                    local hitPoint = Vector3.new(rp.Instance.Position.X, Result.Position.Y, rp.Position.Z)
                    lava.CFrame = CFrame.new(hitPoint, hitPoint + rp.Normal) * CFrame.Angles(math.rad(90), 0, 0)

                    RayOrigin = (lava.CFrame + lava.CFrame.LookVector * 50).Position
                    RayDirection = lava.CFrame.LookVector * -100
                    Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                    if Result then
                        lava.Size = Vector3.new(lava.Size.X, lava.Size.Y, (lava.Position - Result.Position).Magnitude * 2) - Vector3.new(0.01, 0, 0.01)
                        lava.CFrame *= CFrame.Angles(0, 0, math.rad(180))
                        lava.Parent = workspace.Misc
                    end
                end
            end

            if lava.Parent then
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
            else
                lava:Destroy()
            end
        end
    end
end

return Event