local LevelData = {}

LevelData.Levels = {
	["Chest"] = {
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
	["House"] = {
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
	},
	["Right"] = {
		level = 4,
		turn = true
	},
	["Default"] = {
		level = 0,
	},
}

function LevelData:getList()
	local indexList = {}

	for name, data in (LevelData.Levels) do
		if not data.blocked then
			table.insert(indexList, name)
		end
	end

	return indexList
end

return LevelData
