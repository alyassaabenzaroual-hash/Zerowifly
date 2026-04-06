-- Settings
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 50
local ascend = false
local descend = false

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,120,0,120)
Frame.Position = UDim2.new(0.85,0,0.1,0)
Frame.BackgroundColor3 = Color3.fromRGB(0,170,255)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0,100,0,50)
FlyButton.Position = UDim2.new(0,10,0,10)
FlyButton.Text = "🕊️ Fly"
FlyButton.TextScaled = true
FlyButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
FlyButton.Parent = Frame

local SpeedUp = Instance.new("TextButton")
SpeedUp.Size = UDim2.new(0,50,0,30)
SpeedUp.Position = UDim2.new(0,10,0,70)
SpeedUp.Text = "⏫"
SpeedUp.TextScaled = true
SpeedUp.Parent = Frame

local SpeedDown = Instance.new("TextButton")
SpeedDown.Size = UDim2.new(0,50,0,30)
SpeedDown.Position = UDim2.new(0,60,0,70)
SpeedDown.Text = "⏬"
SpeedDown.TextScaled = true
SpeedDown.Parent = Frame

-- Fly/Unfly toggle
FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        FlyButton.BackgroundColor3 = Color3.fromRGB(0,255,0)
        FlyButton.Text = "🕊️ Unfly"
    else
        FlyButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
        FlyButton.Text = "🕊️ Fly"
        HRP.Velocity = Vector3.new(0,0,0)
    end
end)

-- Speed control
SpeedUp.MouseButton1Click:Connect(function()
    speed = speed + 10
end)
SpeedDown.MouseButton1Click:Connect(function()
    speed = math.max(10,speed - 10)
end)

-- Ascend/Descend control
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        ascend = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        descend = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        ascend = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        descend = false
    end
end)

-- Flight update
RunService.RenderStepped:Connect(function()
    if flying then
        local direction = workspace.CurrentCamera.CFrame.LookVector * speed
        if ascend then
            direction = direction + Vector3.new(0,speed,0)
        elseif descend then
            direction = direction - Vector3.new(0,speed,0)
        end
        HRP.Velocity = direction
    end
end)
