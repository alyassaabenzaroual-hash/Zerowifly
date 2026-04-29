-- Mobile GUI with Open/Close (GitHub Ready)
-- By: [Your Name]

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

-- Settings
local settings = {
    spinning = false,
    aimbotEnabled = false,
    espEnabled = false,
    fovRadius = 200,
    smoothness = 6,
    prediction = 0.15,
    guiVisible = true
}

-- Variables
local spinConnection = nil
local aimbotConnection = nil
local espObjects = {}
local screenCenter = nil
local fovCircle = nil
local gui = nil

-- Get Screen Center
local function updateScreenCenter()
    screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end
updateScreenCenter()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScreenCenter)

-- FOV Circle
local function createFOVCircle()
    if fovCircle then fovCircle:Destroy() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Radius = settings.fovRadius
    fovCircle.Color = Color3.fromRGB(255, 100, 100)
    fovCircle.Thickness = 3
    fovCircle.NumSides = 60
    fovCircle.Transparency = 0.5
    fovCircle.Filled = false
    fovCircle.Position = screenCenter or Vector2.new(200, 400)
    
    runService.RenderStepped:Connect(function()
        if fovCircle and fovCircle.Visible and screenCenter then
            fovCircle.Position = screenCenter
        end
    end)
end
createFOVCircle()

-- WallCheck
local function canSee(targetPart)
    if not targetPart then return false end
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRay(ray, player.Character)
    
    if hit then
        local target = targetPart.Parent
        if target and (hit:IsDescendantOf(target) or target:IsDescendantOf(hit)) then
            return true
        end
    end
    return false
end

-- Get Closest Player to Screen Center
local function getClosestPlayerToCenter()
    if not screenCenter then return nil end
    
    local closest = nil
    local closestDistance = settings.fovRadius
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local head = otherPlayer.Character.Head
            local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
            
            if onScreen then
                local distance = (screenCenter - Vector2.new(screenPos.X, screenPos.Y)).magnitude
                
                if distance < closestDistance then
                    if canSee(head) then
                        closestDistance = distance
                        closest = otherPlayer
                    end
                end
            end
        end
    end
    
    return closest
end

-- Smooth Aimbot
local function smoothAimbot(target)
    if not target or not target.Character or not target.Character:FindFirstChild("Head") then
        return
    end
    
    local targetHead = target.Character.Head
    local targetVelocity = target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Velocity or Vector3.zero
    local predictedPos = targetHead.Position + (targetVelocity * settings.prediction)
    
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, predictedPos)
    local newCFrame = currentCFrame:Lerp(targetCFrame, 1 / settings.smoothness)
    camera.CFrame = newCFrame
end

-- Aimbot Loop
local function startAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    
    aimbotConnection = runService.RenderStepped:Connect(function()
        if settings.aimbotEnabled then
            local target = getClosestPlayerToCenter()
            if target then
                smoothAimbot(target)
            end
        end
    end)
end

-- ESP Functions
local function cleanupESP()
    for _, esp in pairs(espObjects) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    espObjects = {}
end

local function updateESP()
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            if settings.espEnabled and otherPlayer.Character then
                local espBox = espObjects[otherPlayer]
                
                if not espBox or not espBox.Parent then
                    espBox = Instance.new("BoxHandleAdornment")
                    espBox.Name = "ESPBox"
                    espBox.Size = Vector3.new(4, 5.5, 1)
                    espBox.Color3 = Color3.fromRGB(255, 50, 50)
                    espBox.AlwaysOnTop = true
                    espBox.Transparency = 0.3
                    espObjects[otherPlayer] = espBox
                end
                
                espBox.Adornee = otherPlayer.Character
                espBox.Visible = true
            elseif espObjects[otherPlayer] then
                espObjects[otherPlayer].Visible = false
            end
        end
    end
end

-- Spin Function
local function startSpin()
    if spinConnection then spinConnection:Disconnect() end
    
    spinConnection = runService.RenderStepped:Connect(function()
        if settings.spinning and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(12), 0)
        end
    end)
end

-- GUI Functions
local function setGUIVisible(visible)
    settings.guiVisible = visible
    if gui then
        gui.Enabled = visible
    end
end

-- Create Mobile GUI
local function createMobileGUI()
    gui = Instance.new("ScreenGui")
    gui.Name = "MobileGUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = gui
    
    local mainCorners = Instance.new("UICorner")
    mainCorners.CornerRadius = UDim.new(0, 16)
    mainCorners.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    titleBar.Parent = mainFrame
    
    local titleCorners = Instance.new("UICorner")
    titleCorners.CornerRadius = UDim.new(0, 16)
    titleCorners.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0.7, 0, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "⚡ Mobile GUI"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 1, 0)
    closeBtn.Position = UDim2.new(1, -45, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = titleBar
    
    local closeCorners = Instance.new("UICorner")
    closeCorners.CornerRadius = UDim.new(0, 12)
    closeCorners.Parent = closeBtn
    
    -- Spin Button
    local spinBtn = Instance.new("TextButton")
    spinBtn.Size = UDim2.new(0.85, 0, 0, 45)
    spinBtn.Position = UDim2.new(0.075, 0, 0.14, 0)
    spinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    spinBtn.Text = "🌀 SPIN : OFF"
    spinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    spinBtn.Font = Enum.Font.GothamSemibold
    spinBtn.TextSize = 15
    spinBtn.Parent = mainFrame
    
    local spinCorners = Instance.new("UICorner")
    spinCorners.CornerRadius = UDim.new(0, 10)
    spinCorners.Parent = spinBtn
    
    -- Aimbot Button
    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(0.85, 0, 0, 45)
    aimBtn.Position = UDim2.new(0.075, 0, 0.28, 0)
    aimBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    aimBtn.Text = "🎯 AIMBOT : OFF"
    aimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimBtn.Font = Enum.Font.GothamSemibold
    aimBtn.TextSize = 15
    aimBtn.Parent = mainFrame
    
    local aimCorners = Instance.new("UICorner")
    aimCorners.CornerRadius = UDim.new(0, 10)
    aimCorners.Parent = aimBtn
    
    -- ESP Button
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(0.85, 0, 0, 45)
    espBtn.Position = UDim2.new(0.075, 0, 0.42, 0)
    espBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    espBtn.Text = "👁️ ESP : OFF"
    espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    espBtn.Font = Enum.Font.GothamSemibold
    espBtn.TextSize = 15
    espBtn.Parent = mainFrame
    
    local espCorners = Instance.new("UICorner")
    espCorners.CornerRadius = UDim.new(0, 10)
    espCorners.Parent = espBtn
    
    -- FOV Toggle Button
    local fovBtn = Instance.new("TextButton")
    fovBtn.Size = UDim2.new(0.4, 0, 0, 40)
    fovBtn.Position = UDim2.new(0.075, 0, 0.55, 0)
    fovBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    fovBtn.Text = "⭕ FOV"
    fovBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovBtn.Font = Enum.Font.GothamSemibold
    fovBtn.TextSize = 13
    fovBtn.Parent = mainFrame
    
    local fovCorners = Instance.new("UICorner")
    fovCorners.CornerRadius = UDim.new(0, 10)
    fovCorners.Parent = fovBtn
    
    -- FOV Value
    local fovValue = Instance.new("TextLabel")
    fovValue.Size = UDim2.new(0.35, 0, 0, 40)
    fovValue.Position = UDim2.new(0.55, 0, 0.55, 0)
    fovValue.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    fovValue.Text = tostring(settings.fovRadius)
    fovValue.TextColor3 = Color3.fromRGB(255, 200, 100)
    fovValue.Font = Enum.Font.GothamBold
    fovValue.TextSize = 14
    fovValue.Parent = mainFrame
    
    local fovValueCorners = Instance.new("UICorner")
    fovValueCorners.CornerRadius = UDim.new(0, 10)
    fovValueCorners.Parent = fovValue
    
    -- WalkSpeed Label
    local wsLabel = Instance.new("TextLabel")
    wsLabel.Size = UDim2.new(0.4, 0, 0, 20)
    wsLabel.Position = UDim2.new(0.075, 0, 0.66, 0)
    wsLabel.BackgroundTransparency = 1
    wsLabel.Text = "🏃 Speed: 16"
    wsLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    wsLabel.Font = Enum.Font.Gotham
    wsLabel.TextSize = 12
    wsLabel.TextXAlignment = Enum.TextXAlignment.Left
    wsLabel.Parent = mainFrame
    
    -- WalkSpeed Box
    local wsBox = Instance.new("TextBox")
    wsBox.Size = UDim2.new(0.4, 0, 0, 35)
    wsBox.Position = UDim2.new(0.075, 0, 0.71, 0)
    wsBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    wsBox.Text = "16"
    wsBox.PlaceholderText = "16-200"
    wsBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    wsBox.Font = Enum.Font.Gotham
    wsBox.TextSize = 14
    wsBox.Parent = mainFrame
    
    local wsCorners = Instance.new("UICorner")
    wsCorners.CornerRadius = UDim.new(0, 10)
    wsCorners.Parent = wsBox
    
    -- Toggle Button (always visible)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(1, -60, 0, 10)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    toggleBtn.Text = "⚡"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 24
    toggleBtn.Parent = gui
    
    local toggleCorners = Instance.new("UICorner")
    toggleCorners.CornerRadius = UDim.new(1, 0)
    toggleCorners.Parent = toggleBtn
    
    -- Button Functions
    local fovVisible = false
    
    spinBtn.MouseButton1Click:Connect(function()
        settings.spinning = not settings.spinning
        spinBtn.Text = settings.spinning and "🌀 SPIN : ON" or "🌀 SPIN : OFF"
        spinBtn.BackgroundColor3 = settings.spinning and Color3.fromRGB(80, 170, 80) or Color3.fromRGB(60, 60, 80)
        if settings.spinning then startSpin() elseif spinConnection then spinConnection:Disconnect() end
    end)
    
    aimBtn.MouseButton1Click:Connect(function()
        settings.aimbotEnabled = not settings.aimbotEnabled
        aimBtn.Text = settings.aimbotEnabled and "🎯 AIMBOT : ON" or "🎯 AIMBOT : OFF"
        aimBtn.BackgroundColor3 = settings.aimbotEnabled and Color3.fromRGB(80, 170, 80) or Color3.fromRGB(60, 60, 80)
        if settings.aimbotEnabled then startAimbot() end
    end)
    
    espBtn.MouseButton1Click:Connect(function()
        settings.espEnabled = not settings.espEnabled
        espBtn.Text = settings.espEnabled and "👁️ ESP : ON" or "👁️ ESP : OFF"
        espBtn.BackgroundColor3 = settings.espEnabled and Color3.fromRGB(80, 170, 80) or Color3.fromRGB(60, 60, 80)
        if not settings.espEnabled then cleanupESP() end
    end)
    
    fovBtn.MouseButton1Click:Connect(function()
        fovVisible = not fovVisible
        fovBtn.BackgroundColor3 = fovVisible and Color3.fromRGB(80, 170, 80) or Color3.fromRGB(60, 60, 80)
        if fovCircle then fovCircle.Visible = fovVisible end
    end)
    
    local function changeFOV(delta)
        local newVal = settings.fovRadius + delta
        if newVal >= 80 and newVal <= 350 then
            settings.fovRadius = newVal
            fovValue.Text = tostring(newVal)
            if fovCircle then fovCircle.Radius = newVal end
        end
    end
    
    fovValue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if input.Position.X < fovValue.AbsolutePosition.X + fovValue.AbsoluteSize.X / 2 then
                changeFOV(-10)
            else
                changeFOV(10)
            end
        end
    end)
    
    wsBox.FocusLost:Connect(function()
        local val = tonumber(wsBox.Text)
        if val and val >= 16 and val <= 200 then
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = val
                wsLabel.Text = "🏃 Speed: " .. val
            end
        else
            wsBox.Text = "16"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        setGUIVisible(false)
    end)
    
    toggleBtn.MouseButton1Click:Connect(function()
        setGUIVisible(not settings.guiVisible)
    end)
    
    return gui
end

-- ESP Loop
runService.RenderStepped:Connect(function()
    updateESP()
end)

-- Character Respawn Handler
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    
    local wsVal = 16
    if gui and gui:FindFirstChild("Frame") then
        local wsBox = gui.Frame:FindFirstChild("TextBox")
        if wsBox then wsVal = tonumber(wsBox.Text) or 16 end
    end
    
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = wsVal
    end
    
    if settings.spinning then startSpin() end
    if settings.espEnabled then updateESP() end
end)

-- Player Leave Cleanup
game.Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then
        espObjects[plr]:Destroy()
        espObjects[plr] = nil
    end
end)

-- Create GUI
createMobileGUI()
startAimbot()

print("✅ Mobile GUI Loaded from GitHub!")
print("📱 Click ⚡ button to open/close menu")
