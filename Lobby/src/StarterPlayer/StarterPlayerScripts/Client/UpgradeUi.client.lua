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
local Upgrade = UpgradeUi.UpgradeFrame.Upgrades

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpgradeConnection = Remotes:WaitForChild("UpgradeConnection")
local DataConnection = Remotes:WaitForChild("DataConnection")

local stats = {"Health", "Speed", "Jump", "Income"}

local function upgradeUiEnable()
    if UpgradeUi.Enabled == true then
        UpgradeUi.Enabled = false
    else
        UpgradeUi.Enabled = true
        ShopUi.Enabled = false
        ShopPopUi.Enabled = false
        LevelsUi.Enabled = false
        SettingsUi.Enabled = false
    end
end

LeftFrame.Upgrade.Activated:Connect(function()
    upgradeUiEnable()
end)

UpgradeUi.UpgradeFrame.Title.Close.Activated:Connect(function()
    upgradeUiEnable()
end)

local function onKeyPress(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.E and gameProcessedEvent == false then
		upgradeUiEnable()
	end
end

------------------------------------------------------------------

local function check()
    local cash = PlayerValues:GetValue(LocalPlayer, "Cash")
    local openUpgrades = false

    --prevents upgrades from popping up for players saving cash
    if cash > 2500 then
        return
    end

    for i, stat in (stats) do
        local statCost = General.getCost(stat, PlayerValues:GetValue(LocalPlayer, stat))
        if statCost and cash >= statCost then
            openUpgrades = true
            break
        end
    end

    if openUpgrades then
        task.wait(1)

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

local function loadCosts()
    for i, stat in (stats) do
        local ui = Upgrade:FindFirstChild(stat)

        local statCost = General.getCost(stat, PlayerValues:GetValue(LocalPlayer, stat))
        if statCost then
            statCost = "Cost: " .. comma_value(statCost)

            ui.Buy.Active = true
            ui.Buy.BackgroundColor3 = Color3.fromRGB(50, 202, 33)
            ui.Buy.AutoButtonColor = true
            ui.Buy.Text = "Buy"
        else
            statCost = "Cost: n/a"

            ui.Buy.Active = false
            ui.Buy.BackgroundColor3 = Color3.fromRGB(145, 145, 145)
            ui.Buy.AutoButtonColor = false
            ui.Buy.Text = "MAX"
        end

        local rounding = 0
        if stat == "Speed" or stat == "Income" then
            rounding = 1
        end

        ui.Stats.Cost.Text = statCost
        ui.Stats.Total.Text = "Current: " .. round(General.getValue(stat, PlayerValues:GetValue(LocalPlayer, stat)), rounding)
    end
end

for i, stat in (stats) do
    PlayerValues:SetCallback(stat, function()
        loadCosts()
    end)
end

------------------------------------------------------------------

UpgradeConnection.OnClientEvent:Connect(function(func)
    if func == "init" then
        loadCosts()
    elseif func == "check" then
        check()
    end
end)

UserInputService.InputBegan:Connect(onKeyPress)
