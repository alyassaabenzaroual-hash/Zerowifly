-- FLyHub V2 | Drag + Hide GUI
-- By alyassaabenzaroual-hash

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,220,0,280)
Frame.Position = UDim2.new(0.05,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true

local function button(text,pos)
	local b = Instance.new("TextButton")
	b.Parent = Frame
	b.Size = UDim2.new(0,200,0,35)
	b.Position = UDim2.new(0,10,0,pos)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(50,50,50)
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

local FlyBtn = button("Fly",10)
local UnFlyBtn = button("UnFly",55)
local SpeedBtn = button("Speed",100)
local JumpBtn = button("Infinite Jump",145)
local TpBtn = button("Teleport Forward",190)
local NoclipBtn = button("NoClip",235)

-- Hide / Show button
local Toggle = Instance.new("TextButton")
Toggle.Parent = ScreenGui
Toggle.Size = UDim2.new(0,100,0,30)
Toggle.Position = UDim2.new(0,10,0,10)
Toggle.Text = "Hide GUI"
Toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
Toggle.TextColor3 = Color3.new(1,1,1)

Toggle.MouseButton1Click:Connect(function()
	if Frame.Visible then
		Frame.Visible = false
		Toggle.Text = "Show GUI"
	else
		Frame.Visible = true
		Toggle.Text = "Hide GUI"
	end
end)

-- FLY
local flying = false
local bv
local bg

FlyBtn.MouseButton1Click:Connect(function()
	if flying then return end
	flying = true

	bv = Instance.new("BodyVelocity")
	bg = Instance.new("BodyGyro")

	bv.MaxForce = Vector3.new(9e9,9e9,9e9)
	bv.Parent = root

	bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bg.CFrame = root.CFrame
	bg.Parent = root

	RunService.RenderStepped:Connect(function()
		if flying then
			bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 80
			bg.CFrame = workspace.CurrentCamera.CFrame
		end
	end)
end)

-- UNFLY
UnFlyBtn.MouseButton1Click:Connect(function()
	flying = false
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end)

-- SPEED
SpeedBtn.MouseButton1Click:Connect(function()
	hum.WalkSpeed = 100
end)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()
	hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)

-- TELEPORT
TpBtn.MouseButton1Click:Connect(function()
	root.CFrame = root.CFrame + root.CFrame.LookVector * 60
end)

-- NOCLIP
local noclip = false
NoclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
end)

RunService.Stepped:Connect(function()
	if noclip then
		for _,v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)
