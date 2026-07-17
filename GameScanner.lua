--[[
    LunarScripts Game Scanner
    Scans the entire game and dumps info to a file for analysis.
    Run this in Xeno/any executor to get a full game report.
    
    Usage:
        1. Execute this script
        2. It creates "GameScan_<PlaceId>.txt" in your executor workspace
        3. Use the info to build game-specific features
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local GameName = game.PlaceId == 0 and "Unknown" or tostring(game.PlaceId)
local Report = {}
local Indent = "  "

local function Log(str)
    table.insert(Report, str)
end

local function GetDescendantsCount(obj)
    local count = 0
    for _ in ipairs(obj:GetDescendants()) do
        count += 1
    end
    return count
end

local function ScanInstance(obj, depth)
    depth = depth or 0
    if depth > 6 then return end

    local prefix = string.rep(Indent, depth)
    local className = obj.ClassName
    local name = obj.Name

    if className == "Script" or className == "LocalScript" or className == "ModuleScript" then
        local lines = 0
        pcall(function()
            local source = obj.Source
            if source then
                for _ in source:gmatch("\n") do lines += 1 end
            end
        end)
        Log(prefix .. "[" .. className .. "] " .. name .. " (" .. lines .. " lines)")
    elseif className == "RemoteEvent" then
        Log(prefix .. "[RemoteEvent] " .. name)
    elseif className == "RemoteFunction" then
        Log(prefix .. "[RemoteFunction] " .. name)
    elseif className == "UnreliableRemoteEvent" then
        Log(prefix .. "[UnreliableRemoteEvent] " .. name)
    elseif className == "BindableEvent" then
        Log(prefix .. "[BindableEvent] " .. name)
    elseif className == "BindableFunction" then
        Log(prefix .. "[BindableFunction] " .. name)
    elseif className == "ModuleScript" then
        local lines = 0
        pcall(function()
            local source = obj.Source
            if source then
                for _ in source:gmatch("\n") do lines += 1 end
            end
        end)
        Log(prefix .. "[ModuleScript] " .. name .. " (" .. lines .. " lines)")
    end

    for _, child in ipairs(obj:GetChildren()) do
        ScanInstance(child, depth + 1)
    end
end

-- HEADER
Log("============================================")
Log("  LunarScripts Game Scanner")
Log("  Place: " .. (game.PlaceId ~= 0 and game.PlaceId or "Local/Unknown"))
Log("  Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
Log("  Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
Log("  Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S"))
Log("============================================")
Log("")

-- PLAYER INFO
Log("== PLAYER INFO ==")
Log("Username: " .. LocalPlayer.Name)
Log("UserId: " .. LocalPlayer.UserId)
Log("AccountAge: " .. LocalPlayer.AccountAge .. " days")
Log("")

-- GAME STRUCTURE
Log("== TOP-LEVEL SERVICES ==")
for _, svc in ipairs({
    "Workspace", "Players", "Lighting", "ReplicatedStorage",
    "ServerScriptService", "ServerStorage", "StarterGui",
    "StarterPack", "StarterPlayer", "Teams", "SoundService",
    "Chat", "Teams", "TestService"
}) do
    local obj = game:FindFirstChild(svc)
    if obj then
        local childCount = #obj:GetChildren()
        local descCount = GetDescendantsCount(obj)
        Log(svc .. ": " .. childCount .. " children, " .. descCount .. " descendants")
    end
end
Log("")

-- REMOTES
Log("== ALL REMOTES (RemoteEvent / RemoteFunction) ==")
local remotes = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("UnreliableRemoteEvent") then
        local path = obj:GetFullName()
        table.insert(remotes, obj.ClassName .. " | " .. path)
    end
end
table.sort(remotes)
for _, r in ipairs(remotes) do
    Log("  " .. r)
end
Log("Total remotes: " .. #remotes)
Log("")

-- SCRIPTS
Log("== ALL SCRIPTS ==")
local scripts = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("BaseScript") or obj:IsA("ModuleScript") then
        local path = obj:GetFullName()
        local lines = 0
        pcall(function()
            local source = obj.Source
            if source then
                for _ in source:gmatch("\n") do lines += 1 end
            end
        end)
        table.insert(scripts, obj.ClassName .. " | " .. path .. " (" .. lines .. " lines)")
    end
end
table.sort(scripts)
for _, s in ipairs(scripts) do
    Log("  " .. s)
end
Log("Total scripts: " .. #scripts)
Log("")

-- WORKSPACE MAP
Log("== WORKSPACE STRUCTURE (3 levels deep) ==")
ScanInstance(workspace, 0)
Log("")

-- CHARACTERS
Log("== CHARACTER INFO ==")
for _, player in ipairs(Players:GetPlayers()) do
    local char = player.Character
    if char then
        Log(player.Name .. ":")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            Log("  Position: " .. tostring(hrp.Position))
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            Log("  Health: " .. tostring(math.floor(hum.Health)) .. "/" .. tostring(math.floor(hum.MaxHealth)))
            Log("  WalkSpeed: " .. tostring(hum.WalkSpeed))
            Log("  JumpPower: " .. tostring(hum.JumpPower))
            Log("  JumpHeight: " .. tostring(hum.JumpHeight))
        end
        Log("  Children: " .. #char:GetChildren())
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                Log("    " .. part.Name .. " (" .. part.ClassName .. ") CanCollide=" .. tostring(part.CanCollide))
            elseif part:IsA("Tool") then
                Log("    [Tool] " .. part.Name)
            end
        end
    end
end
Log("")

-- LIGHTING / FOG / ATMOSPHERE (for ESP suggestions)
Log("== LIGHTING / VISIBILITY ==")
local Light = game:GetService("Lighting")
Log("Brightness: " .. tostring(Light.Brightness))
Log("Ambient: " .. tostring(Light.Ambient))
Log("OutdoorAmbient: " .. tostring(Light.OutdoorAmbient))
Log("FogEnd: " .. tostring(Light.FogEnd))
Log("GlobalShadows: " .. tostring(Light.GlobalShadows))
for _, effect in ipairs(Light:GetChildren()) do
    Log("  [Effect] " .. effect.Name .. " (" .. effect.ClassName .. ")")
end
Log("")

-- TELEPORT / SERVER INFO
Log("== SERVER INFO ==")
Log("GameId: " .. tostring(game.GameId))
Log("PlaceId: " .. tostring(game.PlaceId))
Log("PlaceVersion: " .. tostring(game.PlaceVersion))
Log("JobId: " .. tostring(game.JobId))
Log("ServerType: " .. tostring(game:GetService("NetworkClient") and "Client" or "Unknown"))
Log("")

-- OUTPUT
Log("============================================")
Log("  END OF SCAN")
Log("============================================")

-- SAVE FILE
local content = table.concat(Report, "\n")
local fileName = "GameScan_" .. tostring(game.PlaceId) .. ".txt"

if writefile then
    writefile(fileName, content)
    print("[LunarScripts] Scanner saved: " .. fileName)
    print("[LunarScripts] Found " .. #remotes .. " remotes, " .. #scripts .. " scripts")
else
    warn("[LunarScripts] writefile not available, printing to console:")
    print(content)
end
