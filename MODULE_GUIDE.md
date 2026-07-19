# How to Make a Module for LunarScripts v10

## Overview

A module is a hub window that appears in the LunarScripts loader. Each module is a standalone Luau script hosted on GitHub (raw link). When a user clicks your hub in the loader, your script runs via `loadstring`.

## File Structure

Each module is a **single .lua file** — no external loadstrings allowed.

## Template

```lua
--[[
    My Hub Name
    Module for LunarScripts v10
]]

-- Services (only add what you need)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. Create the window (helpers are global via getgenv)
--    MakeWindow now returns 3 values: gui, Main, topH
local gui, Main, topH = MakeWindow("My Hub Name", 290, 400, { showProfile = false, minimizeLetter = "M" })
--                            ^title            ^width ^height  ^no PFP/name         ^minimize button letter

-- 2. Create a scroll panel (or use the MakePanel helper if available)
local Panel = Instance.new("ScrollingFrame")
Panel.Size = UDim2.new(1, -12, 1, -(topH + 8))
Panel.Position = UDim2.new(0, 6, 0, topH + 4)
Panel.BackgroundTransparency = 1
Panel.BorderSizePixel = 0
Panel.ScrollBarThickness = 2
Panel.ScrollBarImageColor3 = Color3.fromRGB(90, 50, 180)
Panel.CanvasSize = UDim2.new(0, 0, 0, 0)
Panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
Panel.ZIndex = 3
Panel.Parent = Main
local layout = Instance.new("UIListLayout", Panel)
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", Panel)
pad.PaddingTop = UDim.new(0, 3)
pad.PaddingLeft = UDim.new(0, 2)
pad.PaddingRight = UDim.new(0, 2)
pad.PaddingBottom = UDim.new(0, 6)

-- 3. Add features

-- Label: section header (auto-uppercased)
MakeLabel(Panel, "My Features", 1)

-- Toggle: on/off with animated sliding knob
MakeToggle(Panel, "Fly", 2, function(on)
    if on then
        -- enable
    else
        -- disable
    end
end)

-- Slider: draggable value
MakeSlider(Panel, "Speed", 3, 1, 100, 50, function(val)
    -- do something with val
end)

-- Button: clickable action
MakeButton(Panel, "Do Something", 4, function()
    -- action
end)
```

## Available Helpers (all global)

| Helper | Args | Returns | Description |
|--------|------|---------|-------------|
| `MakeWindow(title, w, h, opts)` | `opts.showProfile`, `opts.noClose`, `opts.minimizeLetter` | `gui, Main, topH` | Draggable window with monkey watermark |
| `MakeToggle(panel, name, order, cb)` | `cb(on: boolean)` | `TextButton` | Animated toggle switch |
| `MakeSlider(panel, name, order, min, max, def, cb)` | `cb(val: number)` | `Frame` | Draggable value slider |
| `MakeLabel(panel, name, order)` | | `TextLabel` | Section header (auto-uppercased) |
| `MakeButton(panel, name, order, cb)` | `cb()` | `TextButton` | Accent-colored action button |
| `Drag(frame, handle)` | | | Makes a frame draggable |

## MakeWindow Options

```lua
local gui, Main, topH = MakeWindow("Title", 290, 400, {
    showProfile = false,   -- false = no PFP/name in topbar (recommended for modules)
    noClose = false,       -- true = X button closes ALL hubs + loader
    minimizeLetter = "M"   -- adds - button, collapses to small pill with this letter
})
-- topH is the topbar height in pixels, use it to position content below the bar
```

**Note:** `MakeWindow` now returns `topH` as a third value. Use it to position your scroll panel:
```lua
Panel.Position = UDim2.new(0, 6, 0, topH + 4)
Panel.Size = UDim2.new(1, -12, 1, -(topH + 8))
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
- **Use the helpers** — `MakeToggle`, `MakeSlider`, `MakeLabel`, `MakeButton`
- **Unique minimizeLetter** — pick one not used yet (currently used: `U` = Universal Hub, `H` = Loader)
- **Keep it clean** — good UI, readable code

## Tips

- Use `LayoutOrder` numbers to control element order (1, 2, 3...)
- Wrap risky code in `pcall()` to prevent crashes
- Store toggle state in a local variable, not a global
- All helpers return their UI instance so you can modify them later
- Windows open/close with smooth scale animations automatically
- Every window has the monkey watermark background built in
- Test your module standalone before submitting
