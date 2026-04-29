-- Simple GUI with Spin, Aimbot, and ESP Box
-- Paste this script into your executor

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GreenDeno/Solaris-UI-Library/main/Solaris%20UI%20Library/Source.lua"))()
local Window = Library:NewWindow("Simple GUI")

local Combat = Window:NewSection("Combat")
local Visuals = Window:NewSection("Visuals")
local PlayerSection = Window:NewSection("Player")

-- Variables
local spinning = false
local aimbotEnabled = false
local espEnabled = false

-- Spin Function
local function spinPlayer()
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        spinConnection = game:GetService("RunService").RenderStepped:Connect(function()
            if spinning then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(10), 0)
            end
        end)
    end
end

-- Aimbot Function
local function updateAimbot()
    while aimbotEnabled do
        task.wait()
        local plr = game.Players.LocalPlayer
        local mouse = plr:GetMouse()
        local target = nil
        local closestDist = math.huge

        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= plr and v.Character and v.Character:FindFirstChild("Head") then
                local headPos = v.Character.Head.Position
                local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(headPos)
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = v
                    end
                end
            end
        end

        if target and target.Character and target.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
        end
    end
end

-- ESP Box Function
local function createESP()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer then
            local espBox = Instance.new("BoxHandleAdornment")
            espBox.Name = "ESPBox"
            espBox.Adornee = v.Character
            espBox.Size = Vector3.new(4, 5, 1)
            espBox.Color3 = Color3.fromRGB(255, 0, 0)
            espBox.AlwaysOnTop = true
            espBox.ZIndex = 0
            espBox.Visible = espEnabled
            espBox.Parent = v.Character
        end
    end
end

-- Toggle Spin
Combat:CreateToggle("Spin", false, function(state)
    spinning = state
    if spinning then
        spinPlayer()
    elseif spinConnection then
        spinConnection:Disconnect()
    end
end)

-- Toggle Aimbot
Combat:CreateToggle("Aimbot", false, function(state)
    aimbotEnabled = state
    if aimbotEnabled then
        coroutine.wrap(updateAimbot)()
    end
end)

-- Toggle ESP Box
Visuals:CreateToggle("ESP Box", false, function(state)
    espEnabled = state
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character then
            local esp = v.Character:FindFirstChild("ESPBox")
            if esp then
                esp.Visible = espEnabled
            else
                createESP()
            end
        end
    end
end)

-- Spin Speed Slider
Combat:CreateSlider("Spin Speed", 1, 30, 10, function(value)
    -- Adjust spin speed if needed (currently fixed at 10 deg per frame)
end)

-- WalkSpeed Slider
PlayerSection:CreateSlider("WalkSpeed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- JumpPower Slider
PlayerSection:CreateSlider("JumpPower", 50, 200, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

print("GUI Loaded Successfully!")
