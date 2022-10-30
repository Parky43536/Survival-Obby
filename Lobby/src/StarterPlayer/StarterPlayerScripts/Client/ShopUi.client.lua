local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local SideFrame = PlayerUi:WaitForChild("SideFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local Shop = ShopUi.ShopFrame.ScrollingFrame

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpgradeConnection = Remotes:WaitForChild("UpgradeConnection")
local DataConnection = Remotes:WaitForChild("DataConnection")

local function shopUiEnable()
    if ShopUi.Enabled == true then
        ShopUi.Enabled = false
    else
        ShopUi.Enabled = true
        LevelsUi.Enabled = false
        UpgradeUi.Enabled = false
    end
end

SideFrame.Shop.Activated:Connect(function()
    shopUiEnable()
end)

ShopUi.ShopFrame.TopFrame.Close.Activated:Connect(function()
    shopUiEnable()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.Z and gameProcessedEvent == false then
		shopUiEnable()
	end
end

------------------------------------------------------------------

UserInputService.InputBegan:Connect(onKeyPress)
