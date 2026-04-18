-- FLyHub V3 | FIXED VERSION
-- By alyassaabenzaroual-hash

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- تحديث الشخصية بعد الموت
local char, hum, root

local function setupCharacter()
	char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
end

setupCharacter()
player.CharacterAdded:Connect(setupCharacter)

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,240,0,320)
frame.Position = UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.Active = true
frame.Draggable = true

local function btn(text,y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0,220,0,35)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	return b
end

local punchBtn = btn("Punch 💥",10)
local kickBtn = btn("Kick 🦵",55)
local spinBtn = btn("Spin 🔥",100)
local flyBtn = btn("Fly ✈️",145)
local unflyBtn = btn("UnFly ❌",190)

-- تحسين SPIN 🔥
local spinning = false
spinBtn.MouseButton1Click:Connect(function()
	spinning = not spinning
end)

RunService.RenderStepped:Connect(function()
	if spinning and root then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(50), 0)
	end
end)

-- Punch (Dash قوي)
punchBtn.MouseButton1Click:Connect(function()
	if root then
		root.Velocity = root.CFrame.LookVector * 120
	end
end)

-- Kick (Dash أقوى + رفع)
kickBtn.MouseButton1Click:Connect(function()
	if root then
		root.Velocity = root.CFrame.LookVector * 150 + Vector3.new(0,50,0)
	end
end)

-- Fly
local flying = false
local bv,bg

flyBtn.MouseButton1Click:Connect(function()
	if flying or not root then return end
	flying = true

	bv = Instance.new("BodyVelocity", root)
	bg = Instance.new("BodyGyro", root)

	bv.MaxForce = Vector3.new(9e9,9e9,9e9)
	bg.MaxTorque = Vector3.new(9e9,9e9,9e9)

	RunService.RenderStepped:Connect(function()
		if flying and root then
			bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 90
			bg.CFrame = workspace.CurrentCamera.CFrame
		end
	end)
end)

unflyBtn.MouseButton1Click:Connect(function()
	flying = false
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end)
