local AchievementModule = game.Players.LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.AchievementUnlock
if AchievementModule == nil then return end
if not game.ReplicatedStorage:FindFirstChild("ModulesShared") then return end
local dataModule = require(game:GetService("ReplicatedStorage"):WaitForChild("ModulesShared"):WaitForChild("Achievements"))
local unlockFunc = require(AchievementModule)

local function ImageLoader(url)
    if not (writefile and getcustomasset and request) then return nil end
    
    local rawUrl = url:gsub("github.com", "raw.githubusercontent.com"):gsub("/blob/", "/")
    
    -- Generate consistent filename from URL
    local function generateFileName(url)
        local hash = 0
        for i = 1, #url do
            hash = (hash * 31 + string.byte(url, i)) % 2^32
        end
        return "LoadedImageAchievement_" .. tostring(hash) .. ".png"
    end
    
    local fileName = generateFileName(rawUrl)
    
    -- Check if file exists and return it
    local success, exists = pcall(function()
        return isfile and isfile(fileName)
    end)
    
    if success and exists then
        return getcustomasset(fileName)
    end
    
    -- Download new image if not exists
    local response = request({Url = rawUrl, Method = "GET"})
    if response.StatusCode ~= 200 then return nil end
    
    writefile(fileName, response.Body)
    return getcustomasset(fileName)
end

local matchBadge = ImageLoader("https://github.com/Francisco1692qzd/Endless-Doors-Remake/blob/main/MatchBadge.png?raw=true")
local reboundBadge = ImageLoader("https://github.com/Francisco1692qzd/Endless-Doors-Remake/blob/main/cookiemonster.png?raw=true")
local claimBadge = ImageLoader("https://github.com/Francisco1692qzd/Endless-Doors-Remake/blob/main/InSight.png?raw=true")
local greedBadge = ImageLoader("https://github.com/Francisco1692qzd/Endless-Doors-Remake/blob/main/GreedBadge1.png?raw=true")
local overSeerBadge = ImageLoader("https://github.com/Francisco1692qzd/Endless-Doors-Remake/blob/main/OverseerBadge.png?raw=true")
local philFace = ImageLoader("https://github.com/Francisco1692qzd/Endless-Doors-Remake/blob/main/Untitled241_20230322155244.png?raw=true")
local philBadge = ImageLoader("https://github.com/Francisco1692qzd/Endless-Doors-Remake/blob/main/PhilStone.png?raw=true")

dataModule["Matcher"] = {
	GetInfo = function()
		return {
			Title = "No match for me!",
			Desc = "Encounter Matcher.",
			Reason = " ",
			Image = matchBadge
		}
	end
}

dataModule["Rebound"] = {
	GetInfo = function()
		return {
			Title = "I always come back.",
			Desc = "Encounter Rebound.",
			Reason = " ",
			Image = reboundBadge
		}
	end
}

dataModule["Claim"] = {
	GetInfo = function()
		return {
			Title = "In Sight.",
			Desc = "Encounter Claim.",
			Reason = " ",
			Image = claimBadge
		}
	end
}

dataModule["Greed"] = {
	GetInfo = function()
		return {
			Title = "Too Greedy.",
			Desc = "Die to Greed",
			Reason = " ",
			Image = greedBadge
		}
	end
}

dataModule["Phil"] = {
	GetInfo = function()
		return {
			Title = "I can't see anything!",
			Desc = "Encounter Phil.",
			Reason = " ",
			Image = philBadge
		}
	end
}
	--unlockFunc(nil, "Idiot")
print("Achievements Created Successfully")
