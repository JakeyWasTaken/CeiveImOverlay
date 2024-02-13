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
