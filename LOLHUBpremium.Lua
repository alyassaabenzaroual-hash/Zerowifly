--[[
    اسم السكربت: LOLHUBpremium
    للهواتف المحمولة (Mobile Support)
    نظام Key: ghali
    GitHub: https://github.com/LOLHUBpremium
--]]

-- متغيرات عامة
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- نظام الـ Key
local KeySystem = {
    requiredKey = "ghali",
    userKey = "",
    isVerified = false
}

-- إعدادات السكربت
local settings = {
    aimbot = {
        enabled = false,
        ignoreKnocked = true,
        wallHack = false,
        showFOV = false,
        aimType = "onShoot"
    },
    esp = {
        enabled = false,
        showLines = false,
        showBoxes = false,
        showSkeleton = false,
        showNames = false,
        showHealth = false,
        showDistance = false,
        hideMenu = false
    },
    misc = {
        aimkill = false,
        speed = false,
        fly = false,
        noRecoil = false,
        teleport = false
    },
    colors = {
        menu = Color3.fromRGB(255, 70, 70),
        fov = Color3.fromRGB(255, 0, 0),
        espVisible = Color3.fromRGB(0, 255, 0),
        espInvisible = Color3.fromRGB(255, 255, 0),
        nameText = Color3.fromRGB(255, 255, 255),
        distanceText = Color3.fromRGB(200, 200, 200)
    }
}

-- ========== واجهة الـ Key System (شاشة القفل) ==========
local function createKeySystem()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LOLHUB_KeySystem"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- خلفية داكنة
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.7
    background.Parent = screenGui
    
    -- الإطار الرئيسي
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- زوايا دائرية
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = mainFrame
    
    -- شعار LOLHUBpremium
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 80)
    logo.Position = UDim2.new(0, 0, 0, 20)
    logo.BackgroundTransparency = 1
    logo.Text = "🔥 LOLHUBpremium 🔥"
    logo.TextColor3 = Color3.fromRGB(255, 70, 70)
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.Parent = mainFrame
    
    -- نص إدخال الـ Key
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, -40, 0, 30)
    keyLabel.Position = UDim2.new(0, 20, 0, 130)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = "ENTER KEY:"
    keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    keyLabel.TextSize = 16
    keyLabel.Font = Enum.Font.Gotham
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.Parent = mainFrame
    
    -- حقل إدخال الـ Key
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(1, -40, 0, 50)
    keyBox.Position = UDim2.new(0, 20, 0, 165)
    keyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.PlaceholderText = "Enter key here..."
    keyBox.Text = ""
    keyBox.TextSize = 18
    keyBox.Font = Enum.Font.Gotham
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = mainFrame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 10)
    boxCorner.Parent = keyBox
    
    -- زر التحقق
    local verifyButton = Instance.new("TextButton")
    verifyButton.Size = UDim2.new(0, 200, 0, 50)
    verifyButton.Position = UDim2.new(0.5, -100, 0, 240)
    verifyButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    verifyButton.Text = "✅ VERIFY KEY"
    verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    verifyButton.TextSize = 18
    verifyButton.Font = Enum.Font.GothamBold
    verifyButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = verifyButton
    
    -- زر الديسكورد
    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(0, 200, 0, 40)
    discordButton.Position = UDim2.new(0.5, -100, 0, 310)
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordButton.Text = "💬 JOIN DISCORD"
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextSize = 16
    discordButton.Font = Enum.Font.Gotham
    discordButton.Parent = mainFrame
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 10)
    discordCorner.Parent = discordButton
    
    -- نص الخطأ
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, -40, 0, 30)
    errorLabel.Position = UDim2.new(0, 20, 0, 370)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    errorLabel.TextSize = 14
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.Parent = mainFrame
    
    -- تأثير تموج عند الضغط
    verifyButton.MouseButton1Click:Connect(function()
        local inputKey = keyBox.Text:lower()
        if inputKey == KeySystem.requiredKey then
            KeySystem.isVerified = true
            KeySystem.userKey = inputKey
            
            -- تأثير نجاح
            verifyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            errorLabel.Text = "✅ Key Verified! Loading Menu..."
            errorLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            -- إخفاء شاشة الـ Key بعد ثانية
            task.wait(1)
            screenGui:Destroy()
            createMainMenu() -- إنشاء القائمة الرئيسية بعد التحقق
        else
            -- تأثير فشل
            verifyButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            errorLabel.Text = "❌ Invalid Key! Access Denied."
            errorLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            
            task.wait(0.5)
            verifyButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        end
    end)
    
    discordButton.MouseButton1Click:Connect(function()
        setclipboard or toclipboard("https://discord.gg/LOLHUBpremium")
        errorLabel.Text = "📋 Discord link copied!"
        errorLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        task.wait(1.5)
        errorLabel.Text = ""
    end)
    
    -- دعم لوحة المفاتيح للهواتف
    keyBox.Focused:Connect(function()
        UserInputService.TextBoxFocused = true
    end)
    
    keyBox.FocusLost:Connect(function()
        UserInputService.TextBoxFocused = false
    end)
end

-- ========== القائمة الرئيسية (متوافقة مع اللمس) ==========
local function createMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LOLHUB_Menu"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- زر القائمة العائم (Floating Button)
    local floatingButton = Instance.new("ImageButton")
    floatingButton.Size = UDim2.new(0, 60, 0, 60)
    floatingButton.Position = UDim2.new(0, 10, 1, -80)
    floatingButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    floatingButton.Image = "rbxassetid://6023426923" -- أيقونة روبلوكس افتراضية
    floatingButton.Parent = screenGui
    
    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatingButton
    
    -- تأثير ظل للزر
    local shadow = Instance.new("UIShadow")
    shadow.Parent = floatingButton
    
    -- القائمة الجانبية (Slide-out Menu)
    local menuFrame = Instance.new("Frame")
    menuFrame.Size = UDim2.new(0, 300, 1, 0)
    menuFrame.Position = UDim2.new(-1, 0, 0, 0)
    menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    menuFrame.BorderSizePixel = 0
    menuFrame.Parent = screenGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 15)
    menuCorner.Parent = menuFrame
    
    -- شريط العنوان
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 60)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = menuFrame
    
    -- زر إغلاق القائمة
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    -- عنوان LOLHUBpremium
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 0, 40)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔥 LOLHUBpremium 🔥"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- ScrollingFrame للأزرار (للهواتف)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -60)
    scrollFrame.Position = UDim2.new(0, 0, 0, 60)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.Parent = menuFrame
    
    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 10)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = scrollFrame
    
    -- ========== إنشاء الأزرار والمفاتيح ==========
    local function createCategory(title)
        local catLabel = Instance.new("TextLabel")
        catLabel.Size = UDim2.new(1, -20, 0, 40)
        catLabel.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        catLabel.Text = title
        catLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        catLabel.TextSize = 16
        catLabel.Font = Enum.Font.GothamBold
        catLabel.Parent = scrollFrame
        
        local catCorner = Instance.new("UICorner")
        catCorner.CornerRadius = UDim.new(0, 8)
        catCorner.Parent = catLabel
        
        return catLabel
    end
    
    local function createToggle(text, settingPath, defaultValue)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -20, 0, 50)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        toggleFrame.Parent = scrollFrame
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 10)
        frameCorner.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 70, 0, 35)
        toggleButton.Position = UDim2.new(1, -85, 0.5, -17.5)
        toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
        toggleButton.Text = defaultValue and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextSize = 14
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Parent = toggleFrame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggleButton
        
        -- تعيين القيمة الافتراضية
        local path = string.split(settingPath, ".")
        local current = settings
        for i = 1, #path - 1 do
            current = current[path[i]]
        end
        current[path[#path]] = defaultValue
        
        toggleButton.MouseButton1Click:Connect(function()
            current[path[#path]] = not current[path[#path]]
            toggleButton.BackgroundColor3 = current[path[#path]] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
            toggleButton.Text = current[path[#path]] and "ON" or "OFF"
        end)
        
        return toggleFrame
    end
    
    local function createButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 15
        btn.Font = Enum.Font.GothamBold
        btn.Parent = scrollFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    -- ========== بناء القائمة ==========
    createCategory("🎯 AIMBOT")
    createToggle("✅ Activate Aimbot", "aimbot.enabled", false)
    createToggle("🚫 Ignorar Derrubados", "aimbot.ignoreKnocked", true)
    createToggle("🧱 Puxar em Paredes", "aimbot.wallHack", false)
    createToggle("👁️ Exibir FOV", "aimbot.showFOV", false)
    
    createCategory("👁‍🗨 ESP")
    createToggle("✅ Activar ESP", "esp.enabled", false)
    createToggle("📏 ESP Linha", "esp.showLines", false)
    createToggle("📦 ESP Caixa", "esp.showBoxes", false)
    createToggle("🦴 ESP Esqueleto", "esp.showSkeleton", false)
    createToggle("🏷️ ESP Nome", "esp.showNames", false)
    createToggle("❤️ ESP Vida", "esp.showHealth", false)
    createToggle("🛣️ ESP Distância", "esp.showDistance", false)
    createToggle("🙈 Esconder Painel", "esp.hideMenu", false)
    
    createCategory("⚙️ RAGE FEATURES")
    createToggle("⚔️ AimKill", "misc.aimkill", false)
    createToggle("🏃‍♂️ Speed", "misc.speed", false)
    createToggle("🕊️ Voar Player", "misc.fly", false)
    createToggle("🚫 No Recoil", "misc.noRecoil", false)
    createToggle("🌀 Teleport 8m", "misc.teleport", false)
    
    createCategory("ℹ️ INFO")
    createButton("📋 Copy Discord Link", function()
        setclipboard or toclipboard("https://discord.gg/LOLHUBpremium")
        print("Discord link copied!")
    end)
    
    createButton("✨ GitHub: LOLHUBpremium", function()
        setclipboard or toclipboard("https://github.com/LOLHUBpremium")
        print("GitHub link copied!")
    end)
    
    -- التحكم في إظهار/إخفاء القائمة
    local menuOpen = false
    floatingButton.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        local targetPos = menuOpen and UDim2.new(0, 0, 0, 0) or UDim2.new(-1, 0, 0, 0)
        local tween = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = targetPos})
        tween:Play()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        menuOpen = false
        local tween = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(-1, 0, 0, 0)})
        tween:Play()
    end)
    
    -- سحب Floating Button
    local dragging = false
    local dragStart, buttonStart
    
    floatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            buttonStart = floatingButton.Position
        end
    end)
    
    floatingButton.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            local newX = math.clamp(buttonStart.X.Offset + delta.X, 0, screenGui.AbsoluteSize.X - 60)
            local newY = math.clamp(buttonStart.Y.Offset + delta.Y, 0, screenGui.AbsoluteSize.Y - 100)
            floatingButton.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    
    floatingButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ========== بدء التشغيل ==========
-- تأخير بسيط للتأكد من تحميل كل شيء
task.wait(1)
createKeySystem()
print("🔥 LOLHUBpremium Loaded - Key Required: ghali 🔥")
