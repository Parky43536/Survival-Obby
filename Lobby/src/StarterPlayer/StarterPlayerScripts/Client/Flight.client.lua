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

local isFlying = false
local flySpeed = 50

local flyAnim
local bodyGyro
local bodyVel

local function setFlying(flying)
	local character = LocalPlayer.Character
	local humanoid = character.Humanoid
	local hrp = character.HumanoidRootPart
	local animate = character.Animate

	isFlying = flying

	animate.Disabled = isFlying

	if (isFlying) then
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.maxTorque = Vector3.new(1, 1, 1)*10^6
		bodyGyro.P = 10^6
		bodyGyro.CFrame = hrp.CFrame
		bodyGyro.Parent = hrp

		bodyVel = Instance.new("BodyVelocity")
		bodyVel.maxForce = Vector3.new(1, 1, 1)*10^6
		bodyVel.P = 10^4
		bodyVel.Velocity = Vector3.new()
		bodyVel.Parent = hrp

		flyAnim = humanoid:LoadAnimation(Assets.Animations.FlightIdleAnim)
		flyAnim:Play()

		for _, characterPart in pairs(LocalPlayer.Character:GetChildren()) do
			if characterPart:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(characterPart, "FlyingPlayer")
			end
		end
	else
		if flyAnim then
			flyAnim:Stop()
		end

		if bodyVel then
			bodyVel:Destroy()
		end

		if bodyGyro then
			bodyGyro:Destroy()
		end

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
		local character = LocalPlayer.Character
		local humanoid = character.Humanoid

		if humanoid.MoveDirection ~= Vector3.new(0,0,0) then
			local lookCFrame = cf + cf.LookVector * flySpeed
			local alignedPosition = Vector3.new(character.PrimaryPart.Position.X, lookCFrame.Position.Y, character.PrimaryPart.Position.Z)
			local upCFrame = CFrame.new(character.PrimaryPart.Position, alignedPosition)

			local verticalVelocity = (humanoid.MoveDirection * Vector3.new(1, 0, 1)) * flySpeed
			local horizontalVeclocity = (humanoid.MoveDirection * Vector3.new(0, 1, 0)) * flySpeed / 2 + (upCFrame.LookVector * flySpeed / 2)

			if (character.PrimaryPart.Position - alignedPosition).Magnitude < flySpeed / 5 then
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
	local character = LocalPlayer.Character
	local humanoid = character.Humanoid

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




