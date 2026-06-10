local currentLoadedRoom = workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]
local eyes = game:GetObjects("rbxassetid://11411321855")[1]

local num = 0

if currentLoadedRoom:FindFirstChild("Nodes") then
	num = math.floor(#currentLoadedRoom.Nodes:GetChildren() / 2)
end

eyes.Name = "ClaimNew"
eyes.RushNew.CFrame = (num == 0 and currentLoadedRoom[currentLoadedRoom.Name] or currentLoadedRoom.Nodes[num]).CFrame + Vector3.new(0, 5, 0)
eyes.Parent = workspace

local killed = false
local deathTriggered = false

-- CanSeeTarget function
local function canSeeTarget(target, size)
	if killed == true then
		return false
	end
	
	if not target or not target:FindFirstChild("HumanoidRootPart") then
		return false
	end
	
	if not eyes or not eyes.RushNew then
		return false
	end
	
	local origin = eyes.RushNew.Position
	local direction = (target.HumanoidRootPart.Position - origin).unit * size
	local ray = Ray.new(origin, direction)
	
	local hit, pos = workspace:FindPartOnRay(ray, eyes.RushNew)
	
	if hit and hit:IsDescendantOf(target) then
		killed = true
		return true
	end
	return false
end

-- Setup particles
local particle = eyes.RushNew.Attachment
if particle then
	particle.ParticleEmitter.Enabled = false
	particle.Spark.Enabled = false
end

-- Death sound
local death = Instance.new("Sound")
death.Parent = workspace
death.Name = "die"
death.SoundId = "rbxassetid://5867708670"
death.Volume = 0.7
death.Pitch = 1

local distort = Instance.new("DistortionSoundEffect")
distort.Level = 0.9
distort.Parent = death

-- Bubble sound
local cue = Instance.new("Sound")
cue.Parent = workspace
cue.Name = "Bubbles"
cue.SoundId = "rbxassetid://9113601215"
cue.Volume = 1
cue.Pitch = 0.6

local distort2 = Instance.new("DistortionSoundEffect")
distort2.Level = 0.7
distort2.Parent = cue
cue.TimePosition = 1.25

-- Initial delay
wait(0.5)

if particle then
	particle.Spark.Enabled = true
end
cue:Play()
wait(2)

-- Camera Shaker setup
local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
local camera = workspace.CurrentCamera
local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end)
camShake:Start()

-- Main damage loop with RenderStepped
local deathHintShown = false

task.spawn(function()
	while eyes and eyes.Parent ~= nil and eyes.RushNew and eyes.RushNew.Parent ~= nil do
		game["Run Service"].RenderStepped:Wait()
		
		local v = game.Players.LocalPlayer
		if v and v.Character and v.Character:FindFirstChild("Humanoid") then
			local humanoid = v.Character.Humanoid
			local isHiding = v.Character:GetAttribute("Hiding") or false
			
			if not isHiding and humanoid.Health > 0 then
				local canSee = canSeeTarget(v.Character, 50)
				
				if canSee and not deathTriggered then
					deathTriggered = true
					
					-- Camera shake before death
					camShake:ShakeOnce(10, 25, 0.5, 2)
					
					-- Damage and kill
					humanoid:TakeDamage(100)
					game.ReplicatedStorage.GameStats["Player_" .. v.Name].Total.DeathCause.Value = "Claim"
					death:Play()
					
					-- Disable all body parts (make them invisible/can collide false)
					for _, part in pairs(v.Character:GetChildren()) do
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
							part.Transparency = 1
							part.CanCollide = false
						end
					end
					
					-- Death hint loop
					while humanoid.Health <= 0 --[[and not deathHintShown]] do
						game["Run Service"].RenderStepped:Wait()
						if humanoid.Health <= 0 then
							--deathHintShown = true
							if firesignal then
								firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
									"You died to Claim.",
									"It watches from the darkness. Don't let it see you.",
									"Hide or look away before it's too late!"
								}, "Yellow")
							end
						end
					end
					
					-- Load jumpscare
					pcall(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/check78/GuidingLight/main/ClaimDie.txt"))()
					end)
					
					break
				end
			end
		end
	end
end)

-- Idle sound and tweening
if eyes and eyes.RushNew then
	particle.ParticleEmitter.Enabled = true
	
	local TweenService = game:GetService("TweenService")
	
	local cue2 = Instance.new("Sound")
	cue2.Parent = eyes.RushNew
	cue2.Name = "Idle"
	cue2.SoundId = "rbxassetid://8256091246"
	cue2.Volume = 1
	cue2.Pitch = 4
	
	local distort3 = Instance.new("DistortionSoundEffect")
	distort3.Level = 0.9
	distort3.Parent = cue2
	
	local fl = Instance.new("FlangeSoundEffect")
	fl.Depth = 0.06
	fl.Mix = 0.85
	fl.Rate = 5
	fl.Parent = cue2
	
	cue2.RollOffMaxDistance = 90
	cue2.RollOffMinDistance = 5
	cue2.RollOffMode = Enum.RollOffMode.LinearSquare
	
	local TW = TweenService:Create(cue2, TweenInfo.new(1.5), {Pitch = 0})
	local TW2 = TweenService:Create(cue2, TweenInfo.new(1.5), {Volume = 0})
	local TW3 = TweenService:Create(cue2, TweenInfo.new(1.5), {Volume = 1})
	
	cue2:Play()
	TW3:Play()
	
	wait(11)
	
	if eyes.RushNew then
		eyes.RushNew.Anchored = false
		eyes.RushNew.CanCollide = false
	end
	
	TW:Play()
	TW2:Play()
	
	wait(2)
end

-- Cleanup
if eyes then
	eyes:Destroy()
end
if death then
	death:Destroy()
end
if cue then
	cue:Destroy()
end

local AchievementModule = game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock
if AchievementModule == nil then return end
if workspace:FindFirstChild("OverseerAchievement") then return end
if not game.ReplicatedStorage:FindFirstChild("ModulesShared") then return end
local dataModule = require(game:GetService("ReplicatedStorage"):WaitForChild("ModulesShared"):WaitForChild("Achievements"))
local unlockFunc = require(AchievementModule)
unlockFunc(nil, "Overseer")
local ObtainedBadge = Instance.new("BoolValue")
ObtainedBadge.Name = "OverseerAchievement"
ObtainedBadge.Value = true
ObtainedBadge.Parent = workspace
