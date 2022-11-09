local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventData = {
	["TeslaCoil"] = {
		chance = 65,
		levels = {min = 70, max = General.Levels},
		upgrade = 90,

		delayTime = 2,
		size = 34,
		damageTicks = 10,
		damageDelay = 1,
		damage = 15,
	},
	["Rocket"] = {
		chance = 60,
		levels = {min = 50, max = General.Levels},
		upgrade = 80,

		faceRate = 30,
		delayTime = 2,
		speed = 25,
		size = 12,
		damage = 50,
	},
	["AcidPuddle"] = {
		chance = 60,
		levels = {min = 25, max = General.Levels},
		upgrade = 75,

		despawnTime = 14,
		growTime = 8,
		delayTime = 1,
		size = 20,
		damage = 15,
	},
	["LaserWall"] = {
		chance = 55,
		levels = {min = 15, max = General.Levels},
		upgrade = 65,

		despawnTime = 10,
		riseDelayTime = 0.5,
		laserDelayTime = 1,
		damage = 25,
	},
	--landmines
	["SpeedingWall"] = {
		chance = 45,
		levels = {min = 5, max = General.Levels},
		upgrade = 55,

		speed = 25,
		size = 12,

		upgradedSize = 20,
	},
	["FallingRock"] = {
		chance = 50,
		levels = {min = 1, max = General.Levels},
		upgrade = 45,

		despawnTime = 8,
		damageVelocity = 20,
		height = 40,
		offset = 10,
		size = 8,
		damage = 40,

		upgradedDamage = 50,
		upgradedSize = 16,
	},
	["LavaLine"] = {
		chance = 45,
		levels = {min = 1, max = General.Levels},
		upgrade = 40,

		despawnTime = 6,
		delayTime = 1,
		size = 4,
		damage = 25,

		upgradedSize = 10,
	},
	["Spike"] = {
		chance = 35,
		levels = {min = 1, max = General.Levels},
		upgrade = 35,

		despawnTime = 10,
		delayTime = 0.5,
		damage = 40,

		slow = 8,
		slowDuration = 4,
	},
	["Bomb"] = {
		chance = 40,
		levels = {min = 1, max = General.Levels},
		upgrade = 30,

		delayTime = 2,
		size = 24,
		damage = 50,

		upgradedSize = 32,
		upgradedDamage = 60,
	},
	-----------------------------------------------------
	["Heal"] = {
		chance = 120,
		levels = {min = 20, max = General.Levels},
		heal = 15,
		despawnTime = 30,
	},
	["Coin"] = {
		chance = 20,
		levels = {min = 2, max = General.Levels},
		value = 10,
		despawnTime = 30,
	},
}
return EventData
