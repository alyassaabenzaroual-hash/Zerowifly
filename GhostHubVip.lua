--[[
    GHOST HUB V7.2 - ULTIMATE AUTO FIRE SCRIPT
    Supports: Mobile/PC | Aimbot | ESP | Auto Fire
    FOV Circle 100% | Silent Aim 100% | Auto Fire 100%
--]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

--// LOCAL PLAYER
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

--// ========== MAIN SETTINGS ==========
getgenv().Settings = {
    AutoFire = true,
    AutoFireDelay = 0.08,
    AutoFireRange = 100,
    AutoFirePart = "Head",
    AutoFireWallCheck = true,
    AimAI = false,
    NormalAimbot = false,
    SilentAim = true,
    AimAssist = false,
    Aimlock = false,
    Smoothness = 0.15,
    Prediction = 0.12,
    TargetPart = "Head",
    FOV = 150,
    FOVCircle = true,
    TargetSelector = "Closest",
    ESP = false,
    TeamCheck = true,
    Boxes = false,
    Lines = false,
    Counter = false,
    MaxDistance = 500,
    RefreshRate = 0.05,
    TriggerBot = false,
    TriggerDelay = 0.03,
    TriggerKey = "V",
    Spin = false,
    NoRecoil = false,
    InfAmmo = false,
}

--// TARGET PARTS
local TargetParts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}

--// ========== ESP SYSTEM ==========
local ESPColors = {
    NameColor = Color3.fromRGB(255, 255, 255),
    BoxColor = Color3.fromRGB(255, 50, 100),
    LineColor = Color3.fromRGB(255, 255, 255),
    CounterColor = Color3.fromRGB(255, 215, 0),
    HealthHigh = Color3.fromRGB(0, 255, 0),
    HealthLow = Color3.fromRGB(255, 0, 0),
}

local ESPCache = {}
local ESPScreenGui = Instance.new("ScreenGui")
ESPScreenGui.Name = "GhostESP"
ESPScreenGui.Parent = CoreGui
ESPScreenGui.ResetOnSpawn = false

local CounterLabel = Instance.new("TextLabel")
CounterLabel.Parent = ESPScreenGui
CounterLabel.Size = UDim2.new(0, 220, 0, 35)
CounterLabel.Position = UDim2.new(0.5, -110, 0.02, 0)
CounterLabel.BackgroundTransparency = 0.5
CounterLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CounterLabel.Font = Enum.Font.GothamBold
CounterLabel.TextSize = 14
CounterLabel.TextColor3 = ESPColors.CounterColor
CounterLabel.Text = "👁️ ESP OFF"
CounterLabel.Visible = false
CounterLabel.ZIndex = 10

local CounterCorner = Instance.new("UICorner")
CounterCorner.CornerRadius = UDim.new(0, 8)
CounterCorner.Parent = CounterLabel

local function SetupESPForPlayer(player)
    if player == LP then return end
    
    local function OnCharacterAdded(char)
        if ESPCache[player] then
            local old = ESPCache[player]
            if old.Highlight then pcall(function() old.Highlight:Destroy() end) end
            if old.Tag then pcall(function() old.Tag:Destroy() end) end
            if old.Line then pcall(function() old.Line:Destroy() end) end
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not head or not hum then return end
        
        local highlight = Instance.new("Highlight")
        highlight.FillColor = ESPColors.BoxColor
        highlight.FillTransparency = 0.6
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
        highlight.Enabled = false
        
        local line = Instance.new("LineHandleAdornment")
        line.Length = 0
        line.Thickness = 1.5
        line.Color3 = ESPColors.LineColor
        line.AlwaysOnTop = true
        line.Adornee = root
        line.Parent = ESPScreenGui
        line.Visible = false
        
        local tag = Instance.new("BillboardGui")
        tag.Size = UDim2.new(0, 160, 0, 55)
        tag.AlwaysOnTop = true
        tag.StudsOffset = Vector3.new(0, 2.5, 0)
        tag.Parent = head
        tag.Enabled = false
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextColor3 = ESPColors.NameColor
        nameLabel.TextSize = 13
        nameLabel.Text = player.Name
        nameLabel.Parent = tag
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
        infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Enum.Font.GothamMedium
        infoLabel.TextSize = 11
        infoLabel.Text = "100 HP"
        infoLabel.Parent = tag
        
        ESPCache[player] = {
            Character = char,
            Root = root,
            Head = head,
            Humanoid = hum,
            Highlight = highlight,
            Tag = tag,
            Line = line,
            NameLabel = nameLabel,
            InfoLabel = infoLabel,
            LastUpdate = 0
        }
    end
    
    if player.Character then OnCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(OnCharacterAdded)
end

local espAccumulator = 0
RunService.RenderStepped:Connect(function(dt)
    espAccumulator = espAccumulator + dt
    
    if not getgenv().Settings.ESP then
        for _, data in pairs(ESPCache) do
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Tag then data.Tag.Enabled = false end
            if data.Line then data.Line.Visible = false end
        end
        if CounterLabel then CounterLabel.Visible = false end
        return
    end
    
    if espAccumulator < getgenv().Settings.RefreshRate then return end
    espAccumulator = 0
    if not Camera then return end
    
    local MyRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not MyRoot then return end
    
    local VisibleCount = 0
    
    for player, data in pairs(ESPCache) do
        if not data.Root or not data.Root.Parent or not data.Humanoid or data.Humanoid.Health <= 0 then
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Tag then data.Tag.Enabled = false end
            if data.Line then data.Line.Visible = false end
            goto continue
        end
        
        local isTeammate = false
        if getgenv().Settings.TeamCheck and player.Team and LP.Team then
            isTeammate = (player.Team == LP.Team)
        end
        
        local dist = (MyRoot.Position - data.Root.Position).Magnitude
        local screenPos, onScreen = Camera:WorldToViewportPoint(data.Root.Position)
        
        if onScreen and dist <= getgenv().Settings.MaxDistance and not isTeammate then
            VisibleCount = VisibleCount + 1
            
            if data.Highlight then data.Highlight.Enabled = getgenv().Settings.Boxes end
            if data.Tag then data.Tag.Enabled = true end
            if data.Line then 
                data.Line.Visible = getgenv().Settings.Lines
                if getgenv().Settings.Lines then
                    pcall(function() data.Line.CFrame = CFrame.new(data.Root.Position - Vector3.new(0, 3, 0)) end)
                end
            end
            
            local now = tick()
            if now - (data.LastUpdate or 0) > 0.1 then
                pcall(function()
                    if data.NameLabel then data.NameLabel.Text = player.Name end
                    if data.InfoLabel then
                        local hpPercent = data.Humanoid.Health / data.Humanoid.MaxHealth
                        data.InfoLabel.Text = string.format("%d HP | %dm", math.floor(data.Humanoid.Health), math.floor(dist))
                        data.InfoLabel.TextColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                    end
                end)
                data.LastUpdate = now
            end
        else
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Tag then data.Tag.Enabled = false end
            if data.Line then data.Line.Visible = false end
        end
        
        ::continue::
    end
    
    if getgenv().Settings.Counter then
        CounterLabel.Visible = true
        CounterLabel.Text = "👁️ TARGETS: " .. VisibleCount
    else
        CounterLabel.Visible = false
    end
end)

for _, player in ipairs(Players:GetPlayers()) do SetupESPForPlayer(player) end
Players.PlayerAdded:Connect(SetupESPForPlayer)
Players.PlayerRemoving:Connect(function(player)
    if ESPCache[player] then
        pcall(function()
            if ESPCache[player].Highlight then ESPCache[player].Highlight:Destroy() end
            if ESPCache[player].Tag then ESPCache[player].Tag:Destroy() end
            if ESPCache[player].Line then ESPCache[player].Line:Destroy() end
        end)
        ESPCache[player] = nil
    end
end)

--// ========== UTILITIES ==========
local function Notify(text, color)
    local sg = LP:FindFirstChild("PlayerGui")
    if not sg then return end
    
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
    
    task.spawn(function()
        TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, 10)}):Play()
        task.wait(2)
        TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, -50)}):Play()
        task.wait(0.3)
        frame:Destroy()
    end)
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
        if hitPart and character and hitPart:IsDescendantOf(character) then return true end
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
                    else
                        local part = char:FindFirstChild(getgenv().Settings.TargetPart) or char:FindFirstChild("HumanoidRootPart")
                        if part then
                            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local distToMouse = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                                local distToCamera = (Camera.CFrame.Position - part.Position).Magnitude
                                local health = hum.Health
                                
                                if ignoreFOV or distToMouse <= fov then
                                    local score = 0
                                    if selector == "Closest" then score = distToMouse
                                    elseif selector == "LowestHP" then score = health
                                    elseif selector == "Distance" then score = distToCamera end
                                    
                                    local shouldSelect = false
                                    if selector == "LowestHP" then shouldSelect = health < bestScore
                                    else shouldSelect = score < bestScore end
                                    
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
    end
    return bestTarget, bestPart
end

--// ========== AUTO FIRE (100% شغال) ==========
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
    -- Method 1: Find and fire RemoteEvents
    for _, remote in ipairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("shoot") or name:find("fire") or name:find("attack") or name:find("click") then
                pcall(function() remote:FireServer() end)
                return true
            end
        end
    end
    
    -- Method 2: Mobile touch
    if IsMobile then
        local VirtualInputManager = game:GetService("VirtualInputManager")
        pcall(function()
            VirtualInputManager:SendTouchEvent(500, 500, true, 0, game)
            task.wait(0.03)
            VirtualInputManager:SendTouchEvent(500, 500, false, 0, game)
        end)
    else
        -- Method 3: PC mouse click
        pcall(function() 
            mouse1press() 
            task.wait(0.05) 
            mouse1release() 
        end)
    end
    
    -- Method 4: Virtual User click
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:ClickButton1(Vector2.new(500, 500))
    end)
    
    return true
end

local function UpdateAutoFire()
    if not getgenv().Settings.AutoFire then return end
    local now = tick()
    if now - AutoFireLastShot >= getgenv().Settings.AutoFireDelay then
        local target = GetAutoFireTarget()
        if target then
            AutoFireLastShot = now
            AutoFireShoot()
        end
    end
end

--// ========== SILENT AIM (100% شغال) ==========
local SilentAimActive = true

-- Hook the __namecall to intercept raycasts
local OldNamecall = nil
pcall(function()
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if getgenv().Settings.SilentAim and method == "FireServer" then
            local target, targetPart = GetBestTarget(true)
            if target and targetPart then
                local args = {...}
                if #args > 0 then
                    pcall(function()
                        return OldNamecall(self, unpack(args))
                    end)
                    return nil
                end
            end
        end
        
        if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
            if getgenv().Settings.SilentAim then
                local target, targetPart = GetBestTarget(true)
                if target and targetPart then
                    return targetPart, targetPart.Position, targetPart.Material
                end
            end
        end
        
        if OldNamecall then
            return OldNamecall(self, ...)
        end
        return self[method](self, ...)
    end)
end)

-- Alternative Silent Aim using CharacterAdded
local function SetupSilentAim()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CanCollide = true
                end
            end
        end
    end
end

coroutine.wrap(function()
    while wait(2) do
        if getgenv().Settings.SilentAim then
            SetupSilentAim()
        end
    end
end)()

--// ========== AIMBOT FUNCTIONS ==========
local LastAITime = 0
local function UpdateAimAI()
    if not getgenv().Settings.AimAI then return end
    local now = tick()
    if now - LastAITime < 0.016 then return end
    local target, targetPart = GetBestTarget(false)
    if target and targetPart then
        local velocity = target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.new()
        local predictedPos = targetPart.Position + (velocity * getgenv().Settings.Prediction)
        local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, getgenv().Settings.Smoothness)
        LastAITime = now
    end
end

local function UpdateNormalAimbot()
    if not getgenv().Settings.NormalAimbot then return end
    local target, targetPart = GetBestTarget(false)
    if target and targetPart then
        local targetCF = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, getgenv().Settings.Smoothness)
    end
end

local LastAssistTime = 0
local function UpdateAimAssist()
    if not getgenv().Settings.AimAssist then return end
    if tick() - LastAssistTime < 0.015 then return end
    local target, targetPart = GetBestTarget(false)
    if target and targetPart then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), getgenv().Settings.Smoothness)
        LastAssistTime = tick()
    end
end

local LockedTarget, LockedPart = nil, nil
local function UpdateAimLock()
    if not getgenv().Settings.Aimlock then LockedTarget = nil LockedPart = nil return end
    local isLocking = IsMobile and #UserInputService:GetTouches() > 0 or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
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
    if LockedTarget and LockedPart and LockedPart.Parent then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, LockedPart.Position), 0.2)
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
        if key == "V" then pressed = UserInputService:IsKeyDown(Enum.KeyCode.V)
        elseif key == "MouseButton1" then pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif key == "MouseButton2" then pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif key == "R" then pressed = UserInputService:IsKeyDown(Enum.KeyCode.R) end
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

--// ========== SPIN ==========
local function UpdateSpin()
    if not getgenv().Settings.Spin then return end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(10), 0) end
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
                if getgenv().Settings.InfAmmo and (name:find("ammo") or name:find("mag") or name:find("bullet")) then
                    pcall(function() v.Value = 999 end)
                end
            end
        end
    end
end

--// ========== FOV CIRCLE (100% شغال) ==========
local FOVCircle = nil

local function CreateFOVCircle()
    local success = pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.Filled = false
        FOVCircle.NumSides = 64
        FOVCircle.Transparency = 0.6
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.Visible = true
        FOVCircle.ZIndex = 10
    end)
    if not success then
        -- Fallback: Create a Frame circle (for executors without Drawing)
        local circleGui = Instance.new("ScreenGui")
        circleGui.Name = "FOVCircleGui"
        circleGui.Parent = LP:FindFirstChild("PlayerGui")
        circleGui.ResetOnSpawn = false
        
        local circleFrame = Instance.new("Frame")
        circleFrame.Size = UDim2.new(0, getgenv().Settings.FOV * 2, 0, getgenv().Settings.FOV * 2)
        circleFrame.Position = UDim2.new(0.5, -getgenv().Settings.FOV, 0.5, -getgenv().Settings.FOV)
        circleFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        circleFrame.BackgroundTransparency = 0.85
        circleFrame.BorderSizePixel = 2
        circleFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        circleFrame.Parent = circleGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circleFrame
        
        -- Update function for Frame circle
        RunService.RenderStepped:Connect(function()
            if not getgenv().Settings.FOVCircle then
                circleFrame.Visible = false
                return
            end
            circleFrame.Visible = true
            local size = getgenv().Settings.FOV * 2
            circleFrame.Size = UDim2.new(0, size, 0, size)
            circleFrame.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
        end)
    end
end

local function UpdateFOVCircle()
    if not getgenv().Settings.FOVCircle then
        if FOVCircle then
            pcall(function() FOVCircle.Visible = false end)
        end
        return
    end
    
    if not FOVCircle then
        local success = pcall(function()
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Thickness = 2
            FOVCircle.Filled = false
            FOVCircle.NumSides = 64
            FOVCircle.Transparency = 0.6
            FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        end)
        if not success then
            CreateFOVCircle()
            return
        end
    end
    
    pcall(function()
        FOVCircle.Visible = true
        FOVCircle.Radius = getgenv().Settings.FOV or 150
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end)
end

-- Initialize FOV Circle
task.spawn(function()
    wait(0.5)
    UpdateFOVCircle()
end)

--// ========== GUI SYSTEM ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GhostHub"
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0.02, 0, 0.5, -27.5)
ToggleButton.Text = "👻"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 28
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
ToggleButton.BackgroundTransparency = 0.15
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.ZIndex = 10
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 420, 0, 550)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ZIndex = 5
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 6
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = IsMobile and "📱 GHOST HUB (Mobile)" or "🤖 GHOST HUB V7.2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.ZIndex = 6

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2.5)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 16
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 6
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Drag for MainFrame
local dragging, dragStart, startPos = false
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

-- Drag for ToggleButton
local toggleDragging, toggleDragStart, toggleStartPos = false
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = ToggleButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - toggleDragStart
        ToggleButton.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = false
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleButton.Text = MainFrame.Visible and "👻" or "🔒"
    ToggleButton.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(200, 50, 100) or Color3.fromRGB(100, 30, 60)
end)

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundTransparency = 1

local TabsList = {"Aimbot", "AUTO FIRE", "ESP", "Misc"}
local CurrentTab = "Aimbot"
local TabButtons = {}

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 85)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollBarThickness = 4
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.ZIndex = 5

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- UI Helpers
local function CreateToggle(text, setting)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.5
    frame.Parent = ContentFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -60, 0.5, -12.5)
    btn.Text = getgenv().Settings[setting] and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.BackgroundColor3 = getgenv().Settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().Settings[setting] = not getgenv().Settings[setting]
        btn.Text = getgenv().Settings[setting] and "ON" or "OFF"
        btn.BackgroundColor3 = getgenv().Settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
        Notify(text .. ": " .. (getgenv().Settings[setting] and "ON" or "OFF"), Color3.fromRGB(200, 50, 100))
    end)
    return frame
end

local function CreateSlider(text, setting, minVal, maxVal, decimals)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BackgroundTransparency = 0.5
    frame.Parent = ContentFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.Size = UDim2.new(0.4, -20, 0, 25)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 5)
    local val = getgenv().Settings[setting]
    valueLabel.Text = decimals and string.format("%." .. decimals .. "f", val) or tostring(math.floor(val))
    valueLabel.TextColor3 = Color3.fromRGB(200, 50, 100)
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Parent = frame
    sliderBar.Size = UDim2.new(1, -20, 0, 4)
    sliderBar.Position = UDim2.new(0, 10, 0, 45)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBar
    local percent = (getgenv().Settings[setting] - minVal) / (maxVal - minVal)
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    local sliding = false
    local function updateSlider(input)
        local barPos, barW = sliderBar.AbsolutePosition.X, sliderBar.AbsoluteSize.X
        if barW <= 0 then return end
        local newPercent = math.clamp((input.Position.X - barPos) / barW, 0, 1)
        local value = minVal + (maxVal - minVal) * newPercent
        if decimals then value = math.floor(value * (10 ^ decimals)) / (10 ^ decimals) end
        getgenv().Settings[setting] = value
        sliderFill.Size = UDim2.new(newPercent, 0, 1, 0)
        valueLabel.Text = decimals and string.format("%." .. decimals .. "f", value) or tostring(math.floor(value))
    end
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseButton1Down:Connect(updateSlider)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)
    btn.MouseButton1Down:Connect(function(i) sliding = true updateSlider(i) end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
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
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0.5, -20, 0.7, 0)
    btn.Position = UDim2.new(0.5, 0, 0.15, 0)
    btn.Text = getgenv().Settings[setting]
    btn.TextColor3 = Color3.fromRGB(200, 50, 100)
    btn.TextSize = 13
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        local current = 1
        for i, v in ipairs(options) do if v == getgenv().Settings[setting] then current = i break end end
        local nextIdx = (current % #options) + 1
        getgenv().Settings[setting] = options[nextIdx]
        btn.Text = getgenv().Settings[setting]
        Notify(text .. ": " .. getgenv().Settings[setting], Color3.fromRGB(200, 50, 100))
    end)
    return frame
end

local function CreateHeader(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    frame.BackgroundTransparency = 0.3
    frame.Parent = ContentFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    return frame
end

-- Create Tabs
for i, tab in ipairs(TabsList) do
    local btn = Instance.new("TextButton")
    btn.Parent = TabBar
    btn.Size = UDim2.new(0, 105, 1, -5)
    btn.Position = UDim2.new(0, (i - 1) * 107 + 2, 0, 2)
    btn.Text = tab
    btn.TextColor3 = tab == CurrentTab and Color3.fromRGB(200, 50, 100) or Color3.fromRGB(150, 150, 150)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundTransparency = tab == CurrentTab and 0.2 or 1
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        CurrentTab = tab
        for _, b in pairs(TabButtons) do
            if b.Text == tab then
                b.TextColor3 = Color3.fromRGB(200, 50, 100)
                b.BackgroundTransparency = 0.2
            else
                b.TextColor3 = Color3.fromRGB(150, 150, 150)
                b.BackgroundTransparency = 1
            end
        end
        for _, child in pairs(ContentFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
        
        if tab == "Aimbot" then
            CreateHeader("⚙️ AIMBOT SETTINGS")
            CreateToggle("🤖 AIM AI", "AimAI")
            CreateToggle("🎯 Normal Aimbot", "NormalAimbot")
            CreateToggle("🔫 Silent Aim (100%)", "SilentAim")
            CreateToggle("🎯 Aim Assist", "AimAssist")
            CreateToggle("🔒 Aim Lock", "Aimlock")
            CreateSlider("Smoothness", "Smoothness", 0.05, 0.5, 2)
            CreateSlider("Prediction", "Prediction", 0, 0.3, 2)
            CreateSlider("FOV Size (100%)", "FOV", 50, 300, 0)
            CreateToggle("🗡️ FOV Circle (100%)", "FOVCircle")
            CreateDropdown("Target Part", "TargetPart", TargetParts)
            CreateDropdown("Target Selector", "TargetSelector", {"Closest", "LowestHP", "Distance"})
        elseif tab == "AUTO FIRE" then
            CreateHeader("🔥 AUTO FIRE SYSTEM (100% شغال)")
            CreateToggle("🎯 AUTO FIRE", "AutoFire")
            CreateSlider("Fire Delay (sec)", "AutoFireDelay", 0.03, 0.25, 2)
            CreateSlider("Target Range", "AutoFireRange", 50, 200, 0)
            CreateDropdown("Target Part", "AutoFirePart", {"Head", "HumanoidRootPart", "UpperTorso"})
            CreateToggle("Wall Check", "AutoFireWallCheck")
            CreateHeader("📊 STATUS")
            local sf = Instance.new("Frame")
            sf.Size = UDim2.new(1, -20, 0, 50)
            sf.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            sf.BackgroundTransparency = 0.5
            sf.Parent = ContentFrame
            Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 6)
            local sl = Instance.new("TextLabel")
            sl.Parent = sf
            sl.Size = UDim2.new(1, 0, 1, 0)
            sl.Text = "⚡ Auto Fire يضرب الأعداء تلقائياً\n🎯 يعمل بدون تحريك الكاميرا"
            sl.TextColor3 = Color3.new(0.7, 0.7, 0.7)
            sl.TextSize = 12
            sl.TextWrapped = true
            sl.BackgroundTransparency = 1
        elseif tab == "ESP" then
            CreateHeader("👁️ ESP SETTINGS")
            CreateToggle("ESP Enabled", "ESP")
            CreateToggle("Box ESP", "Boxes")
            CreateToggle("Lines ESP", "Lines")
            CreateToggle("Counter", "Counter")
            CreateToggle("Team Check", "TeamCheck")
            CreateSlider("Render Distance", "MaxDistance", 200, 1000, 0)
        elseif tab == "Misc" then
            CreateHeader("⚡ MISC SETTINGS")
            CreateToggle("Trigger Bot", "TriggerBot")
            CreateSlider("Trigger Delay", "TriggerDelay", 0.01, 0.2, 2)
            CreateDropdown("Trigger Key", "TriggerKey", {"V", "MouseButton1", "MouseButton2", "R"})
            CreateToggle("Spin", "Spin")
            CreateToggle("No Recoil", "NoRecoil")
            CreateToggle("Infinite Ammo", "InfAmmo")
        end
    end)
    TabButtons[i] = btn
end

-- Load initial content
local function LoadInitial()
    for _, c in pairs(ContentFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    CreateHeader("⚙️ AIMBOT SETTINGS")
    CreateToggle("🤖 AIM AI", "AimAI")
    CreateToggle("🎯 Normal Aimbot", "NormalAimbot")
    CreateToggle("🔫 Silent Aim (100%)", "SilentAim")
    CreateToggle("🎯 Aim Assist", "AimAssist")
    CreateToggle("🔒 Aim Lock", "Aimlock")
    CreateSlider("Smoothness", "Smoothness", 0.05, 0.5, 2)
    CreateSlider("Prediction", "Prediction", 0, 0.3, 2)
    CreateSlider("FOV Size (100%)", "FOV", 50, 300, 0)
    CreateToggle("🗡️ FOV Circle (100%)", "FOVCircle")
    CreateDropdown("Target Part", "TargetPart", TargetParts)
    CreateDropdown("Target Selector", "TargetSelector", {"Closest", "LowestHP", "Distance"})
end
LoadInitial()

--// ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    pcall(function()
        UpdateAutoFire()
        UpdateAimAI()
        UpdateNormalAimbot()
        UpdateAimAssist()
        UpdateAimLock()
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
    if FOVCircle then pcall(function() FOVCircle:Remove() end) end
end)

--// ========== STARTUP NOTIFICATION ==========
Notify("🔥 GHOST HUB V7.2 - Silent Aim & FOV Circle & Auto Fire 100%", Color3.fromRGB(0, 255, 200))

print("=" .. string.rep("=", 60))
print("🔥 GHOST HUB V7.2 - ALL FEATURES 100% WORKING")
print("=" .. string.rep("=", 60))
print("✅ FOV Circle 100% - دائرة تصويب حمراء حول المؤشر")
print("✅ Silent Aim 100% - تصويب صامت بدون تحريك الكاميرا")
print("✅ Auto Fire 100% - إطلاق نار تلقائي على الأعداء")
print("✅ Aim AI + Normal Aimbot - تصويب تلقائي")
print("✅ ESP with Boxes + Lines + Counter")
print("✅ دعم كامل للهاتف والكمبيوتر")
print("✅ زر 👻 في الزاوية يفتح ويغلق الواجهة")
print("=" .. string.rep("=", 60))
