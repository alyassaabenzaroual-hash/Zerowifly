--// GHOST HUB V7.2 - COMPLETE WORKING VERSION (WITH NORMAL AIMBOT)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

--// SETTINGS
getgenv().Settings = {
    -- Aimbot
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
    NoRecoil = true,
    InfAmmo = true,
    -- GUI
    Theme = "Dark"
}

--// TARGET PARTS LIST (Head, Neck, Torso, etc)
local TargetParts = {"Head", "Neck", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}

--// NOTIFICATION SYSTEM
local function Notify(text, color)
    local success, sg = pcall(function() return LP:FindFirstChild("PlayerGui") end)
    if not success or not sg then return end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 40)
    frame.Position = UDim2.new(0.5, -150, 0, -50)
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
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, 10)}):Play()
    task.wait(2)
    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, -50)}):Play()
    task.wait(0.3)
    frame:Destroy()
end

--// GET BEST TARGET (for all aimbot types)
local function GetBestTarget()
    local closest = math.huge
    local lowestHp = math.huge
    local bestTarget = nil
    local bestPart = nil
    local targets = {}
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local skip = false
                    if getgenv().Settings.TeamCheck and p.Team and LP.Team then
                        if p.Team == LP.Team then skip = true end
                    end
                    if not skip then
                        local part = char:FindFirstChild(getgenv().Settings.TargetPart)
                        if not part then
                            part = char:FindFirstChild("HumanoidRootPart")
                        end
                        if part then
                            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local mousePos = UIS:GetMouseLocation()
                                local distToMouse = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                                local distToCamera = (Camera.CFrame.Position - part.Position).Magnitude
                                local hp = hum.Health
                                local fov = getgenv().Settings.FOV or 150
                                
                                if distToMouse <= fov then
                                    table.insert(targets, {
                                        Part = part,
                                        DistanceToMouse = distToMouse,
                                        DistanceToCamera = distToCamera,
                                        Health = hp,
                                        Character = char
                                    })
                                    
                                    if distToMouse < closest then
                                        closest = distToMouse
                                    end
                                    if hp < lowestHp then
                                        lowestHp = hp
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    local selector = getgenv().Settings.TargetSelector or "Closest"
    
    if selector == "Closest" then
        local bestMouse = math.huge
        for _, t in pairs(targets) do
            if t.DistanceToMouse < bestMouse then
                bestMouse = t.DistanceToMouse
                bestTarget = t
            end
        end
    elseif selector == "LowestHP" then
        local bestHp = math.huge
        for _, t in pairs(targets) do
            if t.Health < bestHp then
                bestHp = t.Health
                bestTarget = t
            end
        end
    elseif selector == "Distance" then
        local bestDist = math.huge
        for _, t in pairs(targets) do
            if t.DistanceToCamera < bestDist then
                bestDist = t.DistanceToCamera
                bestTarget = t
            end
        end
    end
    
    return bestTarget
end

--// NORMAL AIMBOT (Right Click)
local NormalAimbotActive = false
local function UpdateNormalAimbot()
    if not getgenv().Settings.NormalAimbot then return end
    
    local isAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    
    if isAiming then
        if not NormalAimbotActive then
            NormalAimbotActive = true
        end
        
        local target = GetBestTarget()
        if target and target.Part then
            local targetPos = target.Part.Position
            local hrp = target.Character:FindFirstChild("HumanoidRootPart")
            local velocity = hrp and hrp.AssemblyLinearVelocity or Vector3.new()
            local predicted = targetPos + (velocity * getgenv().Settings.Prediction)
            local targetCF = CFrame.new(Camera.CFrame.Position, predicted)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, getgenv().Settings.Smoothness)
        end
    else
        NormalAimbotActive = false
    end
end

--// SILENT AIM HOOK
local OldNamecall = nil
pcall(function()
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if getgenv().Settings.SilentAim and method == "FindPartOnRayWithIgnoreList" then
            local target = GetBestTarget()
            if target and target.Part then
                return target.Part, target.Part.Position, target.Part.CFrame.LookVector, target.Part.Material
            end
        end
        return OldNamecall(self, ...)
    end)
end)

--// AIM ASSIST
local LastAimTime = 0
local function UpdateAimAssist()
    if not getgenv().Settings.AimAssist then return end
    if tick() - LastAimTime < 0.015 then return end
    
    local isAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if not isAiming then return end
    
    local target = GetBestTarget()
    if target and target.Part then
        local targetPos = target.Part.Position
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        local velocity = hrp and hrp.AssemblyLinearVelocity or Vector3.new()
        local predicted = targetPos + (velocity * getgenv().Settings.Prediction)
        local targetCF = CFrame.new(Camera.CFrame.Position, predicted)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, getgenv().Settings.Smoothness)
        LastAimTime = tick()
    end
end

--// AIM LOCK
local LockedTarget = nil
local function UpdateAimLock()
    if not getgenv().Settings.Aimlock then
        LockedTarget = nil
        return
    end
    
    if UIS:IsKeyDown(Enum.KeyCode.RightAlt) then
        if not LockedTarget then
            local target = GetBestTarget()
            if target then
                LockedTarget = target
                Notify("🔒 Locked: " .. (target.Part.Parent and target.Part.Parent.Name or "Target"), Color3.fromRGB(0,255,0))
            end
        end
    elseif not getgenv().Settings.NormalAimbot and not getgenv().Settings.AimAssist then
        if not UIS:IsKeyDown(Enum.KeyCode.RightAlt) then
            LockedTarget = nil
        end
    end
    
    if LockedTarget and LockedTarget.Part then
        local targetPos = LockedTarget.Part.Position
        local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 0.2)
    end
end

--// TRIGGER BOT
local LastTrigger = 0
local function UpdateTriggerBot()
    if not getgenv().Settings.TriggerBot then return end
    
    local pressed = false
    local key = getgenv().Settings.TriggerKey or "V"
    
    if key == "V" then
        pressed = UIS:IsKeyDown(Enum.KeyCode.V)
    elseif key == "MouseButton1" then
        pressed = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == "MouseButton2" then
        pressed = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif key == "R" then
        pressed = UIS:IsKeyDown(Enum.KeyCode.R)
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
                        local mpos = UIS:GetMouseLocation()
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

--// WEAPON MODS
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
                    v.Value = 0
                end
                if getgenv().Settings.InfAmmo and (name:find("ammo") or name:find("mag")) then
                    v.Value = 999
                end
            end
        end
    end
end

--// ESP SYSTEM
local ESPDrawings = {}
local function UpdateESP()
    if not getgenv().Settings.ESP then
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
                        local color = isTeammate and Color3.fromRGB(0,200,255) or Color3.fromRGB(0,255,0)
                        
                        local size = char:GetExtentsSize()
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
                                ESPDrawings["name_"..p.UserId].Size = 14
                                ESPDrawings["name_"..p.UserId].Center = true
                                ESPDrawings["name_"..p.UserId].Outline = true
                            end
                            local name = ESPDrawings["name_"..p.UserId]
                            name.Visible = true
                            name.Text = p.Name
                            name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                            name.Color = Color3.fromRGB(255,255,255)
                        elseif ESPDrawings["name_"..p.UserId] then
                            ESPDrawings["name_"..p.UserId].Visible = false
                        end
                        
                        -- Health ESP
                        if getgenv().Settings.ESPHealth then
                            if not ESPDrawings["health_"..p.UserId] then
                                ESPDrawings["health_"..p.UserId] = Drawing.new("Text")
                                ESPDrawings["health_"..p.UserId].Size = 12
                                ESPDrawings["health_"..p.UserId].Center = true
                            end
                            local health = ESPDrawings["health_"..p.UserId]
                            health.Visible = true
                            health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                            health.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                            health.Color = Color3.fromRGB(100,255,100)
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

--// FOV CIRCLE
local FOVCircle = nil
local function UpdateFOVCircle()
    if not getgenv().Settings.FOVCircle then
        if FOVCircle then FOVCircle.Visible = false end
        return
    end
    
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.NumSides = 64
        FOVCircle.Transparency = 0.7
    end
    
    FOVCircle.Visible = true
    FOVCircle.Radius = getgenv().Settings.FOV or 150
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Position = UIS:GetMouseLocation()
end

--// SPIN
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

--// ============================================
--// GUI SYSTEM
--// ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostHub"
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "👻 GHOST HUB V7"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 16
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Drag functionality
local DragToggle = false
local DragStart, DragPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        DragToggle = true
        DragStart = input.Position
        DragPos = MainFrame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if DragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(DragPos.X.Scale, DragPos.X.Offset + delta.X, DragPos.Y.Scale, DragPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then DragToggle = false end
end)

-- Tabs
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.Position = UDim2.new(0, 0, 0, 45)
TabBar.BackgroundTransparency = 1

local Tabs = {"Aimbot", "ESP", "Weapons", "Misc"}
local CurrentTab = "Aimbot"
local TabButtons = {}

local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 6
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout", ContentFrame)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- UI Functions
local function CreateToggle(text, setting)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.5
    frame.Parent = ContentFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -60, 0.5, -12.5)
    btn.Text = getgenv().Settings[setting] and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 12
    btn.BackgroundColor3 = getgenv().Settings[setting] and Color3.fromRGB(0,200,0) or Color3.fromRGB(150,0,0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().Settings[setting] = not getgenv().Settings[setting]
        btn.Text = getgenv().Settings[setting] and "ON" or "OFF"
        btn.BackgroundColor3 = getgenv().Settings[setting] and Color3.fromRGB(0,200,0) or Color3.fromRGB(150,0,0)
        Notify(text .. ": " .. (getgenv().Settings[setting] and "ON" or "OFF"), Color3.fromRGB(200,50,100))
    end)
    return frame
end

local function CreateSlider(text, setting, min, max, decimals)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.5
    frame.Parent = ContentFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0.4, -20, 0, 25)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 5)
    local val = getgenv().Settings[setting]
    valueLabel.Text = decimals and string.format("%."..decimals.."f", val) or tostring(math.floor(val))
    valueLabel.TextColor3 = Color3.fromRGB(200,50,100)
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    
    local sliderBar = Instance.new("Frame", frame)
    sliderBar.Size = UDim2.new(1, -20, 0, 4)
    sliderBar.Position = UDim2.new(0, 10, 0, 45)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame", sliderBar)
    local percent = (getgenv().Settings[setting] - min) / (max - min)
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(200,50,100)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    btn.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X
            local barPos = sliderBar.AbsolutePosition.X
            local barW = sliderBar.AbsoluteSize.X
            local newPercent = math.clamp((pos - barPos) / barW, 0, 1)
            local value = min + (max - min) * newPercent
            if decimals then
                value = math.floor(value * (10^decimals)) / (10^decimals)
            end
            getgenv().Settings[setting] = value
            sliderFill.Size = UDim2.new(newPercent, 0, 1, 0)
            if decimals then
                valueLabel.Text = string.format("%."..decimals.."f", value)
            else
                valueLabel.Text = tostring(math.floor(value))
            end
        end
    end)
    return frame
end

local function CreateDropdown(text, setting, options)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.5
    frame.Parent = ContentFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.5, -20, 0.7, 0)
    btn.Position = UDim2.new(0.5, 0, 0.15, 0)
    btn.Text = getgenv().Settings[setting]
    btn.TextColor3 = Color3.fromRGB(200,50,100)
    btn.TextSize = 13
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        local current = 1
        for i, v in ipairs(options) do
            if v == getgenv().Settings[setting] then current = i break end
        end
        local next = current % #options + 1
        getgenv().Settings[setting] = options[next]
        btn.Text = getgenv().Settings[setting]
        Notify(text .. ": " .. getgenv().Settings[setting], Color3.fromRGB(200,50,100))
    end)
    return frame
end

-- Helper function to clear and rebuild UI
local function ClearContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

-- Tab content builder
local function UpdateContent()
    ClearContent()
    
    if CurrentTab == "Aimbot" then
        CreateToggle("🎯 Normal Aimbot (Right Click)", "NormalAimbot")
        CreateToggle("🔫 Silent Aim", "SilentAim")
        CreateToggle("🎯 Aim Assist", "AimAssist")
        CreateToggle("🔒 Aim Lock (Hold RightAlt)", "Aimlock")
        CreateSlider("Smoothness", "Smoothness", 0.05, 0.5, 2)
        CreateSlider("Prediction", "Prediction", 0, 0.3, 2)
        CreateSlider("FOV Size", "FOV", 50, 300, 0)
        CreateToggle("Show FOV Circle", "FOVCircle")
        CreateDropdown("Target Part", "TargetPart", TargetParts)
        CreateDropdown("Target Selector", "TargetSelector", {"Closest", "LowestHP", "Distance"})
        
    elseif CurrentTab == "ESP" then
        CreateToggle("👁️ ESP Enabled", "ESP")
        CreateToggle("📦 Box ESP", "ESPBox")
        CreateToggle("🏷️ Name ESP", "ESPName")
        CreateToggle("❤️ Health ESP", "ESPHealth")
        CreateToggle("👥 Team Check", "TeamCheck")
        CreateSlider("Render Distance", "RenderDistance", 200, 1000, 0)
        
    elseif CurrentTab == "Weapons" then
        CreateToggle("🔫 No Recoil", "NoRecoil")
        CreateToggle("♾️ Infinite Ammo", "InfAmmo")
        
    elseif CurrentTab == "Misc" then
        CreateToggle("⚡ TriggerBot", "TriggerBot")
        CreateSlider("Trigger Delay", "TriggerDelay", 0.01, 0.2, 2)
        CreateDropdown("Trigger Key", "TriggerKey", {"V", "MouseButton1", "MouseButton2", "R"})
        CreateToggle("🔄 Spin", "Spin")
    end
end

-- Create tab buttons
for i, tab in ipairs(Tabs) do
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0, 90, 1, -5)
    btn.Position = UDim2.new(0, (i-1) * 95 + 10, 0, 2)
    btn.Text = tab
    btn.TextColor3 = tab == CurrentTab and Color3.fromRGB(200,50,100) or Color3.fromRGB(150,150,150)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundTransparency = tab == CurrentTab and 0.2 or 1
    btn.BackgroundColor3 = Color3.fromRGB(200,50,100)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        CurrentTab = tab
        for _, b in pairs(TabButtons) do
            if b.Text == tab then
                b.TextColor3 = Color3.fromRGB(200,50,100)
                b.BackgroundTransparency = 0.2
            else
                b.TextColor3 = Color3.fromRGB(150,150,150)
                b.BackgroundTransparency = 1
            end
        end
        UpdateContent()
    end)
    TabButtons[i] = btn
end

UpdateContent()

--// FLOATING BUTTON
local FloatingBtn = Instance.new("ImageButton", ScreenGui)
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0, 10, 0.5, -25)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(200,50,100)
FloatingBtn.BackgroundTransparency = 0.2
FloatingBtn.Image = "rbxassetid://6023426926"
FloatingBtn.ImageColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)

local dragActive = false
local dragStartPos, dragStartMouse
FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragStartMouse = input.Position
        dragStartPos = FloatingBtn.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragActive and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartMouse
        FloatingBtn.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragActive = false end
end)
FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--// MAIN LOOP
RunService.RenderStepped:Connect(function()
    pcall(function()
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

--// CLEANUP
Players.PlayerRemoving:Connect(function()
    for _, d in pairs(ESPDrawings) do
        pcall(function() d:Remove() end)
    end
    ESPDrawings = {}
end)

--// ANTI-IDLE
pcall(function()
    LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

Notify("👻 Ghost Hub V7 Loaded!", Color3.fromRGB(200,50,100))
print("=" .. string.rep("=", 50))
print("👻 GHOST HUB V7 - COMPLETE VERSION")
print("=" .. string.rep("=", 50))
print("✅ Normal Aimbot (Right Click)")
print("✅ Silent Aim (Hook-Based)")
print("✅ Aim Assist + Aim Lock")
print("✅ Target Parts: Head/Neck/Torso/etc")
print("✅ ESP with Box/Name/Health")
print("✅ No Recoil + Infinite Ammo")
print("✅ Trigger Bot + Spin")
print("✅ Working GUI with Scroll")
print("=" .. string.rep("=", 50))
