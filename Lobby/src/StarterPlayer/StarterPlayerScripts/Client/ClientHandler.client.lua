local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientConnection = Remotes:WaitForChild("ClientConnection")

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

------------------------------------------------------------------

local currentSpin
local currentAlertTween
local function shopAlert(cash)
    local alert = LeftFrame.Alerts.ShopAlert

    local alertSpin = 8
    if cash >= General.getCost("Health", PlayerValues:GetValue(LocalPlayer, "Health")) then
        alertSpin /= 2
    end
    if cash >= General.getCost("Speed", PlayerValues:GetValue(LocalPlayer, "Speed")) then
        alertSpin /= 2
    end
    if cash >= General.getCost("Jump", PlayerValues:GetValue(LocalPlayer, "Jump")) then
        alertSpin /= 2
    end
    if cash >= General.getCost("CMulti", PlayerValues:GetValue(LocalPlayer, "CMulti")) then
        alertSpin /= 2
    end

    if alertSpin < 8 then
        if alertSpin ~= currentSpin then
            currentSpin = true
            alert.Visible = true

            if currentAlertTween then currentAlertTween:Cancel() end
            local goal = {Rotation = alert.Rotation + 360}
            local properties = {Time = alertSpin, Repeat = math.huge}
            currentAlertTween = TweenService.tween(alert, goal, properties)
        end
    else
        alert.Visible = false
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
            LeftFrame.Cash.CashIncrease.TextColor3 = Color3.fromRGB(255, 255, 0)
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

    shopAlert(value)
end

local function loadStats()
    local health = General.getValue("Health", PlayerValues:GetValue(LocalPlayer, "Health"))
    local speed = General.getValue("Speed", PlayerValues:GetValue(LocalPlayer, "Speed"))
    local jump = General.getValue("Jump", PlayerValues:GetValue(LocalPlayer, "Jump"))
    local cMulti = General.getValue("CMulti", PlayerValues:GetValue(LocalPlayer, "CMulti"))

    LeftFrame.Stats.Health.Text = "Health: " .. (PlayerValues:GetValue(LocalPlayer, "Health") or General.HealthDefault) .. " (" .. round(health, 0) .. ")"
    LeftFrame.Stats.Speed.Text = "Speed: " .. (PlayerValues:GetValue(LocalPlayer, "Speed") or General.SpeedDefault) .. " (" .. round(speed, 1) .. ")"
    LeftFrame.Stats.Jump.Text = "Jump: " .. (PlayerValues:GetValue(LocalPlayer, "Jump") or General.JumpDefault) .. " (" .. round(jump, 0) .. ")"
    LeftFrame.Stats.CMulti.Text = "C. Multi: " .. (PlayerValues:GetValue(LocalPlayer, "CMulti") or General.CMultiDefault) .. " (" .. round(cMulti, 1) .. ")"
end

PlayerValues:SetCallback("Cash", function(player, value)
    loadCash(value)
end)

PlayerValues:SetCallback("Health", function()
    loadStats()
end)

PlayerValues:SetCallback("Speed", function()
    loadStats()
end)

PlayerValues:SetCallback("Jump", function()
    loadStats()
end)

PlayerValues:SetCallback("CMulti", function()
    loadStats()
end)

------------------------------------------------------------------

local function mobileUi()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
        LeftFrame.Position = UDim2.new(0.01, 0, 0.62, 0)
        RightFrame.Position = UDim2.new(0.99, 0, 0.62, 0)
    elseif not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        LeftFrame.Position = UDim2.new(0.01, 0, 0.88, 0)
        RightFrame.Position = UDim2.new(0.99, 0, 0.88, 0)
    end
end

UserInputService.InputBegan:Connect(function()
    mobileUi()
end)

mobileUi()

------------------------------------------------------------------

ClientConnection.OnClientEvent:Connect(function()
    loadCash(PlayerValues:GetValue(LocalPlayer, "Cash"))
    loadStats()
end)
