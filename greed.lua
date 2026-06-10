if workspace:FindFirstChild("SeekMovingNewClone") or workspace:FindFirstChild("SeekMoving") or workspace.CurrentRooms:FindFirstChild("50") then
    return
end

if workspace:FindFirstChild("RushMoving") then
    return
end

local ded = false
local gone = false
local player = game.Players.LocalPlayer

-- Sound
local sound = Instance.new("Sound", game.Lighting)
sound.SoundId = "rbxassetid://166047422"
sound.Volume = 5
sound:Play()

-- Create independent color correction
local greedColor = Instance.new("ColorCorrectionEffect")
greedColor.Parent = game.Lighting

-- Death check
local character = player.Character
if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health <= 0 then
    ded = true
end

-- Death trigger
game.ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function()
    if gone or ded then return end
    
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if hum and hum.Health > 0 then
        hum:TakeDamage(100)
        ded = true
        
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/greedjumps.lua"))()
        end)
        
        game.ReplicatedStorage.GameStats["Player_" .. player.Name].Total.DeathCause.Value = "Greed"
        
        wait(2.5)
        
        -- Achievement
        local success, achMod = pcall(function()
            return player.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock
        end)
        
        if success and achMod and not workspace:FindFirstChild("GreedAchievement") then
            pcall(function()
                require(achMod)(nil, "Greed")
                local badge = Instance.new("BoolValue")
                badge.Name = "GreedAchievement"
                badge.Value = true
                badge.Parent = workspace
            end)
        end
    end
end)

-- Visual effects on custom color correction
local ts = game:GetService("TweenService")

ts:Create(greedColor, TweenInfo.new(2), {Contrast = -0.19}):Play()
ts:Create(greedColor, TweenInfo.new(2), {Saturation = -0.19}):Play()
ts:Create(greedColor, TweenInfo.new(2), {TintColor = Color3.fromRGB(255, 191, 154)}):Play()

wait(5.7)

-- Fade out effects
ts:Create(greedColor, TweenInfo.new(4), {Contrast = 0}):Play()
ts:Create(greedColor, TweenInfo.new(4), {Saturation = 0}):Play()
ts:Create(greedColor, TweenInfo.new(4), {TintColor = Color3.fromRGB(255, 255, 255)}):Play()

-- Destroy after fade
task.wait(4)
greedColor:Destroy()

gone = true
