local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local RightFrame = PlayerUi:WaitForChild("RightFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local SettingsUi = PlayerGui:WaitForChild("SettingsUi")
local Settings = SettingsUi.SettingsFrame.ScrollingFrame

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SettingsConnection = Remotes:WaitForChild("SettingsConnection")
local DataConnection = Remotes:WaitForChild("DataConnection")

local function settingsUiEnable()
    if SettingsUi.Enabled == true then
        SettingsUi.Enabled = false
    else
        UpgradeUi.Enabled = false
        ShopUi.Enabled = false
        LevelsUi.Enabled = false
        SettingsUi.Enabled = true
    end
end

RightFrame.Settings.Activated:Connect(function()
    settingsUiEnable()
end)

SettingsUi.SettingsFrame.TopFrame.Close.Activated:Connect(function()
    settingsUiEnable()
end)

------------------------------------------------------------------

local settings = {"MusicOff", "SoundOff", "UpgradesOff","AutoUpgrade"}

local function loadToggles()
    for _, setting in (settings) do
        local settingEnabled = PlayerValues:GetValue(LocalPlayer, setting)
        local toggle = Settings:FindFirstChild(setting).Toggle
        if settingEnabled then
            toggle.Image = "rbxassetid://4360945444"
        else
            toggle.Image = "rbxassetid://6790887263"
        end
    end
end

local cooldown = 0.2
local cooldownTime = tick()

for _, setting in (settings) do
    Settings:FindFirstChild(setting).Toggle.Activated:Connect(function()
        if tick() - cooldownTime > cooldown then
            cooldownTime = tick()
            DataConnection:FireServer("SettingToggle", {setting = setting})
        end
    end)

    PlayerValues:SetCallback(setting, function(value)
        if setting == "MusicOff" then
            local music = workspace.Sound:FindFirstChild("Music")
            if music then
                if PlayerValues:GetValue(LocalPlayer, "MusicOff") then
                    music.Volume = 0
                else
                    music.Volume = 0.2
                end
            end
        end

        loadToggles()
    end)
end

SettingsConnection.OnClientEvent:Connect(function()
    loadToggles()
end)

