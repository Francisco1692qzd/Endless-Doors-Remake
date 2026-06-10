local G = getgenv()
local remotesFolder = nil
local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
local camera = workspace.CurrentCamera
local maxRebounds = 4

local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
	camera.CFrame = camera.CFrame * cf
end)

camShake:Start()

local TweenService = game:GetService("TweenService")

G.LoadGithubModel = function(url)
	if not (writefile and getcustomasset and request) then
		return nil
	end

	local function generateFileName(url)
		local hash = 0
		for i = 1, #url do
			hash = (hash * 31 + string.byte(url, i)) % 2^32
		end
		return "bound_" .. tostring(hash) .. ".rbxm"
	end

	local fileName = generateFileName(url)

	local fileExists = false
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

G.LoadGithubAudio = function(url)
	if not (writefile and getcustomasset and request) then return nil end

	local function generateFileName(url)
		local hash = 0
		for i = 1, #url do
			hash = (hash * 31 + string.byte(url, i)) % 2^32
		end
		return "bounds_" .. tostring(hash) .. ".mp3"
	end

	local fileName = generateFileName(url)

	local success, exists = pcall(function()
		return isfile and isfile(fileName)
	end)

	if success and exists then
		local assetSuccess, assetId = pcall(function()
			return getcustomasset(fileName)
		end)

		if assetSuccess then
			return assetId
		end
	end

	local response = request({
		Url = url,
		Method = "GET",
		Headers = {
			["Accept"] = "audio/mpeg, audio/ogg, application/octet-stream"
		}
	})

	if response.StatusCode ~= 200 then
		return nil
	end

	writefile(fileName, response.Body)

	local success, assetId = pcall(function()
		return getcustomasset(fileName)
	end)

	if success then
		return assetId
	end

	return nil
end

local function rebound()
	local entity = nil
	if G.LoadGithubModel then
		entity = G.LoadGithubModel("https://github.com/Francisco1692qzd/Endless-Doors-Remake/blob/main/bound.rbxm?raw=true")
		if entity then
			entity.Parent = workspace
		end
	end
	if entity == nil then return end
	
	-- Check if Rebound exists in the model
	if not entity:FindFirstChild("Rebound") then
		print("Rebound part not found in model")
		return
	end
	
	local reboundPart = entity.Rebound

	local function GetLastRoom()
		local currentRoomNum = game.ReplicatedStorage.GameData.LatestRoom.Value
		if currentRoomNum == 100 then
			return workspace.CurrentRooms[currentRoomNum]
		else
			return workspace.CurrentRooms[currentRoomNum + 1]
		end
	end

	local val = 60
	local speed = 1.8
	local killed = false
	local playerGui = game.Players.LocalPlayer.PlayerGui
	local moveSoundObj = nil  -- Store reference to move sound

	-- Stop any existing destruction sounds
	for _, destructions in pairs(reboundPart:GetChildren()) do
		if destructions:IsA("Sound") and destructions.Name == "Destruction" then
			pcall(function() destructions:Stop() end)
			destructions.Looped = false
		end
	end

	-- Fix Volume from 'Rebound' Sound
	reboundPart.Rebound.Volume = 0.7

	-- Load and play move sound
	local moveSoundId = G.LoadGithubAudio("https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/MovingRebound.mp3")
	if moveSoundId then
		moveSoundObj = Instance.new("Sound", reboundPart)
		moveSoundObj.Volume = 7
		moveSoundObj.SoundId = moveSoundId
	end

	-- Play a thunder sound to warn spawning
	local thundahh = Instance.new("Sound", workspace)
	thundahh.SoundId = "rbxassetid://5246103002"
	thundahh.Volume = 0.9
	thundahh:Play()
	game.Debris:AddItem(thundahh, 10)
	local pitch = Instance.new("PitchShiftSoundEffect", thundahh)
	pitch.Octave = 0.5

	-- Set initial position
	local lastRoom = GetLastRoom()
	if lastRoom and lastRoom:FindFirstChild("RoomExit") then
		reboundPart.CFrame = lastRoom.RoomExit.CFrame
	else
		reboundPart.CFrame = CFrame.new(0, 0, 0)
	end

	if game.ReplicatedStorage:FindFirstChild("RemotesFolder") then 
		remotesFolder = game.ReplicatedStorage:FindFirstChild("RemotesFolder") 
	end

	-- Safe module requires with pcall
	local moduleEvents = nil
	local mainGame = nil
	pcall(function()
		moduleEvents = require(game.ReplicatedStorage.ModulesClient.Module_Events)
		mainGame = require(playerGui.MainUI.Initiator.Main_Game)
	end)

	print("Rebound has been created successfully in workspace")

	local function canSeeTarget(target, size)
		if killed == true then
			return false
		end

		if not target or not target:FindFirstChild("HumanoidRootPart") then
			return false
		end

		if not reboundPart or not reboundPart.Parent then
			return false
		end

		local origin = reboundPart.Position
		local direction = (target.HumanoidRootPart.Position - origin).unit * size
		local ray = Ray.new(origin, direction)

		local hit, pos = workspace:FindPartOnRay(ray, reboundPart)

		if hit and hit:IsDescendantOf(target) then
			killed = true
			return true
		end
		return false
	end

	-- Wait before playing move sound
	task.wait(4)
	
	if moveSoundObj then
		pcall(function() moveSoundObj:Play() end)
	end

	-- Vision check coroutine
	task.spawn(function()
		while entity and entity.Parent ~= nil and reboundPart and reboundPart.Parent ~= nil do 
			task.wait(0.6)
			local v = game.Players.LocalPlayer
			if v and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				local hiding = false
				pcall(function() hiding = v.Character:GetAttribute("Hiding") or false end)
				
				local canSee = canSeeTarget(v.Character, 35)
				if canSee and not hiding then
					if moveSoundObj then
						pcall(function() moveSoundObj:Stop() end)
					end
					pcall(function()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/reboundjumpscare.lua"))()
					end)
					task.wait(0.1)
					if v.Character and v.Character:FindFirstChild("Humanoid") then
						v.Character.Humanoid:TakeDamage(125)
					end
					while game["Run Service"].RenderStepped:Wait() do
						if firesignal and killed then
							firesignal(remotesFolder.DeathHint.OnClientEvent, {
								"You died to Rebound...",
								"Rebound returns multiple times. Each time it gets more aggressive.",
								"Hide in a closet immediately when you hear its thunder sound!"
							}, "Yellow")
						end
					end
					break
				end
			end
		end
	end)

	-- Camera shake coroutine
	task.spawn(function()
		while entity and entity.Parent ~= nil and reboundPart and reboundPart.Parent ~= nil do 
			task.wait(0.35)
			local v = game.Players.LocalPlayer
			if v and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and reboundPart then
				local dist = (reboundPart.Position - v.Character.HumanoidRootPart.Position).magnitude
				if dist <= val then
					camShake:ShakeOnce(8, 13, 0, 1.7)
				end
			end 
		end
	end)

	local gruh = workspace.CurrentRooms
	local currentRoom = game.ReplicatedStorage.GameData.LatestRoom.Value
	
	-- Movement logic - FIXED: maxRebounds is now accessed from the outer scope correctly
	local reboundsLeft = maxRebounds  -- Capture current value
	
	if reboundsLeft == 4 or reboundsLeft == 2 then
		-- Go backwards through RoomEntrance
		for i = currentRoom, 1, -1 do
			if not entity or not reboundPart then break end
			local room = gruh:FindFirstChild(tostring(i))
			if room and room:FindFirstChild("RoomEntrance") then
				local targetCF = room.RoomEntrance.CFrame
				local tween = TweenService:Create(reboundPart, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {CFrame = targetCF})
				tween:Play()
				tween.Completed:Wait()
				task.wait(1)
			end
		end
	elseif reboundsLeft == 3 then
		-- Go forwards through RoomExit
		for i = 1, currentRoom do
			if not entity or not reboundPart then break end
			local room = gruh:FindFirstChild(tostring(i))
			if room and room:FindFirstChild("RoomExit") then
				local targetCF = room.RoomExit.CFrame
				local tween = TweenService:Create(reboundPart, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {CFrame = targetCF})
				tween:Play()
				tween.Completed:Wait()
				task.wait(1)
			end
		end
	elseif reboundsLeft == 1 then
		-- Go backwards
		for i = currentRoom, 1, -1 do
			if not entity or not reboundPart then break end
			local room = gruh:FindFirstChild(tostring(i))
			if room and room:FindFirstChild("RoomEntrance") then
				local targetCF = room.RoomEntrance.CFrame
				local tween = TweenService:Create(reboundPart, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0), {CFrame = targetCF})
				tween:Play()
				tween.Completed:Wait()
				task.wait(0.3)
			end
		end
	end
	
	-- Cleanup
	if reboundPart then
		reboundPart.Anchored = false
		reboundPart.CanCollide = false
	end
	
	game.Debris:AddItem(entity, 4)
end

local function start()
	local light = Instance.new("ColorCorrectionEffect", game.Lighting)
	light.TintColor = Color3.fromRGB(0, 138, 213)
	light.Brightness = -0.02
	light.Contrast = 7
	light.Saturation = 0.6
	game.TweenService:Create(light, TweenInfo.new(11), {
		TintColor = Color3.fromRGB(255,255, 255),
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	}):Play() game.Debris:AddItem(light, 13)
	camShake:ShakeOnce(9, 20, 0, 4.5)
	
	local spawnSoundId = G.LoadGithubAudio("https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/Warning.mp3")
	if spawnSoundId then
		local spawnSound = Instance.new("Sound", workspace) 
		game.Debris:AddItem(spawnSound, 10)
		spawnSound.SoundId = spawnSoundId
		spawnSound.Volume = 1
		spawnSound.PlaybackSpeed = 1
		spawnSound:Play()
	end
	
	-- Initial spawn
	local success, err = pcall(rebound)
	if not success then
		warn("Rebound failed: " .. tostring(err))
	end
	
	-- Subsequent rebounds
	local reboundCount = maxRebounds
	while reboundCount > 1 do
		game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait()
		task.wait(2)
		pcall(rebound)
		reboundCount = reboundCount - 1
	end
	
	-- Achievement unlock (FIXED: moved outside the loop, only trigger once)
	task.wait(1.5)  -- Wait a bit after last rebound
	
	local success, AchievementModule = pcall(function()
		return game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock
	end)
	
	if not success or AchievementModule == nil then return end
	if workspace:FindFirstChild("ReboundEAchievement") then return end
	
	local success2 = pcall(function()
		require(game:GetService("ReplicatedStorage"):WaitForChild("ModulesShared"):WaitForChild("Achievements"))
	end)
	
	local success3, unlockFunc = pcall(function()
		return require(AchievementModule)
	end)
	
	if success3 and unlockFunc then
		pcall(function()
			unlockFunc(nil, "ReboundE")
		end)
		local ObtainedBadge = Instance.new("BoolValue")
		ObtainedBadge.Name = "ReboundEAchievement"
		ObtainedBadge.Value = true
		ObtainedBadge.Parent = workspace
	end
end

pcall(start)
