repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LatestRoom = ReplicatedStorage.GameData.LatestRoom
local TS = game:GetService("TweenService")

-- Fix bulb zap sound
ReplicatedStorage.Sounds.BulbZap.Changed:Connect(function()
	if ReplicatedStorage.Sounds.BulbZap.SoundId ~= "" and ReplicatedStorage.Sounds.BulbZap.SoundId ~= " " then
		ReplicatedStorage.Sounds.BulbZap.SoundId = "rbxassetid://4398878054"
	end
end)

local entityURLs = {
	Matcher = "https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/matcher.lua",
	Bound = "https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/rebound.lua",
	Greed = "https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/greed.lua",
	Overseer = "https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/overseer.lua",
	Phil = "https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/phil.lua",
	Claim = "https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/claim.lua"
}

local function ShowCaption(text, duration)
    local pGui = Player:WaitForChild("PlayerGui")
    if pGui:FindFirstChild("EndlessCaption") then pGui.EndlessCaption:Destroy() end
    local screenGui = Instance.new("ScreenGui", pGui)
    screenGui.Name = "EndlessCaption"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    local captionLabel = Instance.new("TextLabel", screenGui)
    captionLabel.Size = UDim2.new(0.6, 0, 0.05, 10)
    captionLabel.Position = UDim2.new(0.5, 0, 0.92, -60)
    captionLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    captionLabel.BackgroundTransparency = 1
    captionLabel.Text = text
    captionLabel.TextColor3 = Color3.fromRGB(255, 222, 189)
    captionLabel.TextSize = 30
    captionLabel.Font = Enum.Font.Oswald
    captionLabel.TextStrokeTransparency = 0
    
    local alertSound = Instance.new("Sound", game.SoundService)
    alertSound.SoundId = "rbxassetid://3848738542"
    alertSound:Play()
    game.Debris:AddItem(alertSound, 2)
    
    task.delay(duration or 4, function()
        if captionLabel then
            TS:Create(captionLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            task.wait(0.5) screenGui:Destroy()
        end
    end)
end

-- Check if has executed already
local alreadyExecuted = workspace:FindFirstChild("Endless")

if not alreadyExecuted then
	if LatestRoom.Value ~= 0 then
		ShowCaption("Execute this script at door 0, please.", 3.5)
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid:TakeDamage(100)
		end
		return
	else
		local stringValue = Instance.new("StringValue", workspace)
		stringValue.Name = "Endless"
		stringValue.Value = "LSPLASH is the BEST creator of games ever"
		print(stringValue.Value)
		ShowCaption("Loaded", 3)
	end
else
	ShowCaption("Sorry, you can't execute a script currently running already.", 5.7)
	return
end

local function LoadEntity(name)
    if workspace:FindFirstChild("SeekMoving") or workspace:FindFirstChild("SeekMovingNewClone") then 
        return 
    end
	if LatestRoom.Value == 100 or LatestRoom.Value == 50 or LatestRoom.Value > 89 then 
        return 
    end
    local url = entityURLs[name]
    if url then 
        task.spawn(function() 
            pcall(function() 
                print("Spawning: " .. name)
                loadstring(game:HttpGet(url))() 
            end) 
        end) 
    end
end

pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/Endless-Doors-Remake/refs/heads/main/achi.lua"))()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/OverridenEntitiesMode/refs/heads/main/nodes.lua"))()
end)

local opened = false

local rammessages = {
	"Have fun! (you won't)",
	"Eughh... I don't feel so good... please like this mode I'm hungry.",
	"Five nights at Freddy's, how could it be?",
	"Various entities await you.",
	"Dread spawns if you take too long in one room.",
	"Random messages = nil"
}

-- ========== SYNC WAIT (absolute offsets from script start) ==========
local scriptStartTime = workspace:GetServerTimeNow()
local function SyncWait(secondsFromStart)
    local targetTime = scriptStartTime + secondsFromStart
    while workspace:GetServerTimeNow() < targetTime do
        task.wait(0.1)
    end
end

-- Fixed schedule (absolute times)
local spawnSchedule = {
	{time = 75, entity = "Overseer", needsDoor = true},
	{time = 98, entity = "Matcher", needsDoor = true},
	{time = 150, entity = "Overseer", needsDoor = true},
	{time = 164, entity = "Matcher", needsDoor = true},
	{time = 230, entity = "Claim", needsDoor = true},
	{time = 250, entity = "Matcher", needsDoor = true},
	{time = 300, entity = "Overseer", needsDoor = true},
	{time = 410, entity = "Claim", needsDoor = true},
	{time = 450, entity = "Rebound", needsDoor = true},
	{time = 500, entity = "Matcher", needsDoor = true},
	{time = 549, entity = "Claim", needsDoor = true},
	{time = 600, entity = "Overseer", needsDoor = true},
	{time = 750, entity = "Matcher", needsDoor = true},
	{time = 820, entity = "Rebound", needsDoor = true},
	{time = 900, entity = "Overseer", needsDoor = true},
	{time = 1000, entity = "Claim", needsDoor = true},
	{time = 1125, entity = "Rebound", needsDoor = true},
	{time = 1200, entity = "Matcher", needsDoor = true},
	{time = 1500, entity = "Overseer", needsDoor = true},
	{time = 1900, entity = "Phil", needsDoor = true},
	{time = 2000, entity = "Matcher", needsDoor = true},
	{time = 2250, entity = "Claim", needsDoor = true},
	{time = 2700, entity = "Phil", needsDoor = true},
	{time = 3000, entity = "Overseer", needsDoor = true},
	{time = 3600, entity = "Phil", needsDoor = true},
	{time = 4000, entity = "Rebound", needsDoor = true},
}

-- Deterministic RNG for random messages only (doesn't affect spawn sync)
local rngState = math.floor(scriptStartTime * 1000) % 2^31
local function deterministicRandom(min, max)
    rngState = (1103515245 * rngState + 12345) % 2^31
    return min + (rngState % (max - min + 1))
end

LatestRoom.Changed:Connect(function()
	if LatestRoom.Value ~= 0 and opened == false then
		local startSound = Instance.new("Sound", workspace)
		startSound.SoundId = "rbxassetid://4835664238"
		startSound.Volume = 1.5
		startSound.Pitch = 1
		startSound:Play()
		game.Debris:AddItem(startSound, 5)
		
		local folder = Instance.new("Folder", workspace)
		folder.Name = "Mimic"
		
		opened = true
		ShowCaption("Endless Mode Initiated", 3)
		task.wait(3)
		ShowCaption("Good luck, fellow player", 4)
		task.wait(4)
		local randommessage = rammessages[deterministicRandom(1, #rammessages)]
		ShowCaption(randommessage, 5)
		task.wait(5)

		-- ===== FIXED SCHEDULE (absolutely synced) =====
		task.spawn(function()
			for _, spawn in ipairs(spawnSchedule) do
				SyncWait(spawn.time)   -- all players wait for the same absolute time
				
				if spawn.needsDoor then
					LatestRoom.Changed:Wait()   -- all wait for the same door event
				end
				
				LoadEntity(spawn.entity)
				task.wait(0.5)   -- cosmetic delay, does not desync
			end
			
			print("Scheduled spawns complete. Entering random spawn mode...")
			
			-- ===== RANDOM SPAWNS (relative, but players start together) =====
			while true do
				local randomTime = math.random(180, 300)   -- 3-5 minutes real wait
				task.wait(randomTime)                     -- relative wait (same for all because they start this loop together)
				LatestRoom.Changed:Wait()
				
				local entities = {"Overseer", "Matcher", "Claim", "Rebound"}
				local randomEntity = entities[math.random(#entities)]
				LoadEntity(randomEntity)
				
				if math.random(1, 3) == 1 then
					local atmosphereMessages = {
						"You feel something watching...",
						"The air grows heavy...",
						"Something is approaching...",
						"Your heart races..."
					}
					ShowCaption(atmosphereMessages[math.random(#atmosphereMessages)], 2)
				end
			end
		end)
		
		-- ===== GREED (punishment, relative, no door wait) =====
		task.spawn(function()
			while true do
				local delay = math.random(60, 180)
				task.wait(delay)
				LoadEntity("Greed")
				task.wait(1)
			end
		end)
	end
end)
