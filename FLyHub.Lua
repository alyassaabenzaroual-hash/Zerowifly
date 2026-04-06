-- FlyHub Ultimate

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 60
local ascend = false
local descend = false
local noclip = false
local infjump = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FlyHub"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,200)
frame.Position = UDim2.new(0.8,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(0,170,255)
title.Text = "FlyHub"
title.TextScaled = true
title.Parent = frame

local fly = Instance.new("TextButton")
fly.Size = UDim2.new(0,180,0,35)
fly.Position = UDim2.new(0,10,0,40)
fly.Text = "Fly"
fly.BackgroundColor3 = Color3.fromRGB(255,0,0)
fly.TextScaled = true
fly.Parent = frame

local jump = Instance.new("TextButton")
jump.Size = UDim2.new(0,180,0,35)
jump.Position = UDim2.new(0,10,0,80)
jump.Text = "Infinite Jump"
jump.BackgroundColor3 = Color3.fromRGB(255,0,0)
jump.TextScaled = true
jump.Parent = frame

local clip = Instance.new("TextButton")
clip.Size = UDim2.new(0,180,0,35)
clip.Position = UDim2.new(0,10,0,120)
clip.Text = "NoClip"
clip.BackgroundColor3 = Color3.fromRGB(255,0,0)
clip.TextScaled = true
clip.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,20,0,20)
close.Position = UDim2.new(1,-25,0,5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(255,0,0)
close.Parent = frame

-- Fly
fly.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		fly.Text = "Unfly"
		fly.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		fly.Text = "Fly"
		fly.BackgroundColor3 = Color3.fromRGB(255,0,0)
		hrp.Velocity = Vector3.new(0,0,0)
	end
end)

-- Infinite Jump toggle
jump.MouseButton1Click:Connect(function()
	infjump = not infjump
	if infjump then
		jump.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		jump.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
end)

-- NoClip toggle
clip.MouseButton1Click:Connect(function()
	noclip = not noclip
	if noclip then
		clip.BackgroundColor3 = Color3.fromRGB(0,255,0)
	else
		clip.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
end)

-- Close GUI
close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Controls
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

-- Infinite Jump
UIS.JumpRequest:Connect(function()
	if infjump then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- NoClip
RunService.Stepped:Connect(function()
	if noclip then
		for _,v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

-- Fly system
RunService.RenderStepped:Connect(function()
	if flying then
		local dir = workspace.CurrentCamera.CFrame.LookVector * speed
		if ascend then
			dir = dir + Vector3.new(0,speed,0)
		elseif descend then
			dir = dir - Vector3.new(0,speed,0)
		end
		hrp.Velocity = dir
	end
end)
