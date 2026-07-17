--[[
    LunarScripts Hub v9
    Key → Loader → Hub windows
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Junkie
local ok, j = pcall(function() return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
if ok and j then Junkie = j end
if Junkie then
    Junkie.service = "LunarScripts"
    Junkie.identifier = "1158259"
    Junkie.provider = "LunarScripts"
end

local LocalPlayer = Players.LocalPlayer
local LoaderGui = nil
local OpenHubs = {}
local Connections = {}

local C = {
    bg = Color3.fromRGB(14, 14, 20),
    bgLight = Color3.fromRGB(20, 20, 28),
    bgCard = Color3.fromRGB(26, 26, 36),
    accent = Color3.fromRGB(110, 60, 220),
    accentDark = Color3.fromRGB(70, 35, 150),
    accentGlow = Color3.fromRGB(140, 80, 255),
    green = Color3.fromRGB(60, 200, 120),
    red = Color3.fromRGB(220, 60, 60),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(140, 140, 165),
    textMuted = Color3.fromRGB(90, 90, 110),
    sep = Color3.fromRGB(35, 35, 50),
}

local function CleanAll()
    for _, g in pairs(OpenHubs) do pcall(function() g:Destroy() end) end
    OpenHubs = {}
    for _, c in pairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
end

local function Clip(text)
    if setclipboard then setclipboard(text)
    elseif toclipboard then toclipboard(text) end
end

local function Notify(t, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = t or "LunarScripts",
            Text = text or "",
            Duration = dur or 3
        })
    end)
end

local function Tween(obj, props, t)
    local info = TweenInfo.new(t or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function Drag(frame, handle)
    local c, d, s, f
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; s = i.Position; f = frame.Position
            if c then c:Disconnect() end
            c = UserInputService.InputChanged:Connect(function(i2)
                if d and (i2.UserInputType == Enum.UserInputType.MouseMovement or i2.UserInputType == Enum.UserInputType.Touch) then
                    frame.Position = UDim2.new(f.X.Scale, f.X.Offset + (i2.Position.X - s.X), f.Y.Scale, f.Y.Offset + (i2.Position.Y - s.Y))
                end
            end)
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = false; if c then c:Disconnect() c = nil end
        end
    end)
end

local function MakeWindow(sub, w, h, opts)
    opts = opts or {}
    local showProfile = opts.showProfile ~= false
    local noClose = opts.noClose or false
    local minimizeLetter = opts.minimizeLetter

    local gui = Instance.new("ScreenGui")
    gui.Name = "LunarScripts"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game.CoreGui

    local Main = Instance.new("Frame")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Size = UDim2.new(0, w, 0, h)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = C.bg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.ZIndex = 1
    Main.Parent = gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local gradStroke = Instance.new("UIStroke", Main)
    gradStroke.Color = C.accent
    gradStroke.Thickness = 1
    gradStroke.Transparency = 0.6

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, showProfile and 52 or 38)
    TopBar.BackgroundColor3 = C.bgLight
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 2
    TopBar.Parent = Main
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

    local BottomCover = Instance.new("Frame")
    BottomCover.Size = UDim2.new(1, 0, 0, 12)
    BottomCover.Position = UDim2.new(0, 0, 1, -12)
    BottomCover.BackgroundColor3 = C.bgLight
    BottomCover.BorderSizePixel = 0
    BottomCover.ZIndex = 2
    BottomCover.Parent = TopBar

    if showProfile then
        local PFP = Instance.new("ImageLabel")
        PFP.Size = UDim2.new(0, 30, 0, 30)
        PFP.Position = UDim2.new(0, 14, 0.5, -15)
        PFP.BackgroundColor3 = C.bgCard
        PFP.BorderSizePixel = 0
        PFP.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png"
        PFP.ZIndex = 3
        PFP.Parent = TopBar
        Instance.new("UICorner", PFP).CornerRadius = UDim.new(1, 0)
        local pfpStroke = Instance.new("UIStroke", PFP)
        pfpStroke.Color = C.accent
        pfpStroke.Thickness = 1.5
        pfpStroke.Transparency = 0.4

        local UN = Instance.new("TextLabel")
        UN.Size = UDim2.new(1, -90, 0, 16)
        UN.Position = UDim2.new(0, 52, 0, 8)
        UN.BackgroundTransparency = 1
        UN.Text = "@" .. LocalPlayer.Name
        UN.TextColor3 = C.text
        UN.TextSize = 13
        UN.Font = Enum.Font.GothamBold
        UN.TextXAlignment = Enum.TextXAlignment.Left
        UN.ZIndex = 3
        UN.Parent = TopBar

        local ST = Instance.new("TextLabel")
        ST.Size = UDim2.new(1, -90, 0, 14)
        ST.Position = UDim2.new(0, 52, 0, 28)
        ST.BackgroundTransparency = 1
        ST.Text = sub
        ST.TextColor3 = C.textDim
        ST.TextSize = 10
        ST.Font = Enum.Font.Gotham
        ST.TextXAlignment = Enum.TextXAlignment.Left
        ST.ZIndex = 3
        ST.Parent = TopBar
    else
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -80, 0, 38)
        TitleLabel.Position = UDim2.new(0, 14, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = sub
        TitleLabel.TextColor3 = C.text
        TitleLabel.TextSize = 14
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.ZIndex = 3
        TitleLabel.Parent = TopBar
    end

    if minimizeLetter then
        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 26, 0, 26)
        MinBtn.Position = UDim2.new(1, -64, 0.5, -13)
        MinBtn.BackgroundColor3 = C.bgCard
        MinBtn.BorderSizePixel = 0
        MinBtn.Text = "-"
        MinBtn.TextColor3 = C.textDim
        MinBtn.TextSize = 16
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.ZIndex = 4
        MinBtn.Parent = TopBar
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

        MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundColor3 = C.accentDark}, 0.1) end)
        MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundColor3 = C.bgCard}, 0.1) end)

        local MiniFrame = Instance.new("TextButton")
        MiniFrame.Size = UDim2.new(0, 48, 0, 48)
        MiniFrame.Position = Main.Position
        MiniFrame.AnchorPoint = Main.AnchorPoint
        MiniFrame.BackgroundColor3 = C.bgCard
        MiniFrame.BorderSizePixel = 0
        MiniFrame.Text = minimizeLetter
        MiniFrame.TextColor3 = C.accentGlow
        MiniFrame.TextSize = 20
        MiniFrame.Font = Enum.Font.GothamBold
        MiniFrame.ZIndex = 10
        MiniFrame.Visible = false
        MiniFrame.Parent = gui
        Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(0, 14)
        local ms = Instance.new("UIStroke", MiniFrame)
        ms.Color = C.accent
        ms.Thickness = 1.5
        ms.Transparency = 0.4

        local miniDragMoved = false
        local miniDragConn
        MiniFrame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                miniDragMoved = false
                local startPos = i.Position
                local startFramePos = MiniFrame.Position
                miniDragConn = UserInputService.InputChanged:Connect(function(i2)
                    if i2.UserInputType == Enum.UserInputType.MouseMovement or i2.UserInputType == Enum.UserInputType.Touch then
                        local dx = i2.Position.X - startPos.X
                        local dy = i2.Position.Y - startPos.Y
                        if math.abs(dx) > 3 or math.abs(dy) > 3 then miniDragMoved = true end
                        MiniFrame.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + dx, startFramePos.Y.Scale, startFramePos.Y.Offset + dy)
                    end
                end)
            end
        end)
        MiniFrame.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                if miniDragConn then miniDragConn:Disconnect() miniDragConn = nil end
            end
        end)

        local minimized = false
        MinBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                MiniFrame.Position = Main.Position
                Main.Visible = false
                MiniFrame.Visible = true
            else
                Main.Position = MiniFrame.Position
                Main.Visible = true
                MiniFrame.Visible = false
            end
        end)

        MiniFrame.MouseButton1Click:Connect(function()
            if miniDragMoved then return end
            minimized = false
            Main.Position = MiniFrame.Position
            Main.Visible = true
            MiniFrame.Visible = false
        end)
    end

    local XB = Instance.new("TextButton")
    XB.Size = UDim2.new(0, 26, 0, 26)
    XB.Position = UDim2.new(1, -34, 0.5, -13)
    XB.BackgroundColor3 = C.red
    XB.BorderSizePixel = 0
    XB.Text = "X"
    XB.TextColor3 = Color3.new(1, 1, 1)
    XB.TextSize = 11
    XB.Font = Enum.Font.GothamBold
    XB.ZIndex = 4
    XB.Parent = TopBar
    Instance.new("UICorner", XB).CornerRadius = UDim.new(0, 6)

    XB.MouseEnter:Connect(function() Tween(XB, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.1) end)
    XB.MouseLeave:Connect(function() Tween(XB, {BackgroundColor3 = C.red}, 0.1) end)

    if noClose then
        XB.MouseButton1Click:Connect(function()
            CleanAll()
            gui:Destroy()
        end)
    end

    Drag(Main, TopBar)
    return gui, Main
end

------------------------------------------------------------
-- FORWARD DECLARATIONS
------------------------------------------------------------
local ShowKeyWindow, ShowLoaderWindow

------------------------------------------------------------
-- UNIVERSAL HUB
------------------------------------------------------------
local UniActive = { fly = false, noclip = false, infjump = false, walkspeed = false }
local FlySpeed = 80
local DesiredWalkSpeed = 16
local DesiredJumpPower = 50
local WalkSpeedLoopConn
local FlyConn, NoclipConn, InfJumpConn

local function StartFly()
    if UniActive.fly then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    UniActive.fly = true
    hum.PlatformStand = true
    hum.AutoRotate = false

    FlyConn = RunService.Heartbeat:Connect(function(dt)
        if not UniActive.fly then
            pcall(function()
                local c = LocalPlayer.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then
                        h.PlatformStand = false
                        h.AutoRotate = true
                    end
                end
            end)
            if FlyConn then FlyConn:Disconnect() FlyConn = nil end
            return
        end

        local char = LocalPlayer.Character
        if not char then UniActive.fly = false return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then UniActive.fly = false return end

        local cam = workspace.CurrentCamera
        local cf = cam.CFrame
        local dir = Vector3.new(0, 0, 0)

        if UserInputService:GetKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:GetKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:GetKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UserInputService:GetKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:GetKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:GetKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        local move = Vector3.new(0, 0, 0)
        if dir.Magnitude > 0 then
            move = dir.Unit * FlySpeed
        end

        hrp.CFrame = CFrame.new(hrp.Position + move * dt, hrp.Position + move * dt + cf.LookVector)
    end)
end

local function StopFly()
    UniActive.fly = false
end

local function ToggleNoclip()
    UniActive.noclip = not UniActive.noclip
    if UniActive.noclip then
        NoclipConn = RunService.Stepped:Connect(function()
            if not UniActive.noclip then
                if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
                return
            end
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end

local function ToggleInfJump()
    UniActive.infjump = not UniActive.infjump
    if UniActive.infjump then
        InfJumpConn = UserInputService.JumpRequest:Connect(function()
            if not UniActive.infjump then
                if InfJumpConn then InfJumpConn:Disconnect() InfJumpConn = nil end
                return
            end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end

local function ToggleWalkSpeed()
    UniActive.walkspeed = not UniActive.walkspeed
    if UniActive.walkspeed then
        if WalkSpeedLoopConn then return end
        WalkSpeedLoopConn = task.spawn(function()
            while UniActive.walkspeed do
                pcall(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = DesiredWalkSpeed end
                end)
                task.wait(0.5)
            end
            WalkSpeedLoopConn = nil
        end)
    end
end

------------------------------------------------------------
-- UI HELPERS
------------------------------------------------------------
local function MakeToggle(Panel, name, order, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 36)
    B.BackgroundColor3 = C.bgCard
    B.BorderSizePixel = 0
    B.Text = ""
    B.LayoutOrder = order
    B.ZIndex = 4
    B.Parent = Panel
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -44, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = C.textDim
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 5
    Label.Parent = B

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(0, 36, 0, 20)
    Track.Position = UDim2.new(1, -48, 0.5, -10)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Track.BorderSizePixel = 0
    Track.ZIndex = 5
    Track.Parent = B
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = C.textMuted
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 6
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local on = false
    B.MouseButton1Click:Connect(function()
        on = not on
        callback(on)
        if on then
            Tween(Track, {BackgroundColor3 = C.accentDark}, 0.15)
            Tween(Knob, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = C.accentGlow}, 0.15)
            Tween(Label, {TextColor3 = C.text}, 0.15)
        else
            Tween(Track, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.15)
            Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = C.textMuted}, 0.15)
            Tween(Label, {TextColor3 = C.textDim}, 0.15)
        end
    end)

    B.MouseEnter:Connect(function() Tween(B, {BackgroundColor3 = Color3.fromRGB(32, 32, 44)}, 0.1) end)
    B.MouseLeave:Connect(function() Tween(B, {BackgroundColor3 = C.bgCard}, 0.1) end)
end

local function MakeSlider(Panel, name, order, min, max, def, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 40)
    Holder.BackgroundColor3 = C.bgCard
    Holder.BorderSizePixel = 0
    Holder.LayoutOrder = order
    Holder.ZIndex = 4
    Holder.Parent = Panel
    Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -12, 0, 16)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = C.textDim
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 5
    Label.Parent = Holder

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0, 40, 0, 16)
    ValLabel.Position = UDim2.new(1, -52, 0, 4)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(def)
    ValLabel.TextColor3 = C.accentGlow
    ValLabel.TextSize = 12
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.ZIndex = 5
    ValLabel.Parent = Holder

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 4)
    Bar.Position = UDim2.new(0, 12, 0, 28)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 5
    Bar.Parent = Holder
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = C.accent
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 6
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new((def - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 7
    Knob.Parent = Bar
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local val = def

    local function update(input)
        local pct = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * pct)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Knob.Position = UDim2.new(pct, -7, 0.5, -7)
        ValLabel.Text = tostring(val)
        callback(val)
    end

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            update(input)
            dragging = true
        end
    end)
end

local function MakeLabel(Panel, name, order)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 0, 24)
    L.BackgroundTransparency = 1
    L.Text = "   " .. name
    L.TextColor3 = C.textMuted
    L.TextSize = 11
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.LayoutOrder = order
    L.ZIndex = 4
    L.Parent = Panel
end

------------------------------------------------------------
-- EXPOSE TO MODULES
------------------------------------------------------------
getgenv().MakeWindow = MakeWindow
getgenv().Drag = Drag
getgenv().MakeToggle = MakeToggle
getgenv().MakeSlider = MakeSlider
getgenv().MakeLabel = MakeLabel

------------------------------------------------------------
-- EXTERNAL MODULES
------------------------------------------------------------
local Modules = {}

local function OpenModule(mod)
    mod.loader()
end

------------------------------------------------------------
-- UNIVERSAL HUB
------------------------------------------------------------
local function OpenUniversalHub()
    local gui, Main = MakeWindow("Universal Hub", 320, 380, { showProfile = false, minimizeLetter = "U" })
    OpenHubs["universal"] = gui

    local Panel = Instance.new("ScrollingFrame")
    Panel.Size = UDim2.new(1, -12, 1, -48)
    Panel.Position = UDim2.new(0, 6, 0, 42)
    Panel.BackgroundTransparency = 1
    Panel.BorderSizePixel = 0
    Panel.ScrollBarThickness = 2
    Panel.ScrollBarImageColor3 = C.accent
    Panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    Panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Panel.ZIndex = 3
    Panel.Parent = Main
    local panelLayout = Instance.new("UIListLayout", Panel)
    panelLayout.Padding = UDim.new(0, 4)
    panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", Panel).PaddingTop = UDim.new(0, 4)

    MakeToggle(Panel, "Fly", 1, function(v) if v then StartFly() else StopFly() end end)
    MakeSlider(Panel, "Fly Speed", 2, 20, 200, 80, function(v) FlySpeed = v end)
    MakeLabel(Panel, "Movement", 3)
    MakeToggle(Panel, "WalkSpeed", 4, function() ToggleWalkSpeed() end)
    MakeSlider(Panel, "WalkSpeed Value", 5, 16, 200, 16, function(v)
        DesiredWalkSpeed = v
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and UniActive.walkspeed then hum.WalkSpeed = v end
        end)
    end)
    MakeSlider(Panel, "JumpPower", 6, 50, 300, 50, function(v)
        DesiredJumpPower = v
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end)
    end)
    MakeLabel(Panel, "Player", 7)
    MakeToggle(Panel, "NoClip", 8, function() ToggleNoclip() end)
    MakeToggle(Panel, "Infinite Jump", 9, function() ToggleInfJump() end)
end

------------------------------------------------------------
-- WINDOW 1: KEY
------------------------------------------------------------
ShowKeyWindow = function()
    local gui, Main = MakeWindow("Redeem your key", 380, 240, { showProfile = true })

    local C2 = Instance.new("Frame")
    C2.Size = UDim2.new(1, -24, 1, -64)
    C2.Position = UDim2.new(0, 12, 0, 56)
    C2.BackgroundTransparency = 1
    C2.Parent = Main

    local TL = Instance.new("TextLabel")
    TL.Size = UDim2.new(1, 0, 0, 20)
    TL.BackgroundTransparency = 1
    TL.Text = "KEY SYSTEM"
    TL.TextColor3 = C.accentGlow
    TL.TextSize = 12
    TL.Font = Enum.Font.GothamBold
    TL.TextXAlignment = Enum.TextXAlignment.Left
    TL.ZIndex = 3
    TL.Parent = C2

    local KB = Instance.new("TextBox")
    KB.Size = UDim2.new(1, 0, 0, 38)
    KB.Position = UDim2.new(0, 0, 0, 28)
    KB.BackgroundColor3 = C.bgCard
    KB.BorderSizePixel = 0
    KB.PlaceholderText = "Paste your key here..."
    KB.PlaceholderColor3 = C.textMuted
    KB.Text = ""
    KB.TextColor3 = C.text
    KB.TextSize = 13
    KB.Font = Enum.Font.Gotham
    KB.ClearTextOnFocus = false
    KB.ZIndex = 3
    KB.Parent = C2
    Instance.new("UICorner", KB).CornerRadius = UDim.new(0, 8)
    local kbStroke = Instance.new("UIStroke", KB)
    kbStroke.Color = C.sep
    kbStroke.Thickness = 1

    local GKB = Instance.new("TextButton")
    GKB.Size = UDim2.new(0.48, 0, 0, 36)
    GKB.Position = UDim2.new(0, 0, 0, 76)
    GKB.BackgroundColor3 = C.accent
    GKB.BorderSizePixel = 0
    GKB.Text = "Get Key"
    GKB.TextColor3 = Color3.new(1, 1, 1)
    GKB.TextSize = 13
    GKB.Font = Enum.Font.GothamBold
    GKB.ZIndex = 3
    GKB.Parent = C2
    Instance.new("UICorner", GKB).CornerRadius = UDim.new(0, 8)
    GKB.MouseEnter:Connect(function() Tween(GKB, {BackgroundColor3 = C.accentGlow}, 0.1) end)
    GKB.MouseLeave:Connect(function() Tween(GKB, {BackgroundColor3 = C.accent}, 0.1) end)

    local RB = Instance.new("TextButton")
    RB.Size = UDim2.new(0.48, 0, 0, 36)
    RB.Position = UDim2.new(0.52, 0, 0, 76)
    RB.BackgroundColor3 = C.green
    RB.BorderSizePixel = 0
    RB.Text = "Redeem"
    RB.TextColor3 = Color3.new(1, 1, 1)
    RB.TextSize = 13
    RB.Font = Enum.Font.GothamBold
    RB.ZIndex = 3
    RB.Parent = C2
    Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 8)
    RB.MouseEnter:Connect(function() Tween(RB, {BackgroundColor3 = Color3.fromRGB(80, 220, 140)}, 0.1) end)
    RB.MouseLeave:Connect(function() Tween(RB, {BackgroundColor3 = C.green}, 0.1) end)

    local ST = Instance.new("TextLabel")
    ST.Size = UDim2.new(1, 0, 0, 16)
    ST.Position = UDim2.new(0, 0, 0, 120)
    ST.BackgroundTransparency = 1
    ST.Text = ""
    ST.TextColor3 = C.textDim
    ST.TextSize = 11
    ST.Font = Enum.Font.Gotham
    ST.TextXAlignment = Enum.TextXAlignment.Left
    ST.ZIndex = 3
    ST.Parent = C2

    GKB.MouseButton1Click:Connect(function()
        local link = Junkie.get_key_link()
        if link then
            Clip(link)
            ST.Text = "Link copied!"
            ST.TextColor3 = C.green
            Notify("Copied", "Key link copied")
        else
            ST.Text = "Failed to get link"
            ST.TextColor3 = C.red
        end
    end)

    local function DoRedeem()
        local key = KB.Text:gsub("%s+", "")
        if key == "" then
            ST.Text = "Enter a key first"
            ST.TextColor3 = C.red
            return
        end
        ST.Text = "Validating..."
        ST.TextColor3 = C.textDim
        RB.Text = "..."

        local result = Junkie.check_key(key)
        if result and result.valid and result.message ~= "KEYLESS" then
            getgenv().SCRIPT_KEY = key
            ST.Text = "Key valid!"
            ST.TextColor3 = C.green
            Notify("Unlocked", "Key accepted!")
            task.wait(0.5)
            gui:Destroy()
            ShowLoaderWindow()
        elseif result and result.valid and result.message == "KEYLESS" then
            getgenv().SCRIPT_KEY = "KEYLESS"
            ST.Text = "No key required!"
            ST.TextColor3 = C.green
            Notify("Unlocked", "Keyless mode")
            task.wait(0.5)
            gui:Destroy()
            ShowLoaderWindow()
        else
            ST.Text = "Invalid key"
            ST.TextColor3 = C.red
            RB.Text = "Redeem"
            RB.BackgroundColor3 = C.green
            Notify("Invalid", "Key rejected")
        end
    end

    RB.MouseButton1Click:Connect(DoRedeem)
    KB.FocusLost:Connect(function(ep) if ep then DoRedeem() end end)
end

------------------------------------------------------------
-- WINDOW 2: LOADER
------------------------------------------------------------
ShowLoaderWindow = function()
    CleanAll()
    local gui, Main = MakeWindow("Select a hub", 340, 220, { showProfile = true, noClose = true, minimizeLetter = "H" })
    LoaderGui = gui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -16, 0, 20)
    Title.Position = UDim2.new(0, 14, 0, 58)
    Title.BackgroundTransparency = 1
    Title.Text = "HUBS"
    Title.TextColor3 = C.accentGlow
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3
    Title.Parent = Main

    local HubList = Instance.new("Frame")
    HubList.Size = UDim2.new(1, -24, 1, -88)
    HubList.Position = UDim2.new(0, 12, 0, 82)
    HubList.BackgroundTransparency = 1
    HubList.ZIndex = 3
    HubList.Parent = Main
    local hubLayout = Instance.new("UIListLayout", HubList)
    hubLayout.Padding = UDim.new(0, 6)
    hubLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local HubData = {
        { name = "Universal Hub", id = "universal", open = OpenUniversalHub },
    }

    for _, mod in ipairs(Modules) do
        table.insert(HubData, { name = mod.name, id = mod.id, open = function() OpenModule(mod) end })
    end

    for i, hd in ipairs(HubData) do
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(1, 0, 0, 40)
        B.BackgroundColor3 = C.bgCard
        B.BorderSizePixel = 0
        B.Text = ""
        B.LayoutOrder = i
        B.ZIndex = 4
        B.Parent = HubList
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)

        local HubLabel = Instance.new("TextLabel")
        HubLabel.Size = UDim2.new(1, -40, 1, 0)
        HubLabel.Position = UDim2.new(0, 14, 0, 0)
        HubLabel.BackgroundTransparency = 1
        HubLabel.Text = hd.name
        HubLabel.TextColor3 = C.textDim
        HubLabel.TextSize = 13
        HubLabel.Font = Enum.Font.GothamMedium
        HubLabel.TextXAlignment = Enum.TextXAlignment.Left
        HubLabel.ZIndex = 5
        HubLabel.Parent = B

        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 0, 20)
        Arrow.Position = UDim2.new(1, -32, 0.5, -10)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "+"
        Arrow.TextColor3 = C.accent
        Arrow.TextSize = 16
        Arrow.Font = Enum.Font.GothamBold
        Arrow.ZIndex = 5
        Arrow.Parent = B

        local active = false

        B.MouseButton1Click:Connect(function()
            active = not active
            if active then
                Tween(B, {BackgroundColor3 = C.accentDark}, 0.1)
                Tween(HubLabel, {TextColor3 = C.text}, 0.1)
                Arrow.Text = "-"
                hd.open()
            else
                Tween(B, {BackgroundColor3 = C.bgCard}, 0.1)
                Tween(HubLabel, {TextColor3 = C.textDim}, 0.1)
                Arrow.Text = "+"
                if OpenHubs[hd.id] then
                    pcall(function() OpenHubs[hd.id]:Destroy() end)
                    OpenHubs[hd.id] = nil
                end
            end
        end)

        B.MouseEnter:Connect(function()
            if not active then Tween(B, {BackgroundColor3 = Color3.fromRGB(32, 32, 44)}, 0.1) end
        end)
        B.MouseLeave:Connect(function()
            if not active then Tween(B, {BackgroundColor3 = C.bgCard}, 0.1) end
        end)
    end
end

------------------------------------------------------------
-- START
------------------------------------------------------------
local savedKey = getgenv().SCRIPT_KEY
if savedKey and savedKey ~= "" and savedKey ~= "KEYLESS" then
    local ok, result = pcall(function() return Junkie.check_key(savedKey) end)
    if ok and result and result.valid and result.message ~= "KEYLESS" then
        ShowLoaderWindow()
        return
    end
end

getgenv().SCRIPT_KEY = nil
ShowKeyWindow()
print("[LunarScripts] Hub v9 loaded")
