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
end

function Event.Main(levelNum, level, data)
    local rOS1 = EventService:randomObstacleSpawner(levelNum, level)
    local rOS2 = EventService:randomObstacleSpawner(levelNum, level)
    if rOS1 and rOS2 then
        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Whitelist
        Params.FilterDescendantsInstances = {level.Floor:GetChildren()}

        local RayOrigin = rOS1.Position
        local RayDirection = CFrame.new(rOS1.Position, rOS2.Position).LookVector * (rOS1.Position - rOS2.Position).Magnitude
        local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
        if Result then
            EventService:toggleObstacleSpawner(levelNum, rOS1, false)
            EventService:toggleObstacleSpawner(levelNum, rOS2, false)

            return
        end

        local laserWall = Obstacle.LaserWall:Clone()
        laserWall.Pillar1:SetPrimaryPartCFrame(CFrame.new(rOS1.Position))
        laserWall.Pillar2:SetPrimaryPartCFrame(CFrame.new(rOS2.Position))

        EventService:parentToObstacles(levelNum, laserWall)

        local tweenInfo = TweenInfo.new(data.riseDelayTime)
        ModelTweenService.TweenModuleCFrame(laserWall.Pillar1, tweenInfo, laserWall.Pillar1.PrimaryPart.CFrame + laserWall.Pillar1.PrimaryPart.CFrame.UpVector * 17)
        ModelTweenService.TweenModuleCFrame(laserWall.Pillar2, tweenInfo, laserWall.Pillar2.PrimaryPart.CFrame + laserWall.Pillar2.PrimaryPart.CFrame.UpVector * 17)

        task.wait(data.laserDelayTime)

        if laserWall.Parent ~= nil then
            for _, beam in (laserWall:GetDescendants()) do
                if beam.Name == "Beam" then
                    beam.Enabled = true
                end
            end

            local center1 = laserWall.Pillar1.Center
            local center2 = laserWall.Pillar2.Center
            local wall = Instance.new("Part")
            wall.Transparency = 1
            wall.Anchored = true
            wall.Size = Vector3.new(0.5, center1.Size.Y, (center1.Position - center2.Position).Magnitude - 4)
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

                        AudioService:Create(9118068272, player.Character.PrimaryPart, {TimePosition = 0.2, Volume = 0.65})

                        player.Character.Humanoid:TakeDamage(RV(levelNum, data, "damage"))
                    end
                end
            end)

            task.wait(data.despawnTime)
            if laserWall.Parent ~= nil then
                touchConnection:Disconnect()
                laserWall:Destroy()

                EventService:toggleObstacleSpawner(levelNum, rOS1, false)
                EventService:toggleObstacleSpawner(levelNum, rOS2, false)
            end
        end
    end
end

return Event