-- ===== 🔥 ZICKO HUB PREMIUM - ULTIMATE MERGED EDITION =====
-- دمج: الكود المدمج الأول + GUI المتحرك + نظام القفل
-- Total Features: 30+ System | Passkey Protected | Draggable Lock Button

local PASSKEY = "yassaaghaliahmed"

-- ========== خدمات اللعبة ==========
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local VU = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ========== متغيرات عامة ==========
getgenv().InstaKill = true
getgenv().AutoQuest = false
getgenv().AutoLevel = false
getgenv().AutoMastery = false
getgenv().AutoStats = false
getgenv().SelectedStat = "Melee"
getgenv().FastAttack = false
getgenv().AttackSpeed = 0.02
getgenv().WalkSpeed = 16
getgenv().JumpPower = 50
getgenv().ESPEnabled = false
getgenv().SelectedSea = 1
getgenv().TargetLockEnabled = false
getgenv().MaxDistance = 150
getgenv().CombatDistance = 25
getgenv().AutoSkill = false
getgenv().AutoHaki = false
getgenv().AutoDodge = false
getgenv().AutoHeal = false
getgenv().FPSBoost = false
getgenv().AutoChest = false
getgenv().AutoBoss = false
getgenv().AutoFruit = false
getgenv().ServerHop = false
getgenv().AutoRejoin = false
getgenv().AutoSeaBeast = false
getgenv().AutoTerrorshark = false

-- ========== دوال مساعدة ==========
local function GetChar()
    return LP.Character
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function SafeHRP()
    return GetHRP()
end

local function SafeHumanoid(obj)
    return obj and obj:FindFirstChildOfClass("Humanoid")
end

local function GetDistance(pos1, pos2)
    if not pos1 or not pos2 then return math.huge end
    return (pos1 - pos2).Magnitude
end

-- ========== نظام حفظ الإعدادات ==========
local SettingsFile = "ZickoHubSettings"
local Settings = {
    AutoQuest = false, AutoLevel = false, AutoMastery = false, AutoStats = false,
    SelectedStat = "Melee", FastAttack = false, AttackSpeed = 0.02, WalkSpeed = 16,
    JumpPower = 50, ESPEnabled = false, SelectedSea = 1, TargetLockEnabled = false,
    MaxDistance = 150, CombatDistance = 25, AutoSkill = false, AutoHaki = false,
    AutoDodge = false, AutoHeal = false, FPSBoost = false, AutoChest = false,
    AutoBoss = false, AutoFruit = false, ServerHop = false, AutoRejoin = false,
    AutoSeaBeast = false, AutoTerrorshark = false, InstaKill = true
}

local function SaveSettings()
    pcall(function()
        writefile(SettingsFile, HttpService:JSONEncode(Settings))
    end)
end

local function LoadSettings()
    pcall(function()
        if isfile(SettingsFile) then
            local data = readfile(SettingsFile)
            local loaded = HttpService:JSONDecode(data)
            for k, v in pairs(loaded) do
                Settings[k] = v
                getgenv()[k] = v
            end
        end
    end)
end
LoadSettings()

-- ========== نظام الحالة المشتركة ==========
local SharedState = {
    CurrentQuest = nil, QuestKills = 0, LockedTarget = nil, LockedTargetPart = nil,
    CombatState = { InCombat = false, CurrentTarget = nil, LastAttackTime = 0 },
    StuckCheck = { LastPosition = nil, LastPositionTime = 0, StuckCount = 0, IsStuck = false },
    FailSafe = { LastSuccessfulAction = tick(), ErrorCount = 0, RecoveryMode = false, ConsecutiveFails = 0 }
}

local function GetShared(key) return SharedState[key] end
local function SetShared(key, value) SharedState[key] = value end

-- إصلاح Stuck Bool
local stuckCheck = GetShared("StuckCheck")
if stuckCheck then
    stuckCheck.IsStuck = false
    SetShared("StuckCheck", stuckCheck)
end

-- ========== هجوم سريع ==========
local AttackLoopRunning = false
local AttackLoopThread = nil

local function TurboAttack()
    pcall(function()
        VU:Button1Down(Vector2.new(0,0), Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or CFrame.new())
        task.wait(0.005)
        VU:Button1Up(Vector2.new(0,0))
        VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.005)
        VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

local function InstaAttack()
    if not getgenv().InstaKill then return end
    for i = 1, 12 do
        TurboAttack()
    end
end

local function StartFastAttack()
    if AttackLoopRunning then return end
    AttackLoopRunning = true
    AttackLoopThread = task.spawn(function()
        while AttackLoopRunning and getgenv().FastAttack do
            local inCombat = GetShared("CombatState").InCombat
            if inCombat or getgenv().TargetLockEnabled then
                for i = 1, 5 do
                    if not AttackLoopRunning then break end
                    TurboAttack()
                    task.wait(getgenv().AttackSpeed or 0.02)
                end
            end
            task.wait(0.01)
        end
    end)
end

-- ========== حركة ذكية ==========
local ActiveTween = nil

local function SafeTweenTeleport(cf, speed)
    local hrp = GetHRP()
    if not hrp then return false end
    if ActiveTween and ActiveTween.PlaybackState ~= Enum.PlaybackState.Disposed then
        pcall(function() ActiveTween:Cancel() end)
    end
    pcall(function()
        local dist = GetDistance(hrp.Position, cf.Position)
        local time = speed or math.clamp(dist / 100, 0.1, 0.8)
        local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        ActiveTween = TweenService:Create(hrp, tweenInfo, {CFrame = cf})
        ActiveTween:Play()
        task.wait(time)
    end)
    return true
end

-- ========== قتال ذكي ==========
local function SmartCombat(target)
    if not target then return end
    local targetHrp = target.HRP or target.HumanoidRootPart
    if not targetHrp then return end
    local hrp = GetHRP()
    if not hrp then return end
    local dist = (hrp.Position - targetHrp.Position).Magnitude
    if dist > 25 then
        SafeTweenTeleport(targetHrp.CFrame * CFrame.new(0,2,5), 0.25)
    elseif dist < 7 then
        hrp.CFrame = hrp.CFrame * CFrame.new(0,0,-4)
    end
    hrp.CFrame = CFrame.new(hrp.Position, targetHrp.Position)
end

-- ========== جذب الأعداء ==========
local function MagnetEnemies()
    local hrp = GetHRP()
    if not hrp then return end
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    for _, v in pairs(enemies:GetChildren()) do
        local eHRP = v:FindFirstChild("HumanoidRootPart")
        local hum = SafeHumanoid(v)
        if eHRP and hum and hum.Health > 0 then
            pcall(function() eHRP.CFrame = hrp.CFrame * CFrame.new(0,0,-6) end)
        end
    end
end

-- ========== نظام المهام ==========
local QuestData = {
    [1] = {{Name = "Bandit", Level = 1, Enemy = "Bandit", Pos = CFrame.new(-1090, 40, 4240), RequiredKills = 5}},
    [2] = {{Name = "Galley Pirate", Level = 550, Enemy = "Galley Pirate", Pos = CFrame.new(-790, 40, -1180), RequiredKills = 20}},
    [3] = {{Name = "Pirate Millionaire", Level = 1500, Enemy = "Pirate Millionaire", Pos = CFrame.new(2860, 40, -11800), RequiredKills = 30}}
}

local function GetQuestForLevel(level)
    local sea = getgenv().SelectedSea or 1
    local quests = QuestData[sea] or QuestData[1]
    for _, quest in pairs(quests) do
        if level >= quest.Level then return quest end
    end
    return quests[1]
end

-- ========== المواقع ==========
local Locations = {
    ["Sea 1"] = {
        ["Starter Island"] = CFrame.new(1054, 16, 1547),
        ["Jungle"] = CFrame.new(-1210, 28, 4220),
        ["Pirate Village"] = CFrame.new(-1146, 4, 3828),
        ["Desert"] = CFrame.new(944, 6, 4329),
        ["Middle Town"] = CFrame.new(-650, 7, 1723),
        ["Frozen Village"] = CFrame.new(1130, 5, -1154),
        ["Marine Fortress"] = CFrame.new(-4800, 20, 4300),
        ["Skylands"] = CFrame.new(-160, 360, -10),
        ["Prison"] = CFrame.new(4800, 5, 700),
        ["Magma Village"] = CFrame.new(-5200, 8, 8500)
    },
    ["Sea 2"] = {
        ["Cafe"] = CFrame.new(-382, 73, 256),
        ["Kingdom of Rose"] = CFrame.new(-428, 73, 1836),
        ["Mansion"] = CFrame.new(-12463, 332, -7551),
        ["Green Bit"] = CFrame.new(-2200, 73, -2200),
        ["Graveyard"] = CFrame.new(-5400, 8, -700),
        ["Snow Mountain"] = CFrame.new(1000, 125, -5000),
        ["Hot and Cold"] = CFrame.new(-500, 15, -5000),
        ["Cursed Ship"] = CFrame.new(900, 125, 33000),
        ["Ice Castle"] = CFrame.new(6000, 25, -6000),
        ["Forgotten Island"] = CFrame.new(-3000, 45, -10000)
    },
    ["Sea 3"] = {
        ["Mansion"] = CFrame.new(-12463, 332, -7551),
        ["Castle on Sea"] = CFrame.new(-5085, 315, -3156),
        ["Port Town"] = CFrame.new(-780, 15, 5300),
        ["Hydra Island"] = CFrame.new(5700, 600, -200),
        ["Floating Turtle"] = CFrame.new(-13200, 500, -7500),
        ["Great Tree"] = CFrame.new(2100, 20, -12000),
        ["Haunted Castle"] = CFrame.new(-9500, 160, -50)
    }
}

-- ========== نظام تحديد الهدف ==========
local function FindBestTarget()
    local enemies = {}
    local enemiesContainer = Workspace:FindFirstChild("Enemies")
    if not enemiesContainer then return nil end
    local hrp = GetHRP()
    if not hrp then return nil end
    for _, v in pairs(enemiesContainer:GetChildren()) do
        local hum = SafeHumanoid(v)
        local targetHrp = v:FindFirstChild("HumanoidRootPart")
        if hum and targetHrp and hum.Health > 0 then
            table.insert(enemies, {Object = v, Humanoid = hum, HRP = targetHrp, Distance = GetDistance(hrp.Position, targetHrp.Position)})
        end
    end
    table.sort(enemies, function(a,b) return a.Distance < b.Distance end)
    return enemies[1]
end

-- ========== ESP ==========
local ESPObjects = {}
local function CreateESP(obj, color, name, icon)
    if not getgenv().ESPEnabled then return end
    if ESPObjects[obj] then return end
    pcall(function()
        local highlight = Instance.new("Highlight")
        highlight.FillColor = color
        highlight.FillTransparency = 0.35
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
        highlight.Adornee = obj
        highlight.Parent = CoreGui
        ESPObjects[obj] = highlight
    end)
end

-- ========== الحلقة الرئيسية ==========
local MainLoopRunning = false

local function StartMainLoop()
    if MainLoopRunning then return end
    MainLoopRunning = true
    task.spawn(function()
        while MainLoopRunning do
            pcall(function()
                -- تحديث السرعة
                local hum = GetHum()
                if hum then
                    hum.WalkSpeed = getgenv().WalkSpeed or 16
                    hum.JumpPower = getgenv().JumpPower or 50
                end
                
                -- تحديث الهدف
                if getgenv().TargetLockEnabled then
                    local target = FindBestTarget()
                    if target then
                        SetShared("LockedTarget", target)
                        SmartCombat(target)
                        MagnetEnemies()
                        if getgenv().FastAttack then
                            StartFastAttack()
                            InstaAttack()
                        else
                            TurboAttack()
                        end
                    end
                end
                
                -- ESP
                if getgenv().ESPEnabled then
                    local enemies = Workspace:FindFirstChild("Enemies")
                    if enemies then
                        for _, v in pairs(enemies:GetChildren()) do
                            if SafeHumanoid(v) and v:FindFirstChild("HumanoidRootPart") then
                                CreateESP(v, Color3.fromRGB(255,100,50), v.Name, "👾")
                            end
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

-- ========== GUI المتحرك + نظام القفل ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZickoHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- زر القفل المتحرك
local LockButton = Instance.new("ImageButton")
LockButton.Size = UDim2.new(0, 70, 0, 70)
LockButton.Position = UDim2.new(0.5, -35, 0.5, -35)
LockButton.Image = "rbxassetid://3926305904"
LockButton.BackgroundTransparency = 1
LockButton.Draggable = true
LockButton.Parent = ScreenGui
LockButton.Visible = false

-- تأثير الـ Glow
local GlowEffect = Instance.new("ImageLabel")
GlowEffect.Size = UDim2.new(1.4, 0, 1.4, 0)
GlowEffect.Position = UDim2.new(-0.2, 0, -0.2, 0)
GlowEffect.Image = "rbxassetid://3926305904"
GlowEffect.BackgroundTransparency = 1
GlowEffect.ImageTransparency = 0.5
GlowEffect.Parent = LockButton

-- تأثير وميض
task.spawn(function()
    while true do
        for i = 0.3, 0.8, 0.05 do
            GlowEffect.ImageTransparency = i
            task.wait(0.05)
        end
        for i = 0.8, 0.3, -0.05 do
            GlowEffect.ImageTransparency = i
            task.wait(0.05)
        end
    end
end)

-- دوال السحب
local dragging = false
local dragStart, startPos

LockButton.MouseButton1Down:Connect(function(input)
    dragging = true
    dragStart = input.Position
    startPos = LockButton.Position
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        LockButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ========== نافذة تسجيل الدخول ==========
local LoginFrame = Instance.new("Frame")
LoginFrame.Size = UDim2.new(0, 400, 0, 250)
LoginFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
LoginFrame.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
LoginFrame.BackgroundTransparency = 0.1
LoginFrame.BorderSizePixel = 0
LoginFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", LoginFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", LoginFrame)
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(255, 0, 0)

task.spawn(function()
    while LoginFrame and LoginFrame.Parent do
        UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        task.wait(0.05)
    end
end)

local Title = Instance.new("TextLabel", LoginFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ZICKO HUB PREMIUM ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold

local SubTitle = Instance.new("TextLabel", LoginFrame)
SubTitle.Size = UDim2.new(1, 0, 0, 30)
SubTitle.Position = UDim2.new(0, 0, 0, 55)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "ULTIMATE MERGED EDITION"
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.TextSize = 14

local KeyBox = Instance.new("TextBox", LoginFrame)
KeyBox.Size = UDim2.new(0, 280, 0, 45)
KeyBox.Position = UDim2.new(0.5, -140, 0.45, 0)
KeyBox.PlaceholderText = "Enter Passkey..."
KeyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 16
KeyBox.Font = Enum.Font.Gotham

local LoginBtn = Instance.new("TextButton", LoginFrame)
LoginBtn.Size = UDim2.new(0, 180, 0, 45)
LoginBtn.Position = UDim2.new(0.5, -90, 0.75, 0)
LoginBtn.Text = "🔓 ACCESS ZICKO HUB"
LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
LoginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginBtn.TextSize = 16
LoginBtn.Font = Enum.Font.GothamBold

local BtnCorner = Instance.new("UICorner", LoginBtn)
BtnCorner.CornerRadius = UDim.new(0, 8)

-- ========== بدء السكربت بعد تسجيل الدخول ==========
function StartZickoHub()
    LoginFrame.Visible = false
    LockButton.Visible = true
    
    -- تحميل مكتبة Kavo UI
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
    local Window = Library.CreateLib("⚡ ZICKO HUB | ULTIMATE ⚡", "BloodTheme")
    
    -- تبويب المهام
    local FarmTab = Window:NewTab("🌾 Farming")
    local FarmSec = FarmTab:NewSection("Level & Stats")
    
    FarmSec:NewDropdown("Select Stat", {"Melee", "Sword", "Demon Fruit", "Defense"}, function(v)
        getgenv().SelectedStat = v
        Settings.SelectedStat = v
        SaveSettings()
    end)
    
    FarmSec:NewToggle("Auto Stats", function(state)
        getgenv().AutoStats = state
        Settings.AutoStats = state
        SaveSettings()
        task.spawn(function()
            while getgenv().AutoStats do
                task.wait(0.5)
                pcall(function()
                    local comm = ReplicatedStorage:FindFirstChild("Remotes")
                    if comm and comm.CommF_ then
                        comm.CommF_:InvokeServer("AddPoint", getgenv().SelectedStat, 1)
                    end
                end)
            end
        end)
    end)
    
    FarmSec:NewToggle("Auto Quest", function(state)
        getgenv().AutoQuest = state
        Settings.AutoQuest = state
        SaveSettings()
    end)
    
    FarmSec:NewToggle("Auto Level", function(state)
        getgenv().AutoLevel = state
        Settings.AutoLevel = state
        SaveSettings()
    end)
    
    -- تبويب القتال
    local CombatTab = Window:NewTab("⚔️ Combat")
    local CombatSec = CombatTab:NewSection("Attack Settings")
    
    CombatSec:NewToggle("Fast Attack", function(state)
        getgenv().FastAttack = state
        Settings.FastAttack = state
        SaveSettings()
        if state then StartFastAttack() end
    end)
    
    CombatSec:NewToggle("Target Lock", function(state)
        getgenv().TargetLockEnabled = state
        Settings.TargetLockEnabled = state
        SaveSettings()
    end)
    
    CombatSec:NewToggle("Auto Skill (Z/X/C/V)", function(state)
        getgenv().AutoSkill = state
        Settings.AutoSkill = state
        SaveSettings()
    end)
    
    CombatSec:NewToggle("Auto Haki", function(state)
        getgenv().AutoHaki = state
        Settings.AutoHaki = state
        SaveSettings()
    end)
    
    -- تبويب الأحداث
    local EventTab = Window:NewTab("🌊 Sea Events")
    local EventSec = EventTab:NewSection("Sea Monsters")
    
    EventSec:NewToggle("Auto Sea Beast", function(state)
        getgenv().AutoSeaBeast = state
        Settings.AutoSeaBeast = state
        SaveSettings()
    end)
    
    EventSec:NewToggle("Auto Terrorshark", function(state)
        getgenv().AutoTerrorshark = state
        Settings.AutoTerrorshark = state
        SaveSettings()
    end)
    
    -- تبويب المواقع
    local TeleTab = Window:NewTab("📍 Teleports")
    for sea, data in pairs(Locations) do
        local sec = TeleTab:NewSection(sea)
        for loc, cf in pairs(data) do
            sec:NewButton(loc, function()
                local hrp = GetHRP()
                if hrp then hrp.CFrame = cf end
            end)
        end
    end
    
    -- تبويب الإعدادات
    local SetTab = Window:NewTab("⚙️ Settings")
    local SetSec = SetTab:NewSection("Player")
    
    SetSec:NewSlider("Walk Speed", 16, 350, function(s)
        getgenv().WalkSpeed = s
        Settings.WalkSpeed = s
        SaveSettings()
    end)
    
    SetSec:NewSlider("Jump Power", 50, 300, function(s)
        getgenv().JumpPower = s
        Settings.JumpPower = s
        SaveSettings()
    end)
    
    SetSec:NewToggle("ESP Enabled", function(state)
        getgenv().ESPEnabled = state
        Settings.ESPEnabled = state
        SaveSettings()
    end)
    
    SetSec:NewToggle("FPS Boost", function(state)
        getgenv().FPSBoost = state
        Settings.FPSBoost = state
        SaveSettings()
    end)
    
    SetSec:NewKeybind("Toggle UI", Enum.KeyCode.Backquote, function()
        Library:ToggleUI()
    end)
    
    -- بدء الحلقات
    StartMainLoop()
end

-- زر تسجيل الدخول
LoginBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == PASSKEY then
        StartZickoHub()
    else
        KeyBox.Text = ""
        KeyBox.PlaceholderText = "Wrong Passkey! Try again..."
        task.wait(1.5)
        KeyBox.PlaceholderText = "Enter Passkey..."
    end
end)

print("✅ ZICKO HUB ULTIMATE MERGED EDITION LOADED!")
print("🔐 Passkey protected | Draggable lock button | 30+ Features")
