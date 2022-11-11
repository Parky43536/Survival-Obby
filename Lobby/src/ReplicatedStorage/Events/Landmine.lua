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
    local rp = EventService.randomPoint(level)
    if rp then
        local originCFrame = CFrame.new(rp.Position, rp.Position + rp.Normal) * CFrame.Angles(math.rad(-90), 0, 0)
        local landmine = Obstacle.Landmine:Clone()
        landmine:PivotTo(originCFrame)
        EventService.parentToObstacles(levelNum, landmine)

        task.wait(data.delayTime)
        if landmine.Parent ~= nil then
            if levelNum >= data.upgrade then
                local tweenInfo = TweenInfo.new(data.delayTime)
                ModelTweenService.TweenModuleTransparency(landmine, tweenInfo, 0.9)
            end

            local hit = false
            local touchConnection
            touchConnection = landmine.PrimaryPart.Touched:Connect(function()
                if not hit then
                    hit = true

                    if landmine.Parent ~= nil then
                        for _,player in pairs(EventService.getPlayersInRadius(landmine.PrimaryPart.Position, data.size / 2)) do
                            if General.playerCheck(player) then
                                player.Character.Humanoid:TakeDamage(data.damage)
                            end
                        end

                        local particle = Obstacle.Explosion:Clone()
                        particle:PivotTo(landmine.PrimaryPart.CFrame)
                        particle.Parent = workspace

                        AudioService:Create(16433289, landmine.PrimaryPart.Position, {Volume = 0.8})

                        local growsize = Vector3.new(1, 1, 1) * data.size
                        local goal = {Transparency = 0.9, Size = growsize}
                        local properties = {Time = 0.15}
                        TweenService.tween(particle, goal, properties)

                        local goal = {Transparency = 1}
                        local properties = {Time = 1.35}
                        TweenService.tween(particle, goal, properties)

                        game.Debris:AddItem(particle, 1.5)
                        touchConnection:Disconnect()
                        landmine:Destroy()
                    end
                end
            end)

            task.wait(data.despawnTime)
            if landmine.Parent ~= nil then
                touchConnection:Disconnect()
                landmine:Destroy()
            end
        end
    end
end

return Event