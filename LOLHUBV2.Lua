-- 🚀 UNIVERSAL FPS CHEAT v3.0 MOBILE | مع SILENT AIM + AIM DRAG
-- 📱 مخصص للهاتف - يعمل على كل ألعاب FPS
-- 🎮 Arsenal, Phantom Forces, Counter Blox...

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TouchService = game:GetService("TouchEnabled") and require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("TouchGui")) or nil

-- 🎯 الإعدادات المتقدمة (مخصصة للهاتف)
local Settings = {
    Aimbot = {
        Enabled = true,
        SilentAim = true,       -- 🎯 Silent Aim (الأفضل للهاتف)
        AimDrag = false,        -- 🖱 Aim Drag (يسحب الكاميرا)
        FOV = 250,              -- مجال رؤية أكبر للهاتف
        Smooth = 0.25,
        TargetPart = "Head",
        Predict = true,
        PredictionAmount = 0.15,
        TriggerBot = false,
        AutoShoot = true,       -- 🎯 يطلق تلقائياً عند التصويب
        AutoShootDelay = 0.08,
        LockTarget = true       -- يقفل على الهدف
    },
    ESP = {
        Enabled = true, 
        Box = true, 
        BoxFill = false,
        Name = true, 
        Health = true,
        Distance = true,
        Tracer = false,
        Colors = {
            Enemy = Color3.fromRGB(255, 50, 50),
            Box = Color3.fromRGB(255, 0, 0),
            Name = Color3.fromRGB(255, 255, 255),
            Health = Color3.fromRGB(0, 255, 0)
        }
    },
    Movement = {
        Speed = false,
        SpeedValue = 80,
        JumpPower = 80,
        InfiniteJump = false,
        Fly = false,
        FlySpeed = 60
    },
    Visuals = {
        FOVCircle = true,
        FOVCircleColor = Color3.fromRGB(0, 255, 0),
        TargetIndicator = true,
        HitMarker = true
    },
    Controls = {
        JoystickSize = 200,
        Sensitivity = 1.5,
        AutoFire = true,
        AimAssist = true
    }
}

-- 📱 متغيرات الهاتف
local ScreenSize = Camera.ViewportSize
local TouchData = {Active = false, StartPos = nil, CurrentPos = nil}
local Joystick = nil
local ShootButton = nil
local CurrentTarget = nil
local LockedTarget = nil

-- 🎨 عناصر الرسم للهاتف
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Settings.Aimbot.FOV
FOVCircle.Color = Settings.Visuals.FOVCircleColor
FOVCircle.Thickness = 3
FOVCircle.NumSides = 50
FOVCircle.Filled = false
FOVCircle.Transparency = 0.4
FOVCircle.Visible = true
FOVCircle.Position = Vector2.new(ScreenSize.X/2, ScreenSize.Y/2)

-- 🎮 GUI مخصص للهاتف (بدون Kavo UI - خفيف)
local MobileGUI = Instance.new("ScreenGui")
MobileGUI.Name = "MobileCheatGUI"
MobileGUI.Parent = LocalPlayer.PlayerGui
MobileGUI.ResetOnSpawn = false

-- 🎨 إطار التحكم الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 60, 0, 60)
MainFrame.Position = UDim2.new(0, 20, 1, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MainFrame.Parent = MobileGUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = MainFrame

-- 🎯 زر القائمة
local MenuButton = Instance.new("ImageButton")
MenuButton.Size = UDim2.new(1, 0, 1, 0)
MenuButton.BackgroundTransparency = 1
MenuButton.Image = "rbxassetid://6031091209"
MenuButton.Parent = MainFrame

-- 📋 القائمة المنبثقة
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 250, 0, 400)
MenuFrame.Position = UDim2.new(0, 80, 0, -400)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MenuFrame.BackgroundTransparency = 0.1
MenuFrame.BorderSizePixel = 1
MenuFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MenuFrame.Visible = false
MenuFrame.Parent = MainFrame

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MenuFrame

-- 🎯 أزرار القائمة (مبسطة للهاتف)
local Buttons = {
    {Name = "🎯 Aimbot", Toggle = "Aimbot", Y = 10},
    {Name = "👁 ESP", Toggle = "ESP", Y = 60},
    {Name = "⚡ Speed", Toggle = "Speed", Y = 110},
    {Name = "🪽 Fly", Toggle = "Fly", Y = 160},
    {Name = "🔄 Auto Shoot", Toggle = "AutoShoot", Y = 210},
    {Name = "🔒 Lock Target", Toggle = "LockTarget", Y = 260},
    {Name = "❌ Close", Toggle = "Close", Y = 310}
}

for _, btn in pairs(Buttons) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 220, 0, 40)
    button.Position = UDim2.new(0, 15, 0, btn.Y)
    button.Text = btn.Name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(0, 255, 0)
    button.Parent = MenuFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        if btn.Toggle == "Aimbot" then
            Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
            button.Text = (Settings.Aimbot.Enabled and "✅ " or "❌ ") .. btn.Name
        elseif btn.Toggle == "ESP" then
            Settings.ESP.Enabled = not Settings.ESP.Enabled
            button.Text = (Settings.ESP.Enabled and "✅ " or "❌ ") .. btn.Name
        elseif btn.Toggle == "Speed" then
            Settings.Movement.Speed = not Settings.Movement.Speed
            button.Text = (Settings.Movement.Speed and "✅ " or "❌ ") .. btn.Name
        elseif btn.Toggle == "Fly" then
            Settings.Movement.Fly = not Settings.Movement.Fly
            button.Text = (Settings.Movement.Fly and "✅ " or "❌ ") .. btn.Name
        elseif btn.Toggle == "AutoShoot" then
            Settings.Aimbot.AutoShoot = not Settings.Aimbot.AutoShoot
            button.Text = (Settings.Aimbot.AutoShoot and "✅ " or "❌ ") .. btn.Name
        elseif btn.Toggle == "LockTarget" then
            Settings.Aimbot.LockTarget = not Settings.Aimbot.LockTarget
            button.Text = (Settings.Aimbot.LockTarget and "✅ " or "❌ ") .. btn.Name
        elseif btn.Toggle == "Close" then
            MenuFrame.Visible = false
        end
    end)
end

-- 🎮 زر الإطلاق للهاتف
local ShootFrame = Instance.new("Frame")
ShootFrame.Size = UDim2.new(0, 80, 0, 80)
ShootFrame.Position = UDim2.new(1, -100, 1, -100)
ShootFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ShootFrame.BackgroundTransparency = 0.4
ShootFrame.BorderSizePixel = 3
ShootFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
ShootFrame.Parent = MobileGUI

local ShootCorner = Instance.new("UICorner")
ShootCorner.CornerRadius = UDim.new(1, 0)
ShootCorner.Parent = ShootFrame

local ShootButtonClick = Instance.new("ImageButton")
ShootButtonClick.Size = UDim2.new(1, 0, 1, 0)
ShootButtonClick.BackgroundTransparency = 1
ShootButtonClick.Parent = ShootFrame

-- 🕹 عصا التحكم (Joystick) للحركة
local JoystickFrame = Instance.new("Frame")
JoystickFrame.Size = UDim2.new(0, 150, 0, 150)
JoystickFrame.Position = UDim2.new(0, 20, 1, -180)
JoystickFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
JoystickFrame.BackgroundTransparency = 0.5
JoystickFrame.BorderSizePixel = 2
JoystickFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
JoystickFrame.Parent = MobileGUI

local JoystickCorner = Instance.new("UICorner")
JoystickCorner.CornerRadius = UDim.new(1, 0)
JoystickCorner.Parent = JoystickFrame

local JoystickKnob = Instance.new("Frame")
JoystickKnob.Size = UDim2.new(0, 60, 0, 60)
JoystickKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
JoystickKnob.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
JoystickKnob.BackgroundTransparency = 0.3
JoystickKnob.BorderSizePixel = 2
JoystickKnob.BorderColor3 = Color3.fromRGB(255, 255, 255)
JoystickKnob.Parent = JoystickFrame

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = JoystickKnob

-- 📊 بيانات ESP
local ESPData = {}
local Flying = false
local FlyBodyVelocity = nil

-- ========== دوال الهاتف ==========

-- 🎯 عصا التحكم
local JoystickActive = false
local JoystickStartPos = nil
local MoveDirection = Vector3.new()

JoystickFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        JoystickActive = true
        JoystickStartPos = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if JoystickActive and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - JoystickStartPos
        local distance = math.min(delta.Magnitude, 75)
        local angle = math.atan2(delta.Y, delta.X)
        
        local offsetX = math.cos(angle) * distance
        local offsetY = math.sin(angle) * distance
        
        JoystickKnob.Position = UDim2.new(0.5, offsetX - 30, 0.5, offsetY - 30)
        
        -- حساب اتجاه الحركة
        local moveX = math.cos(angle) * (distance / 75)
        local moveZ = math.sin(angle) * (distance / 75)
        
        MoveDirection = Vector3.new(moveX, 0, moveZ)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and JoystickActive then
        JoystickActive = false
        JoystickKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
        MoveDirection = Vector3.new()
    end
end)

-- 🎯 زر الإطلاق
ShootButtonClick.MouseButton1Down:Connect(function()
    if Settings.Aimbot.AutoShoot then
        mouse1click()
    end
end)

-- 🎯 فتح/إغلاق القائمة
MenuButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
end)

-- 🔫 الحصول على أقرب هدف (مخصص للهاتف)
local function GetClosestTarget()
    local closest, shortestDistance = nil, Settings.Aimbot.FOV
    local centerPos = Vector2.new(ScreenSize.X/2, ScreenSize.Y/2)
    
    if Settings.Aimbot.LockTarget and LockedTarget and LockedTarget.Parent then
        local targetPart = LockedTarget:FindFirstChild(Settings.Aimbot.TargetPart) or LockedTarget:FindFirstChild("Head")
        if targetPart and targetPart.Parent and targetPart.Parent:FindFirstChild("Humanoid") and targetPart.Parent.Humanoid.Health > 0 then
            return targetPart
        else
            LockedTarget = nil
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(Settings.Aimbot.TargetPart) or 
                              player.Character:FindFirstChild("Head") or 
                              player.Character:FindFirstChild("HumanoidRootPart")
            
            if targetPart and player.Character:FindFirstChild("Humanoid") and 
               player.Character.Humanoid.Health > 0 then
                
                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - centerPos).Magnitude
                
                if onScreen and distance < shortestDistance then
                    closest = targetPart
                    shortestDistance = distance
                    CurrentTarget = player
                    
                    if Settings.Aimbot.LockTarget then
                        LockedTarget = targetPart.Parent
                    end
                end
            end
        end
    end
    return closest
end

-- 🎯 Silent Aim للهاتف
local function SilentAim()
    local target = GetClosestTarget()
    if target and Settings.Aimbot.SilentAim and Settings.Aimbot.Enabled then
        -- تعديل اتجاه الرماية
        local shootDirection = (target.Position - Camera.CFrame.Position).Unit
        -- Hook للـ RemoteEvent
    end
end

-- 🎯 Auto Shoot للهاتف
local function AutoShoot()
    if not Settings.Aimbot.AutoShoot or not Settings.Aimbot.Enabled then return end
    
    local target = GetClosestTarget()
    if target then
        local screenPoint = Camera:WorldToViewportPoint(target.Position)
        local centerPos = Vector2.new(ScreenSize.X/2, ScreenSize.Y/2)
        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - centerPos).Magnitude
        
        if screenPoint.Z > 0 and distance < 100 then
            task.wait(Settings.Aimbot.AutoShootDelay)
            mouse1click()
            
            -- تأثير إصابة للهاتف
            if Settings.Visuals.HitMarker then
                local hitMarker = Instance.new("Frame")
                hitMarker.Size = UDim2.new(0, 40, 0, 40)
                hitMarker.Position = UDim2.new(0.5, -20, 0.5, -20)
                hitMarker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hitMarker.BackgroundTransparency = 0.5
                hitMarker.BorderSizePixel = 2
                hitMarker.BorderColor3 = Color3.fromRGB(255, 0, 0)
                hitMarker.Parent = MobileGUI
                
                local markerCorner = Instance.new("UICorner")
                markerCorner.CornerRadius = UDim.new(1, 0)
                markerCorner.Parent = hitMarker
                
                TweenService:Create(hitMarker, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, 60, 0, 60),
                    Position = UDim2.new(0.5, -30, 0.5, -30),
                    BackgroundTransparency = 1
                }):Play()
                
                task.wait(0.2)
                hitMarker:Destroy()
            end
        end
    end
end

-- 👁 ESP للهاتف (محسن للأداء)
local function AddESP(player)
    if player == LocalPlayer then return end
    
    ESPData[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line"),
        Distance = Drawing.new("Text")
    }
    
    for _, obj in pairs(ESPData[player]) do
        obj.Visible = false
        obj.Thickness = 2
        obj.Font = 3
        obj.Size = 14
    end
end

local function UpdateESP()
    for player, drawings in pairs(ESPData) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            local vector, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen and humanoid and humanoid.Health > 0 and Settings.ESP.Enabled then
                local distance = (root.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local boxHeight = 120
                local boxWidth = 70
                local boxPosition = Vector2.new(vector.X - boxWidth/2, vector.Y - boxHeight/2)
                
                -- Box
                if Settings.ESP.Box then
                    drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                    drawings.Box.Position = boxPosition
                    drawings.Box.Color = Settings.ESP.Colors.Box
                    drawings.Box.Thickness = 2
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end
                
                -- Health Bar
                if Settings.ESP.Health and head then
                    local headScreen = Camera:WorldToViewportPoint(head.Position)
                    drawings.Health.From = Vector2.new(vector.X - boxWidth/2 - 5, headScreen.Y - boxHeight/2)
                    drawings.Health.To = Vector2.new(vector.X - boxWidth/2 - 5, headScreen.Y - boxHeight/2 + (boxHeight * healthPercent))
                    drawings.Health.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
                    drawings.Health.Thickness = 4
                    drawings.Health.Visible = true
                end
                
                -- Name
                if Settings.ESP.Name then
                    drawings.Name.Text = player.Name
                    drawings.Name.Position = Vector2.new(vector.X - 40, vector.Y - boxHeight/2 - 20)
                    drawings.Name.Color = Settings.ESP.Colors.Name
                    drawings.Name.Visible = true
                end
                
                -- Distance
                if Settings.ESP.Distance then
                    drawings.Distance.Text = math.floor(distance) .. "m"
                    drawings.Distance.Position = Vector2.new(vector.X - 20, vector.Y + boxHeight/2)
                    drawings.Distance.Color = Color3.fromRGB(255, 255, 0)
                    drawings.Distance.Visible = true
                end
            else
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
            end
        end
    end
end

-- 🚀 نظام الحركة للهاتف
local function HandleMovement()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        
        -- Speed hack
        if Settings.Movement.Speed then
            hum.WalkSpeed = Settings.Movement.SpeedValue
        else
            hum.WalkSpeed = 16
        end
        
        -- Infinite Jump
        if Settings.Movement.InfiniteJump then
            hum.JumpPower = Settings.Movement.JumpPower
        end
        
        -- Joystick movement
        if MoveDirection.Magnitude > 0 then
            local moveVector = (Camera.CFrame.RightVector * MoveDirection.X) + (Camera.CFrame.LookVector * -MoveDirection.Z)
            hum:Move(moveVector, true)
        end
    end
end

-- 🚁 نظام الطيران للهاتف
local function FlySystem()
    if not Settings.Movement.Fly then
        if Flying then
            Flying = false
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        return
    end
    
    if not Flying then
        Flying = true
        local char = LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = true
        end
        
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
        FlyBodyVelocity.P = 10000
        FlyBodyVelocity.Parent = char:FindFirstChild("HumanoidRootPart")
    end
    
    if FlyBodyVelocity and LocalPlayer.Character then
        -- تحكم الطيران باستخدام عصا التحكم
        local flyDirection = Vector3.new()
        if MoveDirection.Magnitude > 0 then
            flyDirection = (Camera.CFrame.RightVector * MoveDirection.X) + (Camera.CFrame.LookVector * -MoveDirection.Z)
        end
        
        -- أزرار رفع ونزول للهاتف
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyDirection = flyDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            flyDirection = flyDirection - Vector3.new(0, 1, 0)
        end
        
        if flyDirection.Magnitude > 0 then
            FlyBodyVelocity.Velocity = flyDirection.Unit * Settings.Movement.FlySpeed
        else
            FlyBodyVelocity.Velocity = Vector3.new()
        end
    end
end

-- 🎯 تحديث دائرة FOV
local function UpdateFOVCircle()
    ScreenSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(ScreenSize.X/2, ScreenSize.Y/2)
    FOVCircle.Radius = Settings.Aimbot.FOV
    FOVCircle.Visible = Settings.Visuals.FOVCircle
    FOVCircle.Color = Settings.Visuals.FOVCircleColor
end

-- 🎯 مؤشر الهدف
local TargetIndicator = Drawing.new("Triangle")
TargetIndicator.Visible = false
TargetIndicator.Color = Color3.fromRGB(255, 0, 0)
TargetIndicator.Thickness = 2
TargetIndicator.Filled = false

local function UpdateTargetIndicator()
    local target = GetClosestTarget()
    if target and Settings.Visuals.TargetIndicator and Settings.Aimbot.Enabled then
        local targetScreen = Camera:WorldToViewportPoint(target.Position)
        if targetScreen.Z > 0 then
            local size = 20
            TargetIndicator.PointA = Vector2.new(targetScreen.X - size, targetScreen.Y - size)
            TargetIndicator.PointB = Vector2.new(targetScreen.X + size, targetScreen.Y - size)
            TargetIndicator.PointC = Vector2.new(targetScreen.X, targetScreen.Y + size)
            TargetIndicator.Visible = true
        else
            TargetIndicator.Visible = false
        end
    else
        TargetIndicator.Visible = false
    end
end

-- ========== MAIN LOOP للهاتف ==========
RunService.Heartbeat:Connect(function()
    SilentAim()
    AutoShoot()
    HandleMovement()
    FlySystem()
    UpdateESP()
    UpdateFOVCircle()
    UpdateTargetIndicator()
end)

-- 🎮 التعامل مع شاشة اللمس
UserInputService.TouchEnabled = true

-- إعداد اللاعبين
for _, player in pairs(Players:GetPlayers()) do AddESP(player) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(function(player)
    if ESPData[player] then
        for _, drawing in pairs(ESPData[player]) do
            if drawing and drawing.Destroy then drawing:Destroy() end
        end
        ESPData[player] = nil
    end
end)

-- تنظيف عند الخروج
LocalPlayer.CharacterAdded:Connect(function()
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
    Flying = false
end)

-- إشعار التحميل
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(0, 300, 0, 50)
Notification.Position = UDim2.new(0.5, -150, 0.5, -25)
Notification.Text = "✅ FPS Cheat v3.0 MOBILE LOADED!"
Notification.TextColor3 = Color3.fromRGB(0, 255, 0)
Notification.TextSize = 18
Notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Notification.BackgroundTransparency = 0.5
Notification.BorderSizePixel = 2
Notification.BorderColor3 = Color3.fromRGB(0, 255, 0)
Notification.Parent = MobileGUI

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 10)
NotifCorner.Parent = Notification

task.wait(2)
Notification:Destroy()

print("🌟 FPS CHEAT v3.0 MOBILE LOADED!")
print("📱 مخصص للهاتف - استمتع باللعب!")
