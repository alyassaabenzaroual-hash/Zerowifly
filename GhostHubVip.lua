--// ============================================
--// GHOST HUB V7.2 ULTIMATE (COMPLETE INTEGRATION)
--// ============================================
--// SERVICES & INITIALIZATION
--// ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

--// ============================================
--// STATE MANAGER (نظام إدارة الحالة المتقدم)
--// ============================================
local StateManager = {
    IsRunning = true,
    CurrentTarget = nil,
    LastReliableTick = tick(),
    LastFrameTime = tick(),
    FrameCount = 0,
    AverageFPS = 60,
    Cache = {
        ESP = {},
        Players = {},
        RaycastResults = {}
    },
    RecoveryAttempts = 0,
    MaxRecoveryAttempts = 3
}

--// ============================================
--// FAIL-SAFE SYSTEM (نظام حماية من التعليق)
--// ============================================
local FailSafeSystem = {
    Enabled = true,
    CheckInterval = 2,
    LastCheck = tick(),
    HeartbeatStatus = true,
    RenderStatus = true,
    
    Check = function()
        if not FailSafeSystem.Enabled then return end
        
        local now = tick()
        if now - StateManager.LastReliableTick > 5 then
            warn("[GhostHub] ⚠️ Fail-safe triggered! Attempting recovery...")
            StateManager.RecoveryAttempts = StateManager.RecoveryAttempts + 1
            
            if StateManager.RecoveryAttempts <= StateManager.MaxRecoveryAttempts then
                FailSafeSystem.Recovery()
            else
                FailSafeSystem.FullReset()
            end
        end
        
        -- Monitor Heartbeat health
        if now - FailSafeSystem.LastCheck >= FailSafeSystem.CheckInterval then
            if not FailSafeSystem.HeartbeatStatus then
                warn("[GhostHub] ⚠️ Heartbeat appears frozen, reconnecting...")
                FailSafeSystem.ReconnectHeartbeat()
            end
            if not FailSafeSystem.RenderStatus then
                warn("[GhostHub] ⚠️ RenderStepped appears frozen, reconnecting...")
                FailSafeSystem.ReconnectRender()
            end
            FailSafeSystem.LastCheck = now
            FailSafeSystem.HeartbeatStatus = false
            FailSafeSystem.RenderStatus = false
        end
    end,
    
    Recovery = function()
        NotificationSystem.Show("🔄 System Recovery in progress...", 1.5, "warning")
        
        -- Reset critical systems
        pcall(function()
            if SilentAimManager then SilentAimManager.Update() end
            if ESPManager and ESPManager.ClearAll then ESPManager.ClearAll() end
            StateManager.Cache.ESP = {}
        end)
        
        StateManager.LastReliableTick = tick()
        StateManager.RecoveryAttempts = 0
        
        NotificationSystem.Show("✅ System recovered successfully!", 2, "success")
    end,
    
    FullReset = function()
        warn("[GhostHub] 🔄 Performing full system reset...")
        NotificationSystem.Show("⚠️ Performing full system reset...", 2, "warning")
        
        -- Clear all drawings
        pcall(function()
            for _, drawings in pairs(StateManager.Cache.ESP) do
                if drawings then
                    for _, drawing in pairs(drawings) do
                        if drawing and drawing.Remove then drawing:Remove() end
                    end
                end
            end
            StateManager.Cache.ESP = {}
        end)
        
        -- Reset hooks if needed
        pcall(function()
            if SilentAimManager and SilentAimManager.Unhook then
                SilentAimManager.Unhook()
                task.wait(0.1)
                SilentAimManager.HookRaycast()
            end
        end)
        
        StateManager.LastReliableTick = tick()
        StateManager.RecoveryAttempts = 0
        
        NotificationSystem.Show("✅ System reset complete!", 2, "success")
    end,
    
    ReconnectHeartbeat = function()
        pcall(function()
            RunService.Heartbeat:Connect(function()
                FailSafeSystem.HeartbeatStatus = true
                StateManager.LastReliableTick = tick()
            end)
        end)
    end,
    
    ReconnectRender = function()
        pcall(function()
            RunService.RenderStepped:Connect(function()
                FailSafeSystem.RenderStatus = true
            end)
        end)
    end
}

--// ============================================
--// ANTI-CRASH PROTECTION
--// ============================================
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[GhostHub] Error:", result)
        StateManager.LastReliableTick = tick()
    end
    return result
end

--// ============================================
--// PERFORMANCE MONITOR
--// ============================================
local PerformanceMonitor = {
    UpdateFPS = function()
        local now = tick()
        local delta = now - StateManager.LastFrameTime
        StateManager.FrameCount = StateManager.FrameCount + 1
        
        if delta >= 1 then
            StateManager.AverageFPS = StateManager.FrameCount
            StateManager.FrameCount = 0
            StateManager.LastFrameTime = now
        end
    end,
    
    GetFPS = function()
        return StateManager.AverageFPS
    end
}

--// ============================================
--// GHOST HUB V7.2
--// ============================================
getgenv().GhostHub = {
    Version = "7.2",
    Name = "Ghost Hub V7",
    Loaded = false,
    StartTime = tick(),
    Themes = {
        Dark = {Bg = Color3.fromRGB(20, 20, 25), Accent = Color3.fromRGB(200, 50, 100)},
        Neon = {Bg = Color3.fromRGB(10, 10, 15), Accent = Color3.fromRGB(0, 255, 255)},
        Custom = {Bg = Color3.fromRGB(25, 20, 35), Accent = Color3.fromRGB(150, 50, 200)}
    },
    CurrentTheme = "Dark"
}

--// ============================================
--// DEBUG OVERLAY
--// ============================================
local DebugOverlay = {
    Enabled = false,
    Frame = nil,
    FPSText = nil,
    PingText = nil,
    PlayersText = nil,
    TargetText = nil,
    LastUpdate = 0,
    
    Create = function()
        if DebugOverlay.Frame then return end
        
        local sg = Instance.new("ScreenGui")
        sg.Name = "GhostHubDebug"
        sg.Parent = LP:WaitForChild("PlayerGui")
        sg.ResetOnSpawn = false
        
        DebugOverlay.Frame = Instance.new("Frame", sg)
        DebugOverlay.Frame.Size = UDim2.new(0, 220, 0, 105)
        DebugOverlay.Frame.Position = UDim2.new(0, 10, 0, 10)
        DebugOverlay.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        DebugOverlay.Frame.BackgroundTransparency = 0.6
        DebugOverlay.Frame.Visible = false
        
        local corner = Instance.new("UICorner", DebugOverlay.Frame)
        corner.CornerRadius = UDim.new(0, 8)
        
        DebugOverlay.FPSText = Instance.new("TextLabel", DebugOverlay.Frame)
        DebugOverlay.FPSText.Size = UDim2.new(1, -10, 0, 22)
        DebugOverlay.FPSText.Position = UDim2.new(0, 5, 0, 5)
        DebugOverlay.FPSText.BackgroundTransparency = 1
        DebugOverlay.FPSText.TextColor3 = Color3.fromRGB(0, 255, 0)
        DebugOverlay.FPSText.TextSize = 13
        DebugOverlay.FPSText.TextXAlignment = Enum.TextXAlignment.Left
        DebugOverlay.FPSText.Text = "FPS: --"
        
        DebugOverlay.PingText = Instance.new("TextLabel", DebugOverlay.Frame)
        DebugOverlay.PingText.Size = UDim2.new(1, -10, 0, 22)
        DebugOverlay.PingText.Position = UDim2.new(0, 5, 0, 27)
        DebugOverlay.PingText.BackgroundTransparency = 1
        DebugOverlay.PingText.TextColor3 = Color3.fromRGB(255, 255, 0)
        DebugOverlay.PingText.TextSize = 13
        DebugOverlay.PingText.TextXAlignment = Enum.TextXAlignment.Left
        DebugOverlay.PingText.Text = "Ping: --ms"
        
        DebugOverlay.PlayersText = Instance.new("TextLabel", DebugOverlay.Frame)
        DebugOverlay.PlayersText.Size = UDim2.new(1, -10, 0, 22)
        DebugOverlay.PlayersText.Position = UDim2.new(0, 5, 0, 49)
        DebugOverlay.PlayersText.BackgroundTransparency = 1
        DebugOverlay.PlayersText.TextColor3 = Color3.fromRGB(100, 200, 255)
        DebugOverlay.PlayersText.TextSize = 13
        DebugOverlay.PlayersText.TextXAlignment = Enum.TextXAlignment.Left
        DebugOverlay.PlayersText.Text = "Players: 0"
        
        DebugOverlay.TargetText = Instance.new("TextLabel", DebugOverlay.Frame)
        DebugOverlay.TargetText.Size = UDim2.new(1, -10, 0, 22)
        DebugOverlay.TargetText.Position = UDim2.new(0, 5, 0, 71)
        DebugOverlay.TargetText.BackgroundTransparency = 1
        DebugOverlay.TargetText.TextColor3 = Color3.fromRGB(255, 150, 100)
        DebugOverlay.TargetText.TextSize = 13
        DebugOverlay.TargetText.TextXAlignment = Enum.TextXAlignment.Left
        DebugOverlay.TargetText.Text = "Target: None"
    end,
    
    Update = function()
        if not DebugOverlay.Enabled then
            if DebugOverlay.Frame then DebugOverlay.Frame.Visible = false end
            return
        end
        
        if not DebugOverlay.Frame then DebugOverlay.Create() end
        DebugOverlay.Frame.Visible = true
        
        local now = tick()
        if now - DebugOverlay.LastUpdate < 0.3 then return end
        DebugOverlay.LastUpdate = now
        
        local fps = PerformanceMonitor.GetFPS()
        local fpsColor = fps >= 60 and Color3.fromRGB(0, 255, 0) or (fps >= 30 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
        DebugOverlay.FPSText.TextColor3 = fpsColor
        DebugOverlay.FPSText.Text = string.format("FPS: %d", fps)
        
        local ping = LP:GetNetworkPing() * 1000
        local pingColor = ping <= 100 and Color3.fromRGB(0, 255, 0) or (ping <= 200 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
        DebugOverlay.PingText.TextColor3 = pingColor
        DebugOverlay.PingText.Text = string.format("Ping: %.0fms", ping)
        
        local count = #Players:GetPlayers()
        DebugOverlay.PlayersText.Text = string.format("Players: %d", count)
        
        local target = TargetSelector and TargetSelector.CurrentTarget
        local targetName = target and target.Player and target.Player.Name or "None"
        DebugOverlay.TargetText.Text = string.format("Target: %s", targetName)
    end,
    
    Toggle = function()
        DebugOverlay.Enabled = not DebugOverlay.Enabled
        NotificationSystem.Show(string.format("Debug Overlay %s", DebugOverlay.Enabled and "ON" or "OFF"), 1, "info")
    end
}

--// ============================================
--// NOTIFICATION QUEUE SYSTEM
--// ============================================
local NotificationSystem = {
    Active = nil,
    Queue = {},
    Processing = false,
    MaxQueue = 10,
    
    Show = function(text, duration, type)
        if #NotificationSystem.Queue >= NotificationSystem.MaxQueue then
            table.remove(NotificationSystem.Queue, 1)
        end
        table.insert(NotificationSystem.Queue, {text = text, duration = duration or 2, type = type or "info"})
        if not NotificationSystem.Processing then
            NotificationSystem.ProcessQueue()
        end
    end,
    
    ProcessQueue = function()
        if #NotificationSystem.Queue == 0 then
            NotificationSystem.Processing = false
            return
        end
        
        NotificationSystem.Processing = true
        local notifData = table.remove(NotificationSystem.Queue, 1)
        
        local sg = LP:FindFirstChild("PlayerGui")
        if not sg then
            NotificationSystem.Processing = false
            return
        end
        
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0, 350, 0, 50)
        notif.Position = UDim2.new(0.5, -175, 0, -60)
        notif.BackgroundColor3 = notifData.type == "error" and Color3.fromRGB(200, 50, 50) or 
                                 notifData.type == "success" and Color3.fromRGB(50, 200, 50) or 
                                 notifData.type == "warning" and Color3.fromRGB(200, 150, 50) or
                                 Color3.fromRGB(40, 40, 50)
        notif.BackgroundTransparency = 0.1
        notif.Parent = sg
        notif.ZIndex = 10
        
        local corner = Instance.new("UICorner", notif)
        corner.CornerRadius = UDim.new(0, 10)
        
        local textLabel = Instance.new("TextLabel", notif)
        textLabel.Size = UDim2.new(1, -20, 1, 0)
        textLabel.Position = UDim2.new(0, 10, 0, 0)
        textLabel.Text = notifData.text
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextSize = 14
        textLabel.BackgroundTransparency = 1
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.Font = Enum.Font.Gotham
        
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -175, 0, 10)}):Play()
        
        task.wait(notifData.duration)
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -175, 0, -60)}):Play()
        task.wait(0.3)
        notif:Destroy()
        
        NotificationSystem.ProcessQueue()
    end
}

--// ============================================
--// SETTINGS
--// ============================================
getgenv().Settings = {
    -- Aimbot
    Aimbot = false,
    SilentAim = false,
    Aimlock = false,
    AimAssist = false,
    LegitMode = true,
    Smoothness = 0.15,
    Prediction = 0.12,
    TargetPart = "Head",
    FOV = 150,
    FOVCircle = false,
    FOVColor = Color3.fromRGB(255, 0, 0),
    TargetSelector = "Closest",
    
    -- ESP
    ESP = false,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    ESPDistance = false,
    ESPColor = Color3.fromRGB(0, 255, 0),
    TeamCheck = true,
    WallCheck = true,
    
    -- TriggerBot
    TriggerBot = false,
    TriggerDelay = 0.03,
    TriggerKey = "V",
    
    -- Visual
    LikeEffect = "Hearts",
    Spin = false,
    
    -- Performance
    FPSBoost = false,
    RenderDistance = 500,
    
    -- GUI
    Minimized = false,
    CurrentConfig = "default",
    Theme = "Dark"
}

--// ============================================
--// CONFIG SYSTEM
--// ============================================
local ConfigManager = {
    Save = function(name)
        local data = {}
        for k, v in pairs(getgenv().Settings) do
            if type(v) ~= "function" then
                data[k] = v
            end
        end
        local success = pcall(function()
            writefile("GhostHub_Config_" .. name .. ".json", HttpService:JSONEncode(data))
        end)
        if success then
            NotificationSystem.Show("✅ Config saved: " .. name, 1.5, "success")
        end
    end,
    
    Load = function(name)
        local success, data = pcall(function()
            return readfile("GhostHub_Config_" .. name .. ".json")
        end)
        if success and data then
            local decoded = HttpService:JSONDecode(data)
            for k, v in pairs(decoded) do
                getgenv().Settings[k] = v
            end
            NotificationSystem.Show("📁 Config loaded: " .. name, 1.5, "success")
            return true
        end
        return false
    end,
    
    List = function()
        local files = {}
        local success, result = pcall(function()
            return listfiles()
        end)
        if success then
            for _, file in pairs(result) do
                local name = string.match(file, "GhostHub_Config_(.*)%.json")
                if name then table.insert(files, name) end
            end
        end
        return files
    end
}

--// ============================================
--// REAL SILENT AIM (Hook-based)
--// ============================================
local SilentAimManager = {
    HookActive = false,
    OriginalRaycast = nil,
    
    GetClosestToMouse = function()
        local target = nil
        local closestDist = getgenv().Settings.FOV
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and player.Character:FindFirstChild("Humanoid") then
                local hum = player.Character.Humanoid
                if hum.Health > 0 then
                    if getgenv().Settings.TeamCheck and player.Team == LP.Team then
                        -- Skip teammate
                    else
                        local part = player.Character:FindFirstChild(getgenv().Settings.TargetPart)
                        if not part and getgenv().Settings.TargetPart == "Head" then
                            part = player.Character:FindFirstChild("Head")
                        end
                        if not part then
                            part = player.Character:FindFirstChild("HumanoidRootPart")
                        end
                        
                        if part then
                            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local mousePos = UIS:GetMouseLocation()
                                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    target = part
                                end
                            end
                        end
                    end
                end
            end
        end
        return target
    end,
    
    HookRaycast = function()
        if SilentAimManager.HookActive then return end
        
        SilentAimManager.OriginalRaycast = workspace.Raycast
        
        workspace.Raycast = function(origin, direction, params)
            local result = SilentAimManager.OriginalRaycast(workspace, origin, direction, params)
            
            if getgenv().Settings.SilentAim and StateManager.IsRunning then
                local target = SilentAimManager.GetClosestToMouse()
                if target and target.Parent then
                    -- Return the target as hit result for silent aim
                    return target, target.Position, target.CFrame.LookVector, target.Material
                end
            end
            
            return result
        end
        
        SilentAimManager.HookActive = true
    end,
    
    Unhook = function()
        if SilentAimManager.HookActive and SilentAimManager.OriginalRaycast then
            workspace.Raycast = SilentAimManager.OriginalRaycast
            SilentAimManager.HookActive = false
        end
    end,
    
    Update = function()
        if getgenv().Settings.SilentAim then
            if not SilentAimManager.HookActive then
                SilentAimManager.HookRaycast()
            end
        else
            if SilentAimManager.HookActive then
                SilentAimManager.Unhook()
            end
        end
    end
}

--// ============================================
--// PLAYER CACHE (Event-based)
--// ============================================
local PlayerCache = {
    Players = {},
    
    AddPlayer = function(player)
        if player == LP then return end
        
        PlayerCache.Players[player.UserId] = {
            Player = player,
            Character = nil,
            Hrp = nil,
            Humanoid = nil,
            Team = player.Team
        }
        
        local function onCharacterAdded(character)
            safeCall(function()
                PlayerCache.Players[player.UserId].Character = character
                PlayerCache.Players[player.UserId].Hrp = character:FindFirstChild("HumanoidRootPart")
                PlayerCache.Players[player.UserId].Humanoid = character:FindFirstChild("Humanoid")
            end)
        end
        
        local function onCharacterRemoving()
            if PlayerCache.Players[player.UserId] then
                PlayerCache.Players[player.UserId].Character = nil
                PlayerCache.Players[player.UserId].Hrp = nil
                PlayerCache.Players[player.UserId].Humanoid = nil
            end
            ESPManager.ClearPlayerDrawings(player.UserId)
        end
        
        player.CharacterAdded:Connect(onCharacterAdded)
        player.CharacterRemoving:Connect(onCharacterRemoving)
        
        if player.Character then
            onCharacterAdded(player.Character)
        end
    end,
    
    RemovePlayer = function(player)
        PlayerCache.Players[player.UserId] = nil
        ESPManager.ClearPlayerDrawings(player.UserId)
    end,
    
    GetValidTargets = function()
        local targets = {}
        for _, data in pairs(PlayerCache.Players) do
            if data.Character and data.Hrp and data.Humanoid and data.Humanoid.Health > 0 then
                if getgenv().Settings.TeamCheck and LP.Team and data.Team and LP.Team == data.Team then
                    -- Skip teammate
                else
                    table.insert(targets, {
                        Player = data.Player,
                        Character = data.Character,
                        Hrp = data.Hrp,
                        Humanoid = data.Humanoid,
                        Health = data.Humanoid.Health,
                        MaxHealth = data.Humanoid.MaxHealth,
                        Distance = (data.Hrp.Position - Camera.CFrame.Position).Magnitude
                    })
                end
            end
        end
        return targets
    end
}

--// ============================================
--// WALL CHECK
--// ============================================
local function isVisible(part)
    if not part or not part.Parent then return false end
    if not getgenv().Settings.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 1000
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

--// ============================================
--// ADVANCED TARGET SELECTOR
--// ============================================
local TargetSelector = {
    CurrentTarget = nil,
    
    GetBestTarget = function()
        local targets = PlayerCache.GetValidTargets()
        if #targets == 0 then return nil end
        
        local selector = getgenv().Settings.TargetSelector
        local bestTarget = nil
        
        if selector == "Closest" then
            local closestDist = math.huge
            for _, target in pairs(targets) do
                local targetPart = target.Character:FindFirstChild(getgenv().Settings.TargetPart) or target.Hrp
                if targetPart and isVisible(targetPart) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - UIS:GetMouseLocation()).Magnitude
                        if mouseDist < closestDist and mouseDist <= getgenv().Settings.FOV then
                            closestDist = mouseDist
                            bestTarget = target
                        end
                    end
                end
            end
            
        elseif selector == "LowestHP" then
            local lowestHP = math.huge
            for _, target in pairs(targets) do
                local targetPart = target.Character:FindFirstChild(getgenv().Settings.TargetPart) or target.Hrp
                if targetPart and isVisible(targetPart) and target.Health < lowestHP then
                    lowestHP = target.Health
                    bestTarget = target
                end
            end
            
        elseif selector == "Distance" then
            local closestDist = math.huge
            for _, target in pairs(targets) do
                local targetPart = target.Character:FindFirstChild(getgenv().Settings.TargetPart) or target.Hrp
                if targetPart and isVisible(targetPart) and target.Distance < closestDist then
                    closestDist = target.Distance
                    bestTarget = target
                end
            end
        end
        
        return bestTarget
    end,
    
    Update = function()
        if getgenv().Settings.Aimbot or getgenv().Settings.SilentAim or getgenv().Settings.AimAssist or getgenv().Settings.Aimlock then
            TargetSelector.CurrentTarget = TargetSelector.GetBestTarget()
            StateManager.CurrentTarget = TargetSelector.CurrentTarget
        end
    end
}

--// ============================================
--// AIM ASSIST (Legit + Human-like)
--// ============================================
local AimAssistManager = {
    LastTarget = nil,
    
    Update = function()
        if not getgenv().Settings.AimAssist then return end
        
        local target = TargetSelector.CurrentTarget
        if target and target.Hrp and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local targetPart = target.Character:FindFirstChild(getgenv().Settings.TargetPart) or target.Hrp
            local velocity = target.Hrp.AssemblyLinearVelocity
            local predictedPos = targetPart.Position + (velocity * getgenv().Settings.Prediction)
            
            -- Human-like randomization for legit mode
            local smoothness = getgenv().Settings.LegitMode and 
                               (getgenv().Settings.Smoothness + math.random(-3, 3)/100) or 
                               getgenv().Settings.Smoothness
            smoothness = math.clamp(smoothness, 0.05, 0.5)
            
            local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothness)
            AimAssistManager.LastTarget = target
        end
    end
}

--// ============================================
--// AIM LOCK (Sticky Target)
--// ============================================
local AimLockManager = {
    LockedTarget = nil,
    LockKey = "RightAlt",
    
    Update = function()
        if not getgenv().Settings.Aimlock then
            AimLockManager.LockedTarget = nil
            return
        end
        
        -- Lock on key press
        if UIS:IsKeyDown(Enum.KeyCode[AimLockManager.LockKey]) then
            if not AimLockManager.LockedTarget then
                AimLockManager.LockedTarget = TargetSelector.CurrentTarget
                if AimLockManager.LockedTarget then
                    NotificationSystem.Show("🔒 Locked: " .. AimLockManager.LockedTarget.Player.Name, 1, "success")
                end
            end
        else
            if not getgenv().Settings.Aimbot then
                AimLockManager.LockedTarget = nil
            end
        end
        
        -- Follow locked target
        if AimLockManager.LockedTarget and AimLockManager.LockedTarget.Hrp then
            local targetPart = AimLockManager.LockedTarget.Character:FindFirstChild(getgenv().Settings.TargetPart) or AimLockManager.LockedTarget.Hrp
            local velocity = AimLockManager.LockedTarget.Hrp.AssemblyLinearVelocity
            local predictedPos = targetPart.Position + (velocity * getgenv().Settings.Prediction)
            local targetCF = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 0.2)
        end
    end
}

--// ============================================
--// ESP SYSTEM (Optimized with cleanup)
--// ============================================
local ESPManager = {
    Drawings = {},
    LastUpdate = 0,
    UpdateInterval = 1/24, -- 24 FPS for ESP
    
    CreateDrawing = function(type, props)
        local drawing
        safeCall(function()
            if type == "Square" then
                drawing = Drawing.new("Square")
            elseif type == "Text" then
                drawing = Drawing.new("Text")
            else
                drawing = Drawing.new(type)
            end
            for k, v in pairs(props) do
                drawing[k] = v
            end
        end)
        return drawing
    end,
    
    UpdateESP = function()
        if not getgenv().Settings.ESP then
            for _, drawing in pairs(ESPManager.Drawings) do
                if drawing then drawing.Visible = false end
            end
            return
        end
        
        local now = tick()
        if now - ESPManager.LastUpdate < ESPManager.UpdateInterval then
            return
        end
        ESPManager.LastUpdate = now
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                local target = PlayerCache.Players[player.UserId]
                if target and target.Character and target.Hrp and target.Humanoid and target.Humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(target.Hrp.Position)
                    if onScreen then
                        local distance = target.Distance
                        if distance <= getgenv().Settings.RenderDistance then
                            
                            local isTeammate = getgenv().Settings.TeamCheck and LP.Team and player.Team and LP.Team == player.Team
                            local boxColor = isTeammate and Color3.fromRGB(0, 200, 255) or getgenv().Settings.ESPColor
                            
                            local size = target.Character:GetExtentsSize()
                            local topPos = Camera:WorldToViewportPoint(target.Hrp.Position + Vector3.new(0, size.Y/2, 0))
                            local bottomPos = Camera:WorldToViewportPoint(target.Hrp.Position - Vector3.new(0, size.Y/2, 0))
                            local height = bottomPos.Y - topPos.Y
                            local width = height * 0.5
                            
                            -- Box ESP
                            if getgenv().Settings.ESPBox then
                                local boxId = "box_" .. player.UserId
                                if not ESPManager.Drawings[boxId] then
                                    ESPManager.Drawings[boxId] = ESPManager.CreateDrawing("Square", {Thickness = 2, Visible = true})
                                end
                                if ESPManager.Drawings[boxId] then
                                    ESPManager.Drawings[boxId].Position = Vector2.new(screenPos.X - width/2, topPos.Y)
                                    ESPManager.Drawings[boxId].Size = Vector2.new(width, height)
                                    ESPManager.Drawings[boxId].Color = boxColor
                                    ESPManager.Drawings[boxId].Visible = true
                                end
                            end
                            
                            -- Name ESP
                            if getgenv().Settings.ESPName then
                                local nameId = "name_" .. player.UserId
                                if not ESPManager.Drawings[nameId] then
                                    ESPManager.Drawings[nameId] = ESPManager.CreateDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Size = 14, Center = true})
                                end
                                if ESPManager.Drawings[nameId] then
                                    ESPManager.Drawings[nameId].Text = player.Name
                                    ESPManager.Drawings[nameId].Position = Vector2.new(screenPos.X, screenPos.Y - 50)
                                    ESPManager.Drawings[nameId].Visible = true
                                end
                            end
                            
                            -- Health ESP
                            if getgenv().Settings.ESPHealth then
                                local healthPercent = target.Humanoid.Health / target.Humanoid.MaxHealth
                                local healthId = "health_" .. player.UserId
                                if not ESPManager.Drawings[healthId] then
                                    ESPManager.Drawings[healthId] = ESPManager.CreateDrawing("Text", {Color = Color3.fromRGB(100, 255, 100), Size = 12, Center = true})
                                end
                                if ESPManager.Drawings[healthId] then
                                    ESPManager.Drawings[healthId].Text = string.format("%.0f%%", healthPercent * 100)
                                    ESPManager.Drawings[healthId].Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                                    ESPManager.Drawings[healthId].Visible = true
                                end
                            end
                            
                            -- Distance ESP
                            if getgenv().Settings.ESPDistance then
                                local distId = "dist_" .. player.UserId
                                if not ESPManager.Drawings[distId] then
                                    ESPManager.Drawings[distId] = ESPManager.CreateDrawing("Text", {Color = Color3.fromRGB(255, 255, 100), Size = 11, Center = true})
                                end
                                if ESPManager.Drawings[distId] then
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
    
    ClearPlayerDrawings = function(userId)
        local drawingTypes = {"box", "name", "health", "dist"}
        for _, drawType in pairs(drawingTypes) do
            local drawId = drawType .. "_" .. userId
            if ESPManager.Drawings[drawId] then
                safeCall(function() ESPManager.Drawings[drawId]:Remove() end)
                ESPManager.Drawings[drawId] = nil
            end
        end
    end,
    
    ClearAll = function()
        for _, drawing in pairs(ESPManager.Drawings) do
            safeCall(function() drawing:Remove() end)
        end
        ESPManager.Drawings = {}
    end
}

--// ============================================
--// FOV CIRCLE
--// ============================================
local FOVCircle = {
    Circle = nil,
    
    Update = function()
        if not getgenv().Settings.FOVCircle then
            if FOVCircle.Circle then FOVCircle.Circle.Visible = false end
            return
        end
        
        if not FOVCircle.Circle then
            safeCall(function()
                FOVCircle.Circle = Drawing.new("Circle")
                FOVCircle.Circle.Thickness = 2
                FOVCircle.Circle.Filled = false
                FOVCircle.Circle.NumSides = 64
                FOVCircle.Circle.Transparency = 0.8
            end)
        end
        
        if FOVCircle.Circle then
            FOVCircle.Circle.Visible = true
            FOVCircle.Circle.Radius = getgenv().Settings.FOV
            FOVCircle.Circle.Color = getgenv().Settings.FOVColor
            FOVCircle.Circle.Position = UIS:GetMouseLocation()
        end
    end
}

--// ============================================
--// TRIGGER BOT (Reliable)
--// ============================================
local TriggerBotManager = {
    LastTrigger = 0,
    
    Fire = function()
        if not getgenv().Settings.TriggerBot then return end
        
        local key = getgenv().Settings.TriggerKey
        local isPressed = false
        
        if key == "V" then
            isPressed = UIS:IsKeyDown(Enum.KeyCode.V)
        elseif key == "MouseButton1" then
            isPressed = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif key == "MouseButton2" then
            isPressed = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif key == "R" then
            isPressed = UIS:IsKeyDown(Enum.KeyCode.R)
        end
        
        if isPressed and tick() - TriggerBotManager.LastTrigger >= getgenv().Settings.TriggerDelay then
            local target = Mouse.Target
            if target then
                local character = target:FindFirstAncestorWhichIsA("Model")
                if character and character:FindFirstChild("Humanoid") then
                    local player = Players:GetPlayerFromCharacter(character)
                    if player and player ~= LP then
                        safeCall(function()
                            local VIM = game:GetService("VirtualInputManager")
                            local mousePos = UIS:GetMouseLocation()
                            VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
                            task.wait()
                            VIM:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
                        end)
                        TriggerBotManager.LastTrigger = tick()
                    end
                end
            end
        end
    end
}

--// ============================================
--// PERFORMANCE MANAGER
--// ============================================
local PerformanceManager = {
    FrameTime = 0,
    LastFrame = tick(),
    FrameSkip = 0,
    
    ShouldUpdate = function()
        if not getgenv().Settings.FPSBoost then return true end
        
        local now = tick()
        PerformanceManager.FrameTime = now - PerformanceManager.LastFrame
        PerformanceManager.LastFrame = now
        
        if PerformanceManager.FrameTime > 1/30 then
            PerformanceManager.FrameSkip = (PerformanceManager.FrameSkip + 1) % 2
            return PerformanceManager.FrameSkip == 0
        end
        
        return true
    end
}

--// ============================================
--// VISUAL EFFECTS MANAGER
--// ============================================
local VisualEffectsManager = {
    Active = {},
    Max = 20,
    
    CreateHeart = function(position, color)
        if #VisualEffectsManager.Active >= VisualEffectsManager.Max then
            local oldest = table.remove(VisualEffectsManager.Active, 1)
            safeCall(function() oldest:Destroy() end)
        end
        
        local heart = Instance.new("BillboardGui")
        heart.Size = UDim2.new(0, 2, 0, 2)
        heart.StudsOffset = Vector3.new(0, 2, 0)
        heart.AlwaysOnTop = true
        heart.Parent = position.Parent or workspace
        
        local frame = Instance.new("Frame", heart)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        
        local icon = Instance.new("ImageLabel", frame)
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.Image = getgenv().Settings.LikeEffect == "Hearts" and "rbxassetid://6023426926" or "rbxassetid://6031090998"
        icon.ImageColor3 = color or Color3.fromRGB(255, 50, 100)
        
        table.insert(VisualEffectsManager.Active, heart)
        
        task.spawn(function()
            for i = 0, 30 do
                task.wait(0.033)
                if heart and heart.Parent then
                    heart.StudsOffset = Vector3.new(0, 2 + i * 0.1, 0)
                    icon.ImageTransparency = i / 30
                else
                    break
                end
            end
            safeCall(function() heart:Destroy() end)
            for i, h in pairs(VisualEffectsManager.Active) do
                if h == heart then table.remove(VisualEffectsManager.Active, i) break end
            end
        end)
    end
}

--// ============================================
--// FULL GUI SYSTEM (Tabs / Toggles / Sliders / Keybinds)
--// ============================================
local GUI = {
    Frame = nil,
    Open = true,
    Dragging = false,
    DragStart = nil,
    DragStartPos = nil,
    CurrentTab = "Aimbot",
    Tabs = {"Aimbot", "ESP", "Visual", "Misc", "Settings"},
    
    Create = function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "GhostHubGUI"
        sg.Parent = LP:WaitForChild("PlayerGui")
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        -- Main Frame
        GUI.Frame = Instance.new("Frame", sg)
        GUI.Frame.Size = UDim2.new(0, 500, 0, 450)
        GUI.Frame.Position = UDim2.new(0.5, -250, 0.25, 0)
        GUI.Frame.BackgroundColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Bg
        GUI.Frame.BackgroundTransparency = 0.05
        GUI.Frame.BorderSizePixel = 0
        
        local mainCorner = Instance.new("UICorner", GUI.Frame)
        mainCorner.CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke", GUI.Frame)
        stroke.Color = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
        stroke.Thickness = 1.5
        
        -- Title Bar
        local titleBar = Instance.new("Frame", GUI.Frame)
        titleBar.Size = UDim2.new(1, 0, 0, 40)
        titleBar.BackgroundColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
        titleBar.BackgroundTransparency = 0.2
        titleBar.BorderSizePixel = 0
        
        local titleCorner = Instance.new("UICorner", titleBar)
        titleCorner.CornerRadius = UDim.new(0, 12)
        
        local titleText = Instance.new("TextLabel", titleBar)
        titleText.Size = UDim2.new(1, -60, 1, 0)
        titleText.Position = UDim2.new(0, 15, 0, 0)
        titleText.Text = "👻 GHOST HUB V7"
        titleText.TextColor3 = Color3.new(1, 1, 1)
        titleText.TextSize = 18
        titleText.Font = Enum.Font.GothamBold
        titleText.TextXAlignment = Enum.TextXAlignment.Left
        titleText.BackgroundTransparency = 1
        
        -- Minimize Button
        local minimizeBtn = Instance.new("TextButton", titleBar)
        minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
        minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
        minimizeBtn.Text = "─"
        minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
        minimizeBtn.TextSize = 20
        minimizeBtn.BackgroundTransparency = 1
        minimizeBtn.Font = Enum.Font.GothamBold
        
        minimizeBtn.MouseButton1Click:Connect(function()
            GUI.Open = not GUI.Open
            GUI.Frame.Visible = GUI.Open
        end)
        
        -- Close Button
        local closeBtn = Instance.new("TextButton", titleBar)
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Position = UDim2.new(1, -35, 0, 5)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.TextSize = 16
        closeBtn.BackgroundTransparency = 1
        closeBtn.Font = Enum.Font.GothamBold
        
        closeBtn.MouseButton1Click:Connect(function()
            GUI.Frame.Visible = false
            GUI.Open = false
        end)
        
        -- Drag functionality
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                GUI.Dragging = true
                GUI.DragStart = input.Position
                GUI.DragStartPos = GUI.Frame.Position
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if GUI.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - GUI.DragStart
                GUI.Frame.Position = UDim2.new(
                    GUI.DragStartPos.X.Scale,
                    GUI.DragStartPos.X.Offset + delta.X,
                    GUI.DragStartPos.Y.Scale,
                    GUI.DragStartPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                GUI.Dragging = false
            end
        end)
        
        -- Tab Bar
        local tabBar = Instance.new("Frame", GUI.Frame)
        tabBar.Size = UDim2.new(1, 0, 0, 45)
        tabBar.Position = UDim2.new(0, 0, 0, 40)
        tabBar.BackgroundTransparency = 1
        
        local tabButtons = {}
        for i, tabName in pairs(GUI.Tabs) do
            local btn = Instance.new("TextButton", tabBar)
            btn.Size = UDim2.new(0, 100, 1, -5)
            btn.Position = UDim2.new(0, (i-1) * 100 + 5, 0, 2)
            btn.Text = tabName
            btn.TextColor3 = tabName == GUI.CurrentTab and getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent or Color3.fromRGB(150, 150, 150)
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamBold
            btn.BackgroundTransparency = 1
            btn.BackgroundColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
            btn.BackgroundTransparency = tabName == GUI.CurrentTab and 0.2 or 1
            
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                GUI.CurrentTab = tabName
                for _, b in pairs(tabButtons) do
                    if b.Text == tabName then
                        b.TextColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
                        b.BackgroundTransparency = 0.2
                    else
                        b.TextColor3 = Color3.fromRGB(150, 150, 150)
                        b.BackgroundTransparency = 1
                    end
                end
                GUI.UpdateContent()
            end)
            
            tabButtons[i] = btn
        end
        
        -- Content Frame
        local contentFrame = Instance.new("Frame", GUI.Frame)
        contentFrame.Size = UDim2.new(1, -20, 1, -95)
        contentFrame.Position = UDim2.new(0, 10, 0, 90)
        contentFrame.BackgroundTransparency = 1
        
        GUI.ContentFrame = contentFrame
        
        GUI.UpdateContent()
    end,
    
    CreateToggle = function(parent, y, text, setting, callback)
        local toggleFrame = Instance.new("Frame", parent)
        toggleFrame.Size = UDim2.new(1, -20, 0, 35)
        toggleFrame.Position = UDim2.new(0, 10, 0, y)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        toggleFrame.BackgroundTransparency = 0.5
        
        local corner = Instance.new("UICorner", toggleFrame)
        corner.CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel", toggleFrame)
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        
        local toggleBtn = Instance.new("Frame", toggleFrame)
        toggleBtn.Size = UDim2.new(0, 40, 0, 20)
        toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
        toggleBtn.BackgroundColor3 = getgenv().Settings[setting] and getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent or Color3.fromRGB(60, 60, 70)
        
        local toggleCorner = Instance.new("UICorner", toggleBtn)
        toggleCorner.CornerRadius = UDim.new(1, 0)
        
        local toggleCircle = Instance.new("Frame", toggleBtn)
        toggleCircle.Size = UDim2.new(0, 16, 0, 16)
        toggleCircle.Position = getgenv().Settings[setting] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
        
        local circleCorner = Instance.new("UICorner", toggleCircle)
        circleCorner.CornerRadius = UDim.new(1, 0)
        
        local btn = Instance.new("TextButton", toggleFrame)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        
        btn.MouseButton1Click:Connect(function()
            getgenv().Settings[setting] = not getgenv().Settings[setting]
            toggleBtn.BackgroundColor3 = getgenv().Settings[setting] and getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent or Color3.fromRGB(60, 60, 70)
            local targetPos = getgenv().Settings[setting] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
            if callback then callback(getgenv().Settings[setting]) end
        end)
        
        return toggleFrame
    end,
    
    CreateSlider = function(parent, y, text, setting, min, max, decimals)
        local sliderFrame = Instance.new("Frame", parent)
        sliderFrame.Size = UDim2.new(1, -20, 0, 55)
        sliderFrame.Position = UDim2.new(0, 10, 0, y)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        sliderFrame.BackgroundTransparency = 0.5
        
        local corner = Instance.new("UICorner", sliderFrame)
        corner.CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel", sliderFrame)
        label.Size = UDim2.new(0.7, 0, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        
        local valueLabel = Instance.new("TextLabel", sliderFrame)
        valueLabel.Size = UDim2.new(0.3, -20, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        valueLabel.Text = tostring(getgenv().Settings[setting])
        valueLabel.TextColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
        valueLabel.TextSize = 13
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.BackgroundTransparency = 1
        
        local sliderBar = Instance.new("Frame", sliderFrame)
        sliderBar.Size = UDim2.new(1, -20, 0, 4)
        sliderBar.Position = UDim2.new(0, 10, 0, 35)
        sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        
        local sliderCorner = Instance.new("UICorner", sliderBar)
        sliderCorner.CornerRadius = UDim.new(1, 0)
        
        local sliderFill = Instance.new("Frame", sliderBar)
        sliderFill.Size = UDim2.new((getgenv().Settings[setting] - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
        
        local fillCorner = Instance.new("UICorner", sliderFill)
        fillCorner.CornerRadius = UDim.new(1, 0)
        
        local sliderBtn = Instance.new("TextButton", sliderFrame)
        sliderBtn.Size = UDim2.new(1, 0, 1, 0)
        sliderBtn.BackgroundTransparency = 1
        sliderBtn.Text = ""
        
        local dragging = false
        sliderBtn.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local mousePos = input.Position.X
                local barPos = sliderBar.AbsolutePosition.X
                local barWidth = sliderBar.AbsoluteSize.X
                local percent = math.clamp((mousePos - barPos) / barWidth, 0, 1)
                local value = min + (max - min) * percent
                if decimals then
                    value = math.floor(value * (10^decimals)) / (10^decimals)
                end
                getgenv().Settings[setting] = math.clamp(value, min, max)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                valueLabel.Text = tostring(getgenv().Settings[setting])
            end
        end)
        
        return sliderFrame
    end,
    
    CreateDropdown = function(parent, y, text, setting, options)
        local dropdownFrame = Instance.new("Frame", parent)
        dropdownFrame.Size = UDim2.new(1, -20, 0, 40)
        dropdownFrame.Position = UDim2.new(0, 10, 0, y)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        dropdownFrame.BackgroundTransparency = 0.5
        
        local corner = Instance.new("UICorner", dropdownFrame)
        corner.CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel", dropdownFrame)
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        
        local dropdownBtn = Instance.new("TextButton", dropdownFrame)
        dropdownBtn.Size = UDim2.new(0.5, -20, 0.7, 0)
        dropdownBtn.Position = UDim2.new(0.5, 0, 0.15, 0)
        dropdownBtn.Text = getgenv().Settings[setting]
        dropdownBtn.TextColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
        dropdownBtn.TextSize = 13
        dropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        
        local btnCorner = Instance.new("UICorner", dropdownBtn)
        btnCorner.CornerRadius = UDim.new(0, 4)
        
        dropdownBtn.MouseButton1Click:Connect(function()
            local currentIndex = table.find(options, getgenv().Settings[setting]) or 1
            local nextIndex = currentIndex % #options + 1
            getgenv().Settings[setting] = options[nextIndex]
            dropdownBtn.Text = getgenv().Settings[setting]
        end)
        
        return dropdownFrame
    end,
    
    UpdateContent = function()
        for _, child in pairs(GUI.ContentFrame:GetChildren()) do
            child:Destroy()
        end
        
        local y = 5
        
        if GUI.CurrentTab == "Aimbot" then
            GUI.CreateToggle(GUI.ContentFrame, y, "🔫 Silent Aim", "SilentAim")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "🎯 Aim Assist", "AimAssist")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "🔒 Aim Lock (Hold RightAlt)", "Aimlock")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "🎮 Normal Aimbot (Right Click)", "Aimbot")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "🎭 Legit Mode", "LegitMode")
            y = y + 40
            GUI.CreateSlider(GUI.ContentFrame, y, "Smoothness", "Smoothness", 0.05, 0.5, 2)
            y = y + 60
            GUI.CreateSlider(GUI.ContentFrame, y, "Prediction", "Prediction", 0, 0.3, 2)
            y = y + 60
            GUI.CreateSlider(GUI.ContentFrame, y, "FOV Size", "FOV", 50, 300, 0)
            y = y + 60
            GUI.CreateToggle(GUI.ContentFrame, y, "Show FOV Circle", "FOVCircle")
            y = y + 40
            GUI.CreateDropdown(GUI.ContentFrame, y, "Target Part", "TargetPart", {"Head", "HumanoidRootPart", "UpperTorso", "Random"})
            y = y + 45
            GUI.CreateDropdown(GUI.ContentFrame, y, "Target Selector", "TargetSelector", {"Closest", "LowestHP", "Distance"})
            
        elseif GUI.CurrentTab == "ESP" then
            GUI.CreateToggle(GUI.ContentFrame, y, "👁️ ESP Enabled", "ESP")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "📦 Box ESP", "ESPBox")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "🏷️ Name ESP", "ESPName")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "❤️ Health ESP", "ESPHealth")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "📏 Distance ESP", "ESPDistance")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "👥 Team Check", "TeamCheck")
            y = y + 40
            GUI.CreateToggle(GUI.ContentFrame, y, "🧱 Wall Check", "WallCheck")
            y = y + 40
            GUI.CreateSlider(GUI.ContentFrame, y, "Render Distance", "RenderDistance", 200, 1000, 0)
            
        elseif GUI.CurrentTab == "Visual" then
            GUI.CreateToggle(GUI.ContentFrame, y, "🔄 Spin", "Spin")
            y = y + 40
            GUI.CreateDropdown(GUI.ContentFrame, y, "Like Effect", "LikeEffect", {"Hearts", "Stars"})
            y = y + 45
            GUI.CreateToggle(GUI.ContentFrame, y, "📊 Debug Overlay", "DebugOverlay", function(val)
                DebugOverlay.Toggle()
            end)
            
        elseif GUI.CurrentTab == "Misc" then
            GUI.CreateToggle(GUI.ContentFrame, y, "⚡ TriggerBot", "TriggerBot")
            y = y + 40
            GUI.CreateSlider(GUI.ContentFrame, y, "Trigger Delay", "TriggerDelay", 0.01, 0.2, 2)
            y = y + 60
            GUI.CreateDropdown(GUI.ContentFrame, y, "Trigger Key", "TriggerKey", {"V", "MouseButton1", "MouseButton2", "R"})
            y = y + 45
            GUI.CreateToggle(GUI.ContentFrame, y, "🚀 FPS Boost", "FPSBoost")
            y = y + 40
            
            local saveBtn = Instance.new("TextButton", GUI.ContentFrame)
            saveBtn.Size = UDim2.new(0.4, -10, 0, 35)
            saveBtn.Position = UDim2.new(0, 10, 0, y)
            saveBtn.Text = "💾 Save Config"
            saveBtn.TextColor3 = Color3.new(1, 1, 1)
            saveBtn.BackgroundColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
            saveBtn.BackgroundTransparency = 0.2
            
            local saveCorner = Instance.new("UICorner", saveBtn)
            saveCorner.CornerRadius = UDim.new(0, 6)
            
            saveBtn.MouseButton1Click:Connect(function()
                ConfigManager.Save(getgenv().Settings.CurrentConfig)
            end)
            
            local loadBtn = Instance.new("TextButton", GUI.ContentFrame)
            loadBtn.Size = UDim2.new(0.4, -10, 0, 35)
            loadBtn.Position = UDim2.new(0.5, 0, 0, y)
            loadBtn.Text = "📂 Load Config"
            loadBtn.TextColor3 = Color3.new(1, 1, 1)
            loadBtn.BackgroundColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
            loadBtn.BackgroundTransparency = 0.2
            
            local loadCorner = Instance.new("UICorner", loadBtn)
            loadCorner.CornerRadius = UDim.new(0, 6)
            
            loadBtn.MouseButton1Click:Connect(function()
                ConfigManager.Load(getgenv().Settings.CurrentConfig)
            end)
            
        elseif GUI.CurrentTab == "Settings" then
            GUI.CreateDropdown(GUI.ContentFrame, y, "Theme", "Theme", {"Dark", "Neon"})
        end
    end
}

--// ============================================
--// FLOATING BUTTON (Mobile Support)
--// ============================================
local FloatingButton = nil
local function CreateFloatingButton()
    local sg = Instance.new("ScreenGui")
    sg.Name = "GhostHubFloating"
    sg.Parent = LP:WaitForChild("PlayerGui")
    sg.ResetOnSpawn = false
    
    FloatingButton = Instance.new("ImageButton", sg)
    FloatingButton.Size = UDim2.new(0, 55, 0, 55)
    FloatingButton.Position = UDim2.new(0, 10, 0.5, -27)
    FloatingButton.BackgroundColor3 = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
    FloatingButton.BackgroundTransparency = 0.2
    FloatingButton.Image = "rbxassetid://6023426926"
    FloatingButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    
    local corner = Instance.new("UICorner", FloatingButton)
    corner.CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", FloatingButton)
    stroke.Color = getgenv().GhostHub.Themes[getgenv().Settings.Theme].Accent
    stroke.Thickness = 2
    
    -- Drag
    local dragging = false
    local dragStart, startPos
    
    FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = FloatingButton.Position
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            FloatingButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    FloatingButton.MouseButton1Click:Connect(function()
        if GUI.Frame then
            GUI.Frame.Visible = not GUI.Frame.Visible
            GUI.Open = GUI.Frame.Visible
        else
            GUI.Create()
        end
    end)
    
    FloatingButton.TouchTap:Connect(function()
        if GUI.Frame then
            GUI.Frame.Visible = not GUI.Frame.Visible
            GUI.Open = GUI.Frame.Visible
        else
            GUI.Create()
        end
    end)
end

--// ============================================
--// ANTI-IDLE SYSTEM (منع التعليق)
--// ============================================
local AntiIdle = {
    Enabled = true,
    
    Start = function()
        if not AntiIdle.Enabled then return end
        
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
        
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end)
    end
}

--// ============================================
--// MAIN LOOP WITH FAIL-SAFE INTEGRATION
--// ============================================
local function onHeartbeat()
    PerformanceMonitor.UpdateFPS()
    FailSafeSystem.HeartbeatStatus = true
    StateManager.LastReliableTick = tick()
    
    safeCall(function()
        SilentAimManager.Update()
        TargetSelector.Update()
        if getgenv().Settings.AimAssist then AimAssistManager.Update() end
        if getgenv().Settings.Aimlock then AimLockManager.Update() end
    end)
end

local function onRenderStepped()
    FailSafeSystem.RenderStatus = true
    
    if not PerformanceManager.ShouldUpdate() then return end
    
    safeCall(function()
        DebugOverlay.Update()
        ESPManager.UpdateESP()
        FOVCircle.Update()
        TriggerBotManager.Fire()
        
        if getgenv().Settings.Spin and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(10), 0)
        end
    end)
end

-- Fail-safe monitor loop
task.spawn(function()
    while StateManager.IsRunning do
        task.wait(1)
        safeCall(function()
            FailSafeSystem.Check()
        end)
    end
end)

--// ============================================
--// PLAYER EVENTS
--// ============================================
Players.PlayerAdded:Connect(function(player)
    safeCall(function() PlayerCache.AddPlayer(player) end)
end)

Players.PlayerRemoving:Connect(function(player)
    safeCall(function() 
        PlayerCache.RemovePlayer(player)
        ESPManager.ClearPlayerDrawings(player.UserId)
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LP then
        safeCall(function() PlayerCache.AddPlayer(player) end)
    end
end

--// ============================================
--// CONNECTIONS
--// ============================================
RunService.Heartbeat:Connect(onHeartbeat)
RunService.RenderStepped:Connect(onRenderStepped)

--// ============================================
--// INITIALIZATION
--// ============================================
local function Initialize()
    safeCall(function()
        DebugOverlay.Create()
        CreateFloatingButton()
        GUI.Create()
        AntiIdle.Start()
        
        print("=" .. string.rep("=", 50))
        print("👻 GHOST HUB V7.2 ULTIMATE EDITION 👻")
        print("=" .. string.rep("=", 50))
        print("✅ Full GUI System (Tabs/Toggles/Sliders/Dropdowns)")
        print("✅ Real Silent Aim (Raycast Hook)")
        print("✅ Event-based Player Cache")
        print("✅ Advanced Target Selector + WallCheck")
        print("✅ ESP with Throttling + Proper Cleanup")
        print("✅ Notification Queue System")
        print("✅ Debug Overlay + Performance Manager")
        print("✅ Config Save/Load System")
        print("✅ Mobile Support (Floating Button + Touch)")
        print("✅ Anti-Crash Protection (pcall wrappers)")
        print("✅ Fail-Safe System with Auto-Recovery")
        print("✅ Performance Monitor with FPS Tracking")
        print("✅ Anti-Idle System")
        print("=" .. string.rep("=", 50))
        
        NotificationSystem.Show("👻 Ghost Hub V7.2 Ultimate Activated!", 3, "success")
        NotificationSystem.Show("🔫 Silent Aim Hook: READY", 2, "info")
        NotificationSystem.Show("🛡️ Fail-Safe System: ENABLED", 2, "info")
        
        getgenv().GhostHub.Loaded = true
    end)
end

Initialize()
و الان
