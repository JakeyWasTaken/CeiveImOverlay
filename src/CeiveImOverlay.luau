--!strict

--- @class CeiveImOverlay

--- @prop BackFrame Frame
--- @within CeiveImOverlay
--- Root frame which all layers are under, should be parented under a screen gui

--[=[
    @interface Layer
    @within CeiveImOverlay
    .Id string -- The unique Id for this layer
    .Position UDim2 -- The position this layer will be drawn at, relative to the BackFrame
    .CurrentIndentation number -- A number tracking the current indentation level of this layer, reset after each render pass
    .RenderGroup { Element } -- Array of elements which should be drawn in the render pass
]=]

--[=[
    @interface Style
    @within CeiveImOverlay
    .Height number -- Height in pixels
    .TextSize number
    .IndentSize number -- Indent size in pixels
    .Padding number -- Padding between elements in pixels
    .BackgroundTransparency number
    .TextTransparency number
    .BackgroundColor3 Color3
    .TextColor3 Color3
]=]

--[=[
    @interface StyleDiff
    @within CeiveImOverlay
    .Height number? -- Height in pixels
    .TextSize number?
    .IndentSize number? -- Indent size in pixels
    .Padding number? -- Padding between elements in pixels
    .BackgroundTransparency number?
    .TextTransparency number?
    .BackgroundColor3 Color3?
    .TextColor3 Color3?
]=]

--[=[
    @interface Element
    @within CeiveImOverlay
    .IndentationSize number -- Indentation side of this element in pixels
    .Height number -- Height of this element in pixels
    .Padding number -- The amount of padding this element should have after it in pixels
    .TextSize number
    .BackgroundTransparency number
    .TextTransparency number
    .Text string
    .BackgroundColor3 Color3
    .TextColor3 Color3
]=]

local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

type Element = {
    IndentationSize: number,
    Height: number,
    TextSize: number,
    Padding: number,

    BackgroundTransparency: number,
    TextTransparency: number,

    Text: string,
    BackgroundColor3: Color3,
    TextColor3: Color3,
}

export type Layer = {
    Id: string,
    Position: UDim2,

    CurrentIndentation: number,
    RenderGroup: { Element },
}

export type Style = {
    Height: number,
    TextSize: number,
    IndentSize: number,
    Padding: number,

    BackgroundTransparency: number,
    TextTransparency: number,

    BackgroundColor3: Color3,
    TextColor3: Color3,
}

export type StyleDiff = {
    Height: number?,
    TextSize: number?,
    IndentSize: number?,
    Padding: number?,

    BackgroundTransparency: number?,
    TextTransparency: number?,

    BackgroundColor3: Color3?,
    TextColor3: Color3?,
}

export type ImOverlay = {
    new: (UseInset: boolean?) -> CImOverlay,
}

export type CImOverlay = {

    -- --------------------------------- Methods -------------------------------- --

    --- It will first search all current layers for the `Id` provided,
    --- if a layer is not found, one will be created
    ---
    --- **Layers persist between frames**
    ---
    --- @param Id string -- A unique id for this layer
    --- @param CreateAt UDim2 -- If the layer doesn't already exist, when it is created it will be placed at this provided location
    GetLayer: (self: CImOverlay, Id: string, CreateAt: UDim2) -> Layer,

    --- Will set the current layer
    ---
    --- Setting a layer is not required to render, if one is not set, the default layer will be used
    ---
    --- **This does not act as a stack**
    SetActiveLayer: (self: CImOverlay, Layer: Layer) -> (),
    --- Resets the active layer back to the default one
    PopActiveLayer: (self: CImOverlay) -> (),

    GetActiveLayer: (self: CImOverlay) -> Layer,

    --- Will set the style for the default parameters.
    --- This acts as a diff, so you only have to change what you want
    ---
    --- Avoids having to copy the same parameters across a bunch of calls
    PushStyle: (self: CImOverlay, StyleDiff: StyleDiff) -> (),
    PopStyle: (self: CImOverlay) -> (),

    GetActiveStyle: (self: CImOverlay) -> Style,

    Begin: (self: CImOverlay, Text: string, BackgroundColor: Color3?, TextColor: Color3?) -> (),
    Text: (self: CImOverlay, Text: string, BackgroundColor: Color3?, TextColor: Color3?) -> (),
    End:  (self: CImOverlay) -> (),

    --- Renders one frame
    ---
    --- If you are having odd bugs do not call this in a `RenderStepped` loop,
    --- it can cause very odd unexplainable behaviour
    Render: (self: CImOverlay) -> (),

    --- Will connect to RenderStepped and render for you
    ---
    --- Calling `::Render` anytime after this will throw a soft assert
    InitRendering: (self: CImOverlay) -> (),

    --- **DO NOT USE**
    ---
    --- Use either `::Render` or `::InitRendering`
    m_Render: (self: CImOverlay) -> (),
    m_Cleanup: (self: CImOverlay) -> (),
    m_Pool: (self: CImOverlay) -> (),

    -- Theory behind these asserts is, even if you mess up literally everything you don't have to guard a bunch of stuff
    -- and it will just nicely warn at render
    m_SoftAssert: (self: CImOverlay, Condition: any?, Issue: string) -> boolean,
    m_LogIssues: (self: CImOverlay) -> (),

    -- --------------------------------- Members -------------------------------- --

    BackFrame: Frame,

    m_AllLayers: {[string]: Layer},
    m_Issues: { string },

    m_ActiveLayer: Layer?,
    m_DefaultLayer: Layer,

    m_StyleStack: { StyleDiff },
    m_IsAutoRendering: boolean,

    m_ActiveElements: { TextLabel },

    m_LastState: string,
    m_State: string,
}

local Font = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.ExtraBold)
local Pool: { TextLabel } = {}

local function GetElement(
    Text: string,
    TextColor: Color3,
    BackgroundColor: Color3,
    TextSize: number,
    Height: number,
    IndentationSize: number,
    BackgroundTransparency: number,
    TextTransparency: number
)
    if #Pool == 0 then
        -- Construct element
        local Label = Instance.new("TextLabel")
        Label.FontFace = Font
        Label.Text = Text
	    Label.TextColor3 = TextColor
        Label.TextSize = TextSize
        Label.AutomaticSize = Enum.AutomaticSize.X
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.TextTransparency = TextTransparency
        Label.BackgroundTransparency = BackgroundTransparency
        Label.BackgroundColor3 = BackgroundColor
        Label.BorderSizePixel = 0
        Label.AnchorPoint = Vector2.new(0, 0.5)
        Label.Size = UDim2.fromOffset(0, Height)

        local UIPadding = Instance.new("UIPadding")
        UIPadding.PaddingRight = UDim.new(0, 5)
        UIPadding.PaddingLeft = UDim.new(0, 5 + IndentationSize)
        UIPadding.PaddingBottom = UDim.new(0, 2) -- Align the text a bit more centrally
        UIPadding.Parent = Label

        return Label
    end

    -- Repurpose pooled element
    local Label = table.remove(Pool) :: TextLabel
    local UIPadding = Label:FindFirstChild("UIPadding") :: UIPadding

    Label.Text = Text
    Label.TextColor3 = TextColor
    Label.TextTransparency = TextTransparency
    Label.BackgroundColor3 = BackgroundColor
    Label.BackgroundTransparency = BackgroundTransparency
    Label.Size = UDim2.fromOffset(0, Height)

    UIPadding.PaddingLeft = UDim.new(0, 5 + IndentationSize)

    Label.Visible = true

    return Label
end

local function PoolElement(Element: TextLabel)
    if not Element.Visible then -- Already pooled
        return
    end

    Element.Visible = false
    table.insert(Pool, Element)
end

-- ---------------------------------- Class --------------------------------- --

local CImOverlay: CImOverlay = {} :: any
(CImOverlay :: any).__index = CImOverlay

--[=[
    @within CeiveImOverlay

    It will first search all current layers for the `Id` provided,
    if a layer is not found, one will be created

    **Layers persist between frames**

    @param Id string -- A unique id for this layer
    @param CreateAt UDim2 -- If the layer doesn't already exist, when it is created it will be placed at this provided location
]=]
function CImOverlay:GetLayer(Id: string, CreateAt: UDim2): Layer
    if self.m_AllLayers[Id] then
        return self.m_AllLayers[Id]
    end

    local Layer: Layer = {
        Id = Id,
        Position = CreateAt,

        CurrentIndentation = 0,
        RenderGroup = {},
    }

    self.m_AllLayers[Id] = Layer
    return Layer
end

--[=[
    @within CeiveImOverlay

    Will set the current layer

    Setting a layer is not required to render, if one is not set, the default layer will be used

    **This does not act as a stack**
]=]
function CImOverlay:SetActiveLayer(Layer: Layer)
    if self.m_ActiveLayer then
        self:m_SoftAssert(self.m_ActiveLayer.CurrentIndentation == 0, `Not enough ::End calls to layer "{self.m_ActiveLayer.Id}"`)
    end

    -- TODO: assert layer params

    self.m_ActiveLayer = Layer
end

--[=[
    @within CeiveImOverlay

    Resets the active layer back to the default one
]=]
function CImOverlay:PopActiveLayer()
    if self.m_ActiveLayer then
        self:m_SoftAssert(self.m_ActiveLayer.CurrentIndentation == 0, `Not enough ::End calls to layer "{self.m_ActiveLayer.Id}"`)
    end

    self.m_ActiveLayer = nil
end

--- @within CeiveImOverlay
function CImOverlay:GetActiveLayer(): Layer
    return self.m_ActiveLayer or self.m_DefaultLayer
end

--[=[
    @within CeiveImOverlay

    Will set the style for the default parameters.
    This acts as a diff, so you only have to change what you want

    Avoids having to copy the same parameters across a bunch of calls
]=]
function CImOverlay:PushStyle(StyleDiff: StyleDiff)
    -- TODO: assert style params

    table.insert(self.m_StyleStack, StyleDiff)
end

--- @within CeiveImOverlay
function CImOverlay:PopStyle()
    if #self.m_StyleStack == 0 then
        return
    end

    table.remove(self.m_StyleStack)
end

--- @within CeiveImOverlay
function CImOverlay:GetActiveStyle(): Style
    local Style: Style = {
        Height = 13,
        TextSize = 11,
        IndentSize = 20,
        Padding = 2,

        BackgroundTransparency = 0.4,
        TextTransparency = 0,

        BackgroundColor3 = Color3.new(0, 0, 0),
        TextColor3 = Color3.new(1, 1, 1)
    }

    -- Walk up the stack applying diffs
    for _, Diff in self.m_StyleStack do
        for K, V in Diff do
            Style[K] = V
        end
    end

    return Style
end

--- @within CeiveImOverlay
function CImOverlay:Begin(
    Text: string,
    BackgroundColor: Color3?,
    TextColor: Color3?,
    BackgroundTransparency: number?,
    TextTransparency: number?
)
    if self:m_SoftAssert(typeof(Text) == "string", `Expected param Text of type string, got "{typeof(Text)}"`) then
        return
    end

    if self:m_SoftAssert(not BackgroundColor or typeof(BackgroundColor) == "Color3", `Expected param BackgroundColor of type Color3, got "{typeof(Text)}"`) then
        return
    end

    if self:m_SoftAssert(not TextColor or typeof(TextColor) == "Color3", `Expected param TextColor of type Color3, got "{typeof(Text)}"`) then
        return
    end

    if self:m_SoftAssert(not BackgroundTransparency or typeof(BackgroundTransparency) == "number", `Expected param BackgroundTransparency of type number, got "{typeof(Text)}"`) then
        return
    end

    if self:m_SoftAssert(not TextTransparency or typeof(TextTransparency) == "number", `Expected param TextTransparency of type number, got "{typeof(Text)}"`) then
        return
    end

    self:Text(Text, BackgroundColor, TextColor)
    self:GetActiveLayer().CurrentIndentation += 1
end

--- @within CeiveImOverlay
function CImOverlay:Text(
    Text: string,
    BackgroundColor: Color3?,
    TextColor: Color3?,
    BackgroundTransparency: number?,
    TextTransparency: number?
)
    if self:m_SoftAssert(typeof(Text) == "string", `Expected param Text of type string, got "{typeof(Text)}"`) then
        return
    end

    if self:m_SoftAssert(not BackgroundColor or typeof(BackgroundColor) == "Color3", `Expected param BackgroundColor of type Color3, got "{typeof(Text)}"`) then
        return
    end

    if self:m_SoftAssert(not TextColor or typeof(TextColor) == "Color3", `Expected param TextColor of type Color3, got "{typeof(Text)}"`) then
        return
    end

    if self:m_SoftAssert(not BackgroundTransparency or typeof(BackgroundTransparency) == "number", `Expected param BackgroundTransparency of type number, got "{typeof(Text)}"`) then
        return
    end

    if self:m_SoftAssert(not TextTransparency or typeof(TextTransparency) == "number", `Expected param TextTransparency of type number, got "{typeof(Text)}"`) then
        return
    end

    local Layer = self:GetActiveLayer()
    local Style = self:GetActiveStyle()

    local Element: Element = {
        IndentationSize = Layer.CurrentIndentation * Style.IndentSize,
        Height = Style.Height,
        TextSize = Style.TextSize,
        Padding = Style.Padding,

        BackgroundTransparency = BackgroundTransparency or Style.BackgroundTransparency,
        TextTransparency = TextTransparency or Style.TextTransparency,

        Text = Text,
        TextColor3 = TextColor or Style.TextColor3,
        BackgroundColor3 = BackgroundColor or Style.BackgroundColor3,
    }

    table.insert(Layer.RenderGroup, Element)

    local StateString = `{Layer.Id}{Layer.Position.X.Scale}{Layer.Position.X.Offset}{Layer.Position.Y.Scale}{Layer.Position.Y.Offset}`
    for _, V in Element do
        local StringV
        if typeof(V) == "Color3" then
            StringV = `{V.R}{V.G}{V.B}`
        else
            StringV = tostring(V)
        end

        StateString ..= StringV
    end

    self.m_State ..= StateString
end

--- @within CeiveImOverlay
function CImOverlay:End()
    local Layer = self:GetActiveLayer()
    if self:m_SoftAssert(Layer.CurrentIndentation > 0, `Too many calls to ::End`) then
        return
    end

    Layer.CurrentIndentation = math.max(Layer.CurrentIndentation - 1, 0)
end

--[=[
    @within CeiveImOverlay

    Renders one frame

    If you are having odd bugs do not call this in a `RenderStepped` loop,
    it can cause very odd unexplainable behaviour
]=]
function CImOverlay:Render()
    if self:m_SoftAssert(not self.m_IsAutoRendering, `Cannot call ::Render after ::InitRendering`) then
        return
    end

    self:m_Render()
end

--[=[
    @within CeiveImOverlay

    Will connect to RenderStepped and render for you

    Calling `::Render` anytime after this will throw a soft assert
]=]
function CImOverlay:InitRendering()
    if self.m_IsAutoRendering then
        return
    end

    self.m_IsAutoRendering = true
    RunService.Heartbeat:Connect(function()
        self:m_Render()
    end)

    return
end

--[=[
@within CeiveImOverlay
@private

**DO NOT USE**

Use either `::Render` or `::InitRendering`
]=]
function CImOverlay:m_Render()
    self:m_LogIssues()

    if self.m_State == "" then
        self:m_Pool()
        self:m_Cleanup()
        return
    end

    if self.m_LastState == self.m_State then
        self:m_Cleanup()
        return
    end

    self:m_Pool()
    self.m_LastState = self.m_State

    -- Draw each layer
    local function RenderLayer(Layer: Layer)
        local CurrentYOffset = 0

        for i, ElementData in Layer.RenderGroup do
            local Element = GetElement(
                                ElementData.Text,
                                ElementData.TextColor3,
                                ElementData.BackgroundColor3,
                                ElementData.TextSize,
                                ElementData.Height,
                                ElementData.IndentationSize,
                                ElementData.BackgroundTransparency,
                                ElementData.TextTransparency
                            )

            local ElementPosition = Layer.Position + UDim2.fromOffset(0, CurrentYOffset)
            CurrentYOffset += ElementData.Height + ElementData.Padding

            Element.Position = ElementPosition
            Element.ZIndex = #Layer.RenderGroup - i
            Element.Parent = self.BackFrame

            table.insert(self.m_ActiveElements, Element)
        end
    end

    RenderLayer(self.m_DefaultLayer)
    for _, Layer in self.m_AllLayers do
        RenderLayer(Layer)
    end

    self:m_Cleanup()
end

--- @within CeiveImOverlay
--- @private
function CImOverlay:m_Pool()
    for _, Element in self.m_ActiveElements do
        PoolElement(Element)
    end

    table.clear(self.m_ActiveElements)
end

--- @within CeiveImOverlay
--- @private
function CImOverlay:m_Cleanup()
    self.m_State = ""

    local function CleanupLayer(Layer: Layer)
        self:m_SoftAssert(Layer.CurrentIndentation == 0, `Layer "{Layer.Id}" didn't have enough ::End calls`)

        Layer.CurrentIndentation = 0
        table.clear(Layer.RenderGroup)
    end

    CleanupLayer(self.m_DefaultLayer)
    for _, Layer in self.m_AllLayers do
       CleanupLayer(Layer)
    end
end

--- @within CeiveImOverlay
--- @private
function CImOverlay:m_SoftAssert(Condition: any?, Issue: string)
    if Condition then
        return false
    end

    local Traceback = debug.traceback(Issue, 3)
    table.insert(self.m_Issues, Traceback)

    return true
end

--- @within CeiveImOverlay
--- @private
function CImOverlay:m_LogIssues()
    if #self.m_Issues == 0 then
        return
    end

    local Formatted = {}

    for _, Issue in self.m_Issues do
        table.insert(Formatted, `----------------\n\n{Issue}`)
    end

    warn(`[{#self.m_Issues}] ImOverlay issue(s)\n\n{table.concat(Formatted, "\n\n")}`)
    table.clear(self.m_Issues)
end


-- ------------------------------- Constructor ------------------------------ --

local ImOverlay = {}

--[=[
    @within CeiveImOverlay

    When `UseInset` is true an offset on the BackFrame will be applied to avoid the top-bar in ScreenGui's that ignore the gui inset
]=]
function ImOverlay.new(UseInset: boolean?)
    local self: CImOverlay = setmetatable({}, CImOverlay) :: any

    UseInset = (UseInset == nil and true or UseInset)

    self.m_AllLayers = {}

    self.m_ActiveLayer = nil
    self.m_DefaultLayer = {
        Id = "DEFAULT",
        Position = UDim2.fromOffset(0, 0),

        CurrentIndentation = 0,
        RenderGroup = {}
    }

    self.m_StyleStack = {}
    self.m_IsAutoRendering = false

    self.m_ActiveElements = {}
    self.m_Issues = {}

    self.m_LastState = ""
    self.m_State = ""

    -- Make back frame
    local InsetPosition = UDim2.fromOffset(25, 10 + GuiService:GetGuiInset().Y) -- And roblox broke ::GetGuiInset of the first frame of the game
	local InsetSize = UDim2.new(1, -25, 1, -5)

	local DefaultPosition = UDim2.fromOffset(0, 0)
	local DefaultSize = UDim2.fromScale(1, 1)

    self.BackFrame = Instance.new("Frame")
    self.BackFrame.Position = UseInset and InsetPosition or DefaultPosition
    self.BackFrame.Size = UseInset and InsetSize or DefaultSize
    self.BackFrame.BackgroundTransparency = 1
    self.BackFrame.Active = false

    return self
end

return ImOverlay
