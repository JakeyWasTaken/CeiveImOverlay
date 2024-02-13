# CeiveImOverlay
CeiveImOverlay is a quick and easy way of creating a debug overlay for miscellaneous information. No need to create your own ui or keep track of connections, simply call 3 functions and you have all the information you could ever need.

A basic integration of CeiveImOverlay would be as follows:

```lua
local RunService = game:GetService("RunService")
local CeiveImOverlay = require(...)
local ImOverlay = CeiveImOverlay.new()

ImOverlay.BackFrame.Parent = AScreenGui

-- Could be heartbeat or render stepped, doesnt really matter.
RunService.RenderStepped:Connect(function()
    ImOverlay:Text("Hello World!")

    ImOverlay:Render()
end)
```
Which would result in this:

<div align="center">
    <img src="https://github.com/JakeyWasTaken/CeiveImOverlay/blob/main/docs/assets/basic_example.png?raw=true"/>
</div>

A more complex integration could look something like this:
```lua
local RunService = game:GetService("RunService")
local CeiveImOverlay = require(...)
local ImOverlay = CeiveImOverlay.new()

ImOverlay.BackFrame.Parent = AScreenGui

-- Could be heartbeat or render stepped, doesnt really matter.
RunService.RenderStepped:Connect(function()
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

Wally: https://wally.run/package/jakeywastaken/ceiveimoverlay<br/>
Releases: https://github.com/JakeyWasTaken/CeiveImOverlay/releases<br/>
You can find the demo place here: https://www.roblox.com/games/16359051355/CeiveImOverlay
