-- 👻 GhostHub V4 FIXED | AimLock + ESP + FOV

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimLock = false
local FOV = 150
local Prediction = 0.13
local Target

-- FOV CIRCLE
local Circle = Drawing.new("Circle")
Circle.Radius = FOV
Circle.Color = Color3.fromRGB(255,0,255)
Circle.Thickness = 3
Circle.NumSides = 100
Circle.Filled = false
Circle.Visible = true
Circle.Transparency = 1

RunService.RenderStepped:Connect(function()
	Circle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
	Circle.Radius = FOV
end)

-- GET CLOSEST PLAYER
function GetClosest()

	local Closest
	local Distance = FOV

	for _,v in pairs(Players:GetPlayers()) do

		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then

			local pos,vis = Camera:WorldToViewportPoint(v.Character.Head.Position)

			if vis then

				local diff = (Vector2.new(pos.X,pos.Y) -
				Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude

				if diff < Distance then
					Distance = diff
					Closest = v
				end

			end

		end

	end

	return Closest
end

-- AIMLOCK
RunService.RenderStepped:Connect(function()

	if AimLock then

		if not Target then
			Target = GetClosest()
		end

		if Target and Target.Character and Target.Character:FindFirstChild("Head") then

			local Part = Target.Character.Head
			local Predict = Part.Position + (Part.Velocity * Prediction)

			Camera.CFrame = CFrame.new(Camera.CFrame.Position,Predict)

		else
			Target = nil
		end

	end

end)

-- ESP SYSTEM
function CreateESP(player)

	local Box = Drawing.new("Square")
	Box.Color = Color3.fromRGB(0,255,0)
	Box.Thickness = 2
	Box.Filled = false
	Box.Visible = false

	RunService.RenderStepped:Connect(function()

		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

			local pos,vis = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

			if vis then

				local size = 40

				Box.Size = Vector2.new(size,size*2)
				Box.Position = Vector2.new(pos.X-size/2,pos.Y-size)
				Box.Visible = true

			else
				Box.Visible = false
			end

		else
			Box.Visible = false
		end

	end)

end

for _,v in pairs(Players:GetPlayers()) do
	if v ~= LocalPlayer then
		CreateESP(v)
	end
end

Players.PlayerAdded:Connect(function(v)
	if v ~= LocalPlayer then
		CreateESP(v)
	end
end)

-- GUI 👻
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Toggle = Instance.new("TextButton")
local FOVLabel = Instance.new("TextLabel")
local Slider = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0,200,0,170)
Frame.Position = UDim2.new(0.1,0,0.35,0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.Size = UDim2.new(1,0,0.2,0)
Title.Text = "👻 GhostHub"
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)

Toggle.Parent = Frame
Toggle.Position = UDim2.new(0,0,0.2,0)
Toggle.Size = UDim2.new(1,0,0.3,0)
Toggle.Text = "AimLock OFF"
Toggle.TextScaled = true

Toggle.MouseButton1Click:Connect(function()

	AimLock = not AimLock

	if AimLock then
		Toggle.Text = "AimLock ON 👻"
	else
		Toggle.Text = "AimLock OFF"
		Target = nil
	end

end)

FOVLabel.Parent = Frame
FOVLabel.Position = UDim2.new(0,0,0.5,0)
FOVLabel.Size = UDim2.new(1,0,0.2,0)
FOVLabel.Text = "AIM FOV : "..FOV
FOVLabel.TextScaled = true
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.new(1,1,1)

Slider.Parent = Frame
Slider.Position = UDim2.new(0,0,0.7,0)
Slider.Size = UDim2.new(1,0,0.3,0)
Slider.Text = "1% ───── 100%"
Slider.TextScaled = true

Slider.MouseButton1Click:Connect(function()

	FOV = FOV + 20

	if FOV > 300 then
		FOV = 60
	end

	FOVLabel.Text = "AIM FOV : "..FOV

end)
