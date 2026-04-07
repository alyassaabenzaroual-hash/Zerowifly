-- Professional Aimbot + ESP Script with FOV Circle (Lua for Roblox/Universal)
-- Supports most executors like Synapse X, KRNL, etc.
-- Paste into your executor and enjoy!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Settings
local Settings = {
    Aimbot = {
        Enabled = true,
        TeamCheck = true,
        VisibleCheck = false,
        FOV = 150, -- Field of View radius
        Smoothness = 0.1, -- Lower = Snappier (0.05-0.2 recommended)
        TargetPart = "Head" -- "Head", "HumanoidRootPart", "UpperTorso"
    },
    ESP = {
        Enabled = true,
        TeamCheck = true,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = true,
        BoxThickness = 2,
        TextSize = 14
    },
    FOVCircle = {
        Enabled = true,
        Radius = 150,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 2,
        Transparency = 0.8
    }
}

-- FOV Circle
local ScreenGui = Instance.new("ScreenGui")
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.FOVCircle.Radius
FOVCircle.Color = Settings.FOVCircle.Color
FOVCircle.Thickness = Settings.FOVCircle.Thickness
FOVCircle.Transparency = Settings.FOVCircle.Transparency
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ESP Objects
local ESPObjects = {}

-- Functions
local function WorldToScreen(Position)
    return Camera:WorldToViewportPoint(Position)
end

local function GetClosestPlayer()
    local Closest, Distance = nil, math.huge
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then continue end
            
            local Character = Player.Character
            local HumanoidRootPart = Character.HumanoidRootPart
            local Head = Character:FindFirstChild("Head")
            
            if not Head then continue end
            
            local ScreenPoint, OnScreen = WorldToScreen(Head.Position)
            local ScreenDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
            
            if ScreenDistance < Distance and ScreenDistance < Settings.Aimbot.FOV and OnScreen then
                if Settings.Aimbot.VisibleCheck then
                    local Raycast = workspace:Raycast(HumanoidRootPart.Position, (Head.Position - HumanoidRootPart.Position).Unit * 1000)
                    if Raycast and Raycast.Instance:IsDescendantOf(Character) then
                        Closest = Head
                        Distance = ScreenDistance
                    end
                else
                    Closest = Head
                    Distance = ScreenDistance
                end
            end
        end
    end
    
    return Closest
end

local function Aimbot()
    if not Settings.Aimbot.Enabled then return end
    
    local Target = GetClosestPlayer()
    if Target then
        local ScreenPoint = WorldToScreen(Target.Position)
        local MousePos = Vector2.new(Mouse.X, Mouse.Y)
        local TargetPos = Vector2.new(ScreenPoint.X, ScreenPoint.Y)
        
        local SmoothPos = MousePos:lerp(TargetPos, Settings.Aimbot.Smoothness)
        mousemoverel((smoothPos.X - Mouse.X), (smoothPos.Y - Mouse.Y))
    end
end

local function CreateESP(Player)
    if Player == LocalPlayer then return end
    
    local ESP = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    ESPObjects[Player] = ESP
end

local function UpdateESP()
    for Player, ESP in pairs(ESPObjects) do
        if not Settings.ESP.Enabled then
            for _, Object in pairs(ESP) do
                Object.Visible = false
            end
            continue
        end
        
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") then
            if Settings.ESP.TeamCheck and Player.Team == LocalPlayer.Team then
                for _, Object in pairs(ESP) do
                    Object.Visible = false
                end
                continue
            end
            
            local Character = Player.Character
            local HumanoidRootPart = Character.HumanoidRootPart
            local Humanoid = Character.Humanoid
            local Head = Character:FindFirstChild("Head")
            
            if not Head then
                for _, Object in pairs(ESP) do
                    Object.Visible = false
                end
                continue
            end
            
            local RootPart = WorldToScreen(HumanoidRootPart.Position)
            local HeadPos = WorldToScreen(Head.Position)
            local LegPos = WorldToScreen(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
            
            local Height = (RootPart.Y - LegPos.Y)
            local Width = Height / 2
            
            -- Box
            if Settings.ESP.Boxes then
                ESP.Box.Size = Vector2.new(Width, Height)
                ESP.Box.Position = Vector2.new(RootPart.X - Width / 2, RootPart.Y - Height)
                ESP.Box.Color = Color3.fromRGB(255, 0, 0)
                ESP.Box.Thickness = Settings.ESP.BoxThickness
                ESP.Box.Transparency = 1
                ESP.Box.Visible = true
            else
                ESP.Box.Visible = false
            end
            
            -- Name
            if Settings.ESP.Names then
                ESP.Name.Text = Player.Name
                ESP.Name.Size = Settings.ESP.TextSize
                ESP.Name.Center = true
                ESP.Name.Outline = true
                ESP.Name.Color = Color3.fromRGB(255, 255, 255)
                ESP.Name.Position = Vector2.new(RootPart.X, RootPart.Y - Height - 20)
                ESP.Name.Visible = true
            else
                ESP.Name.Visible = false
            end
            
            -- Distance
            if Settings.ESP.Distance then
                local Distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude)
                ESP.Distance.Text = tostring(Distance) .. "m"
                ESP.Distance.Size = Settings.ESP.TextSize
                ESP.Distance.Center = true
                ESP.Distance.Outline = true
                ESP.Distance.Color = Color3.fromRGB(0, 255, 0)
                ESP.Distance.Position = Vector2.new(RootPart.X, RootPart.Y + Height + 5)
                ESP.Distance.Visible = true
            else
                ESP.Distance.Visible = false
            end
            
            -- Health
            if Settings.ESP.Health then
                local HealthPercent = math.floor((Humanoid.Health / Humanoid.MaxHealth) * 100)
                ESP.Health.Text = "HP: " .. HealthPercent .. "%"
                ESP.Health.Size = Settings.ESP.TextSize
                ESP.Health.Center = true
                ESP.Health.Outline = true
                ESP.Health.Color = Color3.fromRGB(0, 255, 0)
                ESP.Health.Position = Vector2.new(RootPart.X - Width / 2, RootPart.Y + Height / 2)
                ESP.Health.Visible = true
            else
                ESP.Health.Visible = false
            end
            
            -- Tracer
            if Settings.ESP.Tracers then
                ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                ESP.Tracer.To = Vector2.new(RootPart.X, RootPart.Y + Height / 2)
                ESP.Tracer.Color = Color3.fromRGB(255, 0, 100)
                ESP.Tracer.Thickness = 1
                ESP.Tracer.Transparency = 1
                ESP.Tracer.Visible = true
            else
                ESP.Tracer.Visible = false
            end
        else
            for _, Object in pairs(ESP) do
                Object.Visible = false
            end
        end
    end
end

local function UpdateFOVCircle()
    if Settings.FOVCircle.Enabled then
        FOVCircle.Visible = Settings.Aimbot.Enabled
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Radius = Settings.FOVCircle.Radius
    else
        FOVCircle.Visible = false
    end
end

-- Initialize ESP for all players
for _, Player in pairs(Players:GetPlayers()) do
    CreateESP(Player)
    Player.CharacterAdded:Connect(function()
        CreateESP(Player)
    end)
end

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        CreateESP(Player)
    end)
end)

-- Main Loop
RunService.Heartbeat:Connect(function()
    UpdateFOVCircle()
    UpdateESP()
    Aimbot()
end)

-- Toggle Keybinds
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    
    if Input.KeyCode == Enum.KeyCode.Insert then
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
        Settings.ESP.Enabled = not Settings.ESP.Enabled
        print("Aimbot + ESP:", Settings.Aimbot.Enabled and "ON" or "OFF")
    end
    
    if Input.KeyCode == Enum.KeyCode.RightShift then
        Settings.FOVCircle.Enabled = not Settings.FOVCircle.Enabled
        print("FOV Circle:", Settings.FOVCircle.Enabled and "ON" or "OFF")
    end
end)

-- GUI Notification
print("=== Professional Aimbot + ESP Loaded ===")
print("Insert - Toggle Aimbot/ESP")
print("Right Shift - Toggle FOV Circle")
print("FOV Radius:", Settings.Aimbot.FOV)
print("Smoothness:", Settings.Aimbot.Smoothness)

ScreenGui.Parent = game.CoreGui
FOVCircle.Visible = Settings.FOVCircle.Enabled
