local LevelData = {}

LevelData.Levels = {
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
	["Left"] = {
		level = 4,
		turn = true
	},
	["Right"] = {
		level = 4,
		turn = true
	},
	["Default"] = {
		level = 0,
	},
}


function LevelData.getList()
	local indexList = {}

	for name, data in pairs(LevelData.Levels) do
		if not data.blocked then
			table.insert(indexList, name)
		end
	end

	return indexList
end

return LevelData
