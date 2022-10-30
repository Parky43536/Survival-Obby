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
        local rp = EventService.randomPoint(level, {offset = data.size/2, model = {rpController.Instance}, filter = level.Floor:GetChildren()})
        if rp and rp.Instance == rpController.Instance then
            local growToSize
            local touchConnection

            local acid = Assets.Obstacles.Acid:Clone()
            acid.CFrame = CFrame.new(rp.Position, rp.Position + rp.Normal) * CFrame.Angles(math.rad(90), 0, 0)
            acid.Parent = workspace.Misc

            local Params = RaycastParams.new()
            Params.FilterType = Enum.RaycastFilterType.Whitelist
            Params.FilterDescendantsInstances = {rp.Instance}
            local RayOrigin = (acid.CFrame + acid.CFrame.LookVector * 100).Position
            local RayDirection = acid.CFrame.LookVector * -1000
            local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
            if Result then
                growToSize = math.clamp((acid.Position - Result.Position).Magnitude * 2, 0, data.size)
                acid.CFrame *= CFrame.Angles(0, 0, math.rad(180))
                acid.Parent = workspace.Misc
            end

            if acid.Parent and growToSize and growToSize > 4 then
                local goal = {Size = Vector3.new(growToSize, acid.Size.Y, growToSize)}
                local properties = {Time = data.growTime}
                TweenService.tween(acid, goal, properties)

                local goal2 = {Transparency = 0.5}
                local properties2 = {Time = data.delayTime}
                TweenService.tween(acid, goal2, properties2)

                task.wait(data.delayTime)

                acid.AcidParticle.Enabled = true

                touchConnection = acid.Touched:Connect(function(hit)
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

                if acid.Parent ~= nil then
                    touchConnection:Disconnect()
                    acid:Destroy()
                end
            else
                acid:Destroy()
            end
        end
    end
end

return Event