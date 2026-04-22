local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- إعدادات التحقق (Passkey)
local correctPass = "WWWATWHYG"
local isVerified = false

-- إنشاء واجهة التحقق أولاً
local AuthWindow = Library.CreateLib("RAYVoHub | Verification", "GrapeTheme")
local AuthTab = AuthWindow:NewTab("التحقق")
local AuthSection = AuthTab:NewSection("أدخل رمز الدخول")

AuthSection:NewTextBox("Passkey Here", "أدخل الرمز لتشغيل السكربت", function(txt)
    if txt == correctPass then
        isVerified = true
        print("Access Granted!")
        -- إغلاق واجهة التحقق وفتح السكربت الأساسي
        game:GetService("CoreGui"):FindFirstChild("RAYVoHub | Verification"):Destroy()
        
        -- تشغيل السكربت الأساسي
        StartRayVoHub()
    else
        print("Wrong Passkey!")
    end
end)

-- الوظيفة الأساسية للسكربت
function StartRayVoHub()
    local Window = Library.CreateLib("RAYVoHub | Escape Tsunami 🌊", "GrapeTheme")
    
    -- المتغيرات الأساسية للطيران
    local flying = false
    local speed = 50
    local player = game.Players.LocalPlayer
    
    -- وظيفة الطيران
    function toggleFly()
        if flying then
            flying = false
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if player.Character.HumanoidRootPart:FindFirstChild("Velocity") then player.Character.HumanoidRootPart.Velocity:Destroy() end
                if player.Character.HumanoidRootPart:FindFirstChild("Gyro") then player.Character.HumanoidRootPart.Gyro:Destroy() end
                player.Character.Humanoid.PlatformStand = false
            end
        else
            flying = true
            local bg = Instance.new("BodyGyro", player.Character.HumanoidRootPart)
            bg.Name = "Gyro"
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = player.Character.HumanoidRootPart.CFrame
            
            local bv = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
            bv.Name = "Velocity"
            bv.velocity = Vector3.new(0, 0.1, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            spawn(function()
                while flying do
                    player.Character.Humanoid.PlatformStand = true
                    bv.velocity = (workspace.CurrentCamera.CFrame.LookVector * speed)
                    bg.cframe = workspace.CurrentCamera.CFrame
                    task.wait()
                end
            end)
        end
    end

    -- [ القائمة الرئيسية ]
    local Main = Window:NewTab("الرئيسية")
    local MainSection = Main:NewSection("المميزات الخارقة")

    MainSection:NewButton("Godmode (خلود)", "لن تتأثر بالتسونامي", function()
        local char = player.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanTouch = false end
            end
        end
    end)

    -- [ قسم الطيران ]
    local FlyTab = Window:NewTab("الطيران")
    local FlySection = FlyTab:NewSection("تحكم في الجاذبية")

    FlySection:NewButton("تفعيل / إلغاء الطيران (Fly/Unfly)", "اضغط للطيران أو الهبوط", function()
        toggleFly()
    end)

    FlySection:NewSlider("سرعة الطيران", "تحكم في سرعة تحليقك", 300, 10, function(s)
        speed = s
    end)

    -- [ قسم الحركة ]
    local Movement = Window:NewTab("الحركة")
    local MoveSection = Movement:NewSection("السرعة والقفز")

    MoveSection:NewSlider("سرعة المشي", "سرعة ركضك", 500, 16, function(s)
        player.Character.Humanoid.WalkSpeed = s
    end)

    MoveSection:NewSlider("قوة القفز", "ارتفاع القفزة", 500, 50, function(s)
        player.Character.Humanoid.JumpPower = s
    end)

    -- [ قسم التنقل ]
    local TP = Window:NewTab("التنقل")
    local TPSection = TP:NewSection("اختصارات الأماكن")

    TPSection:NewButton("انتقال للنهاية (Win Zone)", "للفوز فوراً", function()
        local target = workspace:FindFirstChild("WinPart") or workspace:FindFirstChild("Finish") or workspace:FindFirstChild("End")
        if target then
            player.Character.HumanoidRootPart.CFrame = target.CFrame
        end
    end)

    -- [ الإعدادات ]
    local Settings = Window:NewTab("الإعدادات")
    local SetSection = Settings:NewSection("التحكم")

    SetSection:NewKeybind("إخفاء القائمة", "RightControl للفتح والإغلاق", Enum.KeyCode.RightControl, function()
        Library:ToggleUI()
    end)
end
