local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Assets = ReplicatedStorage.Assets

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local DataBase = ReplicatedStorage.Database
local SettingsData = require(DataBase:WaitForChild("SettingsData"))

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local RightFrame = PlayerUi:WaitForChild("RightFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local ShopPopUi = PlayerGui:WaitForChild("ShopPopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local SettingsUi = PlayerGui:WaitForChild("SettingsUi")
local Settings = SettingsUi.SettingsFrame.Settings

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SettingsConnection = Remotes:WaitForChild("SettingsConnection")
local DataConnection = Remotes:WaitForChild("DataConnection")

local function settingsUiEnable()
    if SettingsUi.Enabled == true then
        SettingsUi.Enabled = false
    else
        UpgradeUi.Enabled = false
        ShopUi.Enabled = false
        ShopPopUi.Enabled = false
        LevelsUi.Enabled = false
        SettingsUi.Enabled = true
    end
end

RightFrame.Frame.Settings.Activated:Connect(function()
    settingsUiEnable()
end)

SettingsUi.SettingsFrame.Title.Close.Activated:Connect(function()
    settingsUiEnable()
end)

------------------------------------------------------------------

local function loadSettings()
    for name, data in (SettingsData) do
        local ui = Settings:FindFirstChild(name)
        if ui then
            if data.slider then
                ui.Slider.Value.Text = " " .. ((PlayerValues:GetValue(LocalPlayer, name) or data.value) or " ") .. " "
            else
                if PlayerValues:GetValue(LocalPlayer, name) then
                    ui.Toggle.Image = "rbxassetid://4360945444"
                else
                    ui.Toggle.Image = "rbxassetid://6790887263"
                end
            end
        end
    end
end

local toggleCooldown = 0.2
local sliderCooldown = 0.05
local cooldownTime = tick()

for name, data in (SettingsData) do
    local settingHolder
    if data.slider then
        settingHolder = Assets.Ui.SliderSetting:Clone()
    else
        settingHolder = Assets.Ui.ToggleSetting:Clone()
    end

    settingHolder.Name = name
    settingHolder.Desc.Text = data.desc
    settingHolder.LayoutOrder = data.order
    settingHolder.Parent = Settings

    if data.slider then
        settingHolder.Slider.Plus.Activated:Connect(function()
            if tick() - cooldownTime > sliderCooldown then
                cooldownTime = tick()
                DataConnection:FireServer("SettingSlider", {setting = name, value = data.sliderValue, min = data.min, max = data.max})
            end
        end)

        settingHolder.Slider.Minus.Activated:Connect(function()
            if tick() - cooldownTime > sliderCooldown then
                cooldownTime = tick()
                DataConnection:FireServer("SettingSlider", {setting = name, value = -data.sliderValue, min = data.min, max = data.max})
            end
        end)
    else
        settingHolder.Toggle.Activated:Connect(function()
            if tick() - cooldownTime > toggleCooldown then
                cooldownTime = tick()
                DataConnection:FireServer("SettingToggle", {settingName = name})
            end
        end)
    end

    PlayerValues:SetCallback(name, function()
        if name == "Music" then
            local music = workspace.Sound:FindFirstChild("Music")
            if music then
                music.Volume = General.MusicScale * (PlayerValues:GetValue(LocalPlayer, "Music") or SettingsData.Music.default)
            end
        end

        loadSettings()
    end)
end

SettingsConnection.OnClientEvent:Connect(function()
    loadSettings()
end)

