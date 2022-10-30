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
        local rp = EventService.randomPoint(level, {model = {rpController.Instance}, filter = level.Floor:GetChildren()})
        if rp and rp.Instance == rpController.Instance then
            local spike = Assets.Obstacles.Spike:Clone()
            spike.CFrame = CFrame.new(rp.Position, rp.Position + rp.Normal) * CFrame.Angles(math.rad(90), 0, math.rad(180))
            spike.CFrame = spike.CFrame + spike.CFrame.UpVector * -spike.Size.Y / 2
            spike.Parent = workspace.Misc

            local goal = {CFrame = spike.CFrame + spike.CFrame.UpVector * spike.Size.Y}
            local properties = {Time = data.delayTime}
            TweenService.tween(spike, goal, properties)

            task.wait(data.delayTime)

            local touchConnection
            touchConnection = spike.Touched:Connect(function(hit)
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
            if spike.Parent ~= nil then
                touchConnection:Disconnect()
                spike:Destroy()
            end
        end
    end
end

return Event