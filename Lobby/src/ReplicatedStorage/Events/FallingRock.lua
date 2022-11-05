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
    local rp = EventService.randomPoint(level)
    if rp then
        local rng = Random.new()
        local rock = Assets.Obstacles.Rock:Clone()

        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Whitelist
        Params.FilterDescendantsInstances = {EventService.getFloorGroup(rp.Instance)}

        local height = data.height
        local RayOrigin = rp.Position
        local RayDirection = Vector3.new(0, data.height, 0)
        local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
        if Result then
            height = (rp.Position - Result.Position).Magnitude - rock.Size.Y / 2
        end

        rock.Position = rp.Position + Vector3.new(rng:NextInteger(-data.offset, data.offset), height, rng:NextInteger(-data.offset, data.offset))
        rock.Parent = workspace.Misc

        local touchConnection
        touchConnection = rock.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if player and player.Character and rock.Velocity.Magnitude > 80 then
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
        if rock.Parent ~= nil then
            touchConnection:Disconnect()
            rock:Destroy()
        end
    end
end

return Event