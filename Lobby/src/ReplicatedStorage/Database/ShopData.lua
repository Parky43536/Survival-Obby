local ShopData = {}

ShopData.Items = {
	["Coin Magnet"] = {
		gamepass = 103133843,
		cost = 25,
		image = 11829053298,
		desc = "Automatically collects coins for you 🧲",
		order = 1,
	},
	["VIP"] = {
		gamepass = 103133738,
		cost = 250,
		image = 11829052997,
		desc = "Double coins, auto upgrades, and the VIP staff tool 🌟",
		order = 2,
	},
	["God Powers"] = {
		gamepass = 103134193,
		cost = 1000,
		image = 11829053132,
		desc = "Unlocks the powers of flight and god health 🤩",
		order = 3,
	},
	["500 Coins"] = {
		product = 1347281500,
		coins = 500,
		cost = 5,
		image = 11829053433,
		desc = "More coins to buy upgrades and tools 💰 (Unaffected by Income and VIP)",
		order = 4,
	},
	["2,500 Coins"] = {
		product = 1347281667,
		coins = 2500,
		cost = 25,
		image = 11829053433,
		desc = "More coins to buy upgrades and tools 💰 (Unaffected by Income and VIP)",
		order = 5,
	},
	["5,000 Coins"] = {
		product = 1347281803,
		coins = 5000,
		cost = 50,
		image = 11829053433,
		desc = "More coins to buy upgrades and tools 💰 (Unaffected by Income and VIP)",
		order = 6,
	},
	["10,000 Coins"] = {
		product = 1347282712,
		coins = 10000,
		cost = 100,
		image = 11829053433,
		desc = "More coins to buy upgrades and tools 💰 (Unaffected by Income and VIP)",
		order = 7,
	},
	["50,000 Coins"] = {
		product = 1347282905,
		coins = 50000,
		cost = 450,
		image = 11829053433,
		desc = "More coins to buy upgrades and tools 💰 (Unaffected by Income and VIP)",
		order = 8,
	},
	["100,000 Coins"] = {
		product = 1347282974,
		coins = 100000,
		cost = 800,
		image = 11829053433,
		desc = "More coins to buy upgrades and tools 💰 (Unaffected by Income and VIP)",
		order = 9,
	},
	["Bloxy Cola"] = {
		cost = 2000,
		image = 10472127,
		desc = "A cool refreshing drink that heals you 🥤",
		order = 1,
		chest = true,
	},
	["Banana Peel"] = {
		cost = 5000,
		image = 28937264,
		desc = "Drop banana peels on the ground for players to slip on 🍌",
		order = 2,
		chest = true,
	},
	["Bloxiade"] = {
		cost = 10000,
		image = 17237572,
		desc = "An energetic drink that increases your speed for a bit 🔋",
		order = 3,
		chest = true,
	},
	["Invisibility Cape"] = {
		cost = 10000,
		image = 129414426,
		desc = "Makes you invisible while you have it out 👻",
		order = 4,
	},
	["Regen Coil"] = {
		cost = 15000,
		image = 118870588,
		desc = "Passively heals you while you have it out 🩹",
		order = 5,
		chest = true,
	},
	["Speed Coil"] = {
		cost = 25000,
		image = 99170415,
		desc = "Makes you run faster while you have it out 💨",
		order = 6,
	},
	["Gravity Coil"] = {
		cost = 50000,
		image = 16619617,
		desc = "Makes you jump higher while you have it out 🌙",
		order = 7,
		chest = true,
	},
	["Rolling Pin"] = {
		cost = 75000,
		image = 11845896,
		desc = "Smack other players to make them fall over 💥",
		order = 8,
		chest = true,
	},
	["Golden Glove"] = {
		cost = 100000,
		image = 17386312,
		desc = "Smack other players to launch them off the level ✋😈",
		order = 9,
	},
}

function ShopData:getList()
	local indexList = {}

	for name, data in (ShopData.Items) do
		if not data.blocked then
			table.insert(indexList, name)
		end
	end

	return indexList
end

return ShopData
