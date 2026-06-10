    -- UI Construction

    local G = getgenv()
    
G.LoadGithubModel = function(url)
    if not (writefile and getcustomasset and request) then
        return nil
    end
    
    -- Generate a consistent filename based on the URL
    local function generateFileName(url)
        -- Create a simple hash from the URL
        local hash = 0
        for i = 1, #url do
            hash = (hash * 31 + string.byte(url, i)) % 2^32
        end
        return "reboundff_" .. tostring(hash) .. ".rbxm"
    end
    
    local fileName = generateFileName(url)
    
    -- Check if file already exists
    local fileExists = false
    local success, exists = pcall(function()
        return isfile and isfile(fileName)
    end)
    
    if success and exists then
        fileExists = true
        -- Try to load existing model first
        local assetId = getcustomasset(fileName)
        local loadSuccess, result = pcall(function()
            return game:GetObjects(assetId)[1]
        end)
        
        if loadSuccess and result then
            return result
        end
    end
    
    -- If file doesn't exist or loading failed, download new one
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
    
    local JumpscareGui = Instance.new("ScreenGui")
    local Background = Instance.new("Frame")
    local Face = Instance.new("ImageLabel")

    JumpscareGui.Name = "JumpscareGui"
    JumpscareGui.IgnoreGuiInset = true
    JumpscareGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    JumpscareGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    Background.Name = "Background"
    Background.BackgroundColor3 = Color3.fromRGB(3, 25, 99)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.ZIndex = 999

    Face.Name = "Face"
    Face.AnchorPoint = Vector2.new(0.5, 0.5)
    Face.BackgroundTransparency = 1
    Face.Position = UDim2.new(0.5, 0, 0.5, 0)
    Face.ResampleMode = Enum.ResamplerMode.Pixelated
    Face.Size = UDim2.new(0, 150, 0, 150)
    Face.Image = "rbxassetid://10914800940"

    Background.Parent = JumpscareGui
    Face.Parent = Background
    local lowkey = G.LoadGithubAudio("https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/JumpscareReb.mp3")
local scare = Instance.new("Sound")
scare.Parent = JumpscareGui
scare.Name = "MyEarsBurn"
scare.SoundId = lowkey
scare.PlaybackSpeed = 1
scare.Volume = 3

--[[local shift = Instance.new("PitchShiftSoundEffect")
shift.Octave = 0.5
--shift.Parent = scare

local distort = Instance.new("DistortionSoundEffect")
distort.Parent = scare
distort.Level = 0.75

local eq = Instance.new("EqualizerSoundEffect")
eq.HighGain = 10
eq.MidGain = 10
eq.LowGain = 3.7
eq.Parent = scare--]]
    
        task.spawn(function()
            while JumpscareGui.Parent do
                Background.BackgroundColor3 = Color3.fromRGB(3, 25, 99)
                task.wait(math.random(25, 100) / 1000)
                Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                task.wait(math.random(25, 100) / 1000)
            end
        end)

    game.TweenService:Create(Face, TweenInfo.new(0.6), {Size = UDim2.new(0, 1850, 0, 1050), ImageTransparency = 0}):Play()
    scare:Play()
    task.wait(0.7)
    JumpscareGui:Destroy()
    
