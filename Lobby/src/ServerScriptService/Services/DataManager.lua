local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local BadgeService = game:GetService("BadgeService")

local RepServices = ReplicatedStorage.Services
local PlayerValues = require(RepServices.PlayerValues)

local Helpers = ReplicatedStorage.Helpers
local ErrorCodeHelper = require(Helpers.ErrorCodeHelper)

local Utility = ReplicatedStorage.Utility
local General = require(Utility.General)

local Remotes = ReplicatedStorage.Remotes
local DataConnection = Remotes.DataConnection
local ChatConnection = Remotes.ChatConnection

local SerServices = ServerScriptService.Services
local ClientService = require(SerServices.ClientService)
local DataStorage = SerServices.DataStorage
local ProfileService = require(DataStorage.ProfileService)
local ProfileTemplate = require(DataStorage.ProfileTemplate)

local DataManager = {}
DataManager.Profiles = {}

local function round(number, decimal)
    return math.round(number * 10 ^ decimal) / (10 ^ decimal)
end

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

function DataManager:Badges(player)
	local function awardBadge(id)
		if not BadgeService:UserOwnsBadgeAsync(player, id) then
			BadgeService:AwardBadge(player.UserId, id)
		end
	end

	local level = DataManager:GetValue(player, "Level")
	local wins = DataManager:GetValue(player, "Wins")

	if level >= 1 then
		awardBadge(2129871894)
	end
	if level >= 5 then
		awardBadge(2129871896)
	end
	if level >= 10 then
		awardBadge(2129871897)
	end
	if level >= 25 then
		awardBadge(2129871898)
	end
	if level >= 50 then
		awardBadge(2129871900)
	end
	if level >= 100 then
		awardBadge(2129871901)
	end
	if level >= 150 then
		awardBadge(2129871902)
	end
	if level >= 200 then
		awardBadge(2129871903)
	end

	if wins >= 1 then
		awardBadge(2129871886)
	end
	if wins >= 3 then
		awardBadge(2129871890)
	end
	if wins >= 5 then
		awardBadge(2129871891)
	end
	if wins >= 10 then
		awardBadge(2129871892)
	end
end

function DataManager:Restart(player)
	if DataManager:GetValue(player, "Level") == General.Levels + 1 then
		DataManager:SetValue(player, "Level", 0)
		DataManager:SetValue(player, "Cash", 0)
		DataManager:SetValue(player, "Health", 0)
		DataManager:SetValue(player, "Speed", 0)
		DataManager:SetValue(player, "Jump", 0)
		DataManager:SetValue(player, "Income", 0)

		PlayerValues:SetValue(player, "CurrentLevel", 0, "playerOnly")
		PlayerValues:SetValue(player, "Level", 0, "playerOnly")
		PlayerValues:SetValue(player, "Cash", 0, "playerOnly")
		PlayerValues:SetValue(player, "Health", 0, "playerOnly")
		PlayerValues:SetValue(player, "Speed", 0, "playerOnly")
		PlayerValues:SetValue(player, "Jump", 0, "playerOnly")
		PlayerValues:SetValue(player, "Income", 0, "playerOnly")

		if not PlayerValues:GetValue(player, "God Powers") then
			PlayerValues:SetValue(player, "Flight", nil, "playerOnly")
			PlayerValues:SetValue(player, "God Health", nil, "playerOnly")
		end
		for _, tool in pairs(player.Backpack:GetChildren()) do
			if not PlayerValues:GetValue(player, tool) then
				tool:Destroy()
			end
		end

		DataManager:TeleportToLevel(player, {level = 0})
		ClientService:SetPlayerStats(player)
	end
end

function DataManager:TeleportToLevel(player, args)
	if RunService:IsStudio() or PlayerValues:GetValue(player, "Level") >= args.level then
		local level = workspace.Levels:FindFirstChild(args.level)

		if not level then
			repeat
				level = workspace.Levels:FindFirstChild(args.level)
				task.wait()
			until level
		end

		if General.playerCheck(player) then
			PlayerValues:SetValue(player, "CurrentLevel", args.level)

			local character = player.Character
			character:PivotTo(level.Door.PlayerSpawn.CFrame)
		end
	end
end

local alertCooldowns = {}
function DataManager:SetSpawn(player, levelNum)
	PlayerValues:SetValue(player, "CurrentLevel", levelNum)
	ClientService:HealPlayer(player)

	if DataManager:GetValue(player, "Level") + 1 == levelNum or (DataManager:GetValue(player, "Level") == 0 and levelNum == 2) then
		DataManager:SetValue(player, "Level", levelNum)
		PlayerValues:SetValue(player, "Level", levelNum, "playerOnly")
		DataManager:GiveCash(player, General.LevelReward)

		local level = player:FindFirstChild("leaderstats"):FindFirstChild("Level")
		level.Value = levelNum
		if level.Value == "0" then
			level.Value = "Start"
		elseif level.Value == tostring(General.Levels + 1) then
			level.Value = "Finish"
		end

		if levelNum == General.Levels + 1 then
			DataManager:IncrementValue(player, "Wins", 1)

			local wins = player:FindFirstChild("leaderstats"):FindFirstChild("Wins")
			wins.Value += 1
		end
	else
		if DataManager:GetValue(player, "Level") + 1 < levelNum and alertCooldowns[player] ~= levelNum then
			alertCooldowns[player] = levelNum
			ChatConnection:FireClient(player, "[ALERT] You're level didn't progress! Go back!", Color3.fromRGB(255, 0, 0))
		end
	end

	DataManager:Badges(player)
end

function DataManager:GiveCash(player, cash, product)
	if cash > 0 then
		if not product then
			cash = math.floor(cash * General.getValue("Income", PlayerValues:GetValue(player, "Income")))

			if PlayerValues:GetValue(player, "VIP") then
				cash *= 2
			end
		end
	else
		if math.abs(cash) > PlayerValues:GetValue(player, "Cash") then
			cash = -PlayerValues:GetValue(player, "Cash")
		end
	end

	DataManager:IncrementValue(player, "Cash", cash)
	PlayerValues:IncrementValue(player, "Cash", cash, "playerOnly")
end

function DataManager:BuyUpgrade(player, upgrade)
	local cost = General.getCost(upgrade, PlayerValues:GetValue(player, upgrade))
	if cost and PlayerValues:GetValue(player, "Cash") >= cost then
		DataManager:IncrementValue(player, upgrade, 1)
		PlayerValues:IncrementValue(player, upgrade, 1, "playerOnly")
		DataManager:GiveCash(player, -cost)

		ClientService:UpgradePlayer(player, upgrade)
		ClientService:SetPlayerStats(player)
	end
end

function DataManager:SettingToggle(player, args)
	local on = true

	if PlayerValues:GetValue(player, args.setting) then
		on = nil
	end

	if args.setting == "AutoUpgrade" and not PlayerValues:GetValue(player, "VIP") then
		on = nil
	end

	local settings = DataManager:GetValue(player, "Settings")
	settings[args.setting] = on
	DataManager:SetValue(player, "Settings", settings)

	PlayerValues:SetValue(player, args.setting, on, "playerOnly")

	ClientService:SetPlayerStats(player)
end

function DataManager:SettingSlider(player, args)
	local settings = DataManager:GetValue(player, "Settings")
	settings[args.setting] = round(math.clamp(settings[args.setting] + args.value, args.min, args.max), 1)
	DataManager:SetValue(player, "Settings", settings)

	PlayerValues:SetValue(player, args.setting, settings[args.setting], "playerOnly")
end

DataConnection.OnServerEvent:Connect(function(player, action, args)
	if action == "Health" or action == "Speed" or action == "Jump" or action == "Income" then
		DataManager:BuyUpgrade(player, action)
	elseif action == "SettingToggle" then
		DataManager:SettingToggle(player, args)
	elseif action == "SettingSlider" then
		DataManager:SettingSlider(player, args)
	elseif action == "TeleportToLevel" then
		DataManager:TeleportToLevel(player, args)
	end
end)

return DataManager