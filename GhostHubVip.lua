--[[
    GHOST HUB V7.2 - FIXED EDITION
    Buttons: + / - for all settings | Small GUI | Fixed ESP
--]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// LOCAL PLAYER
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

--// ========== SETTINGS ==========
getgenv().Settings = {
    -- Auto Fire
    AutoFire = false,
    AutoFireDelay = 0.08,
    AutoFireRange = 100,
    AutoFirePart = "Head",
    AutoFireWallCheck = true,
    -- Aimbot
    AimAI = false,
    NormalAimbot = false,
    SilentAim = false,
    AimAssist = false,
    Aimlock = false,
    Smoothness = 0.15,
    Prediction = 0.12,
    TargetPart = "Head",
    FOV = 150,
    FOVCircle = false,
    TargetSelector = "Closest",
    -- ESP
    ESP = false,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    TeamCheck = true,
    RenderDistance = 500,
    -- TriggerBot
    TriggerBot = false,
    TriggerDelay = 0.03,
    TriggerKey = "V",
    -- Visual
    Spin = false,
    -- Weapons
    NoRecoil = false,
    InfAmmo = false
}

--// TARGET PARTS
local TargetParts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}

--// ========== UTILITIES ==========
local function Notify(text, color)
    local success, sg = pcall(function() return LP:FindFirstChild("PlayerGui") end)
    if not success or not sg then return end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 35)
    frame.Position = UDim2.new(0.5, -125, 0, -50)
    frame.BackgroundColor3 = color or Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.1
    frame.Parent = sg
    frame.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 13
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, 10)}):Play()
    task.wait(2)
    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, -50)}):Play()
    task.wait(0.3)
    frame:Destroy()
end

--// ========== WALL CHECK ==========
local function IsVisible(part)
    if not part or not part.Parent then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 500
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LP.Character, Camera}
    
    local result = workspace:Raycast(origin, direction, params)
    if result then
        local hitPart = result.Instance
        local character = part.Parent
        if hitPart:IsDescendantOf(character) then
            return true
        end
        return false
    end
    return true
end

--// ========== GET TARGET ==========
local function GetBestTarget(ignoreFOV)
    local bestTarget = nil
    local bestPart = nil
    local bestScore = math.huge
    
    local fov = getgenv().Settings.FOV or 150
    local mousePos = UserInputService:GetMouseLocation()
    local selector = getgenv().Settings.TargetSelector or "Closest"
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if getgenv().Settings.TeamCheck and p.Team and LP.Team and p.Team == LP.Team then
                        -- Skip teammates
                    else
                        local part = char:FindFirstChild(getgenv().Settings.TargetPart)
                        if not part then
                            part = char:FindFirstChild("HumanoidRootPart")
                        end
                        if part then
                            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            local distToMouse = onScreen and (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude or math.huge
                            local distToCamera = (Camera.CFrame.Position - part.Position).Magnitude
                            local health = hum.Health
                            
                            local inFOV = onScreen and distToMouse <= fov
                            
                            if ignoreFOV or inFOV then
                                local score = 0
                                if selector == "Closest" then
                                    score = distToMouse
                                elseif selector == "LowestHP" then
                                    score = health
                                elseif selector == "Distance" then
                                    score = distToCamera
                                end
                                
                                local shouldSelect = false
                                if selector == "LowestHP" then
                                    shouldSelect = health < bestScore
                                else
                                    shouldSelect = score < bestScore
                                end
                                
                                if shouldSelect then
                                    bestScore = score
                                    bestTarget = p
                                    bestPart = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget, bestPart
end

--// ========== AUTO FIRE ==========
local AutoFireTarget = nil
local AutoFireLastShot = 0

local function GetAutoFireTarget()
    local bestTarget = nil
    local bestDistance = getgenv().Settings.AutoFireRange or 100
    
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if getgenv().Settings.TeamCheck and p.Team and LP.Team and p.Team == LP.Team then
                        -- Skip teammates
                    else
                        local part = char:FindFirstChild(getgenv().Settings.AutoFirePart) or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                        if part then
                            local distance = (part.Position - myRoot.Position).Magnitude
                            
                            if distance < bestDistance then
                                if getgenv().Settings.AutoFireWallCheck then
                                    if IsVisible(part) then
                                        bestDistance = distance
                                        bestTarget = p
                                    end
                                else
                                    bestDistance = distance
                                    bestTarget = p
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function AutoFireShoot()
    for _, remote in ipairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("shoot") or name:find("fire") or name:find("attack") then
                remote:FireServer()
                return true
            end
        end
    end
    
    if IsMobile then
        local VirtualInput = game:GetService("VirtualInputManager")
        VirtualInput:SendTouchEvent(500, 700, true, 0, game)
        task.wait(0.03)
        VirtualInput:SendTouchEvent(500, 700, false, 0, game)
    else
        mouse1press()
        task.wait(0.05)
        mouse1release()
    end
    
    return true
end

local function UpdateAutoFire()
    if not getgenv().Settings.AutoFire then return end
    
    local now = tick()
    if now - AutoFireLastShot >= getgenv().Settings.AutoFireDelay then
        AutoFireTarget = GetAutoFireTarget()
        
        if AutoFireTarget then
            AutoFireLastShot = now
            AutoFireShoot()
        end
    end
end

--// ========== AIM AI ==========
local LastAITime = 0

local function UpdateAimAI()
    if not getgenv().Settings.AimAI then return end
    
    local now = tick()
    if now - LastAITime < 0.016 then return end
    
    local target, targetPart = GetBestTarget(false)
    if target and targetPart then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        local velocity = hrp and hrp.AssemblyLinearVelocity or Vector3.new()
        
        local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
        local predictionTime = getgenv().Settings.Prediction or 0.12
        local predictedPos = targetPart.Position + (velocity * predictionTime)
        
        local smoothness = getgenv().Settings.Smoothness or 0.15
        local dynamicSmoothness = math.clamp(smoothness + (distance / 2000), 0.08, 0.35)
        
        local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, dynamicSmoothness)
        
        LastAITime = now
    end
end

--// ========== NORMAL AIMBOT ==========
local function UpdateNormalAimbot()
    if not getgenv().Settings.NormalAimbot then return end
    
    local target, targetPart = GetBestTarget(false)
    if target and targetPart then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        local velocity = hrp and hrp.AssemblyLinearVelocity or Vector3.new()
        local predicted = targetPart.Position + (velocity * getgenv().Settings.Prediction)
        local targetCF = CFrame.new(Camera.CFrame.Position, predicted)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, getgenv().Settings.Smoothness)
    end
end

--// ========== AIM ASSIST ==========
local LastAssistTime = 0

local function UpdateAimAssist()
    if not getgenv().Settings.AimAssist then return end
    if tick() - LastAssistTime < 0.015 then return end
    
    local target, targetPart = GetBestTarget(false)
    if target and targetPart then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        local velocity = hrp and hrp.AssemblyLinearVelocity or Vector3.new()
        local predicted = targetPart.Position + (velocity * getgenv().Settings.Prediction)
        local targetCF = CFrame.new(Camera.CFrame.Position, predicted)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, getgenv().Settings.Smoothness)
        LastAssistTime = tick()
    end
end

--// ========== AIM LOCK ==========
local LockedTarget = nil
local LockedPart = nil

local function UpdateAimLock()
    if not getgenv().Settings.Aimlock then
        LockedTarget = nil
        LockedPart = nil
        return
    end
    
    local isLocking = false
    
    if IsMobile then
        isLocking = #UserInputService:GetTouches() > 0
    else
        isLocking = UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
    end
    
    if isLocking then
        if not LockedTarget then
            local target, targetPart = GetBestTarget(false)
            if target then
                LockedTarget = target
                LockedPart = targetPart
                Notify("🔒 Locked: " .. target.Name, Color3.fromRGB(0,255,0))
            end
        end
    else
        LockedTarget = nil
        LockedPart = nil
    end
    
    if LockedTarget and LockedPart then
        local targetCF = CFrame.new(Camera.CFrame.Position, LockedPart.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 0.2)
    end
end

--// ========== TRIGGER BOT ==========
local LastTrigger = 0

local function UpdateTriggerBot()
    if not getgenv().Settings.TriggerBot then return end
    
    local pressed = false
    local key = getgenv().Settings.TriggerKey or "V"
    
    if IsMobile then
        pressed = #UserInputService:GetTouches() > 0
    else
        if key == "V" then
            pressed = UserInputService:IsKeyDown(Enum.KeyCode.V)
        elseif key == "MouseButton1" then
            pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif key == "MouseButton2" then
            pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif key == "R" then
            pressed = UserInputService:IsKeyDown(Enum.KeyCode.R)
        end
    end
    
    if pressed and tick() - LastTrigger >= getgenv().Settings.TriggerDelay then
        local target = Mouse.Target
        if target then
            local char = target:FindFirstAncestorWhichIsA("Model")
            if char and char:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(char)
                if player and player ~= LP then
                    pcall(function()
                        local VIM = game:GetService("VirtualInputManager")
                        local mpos = UserInputService:GetMouseLocation()
                        VIM:SendMouseButtonEvent(mpos.X, mpos.Y, 0, true, game, 0)
                        task.wait()
                        VIM:SendMouseButtonEvent(mpos.X, mpos.Y, 0, false, game, 0)
                    end)
                    LastTrigger = tick()
                end
            end
        end
    end
end

--// ========== ESP SYSTEM (FIXED - يختفي تماماً) ==========
local ESPDrawings = {}

local function UpdateESP()
    if not getgenv().Settings.ESP then
        -- FIXED: مسح كل الرسومات عند إيقاف ESP
        for _, d in pairs(ESPDrawings) do
            pcall(function() d:Remove() end)
        end
        ESPDrawings = {}
        return
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    
                    if onScreen and dist <= getgenv().Settings.RenderDistance then
                        local isTeammate = getgenv().Settings.TeamCheck and p.Team == LP.Team
                        local color = isTeammate and Color3.fromRGB(0,200,255) or Color3.fromRGB(255,0,0)
                        
                        local height = (500 / pos.Z) * 2
                        local width = height * 0.5
                        
                        -- Box ESP
                        if getgenv().Settings.ESPBox then
                            if not ESPDrawings["box_"..p.UserId] then
                                ESPDrawings["box_"..p.UserId] = Drawing.new("Square")
                                ESPDrawings["box_"..p.UserId].Thickness = 2
                                ESPDrawings["box_"..p.UserId].Filled = false
                            end
                            local box = ESPDrawings["box_"..p.UserId]
                            box.Visible = true
                            box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                            box.Size = Vector2.new(width, height)
                            box.Color = color
                        elseif ESPDrawings["box_"..p.UserId] then
                            ESPDrawings["box_"..p.UserId].Visible = false
                        end
                        
                        -- Name ESP
                        if getgenv().Settings.ESPName then
                            if not ESPDrawings["name_"..p.UserId] then
                                ESPDrawings["name_"..p.UserId] = Drawing.new("Text")
                                ESPDrawings["name_"..p.UserId].Size = 12
                                ESPDrawings["name_"..p.UserId].Center = true
                                ESPDrawings["name_"..p.UserId].Outline = true
                                ESPDrawings["name_"..p.UserId].OutlineColor = Color3.new(0,0,0)
                            end
                            local name = ESPDrawings["name_"..p.UserId]
                            name.Visible = true
                            name.Text = p.Name .. " (" .. math.floor(dist) .. "m)"
                            name.Position = Vector2.new(pos.X, pos.Y - height/2 - 12)
                            name.Color = Color3.new(1,1,1)
                        elseif ESPDrawings["name_"..p.UserId] then
                            ESPDrawings["name_"..p.UserId].Visible = false
                        end
                        
                        -- Health ESP
                        if getgenv().Settings.ESPHealth then
                            if not ESPDrawings["health_"..p.UserId] then
                                ESPDrawings["health_"..p.UserId] = Drawing.new("Text")
                                ESPDrawings["health_"..p.UserId].Size = 10
                                ESPDrawings["health_"..p.UserId].Center = true
                            end
                            local health = ESPDrawings["health_"..p.UserId]
                            health.Visible = true
                            local healthPercent = hum.Health / hum.MaxHealth
                            health.Text = math.floor(hum.Health)
                            health.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                            health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        elseif ESPDrawings["health_"..p.UserId] then
                            ESPDrawings["health_"..p.UserId].Visible = false
                        end
                    else
                        if ESPDrawings["box_"..p.UserId] then ESPDrawings["box_"..p.UserId].Visible = false end
                        if ESPDrawings["name_"..p.UserId] then ESPDrawings["name_"..p.UserId].Visible = false end
                        if ESPDrawings["health_"..p.UserId] then ESPDrawings["health_"..p.UserId].Visible = false end
                    end
                end
            end
        end
    end
end

--// ========== FOV CIRCLE ==========
local FOVCircle = nil

local function UpdateFOVCircle()
    if not getgenv().Settings.FOVCircle then
        if FOVCircle then
            FOVCircle.Visible = false
        end
        return
    end
    
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.NumSides = 64
        FOVCircle.Transparency = 0.7
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    end
    
    FOVCircle.Visible = true
    FOVCircle.Radius = getgenv().Settings.FOV or 150
    FOVCircle.Position = UserInputService:GetMouseLocation()
end

--// ========== SPIN ==========
local function UpdateSpin()
    if not getgenv().Settings.Spin then return end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(10), 0)
        end
    end
end

--// ========== WEAPON MODS ==========
local function ApplyWeaponMods()
    if not getgenv().Settings.NoRecoil and not getgenv().Settings.InfAmmo then return end
    
    local char = LP.Character
    if not char then return end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                local name = v.Name:lower()
                if getgenv().Settings.NoRecoil and (name:find("recoil") or name:find("shake")) then
                    pcall(function() v.Value = 0 end)
                end
                if getgenv().Settings.InfAmmo and (name:find("ammo") or name:find("mag")) then
                    pcall(function() v.Value = 999 end)
                end
            end
        end
    end
end

--// ========== SILENT AIM ==========
local OldNamecall = nil
pcall(function()
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if getgenv().Settings.SilentAim and method == "FindPartOnRayWithIgnoreList" then
            local target, targetPart = GetBestTarget(false)
            if targetPart then
                return targetPart, targetPart.Position, targetPart.CFrame.LookVector, targetPart.Material
            end
        end
        return OldNamecall(self, ...)
    end)
end)

--// ========== GUI SYSTEM (SMALL: 250x420) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostHub"
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame (صغير)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 420)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.Parent = MainFrame
MainCorner.CornerRadius = UDim.new(0, 10)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner")
TitleCorner.Parent = TitleBar
TitleCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "🔥 GHOST HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 14
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Drag Function
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Tabs (صغيرة)
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.BackgroundTransparency = 1

local TabsList = {"⚡", "🎯", "👁️", "🔧"}
local TabNames = {"Aimbot", "WOR🔥", "ESP", "Misc"}
local CurrentTab = "Aimbot"
local TabButtons = {}

-- Content Frame (مع سكرول)
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -10, 1, -75)
ContentFrame.Position = UDim2.new(0, 5, 0, 70)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 3
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper: Button +/-
local function CreatePlusMinus(text, setting, minVal, maxVal, step, decimals)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 5)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local minusBtn = Instance.new("TextButton")
    minusBtn.Parent = frame
    minusBtn.Size = UDim2.new(0, 25, 0, 22)
    minusBtn.Position = UDim2.new(0.7, 0, 0.5, -11)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    minusBtn.TextSize = 14
    minusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    minusBtn.BackgroundTransparency = 0.3
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.Parent = minusBtn
    minusCorner.CornerRadius = UDim.new(0, 4)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.Size = UDim2.new(0, 40, 0, 22)
    valueLabel.Position = UDim2.new(0.72, 25, 0.5, -11)
    local val = getgenv().Settings[setting]
    valueLabel.Text = decimals and string.format("%." .. decimals .. "f", val) or tostring(math.floor(val))
    valueLabel.TextColor3 = Color3.fromRGB(200, 50, 100)
    valueLabel.TextSize = 11
    valueLabel.BackgroundTransparency = 1
    
    local plusBtn = Instance.new("TextButton")
    plusBtn.Parent = frame
    plusBtn.Size = UDim2.new(0, 25, 0, 22)
    plusBtn.Position = UDim2.new(0.85, 0, 0.5, -11)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    plusBtn.TextSize = 14
    plusBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    plusBtn.BackgroundTransparency = 0.3
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.Parent = plusBtn
    plusCorner.CornerRadius = UDim.new(0, 4)
    
    local function updateValue(newVal)
        newVal = math.clamp(newVal, minVal, maxVal)
        if decimals then
            newVal = math.floor(newVal * (10 ^ decimals)) / (10 ^ decimals)
        end
        getgenv().Settings[setting] = newVal
        if decimals then
            valueLabel.Text = string.format("%." .. decimals .. "f", newVal)
        else
            valueLabel.Text = tostring(math.floor(newVal))
        end
        if setting == "FOV" and getgenv().Settings.FOVCircle and FOVCircle then
            FOVCircle.Radius = newVal
        end
    end
    
    minusBtn.MouseButton1Click:Connect(function()
        updateValue(getgenv().Settings[setting] - step)
    end)
    
    plusBtn.MouseButton1Click:Connect(function()
        updateValue(getgenv().Settings[setting] + step)
    end)
    
    return frame
end

local function CreateToggle(text, setting)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 5)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0, 45, 0, 22)
    btn.Position = UDim2.new(0.75, 0, 0.5, -11)
    btn.Text = getgenv().Settings[setting] and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    btn.BackgroundColor3 = getgenv().Settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = btn
    btnCorner.CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().Settings[setting] = not getgenv().Settings[setting]
        btn.Text = getgenv().Settings[setting] and "ON" or "OFF"
        btn.BackgroundColor3 = getgenv().Settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
        Notify(text .. ": " .. (getgenv().Settings[setting] and "ON" or "OFF"), Color3.fromRGB(200, 50, 100))
        
        if setting == "ESP" and not getgenv().Settings[setting] then
            for _, d in pairs(ESPDrawings) do
                pcall(function() d:Remove() end)
            end
            ESPDrawings = {}
        end
    end)
    
    return frame
end

local function CreateDropdown(text, setting, options)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 5)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.45, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0, 70, 0, 22)
    btn.Position = UDim2.new(0.55, 0, 0.5, -11)
    btn.Text = getgenv().Settings[setting]
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = btn
    btnCorner.CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        local current = 1
        for i, v in ipairs(options) do
            if v == getgenv().Settings[setting] then
                current = i
                break
            end
        end
        local nextIdx = current % #options + 1
        getgenv().Settings[setting] = options[nextIdx]
        btn.Text = getgenv().Settings[setting]
        Notify(text .. ": " .. getgenv().Settings[setting], Color3.fromRGB(200, 50, 100))
    end)
    
    return frame
end

local function CreateHeader(text, icon)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 24)
    frame.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    frame.BackgroundTransparency = 0.3
    frame.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, 5)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = icon .. " " .. text .. " " .. icon
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    
    return frame
end

-- Create Tab Buttons
for i, tab in ipairs(TabsList) do
    local btn = Instance.new("TextButton")
    btn.Parent = TabBar
    btn.Size = UDim2.new(0, 60, 1, -4)
    btn.Position = UDim2.new(0, (i - 1) * 62 + 4, 0, 2)
    btn.Text = tab
    btn.TextColor3 = i == 1 and Color3.fromRGB(200, 50, 100) or Color3.fromRGB(150, 150, 150)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundTransparency = i == 1 and 0.2 or 1
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = btn
    btnCorner.CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        CurrentTab = TabNames[i]
        for j, b in pairs(TabButtons) do
            if j == i then
                b.TextColor3 = Color3.fromRGB(200, 50, 100)
                b.BackgroundTransparency = 0.2
            else
                b.TextColor3 = Color3.fromRGB(150, 150, 150)
                b.BackgroundTransparency = 1
            end
        end
        
        -- Clear and rebuild
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        if CurrentTab == "Aimbot" then
            CreateHeader("AIMBOT", "🎯")
            CreateToggle("AIM AI", "AimAI")
            CreateToggle("Normal Aimbot", "NormalAimbot")
            CreateToggle("Silent Aim", "SilentAim")
            CreateToggle("Aim Assist", "AimAssist")
            CreateToggle("Aim Lock", "Aimlock")
            CreateHeader("SETTINGS", "⚙️")
            CreatePlusMinus("Smoothness", "Smoothness", 0.05, 0.5, 0.02, 2)
            CreatePlusMinus("Prediction", "Prediction", 0, 0.3, 0.02, 2)
            CreatePlusMinus("FOV Size", "FOV", 30, 300, 10, 0)
            CreateToggle("Show FOV Circle", "FOVCircle")
            CreateDropdown("Target Part", "TargetPart", TargetParts)
            CreateDropdown("Selector", "TargetSelector", {"Closest", "LowestHP", "Distance"})
            
        elseif CurrentTab == "WOR🔥" then
            CreateHeader("AUTO FIRE", "🔥")
            CreateToggle("Auto Fire", "AutoFire")
            CreatePlusMinus("Fire Delay", "AutoFireDelay", 0.03, 0.25, 0.01, 2)
            CreatePlusMinus("Range", "AutoFireRange", 50, 200, 10, 0)
            CreateDropdown("Target Part", "AutoFirePart", {"Head", "HumanoidRootPart", "UpperTorso"})
            CreateToggle("Wall Check", "AutoFireWallCheck")
            
        elseif CurrentTab == "ESP" then
            CreateHeader("ESP", "👁️")
            CreateToggle("ESP Enabled", "ESP")
            CreateToggle("Box ESP", "ESPBox")
            CreateToggle("Name ESP", "ESPName")
            CreateToggle("Health ESP", "ESPHealth")
            CreateToggle("Team Check", "TeamCheck")
            CreatePlusMinus("Render Distance", "RenderDistance", 200, 1000, 50, 0)
            
        elseif CurrentTab == "Misc" then
            CreateHeader("MISC", "🔧")
            CreateToggle("Trigger Bot", "TriggerBot")
            CreatePlusMinus("Trigger Delay", "TriggerDelay", 0.01, 0.2, 0.01, 2)
            CreateDropdown("Trigger Key", "TriggerKey", {"V", "MouseButton1", "MouseButton2", "R"})
            CreateToggle("Spin", "Spin")
            CreateToggle("No Recoil", "NoRecoil")
            CreateToggle("Infinite Ammo", "InfAmmo")
        end
    end)
    
    TabButtons[i] = btn
end

-- Load initial content (Aimbot)
CreateHeader("AIMBOT", "🎯")
CreateToggle("AIM AI", "AimAI")
CreateToggle("Normal Aimbot", "NormalAimbot")
CreateToggle("Silent Aim", "SilentAim")
CreateToggle("Aim Assist", "AimAssist")
CreateToggle("Aim Lock", "Aimlock")
CreateHeader("SETTINGS", "⚙️")
CreatePlusMinus("Smoothness", "Smoothness", 0.05, 0.5, 0.02, 2)
CreatePlusMinus("Prediction", "Prediction", 0, 0.3, 0.02, 2)
CreatePlusMinus("FOV Size", "FOV", 30, 300, 10, 0)
CreateToggle("Show FOV Circle", "FOVCircle")
CreateDropdown("Target Part", "TargetPart", TargetParts)
CreateDropdown("Selector", "TargetSelector", {"Closest", "LowestHP", "Distance"})

-- Floating Button (صغير)
local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Parent = ScreenGui
FloatingBtn.Size = UDim2.new(0, 40, 0, 40)
FloatingBtn.Position = UDim2.new(0, 10, 0.5, -20)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
FloatingBtn.BackgroundTransparency = 0.2
FloatingBtn.Image = "rbxassetid://6023426926"
FloatingBtn.ImageColor3 = Color3.new(1, 1, 1)

local FloatCorner = Instance.new("UICorner")
FloatCorner.Parent = FloatingBtn
FloatCorner.CornerRadius = UDim.new(1, 0)

local floatDrag = false
local floatDragStart, floatStartPos

FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatDrag = true
        floatDragStart = input.Position
        floatStartPos = FloatingBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if floatDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - floatDragStart
        FloatingBtn.Position = UDim2.new(floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X, floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatDrag = false
    end
end)

FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--// ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    pcall(function()
        UpdateAutoFire()
        UpdateAimAI()
        UpdateNormalAimbot()
        UpdateAimAssist()
        UpdateAimLock()
        UpdateESP()
        UpdateFOVCircle()
        UpdateTriggerBot()
        ApplyWeaponMods()
        UpdateSpin()
    end)
end)

--// ========== ANTI-IDLE ==========
pcall(function()
    LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--// ========== CLEANUP ==========
Players.PlayerRemoving:Connect(function()
    for _, d in pairs(ESPDrawings) do
        pcall(function() d:Remove() end)
    end
    ESPDrawings = {}
end)

--// ========== STARTUP ==========
Notify("🔥 GHOST HUB Loaded!", Color3.fromRGB(0, 255, 200))

print("=" .. string.rep("=", 50))
print("🔥 GHOST HUB V7.2 - ULTIMATE EDITION")
print("=" .. string.rep("=", 50))
print("✅ All settings use + / - buttons")
print("✅ Small GUI (250x420)")
print("✅ ESP clears completely when OFF")
print("✅ FOV works all the time")
print("=" .. string.rep("=", 50))
