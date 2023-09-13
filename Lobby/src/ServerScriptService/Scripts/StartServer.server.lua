local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

PhysicsService:RegisterCollisionGroup("Wall")
PhysicsService:RegisterCollisionGroup("Player")
PhysicsService:RegisterCollisionGroup("FlyingPlayer")

PhysicsService:CollisionGroupSetCollidable("Player", "Player", false)
PhysicsService:CollisionGroupSetCollidable("Player", "FlyingPlayer", false)
PhysicsService:CollisionGroupSetCollidable("Wall", "FlyingPlayer", false)

for _, event in ReplicatedStorage.Events:GetChildren() do
    require(event)
end

local GameService = require(ServerScriptService.Services.GameService)
GameService:SetUpGame()
