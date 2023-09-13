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
local TopFrame = PlayerUi:WaitForChild("TopFrame")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClientConnection = Remotes:WaitForChild("ClientConnection")
local DataConnection = Remotes:WaitForChild("DataConnection")
local ChatConnection = Remotes:WaitForChild("ChatConnection")

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

local function round(number, decimal)
    return math.round(number * 10 ^ decimal) / (10 ^ decimal)
end

local function getAlerts()
    local cash = PlayerValues:GetValue(LocalPlayer, "Cash")
    local alerts = 0

    local health = General.getCost("Health", PlayerValues:GetValue(LocalPlayer, "Health"))
    local speed = General.getCost("Speed", PlayerValues:GetValue(LocalPlayer, "Speed"))
    local jump = General.getCost("Jump", PlayerValues:GetValue(LocalPlayer, "Jump"))
    local income = General.getCost("Income", PlayerValues:GetValue(LocalPlayer, "Income"))

    if health and cash >= health then
        alerts += 1
    end
    if speed and cash >= speed then
        alerts += 1
    end
    if jump and cash >= jump then
        alerts += 1
    end
    if income and cash >= income then
        alerts += 1
    end

    return alerts
end

------------------------------------------------------------------

local chatAlertCooldown
local currentAlertTweens = {}
local function upgradeAlert()
    local alerts = getAlerts()

    local currentLevel = PlayerValues:GetValue(LocalPlayer, "CurrentLevel")
    if alerts == 4 and chatAlertCooldown ~= currentLevel and currentLevel > 2 then
        chatAlertCooldown = currentLevel
        game.StarterGui:SetCore("ChatMakeSystemMessage", {Text = "[ALERT] You need to upgrade your character!", Color = Color3.fromRGB(255, 149, 19)})
    end

    if alerts >= 1 then
        if currentAlertTweens["Background"] then currentAlertTweens["Background"]:Cancel() end
        LeftFrame.Upgrade.BackgroundColor3 = Color3.fromRGB(255, 149, 19)
        local goal = {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}
        local properties = {Time = alertTime, Reverse = true, Repeat = math.huge}
        currentAlertTweens["Background"] = TweenService.tween(LeftFrame.Upgrade, goal, properties)
        ------
        if currentAlertTweens["Text"] then currentAlertTweens["Text"]:Cancel() end
        LeftFrame.Upgrade.ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
        local goal = {TextColor3 = Color3.fromRGB(0, 0, 0)}
        local properties = {Time = alertTime, Reverse = true, Repeat = math.huge}
        currentAlertTweens["Text"] = TweenService.tween(LeftFrame.Upgrade.ButtonText, goal, properties)
        ------
        if currentAlertTweens["Keybind"] then currentAlertTweens["Keybind"]:Cancel() end
        LeftFrame.Upgrade.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
        LeftFrame.Upgrade.Keybind.BackgroundColor3 = Color3.fromRGB(255, 149, 19)
        local goal = {TextColor3 = Color3.fromRGB(0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}
        local properties = {Time = alertTime, Reverse = true, Repeat = math.huge}
        currentAlertTweens["Keybind"] = TweenService.tween(LeftFrame.Upgrade.Keybind, goal, properties)
    else
        if currentAlertTweens["Background"] then currentAlertTweens["Background"]:Cancel() end
        LeftFrame.Upgrade.BackgroundColor3 = Color3.fromRGB(255, 149, 19)
        ------
        if currentAlertTweens["Text"] then currentAlertTweens["Text"]:Cancel() end
        LeftFrame.Upgrade.ButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
        ------
        if currentAlertTweens["Keybind"] then currentAlertTweens["Keybind"]:Cancel() end
        LeftFrame.Upgrade.Keybind.TextColor3 = Color3.fromRGB(255, 255, 255)
        LeftFrame.Upgrade.Keybind.BackgroundColor3 = Color3.fromRGB(255, 149, 19)
    end
end

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
    upgradeAlert()
end

PlayerValues:SetCallback("Cash", function(player, value)
    loadCash(value)
end)

PlayerValues:SetCallback("AutoUpgrade", function()
    autoUpgrade()
end)

------------------------------------------------------------------

task.spawn(function()
    while true do
        for _, ui in (TopFrame:GetChildren()) do
            ui.Visible = true
            task.wait(20)
            ui.Visible = false
            task.wait(10)
        end
    end
end)

local cooldown = 1
local cooldownTime = tick()

TopFrame.Friends.Invite.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()

        local canInvite = SocialService:CanSendGameInviteAsync(LocalPlayer)
        if canInvite then
            SocialService:PromptGameInvite(LocalPlayer)
        elseif not canInvite then
            TopFrame.Friends.Invite.Text = "Failed"
            task.wait(cooldown)
            TopFrame.Friends.Invite.Text = "Invite"
        end
    end
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

ChatConnection.OnClientEvent:Connect(function(text, color)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {Text = text, Color = color})
end)

ClientConnection.OnClientEvent:Connect(function()
    loadCash(PlayerValues:GetValue(LocalPlayer, "Cash"))
end)
