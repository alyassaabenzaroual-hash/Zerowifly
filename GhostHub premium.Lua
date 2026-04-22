-- [[ GHOST HUB PREMIUM - ULTRA HEADSHOT EDITION ]] --
-- Version: 3.5.0
-- Key: yassaamhyb

local PASSKEY = "yassaamhyb"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- الإعدادات
local Settings = {
    Aimbot = false,
    Aimlock = false,
    HeadshotOnly = false, -- ميزة الرأس فقط
    Prediction = 0.165,
    Smoothness = 0.1,
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_Health = false,
    SpinBot = false,
    WalkSpeed = 16
}

-- [ نظام التحقق ]
local function Authenticate()
    local AuthScreen = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local Frame = Instance.new("Frame", AuthScreen)
    Frame.Size = UDim2.new(0, 350, 0, 200)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Frame.BorderSizePixel = 0
    
    Instance.new("UICorner", Frame)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(170, 0, 255)
    Stroke.Thickness = 2

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Text = "GHOST HUB ACCESS"
    Title.TextColor3 = Color3.fromRGB(170, 0, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(0, 250, 0, 40)
    Input.Position = UDim2.new(0.5, -125, 0.45, -20)
    Input.PlaceholderText = "Enter Secret Key..."
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Input)

    local Submit = Instance.new("TextButton", Frame)
    Submit.Size = UDim2.new(0, 150, 0, 40)
    Submit.Position = UDim2.new(0.5, -75, 0.8, -10)
    Submit.Text = "UNLOCK HUB"
    Submit.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
    Submit.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Submit)

    Submit.MouseButton1Click:Connect(function()
        if Input.Text == PASSKEY then
            AuthScreen:Destroy()
            StartGhostHub()
        else
            Input.Text = ""
            Input.PlaceholderText = "INVALID KEY!"
            Input.PlaceholderColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end

-- [ السكربت الرئيسي ]
function StartGhostHub()
    local MainGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Size = UDim2.new(0, 400, 0, 350)
    MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    Instance.new("UICorner", MainFrame)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(170, 0, 255)
    MainStroke.Thickness = 3

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "👻 GHOST HUB PREMIUM V3.5"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1

    local function CreateButton(name, pos, callback)
        local Btn = Instance.new("TextButton", MainFrame)
        Btn.Size = UDim2.new(0, 110, 0, 35)
        Btn.Position = pos
        Btn.Text = name
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 11
        Instance.new("UICorner", Btn)
        
        local Toggled = false
        Btn.MouseButton1Click:Connect(function()
            Toggled = not Toggled
            Btn.BackgroundColor3 = Toggled and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(30, 30, 30)
            callback(Toggled)
        end)
    end

    -- الأزرار
    CreateButton("Aimbot", UDim2.new(0.05, 0, 0.15, 0), function(v) Settings.Aimbot = v end)
    CreateButton("Aimlock", UDim2.new(0.38, 0, 0.15, 0), function(v) Settings.Aimlock = v end)
    CreateButton("HEADSHOT", UDim2.new(0.7, 0, 0.15, 0), function(v) Settings.HeadshotOnly = v end)
    
    CreateButton("SpinBot", UDim2.new(0.05, 0, 0.3, 0), function(v) Settings.SpinBot = v end)
    CreateButton("ESP Box", UDim2.new(0.38, 0, 0.3, 0), function(v) Settings.ESP_Box = v end)
    CreateButton("ESP Skeleton", UDim2.new(0.7, 0, 0.3, 0), function(v) Settings.ESP_Skeleton = v end)

    -- التحكم بالسرعة
    local SpeedLabel = Instance.new("TextLabel", MainFrame)
    SpeedLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
    SpeedLabel.Size = UDim2.new(0, 100, 0, 20)
    SpeedLabel.Text = "WalkSpeed Control:"
    SpeedLabel.TextColor3 = Color3.new(1,1,1)
    SpeedLabel.BackgroundTransparency = 1

    local SpeedInput = Instance.new("TextBox", MainFrame)
    SpeedInput.Size = UDim2.new(0, 100, 0, 30)
    SpeedInput.Position = UDim2.new(0.05, 0, 0.65, 0)
    SpeedInput.Text = "16"
    SpeedInput.BackgroundColor3 = Color3.fromRGB(35,35,35)
    SpeedInput.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", SpeedInput)

    SpeedInput.FocusLost:Connect(function()
        Settings.WalkSpeed = tonumber(SpeedInput.Text) or 16
    end)

    -- منطق البحث عن الهدف (الرأس)
    local function GetTarget()
        local Closest = nil
        local Dist = 500
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen then
                    local Magnitude = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if Magnitude < Dist then
                        Closest = v
                        Dist = Magnitude
                    end
                end
            end
        end
        return Closest
    end

    -- التحديث الموحد
    RunService.RenderStepped:Connect(function()
        -- السرعة
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        end

        -- سبين بوت
        if Settings.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(60), 0)
        end

        -- الايمبوت والرأس
        if Settings.Aimbot or Settings.Aimlock then
            local Target = GetTarget()
            if Target and Target.Character and Target.Character:FindFirstChild("Head") then
                local TargetPart = Target.Character.Head
                local PredictionPos = TargetPart.Position + (TargetPart.Velocity * Settings.Prediction)

                if Settings.Aimlock then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, PredictionPos)
                else
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, PredictionPos), Settings.Smoothness)
                end
            end
        end
    end)
    
    print("GHOST HUB: LOADED WITH HEADSHOT PROTOCOL")
end

Authenticate()
