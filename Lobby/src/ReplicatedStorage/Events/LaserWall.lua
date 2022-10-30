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
    local rOS1 = EventService.randomObstacleSpawner(levelNum, level)
    local rOS2 = EventService.randomObstacleSpawner(levelNum, level)
    if rOS1 and rOS2 then
        local laserWall = Assets.Obstacles.LaserWall:Clone()
        laserWall.Pillar1:SetPrimaryPartCFrame(rOS1.CFrame)
        laserWall.Pillar2:SetPrimaryPartCFrame(rOS2.CFrame)

        laserWall.Parent = workspace.Misc

        local tweenInfo = TweenInfo.new(data.riseDelayTime)
        ModelTweenService.TweenModuleCFrame(laserWall.Pillar1, tweenInfo, laserWall.Pillar1.PrimaryPart.CFrame + laserWall.Pillar1.PrimaryPart.CFrame.UpVector * 17)
        ModelTweenService.TweenModuleCFrame(laserWall.Pillar2, tweenInfo, laserWall.Pillar2.PrimaryPart.CFrame + laserWall.Pillar2.PrimaryPart.CFrame.UpVector * 17)

        task.wait(data.riseDelayTime)

        for _, beam in pairs(laserWall:GetDescendants()) do
            if beam.Name == "Beam" then
                beam.Enabled = true
            end
        end

        local center1 = laserWall.Pillar1.Center
        local center2 = laserWall.Pillar2.Center
        local wall = Instance.new("Part")
        wall.Transparency = 1
        wall.Anchored = true
        wall.Size = Vector3.new(1, center1.Size.Y, (center1.Position - center2.Position).Magnitude)
        wall.CFrame = CFrame.new(center1.Position, center2.Position) + CFrame.new(center1.Position, center2.Position).LookVector * wall.Size.Z / 2
        wall.Parent = laserWall

        local touchConnection
        touchConnection = wall.Touched:Connect(function(hit)
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
        touchConnection:Disconnect()
        laserWall:Destroy()

        EventService.toggleObstacleSpawner(levelNum, rOS1, false)
        EventService.toggleObstacleSpawner(levelNum, rOS2, false)
    end
end

return Event