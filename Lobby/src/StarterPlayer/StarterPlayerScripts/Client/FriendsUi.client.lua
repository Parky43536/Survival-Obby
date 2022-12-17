local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlayerUi = PlayerGui:WaitForChild("PlayerUi")
local RightFrame = PlayerUi:WaitForChild("RightFrame")
local LevelsUi = PlayerGui:WaitForChild("LevelsUi")
local ShopUi = PlayerGui:WaitForChild("ShopUi")
local UpgradeUi = PlayerGui:WaitForChild("UpgradeUi")
local SettingsUi = PlayerGui:WaitForChild("SettingsUi")
local FriendsUi = PlayerGui:WaitForChild("FriendsUi")
local Friends = FriendsUi.FriendsFrame

local function friendsUiEnable()
    if FriendsUi.Enabled == true then
        FriendsUi.Enabled = false
    else
        UpgradeUi.Enabled = false
        ShopUi.Enabled = false
        LevelsUi.Enabled = false
        SettingsUi.Enabled = false
        FriendsUi.Enabled = true
    end
end

RightFrame.Frame.Friends.Activated:Connect(function()
    friendsUiEnable()
end)

FriendsUi.FriendsFrame.TopFrame.Close.Activated:Connect(function()
    friendsUiEnable()
end)

------------------------------------------------------------------

local cooldown = 1
local cooldownTime = tick()

Friends.Invite.Activated:Connect(function()
    if tick() - cooldownTime > cooldown then
        cooldownTime = tick()

        local canInvite = SocialService:CanSendGameInviteAsync(LocalPlayer)
        if canInvite then
            SocialService:PromptGameInvite(LocalPlayer)
        elseif not canInvite then
            Friends.Invite.Text = "Failed"
            task.wait(cooldown)
            Friends.Invite.Text = "Invite"
        end
    end
end)