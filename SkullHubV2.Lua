-- SkullHub V2 Pro UI (Clean Roblox Studio Style)

local player = game.Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SkullHubV2"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 200)
main.Position = UDim2.new(0.4, 0, 0.4, 0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "💀 SkullHub V2"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Tabs
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1,0,0,30)
tabFrame.Position = UDim2.new(0,0,0,40)
tabFrame.BackgroundTransparency = 1

local function createTab(name, pos)
	local btn = Instance.new("TextButton", tabFrame)
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.Position = UDim2.new(0, pos, 0, 0)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	return btn
end

local homeTab = createTab("Home", 0)
local settingsTab = createTab("Settings", 100)

-- Pages
local homePage = Instance.new("Frame", main)
homePage.Size = UDim2.new(1,0,1,-70)
homePage.Position = UDim2.new(0,0,0,70)
homePage.BackgroundTransparency = 1

local settingsPage = Instance.new("Frame", main)
settingsPage.Size = homePage.Size
settingsPage.Position = homePage.Position
settingsPage.BackgroundTransparency = 1
settingsPage.Visible = false

-- Button example (Speed)
local speedBtn = Instance.new("TextButton", homePage)
speedBtn.Size = UDim2.new(0,200,0,40)
speedBtn.Position = UDim2.new(0.15,0,0.1,0)
speedBtn.Text = "⚡ Speed Boost"
speedBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBtn.TextColor3 = Color3.new(1,1,1)

speedBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 32
		end
	end
end)

-- Tab switch
homeTab.MouseButton1Click:Connect(function()
	homePage.Visible = true
	settingsPage.Visible = false
end)

settingsTab.MouseButton1Click:Connect(function()
	homePage.Visible = false
	settingsPage.Visible = true
end)

-- Open/Close button
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0,120,0,35)
toggle.Position = UDim2.new(0,10,0.8,0)
toggle.Text = "Open / Close"
toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggle.TextColor3 = Color3.fromRGB(255,255,255)

toggle.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)
