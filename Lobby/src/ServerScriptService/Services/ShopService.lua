local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Tools = Assets.Tools

local DataBase = ReplicatedStorage.Database
local ShopData = require(DataBase:WaitForChild("ShopData"))

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Remotes = ReplicatedStorage.Remotes
local ShopConnection = Remotes.ShopConnection

local SerServices = ServerScriptService.Services
local DataManager = require(SerServices.DataManager)

local ShopService = {}

local function getNameById(id)
	for name, data in (ShopData) do
		if data.gamepass and data.gamepass == id then
			return name
		end
	end
end

function ShopService:GiveGamepass(player, name)
	PlayerValues:SetValue(player, name, true, "playerOnly")

	local purchases = DataManager:GetValue(player, "Purchases")
	if not purchases[name] then
		print(player.Name .. " was given " .. name)

		purchases[name] = true
		DataManager:GetValue(player, "Purchases")
	end
end

function ShopService:GiveTool(player, name)
	PlayerValues:SetValue(player, name, true, "playerOnly")

	local Tool = Tools:FindFirstChild(name):Clone()
	Tool.Parent = player.Backpack

	local purchases = DataManager:GetValue(player, "Purchases")
	if not purchases[name] then
		print(player.Name .. " was given " .. name)

		purchases[name] = true
		DataManager:GetValue(player, "Purchases")
	end
end

function ShopService:BuyTool(player, name)
	local purchases = DataManager:GetValue(player, "Purchases")
	if not purchases[name] then
		local toolData = ShopData[name]

		if PlayerValues:GetValue(player, "Cash") >= toolData.cost then
			DataManager:GiveCash(player, -toolData.cost)
			ShopService:GiveTool(player, name)
		end
	end
end

function ShopService:InitializePurchases(player)
	local purchases = DataManager:GetValue(player, "Purchases")

	for name, data in (ShopData) do
		if data.gamepass then
			if purchases[name] or MarketplaceService:UserOwnsGamePassAsync(player.UserId, data.gamepass) then
				ShopService:GiveGamepass(player, name)
			end
		else
			if purchases[name] then
				ShopService:GiveTool(player, name)
			end
		end
	end
end

ShopConnection.OnServerEvent:Connect(function(player, action)
	if ShopData[action] then
		if ShopData[action].gamepass then
			MarketplaceService:PromptGamePassPurchase(player, ShopData[action].gamepass)
		else
			ShopService:BuyTool(player, action)
		end
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, id, purchased)
	if purchased then
		ShopService:GiveGamepass(player, getNameById(id))
	end
end)

return ShopService