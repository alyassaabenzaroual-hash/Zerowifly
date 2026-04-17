-- 👻 GhostHub V6 | ULTRA

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimLock = false
local Prediction = 0.13
local FOV = 150
local Target = nil

-- 🌈 RAINBOW
local hue = 0
local function Rainbow()
	hue = (hue + 0.002) % 1
	return Color3.fromHSV(hue,1,1)
end

-- 🎯 FOV
local Circle = Drawing.new("Circle")
Circle.Thickness = 3
Circle.Filled = false
Circle.NumSides = 100
Circle.Transparency = 1
Circle.Visible = true

-- 📦 ESP STORAGE
local ESP = {}

local function CreateESP(player)
	local Box = Drawing.new("Square")
	local Name = Drawing.new("Text")
	local Tracer = Drawing.new("Line")

	Box.Thickness = 2
	Box.Filled = false

	Name.Size = 13
	Name.Center = true
	Name.Outline = true

	Tracer.Thickness = 1

	ESP[player] = {Box = Box, Name = Name, Tracer = Tracer}
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

-- 🎯 GET CLOSEST
local function GetClosest()
	local closest, dist = nil, FOV

	for _,v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then

			local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)

			if vis then
				local diff = (Vector2.new(pos.X,pos.Y) -
				Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude

				if diff < dist then
					dist = diff
					closest = v
				end
			end
		end
	end

	return closest
end

-- 👆 TOUCH AIM
UIS.TouchTap:Connect(function(pos)
	for _,v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then

			local screenPos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)

			if vis then
				local dist = (Vector2.new(screenPos.X,screenPos.Y) - pos).Magnitude
				if dist < 50 then
					Target = v
				end
			end
		end
	end
end)

-- 🎮 LOOP
RunService.RenderStepped:Connect(function()

	-- FOV
	Circle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
	Circle.Radius = FOV
	Circle.Color = Rainbow()

	-- ESP
	for player,data in pairs(ESP) do

		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then

			local hrp = char.HumanoidRootPart
			local pos,vis = Camera:WorldToViewportPoint(hrp.Position)

			if vis then
				local size = 40

				data.Box.Size = Vector2.new(size,size*2)
				data.Box.Position = Vector2.new(pos.X-size/2,pos.Y-size)
				data.Box.Color = Rainbow()
				data.Box.Visible = true

				local health = char:FindFirstChild("Humanoid") and math.floor(char.Humanoid.Health) or 0
				local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)

				data.Name.Text = player.Name.." | "..health.."HP | "..dist.."m"
				data.Name.Position = Vector2.new(pos.X,pos.Y-50)
				data.Name.Color = Rainbow()
				data.Name.Visible = true

				data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
				data.Tracer.To = Vector2.new(pos.X,pos.Y)
				data.Tracer.Color = Rainbow()
				data.Tracer.Visible = true

			else
				data.Box.Visible = false
				data.Name.Visible = false
				data.Tracer.Visible = false
			end
		end
	end

	-- AIMLOCK
	if AimLock then
		if not Target then
			Target = GetClosest()
		end

		if Target and Target.Character and Target.Character:FindFirstChild("Head") then
			local head = Target.Character.Head
			local pred = head.Position + (head.Velocity * Prediction)
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, pred)
		else
			Target = nil
		end
	end

end)

-- 👻 GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,180)
frame.Position = UDim2.new(0.1,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.2,0)
title.Text = "👻 GhostHub"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)

local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0,0,0.2,0)
toggle.Size = UDim2.new(1,0,0.3,0)
toggle.Text = "AimLock OFF"

toggle.MouseButton1Click:Connect(function()
	AimLock = not AimLock
	toggle.Text = AimLock and "AimLock ON 👻" or "AimLock OFF"
	Target = nil
end)

-- 🎚 SLIDER
local slider = Instance.new("Frame", frame)
slider.Position = UDim2.new(0,10,0.6,0)
slider.Size = UDim2.new(1,-20,0,20)
slider.BackgroundColor3 = Color3.fromRGB(50,50,50)

local fill = Instance.new("Frame", slider)
fill.Size = UDim2.new(FOV/300,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(255,0,255)

local dragging = false

slider.InputBegan:Connect(function(input)
	if input.UserInputType.Name == "MouseButton1" or input.UserInputType.Name == "Touch" then
		dragging = true
	end
end)

UIS.InputEnded:Connect(function()
	dragging = false
end)

UIS.InputChanged:Connect(function(input)
	if dragging then
		local x = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X,0,1)
		fill.Size = UDim2.new(x,0,1,0)
		FOV = math.floor(x * 300)
	end
end)
