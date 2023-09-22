local LevelData = {}

LevelData.Levels = {
	["Split"] = {
		level = 4,
	},
	["Dip"] = {
		level = 4,
	},
	["Wall"] = {
		level = 4,
	},
	["Hill"] = {
		level = 4,
	},
	["Advertiser"] = {
		level = 4,
	},
	["Wide"] = {
		level = 4,
	},
	["Line"] = {
		level = 4,
	},
	["Ramp"] = {
		level = 4,
		elevationChange = true,
		chances = 8,
	},
	["Right"] = {
		level = 4,
		turn = true,
		chances = 8,
	},
	["Default"] = {
		level = 0,
	},
}

function LevelData:getList()
	local indexList = {}

	for name, data in (LevelData.Levels) do
		if not data.blocked then
			for _= 1, data.chances or 1 do
				table.insert(indexList, name)
			end
		end
	end

	return indexList
end

return LevelData
