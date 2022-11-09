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
    if value == "damage" then
        if levelNum >= data.upgrade then
            return data.upgradedDamage
        else
            return data.damage
        end
    end
    if value == "size" then
        if levelNum >= data.upgrade then
            return data.upgradedSize
        else
            return data.size
        end
    end
    if value == "bomb" then
        if levelNum >= data.upgrade then
            return Obstacle.UpgradedBomb
        else
            return Obstacle.Bomb
        end
    end
    if value == "explosion" then
        if levelNum >= data.upgrade then
            return Obstacle.UpgradedExplosion
        else
            return Obstacle.Explosion
        end
    end
end

function Event.Main(levelNum, level, data)
    local rp = EventService.randomPoint(level)
    if rp then
        local bomb = RV(levelNum, data, "bomb"):Clone()
        bomb.Position = rp.Position + Vector3.new(0, 3.5, 0)
        EventService.parentToObstacles(levelNum, bomb)

        AudioService:Create(11565378, bomb, {Volume = 0.8, Duration = 2})

        task.wait(data.delayTime)

        if bomb.Parent ~= nil then
            for _,player in pairs(EventService.getPlayersInRadius(bomb.Position, RV(levelNum, data, "size") / 2)) do
                if General.playerCheck(player) then
                    player.Character.Humanoid:TakeDamage(RV(levelNum, data, "damage"))
                end
            end

            local particle = RV(levelNum, data, "explosion"):Clone()
            particle:PivotTo(bomb.CFrame)
            particle.Parent = workspace

            AudioService:Create(16433289, bomb.Position, {Volume = 0.8})

            local growsize = Vector3.new(1, 1, 1) * RV(levelNum, data, "size")
            local goal = {Transparency = 0.9, Size = growsize}
            local properties = {Time = 0.15}
            TweenService.tween(particle, goal, properties)

            local goal = {Transparency = 1}
            local properties = {Time = 1.35}
            TweenService.tween(particle, goal, properties)

            game.Debris:AddItem(particle, 1.5)
            bomb:Destroy()
        end
    end
end

return Event