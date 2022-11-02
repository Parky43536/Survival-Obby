local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Helpers = ReplicatedStorage.Helpers
local ErrorCodeHelper = require(Helpers.ErrorCodeHelper)

local Utility = ReplicatedStorage.Utility
local General = require(Utility.General)

local Remotes = ReplicatedStorage.Remotes
local DataConnection = Remotes.DataConnection

local SerServices = ServerScriptService.Services
local ClientService = require(SerServices.ClientService)
local DataStorage = SerServices.DataStorage
local ProfileService = require(DataStorage.ProfileService)
local ProfileTemplate = require(DataStorage.ProfileTemplate)

local DataManager = {}
DataManager.Profiles = {}

function DataManager:Initialize(player, storeName)
	local PlayerDataProfileStore = ProfileService.GetProfileStore(
		storeName,
		ProfileTemplate
	)

	local profile = PlayerDataProfileStore:LoadProfileAsync("Player_"..player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			if not RunService:IsStudio() then
				player:Kick(ErrorCodeHelper.FormatCode("0001"))
			end
		end)

		if player:IsDescendantOf(Players) then
			self.Profiles[player] = profile
		else
			-- player left before data was loaded
			profile:Release()
		end
	elseif not RunService:IsStudio() then
		player:Kick(ErrorCodeHelper.FormatCode("0002"))
	end

	return profile
end

function DataManager:SetValue(player, property, value)
	local playerProfile = self:GetProfile(player)
	if playerProfile then
		playerProfile.Data[property] = value
	end

	return nil
end

function DataManager:IncrementValue(player, property, value)
	local playerProfile = self:GetProfile(player)
	if playerProfile then
		playerProfile.Data[property] = (playerProfile.Data[property] or 0) + value
	end

	return playerProfile.Data[property]
end

function DataManager:GetValue(player, property)
	local playerProfile = self:GetProfile(player)

	if playerProfile then
		if property then
			return playerProfile.Data[property]
		else
			return playerProfile.Data
		end
	end

	warn(player, "has no profile stored in the data")
	return nil
end

function DataManager:GetProfile(player)
	return self.Profiles[player]
end

----------------------------------------------------------------------------------

function DataManager:SetSpawn(player, levelNum)
	--PlayerValues:SetValue(player, "CurrentLevel", levelNum)

	if DataManager:GetValue(player, "Level") + 1 == levelNum then
		DataManager:SetValue(player, "Level", levelNum)
		PlayerValues:SetValue(player, "Level", levelNum, "playerOnly")

		local level = player:FindFirstChild("leaderstats"):FindFirstChild("Level")
		level.Value += 1

		DataManager:GiveCash(player, General.RewardCash, {noMulti = true})
		ClientService.HealPlayer(player)
	end
end

function DataManager:GiveCash(player, cash, args)
	if not args then args = {} end
	if cash > 0 and not args.noMulti then
		cash = math.floor(cash + (cash * (PlayerValues:GetValue(player, "CMulti") / 10)))
	end

	DataManager:IncrementValue(player, "Cash", cash)
	PlayerValues:IncrementValue(player, "Cash", cash, "playerOnly")
end

function DataManager:BuyHealth(player)
	local cost = General.getCost("Health", PlayerValues:GetValue(player, "Health"))
	if PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:IncrementValue(player, "Health", 1)
		PlayerValues:IncrementValue(player, "Health", 1, "playerOnly")
		DataManager:GiveCash(player, -cost)

		ClientService.SetPlayerStats(player)
	end
end

function DataManager:BuySpeed(player)
	local cost = General.getCost("Speed", PlayerValues:GetValue(player, "Speed"))
	if PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:IncrementValue(player, "Speed", 1)
		PlayerValues:IncrementValue(player, "Speed", 1, "playerOnly")
		DataManager:GiveCash(player, -cost)

		ClientService.SetPlayerStats(player)
	end
end

function DataManager:BuyJump(player)
	local cost = General.getCost("Jump", PlayerValues:GetValue(player, "Jump"))
	if PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:IncrementValue(player, "Jump", 1)
		PlayerValues:IncrementValue(player, "Jump", 1, "playerOnly")
		DataManager:GiveCash(player, -cost)

		ClientService.SetPlayerStats(player)
	end
end

function DataManager:BuyCMulti(player)
	local cost = General.getCost("CMulti", PlayerValues:GetValue(player, "CMulti"))
	if PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:IncrementValue(player, "CMulti", 1)
		PlayerValues:IncrementValue(player, "CMulti", 1, "playerOnly")
		DataManager:GiveCash(player, -cost)
	end
end

function DataManager:BuyLuck(player)
	local cost = General.getCost("Luck", PlayerValues:GetValue(player, "Luck"))
	if PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:IncrementValue(player, "Luck", 1)
		PlayerValues:IncrementValue(player, "Luck", 1, "playerOnly")
		DataManager:GiveCash(player, -cost)
	end
end

DataConnection.OnServerEvent:Connect(function(player, action, args)
	if action == "Health" then
		DataManager:BuyHealth(player)
	elseif action == "Speed" then
		DataManager:BuySpeed(player)
	elseif action == "Jump" then
		DataManager:BuyJump(player)
	elseif action == "CMulti" then
		DataManager:BuyCMulti(player)
	elseif action == "Luck" then
		DataManager:BuyLuck(player)
	--[[elseif action == "CurrentLevel" then
		PlayerValues:SetValue(player, "CurrentLevel", args.level)]]
	end
end)

return DataManager