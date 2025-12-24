# Intro
CeiveImOverlay is a quick and easy way of creating a debug overlay for miscellaneous information. No need to create your own ui or keep track of connections, simply call 3 functions and you have all the information you could ever need.

The BackFrame has to be re-parented to a screen gui for CeiveImOverlay to work.

# Examples

A basic integration of CeiveImOverlay would be as follows:

```lua
local RunService = game:GetService("RunService")
local CeiveImOverlay = require(...)
local ImOverlay = CeiveImOverlay.new()

ImOverlay.BackFrame.Parent = AScreenGui

-- During testing, I found using RenderStepped could cause some really odd issues.
-- So probably use Heartbeat
RunService.Heartbeat:Connect(function()
    ImOverlay:Text("Hello World!")

    ImOverlay:Render()
end)
```
Which would result in this:

<div align="center">
    <img src="https://github.com/JakeyWasTaken/CeiveImOverlay/blob/main/docs/assets/basic_example.png?raw=true"/>
</div>

---

A more complex integration could look something like this:
```lua
local RunService = game:GetService("RunService")
local CeiveImOverlay = require(...)
local ImOverlay = CeiveImOverlay.new()

ImOverlay.BackFrame.Parent = AScreenGui

-- During testing, I found using RenderStepped could cause some really odd issues.
-- So probably use Heartbeat
RunService.Heartbeat:Connect(function()
    for i = 1, 10 do
        ImOverlay:Begin(`Recursive {i}`)
    end

    ImOverlay:Text("Im ontop of the world!")

    for _ = 1, 10 do
        ImOverlay:End()
    end

    ImOverlay:Render()
end)
```
Which would result in this:

<div align="center">
    <img src="https://github.com/JakeyWasTaken/CeiveImOverlay/blob/main/docs/assets/complex_example.png?raw=true"/>
</div>

---

You can also have multiple layers at different locations:
```lua
local RunService = game:GetService("RunService")
local CeiveImOverlay = require(...)
local ImOverlay = CeiveImOverlay.new()

ImOverlay.BackFrame.Parent = AScreenGui

-- During testing, I found using RenderStepped could cause some really odd issues.
-- So probably use Heartbeat
RunService.Heartbeat:Connect(function()
    for i = 1, 10 do
        ImOverlay:Begin(`Recursive {i}`)
    end

    ImOverlay:Text("Im ontop of the world!")

    for _ = 1, 10 do
        ImOverlay:End()
    end

    -- Layers persist over frames, so this could be constructed anywhere
    -- if the layer id already exists, it will just return the pre-existing one
    local MyCoolLayer = ImOverlay:GetLayer("MyCoolLayer", UDim2.new(0.5, 0.15))

    ImOverlay:SetActiveLayer(MyCoolLayer)

    ImOverlay:Begin("My")
        ImOverlay:Begin("Cool")
            ImOverlay:Begin("Layer!!")
            ImOverlay:End()
        ImOverlay:End()
    ImOverlay:End()

    ImOverlay:PopActiveLayer()

    ImOverlay:Render()
end)
```

Which would result in this:

<div align="center">
    <img src="https://github.com/JakeyWasTaken/CeiveImOverlay/blob/main/docs/assets/layer_example.png?raw=true"/>
</div>

---

There's a bunch of styling options to help distinguish certain data and to fit a lot of use cases.

For example, when tests are running we have an extra layer to show some info about every element currently rendering in the default layer, it has some custom styling to be compact as to fit more data.

<div align="center">
    <img src="https://github.com/JakeyWasTaken/CeiveImOverlay/blob/main/docs/assets/running_tests.png?raw=true"/>
</div>

---

Wally: https://wally.run/package/jakeywastaken/ceiveimoverlay
Releases: https://github.com/JakeyWasTaken/CeiveImOverlay/releases
You can find the demo place here: https://www.roblox.com/games/16359051355/CeiveImOverlay
