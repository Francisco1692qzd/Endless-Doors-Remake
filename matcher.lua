local G = getgenv()
local remotesFolder = nil
local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
local camera = workspace.CurrentCamera

local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
	camera.CFrame = camera.CFrame * cf
end)

camShake:Start()

local G = getgenv()

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

game.Lighting.MainColorCorrection.TintColor = Color3.fromRGB(212, 255, 0)
game.Lighting.MainColorCorrection.Contrast = 0.3
local tween = game:GetService("TweenService")
tween:Create(game.Lighting.MainColorCorrection, TweenInfo.new(0.5), {Contrast = 0}):Play()
local TweenService = game:GetService("TweenService")
local TW = TweenService:Create(game.Lighting.MainColorCorrection, TweenInfo.new(0.5),{TintColor = Color3.fromRGB(255, 255, 255)})
TW:Play()
local roast = Instance.new("Sound")
roast.Parent = workspace
roast.Name = "roast"
roast.SoundId = "rbxassetid://9125936117"
roast.Volume = 0.5
roast.Pitch = 3
roast:Play()
wait(0.6)
roast:Destroy()

-- [[ FORCE LOAD: Retries 30 times to bypass Roblox asset loading lag ]]
local function loadModel(id)
	local obj = nil
	local attempts = 0
	local maxAttempts = 30

	while obj == nil and attempts < maxAttempts do
		attempts = attempts + 1
		local success, result = pcall(function()
			return game:GetObjects("rbxassetid://" .. id)
		end)

		if success and result and result[1] then
			obj = result[1]
			--print("✅ Depth Model Loaded successfully on attempt: " .. attempts)
		else
			--warn("⚠️ Attempt " .. attempts .. " failed to load model " .. id .. ". Retrying...")
			task.wait(0.8) -- Small breather for the engine
		end
	end

	if not obj then
		warn("❌ CRITICAL: Failed to load model after 20 attempts.")
	end

	return obj
end

local matcher = loadModel(12445945135)
matcher.Parent = workspace
if not matcher:IsA("BasePart") then
	warn(matcher.Name .. " is a model or a folder, not a part!")
	return
end
local val = 65
local DEF_SPEED = 99999
local speed = 70
local storer = speed
local killed = false
local crucifixActive = false
local playerGui = game.Players.LocalPlayer.PlayerGui
if game.ReplicatedStorage:FindFirstChild("RemotesFolder") then remotesFolder = game.ReplicatedStorage:FindFirstChild("RemotesFolder") end
local moduleScripts = {
	Module_Events = require(game.ReplicatedStorage.ModulesClient.Module_Events),
	Main_Game = require(playerGui.MainUI.Initiator.Main_Game)
	--Earthquake = require(remotesFolder.RequestAsset:InvokeServer("Earthquake"))
}
print("matcher has been created succesfully in workpace")
local function canSeeTarget(target,size)
	if killed == true then
		return
	end

	local origin = matcher.Position
	local direction = (target.HumanoidRootPart.Position - origin).unit * size
	local ray = Ray.new(origin, direction)

	local hit, pos = workspace:FindPartOnRay(ray, matcher)

	if hit and hit:IsDescendantOf(target) then
		killed = true
		return true
	end
	return false
end
local function GetTime(dist, speed)
	return dist / speed
end
wait(2)

spawn(function()
	while matcher.Parent ~= nil and matcher ~= nil do wait(0.1)
		local v = game.Players.LocalPlayer
		if v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") then
			if canSeeTarget(v.Character, 50) and not v.Character:GetAttribute("Hiding") then
				-- CRUCIFIX REPENTANCE LOGIC
				if v.Character:FindFirstChild("Crucifix") and not crucifixActive then
					crucifixActive = true

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

					if matcher then
						repentanceModel:PivotTo(matcher.CFrame * CFrame.new(0, -3.7, 0))
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

					local sufferSound = Instance.new("Sound", matcher)
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

					if matcher then
						for _, snd in pairs(matcher:GetDescendants()) do
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
							if repentanceModel and repentanceModel.Entity and can and matcher then
								matcher.CFrame = repentanceModel.Entity.CFrame
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
					if matcher then matcher:Destroy() end
					can = false
					crucifixActive = false

					-- DO NOT remove the player's Crucifix - leave it alone!

					break
				end

				-- Regular damage (no crucifix)
				if not v.Character:FindFirstChild("Crucifix") and not crucifixActive then
					spawn(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/matcherjumpscare.lua"))()
					end)
					wait(0.1)
					v.Character.Humanoid.Health = 0
				end

				game.ReplicatedStorage.GameStats["Player_".. v.Character.Name].Total.DeathCause.Value = "Matcher"

				while v.Character.Humanoid.Health <= 0 do
					game["Run Service"].RenderStepped:Wait()
					if firesignal then
						firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
							"You died to Matcher...",
							"Running won't work, you shall try hiding.",
							"Pay attention to its arrival sound or a loud sound coming by."
						}, "Yellow")
					end
				end
			end
		end
	end
end)
spawn(function()
	while matcher.Parent ~= nil and matcher ~= nil do wait(0.6)
		local v = game.Players.LocalPlayer
		if v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = v.Character:FindFirstChild("HumanoidRootPart")
			if (matcher.Position - hrp.Position).magnitude <= val then
				camShake:ShakeOnce(4.5, 20, 0, 1)
			end
		end
	end
end)
speed = DEF_SPEED
local gruh = workspace:FindFirstChild("CurrentRooms")
for i = 1, game.ReplicatedStorage.GameData.LatestRoom.Value + 1 do
	if gruh:FindFirstChild(i) then
		if crucifixActive then break end
		local room = gruh[i]
		if room and room:FindFirstChild("Nodes") then
			moduleScripts.Module_Events.shatter(room)
			local nodes = room.Nodes
			for v = 1, #nodes:GetChildren() do
				if nodes:FindFirstChild(v) then
					if crucifixActive then break end
					local waypoint = nodes[v]
					local distance = (matcher.Position - waypoint.Position).magnitude
					local tween = game.TweenService:Create(matcher, TweenInfo.new(GetTime(distance, speed), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0,false,0), {CFrame = waypoint.CFrame + Vector3.new(0,1.4,0)})
					tween:Play()
					tween.Completed:Wait()
					speed = storer
					if room.Name == tostring(game.ReplicatedStorage.GameData.LatestRoom.Value) then
						room.Door.ClientOpen:FireServer()
					end
				end
			end
		end
	end
end

if not crucifixActive then
	-- Define destination with both position AND rotation
	local downCF = CFrame.new(0, -80, -80) * CFrame.Angles(0, 0, 0)  -- Example with rotation

	-- For distance calculation, you ONLY need position
	local destinationPos = downCF.Position  -- Extract just the Vector3
	local distance = (matcher.Position - destinationPos).magnitude

	-- Tween to the full CFrame (position + orientation)
	game.TweenService:Create(matcher, TweenInfo.new(GetTime(distance, speed), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {CFrame = downCF}):Play()
	wait(GetTime(distance, speed))
	matcher:Destroy()
end
local AchievementModule = game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock
if AchievementModule == nil then return end
if workspace:FindFirstChild("MatcherAchievement") then return end
if not game.ReplicatedStorage:FindFirstChild("ModulesShared") then return end
local dataModule = require(game:GetService("ReplicatedStorage"):WaitForChild("ModulesShared"):WaitForChild("Achievements"))
local unlockFunc = require(AchievementModule)
unlockFunc(nil, "Matcher")
local ObtainedBadge = Instance.new("BoolValue")
ObtainedBadge.Name = "MatcherAchievement"
ObtainedBadge.Value = true
ObtainedBadge.Parent = workspace
