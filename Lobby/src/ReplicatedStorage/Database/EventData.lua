local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventData = {
	["TeslaCoil"] = {
		chance = 65,
		levels = {min = 60, max = General.Levels},
		obstacle = true,

		delayTime = 2,
		size = 30,
		damageTicks = 5,
		damageDelay = 2,
		damage = 30,
	},
	["Rocket"] = {
		chance = 60,
		levels = {min = 50, max = General.Levels},
		obstacle = true,

		faceRate = 30,
		delayTime = 2,
		speed = 25,
		size = 12,
		damage = 50,
	},
	["AcidPuddle"] = {
		chance = 60,
		levels = {min = 30, max = General.Levels},
		obstacle = true,

		despawnTime = 14,
		growTime = 8,
		delayTime = 1,
		size = 20,
		damage = 15,
	},
	["LaserWall"] = {
		chance = 55,
		levels = {min = 10, max = General.Levels},
		obstacle = true,

		despawnTime = 10,
		riseDelayTime = 0.5,
		laserDelayTime = 1,
		damage = 25,
	},
	["SpeedingWall"] = {
		chance = 45,
		levels = {min = 5, max = General.Levels},
		obstacle = true,

		speed = 25,
	},
	["FallingRock"] = {
		chance = 50,
		levels = {min = 1, max = General.Levels},
		obstacle = true,

		despawnTime = 8,
		height = 40,
		offset = 10,
		damage = 40,
	},
	["LavaLine"] = {
		chance = 45,
		levels = {min = 1, max = General.Levels},
		obstacle = true,

		despawnTime = 6,
		delayTime = 1,
		damage = 25,
	},
	["Spike"] = {
		chance = 35,
		levels = {min = 1, max = General.Levels},
		obstacle = true,

		despawnTime = 10,
		delayTime = 0.5,
		damage = 40,
	},
	["Bomb"] = {
		chance = 40,
		levels = {min = 1, max = General.Levels},
		obstacle = true,

		delayTime = 2,
		size = 24,
		damage = 50,
	},
	-----------------------------------------------------
	["SuperCoin"] = {
		chance = 40,
		levels = {min = 40, max = General.Levels},
		value = 20,
		despawnTime = 30,
	},
	["Heal"] = {
		chance = 120,
		levels = {min = 20, max = General.Levels},
		heal = 15,
		despawnTime = 30,
	},
	["Coin"] = {
		chance = 20,
		levels = {min = 2, max = 39},
		value = 10,
		despawnTime = 30,
	},
}
return EventData
