local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventData = {
	["Rocket"] = {
		chance = 60,
		levels = {min = 65, max = General.Levels},
		obstacle = true,

		faceRate = 30,
		delayTime = 3,
		speed = 20,
		size = 12,
		damage = 40,
	},
	["AcidPuddle"] = {
		chance = 65,
		levels = {min = 40, max = General.Levels},
		obstacle = true,

		despawnTime = 14,
		growTime = 8,
		delayTime = 1,
		size = 20,
		damage = 10,
	},
	["LaserWall"] = {
		chance = 55,
		levels = {min = 20, max = General.Levels},
		obstacle = true,

		despawnTime = 10,
		riseDelayTime = 0.5,
		laserDelayTime = 0.5,
		damage = 30,
	},
	["SpeedingWall"] = {
		chance = 45,
		levels = {min = 10, max = General.Levels},
		obstacle = true,

		travelTime = 3.5,
	},
	["LavaLine"] = {
		chance = 45,
		levels = {min = 5, max = General.Levels},
		obstacle = true,

		despawnTime = 6,
		delayTime = 1,
		damage = 20,
	},
	["Spike"] = {
		chance = 35,
		levels = {min = 2, max = General.Levels},
		obstacle = true,

		despawnTime = 10,
		delayTime = 0.5,
		damage = 30,
	},
	["Bomb"] = {
		chance = 40,
		levels = {min = 2, max = General.Levels},
		obstacle = true,

		delayTime = 2,
		size = 24,
		damage = 50,
	},
	-----------------------------------------------------
	["SuperCoin"] = {
		chance = 20,
		levels = {min = 50, max = General.Levels},
		value = 20,
		despawnTime = 30,
	},
	["Heal"] = {
		chance = 120,
		levels = {min = 30, max = General.Levels},
		heal = 25,
		despawnTime = 30,
	},
	["Coin"] = {
		chance = 10,
		levels = {min = 2, max = 49},
		value = 10,
		despawnTime = 30,
	},
}
return EventData
