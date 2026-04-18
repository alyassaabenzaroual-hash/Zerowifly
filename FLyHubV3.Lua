-- FLyHub V3 | VR Style + Animations
-- By alyassaabenzaroual-hash

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,240,0,360)
frame.Position = UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local function btn(text,y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0,220,0,35)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

local flyBtn = btn("Fly",10)
local unflyBtn = btn("UnFly",50)
local punchBtn = btn("Punch (Anim)",90)
local kickBtn = btn("Kick (Anim)",130)
local spinBtn = btn("Spin",170)

-- Toggle GUI
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0,110,0,30)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Text = "Hide GUI"

toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
	toggle.Text = frame.Visible and "Hide GUI" or "Show GUI"
end)

-- FLY
local flying = false
local bv,bg

flyBtn.MouseButton1Click:Connect(function()
	if flying then return end
	flying = true

	bv = Instance.new("BodyVelocity", root)
	bg = Instance.new("BodyGyro", root)

	bv.MaxForce = Vector3.new(9e9,9e9,9e9)
	bg.MaxTorque = Vector3.new(9e9,9e9,9e9)

	RunService.RenderStepped:Connect(function()
		if flying then
			bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 80
			bg.CFrame = workspace.CurrentCamera.CFrame
		end
	end)
end)

unflyBtn.MouseButton1Click:Connect(function()
	flying = false
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end)

-- 🎬 ANIMATIONS (IDs عامة)
local punchAnim = Instance.new("Animation")
punchAnim.AnimationId = "rbxassetid://522635514" -- Punch

local kickAnim = Instance.new("Animation")
kickAnim.AnimationId = "rbxassetid://507777268" -- Kick

-- Punch
punchBtn.MouseButton1Click:Connect(function()
	local track = hum:LoadAnimation(punchAnim)
	track:Play()
	root.Velocity = root.CFrame.LookVector * 50
end)

-- Kick
kickBtn.MouseButton1Click:Connect(function()
	local track = hum:LoadAnimation(kickAnim)
	track:Play()
	root.Velocity = root.CFrame.LookVector * 80
end)

-- Spin
local spinning = false
spinBtn.MouseButton1Click:Connect(function()
	spinning = not spinning
end)

RunService.RenderStepped:Connect(function()
	if spinning then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(25), 0)
	end
end)
