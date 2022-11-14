local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
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
local movement = {forward = 0, backward = 0, right = 0, left = 0}
local character
local hrp
local humanoid
local animate
local idleAnim
local moveAnim
local lastAnim

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

local function onUpdate(dt)
	if (isFlying) then
		local cf = Camera.CFrame
		local direction = cf.RightVector*(movement.right - movement.left) + cf.LookVector*(movement.forward - movement.backward)
		if (direction:Dot(direction) > 0) then
			direction = direction.unit
		end
		bodyGyro.CFrame = cf
		bodyVel.Velocity = direction * humanoid.WalkSpeed * 3
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

TogglesFrame.Flight.Activated:Connect(function()
    processFlight()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.Q and gameProcessedEvent == false then
		processFlight()
	end
end

local function movementBind(actionName, inputState, inputObject)
	if (inputState == Enum.UserInputState.Begin) then
		movement[actionName] = 1
	elseif (inputState == Enum.UserInputState.End) then
		movement[actionName] = 0
	end
	if (isFlying) then
		local isMoving = movement.right + movement.left + movement.forward + movement.backward > 0
		local nextAnim = isMoving and moveAnim or idleAnim
		if (nextAnim ~= lastAnim) then
			lastAnim:Stop()
			lastAnim = nextAnim
			lastAnim:Play()
		end
	end
	return Enum.ContextActionResult.Pass
end

UserInputService.InputBegan:Connect(onKeyPress)
ContextActionService:BindAction("forward", movementBind, true, Enum.PlayerActions.CharacterForward)
ContextActionService:BindAction("backward", movementBind, true, Enum.PlayerActions.CharacterBackward)
ContextActionService:BindAction("left", movementBind, true, Enum.PlayerActions.CharacterLeft)
ContextActionService:BindAction("right", movementBind, true, Enum.PlayerActions.CharacterRight)
RunService.RenderStepped:Connect(onUpdate)




