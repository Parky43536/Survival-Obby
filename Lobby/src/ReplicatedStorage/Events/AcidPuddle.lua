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

local touchCooldown = {}

local function RV(levelNum, data, value)
    local upgrades = EventService.totalUpgrades(levelNum, data.upgrades)

    if value == "size" then
        return data.size + data.sizeIncrease * upgrades
    end
end

function Event.Main(levelNum, level, data)
    local rpController = EventService.randomPoint(level)
    if rpController then
        local rp = EventService.randomPoint(level, {offset = RV(levelNum, data, "size") / 2, model = {rpController.Instance}, filter = level.Floor:GetChildren()})
        if rp and rp.Instance == rpController.Instance then
            local growToSize = RV(levelNum, data, "size")
            local touchConnection

            local originCFrame = CFrame.new(rp.Position, rp.Position + rp.Normal) * CFrame.Angles(math.rad(-90), 0, 0)
            originCFrame += originCFrame.UpVector * -0.1

            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Whitelist
            Params.FilterDescendantsInstances = {EventService.getFloorGroup(rp.Instance)}

            local RayOrigin = (originCFrame + originCFrame.LookVector * 100).Position
            local RayDirection = originCFrame.LookVector * -1000
            local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
            if Result then
                growToSize = math.clamp((originCFrame.Position - Result.Position).Magnitude * 2, 0, RV(levelNum, data, "size"))
            end

            RayOrigin = (originCFrame + originCFrame.RightVector * 100).Position
            RayDirection = originCFrame.RightVector * -1000
            Result = workspace:Raycast(RayOrigin, RayDirection, Params)
            if Result then
                local testGrowToSize = math.clamp((originCFrame.Position - Result.Position).Magnitude * 2, 0, RV(levelNum, data, "size"))
                if testGrowToSize < growToSize or growToSize < 4 then
                    growToSize = testGrowToSize
                end
            end

            if growToSize and growToSize > 4 then
                local acid = Obstacle.Acid:Clone()
                acid.CFrame = originCFrame
                acid.CFrame += acid.CFrame.UpVector * 0.1
                EventService.parentToObstacles(levelNum, acid)

                local goal = {Size = Vector3.new(growToSize, acid.Size.Y, growToSize)}
                local properties = {Time = data.growTime}
                TweenService.tween(acid, goal, properties)

                local goal2 = {Transparency = 0.5}
                local properties2 = {Time = data.delayTime}
                TweenService.tween(acid, goal2, properties2)

                task.wait(data.delayTime)

                if acid.Parent ~= nil then
                    acid.AcidParticle.Enabled = true

                    touchConnection = acid.Touched:Connect(function(hit)
                        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                        if player and player.Character then
                            if not touchCooldown[player] then
                                touchCooldown[player] = tick() - EventService.TouchCooldown
                            end
                            if tick() - touchCooldown[player] > EventService.TouchCooldown then
                                touchCooldown[player] = tick()

                                AudioService:Create(9119991790, player.Character.PrimaryPart, {TimePosition = 2, Volume = 0.5})

                                player.Character.Humanoid:TakeDamage(data.damage)
                            end
                        end
                    end)

                    task.wait(data.despawnTime)

                    if acid.Parent ~= nil then
                        touchConnection:Disconnect()
                        acid:Destroy()
                    end
                end
            end
        end
    end
end

return Event