--[[
    Sab Hub — Brainrot Steal
    Module for LunarScripts
    Game: Brainrot stehlen (PlaceId: 96342491571673)
    Features: Game-specific cheats + remote monitoring
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local gui, Main = MakeWindow("Sab Hub — Brainrot", 320, 400, { showProfile = false, minimizeLetter = "S" })

local Panel = Instance.new("ScrollingFrame")
Panel.Size = UDim2.new(1, -12, 1, -48)
Panel.Position = UDim2.new(0, 6, 0, 42)
Panel.BackgroundTransparency = 1
Panel.BorderSizePixel = 0
Panel.ScrollBarThickness = 2
Panel.ScrollBarImageColor3 = Color3.fromRGB(110, 60, 220)
Panel.CanvasSize = UDim2.new(0, 0, 0, 0)
Panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
Panel.ZIndex = 3
Panel.Parent = Main
local panelLayout = Instance.new("UIListLayout", Panel)
panelLayout.Padding = UDim.new(0, 4)
panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Panel).PaddingTop = UDim.new(0, 4)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------
local function GetRemote(name)
    local path = ReplicatedStorage:FindFirstChild("Packages")
    if not path then return nil end
    local net = path:FindFirstChild("Net")
    if not net then return nil end
    local re = net:FindFirstChild("RE")
    if not re then return nil end
    return re:FindFirstChild(name)
end

local function FireRemote(name, ...)
    local remote = GetRemote(name)
    if remote then
        remote:FireServer(...)
        return true
    end
    return false
end

local function GetCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

------------------------------------------------------------
-- GAME INFO
------------------------------------------------------------
MakeLabel(Panel, "Brainrot Steal", 1)
MakeLabel(Panel, "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers, 2)

------------------------------------------------------------
-- MOVEMENT
------------------------------------------------------------
MakeLabel(Panel, "Movement", 10)

MakeSlider(Panel, "Fly Speed", 11, 20, 200, 80, function(v)
    getgenv()._sab_flyspeed = v
end)

local InfJumpConn
MakeToggle(Panel, "Infinite Jump", 12, function(on)
    if on then
        InfJumpConn = UserInputService.JumpRequest:Connect(function()
            local char, hrp, hum = GetCharacter()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if InfJumpConn then InfJumpConn:Disconnect() InfJumpConn = nil end
    end
end)

local NoClipConn
MakeToggle(Panel, "NoClip", 13, function(on)
    if on then
        NoClipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if NoClipConn then NoClipConn:Disconnect() NoClipConn = nil end
    end
end)

MakeSlider(Panel, "WalkSpeed", 14, 16, 200, 34, function(v)
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
end)

MakeSlider(Panel, "JumpPower", 15, 50, 300, 50, function(v)
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end)
end)

MakeSlider(Panel, "FOV", 16, 70, 120, 70, function(v)
    workspace.CurrentCamera.FieldOfView = v
end)

------------------------------------------------------------
-- GAME SPECIFIC
------------------------------------------------------------
MakeLabel(Panel, "Game Features", 20)

MakeToggle(Panel, "Anti-Ragdoll", 21, function(on)
    if on then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("Motor6D") then
                        v:Destroy()
                    end
                end
            end
        end)
    end
end)

MakeToggle(Panel, "Auto Click Steal", 22, function(on)
    if on then
        task.spawn(function()
            while getgenv()._sab_autosteal do
                pcall(function()
                    FireRemote("StealService/Grab")
                end)
                task.wait(0.3)
            end
        end)
    end
    getgenv()._sab_autosteal = on
end)

MakeToggle(Panel, "Auto Claim Plot", 23, function(on)
    if on then
        pcall(function()
            FireRemote("PlotService/ClaimCoins")
            FireRemote("PlotService/Open")
        end)
    end
end)

MakeToggle(Panel, "Auto Craft", 24, function(on)
    if on then
        task.spawn(function()
            while getgenv()._sab_autocraft do
                pcall(function()
                    FireRemote("CraftingMachineService/CraftNow")
                    FireRemote("CraftingMachineService/Claim")
                end)
                task.wait(1)
            end
        end)
    end
    getgenv()._sab_autocraft = on
end)

MakeToggle(Panel, "Auto Sort Inventory", 25, function(on)
    if on then
        pcall(function()
            FireRemote("InventoryService/Sort")
        end)
    end
end)

MakeToggle(Panel, "Auto Sell", 26, function(on)
    if on then
        task.spawn(function()
            while getgenv()._sab_autosell do
                pcall(function()
                    FireRemote("PlotService/Sell")
                end)
                task.wait(2)
            end
        end)
    end
    getgenv()._sab_autosell = on
end)

MakeToggle(Panel, "Click Teleport", 27, function(on)
    if on then
        getgenv()._sab_clicktp = true
        getgenv()._sab_clicktp_conn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if getgenv()._sab_clicktp and input.UserInputType == Enum.UserInputType.MouseButton1 then
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    pcall(function()
                        local char, hrp = GetCharacter()
                        if hrp then
                            local mouse = LocalPlayer:GetMouse()
                            hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                        end
                    end)
                end
            end
        end)
    else
        getgenv()._sab_clicktp = false
        if getgenv()._sab_clicktp_conn then
            getgenv()._sab_clicktp_conn:Disconnect()
            getgenv()._sab_clicktp_conn = nil
        end
    end
end)

MakeLabel(Panel, "Ctrl+Click = Teleport", 28)

------------------------------------------------------------
-- PLAYER LIST
------------------------------------------------------------
MakeLabel(Panel, "Players", 30)

local function RefreshPlayers()
    for _, child in ipairs(Panel:GetChildren()) do
        if child:IsA("TextButton") and child.LayoutOrder >= 31 and child.LayoutOrder <= 50 then
            child:Destroy()
        end
    end
    for i, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if i > 15 then break end

        local B = Instance.new("TextButton")
        B.Size = UDim2.new(1, 0, 0, 28)
        B.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
        B.BorderSizePixel = 0
        B.Text = ""
        B.LayoutOrder = 30 + i
        B.ZIndex = 4
        B.Parent = Panel
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)

        local PL = Instance.new("TextLabel")
        PL.Size = UDim2.new(1, -12, 1, 0)
        PL.Position = UDim2.new(0, 12, 0, 0)
        PL.BackgroundTransparency = 1
        PL.Text = player.Name
        PL.TextColor3 = Color3.fromRGB(180, 180, 200)
        PL.TextSize = 11
        PL.Font = Enum.Font.Gotham
        PL.TextXAlignment = Enum.TextXAlignment.Left
        PL.ZIndex = 5
        PL.Parent = B

        B.MouseButton1Click:Connect(function()
            pcall(function()
                local char, hrp = GetCharacter()
                local targetChar = player.Character
                local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                if hrp and targetHRP then
                    hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -5)
                end
            end)
        end)

        B.MouseEnter:Connect(function()
            B.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        end)
        B.MouseLeave:Connect(function()
            B.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
        end)
    end
end

MakeToggle(Panel, "Auto Refresh Players", 31, function(on)
    if on then
        task.spawn(function()
            while getgenv()._sab_refresh do
                RefreshPlayers()
                task.wait(3)
            end
        end)
    end
    getgenv()._sab_refresh = on
end)

RefreshPlayers()

------------------------------------------------------------
-- ESP
------------------------------------------------------------
MakeLabel(Panel, "Visuals", 50)

local ESPLooper
MakeToggle(Panel, "Player ESP", 51, function(on)
    if on then
        ESPLooper = RunService.RenderStepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local char = player.Character
                if not char then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then continue end

                local bill = hrp:FindFirstChild("SabESP")
                if not bill then
                    bill = Instance.new("BillboardGui")
                    bill.Name = "SabESP"
                    bill.Size = UDim2.new(0, 100, 0, 30)
                    bill.StudsOffset = Vector3.new(0, 3, 0)
                    bill.AlwaysOnTop = true
                    bill.Parent = hrp

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(110, 200, 255)
                    label.TextStrokeTransparency = 0.5
                    label.TextSize = 12
                    label.Font = Enum.Font.GothamBold
                    label.Parent = bill
                end

                local hp = math.floor(hum.Health)
                local maxHp = math.floor(hum.MaxHealth)
                bill.TextLabel.Text = player.Name .. " [" .. hp .. "/" .. maxHp .. "]"

                if hp <= 0 then
                    bill.TextLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                elseif hp < maxHp * 0.3 then
                    bill.TextLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
                else
                    bill.TextLabel.TextColor3 = Color3.fromRGB(110, 200, 255)
                end
            end
        end)
    else
        if ESPLooper then ESPLooper:Disconnect() ESPLooper = nil end
        for _, player in ipairs(Players:GetPlayers()) do
            pcall(function()
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local esp = hrp:FindFirstChild("SabESP")
                        if esp then esp:Destroy() end
                    end
                end
            end)
        end
    end
end)

MakeToggle(Panel, "Fullbright", 52, function(on)
    if on then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").GlobalShadows = true
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)

------------------------------------------------------------
-- REMOTE MONITORING
------------------------------------------------------------
MakeLabel(Panel, "Remote Monitor", 60)

local MonitorActive = false
local MonitorLog = {}
local MonitorCount = {}

MakeToggle(Panel, "Log All Remotes", 61, function(on)
    MonitorActive = on
    if on then
        MonitorLog = {}
        MonitorCount = {}

        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local con = obj.OnClientEvent:Connect(function(...)
                    if not MonitorActive then return end
                    local name = obj:GetFullName()
                    local args = {...}
                    local argStr = ""
                    for i, v in ipairs(args) do
                        argStr = argStr .. tostring(v)
                        if i < #args then argStr = argStr .. ", " end
                    end
                    table.insert(MonitorLog, 1, {
                        time = os.clock(),
                        dir = "SERVER→CLIENT",
                        name = name,
                        args = argStr
                    })
                    MonitorCount[name] = (MonitorCount[name] or 0) + 1
                    if #MonitorLog > 200 then
                        table.remove(MonitorLog)
                    end
                end)
                table.insert(Connections, con)
            end
        end

        local namecall
        namecall = hookmetamethod(game, "__namecall", function(self, ...)
            if not MonitorActive then return namecall(self, ...) end
            local method = getnamecallmethod()
            if method == "FireServer" and self:IsA("RemoteEvent") then
                local name = self:GetFullName()
                local args = {...}
                local argStr = ""
                for i, v in ipairs(args) do
                    argStr = argStr .. tostring(v)
                    if i < #args then argStr = argStr .. ", " end
                end
                table.insert(MonitorLog, 1, {
                    time = os.clock(),
                    dir = "CLIENT→SERVER",
                    name = name,
                    args = argStr
                })
                MonitorCount[name] = (MonitorCount[name] or 0) + 1
                if #MonitorLog > 200 then
                    table.remove(MonitorLog)
                end
            end
            return namecall(self, ...)
        end)

        pcall(function()
            local con
            con = hookmetamethod(game, "__namecall", function(self, ...)
                if MonitorActive and getnamecallmethod() == "FireServer" and self:IsA("RemoteEvent") then
                    local name = self:GetFullName()
                    local args = {...}
                    local argStr = ""
                    for i, v in ipairs(args) do
                        argStr = argStr .. tostring(v)
                        if i < #args then argStr = argStr .. ", " end
                    end
                    table.insert(MonitorLog, 1, {
                        time = os.clock(),
                        dir = "CLIENT→SERVER",
                        name = name,
                        args = argStr
                    })
                    MonitorCount[name] = (MonitorCount[name] or 0) + 1
                    if #MonitorLog > 200 then
                        table.remove(MonitorLog)
                    end
                end
                return con(self, ...)
            end)
            table.insert(Connections, con)
        end)
    end
end)

MakeToggle(Panel, "Save Log to File", 62, function(on)
    if on and MonitorActive then
        local lines = {"== Remote Monitor Log ==", "Time: " .. os.date("%H:%M:%S"), ""}
        for _, entry in ipairs(MonitorLog) do
            table.insert(lines, string.format("[%s] %s | %s | %s", entry.dir, entry.name, entry.args))
        end
        table.insert(lines, "")
        table.insert(lines, "== Remote Call Counts ==")
        for name, count in pairs(MonitorCount) do
            table.insert(lines, count .. "x " .. name)
        end
        local content = table.concat(lines, "\n")
        if writefile then
            writefile("SabMonitor_" .. tostring(game.PlaceId) .. ".txt", content)
        end
    end
end)

MakeLabel(Panel, "Log: " .. "0 entries", 63)

------------------------------------------------------------
-- HIGHLIGHT PLAYERS
------------------------------------------------------------
local HighlightConn
MakeToggle(Panel, "Player Highlights", 55, function(on)
    if on then
        HighlightConn = RunService.RenderStepped:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                local char = player.Character
                if not char then continue end
                local hl = char:FindFirstChild("SabHighlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "SabHighlight"
                    hl.FillColor = Color3.fromRGB(110, 60, 220)
                    hl.OutlineColor = Color3.fromRGB(200, 150, 255)
                    hl.FillTransparency = 0.7
                    hl.OutlineTransparency = 0.3
                    hl.Adornee = char
                    hl.Parent = char
                end
            end
        end)
    else
        if HighlightConn then HighlightConn:Disconnect() HighlightConn = nil end
        for _, player in ipairs(Players:GetPlayers()) do
            pcall(function()
                local char = player.Character
                if char then
                    local hl = char:FindFirstChild("SabHighlight")
                    if hl then hl:Destroy() end
                end
            end)
        end
    end
end)

print("[SabHub] Loaded for: Brainrot Steal | PlaceId: " .. tostring(game.PlaceId))
