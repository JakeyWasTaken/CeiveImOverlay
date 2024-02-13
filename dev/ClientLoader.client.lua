local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local TestsFolder = script.Parent.Parent.Tests
local RuntimeTests = TestsFolder.Runtime

local CeiveImOverlay = require(ReplicatedStorage:WaitForChild("CeiveImOverlay"))
local ImOverlay = CeiveImOverlay.new()

local ScreenGui = PlayerGui:WaitForChild("Gui")
ScreenGui.IgnoreGuiInset = true

ImOverlay.BackFrame.Parent = ScreenGui

local TimeBetweenTest = 5

local Tests = {}
local State = {}
local TestIndex
local ActiveTest

for _, Test in RuntimeTests:GetChildren() do
    table.insert(Tests, {Test.Name, require(Test)})
end

TestIndex = 1
ActiveTest = Tests[1]

RunService.RenderStepped:Connect(function(dt)
    State = {
        DeltaTime = dt
    }

    -- if ActiveTest then
    --     ImOverlay:Begin("Running Tests")
    --     ImOverlay:Text(`Time Between Test: {TimeBetweenTest}s`)
    --     ImOverlay:Text(`Current Test: {ActiveTest[1]}`)
    --     ImOverlay:Text(`Next Test: {Tests[TestIndex + 1] and Tests[TestIndex + 1][1] or "None"}`)
    --     ImOverlay:Begin("Test Container")

    --     ActiveTest[2](ImOverlay, State)

    --     ImOverlay:End()
    --     ImOverlay:End()
    -- else
    --     ImOverlay:Text("Tests completed")
    -- end
    ImOverlay:Text("Hello World!")

    ImOverlay:Render()
end)

while task.wait(TimeBetweenTest) do
    if Tests[TestIndex + 1] then
        TestIndex += 1
        ActiveTest = Tests[TestIndex]
    else
        ActiveTest = nil
    end
end
