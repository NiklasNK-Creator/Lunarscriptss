# How to Make a Module for LunarScripts

## Overview

A module is a hub window that appears in the LunarScripts loader. Each module is a standalone Luau script hosted on GitHub (raw link). When a user clicks your hub in the loader, your script runs via `loadstring`.

## File Structure

Each module is a **single .lua file** — no external loadstrings allowed.

## Template

```lua
--[[
    My Hub Name
    Module for LunarScripts
]]

-- Services (only add what you need)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. Create the window (helpers are global via getgenv)
local gui, Main = MakeWindow("My Hub Name", 340, 360, { showProfile = false, minimizeLetter = "M" })
--                       ^title            ^width ^height  ^no PFP/name         ^minimize button letter

-- 2. Create a ScrollingFrame for buttons
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
local layout = Instance.new("UIListLayout", Panel)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Panel).PaddingTop = UDim.new(0, 6)

-- 3. Add features (helpers take Panel as first arg)

-- Toggle: on/off with dot indicator
MakeToggle(Panel, "Fly", 1, function(on)
    if on then
        -- enable
    else
        -- disable
    end
end)

-- Slider: draggable value
MakeSlider(Panel, "Speed", 2, 1, 100, 50, function(val)
    -- do something with val
end)

-- Label: section header
MakeLabel(Panel, "--- Weapons ---", 3)
```

## Available Helpers (all global)

| Helper | Args | Description |
|--------|------|-------------|
| `MakeWindow(title, w, h, opts)` | `opts.showProfile`, `opts.noClose`, `opts.minimizeLetter` | Creates a draggable window |
| `MakeToggle(panel, name, order, cb)` | `cb(on: boolean)` | On/off button with dot |
| `MakeSlider(panel, name, order, min, max, def, cb)` | `cb(val: number)` | Draggable value slider |
| `MakeLabel(panel, name, order)` | | Section header text |
| `Drag(frame, handle)` | | Makes a frame draggable |
| `Clip(text)` | | Copies text to clipboard |
| `Notify(title, text, dur)` | | Roblox notification |

## MakeWindow Options

```lua
MakeWindow("Title", 340, 360, {
    showProfile = false,   -- false = no PFP/name in topbar (recommended for modules)
    noClose = false,       -- true = X button closes ALL hubs + loader
    minimizeLetter = "M"   -- adds - button, collapses to small square with this letter
})
```

## How to Submit

1. Host your `.lua` file on GitHub
2. Get the **raw link** (click "Raw" button, copy URL)
3. Send the raw link to the LunarScripts team
4. We add it to the `Modules` table in `lunarscript.lua`

Example of what we add:
```lua
{ name = "My Hub", id = "myhub", loader = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/main/hub.lua"))() end },
```

## Rules

- **No external loadstrings** — all code in one file
- **No malicious code** — no stealing, no backdoors
- **Use the helpers** — `MakeToggle`, `MakeSlider`, `MakeLabel`
- **Unique minimizeLetter** — pick one not used yet (current: `U`)
- **Keep it clean** — good UI, readable code

## Tips

- Use `LayoutOrder` numbers to control element order (1, 2, 3...)
- Wrap risky code in `pcall()` to prevent crashes
- Store toggle state in a local variable, not a global
- Test your module standalone before submitting
