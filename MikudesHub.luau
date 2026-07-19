-- Mikudes Hub | Compact Loader Hub
-- Key System powered by Junkie SDK (LunarScripts)

local Junkie = nil
do
    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
    if ok and lib then
        Junkie = lib
        Junkie.service = "LunarScripts"
        Junkie.identifier = "1158259"
        Junkie.provider = "LunarScripts"
    end
end

getgenv().UI_CLOSED = false
getgenv().UI_MINIMIZED = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local CurrentGame = game.PlaceId

local HWID = "Unknown"
pcall(function() HWID = game:GetService("RbxAnalyticsService"):GetClientId() end)

local Colors = {
    bg        = Color3.fromRGB(18, 18, 22),
    surface   = Color3.fromRGB(25, 25, 30),
    surfaceH  = Color3.fromRGB(32, 32, 38),
    surfaceA  = Color3.fromRGB(40, 40, 48),
    primary   = Color3.fromRGB(88, 166, 255),
    primDark  = Color3.fromRGB(60, 140, 230),
    accent    = Color3.fromRGB(130, 85, 220),
    success   = Color3.fromRGB(50, 180, 115),
    succDark  = Color3.fromRGB(38, 150, 95),
    error     = Color3.fromRGB(220, 70, 70),
    txt       = Color3.fromRGB(230, 237, 243),
    txt2      = Color3.fromRGB(150, 158, 168),
    txt3      = Color3.fromRGB(110, 118, 129),
    border    = Color3.fromRGB(50, 54, 61),
    discord   = Color3.fromRGB(88, 101, 242),
    divLine   = Color3.fromRGB(40, 44, 50),
}

local SupportedGameIds = {
    2753915549, 4252370513, 6523147235, 4483381598, 10446484246,
    1962086894, 286090429, 4570018312, 1542185166, 6872265039,
    12401236368, 5763281665, 3215982486, 6068967045, 920587237,
    4872322870, 537413528, 3956818384, 6284583030, 7488226108,
}

local DiscordInvite = "https://discord.gg/mikudes"
local KeyLink = "https://jnkie.com/get-key/lunarscripts"

local function safeCall(fn, ...) local ok, r = pcall(fn, ...); return ok, r end
local function setClip(t) if type(setclipboard) == "function" then pcall(setclipboard, t) end end
local function saveKey(k) if type(writefile) == "function" then pcall(writefile, "mikudes_verified_key.txt", k) end end
local function loadKey() if type(readfile) ~= "function" then return nil end; local ok, c = pcall(readfile, "mikudes_verified_key.txt"); return ok and c or nil end
local function clearKey() if type(delfile) == "function" then pcall(delfile, "mikudes_verified_key.txt") end end

local function httpGet(url)
    local s, r = pcall(function() return game:HttpGet(url, true) end)
    if s and r and r ~= "" then return r end
    if syn and syn.request then
        local s2, r2 = pcall(function()
            local resp = syn.request({Url = url, Method = "GET"})
            return resp.Body
        end)
        if s2 and r2 then return r2 end
    end
    if http_request then
        local s2, r2 = pcall(function()
            local resp = http_request({Url = url, Method = "GET"})
            return resp.Body
        end)
        if s2 and r2 then return r2 end
    end
    if request then
        local s2, r2 = pcall(function()
            local resp = request({Url = url, Method = "GET"})
            return resp.Body
        end)
        if s2 and r2 then return s2 and r2 or nil end
    end
    return nil
end

local function jsonDecode(str)
    local ok, r = pcall(function() return HttpService:JSONDecode(str) end)
    if ok then return r end
    return nil
end

local function fetchGameInfo(placeId)
    local name = "Game " .. placeId
    local icon = ""
    local ok1, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(placeId)
    end)
    if ok1 and info then
        if info.Name then name = info.Name end
        if info.IconImageAssetId and info.IconImageAssetId ~= 0 then
            icon = "rbxthumb://type=Asset&aid=" .. tostring(info.IconImageAssetId) .. "&w=150&h=150"
        end
    end
    if icon == "" then
        local resp = httpGet("https://games.roblox.com/v1/games/multiget-place-details?placeIds=" .. placeId)
        if resp then
            local data = jsonDecode(resp)
            if data and data[1] and data[1].universeId then
                local iconResp = httpGet("https://thumbnails.roblox.com/v1/games/icons?universeIds=" .. data[1].universeId .. "&returnPolicy=PlaceHolder&size=150x150&format=Png&isCircular=false")
                if iconResp then
                    local iconData = jsonDecode(iconResp)
                    if iconData and iconData.data and iconData.data[1] and iconData.data[1].imageUrl then
                        icon = iconData.data[1].imageUrl
                    end
                end
            end
        end
    end
    return name, icon
end

-- ═══════════════════════════════════════════════════════════
-- UI
-- ═══════════════════════════════════════════════════════════

local gui = Instance.new("ScreenGui")
gui.Name = "MikudesHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999

pcall(function() local b = Instance.new("BlurEffect"); b.Size = 10; b.Name = "MikudesBlur"; b.Parent = Lighting end)

local guiOk = pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not guiOk or not gui.Parent then
    gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
end

gui.AncestryChanged:Connect(function(_, p)
    if p == nil then pcall(function() local b = Lighting:FindFirstChild("MikudesBlur"); if b then b:Destroy() end end) end
end)

-- ── Backdrop ──
local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.new(1, 0, 1, 0); backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
backdrop.BackgroundTransparency = 0.4; backdrop.BorderSizePixel = 0; backdrop.Parent = gui

-- ── Main Container ──
local MIN_W, MIN_H = 340, 380
local MAX_W, MAX_H = 600, 600
local curW, curH = 380, 420

local main = Instance.new("Frame")
main.Name = "Main"; main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, curW, 0, curH)
main.BackgroundColor3 = Colors.bg; main.BorderSizePixel = 0; main.ClipsDescendants = true; main.Parent = backdrop
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", main).Color = Colors.border; main:FindFirstChildOfClass("UIStroke").Transparency = 0.2

-- ═══════════════════════════════════════════════════════════
-- TOP BAR
-- ═══════════════════════════════════════════════════════════

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"; topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundColor3 = Colors.surface; topBar.BorderSizePixel = 0; topBar.ZIndex = 5
topBar.Position = UDim2.new(0, 0, 0, 0); topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 10); topBarFix.Position = UDim2.new(0, 0, 1, -10)
topBarFix.BackgroundColor3 = Colors.surface; topBarFix.BorderSizePixel = 0; topBarFix.ZIndex = 5; topBarFix.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0); title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1; title.Text = "Mikudes Hub"
title.TextColor3 = Colors.txt; title.TextSize = 14; title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 6; title.Parent = topBar

-- close button (red X)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(1, -34, 0, 4)
closeBtn.BackgroundColor3 = Colors.error; closeBtn.Text = ""; closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false; closeBtn.Active = true; closeBtn.ZIndex = 10; closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local closeX = Instance.new("TextLabel")
closeX.Size = UDim2.new(1, 0, 1, 0); closeX.BackgroundTransparency = 1
closeX.Text = "X"; closeX.TextColor3 = Color3.new(1, 1, 1)
closeX.TextSize = 12; closeX.Font = Enum.Font.GothamBold; closeX.ZIndex = 11; closeX.Parent = closeBtn

-- minimize button (-)
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.new(0, 24, 0, 24); minBtn.Position = UDim2.new(1, -62, 0, 4)
minBtn.BackgroundColor3 = Colors.surfaceA; minBtn.Text = ""; minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false; minBtn.Active = true; minBtn.ZIndex = 10; minBtn.Parent = topBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local minIcon = Instance.new("Frame")
minIcon.Name = "MinIcon"
minIcon.Size = UDim2.new(0, 10, 0, 2); minIcon.Position = UDim2.new(0.5, -5, 0.5, -1)
minIcon.BackgroundColor3 = Color3.new(1, 1, 1); minIcon.BorderSizePixel = 0; minIcon.ZIndex = 11; minIcon.Parent = minBtn

-- ═══════════════════════════════════════════════════════════
-- CONTENT (below topBar, hides on minimize)
-- ═══════════════════════════════════════════════════════════

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -32); content.Position = UDim2.new(0, 0, 0, 32)
content.BackgroundColor3 = Colors.bg; content.BorderSizePixel = 0
content.ClipsDescendants = true; content.Parent = main

-- ── Scrollable Body ──
local body = Instance.new("ScrollingFrame")
body.Name = "Body"; body.Size = UDim2.new(1, -20, 1, -8)
body.Position = UDim2.new(0, 10, 0, 4); body.BackgroundTransparency = 1
body.BorderSizePixel = 0; body.ScrollBarThickness = 3; body.ScrollBarImageColor3 = Colors.border
body.CanvasSize = UDim2.new(0, 0, 0, 0); body.Parent = content

local bodyLayout = Instance.new("UIListLayout"); bodyLayout.Padding = UDim.new(0, 10)
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder; bodyLayout.Parent = body
Instance.new("UIPadding", body).PaddingBottom = UDim.new(0, 14)

bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    body.CanvasSize = UDim2.new(0, 0, 0, bodyLayout.AbsoluteContentSize.Y + 20)
end)

-- ═══════════════════════════════════════════════════════════
-- PROFILE ROW
-- ═══════════════════════════════════════════════════════════

local profRow = Instance.new("Frame")
profRow.Size = UDim2.new(1, 0, 0, 50); profRow.BackgroundColor3 = Colors.surface
profRow.BorderSizePixel = 0; profRow.LayoutOrder = 1; profRow.Parent = body
Instance.new("UICorner", profRow).CornerRadius = UDim.new(0, 10)

local avFrame = Instance.new("Frame")
avFrame.Size = UDim2.new(0, 36, 0, 36); avFrame.Position = UDim2.new(0, 8, 0.5, -18)
avFrame.BackgroundColor3 = Colors.surfaceA; avFrame.BorderSizePixel = 0; avFrame.Parent = profRow
Instance.new("UICorner", avFrame).CornerRadius = UDim.new(0, 8)

local avImg = Instance.new("ImageLabel")
avImg.Size = UDim2.new(1, -2, 1, -2); avImg.Position = UDim2.new(0, 1, 0, 1)
avImg.BackgroundTransparency = 1; avImg.ScaleType = Enum.ScaleType.Crop
avImg.BorderSizePixel = 0; avImg.Parent = avFrame
Instance.new("UICorner", avImg).CornerRadius = UDim.new(0, 7)
pcall(function() avImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=150&height=150&format=png" end)

local nameL = Instance.new("TextLabel")
nameL.Size = UDim2.new(1, -130, 0, 16); nameL.Position = UDim2.new(0, 52, 0, 8)
nameL.BackgroundTransparency = 1; nameL.Text = LocalPlayer.Name
nameL.TextColor3 = Colors.txt; nameL.TextSize = 14; nameL.Font = Enum.Font.GothamBold
nameL.TextXAlignment = Enum.TextXAlignment.Left; nameL.TextTruncate = Enum.TextTruncate.AtEnd; nameL.Parent = profRow

local idL = Instance.new("TextLabel")
idL.Size = UDim2.new(1, -130, 0, 12); idL.Position = UDim2.new(0, 52, 0, 26)
idL.BackgroundTransparency = 1
idL.Text = "ID: "..LocalPlayer.UserId.."  |  HWID: "..string.sub(HWID, 1, 10)
idL.TextColor3 = Colors.txt3; idL.TextSize = 10; idL.Font = Enum.Font.Gotham
idL.TextXAlignment = Enum.TextXAlignment.Left; idL.TextTruncate = Enum.TextTruncate.AtEnd; idL.Parent = profRow

-- ── Discord button with image ──
local dcBtn = Instance.new("TextButton")
dcBtn.Size = UDim2.new(0, 28, 0, 28); dcBtn.Position = UDim2.new(1, -38, 0.5, -14)
dcBtn.BackgroundColor3 = Colors.discord; dcBtn.Text = ""; dcBtn.BorderSizePixel = 0
dcBtn.AutoButtonColor = false; dcBtn.Parent = profRow
Instance.new("UICorner", dcBtn).CornerRadius = UDim.new(0, 7)

do
    local dColor = Color3.new(1, 1, 1)
    local discordBody = Instance.new("Frame")
    discordBody.Size = UDim2.new(0, 16, 0, 12); discordBody.Position = UDim2.new(0.5, -8, 0.5, -6)
    discordBody.BackgroundTransparency = 1; discordBody.Parent = dcBtn
    Instance.new("UICorner", discordBody).CornerRadius = UDim.new(0, 3)

    local shape = Instance.new("ImageLabel")
    shape.Size = UDim2.new(0, 16, 0, 12); shape.Position = UDim2.new(0, 0, 0, 0)
    shape.BackgroundTransparency = 1; shape.ImageColor3 = dColor
    shape.Image = "rbxassetid://139833863143264"
    shape.ScaleType = Enum.ScaleType.Fit; shape.Parent = discordBody

    task.delay(0.5, function()
        if shape.Image == "" or not shape.IsLoaded then
            shape:Destroy()
            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1, 0, 1, 0); d.BackgroundTransparency = 1
            d.Text = "D"; d.TextColor3 = dColor; d.TextSize = 15
            d.Font = Enum.Font.GothamBold; d.Parent = discordBody
        end
    end)
end

dcBtn.MouseEnter:Connect(function() TweenService:Create(dcBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(71, 82, 196)}):Play() end)
dcBtn.MouseLeave:Connect(function() TweenService:Create(dcBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.discord}):Play() end)
dcBtn.MouseButton1Click:Connect(function()
    setClip(DiscordInvite)
    pcall(function()
        if syn and syn.request then syn.request({Url = DiscordInvite, Method = "GET"})
        elseif http_request then http_request({Url = DiscordInvite, Method = "GET"})
        elseif request then request({Url = DiscordInvite, Method = "GET"}) end
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- KEY SECTION
-- ═══════════════════════════════════════════════════════════

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 16); keyTitle.BackgroundTransparency = 1
keyTitle.Text = "KEY SYSTEM"; keyTitle.TextColor3 = Colors.txt2
keyTitle.TextSize = 10; keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextXAlignment = Enum.TextXAlignment.Left; keyTitle.LayoutOrder = 2; keyTitle.Parent = body

local inputRow = Instance.new("Frame")
inputRow.Size = UDim2.new(1, 0, 0, 34); inputRow.BackgroundColor3 = Colors.surface
inputRow.BorderSizePixel = 0; inputRow.LayoutOrder = 3; inputRow.Parent = body
Instance.new("UICorner", inputRow).CornerRadius = UDim.new(0, 8)

local inputStroke = Instance.new("UIStroke"); inputStroke.Color = Colors.border
inputStroke.Thickness = 1; inputStroke.Transparency = 0.4; inputStroke.Parent = inputRow

local keyIco = Instance.new("TextLabel")
keyIco.Size = UDim2.new(0, 30, 1, 0); keyIco.BackgroundTransparency = 1
keyIco.Text = "K"; keyIco.TextColor3 = Colors.primary; keyIco.TextSize = 14
keyIco.Font = Enum.Font.GothamBold; keyIco.Parent = inputRow

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1, -40, 1, 0); keyInput.Position = UDim2.new(0, 30, 0, 0)
keyInput.BackgroundTransparency = 1; keyInput.PlaceholderText = "Paste key here..."
keyInput.PlaceholderColor3 = Colors.txt3; keyInput.Text = ""
keyInput.TextColor3 = Colors.txt; keyInput.TextSize = 12; keyInput.Font = Enum.Font.Gotham
keyInput.TextXAlignment = Enum.TextXAlignment.Left; keyInput.ClearTextOnFocus = false
keyInput.Parent = inputRow

keyInput.Focused:Connect(function() TweenService:Create(inputStroke, TweenInfo.new(0.15), {Color = Colors.primary, Thickness = 1.5, Transparency = 0}):Play() end)
keyInput.FocusLost:Connect(function() TweenService:Create(inputStroke, TweenInfo.new(0.15), {Color = Colors.border, Thickness = 1, Transparency = 0.4}):Play() end)

-- ── Buttons Row ──
local btnRow = Instance.new("Frame")
btnRow.Size = UDim2.new(1, 0, 0, 32); btnRow.BackgroundTransparency = 1
btnRow.LayoutOrder = 4; btnRow.Parent = body

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(0.48, -3, 1, 0); getKeyBtn.BackgroundColor3 = Colors.primary
getKeyBtn.Text = ""; getKeyBtn.BorderSizePixel = 0; getKeyBtn.AutoButtonColor = false; getKeyBtn.Parent = btnRow
Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)

local getKeyT = Instance.new("TextLabel")
getKeyT.Size = UDim2.new(1, 0, 1, 0); getKeyT.BackgroundTransparency = 1
getKeyT.Text = "Get Key"; getKeyT.TextColor3 = Color3.new(1, 1, 1)
getKeyT.TextSize = 13; getKeyT.Font = Enum.Font.GothamBold; getKeyT.Parent = getKeyBtn

getKeyBtn.MouseEnter:Connect(function() TweenService:Create(getKeyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(110, 180, 255)}):Play() end)
getKeyBtn.MouseLeave:Connect(function() TweenService:Create(getKeyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.primary}):Play() end)
getKeyBtn.MouseButton1Click:Connect(function()
    setClip(KeyLink)
    getKeyT.Text = "Copied!"
    TweenService:Create(getKeyBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.success}):Play()
    task.delay(1.5, function()
        getKeyT.Text = "Get Key"
        TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.primary}):Play()
    end)
end)

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0.48, -3, 1, 0); verifyBtn.Position = UDim2.new(0.52, 3, 0, 0)
verifyBtn.BackgroundColor3 = Colors.success; verifyBtn.Text = ""; verifyBtn.BorderSizePixel = 0
verifyBtn.AutoButtonColor = false; verifyBtn.Parent = btnRow
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)

local verifyT = Instance.new("TextLabel")
verifyT.Size = UDim2.new(1, 0, 1, 0); verifyT.BackgroundTransparency = 1
verifyT.Text = "Verify Key"; verifyT.TextColor3 = Color3.new(1, 1, 1)
verifyT.TextSize = 13; verifyT.Font = Enum.Font.GothamBold; verifyT.Parent = verifyBtn

verifyBtn.MouseEnter:Connect(function() TweenService:Create(verifyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.succDark}):Play() end)
verifyBtn.MouseLeave:Connect(function() TweenService:Create(verifyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.success}):Play() end)

-- ── Status Line ──
local statusL = Instance.new("TextLabel")
statusL.Size = UDim2.new(1, 0, 0, 14); statusL.BackgroundTransparency = 1
statusL.Text = ""; statusL.TextColor3 = Colors.txt3; statusL.TextSize = 11
statusL.Font = Enum.Font.Gotham; statusL.TextXAlignment = Enum.TextXAlignment.Left
statusL.LayoutOrder = 5; statusL.Parent = body

local function showStatus(msg, color, dur)
    statusL.Text = msg; statusL.TextColor3 = color or Colors.txt3
    if dur and dur > 0 then
        task.delay(dur, function() if statusL.Text == msg then statusL.Text = "" end end)
    end
end

local function shakeFrame(frame)
    local origX = frame.Position.X.Offset
    for _ = 1, 3 do
        TweenService:Create(frame, TweenInfo.new(0.04), {Position = UDim2.new(frame.Position.X.Scale, origX - 5, frame.Position.Y.Scale, frame.Position.Y.Offset)}):Play()
        task.wait(0.04)
        TweenService:Create(frame, TweenInfo.new(0.04), {Position = UDim2.new(frame.Position.X.Scale, origX + 5, frame.Position.Y.Scale, frame.Position.Y.Offset)}):Play()
        task.wait(0.04)
    end
    frame.Position = UDim2.new(frame.Position.X.Scale, origX, frame.Position.Y.Scale, frame.Position.Y.Offset)
end

local function showHubContent()
    for _, child in ipairs(body:GetChildren()) do
        if child:IsA("GuiObject") then child.Visible = false end
    end

    local hubTitle = Instance.new("TextLabel")
    hubTitle.Size = UDim2.new(1, 0, 0, 20); hubTitle.BackgroundTransparency = 1
    hubTitle.Text = "WELCOME TO MIKUDES HUB"; hubTitle.TextColor3 = Colors.primary
    hubTitle.TextSize = 14; hubTitle.Font = Enum.Font.GothamBold
    hubTitle.TextXAlignment = Enum.TextXAlignment.Left; hubTitle.LayoutOrder = 100; hubTitle.Parent = body

    local hubMsg = Instance.new("TextLabel")
    hubMsg.Size = UDim2.new(1, 0, 0, 40); hubMsg.BackgroundTransparency = 1
    hubMsg.Text = "Key verified! Hub is ready.\nSelect a game from the supported list above."
    hubMsg.TextColor3 = Colors.txt2; hubMsg.TextSize = 12; hubMsg.Font = Enum.Font.Gotham
    hubMsg.TextXAlignment = Enum.TextXAlignment.Left; hubMsg.TextWrapped = true
    hubMsg.LayoutOrder = 101; hubMsg.Parent = body
end

local function doVerify()
    local key = keyInput.Text:gsub("%s+", "")
    if key == "" then
        showStatus("Enter a key first", Colors.error, 2); shakeFrame(inputRow); return
    end
    if not Junkie then showStatus("Key system not loaded", Colors.error, 3); return end

    verifyT.Text = "..."; verifyBtn.Interactable = false
    TweenService:Create(verifyBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.txt3}):Play()
    showStatus("Verifying...", Colors.txt2, 0)

    local ok, result = pcall(function() return Junkie.check_key(key) end)
    if ok and result and result.valid then
        saveKey(key)
        verifyT.Text = "OK!"
        showStatus("Key verified!", Colors.success, 0)
        TweenService:Create(verifyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.success}):Play()
        task.wait(0.5)
        getgenv().SCRIPT_KEY = key
        showHubContent()
    else
        verifyT.Text = "Verify Key"; verifyBtn.Interactable = true
        showStatus("Invalid key", Colors.error, 2); shakeFrame(inputRow)
        TweenService:Create(verifyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Colors.success}):Play()
    end
end

verifyBtn.MouseButton1Click:Connect(doVerify)
keyInput.FocusLost:Connect(function(ep) if ep then doVerify() end end)

-- ═══════════════════════════════════════════════════════════
-- DIVIDER
-- ═══════════════════════════════════════════════════════════

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, 0, 0, 1); divider.BackgroundColor3 = Colors.divLine
divider.BorderSizePixel = 0; divider.LayoutOrder = 6; divider.Parent = body

-- ═══════════════════════════════════════════════════════════
-- SCROLLING GAME LIST (marquee with images)
-- ═══════════════════════════════════════════════════════════

local gamesLabel = Instance.new("TextLabel")
gamesLabel.Size = UDim2.new(1, 0, 0, 12); gamesLabel.BackgroundTransparency = 1
gamesLabel.Text = "SUPPORTED GAMES"; gamesLabel.TextColor3 = Colors.txt3
gamesLabel.TextSize = 11; gamesLabel.Font = Enum.Font.GothamBold
gamesLabel.TextXAlignment = Enum.TextXAlignment.Left; gamesLabel.LayoutOrder = 7; gamesLabel.Parent = body

local marqueeClip = Instance.new("Frame")
marqueeClip.Size = UDim2.new(1, 0, 0, 46); marqueeClip.BackgroundColor3 = Colors.surface
marqueeClip.BorderSizePixel = 0; marqueeClip.ClipsDescendants = true
marqueeClip.LayoutOrder = 8; marqueeClip.Parent = body
Instance.new("UICorner", marqueeClip).CornerRadius = UDim.new(0, 6)

local marqueeInner = Instance.new("Frame")
marqueeInner.Name = "Inner"; marqueeInner.Size = UDim2.new(2, 0, 1, 0)
marqueeInner.BackgroundTransparency = 1; marqueeInner.BorderSizePixel = 0; marqueeInner.Parent = marqueeClip

local CARD_W = 110
local CARD_GAP = 8
local cardWidth = CARD_W + CARD_GAP

local function buildGameCard(parent, placeId, layoutX)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, CARD_W, 0, 38); card.Position = UDim2.new(0, layoutX, 0, 4)
    card.BackgroundColor3 = Colors.surfaceH; card.BorderSizePixel = 0; card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local ico = Instance.new("ImageLabel")
    ico.Size = UDim2.new(0, 28, 0, 28); ico.Position = UDim2.new(0, 6, 0, 5)
    ico.BackgroundColor3 = Colors.surfaceA; ico.ScaleType = Enum.ScaleType.Crop
    ico.BorderSizePixel = 0; ico.Parent = card
    Instance.new("UICorner", ico).CornerRadius = UDim.new(0, 5)

    local icoLetter = Instance.new("TextLabel")
    icoLetter.Size = UDim2.new(1, 0, 1, 0); icoLetter.BackgroundTransparency = 1
    icoLetter.Text = "?"; icoLetter.TextColor3 = Colors.txt3; icoLetter.TextSize = 12
    icoLetter.Font = Enum.Font.GothamBold; icoLetter.Parent = ico

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1, -42, 0, 14); nm.Position = UDim2.new(0, 40, 0, 5)
    nm.BackgroundTransparency = 1; nm.Text = "Loading..."
    nm.TextColor3 = Colors.txt; nm.TextSize = 10; nm.Font = Enum.Font.GothamBold
    nm.TextXAlignment = Enum.TextXAlignment.Left; nm.TextTruncate = Enum.TextTruncate.AtEnd; nm.Parent = card

    local gid = Instance.new("TextLabel")
    gid.Size = UDim2.new(1, -42, 0, 10); gid.Position = UDim2.new(0, 40, 0, 22)
    gid.BackgroundTransparency = 1; gid.Text = tostring(placeId)
    gid.TextColor3 = Colors.txt3; gid.TextSize = 8; gid.Font = Enum.Font.Gotham
    gid.TextXAlignment = Enum.TextXAlignment.Left; gid.Parent = card

    if placeId == CurrentGame then
        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0, 32, 0, 10); badge.Position = UDim2.new(1, -36, 0, 4)
        badge.BackgroundColor3 = Colors.success; badge.Text = "HERE"
        badge.TextColor3 = Color3.new(1, 1, 1); badge.TextSize = 7; badge.Font = Enum.Font.GothamBold
        badge.Parent = card
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 3)
    end

    task.spawn(function()
        local name, icon = fetchGameInfo(placeId)
        if nm and nm.Parent then nm.Text = name end
        if ico and ico.Parent then
            if icon and icon ~= "" then
                ico.Image = icon
                icoLetter.Visible = false
            else
                icoLetter.Text = string.sub(name, 1, 1)
            end
        end
    end)

    return card
end

local allGameIds = {}
for i = 1, 2 do
    for _, id in ipairs(SupportedGameIds) do
        table.insert(allGameIds, id)
    end
end

local totalWidth = #allGameIds * cardWidth

for i, gid in ipairs(allGameIds) do
    buildGameCard(marqueeInner, gid, (i - 1) * cardWidth)
end

task.defer(function()
    local speed = 50
    local offset = 0
    local halfW = #SupportedGameIds * cardWidth

    game:GetService("RunService").Heartbeat:Connect(function(dt)
        if not main or not main.Parent then return end
        offset = offset + speed * dt
        if offset >= halfW then offset = offset - halfW end
        marqueeInner.Position = UDim2.new(0, -offset, 0, 0)
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- DRAG (top bar)
-- ═══════════════════════════════════════════════════════════

do
    local dragging, dragStart, startPos, dragActive

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragActive = false
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false; dragActive = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            if not dragActive and (math.abs(d.X) > 5 or math.abs(d.Y) > 5) then
                dragActive = true
            end
            if dragActive then
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- RESIZE HANDLE (bottom-right)
-- ═══════════════════════════════════════════════════════════

local resizeHandle

do
    local handle = Instance.new("TextButton")
    handle.Name = "ResizeHandle"
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new(1, -10, 1, -10)
    handle.AnchorPoint = Vector2.new(0, 0)
    handle.BackgroundColor3 = Colors.surfaceA
    handle.BackgroundTransparency = 0.5
    handle.Text = ""
    handle.BorderSizePixel = 0
    handle.AutoButtonColor = false
    handle.ZIndex = 20
    handle.CursorType = Enum.CursorType.SizeNWSE
    handle.Parent = main
    Instance.new("UICorner", handle).CornerRadius = UDim.new(0, 4)
    resizeHandle = handle

    for i = 0, 2 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 5 + i * 3, 0, 1.5)
        line.Position = UDim2.new(1, -(5 + i * 3), 1, -(5 + i * 4))
        line.AnchorPoint = Vector2.new(0, 0)
        line.BackgroundColor3 = Colors.txt3; line.BackgroundTransparency = 0.2
        line.BorderSizePixel = 0; line.ZIndex = 21; line.Parent = handle
    end

    local resizing, resizeStart, startSize, resizeActive

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeActive = false
            resizeStart = input.Position
            startSize = main.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false; resizeActive = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - resizeStart
            if not resizeActive and (math.abs(d.X) > 5 or math.abs(d.Y) > 5) then
                resizeActive = true
            end
            if resizeActive then
                local newW = math.clamp(startSize.X.Offset + d.X, MIN_W, MAX_W)
                local newH = math.clamp(startSize.Y.Offset + d.Y, MIN_H, MAX_H)
                main.Size = UDim2.new(0, newW, 0, newH)
                curW = newW; curH = newH
                content.Size = UDim2.new(1, 0, 1, -32)
                body.CanvasSize = UDim2.new(0, 0, 0, bodyLayout.AbsoluteContentSize.Y + 20)
            end
        end
    end)

    handle.MouseEnter:Connect(function() TweenService:Create(handle, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play() end)
    handle.MouseLeave:Connect(function() TweenService:Create(handle, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play() end)
end

-- ═══════════════════════════════════════════════════════════
-- MINIMIZE / CLOSE
-- ═══════════════════════════════════════════════════════════

minBtn.MouseEnter:Connect(function() TweenService:Create(minBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.txt3}):Play() end)
minBtn.MouseLeave:Connect(function() TweenService:Create(minBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.surfaceA}):Play() end)

minBtn.MouseButton1Click:Connect(function()
    getgenv().UI_MINIMIZED = not getgenv().UI_MINIMIZED
    if getgenv().UI_MINIMIZED then
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, curW, 0, 32)
        }):Play()
        content.Visible = false
        resizeHandle.Visible = false
        minIcon:ClearAllChildren()
        local h = Instance.new("Frame"); h.Size = UDim2.new(0, 10, 0, 2)
        h.Position = UDim2.new(0.5, -5, 0.5, -1); h.BackgroundColor3 = Color3.new(1, 1, 1)
        h.BorderSizePixel = 0; h.Parent = minIcon
        local v = Instance.new("Frame"); v.Size = UDim2.new(0, 2, 0, 10)
        v.Position = UDim2.new(0.5, -1, 0.5, -5); v.BackgroundColor3 = Color3.new(1, 1, 1)
        v.BorderSizePixel = 0; v.Parent = minIcon
    else
        content.Visible = true
        resizeHandle.Visible = true
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, curW, 0, curH)
        }):Play()
        minIcon:ClearAllChildren()
        local l = Instance.new("Frame"); l.Size = UDim2.new(0, 10, 0, 2)
        l.Position = UDim2.new(0.5, -5, 0.5, -1); l.BackgroundColor3 = Color3.new(1, 1, 1)
        l.BorderSizePixel = 0; l.Parent = minIcon
    end
end)

closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 90, 90)}):Play() end)
closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.error}):Play() end)
closeBtn.MouseButton1Click:Connect(function()
    getgenv().UI_CLOSED = true
    getgenv().UI_MINIMIZED = false
    TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.2)
    pcall(function() gui:Destroy() end)
    pcall(function() local b = Lighting:FindFirstChild("MikudesBlur"); if b then b:Destroy() end end)
end)

-- ═══════════════════════════════════════════════════════════
-- AUTO-CHECK SAVED KEY
-- ═══════════════════════════════════════════════════════════

task.spawn(function()
    local savedKey = loadKey()
    local keyToCheck = savedKey or getgenv().SCRIPT_KEY
    if keyToCheck and Junkie then
        local ok, result = pcall(function() return Junkie.check_key(keyToCheck) end)
        if ok and result and result.valid then
            if not savedKey then saveKey(keyToCheck) end
            getgenv().SCRIPT_KEY = keyToCheck
            showHubContent()
            return
        end
        if savedKey and not result.valid then clearKey() end
    end
end)

while not getgenv().UI_CLOSED do task.wait(0.1) end
return getgenv().SCRIPT_KEY
