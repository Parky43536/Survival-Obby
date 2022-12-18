local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Assets = ReplicatedStorage.Assets

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local DataBase = ReplicatedStorage.Database
local ShopData = require(DataBase:WaitForChild("ShopData"))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local LeftFrame = PlayerUi:WaitForChild("LeftFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local SettingsUi = PlayerGui:WaitForChild("SettingsUi")
local FriendsUi = PlayerGui:WaitForChild("FriendsUi")

local ProductsShop = ShopUi.ShopFrame.ProductsScrollingFrame
local ToolsShop = ShopUi.ShopFrame.ToolsScrollingFrame

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopConnection = Remotes:WaitForChild("ShopConnection")

local function shopUiEnable()
    if ShopUi.Enabled == true then
        ShopUi.Enabled = false
    else
        ShopUi.Enabled = true
        LevelsUi.Enabled = false
        UpgradeUi.Enabled = false
        SettingsUi.Enabled = false
        FriendsUi.Enabled = false
    end
end

LeftFrame.Shop.Activated:Connect(function()
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

ShopUi.ShopFrame.Tabs.Products.Activated:Connect(function()
    ProductsShop.Visible = true
    ToolsShop.Visible = false
end)

ShopUi.ShopFrame.Tabs.Tools.Activated:Connect(function()
    ProductsShop.Visible = false
    ToolsShop.Visible = true
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

local cooldown = 0.2
local cooldownTime = tick()

for name, data in (ShopData) do
    local itemHolder
    if data.gamepass or data.product then
        itemHolder = Assets.Ui.Product:Clone()
    else
        itemHolder = Assets.Ui.Tool:Clone()
    end

    itemHolder.Name = name
    itemHolder.Buy.Image = "rbxassetid://" .. data.image
    itemHolder.Info.Cost.Text = itemHolder.Info.Cost.Text .. comma_value(data.cost)
    itemHolder.Info.ItemName.Text = name
    itemHolder.Desc.Text = data.desc
    itemHolder.LayoutOrder = data.order

    if data.gamepass or data.product then
        itemHolder.Parent = ProductsShop
    else
        itemHolder.Parent = ToolsShop
    end

    itemHolder.Buy.Activated:Connect(function()
        if tick() - cooldownTime > cooldown then
            cooldownTime = tick()
            ShopConnection:FireServer(name)
        end
    end)
end

------------------------------------------------------------------

local function loadBought()
    local values = {}
    for name,_ in (ShopData) do
        values[name] = PlayerValues:GetValue(LocalPlayer, name)
    end

    for name,_ in (values) do
        if ProductsShop:FindFirstChild(name) then
            local holderUi = ProductsShop:FindFirstChild(name)
            holderUi.Bought.Visible = true
        end

        if ToolsShop:FindFirstChild(name) then
            local holderUi = ToolsShop:FindFirstChild(name)
            holderUi.Bought.Visible = true
        end
    end
end

for name,_ in (ShopData) do
    PlayerValues:SetCallback(name, function()
        loadBought()
    end)
end

loadBought()

UserInputService.InputBegan:Connect(onKeyPress)
