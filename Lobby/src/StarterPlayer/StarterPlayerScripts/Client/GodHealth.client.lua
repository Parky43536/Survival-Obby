local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Utility = ReplicatedStorage:WaitForChild("Utility")
local General = require(Utility.General)

local RepServices = ReplicatedStorage:WaitForChild("Services")
local PlayerValues = require(RepServices:WaitForChild("PlayerValues"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopConnection = Remotes:WaitForChild("ShopConnection")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local RightFrame = PlayerUi:WaitForChild("RightFrame")

local godHealth = false

local function processGodly()
	godHealth = not godHealth

	if godHealth then
		RightFrame.GodHealth.BackgroundColor3 = Color3.fromRGB(4, 214, 0)
		ShopConnection:FireServer("GiveGodHealth", {on = true})
	else
		RightFrame.GodHealth.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
		ShopConnection:FireServer("GiveGodHealth", {on = false})
	end
end

PlayerValues:SetCallback("God Health", function(player, value)
    if RightFrame then
        if value then
            RightFrame.GodHealth.Visible = true
        else
            RightFrame.GodHealth.Visible = false
        end
    end
end)

RightFrame.GodHealth.Activated:Connect(function()
    processGodly()
end)




