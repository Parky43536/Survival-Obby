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

function Event.Main(levelNum, level, data)
    for i = 1 , EventService.totalUpgrades(levelNum, data.upgrades) + 1 do
        local rpController = EventService.randomPoint(level)
        if rpController then
            local rp = EventService.randomPoint(level, {model = {rpController.Instance}, filter = level.Floor:GetChildren()})
            if rp and rp.Instance == rpController.Instance then
                local spike = Obstacle.Spike:Clone()
                spike.CFrame = CFrame.new(rp.Position, rp.Position + rp.Normal) * CFrame.Angles(math.rad(90), 0, math.rad(180))
                spike.CFrame = spike.CFrame + spike.CFrame.UpVector * -spike.Size.Y / 2
                EventService.parentToObstacles(levelNum, spike)

                local goal = {CFrame = spike.CFrame + spike.CFrame.UpVector * spike.Size.Y}
                local properties = {Time = data.delayTime}
                TweenService.tween(spike, goal, properties)

                task.spawn(function()
                    task.wait(data.delayTime)

                    if spike.Parent ~= nil then
                        local touchConnection
                        touchConnection = spike.Touched:Connect(function(hit)
                            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                            if player and player.Character then
                                if not touchCooldown[player] then
                                    touchCooldown[player] = tick() - EventService.TouchCooldown
                                end
                                if tick() - touchCooldown[player] > EventService.TouchCooldown then
                                    touchCooldown[player] = tick()

                                    AudioService:Create(9119560786, player.Character.PrimaryPart, {Pitch = math.random(10, 20) / 10, Volume = 0.65})

                                    player.Character.Humanoid:TakeDamage(data.damage)
                                end
                            end
                        end)

                        task.wait(data.despawnTime)
                        if spike.Parent ~= nil then
                            touchConnection:Disconnect()
                            spike:Destroy()
                        end
                    end
                end)
            end
        end
    end
end

return Event