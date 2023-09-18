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
	},
	["AcidPuddle"] = {
		name = "Acid Puddle",

		despawnTime = 10,
		growTime = 6,
		delayTime = 1,
		size = 30,
		damage = 25,

		sizeIncrease = 5,
	},
	["LaserWall"] = {
		name = "Laser Wall",

		despawnTime = 10,
		riseDelayTime = 0.5,
		laserDelayTime = 1,
		damage = 60,

		damageIncrease = 5,
	},
	["Landmine"] = {
		name = "Landmine",

		despawnTime = 60,
		delayTime = 1.5,
		size = 25,
		damage = 50,

		sizeIncrease = 4,
		damageIncrease = 5,
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
	},
	["SpeedingWall"] = {
		name = "Speeding Wall",

		speed = 25,
		size = 18,

		sizeIncrease = 4,
	},
	["Rocket"] = {
		name = "Rocket",

		faceRate = 30,
		delayTime = 2,
		speed = 50,
		size = 20,
		damage = 50,

		speedIncrease = 2,
		sizeIncrease = 4,
		damageIncrease = 5,
	},
	["Spinner"] = {
		name = "Spinner",
		level = 1,

		despawnTime = 8,
		delayTime = 1,
		tripTime = 0.5,
		force = 25,
		size = 25,

		sizeIncrease = 5,
	},
	["LavaLine"] = {
		name = "Lava Line",
		level = 1,

		despawnTime = 6,
		delayTime = 1,
		size = 8,
		damage = 25,

		sizeIncrease = 4,
	},
	["Spike"] = {
		name = "Spike",
		level = 1,

		despawnTime = 10,
		delayTime = 0.5,
		damage = 75,
	},
	["Bomb"] = {
		name = "Bomb",
		level = 1,

		delayTime = 2,
		size = 30,
		damage = 50,

		sizeIncrease = 4,
		damageIncrease = 5,
	},
	["Heal"] = {
		name = "Heal",
		level = 1,
		pickAgain = true,

		heal = 0.1,
		despawnTime = 30,
	},
	["Coin"] = {
		name = "Coin",
		level = 1,
		chances = 3,
		pickAgain = true,

		value = 10,
		despawnTime = 30,
	},
}

function EventData:getList()
	local indexList = {}

	for name, data in (EventData.Events) do
		if not data.blocked then
			for i = 1 , data.chances or 1 do
				table.insert(indexList, name)
			end
		end
	end

	return indexList
end

return EventData
