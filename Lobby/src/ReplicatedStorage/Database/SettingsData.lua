local SettingsData = {
	["Music"] = {
		desc = "Music volume",
		order = 1,
		slider = true,
		sliderValue = 0.1,
		default = 1,
		min = 0,
		max = 2,
	},
	["Sounds"] = {
		desc = "Sound volume",
		order = 2,
		slider = true,
		sliderValue = 0.1,
		default = 1,
		min = 0,
		max = 2,
	},
	["AutoUpgrade"] = {
		desc = "Auto upgrade (VIP)",
		order = 3,
	},
	["HealthOff"] = {
		desc = "Disable health upgrade",
		order = 4,
	},
	["SpeedOff"] = {
		desc = "Disable speed upgrade",
		order = 5,
	},
	["JumpOff"] = {
		desc = "Disable jump upgrade",
		order = 6,
	},
}
return SettingsData
