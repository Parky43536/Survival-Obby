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
        local nuke = Obstacle.Nuke:Clone()
        local cframe, size = EventService.getBoundingBox(level.Floor)
        local _, nukeSize = EventService.getBoundingBox(nuke)

        local Params = RaycastParams.new()
        Params.FilterType = Enum.RaycastFilterType.Whitelist
        Params.FilterDescendantsInstances = {workspace.Levels:GetChildren()}

        local RayOrigin = cframe.Position + Vector3.new(0, 100, 0)
        local RayDirection = Vector3.new(0, -1000, 0)
        local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
        if Result then
            cframe = CFrame.new(Result.Position)
        end

        local height = data.height
        RayOrigin = cframe.Position
        RayDirection = Vector3.new(0, data.height, 0)
        Result = workspace:Raycast(RayOrigin, RayDirection, Params)
        if Result then
            height = (cframe.Position - Result.Position).Magnitude - nukeSize.Y
        end

        nuke:PivotTo(cframe + Vector3.new(0, height, 0))
        EventService.parentToObstacles(levelNum, nuke)

        local tweenInfo = TweenInfo.new(data.delayTime, Enum.EasingStyle.Linear)
        ModelTweenService.TweenModulePosition(nuke, tweenInfo, cframe.Position)

        -----

        local stand = Obstacle.Stand:Clone()
        stand:SetPrimaryPartCFrame(rOS.CFrame)
        stand.Button.BillboardGui.Label.Text = "Disarm Nuke:\n" .. data.delayTime
        EventService.parentToObstacles(levelNum, stand)

        local touchConnection
        touchConnection = stand.Button.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if player and player.Character then
                nuke:Destroy()

                local pressTime = 0.1
                local goal = {Position = stand.Button.Position - Vector3.new(0, stand.Button.Size.Y - 0.01, 0)}
                local properties = {Time = pressTime}
                TweenService.tween(stand.Button, goal, properties)

                task.wait(pressTime)

                if stand ~= nil then
                    stand:Destroy()
                    touchConnection:Disconnect()
                end
            end
        end)

        task.spawn(function()
            local time = data.delayTime
            for i = 1 , time do
                task.wait(1)
                if stand.Parent ~= nil then
                    stand.Button.BillboardGui.Label.Text = "Disarm Nuke:\n" .. data.delayTime - i
                end
            end
        end)

        -----

        task.wait(data.delayTime)

        if nuke.Parent ~= nil then
            local playersInLevel = EventService.getPlayersInSize(cframe, size + Vector3.new(10, 200, 10))

            for _, player in playersInLevel do
                player.Character.Humanoid:TakeDamage(data.damage)
            end

            local particle = Obstacle.Explosion:Clone()
            particle:PivotTo(cframe)
            particle.Parent = workspace

            AudioService:Create(16433289, cframe.Position, {Volume = 0.8})

            local goal = {Transparency = 0.9, Size = size * 1.5}
            local properties = {Time = 0.15}
            TweenService.tween(particle, goal, properties)

            local goal = {Transparency = 1}
            local properties = {Time = 1.35}
            TweenService.tween(particle, goal, properties)

            game.Debris:AddItem(particle, 1.5)
            nuke:Destroy()
        end

        stand:Destroy()
        touchConnection:Disconnect()
        EventService.toggleObstacleSpawner(levelNum, rOS, false)
    end
end

return Event