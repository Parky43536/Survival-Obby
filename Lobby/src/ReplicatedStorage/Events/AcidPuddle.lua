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
    local upgrades = EventService:totalUpgrades(levelNum, data.upgrades)

    if value == "damage" then
        return data.damage + data.damageIncrease * upgrades
    end
    if value == "size" then
        return data.size + data.sizeIncrease * upgrades
    end
end

function Event.Main(levelNum, level, data)
    local rpController = EventService:randomPoint(level)
    if rpController then
        local rp = EventService:randomPoint(level, {offset = RV(levelNum, data, "size") / 2, model = {rpController.Instance}, filter = level.Floor:GetChildren()})
        if rp and rp.Instance == rpController.Instance then
            local growToSize = RV(levelNum, data, "size")
            local touchConnection

            local originCFrame = CFrame.new(rp.Position, rp.Position + rp.Normal) * CFrame.Angles(math.rad(-90), 0, 0)
            originCFrame += originCFrame.UpVector * -0.1

            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Whitelist
            Params.FilterDescendantsInstances = {EventService:getFloorGroup(rp.Instance)}

            local directions = {0, 90, 180, 270}
            for _, direction in (directions) do
                local directionCFrame = originCFrame * CFrame.Angles(0, math.rad(direction), 0)
                local RayOrigin = (directionCFrame + directionCFrame.LookVector * 100).Position
                local RayDirection = directionCFrame.LookVector * -1000
                local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
                if Result then
                    if not growToSize then
                        growToSize = math.clamp((originCFrame.Position - Result.Position).Magnitude * 2, 0, RV(levelNum, data, "size"))
                    else
                        local testGrowToSize = math.clamp((originCFrame.Position - Result.Position).Magnitude * 2, 0, RV(levelNum, data, "size"))
                        if testGrowToSize < growToSize then
                            growToSize = testGrowToSize
                        end
                    end
                end
            end

            if growToSize then
                local acid = Obstacle.Acid:Clone()
                acid.CFrame = originCFrame
                acid.CFrame += acid.CFrame.UpVector * 0.1
                EventService:parentToObstacles(levelNum, acid)

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

                                player.Character.Humanoid:TakeDamage(RV(levelNum, data, "damage"))
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