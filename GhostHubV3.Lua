-- AimLock Mobile + FOV + Legendary ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimLock = false
local Prediction = 0.12
local FOV = 150
local Target

-- FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOV
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.NumSides = 100
FOVCircle.Visible = true
FOVCircle.Transparency = 1

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
end)

-- GET CLOSEST PLAYER
function GetClosest()
    local Closest
    local Distance = FOV

    for _,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then

            local pos,vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)

            if vis then
                local diff = (Vector2.new(pos.X,pos.Y) -
                Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude

                if diff < Distance then
                    Closest = v
                    Distance = diff
                end
            end
        end
    end

    return Closest
end

-- AIMLOCK
RunService.RenderStepped:Connect(function()

    if AimLock and Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then

        local Part = Target.Character.HumanoidRootPart
        local Pred = Part.Position + (Part.Velocity * Prediction)

        Camera.CFrame = CFrame.new(Camera.CFrame.Position,Pred)

    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local AimButton = Instance.new("TextButton")
local HideButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,160,0,120)
Frame.Position = UDim2.new(0.1,0,0.4,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true

AimButton.Parent = Frame
AimButton.Size = UDim2.new(1,0,0.5,0)
AimButton.Text = "AimLock OFF"

HideButton.Parent = Frame
HideButton.Position = UDim2.new(0,0,0.5,0)
HideButton.Size = UDim2.new(1,0,0.5,0)
HideButton.Text = "Hide GUI"

AimButton.MouseButton1Click:Connect(function()

    AimLock = not AimLock
    Target = GetClosest()

    if AimLock then
        AimButton.Text = "AimLock ON"
    else
        AimButton.Text = "AimLock OFF"
    end

end)

HideButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

-- ESP SYSTEM
local ESP = {}

function CreateESP(player)

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Visible = false

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1
    Tracer.Visible = false

    local Name = Drawing.new("Text")
    Name.Size = 13
    Name.Center = true
    Name.Outline = true
    Name.Visible = false

    RunService.RenderStepped:Connect(function()

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

            local pos,vis = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            if vis then

                local size = 40

                Box.Size = Vector2.new(size,size*2)
                Box.Position = Vector2.new(pos.X-size/2,pos.Y-size)
                Box.Visible = true

                Tracer.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                Tracer.To = Vector2.new(pos.X,pos.Y)
                Tracer.Visible = true

                Name.Position = Vector2.new(pos.X,pos.Y-50)
                Name.Text = player.Name
                Name.Visible = true

            else

                Box.Visible = false
                Tracer.Visible = false
                Name.Visible = false

            end

        else

            Box.Visible = false
            Tracer.Visible = false
            Name.Visible = false

        end

    end)

end

for _,player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)
