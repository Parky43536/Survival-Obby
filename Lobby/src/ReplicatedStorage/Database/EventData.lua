local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local EventData = {
	["Nuke"] = {
		blocked = true,

		name = "Nuke",
		chance = 75,
		upgrades = {},

		delayTime = 10,
		height = 80,
		damage = 500,

		upgradedDelayTime = 6,
	},
	["TeslaCoil"] = {
		blocked = true,
		
		name = "Tesla Coil",
		chance = 65,
		upgrades = {},

		delayTime = 2,
		size = 32,
		damageTicks = 10,
		damageDelay = 1,
		damage = 15,

		upgradedSize = 44,
	},
	["Rocket"] = {
		blocked = true,
		
		name = "Rocket",
		chance = 60,
		upgrades = {},

		faceRate = 30,
		delayTime = 2,
		speed = 25,
		size = 12,
		damage = 50,

		upgradedSpeed = 50,
	},
	["AcidPuddle"] = {
		blocked = true,
		
		name = "Acid Puddle",
		chance = 60,
		upgrades = {},

		despawnTime = 14,
		growTime = 8,
		delayTime = 1,
		size = 24,
		damage = 10,

		upgradedSize = 32,
	},
	["LaserWall"] = {
		blocked = true,
		
		name = "Laser Wall",
		chance = 55,
		upgrades = {},

		despawnTime = 10,
		riseDelayTime = 0.5,
		laserDelayTime = 1,
		damage = 25,

		upgradedDamage = 35,
	},
	["Landmine"] = {
		blocked = true,
		
		name = "Landmine",
		chance = 50,
		upgrades = {},

		despawnTime = 60,
		delayTime = 1.5,
		size = 20,
		damage = 40,
	},
	["SpeedingWall"] = {
		blocked = true,
		
		name = "Speeding Wall",
		chance = 45,
		upgrades = {},

		speed = 25,
		size = 12,

		upgradedSize = 16,
	},
	["FallingRock"] = {
		blocked = true,
		
		name = "Falling Rock",
		chance = 50,
		level = 1,
		upgrades = {},

		despawnTime = 8,
		damageVelocity = 20,
		height = 40,
		offset = 10,
		size = 8,
		damage = 40,

		upgradedSize = 12,
	},
	["LavaLine"] = {
		blocked = true,
		
		name = "Lava Line",
		chance = 45,
		level = 1,
		upgrades = {},

		despawnTime = 6,
		delayTime = 1,
		size = 4,
		damage = 25,

		upgradedSize = 10,
	},
	["Spike"] = {
		blocked = true,
		
		name = "Spike",
		chance = 35,
		level = 1,
		upgrades = {},

		despawnTime = 10,
		delayTime = 0.5,
		damage = 40,

		slow = 8,
		slowDuration = 4,
	},
	["Bomb"] = {
		name = "Bomb",
		chance = 40,
		level = 1,
		upgrades = {},

		delayTime = 2,
		size = 24,
		damage = 50,

		sizeIncrease = 6,
		damageIncrease = 10,
	},
	-----------------------------------------------------
	["Heal"] = {
		name = "Heal",
		chance = 120,
		level = 1,
		heal = 15,
		despawnTime = 30,
	},
	["Coin"] = {
		name = "Coin",
		chance = 20,
		level = 1,
		value = 10,
		despawnTime = 30,
	},
}
return EventData
