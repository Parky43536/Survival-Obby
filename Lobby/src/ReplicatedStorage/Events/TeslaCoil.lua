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

function Event.Main(levelNum, level, data)
    local rOS = EventService.randomObstacleSpawner(levelNum, level)
    if rOS then
        local coil = Obstacle.TeslaCoil:Clone()
        coil:SetPrimaryPartCFrame(rOS.CFrame)
        EventService.parentToObstacles(levelNum, coil)

        local goal = {Transparency = 0.1}
        local properties = {Time = data.delayTime}
        TweenService.tween(coil.Effect, goal, properties)
        task.wait(data.delayTime)
        coil.Effect.Attachment.Bolts1.Enabled = true
        coil.Effect.Attachment.Bolts2.Enabled = true

        local cframe, size = EventService.getBoundingBox(level.Floor)
        for i = 1 , data.damageTicks do
            if coil.Parent ~= nil then
                for _,player in pairs(EventService.getPlayersInRadius(coil.Effect.Position, data.size / 2)) do
                    if General.playerCheck(player) then
                        local laser = Obstacle.Laser:Clone()
                        laser.Beam.Position = coil.Effect.Position
                        laser.Hit.Position = player.Character.PrimaryPart.Position
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = player.Character.PrimaryPart
                        weld.Part1 = laser.Hit
                        weld.Parent = laser.Hit
                        EventService.parentToObstacles(levelNum, laser)
                        game.Debris:AddItem(laser, data.damageDelay / 2)

                        player.Character.Humanoid:TakeDamage(data.damage)
                    end
                end
            end

            task.wait(data.damageDelay)
        end

        if coil.Parent ~= nil then
            coil:Destroy()
        end

        EventService.toggleObstacleSpawner(levelNum, rOS, false)
    end
end

return Event