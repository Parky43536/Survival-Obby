local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local TogglesFrame = PlayerUi:WaitForChild("TogglesFrame")

local Assets = ReplicatedStorage.Assets

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.maxTorque = Vector3.new(1, 1, 1)*10^6
bodyGyro.P = 10^6

local bodyVel = Instance.new("BodyVelocity")
bodyVel.maxForce = Vector3.new(1, 1, 1)*10^6
bodyVel.P = 10^4

local isFlying = false
local FlySpeed = 50
local character
local hrp
local humanoid
local animate
local idleAnim
local moveAnim
local lastAnim

local function positionVisual(position, args)
    if not args then args = {} end

    local part = Instance.new("Part")
    part.Size = args.size or Vector3.new(1,1,1)
    part.Transparency = args.transparency or 0
    part.BrickColor = BrickColor.new("Bright red")
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace
    if typeof(position) == "Vector3" then
        part.Position = position
    else
        part.CFrame = position
    end

    if args.duration then
        task.spawn(function()
            task.wait(args.duration)
            part:Destroy()
        end)
    end
end

local function setFlying(flying)
	isFlying = flying
	bodyGyro.Parent = isFlying and hrp or nil
	bodyVel.Parent = isFlying and hrp or nil
	bodyGyro.CFrame = hrp.CFrame
	bodyVel.Velocity = Vector3.new()
	animate.Disabled = isFlying
	if (isFlying) then
		lastAnim = idleAnim
		lastAnim:Play()

		for _, characterPart in pairs(LocalPlayer.Character:GetChildren()) do
			if characterPart:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(characterPart, "FlyingPlayer")
			end
		end
	elseif lastAnim then
		lastAnim:Stop()

		for _, characterPart in pairs(LocalPlayer.Character:GetChildren()) do
			if characterPart:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(characterPart, "Player")
			end
		end
	end
end

local function onUpdate()
	if (isFlying) then
		local cf = Camera.CFrame

		if humanoid.MoveDirection ~= Vector3.new(0,0,0) then
			local lookCFrame = cf + cf.LookVector * FlySpeed
			local alignedPosition = Vector3.new(character.PrimaryPart.Position.X, lookCFrame.Position.Y, character.PrimaryPart.Position.Z)
			local upCFrame = CFrame.new(character.PrimaryPart.Position, alignedPosition)

			local verticalVelocity = (humanoid.MoveDirection * Vector3.new(1, 0, 1)) * FlySpeed
			local horizontalVeclocity = (humanoid.MoveDirection * Vector3.new(0, 1, 0)) * FlySpeed / 2 + (upCFrame.LookVector * FlySpeed / 2)

			if (character.PrimaryPart.Position - alignedPosition).Magnitude < FlySpeed / 5 then
				bodyVel.Velocity = verticalVelocity
			else
				bodyVel.Velocity = verticalVelocity + horizontalVeclocity
			end
		else
			bodyVel.Velocity = humanoid.MoveDirection
		end

		bodyGyro.CFrame = cf
	end
end

local function processFlight()
    if not character then
        character = LocalPlayer.Character
        hrp = character.HumanoidRootPart
        humanoid = character.Humanoid
        animate = character.Animate

        idleAnim = humanoid:LoadAnimation(Assets.Animations.FlightIdleAnim)
        moveAnim = humanoid:LoadAnimation(Assets.Animations.FlightMoveAnim)
    end

    if (not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead) then
        return
    end
    if not PlayerValues:GetValue(LocalPlayer, "Flight") then
        return
    end
    for i, v in pairs(humanoid:GetPlayingAnimationTracks()) do
        v:Stop()
    end

	if isFlying then
		TogglesFrame.Flight.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
		TogglesFrame.Flight.Keybind.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
		setFlying(false)
	else
		TogglesFrame.Flight.BackgroundColor3 = Color3.fromRGB(4, 255, 0)
		TogglesFrame.Flight.Keybind.BackgroundColor3 = Color3.fromRGB(4, 255, 0)
		setFlying(true)
	end
end

PlayerValues:SetCallback("Flight", function(player, value)
    if TogglesFrame then
        if value then
            TogglesFrame.Flight.Visible = true
        else
            TogglesFrame.Flight.Visible = false
            setFlying(false)
        end
    end
end)

TogglesFrame.Flight.Activated:Connect(function()
    processFlight()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.Q and gameProcessedEvent == false then
		processFlight()
	end
end

UserInputService.InputBegan:Connect(onKeyPress)
RunService.RenderStepped:Connect(onUpdate)




