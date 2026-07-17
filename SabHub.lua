--[[
    Sab Hub
    Module for LunarScripts
    Game-specific features + universal helpers
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui, Main = MakeWindow("Sab Hub", 320, 360, { showProfile = false, minimizeLetter = "S" })

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
-- GAME DETECTION
------------------------------------------------------------
local GameName = ""
pcall(function()
    GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)
MakeLabel(Panel, "Game: " .. (GameName ~= "" and GameName or "Unknown"), 1)

------------------------------------------------------------
-- UNIVERSAL FEATURES
------------------------------------------------------------
local InfJumpConn
MakeToggle(Panel, "Infinite Jump", 10, function(on)
    if on then
        InfJumpConn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if InfJumpConn then InfJumpConn:Disconnect() InfJumpConn = nil end
    end
end)

local NoClipConn
MakeToggle(Panel, "NoClip", 11, function(on)
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

MakeSlider(Panel, "WalkSpeed", 12, 16, 200, 16, function(v)
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
end)

MakeSlider(Panel, "JumpPower", 13, 50, 300, 50, function(v)
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end)
end)

MakeSlider(Panel, "FOV", 14, 70, 120, 70, function(v)
    workspace.CurrentCamera.FieldOfView = v
end)

------------------------------------------------------------
-- GAME SCAN INFO
------------------------------------------------------------
MakeLabel(Panel, "Game Info", 20)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 60)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Run GameScanner.lua\nfor full game analysis"
InfoLabel.TextColor3 = Color3.fromRGB(90, 90, 110)
InfoLabel.TextSize = 11
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextWrapped = true
InfoLabel.LayoutOrder = 21
InfoLabel.ZIndex = 4
InfoLabel.Parent = Panel

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, 0, 0, 32)
ScanBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
ScanBtn.BorderSizePixel = 0
ScanBtn.Text = ""
ScanBtn.LayoutOrder = 22
ScanBtn.ZIndex = 4
ScanBtn.Parent = Panel
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 8)

local ScanBtnLabel = Instance.new("TextLabel")
ScanBtnLabel.Size = UDim2.new(1, -12, 1, 0)
ScanBtnLabel.Position = UDim2.new(0, 12, 0, 0)
ScanBtnLabel.BackgroundTransparency = 1
ScanBtnLabel.Text = "Copy Scanner Script"
ScanBtnLabel.TextColor3 = Color3.fromRGB(140, 80, 255)
ScanBtnLabel.TextSize = 12
ScanBtnLabel.Font = Enum.Font.GothamBold
ScanBtnLabel.TextXAlignment = Enum.TextXAlignment.Left
ScanBtnLabel.ZIndex = 5
ScanBtnLabel.Parent = ScanBtn

local ScannerScript = [[
-- Paste this into your executor and run it
-- It will save a game report file
loadstring(game:HttpGet("https://raw.githubusercontent.com/NiklasNK-Creator/Lunarscriptss/main/GameScanner.lua"))()
]]

ScanBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(ScannerScript)
    elseif toclipboard then
        toclipboard(ScannerScript)
    end
    ScanBtnLabel.Text = "Copied!"
    task.wait(1.5)
    ScanBtnLabel.Text = "Copy Scanner Script"
end)

ScanBtn.MouseEnter:Connect(function()
    ScanBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
end)
ScanBtn.MouseLeave:Connect(function()
    ScanBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
end)

------------------------------------------------------------
-- REMOTE INFO (auto-detects remotes in game)
------------------------------------------------------------
local Remotes = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        table.insert(Remotes, obj)
    end
end

if #Remotes > 0 then
    MakeLabel(Panel, "Remotes Detected: " .. #Remotes, 30)
    
    for i, remote in ipairs(Remotes) do
        if i > 10 then
            MakeLabel(Panel, "... and " .. (#Remotes - 10) .. " more", 30 + i)
            break
        end
        local RemoteBtn = Instance.new("TextButton")
        RemoteBtn.Size = UDim2.new(1, 0, 0, 28)
        RemoteBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
        RemoteBtn.BorderSizePixel = 0
        RemoteBtn.Text = ""
        RemoteBtn.LayoutOrder = 30 + i
        RemoteBtn.ZIndex = 4
        RemoteBtn.Parent = Panel
        Instance.new("UICorner", RemoteBtn).CornerRadius = UDim.new(0, 6)

        local RemoteLabel = Instance.new("TextLabel")
        RemoteLabel.Size = UDim2.new(1, -12, 1, 0)
        RemoteLabel.Position = UDim2.new(0, 12, 0, 0)
        RemoteLabel.BackgroundTransparency = 1
        RemoteLabel.Text = "[" .. remote.ClassName .. "] " .. remote.Name
        RemoteLabel.TextColor3 = Color3.fromRGB(140, 80, 255)
        RemoteLabel.TextSize = 10
        RemoteLabel.Font = Enum.Font.Gotham
        RemoteLabel.TextXAlignment = Enum.TextXAlignment.Left
        RemoteLabel.ZIndex = 5
        RemoteLabel.Parent = RemoteBtn

        RemoteBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(remote.Name)
            elseif toclipboard then
                toclipboard(remote.Name)
            end
            RemoteLabel.Text = "Copied: " .. remote.Name
            task.wait(1)
            RemoteLabel.Text = "[" .. remote.ClassName .. "] " .. remote.Name
        end)

        RemoteBtn.MouseEnter:Connect(function()
            RemoteBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
        end)
        RemoteBtn.MouseLeave:Connect(function()
            RemoteBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
        end)
    end
end

print("[SabHub] Loaded for: " .. (GameName ~= "" and GameName or "Unknown Game"))
