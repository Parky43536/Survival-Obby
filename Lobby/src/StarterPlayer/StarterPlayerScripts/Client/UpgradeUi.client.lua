local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local AudioService = require(Utility.AudioService)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local LeftFrame = PlayerUi:WaitForChild("LeftFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local ShopPopUi = PlayerGui:WaitForChild("ShopPopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local SettingsUi = PlayerGui:WaitForChild("SettingsUi")
local FriendsUi = PlayerGui:WaitForChild("FriendsUi")
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
        ShopPopUi.Enabled = false
        LevelsUi.Enabled = false
        SettingsUi.Enabled = false
        FriendsUi.Enabled = false
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

Upgrade.Income.Buy.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()
        DataConnection:FireServer("Income")
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

local function round(number, decimal)
    return math.round(number * 10 ^ decimal) / (10 ^ decimal)
end

local stats = {"Health", "Speed", "Jump", "Income"}

local function loadCosts()
    for i, stat in (stats) do
        local statCost = General.getCost(stat, PlayerValues:GetValue(LocalPlayer, stat))
        if statCost then
            statCost = "C " .. comma_value(statCost)
        else
            statCost = "MAX"
        end

        local rounding = 0
        if stat == "Speed" or stat == "Income" then
            rounding = 1
        end

        local ui = Upgrade:FindFirstChild(stat)
        ui.Cost.Amount.Text = statCost
        ui.Total.Amount.Text = round(General.getValue(stat, PlayerValues:GetValue(LocalPlayer, stat)), rounding)
    end
end

for i, stat in (stats) do
    PlayerValues:SetCallback(stat, function()
        loadCosts()
    end)
end

UpgradeConnection.OnClientEvent:Connect(function()
    loadCosts()
end)

UserInputService.InputBegan:Connect(onKeyPress)
