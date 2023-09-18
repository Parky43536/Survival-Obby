local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IsServer = RunService:IsServer()

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
local killCooldown = {}
local bots = {}

local walk = Instance.new("Animation")
walk.AnimationId = "rbxassetid://14813265572"
walk.Parent = script

local function RV(levelNum, data, value)
    local upgrades = EventService:totalUpgrades(levelNum, data.upgrades)

    if value == "speed" then
        return data.speed + data.speedIncrease * upgrades
    end
end

function Event.MoveBot(bot, level)
    local cframe, size = EventService:getBoundingBox(level.Floor)
    local playersInLevel = EventService:getPlayersInSize(cframe, size + Vector3.new(5, 100, 5))
    if bot and bot.PrimaryPart then
        local targetPlayer = EventService:getClosestPlayer(bot.PrimaryPart.Position, playersInLevel)
        if targetPlayer then
            bot.Humanoid:MoveTo(targetPlayer.Character.PrimaryPart.Position, targetPlayer.Character.PrimaryPart)
        end
    end
end

function Event.MoveBots()
    for i, data in pairs(bots) do
        if data.bot == nil or data.bot.Parent == nil then
            table.remove(bots, i)
            continue
        end

        Event.MoveBot(data.bot, data.level)
    end
end

function Event.Main(levelNum, level, data)
    local rp = EventService:randomPoint(level)
    if rp then
        local bot = Obstacle.ButtonBot:Clone()

        local cframe, size = EventService:getBoundingBox(level.Floor)
        local playersInLevel = EventService:getPlayersInSize(cframe, size + Vector3.new(5, 100, 5))
        local targetPlayer = EventService:getClosestPlayer(rp.Position, playersInLevel)
        if targetPlayer then
            bot:SetPrimaryPartCFrame(CFrame.new(rp.Position + Vector3.new(0, 1, 0), targetPlayer.Character.PrimaryPart.Position))
        else
            bot:SetPrimaryPartCFrame(CFrame.new(rp.Position + Vector3.new(0, 1, 0)))
        end

        EventService:parentToObstacles(levelNum, bot)

        task.wait(0.5) --activation delay

        bot.Humanoid.WalkSpeed = RV(levelNum, data, "speed")

        local walkTrack = bot.Humanoid.Animator:LoadAnimation(walk)
        bot.Humanoid.Running:Connect(function(speed)
            if speed > 0 then
                if not walkTrack.IsPlaying then
                    walkTrack:Play()
                end
            else
                if walkTrack.IsPlaying then
                    walkTrack:Stop()
                end
            end
        end)

        local touchConnection
        touchConnection = bot.Hitbox.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if player and player.Character then
                if not killCooldown[player] then
                    killCooldown[player] = tick() - EventService.TouchCooldown / 2
                end
                if tick() - killCooldown[player] > EventService.TouchCooldown / 2 then
                    killCooldown[player] = tick()

                    if player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Running and
                        player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and
                        player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then

                        local particle = Obstacle.Explosion:Clone()
                        particle:PivotTo(bot.PrimaryPart.CFrame)
                        particle.Parent = workspace

                        AudioService:Create(16433289, bot.PrimaryPart.Position, {Volume = 0.4})

                        local growsize = Vector3.new(1, 1, 1) * 4
                        local goal = {Transparency = 0.9, Size = growsize}
                        local properties = {Time = 0.15}
                        TweenService.tween(particle, goal, properties)

                        local goal = {Transparency = 1}
                        local properties = {Time = 1.35}
                        TweenService.tween(particle, goal, properties)

                        game.Debris:AddItem(particle, 1.5)

                        bot:Destroy()
                        touchConnection:Disconnect()
                        return
                    end
                end

                if not touchCooldown[player] then
                    touchCooldown[player] = tick() - EventService.TouchCooldown
                end
                if tick() - touchCooldown[player] > EventService.TouchCooldown then
                    touchCooldown[player] = tick()

                    AudioService:Create(45428486, player.Character.PrimaryPart, {Pitch = 5 + (math.random(0, 20) / 10), Volume = 0.5})

                    player.Character.Humanoid:TakeDamage(data.damage)
                end
            end
        end)

        Event.MoveBot(bot, level)

        table.insert(bots, {
            bot = bot,
            level = level,
        })
    end
end

if IsServer then
    task.spawn(function()
        while true do
            task.wait(1)
            Event.MoveBots()
        end
    end)
end

return Event