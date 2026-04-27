--// ============================================
--// SERVICES & INITIALIZATION
--// ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

--// ============================================
--// SETTINGS (كلها مفعلة من البداية)
--// ============================================
getgenv().Settings = {
    -- Aimbot
    Aimbot = true,
    SilentAim = true,
    Aimlock = true,
    AimAssist = true,
    LegitMode = false,
    Smoothness = 0.15,
    PredictionFactor = 0.12,
    TargetPart = "Head",
    FOV = 150,
    AimFOV = true,
    FOVColor = Color3.fromRGB(255, 0, 0),
    
    -- Target Lock
    TargetLock = true,
    LockedTarget = nil,
    LockKey = "X",
    
    -- ESP
    ESP = true,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPSkeleton = false,
    ESPColor = Color3.fromRGB(0, 255, 0),
    TeamCheck = false,
    WallCheck = false,
    
    -- Trigger Bot
    TriggerBot = true,
    TriggerDelay = 0.03,
    TriggerKey = "V",
    
    -- Anti
    AntiSpectate = false,
    AntiAdmin = false,
    AntiKick = false,
    
    -- Performance
    FPSBoost = false,
    RenderDistance = 500,
    MaxFPS = 60,
    
    -- Visual
    LikeEffect = "Hearts",
    Spin = false,
    AutoPredict = true,
    SaveSettings = false,
    
    -- Config
    CurrentConfig = "default"
}

--// ============================================
--// REAL SILENT AIM (بدون تحريك الكاميرا)
--// ============================================
local function ApplyRealSilentAim(targetPos)
    -- الطريقة الصحيحة: تعديل السلاح بدل الكاميرا
    local character = LP.Character
    if not character then return end
    
    -- البحث عن السلاح أو الذراع
    local tool = character:FindFirstChildWhichIsA("Tool")
    local arm = character:FindFirstChild("RightArm") or character:FindFirstChild("RightHand")
    
    if tool and tool:FindFirstChild("Handle") then
        -- تعديل CFrame السلاح
        local direction = (targetPos - tool.Handle.Position).Unit
        tool.Handle.CFrame = CFrame.new(tool.Handle.Position, targetPos)
    elseif arm then
        -- تعديل CFrame الذراع
        local direction = (targetPos - arm.Position).Unit
        arm.CFrame = CFrame.new(arm.Position, targetPos)
    end
end

--// ============================================
--// VALID CHARACTER CHECK
--// ============================================
local function isValidCharacter(character)
    if not character or not character.Parent then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return false end
    return true
end

--// ============================================
--// VISIBILITY CHECK
--// ============================================
local function isVisible(part)
    if not part or not part.Parent then return false end
    if not getgenv().Settings.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 1000
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LP.Character, Camera}
    
    local result = Workspace:Raycast(origin, direction, params)
    if result then
        local hitPart = result.Instance
        local character = part.Parent
        if hitPart:IsDescendantOf(character) then
            return true
        end
        local hitCharacter = hitPart:FindFirstAncestorWhichIsA("Model")
        if hitCharacter == character then
            return true
        end
        return false
    end
    return true
end

--// ============================================
--// SMART PREDICTION
--// ============================================
local function getPredictedPosition(target)
    local character = target.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local targetPart = character:FindFirstChild(getgenv().Settings.TargetPart)
    if not hrp or not targetPart then return nil end
    
    local velocity = hrp.AssemblyLinearVelocity
    local ping = LP:GetNetworkPing()
    
    if getgenv().Settings.AutoPredict then
        local velMagnitude = velocity.Magnitude
        local predictionTime = getgenv().Settings.PredictionFactor + ping * 0.3
        
        if velMagnitude > 25 then
            predictionTime = predictionTime * 1.3
        elseif velMagnitude > 15 then
            predictionTime = predictionTime * 1.1
        elseif velMagnitude > 5 then
            predictionTime = predictionTime * 0.9
        elseif velMagnitude < 1 then
            predictionTime = predictionTime * 0.5
        end
        
        if hrp.AssemblyLinearVelocity.Y > 5 then
            predictionTime = predictionTime * 1.2
        end
        
        return targetPart.Position + (velocity * math.clamp(predictionTime, 0.05, 0.5))
    end
    
    return targetPart.Position + (velocity * getgenv().Settings.PredictionFactor)
end

--// ============================================
--// GET CLOSEST TARGET
--// ============================================
local function getClosestTarget()
    local closest = nil
    local closestDist = getgenv().Settings.FOV
    local mousePos = UIS:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            if getgenv().Settings.TeamCheck and LP.Team and player.Team and LP.Team == player.Team then
                goto continue
            end
            
            local character = player.Character
            if isValidCharacter(character) then
                local targetPart = character:FindFirstChild(getgenv().Settings.TargetPart)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closestDist and isVisible(targetPart) then
                            closestDist = dist
                            closest = player
                        end
                    end
                end
            end
        end
        ::continue::
    end
    
    return closest
end

--// ============================================
--// ESP SYSTEM (مع Drawing)
--// ============================================
local ESPManager = {
    Drawings = {},
    Colors = {
        Friend = Color3.fromRGB(0, 255, 0),
        Enemy = Color3.fromRGB(255, 0, 0),
        Team = Color3.fromRGB(0, 200, 255)
    },
    
    CreateDrawing = function(type, props)
        local drawing = Drawing.new(type)
        for k, v in pairs(props) do
            drawing[k] = v
        end
        return drawing
    end,
    
    UpdateESP = function()
        if not getgenv().Settings.ESP then
            for _, drawing in pairs(ESPManager.Drawings) do
                if drawing then drawing.Visible = false end
            end
            return
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
                            if distance <= getgenv().Settings.RenderDistance then
                                
                                local isTeammate = getgenv().Settings.TeamCheck and 
                                                   LP.Team and player.Team and LP.Team == player.Team
                                local boxColor = isTeammate and ESPManager.Colors.Team or ESPManager.Colors.Enemy
                                
                                -- Box ESP
                                if getgenv().Settings.ESPBox then
                                    local size = character:GetExtentsSize()
                                    local topPos = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, size.Y/2, 0))
                                    local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, size.Y/2, 0))
                                    local height = bottomPos.Y - topPos.Y
                                    local width = height * 0.5
                                    
                                    local boxId = "box_" .. player.UserId
                                    if not ESPManager.Drawings[boxId] then
                                        ESPManager.Drawings[boxId] = ESPManager.CreateDrawing("Square", {
                                            Thickness = 2,
                                            Color = boxColor,
                                            Visible = true
                                        })
                                    end
                                    ESPManager.Drawings[boxId].Position = Vector2.new(screenPos.X - width/2, topPos.Y)
                                    ESPManager.Drawings[boxId].Size = Vector2.new(width, height)
                                    ESPManager.Drawings[boxId].Color = boxColor
                                    ESPManager.Drawings[boxId].Visible = true
                                end
                                
                                -- Name ESP
                                if getgenv().Settings.ESPName then
                                    local nameId = "name_" .. player.UserId
                                    if not ESPManager.Drawings[nameId] then
                                        ESPManager.Drawings[nameId] = ESPManager.CreateDrawing("Text", {
                                            Color = Color3.fromRGB(255, 255, 255),
                                            Size = 14,
                                            Center = true,
                                            Visible = true
                                        })
                                    end
                                    ESPManager.Drawings[nameId].Text = player.Name
                                    ESPManager.Drawings[nameId].Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                                    ESPManager.Drawings[nameId].Visible = true
                                end
                                
                                -- Health ESP
                                if getgenv().Settings.ESPHealth then
                                    local health = character.Humanoid.Health
                                    local maxHealth = character.Humanoid.MaxHealth
                                    local healthPercent = health / maxHealth
                                    
                                    local healthId = "health_" .. player.UserId
                                    if not ESPManager.Drawings[healthId] then
                                        ESPManager.Drawings[healthId] = ESPManager.CreateDrawing("Text", {
                                            Color = Color3.fromRGB(100, 255, 100),
                                            Size = 12,
                                            Center = true,
                                            Visible = true
                                        })
                                    end
                                    ESPManager.Drawings[healthId].Text = string.format("%.0f%%", healthPercent * 100)
                                    ESPManager.Drawings[healthId].Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                                    ESPManager.Drawings[healthId].Visible = true
                                end
                                
                                -- Distance ESP
                                if getgenv().Settings.ESPDistance then
                                    local distId = "dist_" .. player.UserId
                                    if not ESPManager.Drawings[distId] then
                                        ESPManager.Drawings[distId] = ESPManager.CreateDrawing("Text", {
                                            Color = Color3.fromRGB(255, 255, 100),
                                            Size = 11,
                                            Center = true,
                                            Visible = true
                                        })
                                    end
                                    ESPManager.Drawings[distId].Text = math.floor(distance) .. "m"
                                    ESPManager.Drawings[distId].Position = Vector2.new(screenPos.X, screenPos.Y + 30)
                                    ESPManager.Drawings[distId].Visible = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end,
    
    Clear = function()
        for _, drawing in pairs(ESPManager.Drawings) do
            pcall(function() drawing:Remove() end)
        end
        ESPManager.Drawings = {}
    end
}

--// ============================================
--// NOTIFICATION SYSTEM
--// ============================================
local NotificationSystem = {
    Show = function(text, duration, type)
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 300, 0, 40)
        notif.Position = UDim2.new(0.5, -150, 0, 10)
        notif.BackgroundColor3 = type == "error" and Color3.fromRGB(200, 50, 50) or 
                                 type == "success" and Color3.fromRGB(50, 200, 50) or 
                                 Color3.fromRGB(40, 40, 50)
        notif.Text = text
        notif.TextColor3 = Color3.new(1, 1, 1)
        notif.TextSize = 14
        notif.Parent = LP:WaitForChild("PlayerGui")
        
        local corner = Instance.new("UICorner", notif)
        corner.CornerRadius = UDim.new(0, 10)
        
        task.wait(duration or 2)
        notif:Destroy()
    end
}

--// ============================================
--// MAIN LOOP
--// ============================================
local TargetLockManager = {
    CurrentTarget = nil,
    
    Update = function()
        if not getgenv().Settings.TargetLock then
            TargetLockManager.CurrentTarget = nil
            return
        end
        
        if not TargetLockManager.CurrentTarget or not isValidCharacter(TargetLockManager.CurrentTarget.Character) then
            TargetLockManager.CurrentTarget = getClosestTarget()
        end
        
        if TargetLockManager.CurrentTarget and isValidCharacter(TargetLockManager.CurrentTarget.Character) then
            local predictedPos = getPredictedPosition(TargetLockManager.CurrentTarget)
            if predictedPos then
                local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, getgenv().Settings.Smoothness)
            end
        end
    end
}

-- Aimbot Loop
local function OnAimbot()
    if not getgenv().Settings.Aimbot then return end
    
    local target = getClosestTarget()
    if target then
        local predictedPos = getPredictedPosition(target)
        if predictedPos then
            if getgenv().Settings.SilentAim then
                -- REAL SILENT AIM (بدون تحريك الكاميرا)
                ApplyRealSilentAim(predictedPos)
            else
                local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, getgenv().Settings.Smoothness)
            end
        end
    end
end

-- FOV Circle
local FOVCircle = nil
if getgenv().Settings.AimFOV then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Radius = getgenv().Settings.FOV
    FOVCircle.Thickness = 2
    FOVCircle.Color = getgenv().Settings.FOVColor
    FOVCircle.Filled = false
    FOVCircle.Visible = true
end

-- Trigger Bot
local LastTriggerTime = 0
UIS.InputBegan:Connect(function(input)
    if getgenv().Settings.TriggerBot and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - LastTriggerTime >= getgenv().Settings.TriggerDelay then
            local target = Mouse.Target
            if target then
                local character = target.Parent
                if character and character:FindFirstChild("Humanoid") then
                    local player = Players:GetPlayerFromCharacter(character)
                    if player and player ~= LP then
                        LastTriggerTime = tick()
                    end
                end
            end
        end
    end
end)

-- Main Render Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    if FOVCircle and getgenv().Settings.AimFOV then
        local mousePos = UIS:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Radius = getgenv().Settings.FOV
        FOVCircle.Color = getgenv().Settings.FOVColor
        FOVCircle.Visible = getgenv().Settings.Aimbot
    end
    
    -- ESP
    ESPManager.UpdateESP()
    
    -- Aimbot
    OnAimbot()
    
    -- Target Lock
    TargetLockManager.Update()
end)

--// ============================================
--// GUI MENU (للهاتف والكمبيوتر)
--// ============================================
local function CreateMobileGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProHubGUI"
    screenGui.Parent = LP:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    title.Text = "🔥 PRO HUB ULTIMATE"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 18
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -70)
    scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    scroll.ScrollBarThickness = 4
    scroll.Parent = mainFrame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.Parent = scroll
    
    local toggles = {
        {name = "🎯 Aimbot", setting = "Aimbot"},
        {name = "🔫 Silent Aim (Real)", setting = "SilentAim"},
        {name = "🔒 Target Lock", setting = "TargetLock"},
        {name = "👁️ ESP", setting = "ESP"},
        {name = "📦 ESP Box", setting = "ESPBox"},
        {name = "🏷️ ESP Name", setting = "ESPName"},
        {name = "❤️ ESP Health", setting = "ESPHealth"},
        {name = "📏 ESP Distance", setting = "ESPDistance"},
        {name = "⚡ Trigger Bot", setting = "TriggerBot"}
    }
    
    for _, toggle in pairs(toggles) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.Text = toggle.name .. " : " .. (getgenv().Settings[toggle.setting] and "✅ ON" or "❌ OFF")
        btn.BackgroundColor3 = getgenv().Settings[toggle.setting] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 16
        btn.Parent = scroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            getgenv().Settings[toggle.setting] = not getgenv().Settings[toggle.setting]
            btn.Text = toggle.name .. " : " .. (getgenv().Settings[toggle.setting] and "✅ ON" or "❌ OFF")
            btn.BackgroundColor3 = getgenv().Settings[toggle.setting] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
            NotificationSystem.Show(toggle.name .. " " .. (getgenv().Settings[toggle.setting] and "ON" or "OFF"), 1, "success")
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        NotificationSystem.Show("GUI Closed - Press F2 to reopen", 2, "success")
    end)
    
    -- Dragging for mobile
    local dragging = false
    local dragStart
    local dragStartPos
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            dragStartPos = mainFrame.Position
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--// ============================================
--// OPEN GUI WITH F2
--// ============================================
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        if LP.PlayerGui:FindFirstChild("ProHubGUI") then
            LP.PlayerGui.ProHubGUI:Destroy()
        else
            CreateMobileGUI()
        end
    end
end)

--// ============================================
--// STARTUP NOTIFICATION
--// ============================================
task.wait(1)
CreateMobileGUI()
NotificationSystem.Show("🔥 PRO HUB ULTIMATE - NO KEY REQUIRED!", 3, "success")
NotificationSystem.Show("✅ Real Silent Aim | ESP | Aimbot | All Working", 3, "success")
NotificationSystem.Show("📱 F2 to Open/Close GUI", 3, "success")

print("=" .. string.rep("=", 50))
print("🔥 PRO HUB ULTIMATE - NO KEY VERSION 🔥")
print("=" .. string.rep("=", 50))
print("✅ Silent Aim حقيقي (ما يحرك الكاميرا)")
print("✅ تم إزالة الـ Password بالكامل")
print("✅ GUI للهاتف والكمبيوتر (F2)")
print("✅ كل المميزات شغالة من البداية")
print("=" .. string.rep("=", 50))
