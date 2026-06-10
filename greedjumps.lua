    -- UI Construction

    local JumpscareGui = Instance.new("ScreenGui")
    local Background = Instance.new("Frame")
    local Face = Instance.new("ImageLabel")

    JumpscareGui.Name = "JumpscareGui"
    JumpscareGui.IgnoreGuiInset = true
    JumpscareGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    JumpscareGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    Background.Name = "Background"
    Background.BackgroundColor3 = Color3.fromRGB(77, 5, 99)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.ZIndex = 999

    Face.Name = "Face"
    Face.AnchorPoint = Vector2.new(0.5, 0.5)
    Face.BackgroundTransparency = 1
    Face.Position = UDim2.new(0.5, 0, 0.5, 0)
    Face.ResampleMode = Enum.ResamplerMode.Pixelated
    Face.Size = UDim2.new(0, 150, 0, 150)
    Face.Image = "rbxassetid://10914796550"

    Background.Parent = JumpscareGui
    Face.Parent = Background
local scare = Instance.new("Sound")
scare.Parent = JumpscareGui
scare.Name = "MyEarsBurn"
scare.SoundId = "rbxassetid://6150329916"
scare.Volume = 5

local distort = Instance.new("DistortionSoundEffect")
distort.Parent = scare
distort.Level = 0.75
    
        task.spawn(function()
            while JumpscareGui.Parent do
                Background.BackgroundColor3 = Color3.fromRGB(77, 5, 99)
                task.wait(math.random(25, 100) / 1000)
                Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                task.wait(math.random(25, 100) / 1000)
            end
        end)

    game.TweenService:Create(Face, TweenInfo.new(0.7), {Size = UDim2.new(0, 2450, 0, 1550), ImageTransparency = 0}):Play()
    scare:Play()
    task.wait(0.8)
    JumpscareGui:Destroy()
    
