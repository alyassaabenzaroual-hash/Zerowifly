-- 👻 AIMBOT + BOX ESP BUTTON

local AIM = Instance.new("TextButton")

AIM.Parent = Main
AIM.Size = UDim2.new(0.8,0,0,35)
AIM.Position = UDim2.new(0.1,0,0.95,0)
AIM.Text = "👻 AIMBOT"
AIM.BackgroundColor3 = Color3.fromRGB(40,40,40)
AIM.TextColor3 = Color3.new(1,1,1)
AIM.TextScaled = true

local aiming = false

AIM.MouseButton1Click:Connect(function()
aiming = not aiming
end)

-- 📦 BOX ESP
for _,v in pairs(game:GetService("Players"):GetPlayers()) do
if v ~= game.Players.LocalPlayer then
v.CharacterAdded:Connect(function(char)

local box = Instance.new("BoxHandleAdornment")
box.Size = Vector3.new(4,6,2)
box.Color3 = Color3.fromRGB(255,0,0)
box.AlwaysOnTop = true
box.Adornee = char:WaitForChild("HumanoidRootPart")
box.ZIndex = 5
box.Parent = char

end)
end
end

-- 🎯 AIMBOT
game:GetService("RunService").RenderStepped:Connect(function()

if aiming then

local Camera = workspace.CurrentCamera
local closest = nil
local distance = math.huge

for _,v in pairs(game:GetService("Players"):GetPlayers()) do
if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then

local pos,visible = Camera:WorldToViewportPoint(v.Character.Head.Position)

if visible then
local diff = (Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2) - Vector2.new(pos.X,pos.Y)).Magnitude

if diff < distance then
distance = diff
closest = v
end
end
end
end

if closest then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
end

end

end)
