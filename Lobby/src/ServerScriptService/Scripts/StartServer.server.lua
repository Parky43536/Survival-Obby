local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

for _, event in ReplicatedStorage.Events:GetChildren() do
    require(event)
end

local GameService = require(ServerScriptService.Services.GameService)
GameService.SetUpGame()
