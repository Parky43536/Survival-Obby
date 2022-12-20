local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage:WaitForChild("Utility")
local AudioService = require(Utility.AudioService)
local General = require(Utility.General)

local intermissionTime = 4

local Music = {
    9038835388, --Anthem For New Life A
    1842976958, --Arcade Weekend
    1838659388, --Magnetic Eyes
    1837306827, --Parkour
    1847853099, --Robotic Dance C
}

local function shallowCopy(list)
	local newList = {}
	for i,v in (list) do
		newList[i] = v
	end

	return newList
end

local musicList = shallowCopy(Music)

while true do
    if next(musicList) == nil then
        musicList = shallowCopy(Music)
    end

    local key = math.random(1, #musicList)
    local picked = musicList[key]
    table.remove(musicList, key)

    AudioService:Create(picked, workspace.Sound, {Volume = General.MusicVolume}, {name = "Music"})

    local sound = Instance.new("Sound")
    sound.Name = "FakeMusic"
    sound.SoundId = "rbxassetid://".. picked
    sound.Parent = workspace.Sound
    sound.Volume = 0
    sound:Play()

    sound.Ended:Wait()
    sound:Destroy()
end