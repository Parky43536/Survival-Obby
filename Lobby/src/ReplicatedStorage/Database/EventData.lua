local EventData = {}

EventData.Events = {
	["Nuke"] = {
		name = "Nuke",

		delayTime = 10,
		height = 80,
		damage = 500,
	},
	["TeslaCoil"] = {
		name = "Tesla Coil",

		delayTime = 2,
		size = 40,
		damageTicks = 10,
		damageDelay = 1,
		damage = 20,

		sizeIncrease = 5,
		damageIncrease = 10,
	},
	["AcidPuddle"] = {
		name = "Acid Puddle",

		despawnTime = 10,
		growTime = 6,
		delayTime = 1,
		size = 30,
		damage = 20,

		sizeIncrease = 5,
		damageIncrease = 10,
	},
	["LaserWall"] = {
		name = "Laser Wall",

		despawnTime = 10,
		riseDelayTime = 0.5,
		laserDelayTime = 1,
		damage = 60,

		damageIncrease = 10,
	},
	["Landmine"] = {
		name = "Landmine",

		delayTime = 1.5,
		size = 25,
		damage = 50,

		sizeIncrease = 4,
		damageIncrease = 10,
	},
	["FallingRock"] = {
		name = "Falling Rock",

		despawnTime = 8,
		damageVelocity = 20,
		height = 40,
		offset = 10,
		size = 14,
		damage = 30,

		sizeIncrease = 2,
		damageIncrease = 10,
	},
	["SpeedingWall"] = {
		name = "Speeding Wall",

		speed = 25,
		size = 18,

		sizeIncrease = 2,
	},
	["HomingRocket"] = {
		name = "Homing Rocket",
		copyOf = "Rocket",

		speed = 20,
	},
	["Rocket"] = {
		name = "Rocket",

		rate = 30,
		delayTime = 2,
		distance = 100,
		speed = 40,
		size = 20,
		damage = 50,

		speedIncrease = 5,
		sizeIncrease = 4,
		damageIncrease = 10,
	},
	["ButtonBot"] = {
		name = "Button Bot",
		level = 1,

		speed = 13,
		damage = 20,

		speedIncrease = 3,
		damageIncrease = 10,
	},
	["Spinner"] = {
		name = "Spinner",
		level = 1,

		despawnTime = 8,
		delayTime = 1,
		tripTime = 0.5,
		force = 25,
		size = 18,

		sizeIncrease = 4,
	},
	["LavaLine"] = {
		name = "Lava Line",
		level = 1,

		despawnTime = 6,
		delayTime = 1,
		size = 8,
		damage = 20,

		sizeIncrease = 4,
		damageIncrease = 10,
	},
	["Spike"] = {
		name = "Spike",
		level = 1,

		despawnTime = 10,
		delayTime = 0.5,
		damage = 80,
	},
	["Bomb"] = {
		name = "Bomb",
		level = 1,

		delayTime = 2,
		size = 30,
		damage = 50,

		sizeIncrease = 4,
		damageIncrease = 10,
	},
	["Heal"] = {
		name = "Heal",
		level = 1,

		heal = 0.1,
		despawnTime = 30,
	},
	["Coin"] = {
		name = "Coin",
		level = 1,
		blocked = true,

		value = 10,
		despawnTime = 30,
	},
}

function EventData:getList()
	local indexList = {}

	for name, data in (EventData.Events) do
		if not data.blocked then
			table.insert(indexList, name)
		end

		if data.TESTING then
			return {name}
		end
	end

	return indexList
end

return EventData
