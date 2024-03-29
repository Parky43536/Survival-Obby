local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage.Assets
local Tools = Assets.Tools

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local DataBase = ReplicatedStorage.Database
local ShopData = require(DataBase:WaitForChild("ShopData"))

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Remotes = ReplicatedStorage.Remotes
local ShopConnection = Remotes.ShopConnection

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)
local ClientService = require(SerServices.ClientService)

local ShopService = {}

local function getNameById(id)
	for name, data in (ShopData.Items) do
		if data.product and data.product == id then
			return name
		end
		if data.gamepass and data.gamepass == id then
			return name
		end
	end
end

function ShopService:GiveGamepass(player, name)
	PlayerValues:SetValue(player, name, true, "playerOnly")

	if name == "God Powers" then
		PlayerValues:SetValue(player, "Flight", true, "playerOnly")
        PlayerValues:SetValue(player, "God Health", true, "playerOnly")
	elseif name == "VIP" then
		PlayerValues:SetValue(player, "VIP Wand", true, "playerOnly")
		if not player.Backpack:FindFirstChild("VIP Wand") then
			local Tool = Tools:FindFirstChild("VIP Wand"):Clone()
			Tool.Parent = player.Backpack
		end
	end

	local purchases = DataManager:GetValue(player, "Purchases")
	if not purchases[name] then
		purchases[name] = true
		DataManager:SetValue(player, "Purchases", purchases)
	end
end

function ShopService:GiveProduct(player, name)
	DataManager:SettingToggle(player, {settingName = "AutoUpgrade", setting = "off"})

	DataManager:GiveCash(player, ShopData.Items[name].coins, true)

	local purchases = DataManager:GetValue(player, "Purchases")
	if not purchases[name] then purchases[name] = 0 end
	purchases[name] += 1
	DataManager:SetValue(player, "Purchases", purchases)
end

function ShopService:GiveTool(player, name)
	PlayerValues:SetValue(player, name, true, "playerOnly")

	if not player.Backpack:FindFirstChild(name) then
		local Tool = Tools:FindFirstChild(name):Clone()
		Tool.Parent = player.Backpack
	end

	local purchases = DataManager:GetValue(player, "Purchases")
	if not purchases[name] then
		purchases[name] = true
		DataManager:SetValue(player, "Purchases", purchases)
	end
end

function ShopService:BuyTool(player, name)
	local purchases = DataManager:GetValue(player, "Purchases")
	if not purchases[name] then
		local toolData = ShopData.Items[name]

		if PlayerValues:GetValue(player, "Cash") >= toolData.cost or RunService:IsStudio() then
			DataManager:GiveCash(player, -toolData.cost)
			ShopService:GiveTool(player, name)
		end
	end
end

function ShopService:InitializePurchases(player)
	local purchases = DataManager:GetValue(player, "Purchases")

	for name, data in (ShopData.Items) do
		if data.gamepass then
			if purchases[name] or MarketplaceService:UserOwnsGamePassAsync(player.UserId, data.gamepass) then
				ShopService:GiveGamepass(player, name)
			end
		elseif not data.product then
			if purchases[name] then
				ShopService:GiveTool(player, name)
			end
		end
	end
end

function ShopService:InitializeTools(player)
	for name, data in (ShopData.Items) do
		if not data.product and not data.gamepass and PlayerValues:GetValue(player, name) then
			if not player.Backpack:FindFirstChild(name) then
				local Tool = Tools:FindFirstChild(name):Clone()
				Tool.Parent = player.Backpack
			end
		end
	end
end

ShopConnection.OnServerEvent:Connect(function(player, action, args)
	if not args then args = {} end

	if ShopData.Items[action] then
		if ShopData.Items[action].gamepass then
			MarketplaceService:PromptGamePassPurchase(player, ShopData.Items[action].gamepass)
		elseif ShopData.Items[action].product then
			MarketplaceService:PromptProductPurchase(player, ShopData.Items[action].product)
		else
			ShopService:BuyTool(player, action)
		end
	elseif action == "GiveGodHealth" then
		PlayerValues:SetValue(player, "GodHealth", args.on)
		ClientService:SetPlayerStats(player)
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, purchased)
	if purchased then
		ShopService:GiveGamepass(player, getNameById(id))
	end
end)

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	local name = getNameById(receiptInfo.ProductId)
	ShopService:GiveProduct(player, name)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

return ShopService