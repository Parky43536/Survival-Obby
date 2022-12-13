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
            local spinner = Obstacle.Spinner:Clone()
            spinner:PivotTo(CFrame.new(rp.Position, rp.Position + rp.Normal) * CFrame.Angles(math.rad(180), 0, 0))
            spinner.Beam.Size = Vector3.new(RV(levelNum, data, "size"), spinner.Beam.Size.Y, spinner.Beam.Size.Z)
            EventService.parentToObstacles(levelNum, spinner)

            task.spawn(function()
                task.wait(data.delayTime)

                if spinner.Parent ~= nil then
                    local goal = {CFrame = spinner.Beam.CFrame * CFrame.Angles(0, 0, math.rad(180))}
                    local properties = {Time = 1, Repeat = math.huge}
                    TweenService.tween(spinner.Beam, goal, properties)

                    local touchConnection
                    touchConnection = spinner.Beam.Touched:Connect(function(hit)
                        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
                        if player and player.Character then
                            if not touchCooldown[player] then
                                touchCooldown[player] = tick() - EventService.TouchCooldown
                            end
                            if tick() - touchCooldown[player] > EventService.TouchCooldown then
                                touchCooldown[player] = tick()

                                AudioService:Create(9120917109, player.Character.PrimaryPart, {Pitch = math.random(10, 20) / 10, Volume = 0.75})

                                local physics = Obstacle.Physics:Clone()
                                physics.Parent = player.Character

                                task.wait(data.tripTime)

                                if player and player.Character then
                                    local newscript = Obstacle.GettingUp:Clone()
                                    newscript.Parent = player.Character
                                end
                            end
                        end
                    end)

                    task.wait(data.despawnTime)
                    if spinner.Parent ~= nil then
                        touchConnection:Disconnect()
                        spinner:Destroy()
                    end
                end
            end)
        end
    end
end

return Event