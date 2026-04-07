-- 💀 SkullHub Legendary Ultimate
-- by alyassaabenzaroual

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- #########################
-- 💀 Floating Open Button
-- #########################
local OpenButton = Instance.new("TextButton")
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0,60,0,60)
OpenButton.Position = UDim2.new(0,20,0.5,-30)
OpenButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
OpenButton.Text = "💀"
OpenButton.TextScaled = true
OpenButton.TextColor3 = Color3.fromRGB(255,0,0)
OpenButton.Active = true
OpenButton.Draggable = true

-- #########################
-- Main GUI
-- #########################
local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.new(0,320,0,380)
Main.Position = UDim2.new(0.5,-160,0.5,-190)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Active = true
Main.Draggable = true

local Gradient = Instance.new("UIGradient",Main)
Gradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))
}

local Title = Instance.new("TextLabel",Main)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "💀 SkullHub"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true

local Close = Instance.new("TextButton",Main)
Close.Size = UDim2.new(0,40,0,40)
Close.Position = UDim2.new(1,-40,0,0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(255,50,50)

-- #########################
-- Buttons
-- #########################
local function MakeButton(btn,y,text)
btn.Parent = Main
btn.Size = UDim2.new(0.8,0,0,35)
btn.Position = UDim2.new(0.1,0,y,0)
btn.Text = text
btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
end

local Fly = Instance.new("TextButton")
local Speed = Instance.new("TextButton")
local Jump = Instance.new("TextButton")
local Noclip = Instance.new("TextButton")
local TP = Instance.new("TextButton")
local ESP = Instance.new("TextButton")

MakeButton(Fly,0.18,"Fly")
MakeButton(Speed,0.30,"Speed")
MakeButton(Jump,0.42,"Infinite Jump")
MakeButton(Noclip,0.54,"Noclip")
MakeButton(TP,0.66,"Teleport")
MakeButton(ESP,0.78,"ESP + Box")

-- #########################
-- BUTTON FUNCTIONS
-- #########################

Close.MouseButton1Click:Connect(function()
Main.Visible = false
end)

OpenButton.MouseButton1Click:Connect(function()
Main.Visible = not Main.Visible
end)

-- Speed Slider
Speed.MouseButton1Click:Connect(function()
Player.Character.Humanoid.WalkSpeed = 80
end)

-- Infinite Jump
Jump.MouseButton1Click:Connect(function()
UIS.JumpRequest:Connect(function()
Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
end)
end)

-- Noclip
Noclip.MouseButton1Click:Connect(function()
RunService.Stepped:Connect(function()
for _,v in pairs(Player.Character:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide = false
end
end
end)
end)

-- Teleport forward
TP.MouseButton1Click:Connect(function()
local char = Player.Character
char:MoveTo(char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.LookVector * 50)
end)

-- Fly
Fly.MouseButton1Click:Connect(function()
loadstring(game:HttpGet("https://pastebin.com/raw/3xqU7qZ3"))()
end)

-- ESP + Box
ESP.MouseButton1Click:Connect(function()
for _,v in pairs(Players:GetPlayers()) do
if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then

-- Billboard Name
local Billboard = Instance.new("BillboardGui",v.Character.Head)
Billboard.Size = UDim2.new(0,100,0,40)
Billboard.AlwaysOnTop = true
local Name = Instance.new("TextLabel",Billboard)
Name.Size = UDim2.new(1,0,1,0)
Name.BackgroundTransparency = 1
Name.Text = v.Name
Name.TextColor3 = Color3.fromRGB(255,0,0)
Name.TextScaled = true

-- Box ESP
local Box = Instance.new("BoxHandleAdornment")
Box.Size = Vector3.new(4,6,2)
Box.Adornee = v.Character:FindFirstChild("HumanoidRootPart")
Box.AlwaysOnTop = true
Box.ZIndex = 5
Box.Color3 = Color3.fromRGB(255,0,0)
Box.Parent = v.Character

end
end
end)
