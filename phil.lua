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

-- Create Phil part
local Phil = Instance.new("Part")
Phil.Anchored = true
Phil.CanCollide = false
Phil.Parent = workspace
Phil.Transparency = 1

-- Load face
local face = game:GetObjects("rbxassetid://10736929559")[1]
face.Parent = Phil
face.ImageLabel.Image = ImageLoader("https://github.com/check78/entity-images/blob/main/Untitled241_20230322155244.png?raw=true")

local currentLoadedRoom = workspace.CurrentRooms[game:GetService("ReplicatedStorage").GameData.LatestRoom.Value]

-- Position Phil
local num = 0
if currentLoadedRoom:FindFirstChild("Nodes") then
    num = math.floor(#currentLoadedRoom.Nodes:GetChildren() / 2)
end

Phil.CFrame = (num == 0 and currentLoadedRoom[currentLoadedRoom.Name] or currentLoadedRoom.Nodes[num]).CFrame + Vector3.new(0, 5, 0)

wait(1)

-- Shatter the room
local ModuleEvents = require(game:GetService("ReplicatedStorage").ModulesClient.Module_Events)
ModuleEvents.shatter(workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value])

-- Teleport Phil away
Phil.CFrame = CFrame.new(0, 0, 35000)

-- Camera shake setup
local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
local camera = workspace.CurrentCamera
local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
    camera.CFrame = camera.CFrame * shakeCf
end)

camShake:Start()
camShake:ShakeOnce(100, 50, 0.5, 0.5)

-- Break sounds
local roast = Instance.new("Sound")
roast.Parent = workspace
roast.Name = "Break2"
roast.SoundId = "rbxassetid://6737582037"
roast.Volume = 1

local roast1 = Instance.new("Sound")
roast1.Parent = workspace
roast1.Name = "Break1"
roast1.SoundId = "rbxassetid://9103909576"
roast1.Volume = 1

local roast2 = Instance.new("Sound")
roast2.Parent = workspace
roast2.Name = "Break2"
roast2.SoundId = "rbxassetid://5961220911"
roast2.Volume = 1

roast2:Play()
roast1:Play()
roast:Play()

-- Darken all lights
local tweenInfo = TweenInfo.new(0.5)
local darkColor = {Color = Color3.new(0, 0, 0)}
local currentRoom = workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]

for i, v in pairs(currentRoom:GetDescendants()) do
    if v:IsA("Light") then
        game.TweenService:Create(v, tweenInfo, darkColor):Play()
        if v.Parent and v.Parent.Name == "LightFixture" then
            game.TweenService:Create(v.Parent, tweenInfo, darkColor):Play()
        end
    end
end

-- Destroy rug
local rug = workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Assets.Rug
if rug then rug:Destroy() end

local roomValue = game.ReplicatedStorage.GameData.LatestRoom.Value

-- Darken walls
for i, v in pairs(workspace.CurrentRooms[roomValue].Parts:GetChildren()) do
    if v.Name == "Wall" then
        v.Material = "Limestone"
        v.Color = Color3.new(0, 0, 0)
        if v:FindFirstChild("Wallpaper") then
            v.Wallpaper:Destroy()
        end
    end
end

-- Darken drop ceiling children
for i, v in pairs(workspace.CurrentRooms[roomValue].Parts.DropCeiling:GetChildren()) do
    if v.Name == "Ceiling" then
        v.Material = "Limestone"
        v.Color = Color3.new(0, 0, 0)
    end
end

-- Darken drop ceiling model
for i, v in pairs(workspace.CurrentRooms[roomValue].Parts.DropCeiling.Model:GetChildren()) do
    v.Material = "Limestone"
    v.Color = Color3.new(0, 0, 0)
end

-- Darken all base parts if room is before 90
if roomValue < 90 then
    for i, v in pairs(workspace.CurrentRooms[roomValue].Parts:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Limestone
            v.Color = Color3.new(0, 0, 0)
        end
    end
end
