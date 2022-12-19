local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Assets = ReplicatedStorage.Assets

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DataConnection = Remotes:WaitForChild("DataConnection")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local LeftFrame = PlayerUi:WaitForChild("LeftFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local SettingsUi = PlayerGui:WaitForChild("SettingsUi")
local FriendsUi = PlayerGui:WaitForChild("FriendsUi")
local Levels = LevelsUi.LevelsFrame.ScrollingFrame

local function levelsUiEnable()
    if LevelsUi.Enabled == true then
        LevelsUi.Enabled = false
    else
        LevelsUi.Enabled = true
        ShopUi.Enabled = false
        UpgradeUi.Enabled = false
        SettingsUi.Enabled = false
        FriendsUi.Enabled = false
    end
end

LeftFrame.Levels.Activated:Connect(function()
    levelsUiEnable()
end)

LevelsUi.LevelsFrame.TopFrame.Close.Activated:Connect(function()
    levelsUiEnable()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.X and gameProcessedEvent == false then
		levelsUiEnable()
	end
end

------------------------------------------------------------------

local function levelsUi()
    local currentLevel = PlayerValues:GetValue(LocalPlayer, "Level") or 0

    for levelNum = 1 , General.Levels do
        local level

        if not Levels:FindFirstChild(levelNum) then
            level = Assets.Ui.Level:Clone()
            level.Name = levelNum
            level.Text = levelNum
            level.Parent = Levels

            level.Activated:Connect(function()
                DataConnection:FireServer("TeleportToLevel", {level = levelNum})
            end)
        else
            level = Levels:FindFirstChild(levelNum)
        end

        if currentLevel >= levelNum then
            level.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        else
            level.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
        end
    end

    if currentLevel >= General.Levels + 1 then
        LevelsUi.LevelsFrame.Tabs.Finish.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    else
        LevelsUi.LevelsFrame.Tabs.Finish.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    end
end

LevelsUi.LevelsFrame.Tabs.Start.Activated:Connect(function()
    DataConnection:FireServer("TeleportToLevel", {level = 0})
end)

LevelsUi.LevelsFrame.Tabs.Finish.Activated:Connect(function()
    DataConnection:FireServer("TeleportToLevel", {level = General.Levels + 1})
end)

PlayerValues:SetCallback("Level", function()
    levelsUi()
end)

UserInputService.InputBegan:Connect(onKeyPress)

levelsUi()


