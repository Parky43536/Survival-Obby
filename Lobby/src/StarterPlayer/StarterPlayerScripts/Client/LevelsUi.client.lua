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
local ShopPopUi = PlayerGui:WaitForChild("ShopPopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local SettingsUi = PlayerGui:WaitForChild("SettingsUi")
local Levels = LevelsUi.LevelsFrame.Levels

local function levelsUiEnable()
    if LevelsUi.Enabled == true then
        LevelsUi.Enabled = false
    else
        LevelsUi.Enabled = true
        ShopUi.Enabled = false
        ShopPopUi.Enabled = false
        UpgradeUi.Enabled = false
        SettingsUi.Enabled = false
    end
end

LeftFrame.Levels.Activated:Connect(function()
    levelsUiEnable()
end)

LevelsUi.LevelsFrame.Title.Close.Activated:Connect(function()
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

    

    for levelNum = 0 , General.Levels + 1 do
        local level

        if not Levels:FindFirstChild(levelNum) then
            if levelNum == 0 then
                level = Assets.Ui.LevelInvert:Clone()
                level.Level.Text = " Start "
            elseif levelNum == General.Levels + 1 then
                level = Assets.Ui.LevelInvert:Clone()
                level.Level.Text = " Finish "
            else
                level = Assets.Ui.Level:Clone()
                level.Level.Text = " " .. levelNum .. " "
            end

            level.Name = levelNum
            level.Parent = Levels

            level.Level.Activated:Connect(function()
                DataConnection:FireServer("TeleportToLevel", {level = levelNum})
            end)
        else
            level = Levels:FindFirstChild(levelNum)
        end

        if currentLevel >= levelNum then
            if levelNum == 0 or levelNum == General.Levels + 1 then
                level.Level.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            else
                level.Level.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            end
        else
            level.Level.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
        end
    end
end

PlayerValues:SetCallback("Level", function()
    levelsUi()
end)

UserInputService.InputBegan:Connect(onKeyPress)

levelsUi()


