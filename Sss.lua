-- ==========================================
-- الخدمات الأساسية
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- الإعدادات والمتغيرات (Settings)
-- ==========================================
local Settings = {
    Aimbot = {
        Enabled = false,
        ShowFOV = false,
        FOV_Radius = 120,
        TriggerBot = false,
        HitboxExpander = false,
        HitboxSize = 25,
        WallBang = false
    },
    ESP = {
        Enabled = false,
        ShowNames = false,
        Chams = false
    },
    Combo = {
        SpeedBoost = false,
        SpeedMultiplier = 2,
        InfiniteJump = false,
        Noclip = false,
        GodMode = false,
        InfAmmo = false,
        JumpPowerBoost = false,
        JumpPowerMultiplier = 2
    },
    Transmission = {
        SavedPosition = nil,
        SavedCFrame = nil
    },
    AutoClicker = {
        Enabled = false,
        ShowIcon = false,
        CPS = 10
    },
    Friends = {}
}

local TargetPartsPriority = {"Head", "UpperTorso", "Torso", "LowerTorso", "RightUpperArm", "RightArm", "LeftUpperArm", "LeftArm", "RightLowerArm", "LeftLowerArm"}

-- ==========================================
-- دالة تأثير ألوان قوس قزح
-- ==========================================
local function RainbowColor(speed)
    local hue = (tick() * (speed or 0.5)) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- ==========================================
-- 1. شاشة الدخول (Loading Screen)
-- ==========================================
local LoadingScreen = Instance.new("ScreenGui")
LoadingScreen.Name = "HasanLoading"
LoadingScreen.ResetOnSpawn = false
LoadingScreen.IgnoreGuiInset = true
LoadingScreen.Parent = CoreGui

local LoadingBg = Instance.new("Frame")
LoadingBg.Size = UDim2.new(1, 0, 1, 0)
LoadingBg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LoadingBg.BorderSizePixel = 0
LoadingBg.Parent = LoadingScreen

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 100, 0, 100)
LogoLabel.AnchorPoint = Vector2.new(0.5, 0.5)
LogoLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "Z"
LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextSize = 65
LogoLabel.Parent = LoadingBg

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 25)
LoadingText.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingText.Position = UDim2.new(0.5, 0, 0.65, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Loading..."
LoadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
LoadingText.Font = Enum.Font.GothamMedium
LoadingText.TextSize = 12
LoadingText.Parent = LoadingBg

-- Animation for logo
coroutine.wrap(function()
    LogoLabel.TextTransparency = 1
    TweenService:Create(LogoLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    
    local pulseTween = TweenService:Create(LogoLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 115, 0, 115)})
    pulseTween:Play()
    
    task.wait(2.5)
    
    TweenService:Create(LoadingBg, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LogoLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingText, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
    
    task.wait(0.6)
    LoadingScreen:Destroy()
end)()

-- ==========================================
-- 2. بناء الواجهة الرئيسية (Main GUI) - مصغرة 20%
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HasanHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- مجلد ESP
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Folder"
ESPFolder.Parent = ScreenGui

-- دائرة FOV
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.Aimbot.FOV_Radius * 2, 0, Settings.Aimbot.FOV_Radius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
local FOVStroke = Instance.new("UIStroke", FOVCircle)
FOVStroke.Color = Color3.fromRGB(255, 255, 255); FOVStroke.Thickness = 1.5

-- ==========================================
-- 3. الإطار الرئيسي (مصغر 20%: 320*0.8=256, 420*0.8=336)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 256, 0, 336)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainFrame.BackgroundTransparency = 0
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- تأثير زجاجي فوق الخلفية
local GlassEffect = Instance.new("Frame")
GlassEffect.Size = UDim2.new(1, 0, 1, 0)
GlassEffect.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
GlassEffect.BackgroundTransparency = 0.3
GlassEffect.BorderSizePixel = 0
GlassEffect.ZIndex = 2
GlassEffect.Parent = MainFrame
Instance.new("UICorner", GlassEffect).CornerRadius = UDim.new(0, 10)

-- ==========================================
-- 3.1 تأثير الرموز الساقطة داخل الواجهة (محسن)
-- ==========================================
local matrixSymbols = {"$", "%", "&", "@", "+", "*", "Z", "#", "!", "?", "/", "\\", "~", "=", "<", ">"}
local matrixChars = {}

-- إنشاء الرموز داخل MainFrame
for i = 1, 25 do
    local char = Instance.new("TextLabel")
    char.Size = UDim2.new(0, 20, 0, 20)
    -- وضع عشوائي على المحور Y أيضاً
    local randomY = math.random() * 1.1 - 0.1 -- بين -0.1 و 1.0
    char.Position = UDim2.new(math.random() * 0.9, 0, randomY, 0)
    char.BackgroundTransparency = 1
    char.Text = matrixSymbols[math.random(1, #matrixSymbols)]
    char.TextColor3 = Color3.fromRGB(0, math.random(120, 255), math.random(80, 200))
    char.Font = Enum.Font.GothamBold
    char.TextSize = math.random(11, 20)
    char.TextTransparency = math.random(3, 7) / 10
    char.ZIndex = 1
    char.Parent = MainFrame
    
    matrixChars[char] = {
        Speed = math.random(15, 45) / 100, -- سرعات مختلفة
        XPos = math.random() * 0.9,
        StartY = randomY
    }
end

-- تحريك الرموز بشكل سلس ومستقر
RunService.RenderStepped:Connect(function(dt)
    local deltaTime = math.min(dt, 0.1) -- منع القفزات الكبيرة
    for char, data in pairs(matrixChars) do
        if char and char.Parent then
            local pos = char.Position
            -- تحريك للأسفل
            local newY = pos.Y.Scale + (data.Speed * deltaTime)
            
            -- إذا وصل للأسفل، أعده للأعلى
            if newY > 1.05 then
                newY = -0.1
                char.Text = matrixSymbols[math.random(1, #matrixSymbols)]
                char.TextTransparency = math.random(3, 7) / 10
                char.TextColor3 = Color3.fromRGB(0, math.random(120, 255), math.random(80, 200))
                data.Speed = math.random(15, 45) / 100 -- تغيير السرعة
            end
            
            char.Position = UDim2.new(data.XPos, 0, newY, 0)
        end
    end
end)

-- ==========================================
-- 4. شريط العنوان (مصغر)
-- ==========================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundTransparency = 0.5
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 10
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local LogoSmall = Instance.new("TextLabel")
LogoSmall.Size = UDim2.new(0, 24, 0, 24)
LogoSmall.Position = UDim2.new(0, 8, 0.5, -12)
LogoSmall.BackgroundTransparency = 1
LogoSmall.Text = "Z"
LogoSmall.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoSmall.Font = Enum.Font.GothamBold
LogoSmall.TextSize = 16
LogoSmall.ZIndex = 10
LogoSmall.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 120, 1, 0)
TitleLabel.Position = UDim2.new(0, 36, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Hasan Hub"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 10
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 40, 0, 12)
VersionLabel.Position = UDim2.new(0, 36, 0, 20)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v2.0.0"
VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 8
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.ZIndex = 10
VersionLabel.Parent = TitleBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 6, 0, 6)
StatusDot.Position = UDim2.new(0, 145, 0.5, -3)
StatusDot.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
StatusDot.ZIndex = 10
StatusDot.Parent = TitleBar
Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 50, 0, 12)
StatusText.Position = UDim2.new(0, 155, 0.5, -6)
StatusText.BackgroundTransparency = 1
StatusText.Text = "● Online"
StatusText.TextColor3 = Color3.fromRGB(50, 255, 50)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 8
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.ZIndex = 10
StatusText.Parent = TitleBar

RunService.RenderStepped:Connect(function()
    TitleLabel.TextColor3 = RainbowColor(0.3)
end)

-- أزرار التحكم (مصغرة)
local function CreateTitleBtn(text, color, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 24, 0, 24)
    btn.Position = UDim2.new(1, xOffset, 0.5, -12)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.ZIndex = 10
    btn.Parent = TitleBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local CloseBtn = CreateTitleBtn("✕", Color3.fromRGB(255, 65, 65), -28)
local MinBtn = CreateTitleBtn("−", Color3.fromRGB(50, 150, 255), -56)

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
        {Size = isMinimized and UDim2.new(0, 256, 0, 36) or UDim2.new(0, 256, 0, 336)}):Play()
    MinBtn.Text = isMinimized and "+" or "−"
end)

CloseBtn.MouseButton1Click:Connect(function()
    Settings.Aimbot.Enabled = false; Settings.ESP.Enabled = false
    Settings.Aimbot.HitboxExpander = false; Settings.Aimbot.WallBang = false
    Settings.AutoClicker.Enabled = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
        {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- ==========================================
-- 5. نظام السحب المحسن (حرية كاملة داخل الشاشة)
-- ==========================================
local function MakeDraggable(gui, dragArea)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragStart = nil
            startPos = nil
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local guiSize = gui.AbsoluteSize
            local viewportSize = Camera.ViewportSize
            
            -- حساب الموقع الجديد مع حرية كاملة
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            
            -- السماح فقط بحدود منطقية (عدم خروج كامل)
            newX = math.clamp(newX, -guiSize.X + 30, viewportSize.X - 30)
            newY = math.clamp(newY, 0, viewportSize.Y - 36)
            
            gui.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

-- تطبيق السحب على شريط العنوان
MakeDraggable(MainFrame, TitleBar)

-- ==========================================
-- 6. نظام التبويبات (مصغر)
-- ==========================================
local TabsContainer = Instance.new("ScrollingFrame")
TabsContainer.Size = UDim2.new(1, -8, 0, 32)
TabsContainer.Position = UDim2.new(0, 4, 0, 40)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0
TabsContainer.ScrollingDirection = Enum.ScrollingDirection.X
TabsContainer.ScrollBarThickness = 1
TabsContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
TabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsContainer.ZIndex = 5
TabsContainer.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabsContainer

TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabsContainer.CanvasSize = UDim2.new(0, TabListLayout.AbsoluteContentSize.X + 8, 0, 0)
end)

local function CreateScrollContainer(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -80)
    scroll.Position = UDim2.new(0, 4, 0, 76)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    scroll.ScrollBarImageTransparency = 0.3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Visible = false
    scroll.ZIndex = 5
    scroll.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    
    return scroll
end

local AimbotScroll = CreateScrollContainer("AimbotScroll")
local ESPScroll = CreateScrollContainer("ESPScroll")
local ComboScroll = CreateScrollContainer("ComboScroll")
local FriendsScroll = CreateScrollContainer("FriendsScroll")
local TeleportScroll = CreateScrollContainer("TeleportScroll")
local TransmissionScroll = CreateScrollContainer("TransmissionScroll")
local FarmScroll = CreateScrollContainer("FarmScroll")
local AutoClickerScroll = CreateScrollContainer("AutoClickerScroll")

AimbotScroll.Visible = true

local tabButtons = {}
local function CreateTabButton(text, icon, targetScroll)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 56, 1, -4)
    btn.BackgroundColor3 = targetScroll.Visible and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 45)
    btn.Text = icon .. " " .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 9
    btn.ZIndex = 5
    btn.Parent = TabsContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.Size = UDim2.new(0, btn.TextBounds.X + 20, 1, -4)
    
    table.insert(tabButtons, btn)
    
    btn.MouseButton1Click:Connect(function()
        local tabs = {
            AimbotScroll, ESPScroll, ComboScroll, FriendsScroll,
            TeleportScroll, TransmissionScroll, FarmScroll, AutoClickerScroll
        }
        for _, tab in ipairs(tabs) do
            tab.Visible = (tab == targetScroll)
        end
        
        for _, otherBtn in ipairs(tabButtons) do
            TweenService:Create(otherBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
                {BackgroundColor3 = (otherBtn == btn) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(40, 40, 45)}):Play()
        end
    end)
end

CreateTabButton("Aimbot", "🎯", AimbotScroll)
CreateTabButton("ESP", "👁️", ESPScroll)
CreateTabButton("Combo", "⚡", ComboScroll)
CreateTabButton("Friends", "👥", FriendsScroll)
CreateTabButton("TP", "📍", TeleportScroll)
CreateTabButton("Trans", "💾", TransmissionScroll)
CreateTabButton("Farm", "🤖", FarmScroll)
CreateTabButton("Clicker", "🖱️", AutoClickerScroll)

-- ==========================================
-- 7. عناصر التحكم (مصغرة)
-- ==========================================
local function CreateToggleItem(parentScroll, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.BackgroundTransparency = 0.1
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 5
    btn.Parent = parentScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(1, -22, 0.5, -7)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    indicator.ZIndex = 5
    indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
            {BackgroundColor3 = state and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), 
            {TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)}):Play()
        callback(state)
    end)
end

local function CreateInputItem(parentScroll, text, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 30)
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    container.BackgroundTransparency = 0.1
    container.ZIndex = 5
    container.Parent = parentScroll
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 5)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5
    label.Parent = container
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.35, 0, 0.6, 0)
    box.Position = UDim2.new(0.62, 0, 0.2, 0)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.Text = placeholder
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    box.ZIndex = 5
    box.Parent = container
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
    
    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then callback(num) else box.Text = placeholder end
    end)
end

-- ==========================================
-- 8. نظام الإشعارات (مصغر)
-- ==========================================
local function ShowNotification(text, duration)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 200, 0, 32)
    notif.Position = UDim2.new(0.5, -100, -0.1, 0)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notif.BackgroundTransparency = 0.2
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    notif.Parent = ScreenGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, 0, 1, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = text
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.Font = Enum.Font.GothamSemibold
    notifText.TextSize = 11
    notifText.ZIndex = 100
    notifText.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
        {Position = UDim2.new(0.5, -100, 0.02, 0)}):Play()
    
    task.spawn(function()
        task.wait(duration or 3)
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), 
            {Position = UDim2.new(0.5, -100, -0.1, 0), BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        notif:Destroy()
    end)
end

-- ==========================================
-- 9. قائمة Transmission (مصغرة)
-- ==========================================
local function CreateTransmissionButtons(parentScroll)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 112)
    container.BackgroundTransparency = 1
    container.ZIndex = 5
    container.Parent = parentScroll
    
    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Size = UDim2.new(1, 0, 0, 36)
    SaveBtn.Position = UDim2.new(0, 0, 0, 0)
    SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    SaveBtn.Text = "💾 Save Position"
    SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.TextSize = 11
    SaveBtn.ZIndex = 5
    SaveBtn.Parent = container
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)
    
    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Size = UDim2.new(1, 0, 0, 36)
    TeleportBtn.Position = UDim2.new(0, 0, 0, 44)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    TeleportBtn.Text = "🚀 Teleport"
    TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.TextSize = 11
    TeleportBtn.ZIndex = 5
    TeleportBtn.Parent = container
    Instance.new("UICorner", TeleportBtn).CornerRadius = UDim.new(0, 6)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 16)
    StatusLabel.Position = UDim2.new(0, 0, 1, 12)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "⚠️ No position saved"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 9
    StatusLabel.ZIndex = 5
    StatusLabel.Parent = container
    
    SaveBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            Settings.Transmission.SavedPosition = char.HumanoidRootPart.Position
            Settings.Transmission.SavedCFrame = char.HumanoidRootPart.CFrame
            StatusLabel.Text = "✅ Position saved!"
            StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            ShowNotification("✅ Position saved successfully", 2)
            task.wait(2)
            StatusLabel.Text = "⚠️ No position saved"
            StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
    
    TeleportBtn.MouseButton1Click:Connect(function()
        if Settings.Transmission.SavedPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Settings.Transmission.SavedPosition + Vector3.new(0, 2, 0))
            ShowNotification("🚀 Teleported to saved position", 2)
        end
    end)
end

-- ==========================================
-- 10. نظام Auto Farm (مصغر)
-- ==========================================
local function CreateFarmButtons(parentScroll)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 144)
    container.BackgroundTransparency = 1
    container.ZIndex = 5
    container.Parent = parentScroll
    
    local MacroPath = {}
    local isRecording = false
    local isPlaying = false
    local recordConnection = nil
    
    local function CreateFarmBtn(text, color, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.ZIndex = 5
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end
    
    local RecordBtn = CreateFarmBtn("⏺️ Record", Color3.fromRGB(200, 50, 50), 0)
    local SaveBtn = CreateFarmBtn("💾 Save Farm", Color3.fromRGB(50, 200, 100), 44)
    local PlayBtn = CreateFarmBtn("▶️ Play", Color3.fromRGB(0, 150, 255), 88)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 16)
    StatusLabel.Position = UDim2.new(0, 0, 1, 4)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Ready to record..."
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 9
    StatusLabel.ZIndex = 5
    StatusLabel.Parent = container
    
    local function Countdown(btn, endText, callback)
        task.spawn(function()
            local originalColor = btn.BackgroundColor3
            btn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
            for i = 3, 1, -1 do
                btn.Text = tostring(i) .. "..."
                task.wait(1)
            end
            btn.BackgroundColor3 = originalColor
            btn.Text = endText
            callback()
        end)
    end
    
    RecordBtn.MouseButton1Click:Connect(function()
        if isRecording or isPlaying then return end
        Countdown(RecordBtn, "🔴 Recording...", function()
            MacroPath = {}
            isRecording = true
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                recordConnection = RunService.Heartbeat:Connect(function(dt)
                    if isRecording and hrp then
                        table.insert(MacroPath, {cframe = hrp.CFrame, dt = dt})
                    end
                end)
            end
        end)
    end)
    
    SaveBtn.MouseButton1Click:Connect(function()
        if isRecording then
            isRecording = false
            if recordConnection then recordConnection:Disconnect() end
            RecordBtn.Text = "⏺️ Record"
            ShowNotification("✅ Farm saved! (" .. #MacroPath .. " points)", 2)
        end
    end)
    
    PlayBtn.MouseButton1Click:Connect(function()
        if isRecording then return end
        if isPlaying then
            isPlaying = false
            PlayBtn.Text = "▶️ Play"
            PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            return
        end
        if #MacroPath == 0 then
            ShowNotification("❌ No farm data!", 2)
            return
        end
        Countdown(PlayBtn, "⏹️ Stop", function()
            isPlaying = true
            PlayBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.spawn(function()
                while isPlaying do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and #MacroPath > 0 then
                        hrp.Anchored = true
                        for _, step in ipairs(MacroPath) do
                            if not isPlaying then break end
                            hrp.CFrame = step.cframe
                            task.wait(step.dt)
                        end
                        hrp.Anchored = false
                    end
                    if not isPlaying then break end
                    task.wait(3)
                end
            end)
        end)
    end)
end

-- ==========================================
-- 11. نظام Auto Clicker (مصغر)
-- ==========================================
local ClickerIcon = Instance.new("Frame")
ClickerIcon.Size = UDim2.new(0, 26, 0, 26)
ClickerIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
ClickerIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ClickerIcon.Visible = false
ClickerIcon.ZIndex = 50
ClickerIcon.Parent = ScreenGui
Instance.new("UICorner", ClickerIcon).CornerRadius = UDim.new(1, 0)
MakeDraggable(ClickerIcon, ClickerIcon)

local ClickerDot = Instance.new("Frame")
ClickerDot.Size = UDim2.new(0, 8, 0, 8)
ClickerDot.AnchorPoint = Vector2.new(0.5, 0.5)
ClickerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
ClickerDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ClickerDot.ZIndex = 51
ClickerDot.Parent = ClickerIcon
Instance.new("UICorner", ClickerDot).CornerRadius = UDim.new(1, 0)

local function CreateAutoClickerUI(parentScroll)
    local ShowBtn = Instance.new("TextButton")
    ShowBtn.Size = UDim2.new(1, -8, 0, 32)
    ShowBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ShowBtn.Text = "Show Icon"
    ShowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ShowBtn.Font = Enum.Font.GothamBold
    ShowBtn.TextSize = 10
    ShowBtn.ZIndex = 5
    ShowBtn.Parent = parentScroll
    Instance.new("UICorner", ShowBtn).CornerRadius = UDim.new(0, 5)
    
    ShowBtn.MouseButton1Click:Connect(function()
        Settings.AutoClicker.ShowIcon = not Settings.AutoClicker.ShowIcon
        ClickerIcon.Visible = Settings.AutoClicker.ShowIcon
        ShowBtn.Text = Settings.AutoClicker.ShowIcon and "Hide Icon" or "Show Icon"
        TweenService:Create(ShowBtn, TweenInfo.new(0.2), 
            {BackgroundColor3 = Settings.AutoClicker.ShowIcon and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(45, 45, 50)}):Play()
    end)
    
    CreateInputItem(parentScroll, "CPS:", "10", function(val)
        Settings.AutoClicker.CPS = math.max(1, tonumber(val) or 10)
    end)
    
    local StartBtn = Instance.new("TextButton")
    StartBtn.Size = UDim2.new(1, -8, 0, 36)
    StartBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    StartBtn.Text = "Start Clicker"
    StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartBtn.Font = Enum.Font.GothamBold
    StartBtn.TextSize = 11
    StartBtn.ZIndex = 5
    StartBtn.Parent = parentScroll
    Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)
    
    StartBtn.MouseButton1Click:Connect(function()
        Settings.AutoClicker.Enabled = not Settings.AutoClicker.Enabled
        StartBtn.Text = Settings.AutoClicker.Enabled and "Stop Clicker" or "Start Clicker"
        TweenService:Create(StartBtn, TweenInfo.new(0.2), 
            {BackgroundColor3 = Settings.AutoClicker.Enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 150, 255)}):Play()
    end)
    
    task.spawn(function()
        while true do
            if Settings.AutoClicker.Enabled and ClickerIcon.Visible then
                local centerPos = ClickerIcon.AbsolutePosition + (ClickerIcon.AbsoluteSize / 2)
                VirtualUser:ClickButton1(centerPos)
            end
            task.wait(1 / math.max(1, (Settings.AutoClicker.CPS or 10)))
        end
    end)
end

CreateAutoClickerUI(AutoClickerScroll)

-- ==========================================
-- 12. قوائم الأصدقاء والانتقال (مصغرة)
-- ==========================================
local function CreateFriendRow(parentScroll, player)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 36)
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    container.BackgroundTransparency = 0.1
    container.ZIndex = 5
    container.Parent = parentScroll
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 5)
    
    local headIcon = Instance.new("ImageLabel")
    headIcon.Size = UDim2.new(0, 24, 0, 24)
    headIcon.Position = UDim2.new(0, 6, 0.5, -12)
    headIcon.BackgroundTransparency = 1
    headIcon.ZIndex = 5
    headIcon.Parent = container
    Instance.new("UICorner", headIcon).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        local content = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        headIcon.Image = content
    end)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 80, 1, 0)
    nameLabel.Position = UDim2.new(0, 36, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextSize = 10
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = container
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -48, 0.5, -10)
    btn.BackgroundColor3 = Settings.Friends[player.UserId] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    btn.Text = Settings.Friends[player.UserId] and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.ZIndex = 5
    btn.Parent = container
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        Settings.Friends[player.UserId] = not Settings.Friends[player.UserId]
        TweenService:Create(btn, TweenInfo.new(0.2), 
            {BackgroundColor3 = Settings.Friends[player.UserId] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)}):Play()
        btn.Text = Settings.Friends[player.UserId] and "ON" or "OFF"
    end)
end

local function CreateTeleportRow(parentScroll, player)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 36)
    container.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    container.BackgroundTransparency = 0.1
    container.ZIndex = 5
    container.Parent = parentScroll
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 5)
    
    local headIcon = Instance.new("ImageLabel")
    headIcon.Size = UDim2.new(0, 24, 0, 24)
    headIcon.Position = UDim2.new(0, 6, 0.5, -12)
    headIcon.BackgroundTransparency = 1
    headIcon.ZIndex = 5
    headIcon.Parent = container
    Instance.new("UICorner", headIcon).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        local content = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        headIcon.Image = content
    end)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 80, 1, 0)
    nameLabel.Position = UDim2.new(0, 36, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextSize = 10
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 5
    nameLabel.Parent = container
    
    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Size = UDim2.new(0, 48, 0, 20)
    teleportBtn.Position = UDim2.new(1, -56, 0.5, -10)
    teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    teleportBtn.Text = "Teleport"
    teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.TextSize = 9
    teleportBtn.ZIndex = 5
    teleportBtn.Parent = container
    Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 5)
    
    teleportBtn.MouseButton1Click:Connect(function()
        local myChar = LocalPlayer.Character
        local targetChar = player.Character
        if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
            myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
            ShowNotification("📍 Teleported to " .. player.Name, 2)
        end
    end)
end

local function UpdateLists()
    for _, child in ipairs(FriendsScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for _, child in ipairs(TeleportScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateFriendRow(FriendsScroll, player)
            CreateTeleportRow(TeleportScroll, player)
        end
    end
end

Players.PlayerAdded:Connect(UpdateLists)
Players.PlayerRemoving:Connect(UpdateLists)
UpdateLists()

-- ==========================================
-- 13. تعبئة القوائم بالأوامر
-- ==========================================
-- Aimbot Tab
CreateToggleItem(AimbotScroll, "Smart Aimbot", function(s) Settings.Aimbot.Enabled = s end)
CreateToggleItem(AimbotScroll, "Hitbox Expander", function(s) Settings.Aimbot.HitboxExpander = s end)
CreateInputItem(AimbotScroll, "Hitbox Size:", "25", function(val) Settings.Aimbot.HitboxSize = val end)
CreateToggleItem(AimbotScroll, "Trigger Bot", function(s) Settings.Aimbot.TriggerBot = s end)
CreateToggleItem(AimbotScroll, "Wall Bang", function(s) Settings.Aimbot.WallBang = s end)
CreateToggleItem(AimbotScroll, "Show FOV Circle", function(s) Settings.Aimbot.ShowFOV = s; FOVCircle.Visible = s end)
CreateInputItem(AimbotScroll, "FOV Radius:", "120", function(val) Settings.Aimbot.FOV_Radius = val; FOVCircle.Size = UDim2.new(0, val * 2, 0, val * 2) end)

-- ESP Tab
CreateToggleItem(ESPScroll, "Enable ESP", function(s) Settings.ESP.Enabled = s end)
CreateToggleItem(ESPScroll, "Show Names", function(s) Settings.ESP.ShowNames = s end)
CreateToggleItem(ESPScroll, "Chams", function(s) Settings.ESP.Chams = s end)

-- Combo Tab
local FloatingTpBtn = Instance.new("TextButton")
FloatingTpBtn.Size = UDim2.new(0, 112, 0, 28)
FloatingTpBtn.Position = UDim2.new(0.5, -56, 0.85, 0)
FloatingTpBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
FloatingTpBtn.Text = "🎯 TP Nearest"
FloatingTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingTpBtn.Font = Enum.Font.GothamBold
FloatingTpBtn.TextSize = 10
FloatingTpBtn.Visible = false
FloatingTpBtn.ZIndex = 50
FloatingTpBtn.Parent = ScreenGui
Instance.new("UICorner", FloatingTpBtn).CornerRadius = UDim.new(0, 6)
MakeDraggable(FloatingTpBtn, FloatingTpBtn)

CreateToggleItem(ComboScroll, "Noclip", function(s) Settings.Combo.Noclip = s end)
CreateToggleItem(ComboScroll, "Show TP Button", function(s) FloatingTpBtn.Visible = s end)
CreateToggleItem(ComboScroll, "Speed Boost", function(s) Settings.Combo.SpeedBoost = s; if not s and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end)
CreateInputItem(ComboScroll, "Speed Multiplier:", "2", function(val) Settings.Combo.SpeedMultiplier = val; if Settings.Combo.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 * val end end)
CreateToggleItem(ComboScroll, "Infinite Jump", function(s) Settings.Combo.InfiniteJump = s end)
CreateToggleItem(ComboScroll, "Jump Power Boost", function(s) Settings.Combo.JumpPowerBoost = s; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = s and (50 * Settings.Combo.JumpPowerMultiplier) or 50 end end)
CreateInputItem(ComboScroll, "Jump Multiplier:", "2", function(val) Settings.Combo.JumpPowerMultiplier = val; if Settings.Combo.JumpPowerBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = 50 * val end end)
CreateToggleItem(ComboScroll, "God Mode", function(s) Settings.Combo.GodMode = s end)
CreateToggleItem(ComboScroll, "Infinite Ammo", function(s) Settings.Combo.InfAmmo = s end)

-- Transmission & Farm
CreateTransmissionButtons(TransmissionScroll)
CreateFarmButtons(FarmScroll)

-- ==========================================
-- 14. المنطق البرمجي (Aimbot, ESP, Combo)
-- ==========================================
local function GetBestVisibleTarget()
    local bestPart = nil; local shortestDist = Settings.Aimbot.FOV_Radius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and not Settings.Friends[p.UserId] then
            for _, partName in ipairs(TargetPartsPriority) do
                local part = p.Character:FindFirstChild(partName)
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                        if dist <= shortestDist then
                            if Settings.Aimbot.WallBang then
                                shortestDist = dist; bestPart = part; break
                            else
                                local rayResult = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
                                if rayResult then
                                    shortestDist = dist; bestPart = part; break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

local triggerTick = 0
RunService:BindToRenderStep("HasanAimbotCore", Enum.RenderPriority.Camera.Value + 1, function()
    local targetPart = GetBestVisibleTarget()
    if Settings.Aimbot.Enabled and targetPart then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    end
    
    if Settings.Aimbot.TriggerBot and targetPart then
        triggerTick = triggerTick + 1
        if triggerTick % 10 == 0 then
            VirtualUser:ClickButton1(Vector2.new())
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not Settings.Friends[p.UserId] then
            local hrp = p.Character.HumanoidRootPart
            if Settings.Aimbot.HitboxExpander then
                hrp.Size = Vector3.new(Settings.Aimbot.HitboxSize, Settings.Aimbot.HitboxSize, Settings.Aimbot.HitboxSize)
                hrp.Transparency = 0.8
                hrp.BrickColor = BrickColor.new("Bright blue")
                hrp.Material = Enum.Material.ForceField
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
            end
        end
    end
end)

-- ESP System
ESP_Objects = {}
RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not Settings.Friends[p.UserId] then
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                if not ESP_Objects[p] then
                    ESP_Objects[p] = {
                        Box = Instance.new("Frame"),
                        HealthBG = Instance.new("Frame"),
                        HealthBar = Instance.new("Frame"),
                        Tracer = Instance.new("Frame"),
                        NameTag = Instance.new("TextLabel"),
                        Highlight = Instance.new("Highlight")
                    }
                    
                    ESP_Objects[p].Box.BackgroundTransparency = 1
                    ESP_Objects[p].Box.BorderColor3 = Color3.fromRGB(255, 50, 50)
                    ESP_Objects[p].Box.BorderSizePixel = 2
                    ESP_Objects[p].Box.Parent = ESPFolder
                    
                    ESP_Objects[p].HealthBG.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    ESP_Objects[p].HealthBG.BorderSizePixel = 0
                    ESP_Objects[p].HealthBG.Parent = ESPFolder
                    
                    ESP_Objects[p].HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                    ESP_Objects[p].HealthBar.BorderSizePixel = 0
                    ESP_Objects[p].HealthBar.Parent = ESP_Objects[p].HealthBG
                    
                    ESP_Objects[p].Tracer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    ESP_Objects[p].Tracer.BorderSizePixel = 0
                    ESP_Objects[p].Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
                    ESP_Objects[p].Tracer.Parent = ESPFolder
                    
                    ESP_Objects[p].NameTag.BackgroundTransparency = 1
                    ESP_Objects[p].NameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ESP_Objects[p].NameTag.Font = Enum.Font.GothamBold
                    ESP_Objects[p].NameTag.TextSize = 12
                    ESP_Objects[p].NameTag.Parent = ESPFolder
                    
                    ESP_Objects[p].Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    ESP_Objects[p].Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    ESP_Objects[p].Highlight.Parent = ESPFolder
                end
                
                local objs = ESP_Objects[p]
                local isValid = false
                
                if Settings.ESP.Chams then
                    objs.Highlight.Adornee = char
                    objs.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                else
                    objs.Highlight.Adornee = nil
                end
                
                if Settings.ESP.Enabled then
                    local topPos = char.Head.Position + Vector3.new(0, 1, 0)
                    local bottomPos = char.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
                    local top2D, onScreen1 = Camera:WorldToViewportPoint(topPos)
                    local bottom2D, onScreen2 = Camera:WorldToViewportPoint(bottomPos)
                    
                    if onScreen1 or onScreen2 then
                        isValid = true
                        local height = math.abs(bottom2D.Y - top2D.Y)
                        local width = height / 2
                        
                        objs.Box.Size = UDim2.new(0, width, 0, height)
                        objs.Box.Position = UDim2.new(0, top2D.X - width/2, 0, top2D.Y)
                        
                        local hpPct = char.Humanoid.Health / char.Humanoid.MaxHealth
                        objs.HealthBG.Size = UDim2.new(0, 3, 0, height)
                        objs.HealthBG.Position = UDim2.new(0, (top2D.X - width/2) - 6, 0, top2D.Y)
                        objs.HealthBar.Size = UDim2.new(1, 0, hpPct, 0)
                        objs.HealthBar.Position = UDim2.new(0, 0, 1 - hpPct, 0)
                        objs.HealthBar.BackgroundColor3 = Color3.fromRGB(255 - (hpPct*255), hpPct*255, 50)
                        
                        local startPos = Vector2.new(Camera.ViewportSize.X / 2, 0)
                        local endPos = Vector2.new(top2D.X, top2D.Y)
                        local dist = (endPos - startPos).Magnitude
                        objs.Tracer.Size = UDim2.new(0, dist, 0, 1)
                        objs.Tracer.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
                        objs.Tracer.Rotation = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))
                        
                        if Settings.ESP.ShowNames then
                            objs.NameTag.Visible = true
                            objs.NameTag.Text = p.Name .. " [" .. math.floor((Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude) .. "m]"
                            objs.NameTag.Position = UDim2.new(0, top2D.X - 50, 0, top2D.Y - 20)
                            objs.NameTag.Size = UDim2.new(0, 100, 0, 20)
                        else
                            objs.NameTag.Visible = false
                        end
                    end
                end
                
                objs.Box.Visible = isValid
                objs.HealthBG.Visible = isValid
                objs.Tracer.Visible = isValid
                if not isValid then objs.NameTag.Visible = false end
            else
                if ESP_Objects[p] then
                    ESP_Objects[p].Box.Visible = false
                    ESP_Objects[p].HealthBG.Visible = false
                    ESP_Objects[p].Tracer.Visible = false
                    ESP_Objects[p].NameTag.Visible = false
                    ESP_Objects[p].Highlight.Adornee = nil
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESP_Objects[p] then
        for _, v in pairs(ESP_Objects[p]) do v:Destroy() end
        ESP_Objects[p] = nil
    end
end)

-- زر الانتقال العائم
FloatingTpBtn.MouseButton1Click:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local nearest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local d = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist, nearest = d, p end
        end
    end
    if nearest then
        myRoot.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        ShowNotification("🎯 Teleported to nearest player", 2)
    end
end)

-- Combo Logic
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    if Settings.Combo.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Settings.Combo.SpeedBoost then hum.WalkSpeed = 16 * Settings.Combo.SpeedMultiplier end
        if Settings.Combo.GodMode and hum.Health > 0 and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        if Settings.Combo.JumpPowerBoost then hum.JumpPower = 50 * Settings.Combo.JumpPowerMultiplier end
    end
    
    if Settings.Combo.InfAmmo then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    local vName = string.lower(v.Name)
                    if string.find(vName, "ammo") or string.find(vName, "clip") or string.find(vName, "mag") then v.Value = 999 end
                    if string.find(vName, "reload") or string.find(vName, "cooldown") then v.Value = 0 end
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.Combo.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ==========================================
-- 15. عرض رسالة الترحيب عند التحميل
-- ==========================================
task.wait(3)
ShowNotification("🚀 Hasan Hub v2.0 Loaded Successfully", 3)
