-- FLyHub V4 | Pro UI
-- By alyassaabenzaroual-hash

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char, hum, root

-- Respawn Fix
local function setup()
	char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
end

setup()
player.CharacterAdded:Connect(setup)

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,260,0,300)
main.Position = UDim2.new(0.05,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.Text = "FLyHub V4"
title.BackgroundColor3 = Color3.fromRGB(30,30,30)
title.TextColor3 = Color3.new(1,1,1)

-- Tabs
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1,0,0,30)
tabFrame.Position = UDim2.new(0,0,0,30)
tabFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,0,1,-60)
content.Position = UDim2.new(0,0,0,60)
content.BackgroundTransparency = 1

local function createTab(name,x)
	local b = Instance.new("TextButton", tabFrame)
	b.Size = UDim2.new(0.5,0,1,0)
	b.Position = UDim2.new(x,0,0,0)
	b.Text = name
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

local playerTabBtn = createTab("Player",0)
local funTabBtn = createTab("Fun",0.5)

local playerTab = Instance.new("Frame", content)
playerTab.Size = UDim2.new(1,0,1,0)

local funTab = Instance.new("Frame", content)
funTab.Size = UDim2.new(1,0,1,0)
funTab.Visible = false

-- Tab switching
playerTabBtn.MouseButton1Click:Connect(function()
	playerTab.Visible = true
	funTab.Visible = false
end)

funTabBtn.MouseButton1Click:Connect(function()
	playerTab.Visible = false
	funTab.Visible = true
end)

-- Button maker
local function btn(parent,text,y)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,220,0,35)
	b.Position = UDim2.new(0,20,0,y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

-- Player Tab
local flyBtn = btn(playerTab,"Fly",10)
local unflyBtn = btn(playerTab,"UnFly",55)
local speedBtn = btn(playerTab,"Speed",100)
local jumpBtn = btn(playerTab,"Infinite Jump",145)
local tpBtn = btn(playerTab,"Teleport",190)

-- Fun Tab
local spinBtn = btn(funTab,"Spin 🔥",10)

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

-- Speed
local speed = false
speedBtn.MouseButton1Click:Connect(function()
	speed = not speed
	hum.WalkSpeed = speed and 80 or 16
end)

-- Infinite Jump
local infJump = false
jumpBtn.MouseButton1Click:Connect(function()
	infJump = not infJump
end)

UIS.JumpRequest:Connect(function()
	if infJump then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Teleport
tpBtn.MouseButton1Click:Connect(function()
	if root then
		root.CFrame = root.CFrame + root.CFrame.LookVector * 60
	end
end)

-- Spin 🔥 (محسن)
local spinning = false
spinBtn.MouseButton1Click:Connect(function()
	spinning = not spinning
end)

RunService.RenderStepped:Connect(function()
	if spinning and root then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(70), 0)
	end
end)
