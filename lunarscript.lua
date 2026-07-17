--[[
    LunarScripts Hub v8
    Key → Loader → Hub windows (toggle on/off)
    Uses jnkie.com SDK
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "LunarScripts"
Junkie.identifier = "1158259"
Junkie.provider = "LunarScripts"

local LocalPlayer = Players.LocalPlayer
local LoaderGui = nil
local OpenHubs = {}
local Connections = {}

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
            d = false if c then c:Disconnect() c = nil end
        end
    end)
end

local function MakeWindow(sub, w, h, opts)
    opts = opts or {}
    local showProfile = opts.showProfile ~= false
    local noClose = opts.noClose or false
    local minimizeLetter = opts.minimizeLetter or nil

    local gui = Instance.new("ScreenGui")
    gui.Name = "LunarScripts"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game.CoreGui

    local Main = Instance.new("Frame")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Size = UDim2.new(0, w, 0, h)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.ZIndex = 1
    Main.Parent = gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = Color3.fromRGB(90, 50, 170)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, showProfile and 50 or 36)
    TopBar.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 2
    TopBar.Parent = Main
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

    local Sep = Instance.new("Frame")
    Sep.Size = UDim2.new(1, 0, 0, 1)
    Sep.Position = UDim2.new(0, 0, 1, -1)
    Sep.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Sep.BorderSizePixel = 0
    Sep.ZIndex = 3
    Sep.Parent = TopBar

    local nameX = 12
    if showProfile then
        local PFP = Instance.new("ImageLabel")
        PFP.Size = UDim2.new(0, 32, 0, 32)
        PFP.Position = UDim2.new(0, 12, 0.5, -16)
        PFP.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        PFP.BorderSizePixel = 0
        PFP.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png"
        PFP.ZIndex = 3
        PFP.Parent = TopBar
        Instance.new("UICorner", PFP).CornerRadius = UDim.new(1, 0)
        local ps = Instance.new("UIStroke", PFP)
        ps.Color = Color3.fromRGB(90, 50, 170)
        ps.Thickness = 1.5

        local UN = Instance.new("TextLabel")
        UN.Size = UDim2.new(1, -70, 0, 18)
        UN.Position = UDim2.new(0, 52, 0, 6)
        UN.BackgroundTransparency = 1
        UN.Text = "@" .. LocalPlayer.Name
        UN.TextColor3 = Color3.fromRGB(220, 220, 230)
        UN.TextSize = 13
        UN.Font = Enum.Font.GothamBold
        UN.TextXAlignment = Enum.TextXAlignment.Left
        UN.ZIndex = 3
        UN.Parent = TopBar

        local ST = Instance.new("TextLabel")
        ST.Size = UDim2.new(1, -70, 0, 14)
        ST.Position = UDim2.new(0, 52, 0, 24)
        ST.BackgroundTransparency = 1
        ST.Text = sub
        ST.TextColor3 = Color3.fromRGB(110, 110, 135)
        ST.TextSize = 10
        ST.Font = Enum.Font.Gotham
        ST.TextXAlignment = Enum.TextXAlignment.Left
        ST.ZIndex = 3
        ST.Parent = TopBar
        nameX = 52
    else
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -80, 0, 36)
        TitleLabel.Position = UDim2.new(0, 12, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = sub
        TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
        TitleLabel.TextSize = 13
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.ZIndex = 3
        TitleLabel.Parent = TopBar
    end

    if minimizeLetter then
        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 28, 0, 28)
        MinBtn.Position = UDim2.new(1, -66, 0, (TopBar.Size.Y.Offset - 28) / 2)
        MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        MinBtn.BorderSizePixel = 0
        MinBtn.Text = "-"
        MinBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
        MinBtn.TextSize = 14
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.ZIndex = 4
        MinBtn.Parent = TopBar
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

        local MiniFrame = Instance.new("TextButton")
        MiniFrame.Size = UDim2.new(0, 44, 0, 44)
        MiniFrame.Position = Main.Position
        MiniFrame.AnchorPoint = Main.AnchorPoint
        MiniFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 60)
        MiniFrame.BorderSizePixel = 0
        MiniFrame.Text = minimizeLetter
        MiniFrame.TextColor3 = Color3.fromRGB(220, 200, 255)
        MiniFrame.TextSize = 18
        MiniFrame.Font = Enum.Font.GothamBold
        MiniFrame.ZIndex = 10
        MiniFrame.Visible = false
        MiniFrame.Parent = gui
        Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(0, 10)
        local ms = Instance.new("UIStroke", MiniFrame)
        ms.Color = Color3.fromRGB(90, 50, 170)
        ms.Thickness = 1.5
        ms.Transparency = 0.3

        local function DragWithFlag(frame, handle)
            local c, d, s, f, moved
            handle.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    d = true; moved = false; s = i.Position; f = frame.Position
                    if c then c:Disconnect() end
                    c = UserInputService.InputChanged:Connect(function(i2)
                        if d and (i2.UserInputType == Enum.UserInputType.MouseMovement or i2.UserInputType == Enum.UserInputType.Touch) then
                            local dx = i2.Position.X - s.X
                            local dy = i2.Position.Y - s.Y
                            if math.abs(dx) > 2 or math.abs(dy) > 2 then moved = true end
                            frame.Position = UDim2.new(f.X.Scale, f.X.Offset + dx, f.Y.Scale, f.Y.Offset + dy)
                        end
                    end)
                end
            end)
            handle.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    d = false; if c then c:Disconnect() c = nil end
                end
            end)
            return function() return moved end
        end

        local getMoved = DragWithFlag(MiniFrame, MiniFrame)

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
            if getMoved() then return end
            minimized = false
            Main.Position = MiniFrame.Position
            Main.Visible = true
            MiniFrame.Visible = false
        end)
    end

    local XB = Instance.new("TextButton")
    XB.Size = UDim2.new(0, 28, 0, 28)
    XB.Position = UDim2.new(1, -36, 0, (TopBar.Size.Y.Offset - 28) / 2)
    XB.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    XB.BorderSizePixel = 0
    XB.Text = "X"
    XB.TextColor3 = Color3.fromRGB(255, 255, 255)
    XB.TextSize = 12
    XB.Font = Enum.Font.GothamBold
    XB.ZIndex = 4
    XB.Parent = TopBar
    Instance.new("UICorner", XB).CornerRadius = UDim.new(0, 6)

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
local UniActive = { fly = false, noclip = false, infjump = false }
local FlySpeed = 80
local DesiredWalkSpeed = 16
local DesiredJumpPower = 50
local WalkSpeedConn
local FlyConn, NoclipConn, InfJumpConn

local function StartFly()
    if UniActive.fly then return end
    UniActive.fly = true
    local char = LocalPlayer.Character
    if not char then UniActive.fly = false return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then UniActive.fly = false return end

    local oldGrav = workspace.Gravity
    workspace.Gravity = 0
    hum.PlatformStand = true

    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.D = 500
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 1e4
    bv.Parent = hrp

    FlyConn = RunService.RenderStepped:Connect(function()
        if not UniActive.fly then
            pcall(function() bg:Destroy() end)
            pcall(function() bv:Destroy() end)
            workspace.Gravity = oldGrav
            pcall(function()
                local c = LocalPlayer.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then h.PlatformStand = false end
                end
            end)
            if FlyConn then FlyConn:Disconnect() FlyConn = nil end
            return
        end

        local char = LocalPlayer.Character
        if not char then StopFly() return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then StopFly() return end

        local cam = workspace.CurrentCamera
        local cf = cam.CFrame
        local dir = Vector3.new(0, 0, 0)

        if UserInputService:GetKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:GetKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:GetKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UserInputService:GetKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:GetKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:GetKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then
            bv.Velocity = dir.Unit * FlySpeed
        else
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cf.LookVector)
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

------------------------------------------------------------
-- UI HELPERS (shared with modules)
------------------------------------------------------------
local function MakeToggle(Panel, name, order, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -12, 0, 30)
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    B.BorderSizePixel = 0
    B.Text = "   " .. name
    B.TextColor3 = Color3.fromRGB(160, 160, 180)
    B.TextSize = 12
    B.Font = Enum.Font.Gotham
    B.TextXAlignment = Enum.TextXAlignment.Left
    B.LayoutOrder = order
    B.ZIndex = 4
    B.Parent = Panel
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 8, 0, 8)
    Dot.Position = UDim2.new(1, -20, 0.5, -4)
    Dot.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    Dot.BorderSizePixel = 0
    Dot.ZIndex = 5
    Dot.Parent = B
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local on = false
    B.MouseButton1Click:Connect(function()
        on = not on
        callback(on)
        Dot.BackgroundColor3 = on and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(70, 70, 90)
        B.TextColor3 = on and Color3.fromRGB(120, 230, 140) or Color3.fromRGB(160, 160, 180)
    end)
end

local function MakeSlider(Panel, name, order, min, max, def, callback)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -12, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = "   " .. name .. "  [" .. def .. "]"
    Label.TextColor3 = Color3.fromRGB(160, 160, 180)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.LayoutOrder = order
    Label.ZIndex = 4
    Label.Parent = Panel

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -12, 0, 6)
    Bar.Position = UDim2.new(0, 6, 0, 18)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Bar.BorderSizePixel = 0
    Bar.LayoutOrder = order + 0.1
    Bar.ZIndex = 4
    Bar.Parent = Label
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(90, 50, 170)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 5
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new((def - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 6
    Knob.Parent = Bar
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local val = def

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
            local absPos = Bar.AbsolutePosition.X
            local absSize = Bar.AbsoluteSize.X
            local pct = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            val = math.floor(min + (max - min) * pct)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            Knob.Position = UDim2.new(pct, -7, 0.5, -7)
            Label.Text = "   " .. name .. "  [" .. val .. "]"
            callback(val)
        end
    end)

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local absPos = Bar.AbsolutePosition.X
            local absSize = Bar.AbsoluteSize.X
            local pct = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            val = math.floor(min + (max - min) * pct)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            Knob.Position = UDim2.new(pct, -7, 0.5, -7)
            Label.Text = "   " .. name .. "  [" .. val .. "]"
            callback(val)
        end
    end)
end

local function MakeLabel(Panel, name, order)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -12, 0, 20)
    L.BackgroundTransparency = 1
    L.Text = "   " .. name
    L.TextColor3 = Color3.fromRGB(110, 110, 135)
    L.TextSize = 11
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.LayoutOrder = order
    L.ZIndex = 4
    L.Parent = Panel
end

------------------------------------------------------------
-- EXPOSE HELPERS TO MODULES
------------------------------------------------------------
getgenv().MakeWindow = MakeWindow
getgenv().Drag = Drag
getgenv().MakeToggle = MakeToggle
getgenv().MakeSlider = MakeSlider
getgenv().MakeLabel = MakeLabel

------------------------------------------------------------
-- EXTERNAL MODULES (add loadstrings here)
------------------------------------------------------------
local Modules = {
    -- { name = "Hub Name", id = "hubid", loader = function() loadstring(game:HttpGet("RAW_LINK_HERE"))() end },
}

local function OpenModule(mod)
    mod.loader()
end

------------------------------------------------------------
-- UNIVERSAL HUB
------------------------------------------------------------
local function OpenUniversalHub()
    local gui, Main = MakeWindow("Universal Hub", 340, 360, { showProfile = false, minimizeLetter = "U" })
    OpenHubs["universal"] = gui

    local Panel = Instance.new("ScrollingFrame")
    Panel.Size = UDim2.new(1, -16, 1, -52)
    Panel.Position = UDim2.new(0, 8, 0, 44)
    Panel.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Panel.BorderSizePixel = 0
    Panel.ScrollBarThickness = 3
    Panel.ScrollBarImageColor3 = Color3.fromRGB(90, 50, 170)
    Panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    Panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Panel.ZIndex = 3
    Panel.Parent = Main
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 8)
    local panelLayout = Instance.new("UIListLayout", Panel)
    panelLayout.Padding = UDim.new(0, 5)
    panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", Panel).PaddingTop = UDim.new(0, 6)

    MakeToggle(Panel, "Fly", 1, function(v) if v then StartFly() else StopFly() end end)
    MakeToggle(Panel, "NoClip", 2, function() ToggleNoclip() end)
    MakeToggle(Panel, "Infinite Jump", 3, function() ToggleInfJump() end)
    MakeSlider(Panel, "Fly Speed", 4, 20, 200, 80, function(v) FlySpeed = v end)
    MakeSlider(Panel, "WalkSpeed", 5, 16, 200, 16, function(v)
        DesiredWalkSpeed = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
    MakeSlider(Panel, "JumpPower", 6, 50, 300, 50, function(v)
        DesiredJumpPower = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end)

    if not WalkSpeedConn then
        WalkSpeedConn = task.spawn(function()
            while task.wait(0.01) do
                pcall(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if DesiredWalkSpeed ~= 16 then hum.WalkSpeed = DesiredWalkSpeed end
                        if DesiredJumpPower ~= 50 then hum.JumpPower = DesiredJumpPower end
                    end
                end)
            end
        end)
    end
end

------------------------------------------------------------
-- WINDOW 1: KEY
------------------------------------------------------------
ShowKeyWindow = function()
    local gui, Main = MakeWindow("Redeem your key to continue", 380, 220, { showProfile = true })

    local C = Instance.new("Frame")
    C.Size = UDim2.new(1, -24, 1, -60)
    C.Position = UDim2.new(0, 12, 0, 52)
    C.BackgroundTransparency = 1
    C.Parent = Main

    local TL = Instance.new("TextLabel")
    TL.Size = UDim2.new(1, 0, 0, 28)
    TL.BackgroundTransparency = 1
    TL.Text = "Key System"
    TL.TextColor3 = Color3.fromRGB(140, 90, 230)
    TL.TextSize = 15
    TL.Font = Enum.Font.GothamBold
    TL.TextXAlignment = Enum.TextXAlignment.Left
    TL.ZIndex = 3
    TL.Parent = C

    local KB = Instance.new("TextBox")
    KB.Size = UDim2.new(1, 0, 0, 36)
    KB.Position = UDim2.new(0, 0, 0, 34)
    KB.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    KB.BorderSizePixel = 0
    KB.PlaceholderText = "Paste your key here..."
    KB.PlaceholderColor3 = Color3.fromRGB(80, 80, 100)
    KB.Text = ""
    KB.TextColor3 = Color3.fromRGB(210, 210, 220)
    KB.TextSize = 12
    KB.Font = Enum.Font.Gotham
    KB.ClearTextOnFocus = false
    KB.ZIndex = 3
    KB.Parent = C
    Instance.new("UICorner", KB).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", KB).Color = Color3.fromRGB(45, 45, 60)

    local GKB = Instance.new("TextButton")
    GKB.Size = UDim2.new(0.48, 0, 0, 34)
    GKB.Position = UDim2.new(0, 0, 0, 78)
    GKB.BackgroundColor3 = Color3.fromRGB(90, 50, 170)
    GKB.BorderSizePixel = 0
    GKB.Text = "Get Key"
    GKB.TextColor3 = Color3.fromRGB(255, 255, 255)
    GKB.TextSize = 12
    GKB.Font = Enum.Font.GothamBold
    GKB.ZIndex = 3
    GKB.Parent = C
    Instance.new("UICorner", GKB).CornerRadius = UDim.new(0, 6)

    local RB = Instance.new("TextButton")
    RB.Size = UDim2.new(0.48, 0, 0, 34)
    RB.Position = UDim2.new(0.52, 0, 0, 78)
    RB.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
    RB.BorderSizePixel = 0
    RB.Text = "Redeem"
    RB.TextColor3 = Color3.fromRGB(255, 255, 255)
    RB.TextSize = 12
    RB.Font = Enum.Font.GothamBold
    RB.ZIndex = 3
    RB.Parent = C
    Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 6)

    local ST = Instance.new("TextLabel")
    ST.Size = UDim2.new(1, 0, 0, 16)
    ST.Position = UDim2.new(0, 0, 0, 120)
    ST.BackgroundTransparency = 1
    ST.Text = ""
    ST.TextColor3 = Color3.fromRGB(130, 130, 155)
    ST.TextSize = 10
    ST.Font = Enum.Font.Gotham
    ST.TextXAlignment = Enum.TextXAlignment.Left
    ST.ZIndex = 3
    ST.Parent = C

    GKB.MouseButton1Click:Connect(function()
        local link = Junkie.get_key_link()
        if link then
            Clip(link)
            ST.Text = "Link copied!"
            ST.TextColor3 = Color3.fromRGB(100, 200, 130)
            Notify("Copied", "Key link copied")
        else
            ST.Text = "Failed to get link"
            ST.TextColor3 = Color3.fromRGB(200, 80, 80)
        end
    end)

    local function DoRedeem()
        local key = KB.Text:gsub("%s+", "")
        if key == "" then
            ST.Text = "Enter a key first"
            ST.TextColor3 = Color3.fromRGB(200, 80, 80)
            return
        end
        ST.Text = "Validating..."
        ST.TextColor3 = Color3.fromRGB(130, 130, 155)
        RB.Text = "..."

        local result = Junkie.check_key(key)
        if result and result.valid and result.message ~= "KEYLESS" then
            getgenv().SCRIPT_KEY = key
            ST.Text = "Key valid!"
            ST.TextColor3 = Color3.fromRGB(80, 200, 120)
            Notify("Unlocked", "Key accepted!")
            task.wait(0.5)
            gui:Destroy()
            ShowLoaderWindow()
        elseif result and result.valid and result.message == "KEYLESS" then
            getgenv().SCRIPT_KEY = "KEYLESS"
            ST.Text = "No key required!"
            ST.TextColor3 = Color3.fromRGB(80, 200, 120)
            Notify("Unlocked", "Keyless mode")
            task.wait(0.5)
            gui:Destroy()
            ShowLoaderWindow()
        else
            ST.Text = "Invalid key"
            ST.TextColor3 = Color3.fromRGB(200, 80, 80)
            RB.Text = "Redeem"
            RB.BackgroundColor3 = Color3.fromRGB(40, 150, 70)
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
    local gui, Main = MakeWindow("Select a hub", 360, 200, { showProfile = true, noClose = true, minimizeLetter = "H" })
    LoaderGui = gui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -16, 0, 20)
    Title.Position = UDim2.new(0, 8, 0, 56)
    Title.BackgroundTransparency = 1
    Title.Text = "Hubs"
    Title.TextColor3 = Color3.fromRGB(140, 90, 230)
    Title.TextSize = 13
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3
    Title.Parent = Main

    local HubList = Instance.new("Frame")
    HubList.Size = UDim2.new(1, -16, 1, -80)
    HubList.Position = UDim2.new(0, 8, 0, 80)
    HubList.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    HubList.BorderSizePixel = 0
    HubList.ZIndex = 3
    HubList.Parent = Main
    Instance.new("UICorner", HubList).CornerRadius = UDim.new(0, 8)
    local hubLayout = Instance.new("UIListLayout", HubList)
    hubLayout.Padding = UDim.new(0, 6)
    hubLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", HubList).PaddingTop = UDim.new(0, 8)

    local HubData = {
        { name = "Universal Hub", id = "universal", open = OpenUniversalHub },
    }

    for _, mod in ipairs(Modules) do
        table.insert(HubData, { name = mod.name, id = mod.id, open = function() OpenModule(mod) end })
    end

    for i, hd in ipairs(HubData) do
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(1, -12, 0, 34)
        B.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        B.BorderSizePixel = 0
        B.Text = "   +  " .. hd.name
        B.TextColor3 = Color3.fromRGB(180, 180, 200)
        B.TextSize = 12
        B.Font = Enum.Font.Gotham
        B.TextXAlignment = Enum.TextXAlignment.Left
        B.LayoutOrder = i
        B.ZIndex = 4
        B.Parent = HubList
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)

        local active = false

        B.MouseButton1Click:Connect(function()
            if active then
                active = false
                B.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                B.Text = "   +  " .. hd.name
                B.TextColor3 = Color3.fromRGB(180, 180, 200)
                if OpenHubs[hd.id] then
                    pcall(function() OpenHubs[hd.id]:Destroy() end)
                    OpenHubs[hd.id] = nil
                end
            else
                active = true
                B.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
                B.Text = "   -  " .. hd.name
                B.TextColor3 = Color3.fromRGB(220, 200, 255)
                hd.open()
            end
        end)

        B.MouseEnter:Connect(function()
            if not active then B.BackgroundColor3 = Color3.fromRGB(40, 40, 56) end
        end)
        B.MouseLeave:Connect(function()
            if not active then B.BackgroundColor3 = Color3.fromRGB(30, 30, 42) end
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
print("[LunarScripts] Hub v8 loaded")
