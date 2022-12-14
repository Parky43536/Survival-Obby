local EventData = {
	["Nuke"] = {
		name = "Nuke",
		chance = 75,
		upgrades = {},

		delayTime = 10,
		height = 80,
		damage = 500,
	},
	["TeslaCoil"] = {
		name = "Tesla Coil",
		chance = 65,
		upgrades = {},

		delayTime = 2,
		size = 40,
		damageTicks = 10,
		damageDelay = 1,
		damage = 15,

		sizeIncrease = 5,
	},
	["AcidPuddle"] = {
		name = "Acid Puddle",
		chance = 60,
		upgrades = {},

		despawnTime = 10,
		growTime = 6,
		delayTime = 1,
		size = 24,
		damage = 15,

		sizeIncrease = 6,
	},
	["LaserWall"] = {
		name = "Laser Wall",
		chance = 55,
		upgrades = {},

		despawnTime = 10,
		riseDelayTime = 0.5,
		laserDelayTime = 1,
		damage = 30,

		damageIncrease = 10,
	},
	["Landmine"] = {
		name = "Landmine",
		chance = 45,
		upgrades = {},

		despawnTime = 60,
		delayTime = 1.5,
		size = 20,
		damage = 30,

		sizeIncrease = 4,
		damageIncrease = 5,
	},
	["FallingRock"] = {
		name = "Falling Rock",
		chance = 50,
		upgrades = {},

		despawnTime = 8,
		damageVelocity = 20,
		height = 40,
		offset = 10,
		size = 8,
		damage = 30,

		sizeIncrease = 4,
	},
	["SpeedingWall"] = {
		name = "Speeding Wall",
		chance = 45,
		upgrades = {},

		speed = 25,
		size = 12,

		sizeIncrease = 4,
	},
	["Rocket"] = {
		name = "Rocket",
		chance = 60,
		upgrades = {},

		faceRate = 30,
		delayTime = 2,
		speed = 25,
		size = 12,
		damage = 30,

		speedIncrease = 5,
		sizeIncrease = 4,
		damageIncrease = 5,
	},
	["Spinner"] = {
		name = "Spinner",
		chance = 55,
		level = 1,
		upgrades = {},

		despawnTime = 8,
		delayTime = 1,
		tripTime = 0.5,
		size = 18,

		sizeIncrease = 4,
	},
	["LavaLine"] = {
		name = "Lava Line",
		chance = 45,
		level = 1,
		upgrades = {},

		despawnTime = 6,
		delayTime = 1,
		size = 4,
		damage = 15,

		sizeIncrease = 4,
	},
	["Spike"] = {
		name = "Spike",
		chance = 35,
		level = 1,
		upgrades = {},

		despawnTime = 10,
		delayTime = 0.5,
		damage = 30,
	},
	["Bomb"] = {
		name = "Bomb",
		chance = 40,
		level = 1,
		upgrades = {},

		delayTime = 2,
		size = 24,
		damage = 30,

		sizeIncrease = 4,
		damageIncrease = 5,
	},
	["Heal"] = {
		name = "Heal",
		chance = 120,
		level = 1,
		heal = 0.1,
		despawnTime = 30,
	},
	["Coin"] = {
		name = "Coin",
		chance = 15,
		level = 1,
		value = 10,
		despawnTime = 30,
	},
}
return EventData
