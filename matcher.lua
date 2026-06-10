local G = getgenv()
local remotesFolder = nil
local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
local camera = workspace.CurrentCamera

local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
	camera.CFrame = camera.CFrame * cf
end)

camShake:Start()

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
				spawn(function()
					loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/matcherjumpscare.lua"))()
				end)
				wait(0.35)
				v.Character.Humanoid:TakeDamage(125)
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
		local room = gruh[i]
		if room and room:FindFirstChild("Nodes") then
			moduleScripts.Module_Events.shatter(room)
			local nodes = room.Nodes
			for v = 1, #nodes:GetChildren() do
				if nodes:FindFirstChild(v) then
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

-- Define destination with both position AND rotation
local downCF = CFrame.new(0, -80, -80) * CFrame.Angles(0, 0, 0)  -- Example with rotation

-- For distance calculation, you ONLY need position
local destinationPos = downCF.Position  -- Extract just the Vector3
local distance = (matcher.Position - destinationPos).magnitude

-- Tween to the full CFrame (position + orientation)
game.TweenService:Create(matcher, TweenInfo.new(GetTime(distance, speed), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {CFrame = downCF}):Play()
wait(GetTime(distance, speed))
matcher:Destroy()
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
