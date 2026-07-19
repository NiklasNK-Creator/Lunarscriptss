--[[
    LunarScripts Hub v10
    Key -> Loader -> Hub windows
]]

-- SERVICES
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

-- KEY SDK
local Junkie
do
    local ok, j = pcall(function()
        return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
    if ok and j then
        Junkie = j
        Junkie.service = "LunarScripts"
        Junkie.identifier = "1158259"
        Junkie.provider = "LunarScripts"
    end
end

-- CONSTANTS
local LocalPlayer = Players.LocalPlayer
local MONKEY_URL = "https://raw.githubusercontent.com/NiklasNK-Creator/Lunarscriptss/main/monkey.png"
local ANIM_SPEED = 0.2
local ZERO_V3 = Vector3.new(0, 0, 0)
local UP_V3 = Vector3.new(0, 1, 0)

-- STATE
local LoaderGui = nil
local OpenHubs = {}
local HubConnections = {}

------------------------------------------------------------
-- COLOR PALETTE
------------------------------------------------------------
local C = {
    bg       = Color3.fromRGB(10, 10, 16),
    bgLight  = Color3.fromRGB(16, 16, 24),
    bgCard   = Color3.fromRGB(22, 22, 32),
    bgHover  = Color3.fromRGB(28, 28, 40),
    accent   = Color3.fromRGB(110, 60, 220),
    accentDark = Color3.fromRGB(65, 30, 140),
    accentGlow = Color3.fromRGB(140, 80, 255),
    accentSoft = Color3.fromRGB(90, 50, 180),
    green    = Color3.fromRGB(50, 190, 110),
    red      = Color3.fromRGB(190, 45, 45),
    yellow   = Color3.fromRGB(220, 180, 50),
    text     = Color3.fromRGB(240, 240, 250),
    textDim  = Color3.fromRGB(150, 150, 175),
    textMuted = Color3.fromRGB(75, 75, 95),
    sep      = Color3.fromRGB(30, 30, 44),
    trackOff = Color3.fromRGB(38, 38, 52),
    trackOn  = Color3.fromRGB(65, 30, 140),
}

------------------------------------------------------------
-- UTILITY FUNCTIONS
------------------------------------------------------------
local function DestroyHubFeatures(hubId)
    if HubConnections[hubId] then
        for _, conn in ipairs(HubConnections[hubId]) do
            pcall(function() conn:Disconnect() end)
        end
        HubConnections[hubId] = nil
    end
end

local function TrackConnection(hubId, conn)
    if not HubConnections[hubId] then HubConnections[hubId] = {} end
    table.insert(HubConnections[hubId], conn)
    return conn
end

local function CleanAll()
    for id, _ in pairs(OpenHubs) do
        DestroyHubFeatures(id)
    end
    for _, g in pairs(OpenHubs) do
        pcall(function() g:Destroy() end)
    end
    OpenHubs = {}
end

local function Clip(text)
    local fn = setclipboard or toclipboard
    if fn then fn(text) end
end

local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "LunarScripts",
            Text = text or "",
            Duration = dur or 3,
        })
    end)
end

local tweenCache = {}
local function Tween(obj, props, t)
    local key = tostring(t or 0.15)
    if not tweenCache[key] then
        tweenCache[key] = TweenInfo.new(t or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    end
    local tw = TweenService:Create(obj, tweenCache[key], props)
    tw:Play()
    return tw
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsInputType(input, ...)
    local t = input.UserInputType
    for _, v in ipairs({...}) do
        if t == v then return true end
    end
    return false
end

local MOUSE_OR_TOUCH = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch }
local MOVE_TYPES = { Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch }

------------------------------------------------------------
-- DRAG SYSTEM
------------------------------------------------------------
local function Drag(frame, handle)
    local conn, dragging, startInput, startPos
    handle.InputBegan:Connect(function(input)
        if IsInputType(input, unpack(MOUSE_OR_TOUCH)) then
            dragging = true
            startInput = input.Position
            startPos = frame.Position
            if conn then conn:Disconnect() end
            conn = UserInputService.InputChanged:Connect(function(moved)
                if dragging and IsInputType(moved, unpack(MOVE_TYPES)) then
                    local delta = moved.Position - startInput
                    frame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end)
        end
    end)
    handle.InputEnded:Connect(function(input)
        if IsInputType(input, unpack(MOUSE_OR_TOUCH)) then
            dragging = false
            if conn then conn:Disconnect() conn = nil end
        end
    end)
end

------------------------------------------------------------
-- WINDOW FACTORY
------------------------------------------------------------
local function MakeWindow(sub, w, h, opts)
    opts = opts or {}
    local showProfile = opts.showProfile ~= false
    local noClose = opts.noClose or false
    local minimizeLetter = opts.minimizeLetter
    local topH = showProfile and 48 or 34

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "LunarScripts"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = C.bg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.ZIndex = 1
    Main.Parent = gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = C.accent
    stroke.Thickness = 1
    stroke.Transparency = 0.4

    -- Monkey background (BEHIND everything, low transparency)
    -- Requires monkey.png to be committed to the repo root
    pcall(function()
        local BG = Instance.new("ImageLabel")
        BG.Name = "MonkeyBG"
        BG.Size = UDim2.new(1, 0, 1, 0)
        BG.Position = UDim2.new(0, 0, 0, 0)
        BG.BackgroundTransparency = 1
        BG.Image = MONKEY_URL
        BG.ImageTransparency = 0.85
        BG.ScaleType = Enum.ScaleType.Fit
        BG.ImageXAlignment = Enum.ImageXAlignment.Center
        BG.ImageYAlignment = Enum.ImageYAlignment.Center
        BG.ZIndex = 1
        BG.Parent = Main
    end)

    -- Open animation
    task.spawn(function()
        Tween(Main, {Size = UDim2.new(0, w, 0, h)}, ANIM_SPEED)
    end)

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, topH)
    TopBar.BackgroundColor3 = C.bgLight
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 5
    TopBar.Parent = Main
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
    local cover = Instance.new("Frame")
    cover.Size = UDim2.new(1, 0, 0, 10)
    cover.Position = UDim2.new(0, 0, 1, -10)
    cover.BackgroundColor3 = C.bgLight
    cover.BorderSizePixel = 0
    cover.ZIndex = 5
    cover.Parent = TopBar

    -- Separator
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -20, 0, 1)
    sep.Position = UDim2.new(0, 10, 1, 0)
    sep.BackgroundColor3 = C.sep
    sep.BorderSizePixel = 0
    sep.ZIndex = 6
    sep.Parent = TopBar

    -- Profile or title
    if showProfile then
        local PFP = Instance.new("ImageLabel")
        PFP.Size = UDim2.new(0, 26, 0, 26)
        PFP.Position = UDim2.new(0, 10, 0.5, -13)
        PFP.BackgroundColor3 = C.bgCard
        PFP.BorderSizePixel = 0
        PFP.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png"
        PFP.ZIndex = 6
        PFP.Parent = TopBar
        Instance.new("UICorner", PFP).CornerRadius = UDim.new(1, 0)
        local pfpS = Instance.new("UIStroke", PFP)
        pfpS.Color = C.accentSoft
        pfpS.Thickness = 1.5
        pfpS.Transparency = 0.2

        local Name = Instance.new("TextLabel")
        Name.Size = UDim2.new(1, -85, 0, 14)
        Name.Position = UDim2.new(0, 44, 0, 7)
        Name.BackgroundTransparency = 1
        Name.Text = "@" .. LocalPlayer.Name
        Name.TextColor3 = C.text
        Name.TextSize = 11
        Name.Font = Enum.Font.GothamBold
        Name.TextXAlignment = Enum.TextXAlignment.Left
        Name.ZIndex = 6
        Name.Parent = TopBar

        local Sub = Instance.new("TextLabel")
        Sub.Size = UDim2.new(1, -85, 0, 12)
        Sub.Position = UDim2.new(0, 44, 0, 24)
        Sub.BackgroundTransparency = 1
        Sub.Text = sub
        Sub.TextColor3 = C.textDim
        Sub.TextSize = 9
        Sub.Font = Enum.Font.Gotham
        Sub.TextXAlignment = Enum.TextXAlignment.Left
        Sub.ZIndex = 6
        Sub.Parent = TopBar
    else
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -75, 0, topH)
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = sub
        Title.TextColor3 = C.text
        Title.TextSize = 12
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 6
        Title.Parent = TopBar
    end

    -- Minimize button
    if minimizeLetter then
        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 22, 0, 22)
        MinBtn.Position = UDim2.new(1, -54, 0.5, -11)
        MinBtn.BackgroundColor3 = C.bgCard
        MinBtn.BorderSizePixel = 0
        MinBtn.Text = "-"
        MinBtn.TextColor3 = C.textDim
        MinBtn.TextSize = 13
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.ZIndex = 7
        MinBtn.Parent = TopBar
        Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
        MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundColor3 = C.accentDark}, 0.1) end)
        MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundColor3 = C.bgCard}, 0.1) end)

        local Mini = Instance.new("TextButton")
        Mini.Size = UDim2.new(0, 40, 0, 40)
        Mini.Position = Main.Position
        Mini.AnchorPoint = Main.AnchorPoint
        Mini.BackgroundColor3 = C.bg
        Mini.BorderSizePixel = 0
        Mini.Text = minimizeLetter
        Mini.TextColor3 = C.accentGlow
        Mini.TextSize = 16
        Mini.Font = Enum.Font.GothamBold
        Mini.ZIndex = 10
        Mini.Visible = false
        Mini.Parent = gui
        Instance.new("UICorner", Mini).CornerRadius = UDim.new(0, 10)
        local ms = Instance.new("UIStroke", Mini)
        ms.Color = C.accent
        ms.Thickness = 1
        ms.Transparency = 0.3

        local miniMoved = false
        local miniConn
        Mini.InputBegan:Connect(function(i)
            if IsInputType(i, unpack(MOUSE_OR_TOUCH)) then
                miniMoved = false
                local sp, sfp = i.Position, Mini.Position
                miniConn = UserInputService.InputChanged:Connect(function(i2)
                    if IsInputType(i2, unpack(MOVE_TYPES)) then
                        local dx, dy = i2.Position.X - sp.X, i2.Position.Y - sp.Y
                        if math.abs(dx) > 3 or math.abs(dy) > 3 then miniMoved = true end
                        Mini.Position = UDim2.new(sfp.X.Scale, sfp.X.Offset + dx, sfp.Y.Scale, sfp.Y.Offset + dy)
                    end
                end)
            end
        end)
        Mini.InputEnded:Connect(function(i)
            if IsInputType(i, unpack(MOUSE_OR_TOUCH)) then
                if miniConn then miniConn:Disconnect() miniConn = nil end
            end
        end)

        MinBtn.MouseButton1Click:Connect(function()
            Mini.Position = Main.Position
            Main.Visible = false
            Mini.Visible = true
        end)
        Mini.MouseButton1Click:Connect(function()
            if miniMoved then return end
            Main.Position = Mini.Position
            Main.Visible = true
            Mini.Visible = false
        end)
    end

    -- Close button
    local XB = Instance.new("TextButton")
    XB.Size = UDim2.new(0, 22, 0, 22)
    XB.Position = UDim2.new(1, -30, 0.5, -11)
    XB.BackgroundColor3 = C.red
    XB.BorderSizePixel = 0
    XB.Text = "X"
    XB.TextColor3 = Color3.new(1, 1, 1)
    XB.TextSize = 9
    XB.Font = Enum.Font.GothamBold
    XB.ZIndex = 7
    XB.Parent = TopBar
    Instance.new("UICorner", XB).CornerRadius = UDim.new(0, 6)
    XB.MouseEnter:Connect(function() Tween(XB, {BackgroundColor3 = Color3.fromRGB(230, 65, 65)}, 0.1) end)
    XB.MouseLeave:Connect(function() Tween(XB, {BackgroundColor3 = C.red}, 0.1) end)

    XB.MouseButton1Click:Connect(function()
        if noClose then
            CleanAll()
        end
        gui:Destroy()
    end)

    Drag(Main, TopBar)
    return gui, Main, topH
end

------------------------------------------------------------
-- FORWARD DECLARATIONS
------------------------------------------------------------
local ShowKeyWindow, ShowLoaderWindow

------------------------------------------------------------
-- UNIVERSAL HUB — STATE
------------------------------------------------------------
local UniActive = {}
local FlySpeed = 80
local DesiredWalkSpeed = 16
local DesiredJumpPower = 50

------------------------------------------------------------
-- UNIVERSAL HUB — FEATURES
------------------------------------------------------------

-- FLY
local function StartFly(hubId)
    if UniActive.fly then return end
    local hrp, hum = GetHRP(), GetHumanoid()
    if not hrp or not hum then return end
    UniActive.fly = true
    hum.PlatformStand = true
    hum.AutoRotate = false

    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        if not UniActive.fly then
            local h = GetHumanoid()
            if h then h.PlatformStand = false; h.AutoRotate = true end
            if conn then conn:Disconnect() end
            return
        end
        local hrp2 = GetHRP()
        if not hrp2 then UniActive.fly = false; return end

        local cf = Workspace.CurrentCamera.CFrame
        local dir = ZERO_V3
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + UP_V3 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - UP_V3 end

        hrp2.AssemblyLinearVelocity = ZERO_V3
        hrp2.AssemblyAngularVelocity = ZERO_V3

        local move = dir.Magnitude > 0 and dir.Unit * FlySpeed or ZERO_V3
        hrp2.CFrame = CFrame.new(hrp2.Position + move * dt, hrp2.Position + move * dt + cf.LookVector)
    end)
    TrackConnection(hubId, conn)
end

local function StopFly()
    UniActive.fly = false
end

-- NOCLIP
local function SetNoclip(on, hubId)
    UniActive.noclip = on
    if on then
        local conn
        conn = RunService.Stepped:Connect(function()
            if not UniActive.noclip then
                if conn then conn:Disconnect() end
                return
            end
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        TrackConnection(hubId, conn)
    end
end

-- INFINITE JUMP
local function SetInfJump(on, hubId)
    UniActive.infjump = on
    if on then
        local conn
        conn = UserInputService.JumpRequest:Connect(function()
            if not UniActive.infjump then
                if conn then conn:Disconnect() end
                return
            end
            local hum = GetHumanoid()
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hum.JumpPower = math.max(hum.JumpPower, 50)
                hum.JumpHeight = math.max(hum.JumpHeight or 0, 7.2)
            end
        end)
        TrackConnection(hubId, conn)
    end
end

-- WALKSPEED
local function SetWalkSpeed(on, hubId)
    UniActive.walkspeed = on
    if on then
        local conn
        conn = task.spawn(function()
            while UniActive.walkspeed do
                pcall(function()
                    local hum = GetHumanoid()
                    if hum then hum.WalkSpeed = DesiredWalkSpeed end
                end)
                task.wait(0.2)
            end
        end)
        -- task.spawn returns a thread, not a RBXScriptConnection, so track it differently
        TrackConnection(hubId, {
            Disconnect = function()
                UniActive.walkspeed = false
            end
        })
    end
end

-- GOD MODE (prevents death by freezing health at max)
local function SetGodMode(on, hubId)
    UniActive.godmode = on
    if on then
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not UniActive.godmode then
                if conn then conn:Disconnect() end
                return
            end
            pcall(function()
                local hum = GetHumanoid()
                if hum and hum.Health > 0 then
                    hum.Health = hum.MaxHealth
                end
            end)
        end)
        TrackConnection(hubId, conn)

        -- Also hook character added to re-apply
        local charConn
        charConn = LocalPlayer.CharacterAdded:Connect(function(char)
            if not UniActive.godmode then
                if charConn then charConn:Disconnect() end
                return
            end
            task.wait(0.5)
            pcall(function()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth end
            end)
        end)
        TrackConnection(hubId, charConn)
    end
end

-- FULLBRIGHT
local function SetFullbright(on, hubId)
    UniActive.fullbright = on
    if on then
        UniActive._fbBackup = {
            Ambient = Lighting.Ambient,
            Brightness = Lighting.Brightness,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
        }
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.FogEnd = 1e9
        Lighting.GlobalShadows = false
    else
        if UniActive._fbBackup then
            Lighting.Ambient = UniActive._fbBackup.Ambient
            Lighting.Brightness = UniActive._fbBackup.Brightness
            Lighting.FogEnd = UniActive._fbBackup.FogEnd
            Lighting.GlobalShadows = UniActive._fbBackup.GlobalShadows
            UniActive._fbBackup = nil
        end
    end
end

-- ESP
local function SetESP(on, hubId)
    UniActive.esp = on
    if on then
        UniActive._espConnList = {}
        UniActive._espPlayers = {}

        local function AddESP(player)
            if player == LocalPlayer then return end
            if not UniActive.esp then return end
            local highlight = Instance.new("Highlight")
            highlight.Name = "LunarESP_" .. player.Name
            highlight.FillColor = C.accent
            highlight.FillTransparency = 0.65
            highlight.OutlineColor = C.accentGlow
            highlight.OutlineTransparency = 0.05
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = game:GetService("CoreGui")
            UniActive._espPlayers[player] = highlight

            local function attach()
                if player.Character and UniActive.esp then
                    highlight.Adornee = player.Character
                end
            end
            attach()
            local c = player.CharacterAdded:Connect(function()
                task.wait(0.3)
                attach()
            end)
            table.insert(UniActive._espConnList, c)
        end

        for _, p in ipairs(Players:GetPlayers()) do AddESP(p) end
        local c = Players.PlayerAdded:Connect(function(p)
            if UniActive.esp then AddESP(p) end
        end)
        table.insert(UniActive._espConnList, c)
        TrackConnection(hubId, c)
    else
        if UniActive._espPlayers then
            for _, h in pairs(UniActive._espPlayers) do
                pcall(function() h:Destroy() end)
            end
            UniActive._espPlayers = nil
        end
        if UniActive._espConnList then
            for _, c in ipairs(UniActive._espConnList) do
                pcall(function() c:Disconnect() end)
            end
            UniActive._espConnList = nil
        end
    end
end

-- ANTI-AFK
local function SetAntiAFK(on, hubId)
    UniActive.antiafk = on
    if on then
        local conn
        conn = task.spawn(function()
            while UniActive.antiafk do
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
                task.wait(50)
            end
        end)
        TrackConnection(hubId, {
            Disconnect = function()
                UniActive.antiafk = false
            end
        })
    end
end

-- FOV CHANGER
local function SetFOV(val)
    pcall(function()
        Workspace.CurrentCamera.FieldOfView = val
    end)
end

-- TELEPORT TO MOUSE
local function TeleportToMouse()
    local hrp = GetHRP()
    if not hrp then
        Notify("Error", "No character found")
        return
    end
    pcall(function()
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Hit then
            local pos = mouse.Hit.Position
            hrp.CFrame = CFrame.new(pos + UP_V3 * 3)
            Notify("Teleported", "Moved to cursor")
        else
            Notify("Error", "Could not get cursor position")
        end
    end)
end

-- RESPAWN
local function ForceRespawn()
    pcall(function()
        LocalPlayer.Character = nil
    end)
    task.wait(0.3)
    pcall(function()
        LocalPlayer:LoadCharacter()
    end)
    Notify("Respawn", "Respawning...")
end

-- FREECAM
local function SetFreecam(on, hubId)
    UniActive.freecam = on
    if on then
        UniActive._fcOld = Workspace.CurrentCamera.CameraType
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        local speed = 60
        local conn
        conn = RunService.RenderStepped:Connect(function(dt)
            if not UniActive.freecam then
                Workspace.CurrentCamera.CameraType = UniActive._fcOld or Enum.CameraType.Custom
                if conn then conn:Disconnect() end
                return
            end
            local cam = Workspace.CurrentCamera
            local cf = cam.CFrame
            local dir = ZERO_V3
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir = dir + UP_V3 end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir = dir - UP_V3 end
            if dir.Magnitude > 0 then
                cam.CFrame = cf + (dir.Unit * speed * dt)
            end
        end)
        TrackConnection(hubId, conn)
    else
        Workspace.CurrentCamera.CameraType = UniActive._fcOld or Enum.CameraType.Custom
    end
end

------------------------------------------------------------
-- UI HELPERS
------------------------------------------------------------
local function MakeToggle(Panel, name, order, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -4, 0, 32)
    B.BackgroundColor3 = C.bgCard
    B.BorderSizePixel = 0
    B.Text = ""
    B.AutoButtonColor = false
    B.LayoutOrder = order
    B.ZIndex = 4
    B.Parent = Panel
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 7)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -52, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = C.textDim
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 5
    Label.Parent = B

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(0, 32, 0, 16)
    Track.Position = UDim2.new(1, -42, 0.5, -8)
    Track.BackgroundColor3 = C.trackOff
    Track.BorderSizePixel = 0
    Track.ZIndex = 5
    Track.Parent = B
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new(0, 2, 0.5, -6)
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
            Tween(Track, {BackgroundColor3 = C.trackOn}, 0.12)
            Tween(Knob, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = C.accentGlow}, 0.12)
            Tween(Label, {TextColor3 = C.text}, 0.12)
        else
            Tween(Track, {BackgroundColor3 = C.trackOff}, 0.12)
            Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = C.textMuted}, 0.12)
            Tween(Label, {TextColor3 = C.textDim}, 0.12)
        end
    end)

    B.MouseEnter:Connect(function() Tween(B, {BackgroundColor3 = C.bgHover}, 0.08) end)
    B.MouseLeave:Connect(function() Tween(B, {BackgroundColor3 = C.bgCard}, 0.08) end)
    return B
end

local function MakeSlider(Panel, name, order, min, max, def, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -4, 0, 36)
    Holder.BackgroundColor3 = C.bgCard
    Holder.BorderSizePixel = 0
    Holder.LayoutOrder = order
    Holder.ZIndex = 4
    Holder.Parent = Panel
    Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 7)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 0, 13)
    Label.Position = UDim2.new(0, 10, 0, 3)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = C.textDim
    Label.TextSize = 10
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 5
    Label.Parent = Holder

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0, 34, 0, 13)
    ValLabel.Position = UDim2.new(1, -44, 0, 3)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(def)
    ValLabel.TextColor3 = C.accentGlow
    ValLabel.TextSize = 10
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.ZIndex = 5
    ValLabel.Parent = Holder

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 3)
    Bar.Position = UDim2.new(0, 10, 0, 24)
    Bar.BackgroundColor3 = C.sep
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
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.Position = UDim2.new((def - min) / (max - min), -5, 0.5, -5)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 7
    Knob.Parent = Bar
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function update(input)
        local pct = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pct)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Knob.Position = UDim2.new(pct, -5, 0.5, -5)
        ValLabel.Text = tostring(val)
        callback(val)
    end

    Knob.InputBegan:Connect(function(input)
        if IsInputType(input, unpack(MOUSE_OR_TOUCH)) then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if IsInputType(input, unpack(MOUSE_OR_TOUCH)) then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and IsInputType(input, unpack(MOVE_TYPES)) then update(input) end
    end)
    Bar.InputBegan:Connect(function(input)
        if IsInputType(input, unpack(MOUSE_OR_TOUCH)) then update(input); dragging = true end
    end)
    return Holder
end

local function MakeLabel(Panel, name, order)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -4, 0, 20)
    L.BackgroundTransparency = 1
    L.Text = "  " .. string.upper(name)
    L.TextColor3 = C.textMuted
    L.TextSize = 9
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.LayoutOrder = order
    L.ZIndex = 4
    L.Parent = Panel
end

local function MakeButton(Panel, name, order, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -4, 0, 30)
    B.BackgroundColor3 = C.accentDark
    B.BorderSizePixel = 0
    B.Text = name
    B.TextColor3 = C.text
    B.TextSize = 11
    B.Font = Enum.Font.GothamBold
    B.AutoButtonColor = false
    B.LayoutOrder = order
    B.ZIndex = 4
    B.Parent = Panel
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 7)

    B.MouseEnter:Connect(function() Tween(B, {BackgroundColor3 = C.accent}, 0.08) end)
    B.MouseLeave:Connect(function() Tween(B, {BackgroundColor3 = C.accentDark}, 0.08) end)
    B.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return B
end

------------------------------------------------------------
-- EXPOSE TO MODULES
------------------------------------------------------------
getgenv().MakeWindow = MakeWindow
getgenv().Drag = Drag
getgenv().MakeToggle = MakeToggle
getgenv().MakeSlider = MakeSlider
getgenv().MakeLabel = MakeLabel
getgenv().MakeButton = MakeButton

------------------------------------------------------------
-- EXTERNAL MODULES
------------------------------------------------------------
local Modules = {
}

local function OpenModule(mod)
    mod.loader()
end

------------------------------------------------------------
-- SCROLL PANEL HELPER
------------------------------------------------------------
local function MakePanel(Main, topH)
    local Panel = Instance.new("ScrollingFrame")
    Panel.Size = UDim2.new(1, -12, 1, -(topH + 8))
    Panel.Position = UDim2.new(0, 6, 0, topH + 4)
    Panel.BackgroundTransparency = 1
    Panel.BorderSizePixel = 0
    Panel.ScrollBarThickness = 2
    Panel.ScrollBarImageColor3 = C.accentSoft
    Panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    Panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Panel.ZIndex = 3
    Panel.Parent = Main
    local lay = Instance.new("UIListLayout", Panel)
    lay.Padding = UDim.new(0, 4)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", Panel)
    pad.PaddingTop = UDim.new(0, 3)
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 2)
    pad.PaddingBottom = UDim.new(0, 6)
    return Panel
end

------------------------------------------------------------
-- UNIVERSAL HUB
------------------------------------------------------------
local function OpenUniversalHub()
    local gui, Main, topH = MakeWindow("Universal Hub", 290, 480, { showProfile = false, minimizeLetter = "U" })
    local hubId = "universal"
    OpenHubs[hubId] = gui

    -- When hub GUI is destroyed, clean up all features
    gui.Destroying:Connect(function()
        UniActive.fly = false
        UniActive.noclip = false
        UniActive.infjump = false
        UniActive.walkspeed = false
        UniActive.godmode = false
        UniActive.fullbright = false
        UniActive.freecam = false
        UniActive.antiafk = false
        SetESP(false, hubId)
        SetFullbright(false, hubId)
        SetFreecam(false, hubId)
        DestroyHubFeatures(hubId)
    end)

    local Panel = MakePanel(Main, topH)

    -- Flight
    MakeLabel(Panel, "Flight", 1)
    MakeToggle(Panel, "Fly", 2, function(v)
        if v then StartFly(hubId) else StopFly() end
    end)
    MakeSlider(Panel, "Fly Speed", 3, 10, 300, 80, function(v) FlySpeed = v end)

    -- Movement
    MakeLabel(Panel, "Movement", 4)
    MakeToggle(Panel, "WalkSpeed", 5, function(v) SetWalkSpeed(v, hubId) end)
    MakeSlider(Panel, "Speed Value", 6, 16, 500, 16, function(v)
        DesiredWalkSpeed = v
        pcall(function()
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = v end
        end)
    end)
    MakeSlider(Panel, "Jump Power", 7, 0, 500, 50, function(v)
        DesiredJumpPower = v
        pcall(function()
            local hum = GetHumanoid()
            if hum then hum.JumpPower = v end
        end)
    end)
    MakeToggle(Panel, "NoClip", 8, function(v) SetNoclip(v, hubId) end)
    MakeToggle(Panel, "Infinite Jump", 9, function(v) SetInfJump(v, hubId) end)

    -- Player
    MakeLabel(Panel, "Player", 10)
    MakeToggle(Panel, "God Mode", 11, function(v) SetGodMode(v, hubId) end)
    MakeButton(Panel, "Teleport to Cursor", 12, TeleportToMouse)
    MakeButton(Panel, "Respawn", 13, ForceRespawn)

    -- Visuals
    MakeLabel(Panel, "Visuals", 14)
    MakeToggle(Panel, "ESP", 15, function(v) SetESP(v, hubId) end)
    MakeToggle(Panel, "Fullbright", 16, function(v) SetFullbright(v, hubId) end)
    MakeSlider(Panel, "Field of View", 17, 30, 120, 70, SetFOV)
    MakeToggle(Panel, "Freecam", 18, function(v) SetFreecam(v, hubId) end)

    -- Misc
    MakeLabel(Panel, "Misc", 19)
    MakeToggle(Panel, "Anti-AFK", 20, function(v) SetAntiAFK(v, hubId) end)
end

------------------------------------------------------------
-- WINDOW 1: KEY
------------------------------------------------------------
ShowKeyWindow = function()
    local gui, Main, topH = MakeWindow("Redeem your key", 340, 220, { showProfile = true })

    local C2 = Instance.new("Frame")
    C2.Size = UDim2.new(1, -20, 1, -(topH + 10))
    C2.Position = UDim2.new(0, 10, 0, topH + 6)
    C2.BackgroundTransparency = 1
    C2.ZIndex = 2
    C2.Parent = Main

    local TL = Instance.new("TextLabel")
    TL.Size = UDim2.new(1, 0, 0, 16)
    TL.BackgroundTransparency = 1
    TL.Text = "KEY SYSTEM"
    TL.TextColor3 = C.accentGlow
    TL.TextSize = 10
    TL.Font = Enum.Font.GothamBold
    TL.TextXAlignment = Enum.TextXAlignment.Left
    TL.ZIndex = 3
    TL.Parent = C2

    local KB = Instance.new("TextBox")
    KB.Size = UDim2.new(1, 0, 0, 32)
    KB.Position = UDim2.new(0, 0, 0, 22)
    KB.BackgroundColor3 = C.bgCard
    KB.BorderSizePixel = 0
    KB.PlaceholderText = "Paste your key here..."
    KB.PlaceholderColor3 = C.textMuted
    KB.Text = ""
    KB.TextColor3 = C.text
    KB.TextSize = 11
    KB.Font = Enum.Font.Gotham
    KB.ClearTextOnFocus = false
    KB.ZIndex = 3
    KB.Parent = C2
    Instance.new("UICorner", KB).CornerRadius = UDim.new(0, 7)
    Instance.new("UIPadding", KB).PaddingLeft = UDim.new(0, 10)
    local kbs = Instance.new("UIStroke", KB)
    kbs.Color = C.sep
    kbs.Thickness = 1

    local GKB = Instance.new("TextButton")
    GKB.Size = UDim2.new(0.48, 0, 0, 30)
    GKB.Position = UDim2.new(0, 0, 0, 62)
    GKB.BackgroundColor3 = C.accent
    GKB.BorderSizePixel = 0
    GKB.Text = "Get Key"
    GKB.TextColor3 = Color3.new(1, 1, 1)
    GKB.TextSize = 11
    GKB.Font = Enum.Font.GothamBold
    GKB.AutoButtonColor = false
    GKB.ZIndex = 3
    GKB.Parent = C2
    Instance.new("UICorner", GKB).CornerRadius = UDim.new(0, 7)
    GKB.MouseEnter:Connect(function() Tween(GKB, {BackgroundColor3 = C.accentGlow}, 0.08) end)
    GKB.MouseLeave:Connect(function() Tween(GKB, {BackgroundColor3 = C.accent}, 0.08) end)

    local RB = Instance.new("TextButton")
    RB.Size = UDim2.new(0.48, 0, 0, 30)
    RB.Position = UDim2.new(0.52, 0, 0, 62)
    RB.BackgroundColor3 = C.green
    RB.BorderSizePixel = 0
    RB.Text = "Redeem"
    RB.TextColor3 = Color3.new(1, 1, 1)
    RB.TextSize = 11
    RB.Font = Enum.Font.GothamBold
    RB.AutoButtonColor = false
    RB.ZIndex = 3
    RB.Parent = C2
    Instance.new("UICorner", RB).CornerRadius = UDim.new(0, 7)
    RB.MouseEnter:Connect(function() Tween(RB, {BackgroundColor3 = Color3.fromRGB(70, 210, 130)}, 0.08) end)
    RB.MouseLeave:Connect(function() Tween(RB, {BackgroundColor3 = C.green}, 0.08) end)

    local ST = Instance.new("TextLabel")
    ST.Size = UDim2.new(1, 0, 0, 14)
    ST.Position = UDim2.new(0, 0, 0, 100)
    ST.BackgroundTransparency = 1
    ST.Text = ""
    ST.TextColor3 = C.textDim
    ST.TextSize = 9
    ST.Font = Enum.Font.Gotham
    ST.TextXAlignment = Enum.TextXAlignment.Left
    ST.ZIndex = 3
    ST.Parent = C2

    GKB.MouseButton1Click:Connect(function()
        if not Junkie then
            ST.Text = "Key system unavailable"
            ST.TextColor3 = C.red
            return
        end
        local ok, link = pcall(function() return Junkie.get_key_link() end)
        if ok and link then
            Clip(link)
            ST.Text = "Link copied to clipboard!"
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
        if not Junkie then
            ST.Text = "Key system unavailable"
            ST.TextColor3 = C.red
            return
        end
        ST.Text = "Validating..."
        ST.TextColor3 = C.textDim
        RB.Text = "..."

        local ok, result = pcall(function() return Junkie.check_key(key) end)
        if not ok or not result then
            ST.Text = "Validation error"
            ST.TextColor3 = C.red
            RB.Text = "Redeem"
            return
        end

        if result.valid and result.message ~= "KEYLESS" then
            getgenv().SCRIPT_KEY = key
            ST.Text = "Key valid!"
            ST.TextColor3 = C.green
            Notify("Unlocked", "Key accepted!")
            task.wait(0.4)
            gui:Destroy()
            ShowLoaderWindow()
        elseif result.valid and result.message == "KEYLESS" then
            getgenv().SCRIPT_KEY = "KEYLESS"
            ST.Text = "No key required!"
            ST.TextColor3 = C.green
            Notify("Unlocked", "Keyless mode")
            task.wait(0.4)
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
    local gui, Main, topH = MakeWindow("Select a hub", 300, 180, { showProfile = true, noClose = true, minimizeLetter = "H" })
    LoaderGui = gui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -16, 0, 16)
    Title.Position = UDim2.new(0, 12, 0, topH + 4)
    Title.BackgroundTransparency = 1
    Title.Text = "HUBS"
    Title.TextColor3 = C.accentGlow
    Title.TextSize = 9
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3
    Title.Parent = Main

    local HubList = Instance.new("ScrollingFrame")
    HubList.Size = UDim2.new(1, -20, 1, -(topH + 28))
    HubList.Position = UDim2.new(0, 10, 0, topH + 22)
    HubList.BackgroundTransparency = 1
    HubList.BorderSizePixel = 0
    HubList.ScrollBarThickness = 2
    HubList.ScrollBarImageColor3 = C.accentSoft
    HubList.CanvasSize = UDim2.new(0, 0, 0, 0)
    HubList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    HubList.ZIndex = 3
    HubList.Parent = Main
    local hl = Instance.new("UIListLayout", HubList)
    hl.Padding = UDim.new(0, 5)
    hl.SortOrder = Enum.SortOrder.LayoutOrder

    local HubData = {
        { name = "Universal Hub", id = "universal", open = OpenUniversalHub },
    }
    for _, mod in ipairs(Modules) do
        table.insert(HubData, { name = mod.name, id = mod.id, open = function() OpenModule(mod) end })
    end

    for i, hd in ipairs(HubData) do
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(1, 0, 0, 34)
        B.BackgroundColor3 = C.bgCard
        B.BorderSizePixel = 0
        B.Text = ""
        B.AutoButtonColor = false
        B.LayoutOrder = i
        B.ZIndex = 4
        B.Parent = HubList
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 7)

        local HL = Instance.new("TextLabel")
        HL.Size = UDim2.new(1, -36, 1, 0)
        HL.Position = UDim2.new(0, 12, 0, 0)
        HL.BackgroundTransparency = 1
        HL.Text = hd.name
        HL.TextColor3 = C.textDim
        HL.TextSize = 11
        HL.Font = Enum.Font.GothamMedium
        HL.TextXAlignment = Enum.TextXAlignment.Left
        HL.ZIndex = 5
        HL.Parent = B

        local Arr = Instance.new("TextLabel")
        Arr.Size = UDim2.new(0, 16, 0, 16)
        Arr.Position = UDim2.new(1, -26, 0.5, -8)
        Arr.BackgroundTransparency = 1
        Arr.Text = "+"
        Arr.TextColor3 = C.accentSoft
        Arr.TextSize = 13
        Arr.Font = Enum.Font.GothamBold
        Arr.ZIndex = 5
        Arr.Parent = B

        local active = false
        B.MouseButton1Click:Connect(function()
            active = not active
            if active then
                Tween(B, {BackgroundColor3 = C.accentDark}, 0.1)
                Tween(HL, {TextColor3 = C.text}, 0.1)
                Arr.Text = "-"
                hd.open()
            else
                Tween(B, {BackgroundColor3 = C.bgCard}, 0.1)
                Tween(HL, {TextColor3 = C.textDim}, 0.1)
                Arr.Text = "+"
                if OpenHubs[hd.id] then
                    pcall(function() OpenHubs[hd.id]:Destroy() end)
                    OpenHubs[hd.id] = nil
                end
                DestroyHubFeatures(hd.id)
            end
        end)

        B.MouseEnter:Connect(function()
            if not active then Tween(B, {BackgroundColor3 = C.bgHover}, 0.08) end
        end)
        B.MouseLeave:Connect(function()
            if not active then Tween(B, {BackgroundColor3 = C.bgCard}, 0.08) end
        end)
    end
end

------------------------------------------------------------
-- START
------------------------------------------------------------
local savedKey = getgenv().SCRIPT_KEY
if savedKey and savedKey ~= "" and savedKey ~= "KEYLESS" and Junkie then
    local ok, result = pcall(function() return Junkie.check_key(savedKey) end)
    if ok and result and result.valid and result.message ~= "KEYLESS" then
        ShowLoaderWindow()
        print("[LunarScripts] Hub v10 loaded")
        return
    end
end
getgenv().SCRIPT_KEY = nil
ShowKeyWindow()
print("[LunarScripts] Hub v10 loaded")
