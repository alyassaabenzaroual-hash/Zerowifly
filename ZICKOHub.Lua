-- [[ ZICKO HUB PREMIUM - THE OMNI EDITION V12.0 ]]
-- Total Features: Auto Farm, Sea Events, Boss Hunter, Chests, Fruits, ESP, Teleports
-- Passkey: yassaaghaliahmed | Toggle Key: ₩ (Backquote)

local PASSKEY = "yassaaghaliahmed"

local function SafeHRP()
    local LP = game:GetService("Players").LocalPlayer
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        return LP.Character.HumanoidRootPart
    end
    return nil
end

local function SafeHumanoid(obj)
    return obj and obj:FindFirstChild("Humanoid")
end

-- [ LOCATIONS - نفس الشيء ]
local Locations = { -- (ما لمسته)
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

-- UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("⚡ ZICKO HUB: GIGA EDITION ⚡", "BloodTheme")

-- GLOBALS (نفسها)
getgenv().AutoStats = false
getgenv().SelectedStat = "Melee"
getgenv().AutoSeaBeast = false
getgenv().AutoTerrorshark = false
getgenv().AutoPiranha = false
getgenv().AutoBoss = false
getgenv().AutoFruit = false
getgenv().FastAttack = true
getgenv().WalkSpeed = 16

local LP = game:GetService("Players").LocalPlayer
local VU = game:GetService("VirtualUser")

function StartZickoHub()

    local FarmTab = Window:NewTab("Auto Farming")
    local StatSec = FarmTab:NewSection("Level & Stats")

    StatSec:NewDropdown("Select Stat", "Points Target", {"Melee", "Sword", "Demon Fruit", "Defense"}, function(v)
        getgenv().SelectedStat = v
    end)

    StatSec:NewToggle("Auto Stats", "Auto Points", function(state)
        getgenv().AutoStats = state
        task.spawn(function()
            while getgenv().AutoStats do
                task.wait(0.5)
                pcall(function()
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AddPoint", getgenv().SelectedStat, 1)
                end)
            end
        end)
    end)

    StatSec:NewToggle("Fast Attack V2", "No Animation Delay", function(v)
        getgenv().FastAttack = v
    end)

    -- SEA
    local SeaTab = Window:NewTab("Sea Events")
    local SeaSec = SeaTab:NewSection("Sea Monsters")

    SeaSec:NewToggle("Auto Sea Beast", "Kill SB Instantly", function(state)
        getgenv().AutoSeaBeast = state
        task.spawn(function()
            while getgenv().AutoSeaBeast do
                task.wait(1)
                if workspace:FindFirstChild("SeaBeasts") then
                    for _, v in pairs(workspace.SeaBeasts:GetChildren()) do
                        local hum = SafeHumanoid(v)
                        local hrp = SafeHRP()
                        if hum and hum.Health > 0 and hrp and v.PrimaryPart then
                            repeat
                                task.wait()
                                hrp.CFrame = v.PrimaryPart.CFrame * CFrame.new(0,45,0)
                                if getgenv().FastAttack then
                                    VU:CaptureController()
                                    VU:ClickButton1(Vector2.new(0,0))
                                end
                            until hum.Health <= 0 or not getgenv().AutoSeaBeast
                        end
                    end
                end
            end
        end)
    end)

    SeaSec:NewToggle("Auto Terrorshark", "Farms Terrorsharks", function(state)
        getgenv().AutoTerrorshark = state
        task.spawn(function()
            while getgenv().AutoTerrorshark do
                task.wait(0.5)
                if workspace:FindFirstChild("Enemies") then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        local hum = SafeHumanoid(v)
                        local hrp = SafeHRP()
                        if v.Name == "Terrorshark" and hum and hrp and v:FindFirstChild("HumanoidRootPart") then
                            repeat
                                task.wait()
                                hrp.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,35,0)
                            until hum.Health <= 0 or not getgenv().AutoTerrorshark
                        end
                    end
                end
            end
        end)
    end)

    -- BOSS
    local HuntTab = Window:NewTab("Boss & Fruit")

    HuntTab:NewSection("Bosses"):NewToggle("Auto Boss Killer", "Kill All Bosses", function(s)
        getgenv().AutoBoss = s
        task.spawn(function()
            while getgenv().AutoBoss do
                task.wait(0.5)
                if workspace:FindFirstChild("Enemies") then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        local hum = SafeHumanoid(v)
                        local hrp = SafeHRP()
                        if hum and hrp and v:FindFirstChild("HumanoidRootPart") then
                            if v.Name:find("Boss") or v:FindFirstChild("Configuration") then
                                repeat
                                    task.wait()
                                    hrp.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,15,0)
                                    if getgenv().FastAttack then
                                        VU:CaptureController()
                                        VU:ClickButton1(Vector2.new(0,0))
                                    end
                                until hum.Health <= 0 or not getgenv().AutoBoss
                            end
                        end
                    end
                end
            end
        end)
    end)

    HuntTab:NewSection("Items"):NewToggle("Auto Fruit", "Teleport to Fruit", function(s)
        getgenv().AutoFruit = s
        task.spawn(function()
            while getgenv().AutoFruit do
                task.wait(0.5)
                local hrp = SafeHRP()
                if hrp then
                    for _, v in pairs(workspace:GetChildren()) do
                        if v:IsA("Tool") and v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                            hrp.CFrame = v.Handle.CFrame
                        end
                    end
                end
            end
        end)
    end)

    -- TELEPORT (نفسه)
    local TeleTab = Window:NewTab("Teleports")
    for sea, data in pairs(Locations) do
        local sec = TeleTab:NewSection(sea)
        for loc, cf in pairs(data) do
            sec:NewButton(loc, "Go to " .. loc, function()
                local hrp = SafeHRP()
                if hrp then hrp.CFrame = cf end
            end)
        end
    end

    -- SETTINGS
    local SetTab = Window:NewTab("Settings")
    SetTab:NewSection("Player"):NewSlider("WalkSpeed", "Speed", 500, 16, function(s)
        getgenv().WalkSpeed = s
    end)

    SetTab:NewSection("System"):NewKeybind("Toggle UI", "Key: ₩", Enum.KeyCode.Backquote, function()
        Library:ToggleUI()
    end)

    task.spawn(function()
        while task.wait(0.1) do
            pcall(function()
                if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                    LP.Character.Humanoid.WalkSpeed = getgenv().WalkSpeed
                end
            end)
        end
    end)
end

-- LOGIN (نفسه بس task.spawn)
local function ShowLogin()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 350, 0, 200)
    Main.Position = UDim2.new(0.5, -175, 0.5, -100)
    Main.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
    Instance.new("UICorner", Main)

    local UIStroke = Instance.new("UIStroke", Main)
    UIStroke.Thickness = 3
    task.spawn(function()
        while task.wait() do
            UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
    end)

    local KeyBox = Instance.new("TextBox", Main)
    KeyBox.Size = UDim2.new(0, 260, 0, 45)
    KeyBox.Position = UDim2.new(0.5, -130, 0.35, 0)
    KeyBox.PlaceholderText = "Enter Passkey..."
    KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)

    local LoginBtn = Instance.new("TextButton", Main)
    LoginBtn.Size = UDim2.new(0, 140, 0, 40)
    LoginBtn.Position = UDim2.new(0.5, -70, 0.7, 0)
    LoginBtn.Text = "ACCESS ZICKO HUB"
    LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    LoginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    LoginBtn.MouseButton1Click:Connect(function()
        if KeyBox.Text == PASSKEY then
            ScreenGui:Destroy()
            StartZickoHub()
        end
    end)
end

ShowLogin()
