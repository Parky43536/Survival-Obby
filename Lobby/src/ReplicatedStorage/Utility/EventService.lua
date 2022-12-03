local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local IsServer = RunService:IsServer()

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local Signal
if IsServer then
    Signal = Instance.new("RemoteEvent")
    Signal.Name = "Signal"
    Signal.Parent = script
else
    Signal = script:WaitForChild("Signal")
end

local EventService = {}

--Variables---------------------------------------------

EventService.TouchCooldown = 1

--Functions---------------------------------------------

local obstacleSpawners = {}

function EventService.totalUpgrades(levelNum, upgrades)
    local totalUpgrades = 0

    for _, level in pairs(upgrades) do
        if levelNum >= level then
            totalUpgrades += 1
        end
    end

    return totalUpgrades
end

function EventService.toggleObstacleSpawner(levelNum, obstacleSpawner, toggle)
    if not obstacleSpawners[levelNum] then obstacleSpawners[levelNum] = {} end
    obstacleSpawners[levelNum][obstacleSpawner] = toggle
end

function EventService.checkObstacleSpawner(levelNum, obstacleSpawner)
    if obstacleSpawners[levelNum] and obstacleSpawners[levelNum][obstacleSpawner] then
        return false
    end

    return true
end

function EventService.randomObstacleSpawner(levelNum, level)
    local rng = Random.new()
    local obstacleSpawnerList = {}

    for _, part in pairs(level:GetDescendants()) do
        if CollectionService:HasTag(part, "ObstacleSpawner") then
            table.insert(obstacleSpawnerList, part)
        end
    end

    local pickedSpawner
    repeat
        local num = rng:NextInteger(1, #obstacleSpawnerList)
        if EventService.checkObstacleSpawner(levelNum, obstacleSpawnerList[num]) then
            pickedSpawner = obstacleSpawnerList[num]
        else
            table.remove(obstacleSpawnerList, num)
        end
    until pickedSpawner or #obstacleSpawnerList == 0

    if pickedSpawner then
        EventService.toggleObstacleSpawner(levelNum, pickedSpawner, true)
    end

    return pickedSpawner
end

function EventService.getBoundingBox(model, orientation)
	if typeof(model) == "Instance" then
		model = model:GetDescendants()
	end
	if not orientation then
		orientation = CFrame.new()
	end
	local abs = math.abs
	local inf = math.huge

	local minx, miny, minz = inf, inf, inf
	local maxx, maxy, maxz = -inf, -inf, -inf

	for _, obj in pairs(model) do
		if obj:IsA("BasePart") then
			local cf = obj.CFrame
			cf = orientation:ToObjectSpace(cf)
			local size = obj.Size
			local sx, sy, sz = size.X, size.Y, size.Z

			local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components()

			local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz)
			local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz)
			local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz)

			if minx > x - wsx then
				minx = x - wsx
			end
			if miny > y - wsy then
				miny = y - wsy
			end
			if minz > z - wsz then
				minz = z - wsz
			end

			if maxx < x + wsx then
				maxx = x + wsx
			end
			if maxy < y + wsy then
				maxy = y + wsy
			end
			if maxz < z + wsz then
				maxz = z + wsz
			end
		end
	end

	local omin, omax = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	local omiddle = (omax+omin)/2
	local wCf = orientation - orientation.p + orientation:pointToWorldSpace(omiddle)
	local size = (omax-omin)

	return wCf, size
end

function EventService.getFloorGroup(part)
    if part.Parent and part.Parent.Name == "FloorGroup" then
        return part.Parent:GetChildren()
    else
        return part
    end
end

function EventService.parentToObstacles(levelNum, part)
    if not workspace.Obstacles:FindFirstChild(levelNum) then
        local folder = Instance.new("Folder")
        folder.Name = levelNum
        folder.Parent = workspace.Obstacles
    end

    part.Parent = workspace.Obstacles:FindFirstChild(levelNum)
end

function EventService.randomPoint(level, args)
    if not args then args = {} end
    if not args.offset then args.offset = 2 end

    local rng = Random.new()
    local cframe, size = EventService.getBoundingBox(args.model or level.Floor)

    local x = cframe.Position.X + rng:NextInteger(math.clamp((-size.X/2) + args.offset, -99e99, 0), math.clamp((size.X/2) - args.offset, 0, 99e99))
    local z = cframe.Position.Z + rng:NextInteger(math.clamp((-size.Z/2) + args.offset, -99e99, 0), math.clamp((size.Z/2) - args.offset, 0, 99e99))
    local pos = Vector3.new(x, cframe.Position.Y + 100, z)

    if args.show then
        EventService.positionVisual(Vector3.new(x, cframe.Position.Y, z), {
            transparency = 0.5,
            size = size + Vector3.new(-args.offset, 1, -args.offset),
            duration = 1,
        })
    end

    local RayOrigin = pos
    local RayDirection = Vector3.new(0, -1000, 0)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Whitelist

    if args.filter then
        Params.FilterDescendantsInstances = args.filter
    elseif args.model then
        if typeof(args.model) == "Instance" then
            Params.FilterDescendantsInstances = {args.model:GetChildren()}
        else
            Params.FilterDescendantsInstances = args.model
        end
    else
        Params.FilterDescendantsInstances = {level.Floor:GetChildren()}
    end

    local Result = workspace:Raycast(RayOrigin, RayDirection, Params)
    return Result
end

function EventService.getPlayersInRadius(position, radius, players)
    local currentPlayers = Players:GetChildren()
    local playersInRadius = {}

    for _, player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
            if (player.Character.PrimaryPart.Position - position).Magnitude <= radius then
                table.insert(playersInRadius, player)
            end
        end
    end

    return playersInRadius
end

function EventService.getPlayersInSize(cframe, size, players)
    local currentPlayers = Players:GetChildren()
    local playersInSize = {}

    for _,player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
            local relativePoint = cframe:Inverse() * player.Character.PrimaryPart.Position
            local isInsideHitbox = true
            for _,axis in ipairs{"X","Y","Z"} do
                if math.abs(relativePoint[axis]) > size[axis]/2 then
                    isInsideHitbox = false
                    break
                end
            end

            if isInsideHitbox then
                table.insert(playersInSize, player)
            end
        end
    end

    return playersInSize
end

function EventService.getClosestPlayer(position, players)
    local currentPlayers = Players:GetChildren()
    local closestPlayer

    for _, player in pairs(players or currentPlayers) do
        if General.playerCheck(player) then
            if not closestPlayer then
                closestPlayer = player
            elseif not General.playerCheck(closestPlayer) then
                closestPlayer = player
            elseif (player.Character.PrimaryPart.Position - position).Magnitude < (closestPlayer.Character.PrimaryPart.Position - position).Magnitude then
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

function EventService.positionVisual(position, args)
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

--Cleaning---------------------------------------------

function EventService.CleanLevel(levelNum, level)
    local obstacles = workspace.Obstacles:FindFirstChild(levelNum)
    if obstacles then
        for _, part in pairs(obstacles:GetDescendants()) do
            part:Destroy()
        end
    end

    if IsServer then
        Signal:FireAllClients(levelNum)
    end
end

if not IsServer then
    Signal.OnClientEvent:Connect(function(...)
        EventService.CleanLevel(...)
    end)
end

return EventService