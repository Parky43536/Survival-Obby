local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SocialService = game:GetService("SocialService")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)
local TweenService = require(Utility.TweenService)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local LeftFrame = PlayerUi:WaitForChild("LeftFrame")
local RightFrame = PlayerUi:WaitForChild("RightFrame")
local Warning = PlayerUi:WaitForChild("Warning")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientConnection = Remotes:WaitForChild("ClientConnection")
local DataConnection = Remotes:WaitForChild("DataConnection")

local alertTime = 1

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

------------------------------------------------------------------

local running = false
local function autoUpgrade()
    if PlayerValues:GetValue(LocalPlayer, "AutoUpgrade") and running == false then
        running = true

        local upgrades = {"Health", "Speed", "Jump", "Income"}

        local lowestCost = false
        for _, upgrade in upgrades do
            local cost = General.getCost(upgrade, PlayerValues:GetValue(LocalPlayer, upgrade))
            if cost then
                if not lowestCost then
                    lowestCost = cost
                elseif cost < lowestCost then
                    lowestCost = General.getCost(upgrade, PlayerValues:GetValue(LocalPlayer, upgrade))
                end
            end
        end

        if lowestCost then
            while lowestCost and PlayerValues:GetValue(LocalPlayer, "Cash") >= lowestCost do
                for _, upgrade in upgrades do
                    DataConnection:FireServer(upgrade)

                    task.wait(0.25)
                end

                lowestCost = false
                for _, upgrade in upgrades do
                    local cost = General.getCost(upgrade, PlayerValues:GetValue(LocalPlayer, upgrade))
                    if cost then
                        if not lowestCost then
                            lowestCost = General.getCost(upgrade, PlayerValues:GetValue(LocalPlayer, upgrade))
                        elseif General.getCost(upgrade, PlayerValues:GetValue(LocalPlayer, upgrade)) < lowestCost then
                            lowestCost = General.getCost(upgrade, PlayerValues:GetValue(LocalPlayer, upgrade))
                        end
                    end
                end
            end
        end

        running = false
    end
end

local currentCash
local lastCashUpate
local currentTween
local function loadCash(value)
    LeftFrame.Cash.CashAmount.Text = comma_value(value)

    if currentCash then
        local cashGain = value - currentCash
        if cashGain ~= 0 then
            if cashGain > 0 then
                LeftFrame.Cash.CashIncrease.Text = "+" .. comma_value(cashGain)
            else
                LeftFrame.Cash.CashIncrease.Text = comma_value(cashGain)
            end

            if currentTween then currentTween:Cancel() end
            LeftFrame.Cash.CashIncrease.Size = UDim2.new(0.6, 0, 0.6, 0)
            LeftFrame.Cash.CashIncrease.TextColor3 = Color3.fromRGB(254, 219, 65)
            local goal = {Size = LeftFrame.Cash.CashIncrease.Size + UDim2.new(0.2, 0, 0.2, 0), TextColor3 = Color3.fromRGB(255, 175, 110)}
            local properties = {Time = 1, Dir = "In", Style = "Bounce", Reverse = true}
            currentTween = TweenService.tween(LeftFrame.Cash.CashIncrease, goal, properties)
            LeftFrame.Cash.CashIncrease.Visible = true

            local ticker = tick()
            lastCashUpate = ticker
            task.delay(2, function()
                if lastCashUpate == ticker then
                    LeftFrame.Cash.CashIncrease.Visible = false
                    currentCash = value
                end
            end)
        end
    else
        currentCash = value
    end

    autoUpgrade()
end

PlayerValues:SetCallback("Cash", function(player, value)
    loadCash(value)
end)

PlayerValues:SetCallback("AutoUpgrade", function()
    autoUpgrade()
end)

ClientConnection.OnClientEvent:Connect(function()
    loadCash(PlayerValues:GetValue(LocalPlayer, "Cash"))
end)

------------------------------------------------------------------

local mobile = false
local function mobileUi()
    local changed = false
    if not mobile and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
        mobile = true
        changed = true
    end

    if changed then
        if mobile then
            LeftFrame.Position = UDim2.new(0.01, 0, 0.62, 0)
            RightFrame.Position = UDim2.new(0.99, 0, 0.62, 0)

            for _, ui in (PlayerUi:GetDescendants()) do
                if ui.Name == "Keybind" then
                    ui.Visible = false
                end
            end
        else
            LeftFrame.Position = UDim2.new(0.01, 0, 0.88, 0)
            RightFrame.Position = UDim2.new(0.99, 0, 0.88, 0)

            for _, ui in (PlayerUi:GetDescendants()) do
                if ui.Name == "Keybind" then
                    ui.Visible = true
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function()
    mobileUi()
end)

mobileUi()

------------------------------------------------------------------

Warning.Activated:Connect(function()
    Warning.Visible = false
    DataConnection:FireServer("TeleportToLevel", {level = PlayerValues:GetValue(LocalPlayer, "Level") or 0})
end)

DataConnection.OnClientEvent:Connect(function()
    Warning.Visible = true
end)
