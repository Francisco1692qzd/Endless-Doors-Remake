local G = getgenv()
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
local crucifixActive = false

G.LoadGithubModel = function(url)
	if not (writefile and getcustomasset and request) then
		return nil
	end

	local function generateFileName(url)
		local hash = 0
		for i = 1, #url do
			hash = (hash * 31 + string.byte(url, i)) % 2^32
		end
		return "model_matcher_" .. tostring(hash) .. ".rbxm"
	end

	local fileName = generateFileName(url)

	local success, exists = pcall(function()
		return isfile and isfile(fileName)
	end)

	if success and exists then
		local assetId = getcustomasset(fileName)
		local loadSuccess, result = pcall(function()
			return game:GetObjects(assetId)[1]
		end)

		if loadSuccess and result then
			return result
		end
	end

	local response = request({Url = url, Method = "GET"})
	if response.StatusCode ~= 200 then return nil end

	writefile(fileName, response.Body)
	local assetId = getcustomasset(fileName)
	local success, result = pcall(function()
		return game:GetObjects(assetId)[1]
	end)

	if success and result then return result end
	return nil
end

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
					if not crucifixActive and v.Character:FindFirstChild("Crucifix") then
						crucifixActive = true
						deathTriggered = false
						camShake:Shake(CameraShaker.Presets.Bump)
						cue:Stop()

						local repentanceURL = "https://github.com/RegularVynixu/Utilities/blob/main/Doors/Entity%20Spawner/Assets/Repentance.rbxm?raw=true"
						local repentanceModel = nil
						if G.LoadGithubModel then
							repentanceModel = G.LoadGithubModel(repentanceURL)
							if repentanceModel then repentanceModel.Parent = workspace end
						end

						if repentanceModel == nil then 
							crucifixActive = false
							return 
						end

						if eyes.RushNew then
							repentanceModel:PivotTo(eyes.RushNew.CFrame * CFrame.new(0, -5.6, 0))
						end

						local crucifix = repentanceModel.Crucifix
						local soundFail = crucifix.SoundFail
						local sound = crucifix.Sound
						local light = crucifix.Light
						light.Parent = repentanceModel.PrimaryPart
						soundFail.Parent = repentanceModel.PrimaryPart
						sound.Parent = repentanceModel.PrimaryPart

						-- CRITICAL FIX: Set position FIRST while anchored
						local targetCFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, -3)
						local targetPosition = targetCFrame.Position

						-- Keep anchored initially
						crucifix.Anchored = true
						crucifix.CFrame = targetCFrame

						-- ADD BodyGyro to keep it upright while rotating
						local bodyGyro = Instance.new("BodyGyro")
						bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
						bodyGyro.CFrame = CFrame.new()
						bodyGyro.P = 10000
						bodyGyro.D = 500
						bodyGyro.Parent = crucifix

						-- ADD BodyPosition to keep it floating (prevent falling)
						local bodyPosition = Instance.new("BodyPosition")
						bodyPosition.MaxForce = Vector3.new(400000, 400000, 400000)
						bodyPosition.P = 10000
						bodyPosition.D = 500
						bodyPosition.Position = targetPosition
						bodyPosition.Parent = crucifix

						-- ADD BodyAngularVelocity for rotation
						local angularVelocity = Instance.new("BodyAngularVelocity")
						angularVelocity.MaxTorque = Vector3.new(400000, 400000, 400000)
						angularVelocity.AngularVelocity = Vector3.new(0, 25, 0)
						angularVelocity.Parent = crucifix

						-- NOW unanchor it (physics will take over with BodyPosition holding it)
						crucifix.Anchored = false

						local sufferSound = Instance.new("Sound", eyes.RushNew)
						sufferSound.SoundId = "rbxassetid://6305809364"
						sufferSound.Volume = 3.9
						sufferSound.Name = "Suffer"
						sufferSound.PlaybackSpeed = 0.6
						sufferSound.Looped = false
						sufferSound:Play()

						local eq = Instance.new("EqualizerSoundEffect", sufferSound)
						eq.HighGain = 4
						eq.LowGain = 0
						eq.MidGain = 4

						local can = true

						if eyes.RushNew then
							for _, snd in pairs(eyes.RushNew:GetDescendants()) do
								if (snd:IsA("Sound") and snd.Name ~= "Suffer") then
									snd:Stop()
								end
							end
						end

						if sound then sound:Play() end
						camShake:ShakeOnce(1.8, 16, 0.2, 3.9, 1, 6)

						-- Make the entity follow the crucifix during repentance
						local followLoop = task.spawn(function()
							while can and repentanceModel and repentanceModel.Entity do
								task.wait()
								if repentanceModel and repentanceModel.Entity and can and eyes.RushNew then
									eyes.RushNew.CFrame = repentanceModel.Entity.CFrame
									-- Update BodyPosition to keep crucifix floating
									if bodyPosition and crucifix then
										bodyPosition.Position = crucifix.Position
									end
								end
							end
						end)

						task.wait(1.7)

						camShake:ShakeOnce(2.1, 16, 0.2, 3.7, 1, 6)

						-- Move upward (keep rotating via BodyAngularVelocity)
						if repentanceModel and repentanceModel.Entity then
							local entity = repentanceModel.Entity
							local moveUpTween = game.TweenService:Create(entity, TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
								CFrame = entity.CFrame * CFrame.new(0, 3.5, 0)
							})
							moveUpTween:Play()

							-- Also update BodyPosition target
							if bodyPosition then
								local newPosTween = game.TweenService:Create(bodyPosition, TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
									Position = (entity.CFrame * CFrame.new(0, 3.5, 0)).Position
								})
								newPosTween:Play()
							end
						end
						task.wait(1.35)

						camShake:ShakeOnce(1.8, 16, 0.2, 2.9, 1, 6)

						-- Lower the entity (still rotating)
						if repentanceModel and repentanceModel.Entity then
							local entity = repentanceModel.Entity
							local lowerTween = game.TweenService:Create(entity, TweenInfo.new(1.68, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
								CFrame = entity.CFrame * CFrame.new(0, -24, 0)
							})
							lowerTween:Play()

							if bodyPosition then
								local lowerPosTween = game.TweenService:Create(bodyPosition, TweenInfo.new(1.68, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
									Position = (entity.CFrame * CFrame.new(0, -24, 0)).Position
								})
								lowerPosTween:Play()
							end
						end
						task.wait(1.68)

						camShake:ShakeOnce(1.8, 16, 0.2, 4.2, 1, 6)

						-- Slow down rotation
						if angularVelocity then
							local slowTween = game.TweenService:Create(angularVelocity, TweenInfo.new(1.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								AngularVelocity = Vector3.new(0, 3, 0)
							})
							slowTween:Play()
						end
						task.wait(1.7)

						-- Stop rotation completely
						if angularVelocity then
							local stopTween = game.TweenService:Create(angularVelocity, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								AngularVelocity = Vector3.new(0, 0, 0)
							})
							stopTween:Play()
						end

						-- Disable body forces (allow falling/destruction)
						if bodyPosition then
							local fadeForceTween = game.TweenService:Create(bodyPosition, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
								P = 0
							})
							fadeForceTween:Play()
						end

						if bodyGyro then
							local fadeGyroTween = game.TweenService:Create(bodyGyro, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
								P = 0
							})
							fadeGyroTween:Play()
						end

						camShake:ShakeOnce(3.8, 16, 0.2, 6, 1, 6)

						-- Grow the crucifix
						if crucifix then
							local growTween = game.TweenService:Create(crucifix, TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
								Size = crucifix.Size * 2.4
							})
							growTween:Play()

							if light then
								local growLightTween = game.TweenService:Create(light, TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
									Brightness = light.Brightness * 1.8,
									Range = light.Range * 1.9
								})
								growLightTween:Play()
							end
						end
						task.wait(1.9)

						-- Make the crucifix transparent
						if crucifix then
							local fadeTween = game.TweenService:Create(crucifix, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
								Transparency = 1
							})
							fadeTween:Play()
						end

						-- Fade out all parts of the repentance model
						if repentanceModel then
							for _, part in pairs(repentanceModel:GetDescendants()) do
								if part:IsA("BasePart") then
									local partFade = game.TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Linear), {
										Transparency = 1
									})
									partFade:Play()
								end
							end
						end

						task.wait(1.8)

						-- Destroy the entity and crucifix effects ONLY
						if repentanceModel then repentanceModel:Destroy() end
						if eyes.RushNew then eyes:Destroy() end
						can = false
						crucifixActive = false

						-- DO NOT remove the player's Crucifix - leave it alone!

						break
					end
					
					if not crucifixActive and not v.Character:FindFirstChild("Crucifix") then
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
					end

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
if workspace:FindFirstChild("ClaimAchievement") then return end
if not game.ReplicatedStorage:FindFirstChild("ModulesShared") then return end
local dataModule = require(game:GetService("ReplicatedStorage"):WaitForChild("ModulesShared"):WaitForChild("Achievements"))
local unlockFunc = require(AchievementModule)
unlockFunc(nil, "Claim")
local ObtainedBadge = Instance.new("BoolValue")
ObtainedBadge.Name = "ClaimAchievement"
ObtainedBadge.Value = true
ObtainedBadge.Parent = workspace
