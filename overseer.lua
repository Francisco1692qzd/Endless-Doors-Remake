local Overseer = Instance.new("Model")
Overseer.Parent = workspace
Overseer.Name = "Overseer"

local v = game.Players.LocalPlayer
local enableDamage = true
local no = false

-- Sounds
local damage1 = Instance.new("Sound")
damage1.SoundId = "rbxassetid://5507830449"
damage1.Pitch = 1.2
damage1.Volume = 0.7

local damage2 = Instance.new("Sound")
damage2.SoundId = "rbxassetid://5507830815"
damage2.Pitch = 1.2
damage2.Volume = 0.7

local damage3 = Instance.new("Sound")
damage3.SoundId = "rbxassetid://5507829691"
damage3.Pitch = 1.2
damage3.Volume = 0.7

-- Camera Shake
local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
local camera = workspace.CurrentCamera
local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end)

-- Get current room
local currentLoadedRoom = workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]
local eyes = game:GetObjects("rbxassetid://12285389022")[1]

-- Auto-destroy Overseer when new room loads
workspace.CurrentRooms.ChildAdded:Connect(function()
	if Overseer then
		Overseer:Destroy()
	end
	enableDamage = false
end)

-- Position the eyes
local num = 0
if currentLoadedRoom:FindFirstChild("Nodes") then
	num = math.floor(#currentLoadedRoom.Nodes:GetChildren() / 2)
end

local targetCF = (num == 0 and currentLoadedRoom[currentLoadedRoom.Name] or currentLoadedRoom.Nodes[num]).CFrame
eyes.CFrame = targetCF + Vector3.new(0, 5, 0)
eyes.Parent = Overseer

-- Parent sounds
damage1.Parent = Overseer
damage2.Parent = Overseer
damage3.Parent = Overseer
local soundList = {damage1, damage2, damage3}

-- Check if already dead
if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0 then
	no = true
end

-- Main damage loop
task.spawn(function()
	while Overseer and enableDamage do
		task.wait(0.5)
		
		if not Overseer or not enableDamage then break end
		
		-- Don't damage during Seek chase or room 50
		if workspace:FindFirstChild("SeekMoving") or workspace:FindFirstChild("SeekMovingNewClone") or workspace.CurrentRooms:FindFirstChild("50") then
			continue
		end

		if workspace:FindFirstChild("Lookman") or workspace:FindFirstChild("Eyes") then
			continue
		end
		
		local isOnScreen = workspace.CurrentCamera:WorldToScreenPoint(eyes.Position)
		
		if not isOnScreen then
			local character = v.Character
			if character and character:FindFirstChild("Humanoid") then
				local humanoid = character.Humanoid
				local isHiding = character:GetAttribute("Hiding") or false
				
				if not isHiding then
					camShake:Start()
					camShake:ShakeOnce(5, 15, 0.1, 1)
					humanoid.Health = humanoid.Health - 3
					
					if no == false then
						soundList[math.random(#soundList)]:Play()
					end
					
					if humanoid.Health <= 0 and no == false then
						game.ReplicatedStorage.GameStats["Player_" .. v.Name].Total.DeathCause.Value = "Overseer Eyes"
						no = true
						
						-- Death hint
						while game["Run Service"].RenderStepped:Wait() do
							if firesignal then
								firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
									"You died to Overseer.",
									"It only strikes when you're not watching.",
									"Keep your eyes on it or hide!"
								}, "Yellow")
							end
						end
					end
				end
			end
		end
	end
end)
