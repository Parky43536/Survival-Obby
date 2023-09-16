local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DataBase = ReplicatedStorage.Database
local SettingsData = require(DataBase:WaitForChild("SettingsData"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local IsServer = RunService:IsServer()

local LocalPlayer

local Signal
if IsServer then
    Signal = Instance.new("RemoteEvent")
    Signal.Name = "Signal"
    Signal.Parent = script
else
    Signal = script:WaitForChild("Signal")
	LocalPlayer = Players.LocalPlayer
end

local AudioService = {}
AudioService.SavedAudios = {}
AudioService.CurrentMusic = {}

local function shallowCopy(list)
	local newList = {}
	for i,v in (list) do
		newList[i] = v
	end

	return newList
end

local function createSoundContainer(cframe)
	local newContainer = Instance.new("Part")
	newContainer.Transparency = 1
	newContainer.CastShadow = false
	newContainer.Anchored = true
	newContainer.CanCollide = false
	newContainer.CanTouch = false
	newContainer.CanQuery = false
	newContainer.Locked = true
	newContainer.CFrame = cframe
	newContainer.Size = Vector3.new(1, 1, 1)
	newContainer.Parent = workspace.Sound

	return newContainer
end

function AudioService:Create(id, target, properties, args)
	if not args then args = {} end
	if not properties then properties = {} end

	if not args.saveId or not AudioService.SavedAudios[args.saveId] then
		if IsServer then
			if args.name and args.name == "Music" then
				AudioService.CurrentMusic = {id = id, start = tick(), target = target, properties = properties, args = args}
			end

			if args.player then
				Signal:FireClient(args.player, "Create", id, target, properties, args)
			else
				Signal:FireAllClients("Create", id, target, properties, args)
			end

			return
		end

		--start client

		if args.name and args.name == "Music" then
			if workspace.Sound:FindFirstChild("Music") then
				workspace.Sound:FindFirstChild("Music"):Destroy()
			end
		end

		id = tostring(id)
		local newSoundObject = Instance.new("Sound")
		newSoundObject.Name = args.name or id
		newSoundObject.SoundId = "rbxassetid://".. id

		if args.effects then
			for effect, properties in (args.effects) do
				local newEffect = Instance.new(effect)
				for property, value in (properties or {}) do
					newEffect[property] = value
				end

				newEffect.Parent = newSoundObject
			end
		end

		for property, value in (properties or {}) do
			if property ~= "Delay" and property ~= "Duration" then
				newSoundObject[property] = value
			elseif property == "LoopDuration" then
				newSoundObject["Looped"] = true
			end
		end

		if args.name and args.name == "Music" then
			newSoundObject["Volume"] = General.MusicScale * (PlayerValues:GetValue(LocalPlayer, "Music") or SettingsData.Music.default)
		else
			newSoundObject["Volume"] = General.SoundScale * (PlayerValues:GetValue(LocalPlayer, "Sounds") or SettingsData.Sounds.default)
		end

		local container
		local createdContainer = false

		if typeof(target) == "Instance" then
			container = target
		elseif typeof(target) == "Vector3" then
			container = createSoundContainer(CFrame.new(target))
			createdContainer = true
		elseif typeof(target) == "CFrame" then
			container = createSoundContainer(target)
			createdContainer = true
		end

		newSoundObject.Parent = container

		task.spawn(function()
			task.wait(properties.Delay or 0)
			newSoundObject:Play()

			if args.saveId then
				if createdContainer then
					AudioService.SavedAudios[args.saveId] = container
				else
					AudioService.SavedAudios[args.saveId] = newSoundObject
				end
			else
				if not newSoundObject.Looped then
					newSoundObject.Ended:Connect(function()
						if createdContainer then
							container:Destroy()
						else
							newSoundObject:Destroy()
						end
					end)
				elseif properties.Duration then
					task.wait(properties.Duration or 0)
					if createdContainer then
						container:Destroy()
					else
						newSoundObject:Destroy()
					end
				end
			end
		end)

		return newSoundObject, container
	end

	return false, false
end

function AudioService:Music(player)
	if AudioService.CurrentMusic.id then
		local properties = shallowCopy(AudioService.CurrentMusic.properties)
		properties["TimePosition"] = tick() - AudioService.CurrentMusic.start

		local args = shallowCopy(AudioService.CurrentMusic.args)
		args["player"] = player

		AudioService:Create(
			AudioService.CurrentMusic.id,
			AudioService.CurrentMusic.target,
			properties,
			args
		)
	end
end

function AudioService:Destroy(saveId)
	if IsServer then
		Signal:FireAllClients("Destroy", saveId)
		return
	end

	--start client

	if AudioService.SavedAudios[saveId] then
		AudioService.SavedAudios[saveId]:Destroy()
		AudioService.SavedAudios[saveId] = nil
	end
end

if not IsServer then
	Signal.OnClientEvent:Connect(function(func, ...)
		if AudioService[func] then
			AudioService[func](nil, ...)
		end
	end)
end

return AudioService