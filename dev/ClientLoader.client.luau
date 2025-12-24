task.wait(.25) -- Make ::GetGuiInset work

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

RunService.Heartbeat:Connect(function(dt)
    State = {
        DeltaTime = dt
    }

    if ActiveTest then
        ImOverlay:Begin("Running Tests")
        ImOverlay:Text(`Time Between Test: {TimeBetweenTest}s`)
        ImOverlay:Text(`Current Test: {ActiveTest[1]}`)
        ImOverlay:Text(`Next Test: {Tests[TestIndex + 1] and Tests[TestIndex + 1][1] or "None"}`)
        ImOverlay:Begin("Test Container")

        ActiveTest[2](ImOverlay, State)

        ImOverlay:End()
        ImOverlay:End()

    else
        ImOverlay:Text("Tests completed, restarting")
    end

    do
        local dbg = ImOverlay:GetLayer("Debug", UDim2.fromScale(0.5, 0))

        ImOverlay:SetActiveLayer(dbg)

        ImOverlay:PushStyle({BackgroundTransparency = 0, Padding = 0})
        ImOverlay:Begin("Default layer elements")
        for i, Element in ImOverlay.m_DefaultLayer.RenderGroup do
            ImOverlay:Begin(`Element {i}`)
            ImOverlay:Text(`Text: {Element.Text}`)
            ImOverlay:Text(`BackgroundColor3: {Element.BackgroundColor3}`)
            ImOverlay:Text(`TextColor3: {Element.TextColor3}`)
            ImOverlay:Text(`IndentationSize: {Element.IndentationSize}`)
            ImOverlay:Text(`Height: {Element.Height}`)
            ImOverlay:Text(`TextSize: {Element.TextSize}`)
            ImOverlay:End()
        end
        ImOverlay:End()
        ImOverlay:PopStyle()

        ImOverlay:PopActiveLayer()
    end

    ImOverlay:Render()
end)

while task.wait(TimeBetweenTest) do
    if Tests[TestIndex + 1] then
        TestIndex += 1
        ActiveTest = Tests[TestIndex]
    elseif ActiveTest and not Tests[TestIndex + 1] then
        ActiveTest = nil
    else
        TestIndex = 1
        ActiveTest = Tests[TestIndex]
    end
end
