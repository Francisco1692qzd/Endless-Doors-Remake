local G = getgenv()
local ReplicatedStorage = game.ReplicatedStorage

G.LoadGithubModel = function(url)
    if not (writefile and getcustomasset and request) then
        return nil
    end
    
    local function generateFileName(url)
        local hash = 0
        for i = 1, #url do
            hash = (hash * 31 + string.byte(url, i)) % 2^32
        end
        return "model_overseer_" .. tostring(hash) .. ".rbxm"
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

local function loadModel(id)
    local obj = nil
    local attempts = 0
    local maxAttempts = 20

    while obj == nil and attempts < maxAttempts do
        attempts = attempts + 1
        local success, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. id)
        end)

        if success and result and result[1] then
            obj = result[1]
        else
            task.wait(0.5)
        end
    end

    if not obj then
        warn("Failed to load model after 20 attempts.")
    end
    
    return obj
end

local Overseer = Instance.new("Model")
Overseer.Parent = workspace
Overseer.Name = "Overseer"

local v = game.Players.LocalPlayer
local enableDamage = true
local no = false
local crucifixActive = false

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
camShake:Start()

-- Get current room
local currentLoadedRoom = workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value]
local eyes = loadModel(12285389022)

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
if eyes then
    eyes.CFrame = targetCF + Vector3.new(0, 5, 0)
    eyes.Parent = Overseer
end

-- Parent sounds
damage1.Parent = Overseer
damage2.Parent = Overseer
damage3.Parent = Overseer
local soundList = {damage1, damage2, damage3}

-- Check if already dead
if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0 then
    no = true
end

-- Helper function to check if eyes are on screen
local function isOnScreen(position)
    if not position then return false end
    
    local vector, onScreen = camera:WorldToViewportPoint(position)
    
    if not onScreen then
        return false
    end
    
    local screenX = vector.X
    local screenY = vector.Y
    
    if type(screenX) ~= "number" or type(screenY) ~= "number" then
        return false
    end
    
    local viewportX = camera.ViewportSize.X
    local viewportY = camera.ViewportSize.Y
    
    if screenX >= -10 and screenX <= viewportX + 10 and screenY >= -10 and screenY <= viewportY + 10 then
        return true
    end
    
    return false
end

-- FORCED DAMAGE LOOP
task.spawn(function()
    while Overseer and enableDamage and not crucifixActive do
        task.wait(0.3)
        
        if not Overseer or not enableDamage or crucifixActive then break end
        
        if workspace:FindFirstChild("SeekMoving") or workspace:FindFirstChild("SeekMovingNewClone") or workspace.CurrentRooms:FindFirstChild("50") then
            continue
        end
        
        local character = v.Character
        if not character or not character:FindFirstChild("Humanoid") then
            continue
        end
        
        local humanoid = character.Humanoid
        local isHiding = character:GetAttribute("Hiding") or false
        
        if isHiding then
            continue
        end
        
        if not eyes or not eyes.Parent then
            continue
        end
        
        local lookingAtEyes = isOnScreen(eyes.Position)
        
        -- ONLY damage when NOT looking
        if not lookingAtEyes and humanoid.Health > 0 then
            camShake:ShakeOnce(5, 15, 0.1, 1)
            
            -- CRUCIFIX REPENTANCE LOGIC
            if character:FindFirstChild("Crucifix") and not crucifixActive then
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

                if eyes then
                    repentanceModel:PivotTo(eyes.CFrame * CFrame.new(0, -5, 0))
                end

                local crucifix = repentanceModel.Crucifix
                local soundFail = crucifix.SoundFail
                local sound = crucifix.Sound
                local light = crucifix.Light
                
                -- CRITICAL FIX: Set position FIRST while anchored
                local targetCFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 4, -3)
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
                
                local sufferSound = Instance.new("Sound", eyes)
                sufferSound.SoundId = "rbxassetid://1228230799"
                sufferSound.Volume = 2
                sufferSound.Name = "Suffer"
                sufferSound.PlaybackSpeed = 1.3
                sufferSound.Looped = true
                sufferSound:Play()
                
                local eq = Instance.new("EqualizerSoundEffect", sufferSound)
                eq.HighGain = 4
                eq.LowGain = 5.5
                eq.MidGain = 4
                
                local can = true
                
                if eyes then
                    for _, snd in pairs(eyes:GetDescendants()) do
                        if (snd:IsA("Sound") and snd.Name ~= "Suffer") then
                            snd:Stop()
                        end
                    end
                end
                
                if sound then sound:Play() end
                enableDamage = false
                camShake:ShakeOnce(1.8, 16, 0.2, 2.7, 1, 6)
                
                -- Make the entity follow the crucifix during repentance
                local followLoop = task.spawn(function()
                    while can and repentanceModel and repentanceModel.Entity do
                        task.wait()
                        if repentanceModel and repentanceModel.Entity and can and eyes then
                            eyes.CFrame = repentanceModel.Entity.CFrame
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

                camShake:ShakeOnce(1.8, 16, 0.2, 2.4, 1, 6)
                
                -- Lower the entity (still rotating)
                if repentanceModel and repentanceModel.Entity then
                    local entity = repentanceModel.Entity
                    local lowerTween = game.TweenService:Create(entity, TweenInfo.new(1.68, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        CFrame = entity.CFrame * CFrame.new(0, -12, 0)
                    })
                    lowerTween:Play()
                    
                    if bodyPosition then
                        local lowerPosTween = game.TweenService:Create(bodyPosition, TweenInfo.new(1.68, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                            Position = (entity.CFrame * CFrame.new(0, -12, 0)).Position
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
                enableDamage = true
                if Overseer then Overseer:Destroy() end
                can = false
                crucifixActive = false
                
                -- DO NOT remove the player's Crucifix - leave it alone!
                
                break
            end
            
            -- Regular damage (no crucifix)
            if not character:FindFirstChild("Crucifix") and not crucifixActive then
                humanoid.Health = humanoid.Health - 3
            end
            
            if no == false and not crucifixActive then
                pcall(function() soundList[math.random(#soundList)]:Play() end)
            end
            
            if humanoid.Health <= 0 and no == false then
                game.ReplicatedStorage.GameStats["Player_" .. v.Name].Total.DeathCause.Value = "Overseer Eyes"
                no = true
                
                task.spawn(function()
                    task.wait(0.5)
                    if firesignal then
                        firesignal(game.ReplicatedStorage.RemotesFolder.DeathHint.OnClientEvent, {
                            "You died to Overseer.",
                            "It strikes when you look away.",
                            "Keep staring at it to survive!"
                        }, "Yellow")
                    end
                end)
            end
        end
    end
end)

-- Force position update to make sure eyes are trackable
task.spawn(function()
    while Overseer and enableDamage and not crucifixActive do
        task.wait(2)
        if eyes and eyes.Parent then
            local currentPos = eyes.CFrame
            eyes.CFrame = currentPos + Vector3.new(0, 0.01, 0)
            task.wait(0.05)
            eyes.CFrame = currentPos
        end
    end
end)
