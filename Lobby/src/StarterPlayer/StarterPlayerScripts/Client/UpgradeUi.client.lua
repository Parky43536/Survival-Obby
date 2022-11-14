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
local LeftFrame = PlayerUi:WaitForChild("LeftFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local Upgrade = UpgradeUi.UpgradeFrame.ScrollingFrame

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpgradeConnection = Remotes:WaitForChild("UpgradeConnection")
local DataConnection = Remotes:WaitForChild("DataConnection")

local function upgradeUiEnable()
    if UpgradeUi.Enabled == true then
        UpgradeUi.Enabled = false
    else
        UpgradeUi.Enabled = true
        ShopUi.Enabled = false
        LevelsUi.Enabled = false
    end
end

LeftFrame.Upgrade.Activated:Connect(function()
    upgradeUiEnable()
end)

UpgradeUi.UpgradeFrame.TopFrame.Close.Activated:Connect(function()
    upgradeUiEnable()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.E and gameProcessedEvent == false then
		upgradeUiEnable()
	end
end

------------------------------------------------------------------

local cooldown = 0.2
local cooldownTime = tick()

Upgrade.Health.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("Health")
    end
end)

Upgrade.Speed.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("Speed")
    end
end)

Upgrade.Jump.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("Jump")
    end
end)

Upgrade.CMulti.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("CMulti")
    end
end)

------------------------------------------------------------------

local function comma_value(amount)
    local formatted = amount
    while true do
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

local function loadCosts()
    Upgrade.Health.Cost.Amount.Text = "C " .. comma_value(General.getCost("Health", PlayerValues:GetValue(LocalPlayer, "Health")))
    Upgrade.Speed.Cost.Amount.Text = "C " .. comma_value(General.getCost("Speed", PlayerValues:GetValue(LocalPlayer, "Speed")))
    Upgrade.Jump.Cost.Amount.Text = "C " .. comma_value(General.getCost("Jump", PlayerValues:GetValue(LocalPlayer, "Jump")))
    Upgrade.CMulti.Cost.Amount.Text = "C " .. comma_value(General.getCost("CMulti", PlayerValues:GetValue(LocalPlayer, "CMulti")))
end

PlayerValues:SetCallback("Health", function()
    loadCosts()
end)

PlayerValues:SetCallback("Speed", function()
    loadCosts()
end)

PlayerValues:SetCallback("Jump", function()
    loadCosts()
end)

PlayerValues:SetCallback("CMulti", function()
    loadCosts()
end)

UpgradeConnection.OnClientEvent:Connect(function()
    loadCosts()
end)

UserInputService.InputBegan:Connect(onKeyPress)
