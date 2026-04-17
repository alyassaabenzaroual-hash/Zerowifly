-- 👻 GhostHub V7 (FULL UI)

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,420)
frame.Position = UDim2.new(0.3,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0.1,0)
title.Text = "👻 GhostHubV7 by alyassaa"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)

-- BUTTON FUNCTION
local function Button(text, posY)
	local btn = Instance.new("TextButton", frame)
	btn.Position = UDim2.new(0.05,0,posY,0)
	btn.Size = UDim2.new(0.9,0,0.06,0)
	btn.Text = text.." : OFF"
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	
	local state = false
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = text.." : "..(state and "ON" or "OFF")
	end)
	
	return btn
end

local function Section(text, posY)
	local lbl = Instance.new("TextLabel", frame)
	lbl.Position = UDim2.new(0,0,posY,0)
	lbl.Size = UDim2.new(1,0,0.05,0)
	lbl.Text = text
	lbl.TextScaled = true
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(180,180,180)
end

-------------------------------------------------
-- 🎯 AIM
-------------------------------------------------
Section("🎯 AIM",0.1)

Button("Ativar Aimbot",0.16)
Button("Ignorar Derrubados",0.22)
Button("Puxar em Paredes",0.28)
Button("Exibir FOV",0.34)

-------------------------------------------------
-- 👁 ESP
-------------------------------------------------
Section("👁 ESP",0.40)

Button("Ativar ESP",0.46)
Button("ESP Linha",0.52)
Button("ESP Caixa",0.58)
Button("ESP Esqueleto",0.64)
Button("ESP Nome",0.70)
Button("ESP Vida",0.76)
Button("ESP Distância",0.82)

-------------------------------------------------
-- ⚙️ MISC
-------------------------------------------------
Section("⚙️ MISC",0.88)

local hideBtn = Instance.new("TextButton", frame)
hideBtn.Position = UDim2.new(0.05,0,0.94,0)
hideBtn.Size = UDim2.new(0.9,0,0.06,0)
hideBtn.Text = "🙈 Hide GUI"
hideBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
hideBtn.TextColor3 = Color3.new(1,1,1)

hideBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-------------------------------------------------
-- 🎨 COLORS
-------------------------------------------------
local colorBtn = Instance.new("TextButton", frame)
colorBtn.Position = UDim2.new(0.05,0,1.00,0)
colorBtn.Size = UDim2.new(0.9,0,0.06,0)
colorBtn.Text = "🎨 Change Color"
colorBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
colorBtn.TextColor3 = Color3.new(1,1,1)

colorBtn.MouseButton1Click:Connect(function()
	frame.BackgroundColor3 = Color3.fromRGB(
		math.random(0,255),
		math.random(0,255),
		math.random(0,255)
	)
end)
