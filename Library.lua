local ImportGlobals
local ClosureBindings = {
    function()
        local wax, script, require = ImportGlobals(1)

        return (function(...)
            game:GetService('HttpService')

            local root = script
            local Components = root.components
            local Packages = script.packages
            local Fusion = require(Packages.fusion)
            local States = require(Packages.states)
            local ElementsTable = require(script.Elements)
            local Children = Fusion.Children
            local ForPairs = Fusion.ForPairs
            local New = Fusion.New
            local Observer = Fusion.Observer
            local Utils = script.utils

            require(Utils.unwrap)

            local Library = {
                Version = '1.0.0',
                States = States,
                Options = {},
                Connections = {},
                Window = nil,
                Unloaded = false,
                MinimizeKeybind = nil,
                GUI = nil,
            }

            States.Library:set(Library)

            local Elements = {}

            Elements.__index = Elements

            function Elements.__namecall(_, Key, ...)
                if Elements[Key] then
                    return Elements[Key](...)
                end

                error(string.format('Invalid method call: %s', Key))
            end

            local initElementComponent = function(
                ElementComponent,
                Container,
                Type,
                ScrollFrame
            )
                ElementComponent.Container = Container
                ElementComponent.Type = Type
                ElementComponent.ScrollFrame = ScrollFrame
                ElementComponent.Library = Library
            end

            for _, ElementComponent in ipairs(ElementsTable)do
                Elements['Add' .. ElementComponent.__type] = function(
                    self,
                    Idx,
                    Config
                )
                    initElementComponent(ElementComponent, self.Container, self.Type, self.ScrollFrame)

                    return ElementComponent:New(Idx, Config)
                end
            end

            States.Elements:set(Elements)

            function Library:CreateWindow(Config)
                assert(Config.Title, '[WINDOW] Missing Title')
                assert(Config.Title, '[WINDOW] Missing Tag')

                if Library.Window then
                    error('[WINDOW] Window already exists')

                    return
                end
                if not Library.GUI then
                    if Config.Debug then
                        local GUI = New('Frame')({
                            Name = 'Frame',
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromScale(1, 1),
                            Parent = Config.Parent or game.CoreGui or game.PlayerGui,
                            [Children] = {
                                ForPairs(States.Objects, function(index, value)
                                    return index, value
                                end, Fusion.cleanup),
                            },
                        })

                        Library.GUI = GUI
                    else
                        local ProtectGui = protectgui or (syn and syn.protect_gui) or function(
                        ) end
                        local GUI = New('ScreenGui')({
                            Parent = game.CoreGui or Config.Parent,
                            [Children] = {
                                ForPairs(States.Objects, function(index, value)
                                    return index, value
                                end, Fusion.cleanup),
                            },
                        })

                        ProtectGui(GUI)

                        Library.GUI = GUI
                    end
                end

                Library.MinimizeKey = Config.MinimizeKey or Enum.KeyCode.LeftControl
                Library.Theme = Config.Theme or 'Dark'

                local Window = require(Components.window.window)(Config)

                Library.Window = Window

                return Window
            end
            function Library:SetTheme(theme)
                States.Theme:set(theme)
            end
            function Library:Destroy()
                print('Destroying')

                if Library.Connections then
                    for _, v in pairs(Library.Connections)do
                        v:Disconnect()
                    end
                end

                Library.Unloaded = true

                if Library.GUI then
                    Library.GUI:Destroy()

                    Library.GUI = nil
                end
            end

            local onDestroyObserver = Observer(States.toDestroy)

            onDestroyObserver:onChange(function()
                Library:Destroy()
            end)

            function Library:Notify(config)
                print(`{config.Title} - {config.Content}: {config.SubContent}`)
            end

            pcall(function()
                getgenv().Kyanos = Library
            end)

            return Library
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(2)

        return (function(...)
            local Elements = {}

            for _, Theme in next, script:GetChildren()do
                table.insert(Elements, require(Theme))
            end

            return Elements
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(3)

        return (function(...)
            local Utils = script.Parent.Parent.utils
            local animate = require(Utils.animate)
            local colorUtils = require(Utils.color3)
            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local safeCallback = require(Utils.safecallback)
            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)
            require(Packages.states)

            local Children = Fusion.Children
            local _ = Fusion.Computed
            local _ = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local _ = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Button'

            function Element:New(props)
                assert(props.Title, '[BUTTON] Missing Title')
                assert(props.Style, '[BUTTON] Missing Style')

                local Button = {
                    Callback = props.Callback or function(_) end,
                    Style = string.lower(props.Style),
                    Type = 'Button',
                }
                local isHovering = Value(false)
                local isHeldDown = Value(false)

                Button.Root = New('Frame')({
                    Name = 'Button',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    [Children] = {
                        New('TextButton')({
                            Name = 'TextButton',
                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            Text = props.Title,
                            TextColor3 = animate(function()
                                local state = Button.Style

                                if state == 'default' then
                                    if unwrap(isHovering) then
                                        return colorUtils.lightenRGB(unwrap(Theme.tertiary_text), 35)
                                    end

                                    return unwrap(Theme.tertiary_text)
                                else
                                    if unwrap(isHovering) then
                                        return Color3.fromRGB(255, 255, 255)
                                    end

                                    return colorUtils.lightenRGB(unwrap(Theme.text), 10)
                                end
                            end, 25, 1),
                            TextSize = 14,
                            BackgroundTransparency = animate(function()
                                if unwrap(isHeldDown) then
                                    return 0.1
                                end

                                return 0
                            end, 25, 1),
                            BackgroundColor3 = animate(function()
                                local color
                                local state = Button.Style

                                if state == 'primary' then
                                    color = unwrap(Theme.accent)
                                elseif state == 'danger' then
                                    color = unwrap(Theme.danger)
                                elseif state == 'warning' then
                                    color = unwrap(Theme.warning)
                                else
                                    color = unwrap(Theme.secondary_background)
                                end
                                if unwrap(isHovering) then
                                    return colorUtils.lightenRGB(color, 10)
                                end
                                if unwrap(isHeldDown) then
                                    return colorUtils.darkenRGB(color, 15)
                                end

                                return color
                            end, 25, 1),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = animate(function()
                                if unwrap(isHeldDown) then
                                    return UDim2.new(1, -4, 0, 28)
                                end

                                return UDim2.new(1, 0, 0, 28)
                            end, 25, 1),
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = animate(function()
                                if unwrap(isHeldDown) then
                                    return UDim2.new(0.5, 0, 0, 2)
                                end

                                return UDim2.new(0.5, 0, 0, 0)
                            end, 25, 1),
                            [Children] = {
                                New('UICorner')({
                                    Name = 'UICorner',
                                    CornerRadius = UDim.new(0, 4),
                                }),
                                New('UIStroke')({
                                    Name = 'UIStroke',
                                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                    Color = animate(function()
                                        local color
                                        local state = Button.Style

                                        if state == 'primary' then
                                            color = unwrap(Theme.accent)
                                        elseif state == 'danger' then
                                            color = unwrap(Theme.danger)
                                        elseif state == 'warning' then
                                            color = unwrap(Theme.warning)
                                        else
                                            color = unwrap(Theme.secondary_background)
                                        end
                                        if unwrap(isHovering) then
                                            return colorUtils.lightenRGB(color, 50)
                                        end

                                        return colorUtils.lightenRGB(color, 35)
                                    end, 25, 1),
                                    Transparency = 0.25,
                                    Thickness = 1,
                                }),
                                New('UIPadding')({
                                    Name = 'UIPadding',
                                    PaddingBottom = UDim.new(0, 8),
                                    PaddingLeft = UDim.new(0, 16),
                                    PaddingRight = UDim.new(0, 16),
                                    PaddingTop = UDim.new(0, 8),
                                }),
                                New('UIGradient')({
                                    Name = 'UIGradient',
                                    Rotation = 90,
                                    Transparency = NumberSequence.new({
                                        NumberSequenceKeypoint.new(0, 0),
                                        NumberSequenceKeypoint.new(1, 0.125),
                                    }),
                                }),
                            },
                            [OnEvent('Activated')] = function()
                                safeCallback(function()
                                    Button.Callback()
                                end)
                            end,
                            [OnEvent('InputEnded')] = function(Input)
                                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                    isHeldDown:set(false)
                                end
                            end,
                            [OnEvent('InputBegan')] = function(Input)
                                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                    isHeldDown:set(true)
                                end
                            end,
                            [OnEvent('MouseEnter')] = function()
                                isHovering:set(true)
                            end,
                            [OnEvent('MouseLeave')] = function()
                                isHovering:set(false)
                                isHeldDown:set(false)
                            end,
                        }),
                    },
                })

                insertItem(self.Container, Button.Root)

                return Button
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(4)

        return (function(...)
            local Utils = script.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)

            require(Utils.safecallback)

            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local _ = Fusion.ForPairs
            local Observer = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local UserInputService = game:GetService('UserInputService')
            local _ = game:GetService('Workspace').CurrentCamera

            game:GetService('RunService')

            local Element = {}

            Element.__index = Element
            Element.__type = 'Colorpicker'

            function Element:New(Idx, props)
                local Colorpicker = {
                    Title = Value(props.Title) or nil,
                    Description = Value(props.Description) or nil,
                    Value = Value(props.Default or Color3.fromRGB(255, 255, 255)),
                    Type = 'Colorpicker',
                    Callback = props.Callback or function() end,
                    Changed = function() end,
                    Opened = Value(false),
                    H = nil,
                    S = nil,
                    V = nil,
                }
                local sliderDragging = Value(false)
                local hsvDragging = Value(false)
                local H, S, V = unwrap(Colorpicker.Value):ToHSV()

                Colorpicker.H = H
                Colorpicker.S = S
                Colorpicker.V = V

                local Root = Value()

                Value()

                local ColorpickerFrame = Value()
                local Holder = Value()
                local HSV = Value()
                local HSVDrag = Value()
                local Slider = Value()
                local SliderDrag = Value()
                local HexRGBContainer = Value()
                local Hex = Value()
                local RGB = Value()
                local Submit = Value()

                Value()
                Value()
                Value()

                local Visualize = Value()

                Value(Color3.fromHSV(Colorpicker.H, 1, 1))

                local SubmitColor = Value(Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V))
                local updateAssetsColors = function()
                    unwrap(HSV).BackgroundColor3 = Color3.fromHSV(Colorpicker.H, 1, 1)
                    unwrap(Submit).BackgroundColor3 = Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V)
                    unwrap(Hex).Text = Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V):ToHex()
                    unwrap(RGB).Text = string.format('%d, %d, %d', unwrap(Submit).BackgroundColor3.R * 255, unwrap(Submit).BackgroundColor3.G * 255, unwrap(Submit).BackgroundColor3.B * 255)
                end
                local updateDragPositions = function()
                    unwrap(SliderDrag).Position = UDim2.new(Colorpicker.H, 0, 0.5, 0)
                    unwrap(HSVDrag).Position = UDim2.new(Colorpicker.S, 0, 1 - Colorpicker.V, 0)
                end
                local RecalculatePickerPosition = function()
                    local visualizerPos = unwrap(Visualize).AbsolutePosition
                    local visualizerSize = unwrap(Visualize).AbsoluteSize
                    local picker = unwrap(ColorpickerFrame)

                    picker.Position = UDim2.fromOffset(visualizerPos.X, visualizerPos.Y + visualizerSize.Y + 5)
                end

                Colorpicker.Picker = New'TextButton'{
                    [Ref] = ColorpickerFrame,
                    Name = 'Colorpicker',
                    BackgroundColor3 = Theme.background,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(241, 0),
                    ZIndex = 9999,
                    Visible = Colorpicker.Opened,
                    Parent = unwrap(States.Library).GUI,
                    [Children] = {
                        New'UICorner'{
                            Name = 'UICorner',
                            CornerRadius = UDim.new(0, 4),
                        },
                        New'UIStroke'{
                            Name = 'UIStroke',
                            Color = Theme.stroke,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        },
                        New'Frame'{
                            [Ref] = Holder,
                            Name = 'Holder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 9999,
                            [Children] = {
                                New'ImageLabel'{
                                    [Ref] = HSV,
                                    Name = 'HSV',
                                    Image = 'rbxassetid://4155801252',
                                    BackgroundColor3 = Color3.fromRGB(255, 138, 21),
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromScale(0.0928, 0.0357),
                                    Size = UDim2.new(1, 0, 0, 140),
                                    ZIndex = 9999,
                                    [Children] = {
                                        New'ImageButton'{
                                            [Ref] = HSVDrag,
                                            Name = 'Drag',
                                            Image = 'http://www.roblox.com/asset/?id=4805639000',
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(27, 42, 53),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromScale(0.5, 0.5),
                                            Size = UDim2.fromOffset(20, 20),
                                            ZIndex = 9999,
                                            [OnEvent('InputBegan')] = function(
                                                input
                                            )
                                                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                                    hsvDragging:set(true)

                                                    local inputChanged

                                                    inputChanged = UserInputService.InputChanged:Connect(function(
                                                        input
                                                    )
                                                        if hsvDragging:get() and input.UserInputType == Enum.UserInputType.MouseMovement then
                                                            local percentX = math.clamp((input.Position.X - unwrap(HSV).AbsolutePosition.X) / unwrap(HSV).AbsoluteSize.X, 0, 1)
                                                            local percentY = math.clamp((input.Position.Y - unwrap(HSV).AbsolutePosition.Y) / unwrap(HSV).AbsoluteSize.Y, 0, 1)

                                                            Colorpicker.S = percentX
                                                            Colorpicker.V = 1 - percentY
                                                            unwrap(HSVDrag).Position = UDim2.new(percentX, 0, percentY, 0)

                                                            updateAssetsColors()
                                                            updateDragPositions()
                                                        end
                                                    end)

                                                    local inputEnded

                                                    inputEnded = UserInputService.InputEnded:Connect(function(
                                                        input
                                                    )
                                                        if hsvDragging:get() and input.UserInputType == Enum.UserInputType.MouseButton1 then
                                                            inputChanged:Disconnect()
                                                            inputEnded:Disconnect()
                                                            hsvDragging:set(false)
                                                        end
                                                    end)

                                                    table.insert(unwrap(States.Library).Connections, inputChanged)
                                                    table.insert(unwrap(States.Library).Connections, inputEnded)
                                                end
                                            end,
                                        },
                                        New'UICorner'{
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 4),
                                        },
                                        New'UIStroke'{
                                            Name = 'UIStroke',
                                            Color = Theme.stroke,
                                        },
                                    },
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 10),
                                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                },
                                New'UIPadding'{
                                    Name = 'UIPadding',
                                    PaddingLeft = UDim.new(0, 10),
                                    PaddingRight = UDim.new(0, 10),
                                    PaddingTop = UDim.new(0, 10),
                                },
                                New'Frame'{
                                    [Ref] = Slider,
                                    Name = 'Slider',
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BorderColor3 = Color3.fromRGB(27, 42, 53),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromScale(0.0253, 0.744),
                                    Size = UDim2.new(1, 0, 0, 18),
                                    ZIndex = 9999,
                                    [Children] = {
                                        New'UIGradient'{
                                            Name = 'UIGradient',
                                            Color = ColorSequence.new({
                                                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                                                ColorSequenceKeypoint.new(0.0557, Color3.fromRGB(255, 85, 0)),
                                                ColorSequenceKeypoint.new(0.111, Color3.fromRGB(255, 170, 0)),
                                                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(254, 255, 0)),
                                                ColorSequenceKeypoint.new(0.223, Color3.fromRGB(169, 255, 0)),
                                                ColorSequenceKeypoint.new(0.279, Color3.fromRGB(84, 255, 0)),
                                                ColorSequenceKeypoint.new(0.334, Color3.fromRGB(0, 255, 1)),
                                                ColorSequenceKeypoint.new(0.39, Color3.fromRGB(0, 255, 87)),
                                                ColorSequenceKeypoint.new(0.446, Color3.fromRGB(0, 255, 172)),
                                                ColorSequenceKeypoint.new(0.501, Color3.fromRGB(0, 253, 255)),
                                                ColorSequenceKeypoint.new(0.557, Color3.fromRGB(0, 168, 255)),
                                                ColorSequenceKeypoint.new(0.613, Color3.fromRGB(0, 82, 255)),
                                                ColorSequenceKeypoint.new(0.669, Color3.fromRGB(3, 0, 255)),
                                                ColorSequenceKeypoint.new(0.724, Color3.fromRGB(88, 0, 255)),
                                                ColorSequenceKeypoint.new(0.78, Color3.fromRGB(173, 0, 255)),
                                                ColorSequenceKeypoint.new(0.836, Color3.fromRGB(255, 0, 251)),
                                                ColorSequenceKeypoint.new(0.891, Color3.fromRGB(255, 0, 166)),
                                                ColorSequenceKeypoint.new(0.947, Color3.fromRGB(255, 0, 81)),
                                                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                                            }),
                                        },
                                        New'UICorner'{
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 4),
                                        },
                                        New'ImageButton'{
                                            [Ref] = SliderDrag,
                                            Name = 'Drag',
                                            Image = 'http://www.roblox.com/asset/?id=4805639000',
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(27, 42, 53),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromScale(0.5, 0.5),
                                            Size = UDim2.fromOffset(20, 20),
                                            ZIndex = 9999,
                                            [OnEvent'InputBegan'] = function(
                                                Input
                                            )
                                                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                                    sliderDragging:set(true)

                                                    local inputChanged

                                                    inputChanged = UserInputService.InputChanged:Connect(function(
                                                        input
                                                    )
                                                        if sliderDragging:get() and input.UserInputType == Enum.UserInputType.MouseMovement then
                                                            local percentX = math.clamp((input.Position.X - unwrap(Slider).AbsolutePosition.X) / unwrap(Slider).AbsoluteSize.X, 0, 1)

                                                            Colorpicker.H = percentX
                                                            unwrap(SliderDrag).Position = UDim2.new(percentX, 0, 0.5, 0)

                                                            updateAssetsColors()
                                                        end
                                                    end)

                                                    local inputEnded

                                                    inputEnded = UserInputService.InputEnded:Connect(function(
                                                        input
                                                    )
                                                        if sliderDragging:get() and input.UserInputType == Enum.UserInputType.MouseButton1 then
                                                            inputChanged:Disconnect()
                                                            inputEnded:Disconnect()
                                                            sliderDragging:set(false)
                                                        end
                                                    end)

                                                    table.insert(unwrap(States.Library).Connections, inputChanged)
                                                    table.insert(unwrap(States.Library).Connections, inputEnded)
                                                end
                                            end,
                                        },
                                    },
                                },
                                New'Frame'{
                                    [Ref] = HexRGBContainer,
                                    Name = 'HEXRGB',
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Size = UDim2.fromScale(1, 0),
                                    ZIndex = 9999,
                                    [Children] = {
                                        New'UIListLayout'{
                                            Name = 'UIListLayout',
                                            Padding = UDim.new(0, 6),
                                            FillDirection = Enum.FillDirection.Horizontal,
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                        },
                                        New'TextBox'{
                                            [Ref] = Hex,
                                            Name = 'HEX',
                                            CursorPosition = -1,
                                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                            PlaceholderColor3 = Theme.tertiary_text,
                                            PlaceholderText = 'HEX',
                                            Text = '',
                                            TextColor3 = Theme.secondary_text,
                                            TextSize = 14,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Size = UDim2.new(0.5, -3, 0, 25),
                                            ZIndex = 9999,
                                            [Children] = {
                                                New'UIStroke'{
                                                    Name = 'UIStroke',
                                                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                                    Color = Theme.stroke,
                                                },
                                                New'UICorner'{
                                                    Name = 'UICorner',
                                                    CornerRadius = UDim.new(0, 2),
                                                },
                                            },
                                            [OnEvent'FocusLost'] = function()
                                                if string.match(unwrap(Hex).Text, '^%x%x%x%x%x%x$') then
                                                    Colorpicker.H, Colorpicker.S, Colorpicker.V = Color3.fromHex(unwrap(Hex).Text):ToHSV()
                                                end

                                                updateAssetsColors()
                                                updateDragPositions()
                                            end,
                                        },
                                        New'TextBox'{
                                            [Ref] = RGB,
                                            Name = 'RGB',
                                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                            PlaceholderColor3 = Theme.tertiary_text,
                                            PlaceholderText = 'RGB',
                                            Text = '',
                                            TextColor3 = Theme.secondary_text,
                                            TextSize = 14,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Size = UDim2.new(0.5, -3, 0, 25),
                                            ZIndex = 9999,
                                            [Children] = {
                                                New'UIStroke'{
                                                    Name = 'UIStroke',
                                                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                                    Color = Theme.stroke,
                                                },
                                                New'UICorner'{
                                                    Name = 'UICorner',
                                                    CornerRadius = UDim.new(0, 2),
                                                },
                                            },
                                            [OnEvent'FocusLost'] = function()
                                                if string.match(unwrap(RGB).Text, '^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$') then
                                                    local r, g, b = string.match(unwrap(RGB).Text, '^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$')

                                                    r, g, b = math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255)
                                                    Colorpicker.H, Colorpicker.S, Colorpicker.V = Color3.fromRGB(r, g, b):ToHSV()
                                                end

                                                updateAssetsColors()
                                                updateDragPositions()
                                            end,
                                        },
                                    },
                                },
                                New'TextButton'{
                                    [Ref] = Submit,
                                    Name = 'TextButton',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = 'Submit',
                                    TextColor3 = Theme.text,
                                    TextSize = 14,
                                    BackgroundColor3 = animate(function()
                                        return SubmitColor:get()
                                    end, 40, 1),
                                    Size = UDim2.new(1, 0, 0, 25),
                                    ZIndex = 9999,
                                    [Children] = {
                                        New'UICorner'{
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 2),
                                        },
                                        New'UIStroke'{
                                            Name = 'UIStroke',
                                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                            Color = Theme.stroke,
                                        },
                                    },
                                    [OnEvent'InputEnded'] = function(Input)
                                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                            local color = Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V)

                                            Colorpicker.Value:set(color)

                                            unwrap(Submit).BackgroundColor3 = color

                                            Colorpicker.Changed(color)
                                            Colorpicker.Callback(color)
                                        end
                                    end,
                                },
                            },
                        },
                        New'UISizeConstraint'{
                            Name = 'UISizeConstraint',
                            MinSize = Vector2.new(240, 255),
                        },
                        New'ImageLabel'{
                            Name = 'EShadow',
                            Image = 'rbxassetid://9313765853',
                            ImageColor3 = Theme.background,
                            ImageTransparency = 0.5,
                            ScaleType = Enum.ScaleType.Slice,
                            SliceCenter = Rect.new(45, 45, 45, 45),
                            SliceScale = 1.2,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(27, 42, 53),
                            ClipsDescendants = true,
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.new(1, 75, 1, 75),
                            ZIndex = -1,
                        },
                    },
                }
                Colorpicker.Root = New'Frame'{
                    [Ref] = Root,
                    Name = 'Text',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    [Children] = {
                        New'Frame'{
                            Name = 'Addons',
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.fromScale(0, 1),
                            [Children] = {
                                New'Frame'{
                                    [Ref] = Visualize,
                                    Name = 'Visualize',
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    BackgroundColor3 = animate(function()
                                        return Colorpicker.Value:get()
                                    end, 40, 1),
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    LayoutOrder = 1,
                                    Position = UDim2.fromScale(1, 0.5),
                                    Size = UDim2.fromOffset(40, 20),
                                    [Children] = {
                                        New'UICorner'{
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 3),
                                        },
                                    },
                                    [OnEvent'InputEnded'] = function(Input)
                                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                            Colorpicker.Opened:set(not Colorpicker.Opened:get())
                                        end
                                    end,
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 15),
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                },
                            },
                        },
                        New'Frame'{
                            Name = 'TextHolder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, -80, 1, 0),
                            [Children] = {
                                New'TextLabel'{
                                    Name = 'Title',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = props.Title,
                                    TextColor3 = Theme.secondary_text,
                                    TextSize = 15,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromOffset(0, 10),
                                    Size = UDim2.fromScale(1, 0),
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 5),
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                },
                                Computed(function()
                                    if props.Description then
                                        return New'TextLabel'{
                                            Name = 'Description',
                                            FontFace = Font.new('rbxassetid://12187365364'),
                                            RichText = true,
                                            Text = props.Description,
                                            TextColor3 = Theme.tertiary_text,
                                            TextSize = 15,
                                            TextWrapped = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                            Visible = true,
                                        }
                                    end

                                    return
                                end, Fusion.cleanup),
                            },
                        },
                    },
                }

                Observer(Colorpicker.Opened):onChange(function()
                    if Colorpicker.Opened:get() then
                        local escapeConnection = UserInputService.InputBegan:Connect(function(
                            Input
                        )
                            if Input.KeyCode == Enum.KeyCode.Escape then
                                Colorpicker:Close()
                            end
                        end)

                        table.insert(unwrap(States.Library).Connections, escapeConnection)

                        local positionConnection = unwrap(Visualize):GetPropertyChangedSignal('AbsolutePosition'):Connect(function(
                        )
                            RecalculatePickerPosition()
                        end)

                        table.insert(unwrap(States.Library).Connections, positionConnection)
                        RecalculatePickerPosition()
                    else
                        if Colorpicker.Connection then
                            Colorpicker.Connection:Disconnect()

                            Colorpicker.Connection = nil
                        end
                    end
                end)

                function Colorpicker:SetTitle(newValue)
                    Colorpicker.Title:set(newValue)
                end
                function Colorpicker:SetDescription(newValue)
                    Colorpicker.Description:set(newValue)
                end

                insertItem(self.Container, Colorpicker.Root)
                updateAssetsColors()
                updateDragPositions()

                unwrap(Submit).BackgroundColor3 = unwrap(Colorpicker.Value)

                return Colorpicker
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(5)

        return (function(...)
            local UserInputService = game:GetService('UserInputService')
            local _ = game:GetService('Workspace').CurrentCamera
            local Utils = script.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local safeCallback = require(Utils.safecallback)
            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local _ = Fusion.ForPairs
            local _ = Fusion.ForValues
            local Observer = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Dropdown'

            function Element:New(Idx, props)
                local Dropdown = {
                    Values = props.Values,
                    Value = props.Default,
                    Multi = props.Multi,
                    Buttons = {},
                    Opened = Value(false),
                    Callback = props.Callback or function(_) end,
                    Type = 'Dropdown',
                    Changed = function(_) end,
                }
                local DropdownInner = Value()
                local DropdownHolder = Value()
                local DropdownHolderListLayout = Value()
                local DropdownDisplay = Value()
                local onOpened = function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dropdown.Opened:set(not Dropdown.Opened:get())
                    end
                end
                local RecalculateListPosition = function()
                    local innerPosition = unwrap(DropdownInner).AbsolutePosition
                    local innerSize = unwrap(DropdownInner).AbsoluteSize
                    local holder = unwrap(DropdownHolder)

                    holder.Position = UDim2.fromOffset(innerPosition.X, innerPosition.Y + innerSize.Y + 5)
                end
                local ContinuousPositionCalculation = function()
                    while Dropdown.Opened:get() do
                        RecalculateListPosition()
                        task.wait()
                    end
                end
                local RecalculateListSize = function()
                    if #Dropdown.Values > 10 then
                        return 350
                    else
                        return unwrap(DropdownHolderListLayout).AbsoluteContentSize.Y + 10
                    end
                end
                local RecalculateCanvasSize = function()
                    unwrap(DropdownHolder).CanvasSize = UDim2.fromOffset(0, unwrap(DropdownHolderListLayout).AbsoluteContentSize.Y)
                end
                local openedChanged = Observer(Dropdown.Opened)

                openedChanged:onChange(function()
                    RecalculateListSize()
                    RecalculateCanvasSize()

                    if Dropdown.Opened:get() then
                        coroutine.wrap(ContinuousPositionCalculation)()
                    end
                end)

                Dropdown.Holder = New('ScrollingFrame')({
                    [Ref] = DropdownHolder,
                    Name = 'Frame',
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(),
                    ScrollBarThickness = 0,
                    BackgroundColor3 = Theme.background,
                    BackgroundTransparency = animate(function()
                        local state = Dropdown.Opened:get()

                        if state then
                            return 0
                        end

                        return 1
                    end, 15, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Selectable = false,
                    Size = animate(function()
                        local state = Dropdown.Opened:get()

                        if state then
                            return UDim2.fromOffset(200, RecalculateListSize())
                        end

                        return UDim2.fromOffset(200, 0)
                    end, 35, 1),
                    Visible = true,
                    Parent = unwrap(States.Library).GUI,
                    ZIndex = 999,
                    [Children] = {
                        New('UICorner')({
                            Name = 'UICorner',
                            CornerRadius = UDim.new(0, 2),
                        }),
                        New('UIStroke')({
                            Name = 'UIStroke',
                            Color = Theme.stroke,
                            Transparency = animate(function()
                                local state = Dropdown.Opened:get()

                                if state then
                                    return 0
                                end

                                return 1
                            end, 15, 1),
                        }),
                        New('UIListLayout')({
                            [Ref] = DropdownHolderListLayout,
                            Name = 'UIListLayout',
                            Padding = UDim.new(0, 0),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }),
                        New('UIPadding')({
                            Name = 'UIPadding',
                            PaddingBottom = UDim.new(0, 5),
                            PaddingLeft = UDim.new(0, 5),
                            PaddingTop = UDim.new(0, 5),
                        }),
                        New('UISizeConstraint')({
                            Name = 'UISizeConstraint',
                            MinSize = Vector2.new(200, 0),
                        }),
                    },
                })
                Dropdown.Root = New('Frame')({
                    Name = 'Dropdown',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    [Children] = {
                        New('Frame')({
                            Name = 'Addons',
                            AnchorPoint = Vector2.new(1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.fromScale(0, 1),
                            [Children] = {
                                New('UIListLayout')({
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 15),
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                }),
                                New('TextButton')({
                                    [Ref] = DropdownInner,
                                    Name = 'Interact',
                                    FontFace = Font.new('rbxassetid://12187365364'),
                                    Text = '',
                                    TextColor3 = Color3.fromRGB(255, 255, 255),
                                    TextSize = 12,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    Active = false,
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    BackgroundColor3 = Theme.background,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    ClipsDescendants = true,
                                    LayoutOrder = 1,
                                    Position = UDim2.fromScale(1, 0.5),
                                    Selectable = false,
                                    Size = UDim2.fromOffset(200, 30),
                                    [Children] = {
                                        New('UICorner')({
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 2),
                                        }),
                                        New('ImageLabel')({
                                            Name = 'Icon',
                                            Image = 'rbxassetid://88197529571865',
                                            AnchorPoint = Vector2.new(1, 0.5),
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Interactable = false,
                                            LayoutOrder = 1,
                                            Position = UDim2.new(1, -5, 0.5, 0),
                                            Size = UDim2.fromOffset(14, 14),
                                            ImageColor3 = animate(function()
                                                local state = Dropdown.Opened:get()

                                                if state then
                                                    return Theme.accent:get()
                                                end

                                                return Theme.text:get()
                                            end, 25, 1),
                                        }),
                                        New('UIStroke')({
                                            Name = 'UIStroke',
                                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                            Color = Theme.stroke,
                                        }),
                                        New('TextLabel')({
                                            [Ref] = DropdownDisplay,
                                            Name = 'Values',
                                            FontFace = Font.new('rbxassetid://12187365364'),
                                            Text = '--',
                                            TextColor3 = animate(function()
                                                local state = Dropdown.Opened:get()

                                                if state then
                                                    return Theme.text:get()
                                                end

                                                return Theme.secondary_text:get()
                                            end, 40, 1),
                                            TextSize = 14,
                                            TextTruncate = Enum.TextTruncate.AtEnd,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AnchorPoint = Vector2.new(0, 0.5),
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            ClipsDescendants = true,
                                            Position = UDim2.new(0, 10, 0.5, 0),
                                            Size = UDim2.new(1, -30, 1, 0),
                                        }),
                                    },
                                    [OnEvent('InputEnded')] = onOpened,
                                }),
                            },
                        }),
                        New('Frame')({
                            Name = 'TextHolder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, -190, 1, 0),
                            [Children] = {
                                New('TextLabel')({
                                    Name = 'Title',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = props.Title,
                                    TextColor3 = animate(function()
                                        local state = Dropdown.Opened:get()

                                        if state then
                                            return Theme.text:get()
                                        end

                                        return Theme.secondary_text:get()
                                    end, 40, 1),
                                    TextSize = 15,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromOffset(0, 10),
                                    Size = UDim2.fromScale(1, 0),
                                }),
                                New('UIListLayout')({
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 5),
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                }),
                                Computed(function()
                                    if props.Description then
                                        return New('TextLabel')({
                                            Name = 'Description',
                                            FontFace = Font.new('rbxassetid://12187365364'),
                                            RichText = true,
                                            Text = props.Description,
                                            TextColor3 = Theme.tertiary_text,
                                            TextSize = 15,
                                            TextWrapped = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                            Visible = true,
                                        })
                                    end

                                    return
                                end, Fusion.cleanup),
                            },
                        }),
                    },
                })

                function Dropdown:SetValues(NewValues)
                    if NewValues then
                        Dropdown.Values = NewValues
                    end

                    Dropdown:BuildDropdownList()
                end
                function Dropdown:OnChanged(Func)
                    Dropdown.Changed = Func

                    Func(Dropdown.Value)
                end
                function Dropdown:SetValue(Val)
                    if Dropdown.Multi then
                        local nTable = {}

                        for Value, _ in next, Val do
                            if table.find(Dropdown.Values, Value) then
                                nTable[Value] = true
                            end
                        end

                        Dropdown.Value = nTable
                    else
                        if not Val then
                            Dropdown.Value = nil
                        elseif table.find(Dropdown.Values, Val) then
                            Dropdown.Value = Val
                        end
                    end

                    Dropdown:BuildDropdownList()
                    Dropdown:Display()
                    safeCallback(function()
                        Dropdown.Callback(Dropdown.Value)
                        Dropdown.Changed(Dropdown.Value)
                    end)
                end
                function Dropdown:GetActiveValues()
                    if Dropdown.Multi then
                        local T = {}

                        for Value, Bool in next, Dropdown.Value do
                            table.insert(T, Value)
                        end

                        return T
                    else
                        return Dropdown.Value and 1 or 0
                    end
                end
                function Dropdown:Display()
                    local Values = Dropdown.Values
                    local Str = ''

                    if Dropdown.Multi then
                        for Idx, Value in next, Values do
                            if Dropdown.Value[Value] then
                                Str = Str .. Value .. ', '
                            end
                        end

                        Str = Str:sub(1, #Str - 2)
                    else
                        Str = Dropdown.Value or ''
                    end

                    unwrap(DropdownDisplay).Text = (Str == '' and '--' or Str)
                end
                function Dropdown:BuildDropdownList()
                    local Values = Dropdown.Values

                    for _, Element in next, unwrap(DropdownHolder):GetChildren()do
                        if Element:IsA('TextButton') then
                            Element:Destroy()
                        end
                    end

                    local Count = 0

                    for Idx, Value1 in next, Values do
                        local Table = {}

                        Count = Count + 1

                        local Selected = Value()

                        if Dropdown.Multi then
                            Selected:set(Dropdown.Value[Value1])
                        else
                            Selected:set(Dropdown.Value == Value1)
                        end

                        function Table:UpdateButton()
                            if Dropdown.Multi then
                                Selected:set(Dropdown.Value[Value1])
                            else
                                Selected:set(Dropdown.Value == Value1)
                            end
                        end

                        local Button = New('TextButton')({
                            Name = 'OptionButton',
                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            Text = Value1,
                            TextColor3 = animate(function()
                                local state = Selected:get()

                                if state then
                                    return Theme.accent:get()
                                end

                                return Theme.secondary_text:get()
                            end, 45, 1),
                            TextTransparency = animate(function()
                                local state = Dropdown.Opened:get()

                                if state then
                                    return 0
                                end

                                return 1
                            end, 15, 1),
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 1,
                            BackgroundColor3 = Theme.background,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Selectable = false,
                            Size = UDim2.new(1, -5, 0, 25),
                            Parent = DropdownHolder,
                            ZIndex = 1000,
                            [Children] = {
                                New('UICorner')({
                                    Name = 'UICorner',
                                    CornerRadius = UDim.new(0, 2),
                                }),
                                New('UIPadding')({
                                    Name = 'UIPadding',
                                    PaddingLeft = UDim.new(0, 5),
                                }),
                            },
                            [OnEvent('InputBegan')] = function(Input)
                                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                    local Try = not Selected:get()

                                    if not (Dropdown:GetActiveValues() == 1 and not Try and not Dropdown.AllowNull) then
                                        if Dropdown.Multi then
                                            Selected:set(Try)

                                            Dropdown.Value[Value1] = Selected:get() and true or nil
                                        else
                                            Selected:set(Try)

                                            Dropdown.Value = Selected:get() and Value1 or nil

                                            for _, OtherButton in next, Dropdown.Buttons do
                                                OtherButton:UpdateButton()
                                            end
                                        end

                                        Dropdown:Display()
                                        Table:UpdateButton()
                                        safeCallback(function()
                                            Dropdown.Callback(Dropdown.Value)
                                            Dropdown.Changed(Dropdown.Value)
                                        end)
                                    end
                                end
                            end,
                        })

                        Table:UpdateButton()
                        Dropdown:Display()

                        Dropdown.Buttons[Button] = Table
                    end

                    RecalculateCanvasSize()
                    RecalculateListSize()
                end
                function Dropdown:Destroy()
                    unwrap(Dropdown.Root):Destroy()

                    unwrap(States.Library).Options[Idx] = nil
                end

                local DropCon = UserInputService.InputBegan:Connect(function(
                    Input
                )
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        local AbsPos, AbsSize = unwrap(DropdownHolder).AbsolutePosition, unwrap(DropdownHolder).AbsoluteSize

                        if Dropdown.Opened:get() and (UserInputService:GetMouseLocation().X < AbsPos.X or UserInputService:GetMouseLocation().X > AbsPos.X + AbsSize.X or UserInputService:GetMouseLocation().Y < AbsPos.Y) then
                            Dropdown.Opened:set(false)
                        end
                    end
                end)

                table.insert(unwrap(States.Library).Connections, DropCon)
                insertItem(self.Container, Dropdown.Root)

                unwrap(States.Library).Options[Idx] = Dropdown

                Dropdown:BuildDropdownList()
                RecalculateListPosition()
                RecalculateListSize()
                RecalculateCanvasSize()

                local Defaults = {}

                if type(props.Default) == 'string' then
                    local Idx = table.find(Dropdown.Values, props.Default)

                    if Idx then
                        table.insert(Defaults, Idx)
                    end
                elseif type(props.Default) == 'table' then
                    for _, Value in next, props.Default do
                        local Idx = table.find(Dropdown.Values, Value)

                        if Idx then
                            table.insert(Defaults, Idx)
                        end
                    end
                elseif type(props.Default) == 'number' and Dropdown.Values[props.Default] ~= nil then
                    table.insert(Defaults, props.Default)
                end
                if next(Defaults) then
                    for i = 1, #Defaults do
                        local Index = Defaults[i]

                        if Dropdown.Multi then
                            Dropdown.Value[Dropdown.Values[Index] ] = true
                        else
                            Dropdown.Value = Dropdown.Values[Index]
                        end
                        if not Dropdown.Multi then
                            break
                        end
                    end

                    Dropdown:BuildDropdownList()
                    Dropdown:Display()
                end

                return Dropdown
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(6)

        return (function(...)
            local Utils = script.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local safeCallback = require(Utils.safecallback)
            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local _ = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Input'

            function Element:New(Idx, props)
                local Input = {
                    Value = props.Default or '',
                    Numeric = props.Numeric or false,
                    Finished = props.Finished or false,
                    Callback = props.Callback or function() end,
                    Placeholder = props.Placeholder or '...',
                    Type = 'Input',
                    Changed = function(_) end,
                }
                local Box = Value()
                local isFocused = Value(false)

                Input.Root = New'Frame'{
                    Name = 'Textbox',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    [Children] = {
                        New'Frame'{
                            Name = 'Addons',
                            AnchorPoint = Vector2.new(1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.fromScale(0, 1),
                            [Children] = {
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 15),
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                },
                                New'Frame'{
                                    Name = 'Holder',
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    BackgroundColor3 = Theme.background,
                                    BackgroundTransparency = 0,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    ClipsDescendants = true,
                                    Size = UDim2.fromScale(0, 1),
                                    [Children] = {
                                        New'TextBox'{
                                            [Ref] = Box,
                                            Name = 'Input',
                                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                                            PlaceholderText = Input.Placeholder,
                                            Text = Input.Value,
                                            TextColor3 = Theme.secondary_text,
                                            TextSize = 13,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.X,
                                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            ClipsDescendants = true,
                                            LayoutOrder = 1,
                                            Size = UDim2.fromOffset(0, 25),
                                            [Children] = {
                                                New'UIPadding'{
                                                    Name = 'UIPadding',
                                                    PaddingLeft = UDim.new(0, 10),
                                                },
                                            },
                                            [OnEvent('Focused')] = function()
                                                isFocused:set(true)
                                            end,
                                            [OnEvent('FocusLost')] = function()
                                                isFocused:set(false)
                                            end,
                                        },
                                        New'UIListLayout'{
                                            Name = 'UIListLayout',
                                            FillDirection = Enum.FillDirection.Horizontal,
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                            VerticalAlignment = Enum.VerticalAlignment.Center,
                                        },
                                        New'UIStroke'{
                                            Name = 'UIStroke',
                                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                            Color = Theme.stroke,
                                        },
                                        New'UICorner'{
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 2),
                                        },
                                        New'UIPadding'{
                                            Name = 'UIPadding',
                                            PaddingRight = UDim.new(0, 10),
                                        },
                                    },
                                },
                            },
                        },
                        New'Frame'{
                            Name = 'TextHolder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, -80, 1, 0),
                            [Children] = {
                                New'TextLabel'{
                                    Name = 'Title',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = props.Title,
                                    TextColor3 = animate(function()
                                        if isFocused:get() then
                                            return Theme.text:get()
                                        end

                                        return Theme.secondary_text:get()
                                    end, 40, 1),
                                    TextSize = 15,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromOffset(0, 10),
                                    Size = UDim2.fromScale(1, 0),
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 5),
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                },
                                Computed(function()
                                    if props.Description then
                                        return New'TextLabel'{
                                            Name = 'Description',
                                            FontFace = Font.new('rbxassetid://12187365364'),
                                            RichText = true,
                                            Text = props.Description,
                                            TextColor3 = Theme.tertiary_text,
                                            TextSize = 15,
                                            TextWrapped = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                            Visible = true,
                                        }
                                    end

                                    return
                                end, Fusion.cleanup),
                            },
                        },
                    },
                }

                function Input:SetValue(Text)
                    if Input.Numeric then
                        if (not tonumber(Text)) and Text:len() > 0 then
                            Text = Input.Value
                        end
                    end

                    Input.Value = Text
                    unwrap(Box).Text = Text

                    safeCallback(function()
                        Input.Callback(Input.Value)
                        Input.Changed(Input.Value)
                    end)
                end

                if Input.Finished then
                    local Con = unwrap(Box).FocusLost:Connect(function(enter)
                        if not enter then
                            return
                        end

                        Input:SetValue(unwrap(Box).Text)
                    end)

                    table.insert(unwrap(States.Library).Connections, Con)
                else
                    local Con = unwrap(Box):GetPropertyChangedSignal('Text'):Connect(function(
                    )
                        Input:SetValue(unwrap(Box).Text)
                    end)

                    table.insert(unwrap(States.Library).Connections, Con)
                end

                function Input:OnChanged(Func)
                    Input.Changed = Func

                    Func(Input.Value)
                end
                function Input:Destroy()
                    InputFrame:Destroy()

                    Library.Options[Idx] = nil
                end

                insertItem(self.Container, Input.Root)

                unwrap(States.Library).Options[Idx] = Input

                return Input
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(7)

        return (function(...)
            local UserInputService = game:GetService('UserInputService')
            local Utils = script.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local safeCallback = require(Utils.safecallback)
            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local _ = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Keybind'

            function Element:New(Idx, props)
                local Keybind = {
                    Value = props.Default,
                    Toggled = false,
                    Mode = props.Mode or 'Toggle',
                    Type = 'Keybind',
                    Callback = props.Callback or function(_) end,
                    Changed = function(_) end,
                    Clicked = function(_) end,
                }
                local Picking = Value(false)
                local KeybindDisplay = Value()

                Keybind.Root = New('Frame')({
                    Name = 'Keybind',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    [Children] = {
                        New('Frame')({
                            Name = 'Addons',
                            AnchorPoint = Vector2.new(1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.fromScale(0, 1),
                            [Children] = {
                                New('UIListLayout')({
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 15),
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                }),
                                New('TextButton')({
                                    [Ref] = KeybindDisplay,
                                    Name = 'Interact',
                                    FontFace = Font.new('rbxassetid://12187365364'),
                                    Text = Keybind.Value,
                                    TextColor3 = Theme.secondary_text,
                                    TextSize = 15,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    Active = false,
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    BackgroundColor3 = Theme.background,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    ClipsDescendants = true,
                                    LayoutOrder = 1,
                                    Position = UDim2.fromScale(1, 0.5),
                                    Selectable = false,
                                    Size = UDim2.fromOffset(0, 25),
                                    [Children] = {
                                        New('UICorner')({
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 2),
                                        }),
                                        New('UIStroke')({
                                            Name = 'UIStroke',
                                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                            Color = Theme.stroke,
                                        }),
                                        New('UIPadding')({
                                            Name = 'UIPadding',
                                            PaddingLeft = UDim.new(0, 11),
                                            PaddingRight = UDim.new(0, 10),
                                        }),
                                    },
                                    [OnEvent('InputBegan')] = function(Input)
                                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                            local Display = unwrap(KeybindDisplay)

                                            if not Display then
                                                return
                                            end

                                            Picking:set(true)

                                            Display.Text = '...'

                                            task.wait(0.2)

                                            local Event

                                            Event = UserInputService.InputBegan:Connect(function(
                                                Input
                                            )
                                                local Key

                                                if Input.UserInputType == Enum.UserInputType.Keyboard then
                                                    Key = Input.KeyCode.Name
                                                elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                                                    Key = 'MouseLeft'
                                                elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                                                    Key = 'MouseRight'
                                                end

                                                local EndedEvent

                                                EndedEvent = UserInputService.InputEnded:Connect(function(
                                                    Input
                                                )
                                                    if Input.KeyCode.Name == Key or Key == 'MouseLeft' and Input.UserInputType == Enum.UserInputType.MouseButton1 or Key == 'MouseRight' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                                                        Picking:set(false)

                                                        Display.Text = Key
                                                        Keybind.Value = Key

                                                        safeCallback(function()
                                                            Keybind.Changed(Input.KeyCode or Input.UserInputType)
                                                        end)
                                                        Event:Disconnect()
                                                        EndedEvent:Disconnect()
                                                    end
                                                end)
                                            end)
                                        end
                                    end,
                                }),
                            },
                        }),
                        New('Frame')({
                            Name = 'TextHolder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, -80, 1, 0),
                            [Children] = {
                                New('TextLabel')({
                                    Name = 'Title',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = props.Title,
                                    TextColor3 = animate(function()
                                        if Picking:get() then
                                            return Theme.text:get()
                                        end

                                        return Theme.secondary_text:get()
                                    end, 40, 1),
                                    TextSize = 15,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromOffset(0, 10),
                                    Size = UDim2.fromScale(1, 0),
                                }),
                                New('UIListLayout')({
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 5),
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                }),
                                Computed(function()
                                    if props.Description then
                                        return New('TextLabel')({
                                            Name = 'Description',
                                            FontFace = Font.new('rbxassetid://12187365364'),
                                            RichText = true,
                                            Text = props.Description,
                                            TextColor3 = Theme.tertiary_text,
                                            TextSize = 15,
                                            TextWrapped = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                            Visible = true,
                                        })
                                    end

                                    return
                                end, Fusion.cleanup),
                            },
                        }),
                    },
                })

                function Keybind:GetState()
                    if UserInputService:GetFocusedTextBox() and Keybind.Mode ~= 'Always' then
                        return false
                    end
                    if Keybind.Mode == 'Always' then
                        return true
                    elseif Keybind.Mode == 'Hold' then
                        if Keybind.Value == 'None' then
                            return false
                        end

                        local Key = Keybind.Value

                        if Key == 'MouseLeft' or Key == 'MouseRight' then
                            return Key == 'MouseLeft' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or Key == 'MouseRight' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                        else
                            return UserInputService:IsKeyDown(Enum.KeyCode[Keybind.Value])
                        end
                    else
                        return Keybind.Toggled
                    end
                end
                function Keybind:SetValue(Key, Mode)
                    Key = Key or Keybind.Value
                    Mode = Mode or Keybind.Mode
                    unwrap(KeybindDisplay).Text = Key
                    Keybind.Value = Key
                    Keybind.Mode = Mode
                end
                function Keybind:OnClick(Callback)
                    Keybind.Clicked = Callback
                end
                function Keybind:OnChanged(Callback)
                    Keybind.Changed = Callback

                    Callback(Keybind.Value)
                end
                function Keybind:DoClick()
                    safeCallback(function()
                        Keybind.Callback(Keybind.Toggled)
                    end)
                    safeCallback(function()
                        Keybind.Clicked(Keybind.Toggled)
                    end)
                end
                function Keybind:Destroy()
                    Keybind.Root:Destroy()

                    unwrap(States.Library).Options[Idx] = nil
                end

                table.insert(unwrap(States.Library).Connections, UserInputService.InputBegan:Connect(function(
                    Input
                )
                    if not Picking:get() and not UserInputService:GetFocusedTextBox() then
                        if Keybind.Mode == 'Toggle' then
                            local Key = Keybind.Value

                            if Key == 'MouseLeft' or Key == 'MouseRight' then
                                if Key == 'MouseLeft' and Input.UserInputType == Enum.UserInputType.MouseButton1 or Key == 'MouseRight' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                                    Keybind.Toggled = not Keybind.Toggled

                                    Keybind:DoClick()
                                end
                            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                                if Input.KeyCode.Name == Key then
                                    Keybind.Toggled = not Keybind.Toggled

                                    Keybind:DoClick()
                                end
                            end
                        end
                    end
                end))
                insertItem(self.Container, Keybind.Root)

                unwrap(States.Library).Options[Idx] = Keybind

                return Keybind
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(8)

        return (function(...)
            local Utils = script.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local safeCallback = require(Utils.safecallback)
            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local _ = Fusion.Computed
            local ForPairs = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local _ = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Radio'

            function Element:New(Idx, props)
                local RadioGroup = {
                    Title = props.Title,
                    Options = props.Options,
                    Default = props.Default or props.Options[1],
                    Callback = props.Callback or function() end,
                    Changed = function() end,
                }
                local selectedOption = Value(RadioGroup.Default)

                RadioGroup.Root = New'Frame'{
                    Name = 'RadioGroup',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    [Children] = {
                        New'TextLabel'{
                            Name = 'Title',
                            Text = RadioGroup.Title,
                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            TextColor3 = Theme.text,
                            TextSize = 15,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 0),
                        },
                        New'UIListLayout'{
                            Name = 'UIListLayout',
                            Padding = UDim.new(0, 10),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        },
                        ForPairs(RadioGroup.Options, function(index, option)
                            return index, New'TextButton'{
                                Name = 'RadioButton',
                                Text = option,
                                FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                TextColor3 = animate(function()
                                    if unwrap(selectedOption) == option then
                                        return Theme.text:get()
                                    end

                                    return Theme.secondary_text:get()
                                end, 40, 1),
                                TextSize = 15,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                AutomaticSize = Enum.AutomaticSize.Y,
                                BackgroundColor3 = Theme.background,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 0),
                                [Children] = {
                                    New'UICorner'{
                                        Name = 'UICorner',
                                        CornerRadius = UDim.new(0, 2),
                                    },
                                    New'UIStroke'{
                                        Name = 'UIStroke',
                                        Color = Theme.stroke,
                                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                    },
                                    New'UIPadding'{
                                        Name = 'UIPadding',
                                        PaddingLeft = UDim.new(0, 11),
                                    },
                                    New'ImageLabel'{
                                        Name = 'RadioIcon',
                                        Image = 'rbxassetid://128735638309771',
                                        ImageColor3 = animate(function()
                                            if unwrap(selectedOption) == option then
                                                return Theme.accent:get()
                                            end

                                            return Theme.background:get()
                                        end, 40, 1),
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromOffset(20, 20),
                                        Position = UDim2.fromScale(0, 0.5),
                                        AnchorPoint = Vector2.new(0, 0.5),
                                    },
                                },
                                [OnEvent('Activated')] = function()
                                    selectedOption:set(option)
                                    safeCallback(function()
                                        RadioGroup.Callback(option)
                                        RadioGroup.Changed(option)
                                    end)
                                end,
                            }
                        end),
                    },
                }

                function RadioGroup:OnChanged(Func)
                    RadioGroup.Changed = Func

                    Func(unwrap(selectedOption))
                end
                function RadioGroup:SetValue(Value)
                    selectedOption:set(Value)
                end

                insertItem(self.Container, RadioGroup.Root)

                unwrap(States.Library).Options[Idx] = RadioGroup

                return RadioGroup
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(9)

        return (function(...)
            local Utils = script.Parent.Parent.utils

            require(Utils.animate)
            require(Utils.color3)
            require(Utils.unwrap)

            local insertItem = require(Utils.insertitem)

            require(Utils.safecallback)

            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)
            require(Packages.states)

            local Children = Fusion.Children
            local _ = Fusion.Computed
            local _ = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local _ = Fusion.OnEvent
            local _ = Fusion.Value
            local _ = Fusion.Tween
            local _ = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Seperator'

            function Element:New()
                local Seperator = {}

                Seperator.Root = New('Frame')({
                    Name = 'Seperator',
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Interactable = false,
                    Size = UDim2.new(1, 0, 0, 0),
                    [Children] = {
                        New('Frame')({
                            Name = 'Frame',
                            AnchorPoint = Vector2.new(0, 0.5),
                            BackgroundColor3 = Theme.stroke,
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(0, 0.5),
                            Size = UDim2.new(1, 0, 0, 0),
                            [Children] = {
                                New('UIStroke')({
                                    Name = 'UIStroke',
                                    Color = Theme.stroke,
                                }),
                            },
                        }),
                    },
                })

                insertItem(self.Container, Seperator.Root)

                return Seperator
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(10)

        return (function(...)
            local UserInputService = game:GetService('UserInputService')
            local RunService = game:GetService('RunService')
            local Utils = script.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local safeCallback = require(Utils.safecallback)
            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local _ = Fusion.ForPairs
            local Observer = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Slider'

            function Element:New(Idx, props)
                local Slider = {
                    Title = props.Title,
                    Suffix = props.Suffix or '',
                    Default = props.Default,
                    Min = props.Min,
                    Max = props.Max,
                    Value = props.Default or props.Min,
                    Rounding = props.Rounding or 0,
                    Type = 'Slider',
                    Callback = props.Callback or function() end,
                    Changed = function() end,
                }
                local roundValue = function(value, decimalPlaces)
                    local mult = 10 ^ (decimalPlaces or 0)

                    return math.floor(value * mult + 0.5) / mult
                end
                local barRef = Value()
                local isGrabbing = Value(false)
                local isHoveringCircle = Value(false)
                local numberValue = Value(roundValue(math.min(Slider.Default or Slider.Min, Slider.Max), Slider.Rounding or 0))
                local numberObserver = Observer(numberValue)
                local barSize = Value(UDim2.fromScale((unwrap(numberValue) - Slider.Min) / (Slider.Max - Slider.Min), 1))

                function update()
                    Slider.Value = unwrap(numberValue)

                    barSize:set(UDim2.fromScale((unwrap(numberValue) - Slider.Min) / (Slider.Max - Slider.Min), 1))
                    safeCallback(function()
                        Slider.Callback(unwrap(numberValue))
                        Slider.Changed(unwrap(numberValue))
                    end)
                end

                numberObserver:onChange(update)

                Slider.Root = New('Frame')({
                    Name = 'Slider',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    [Children] = {
                        New('UIListLayout')({
                            Name = 'UIListLayout',
                            Padding = UDim.new(0, 10),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }),
                        New('Frame')({
                            [Ref] = barRef,
                            Name = 'Bar',
                            BackgroundColor3 = Theme.secondary_background,
                            BorderSizePixel = 0,
                            LayoutOrder = 2,
                            Position = UDim2.fromScale(0, 0.6),
                            Size = UDim2.new(1, 0, 0, 5),
                            [Children] = {
                                New('UIStroke')({
                                    Name = 'UIStroke',
                                    Color = Theme.stroke,
                                }),
                                New('UICorner')({
                                    Name = 'UICorner',
                                    CornerRadius = UDim.new(0, 2),
                                }),
                                New('Frame')({
                                    Name = 'Progress',
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    BackgroundColor3 = Theme.accent,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromScale(0, 0.5),
                                    Size = animate(function()
                                        return barSize:get()
                                    end, 40, 1),
                                    [Children] = {
                                        New('UIStroke')({
                                            Name = 'UIStroke',
                                            Color = Theme.stroke,
                                        }),
                                        New('UICorner')({
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 2),
                                        }),
                                        New('Frame')({
                                            Name = 'Drag',
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            BackgroundColor3 = Theme.text,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromScale(1, 0.5),
                                            Size = animate(function()
                                                local state = isHoveringCircle:get()

                                                if state then
                                                    return UDim2.fromOffset(15, 15)
                                                end

                                                return UDim2.fromOffset(12, 12)
                                            end, 40, 1),
                                            [Children] = {
                                                New('UICorner')({
                                                    Name = 'UICorner',
                                                    CornerRadius = UDim.new(1, 0),
                                                }),
                                            },
                                            [OnEvent('MouseEnter')] = function()
                                                isHoveringCircle:set(true)
                                            end,
                                            [OnEvent('MouseLeave')] = function()
                                                isHoveringCircle:set(false)
                                            end,
                                        }),
                                    },
                                }),
                            },
                            [OnEvent('InputBegan')] = function(inputObject)
                                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
                                    isGrabbing:set(true)
                                end
                            end,
                            [OnEvent('InputEnded')] = function(inputObject)
                                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
                                    isGrabbing:set(false)
                                end
                            end,
                        }),
                        New('Frame')({
                            Name = 'TextHolder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            LayoutOrder = 1,
                            Size = UDim2.fromScale(1, 0),
                            [Children] = {
                                New('Frame')({
                                    Name = 'Text',
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Size = UDim2.fromScale(1, 0),
                                    [Children] = {
                                        New('TextLabel')({
                                            Name = 'Title',
                                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                            Text = props.Title,
                                            TextColor3 = animate(function()
                                                if isGrabbing:get() then
                                                    return Theme.text:get()
                                                end

                                                return Theme.secondary_text:get()
                                            end, 40, 1),
                                            TextSize = 15,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                        }),
                                        Computed(function()
                                            if props.Description then
                                                return New('TextLabel')({
                                                    Name = 'Description',
                                                    FontFace = Font.new('rbxassetid://12187365364'),
                                                    RichText = true,
                                                    Text = props.Description,
                                                    TextColor3 = Theme.tertiary_text,
                                                    TextSize = 15,
                                                    TextWrapped = true,
                                                    TextXAlignment = Enum.TextXAlignment.Left,
                                                    AutomaticSize = Enum.AutomaticSize.Y,
                                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                    BackgroundTransparency = 1,
                                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                    BorderSizePixel = 0,
                                                    Position = UDim2.fromOffset(0, 10),
                                                    Size = UDim2.fromScale(1, 0),
                                                    Visible = true,
                                                })
                                            end

                                            return
                                        end, Fusion.cleanup),
                                        New('UIListLayout')({
                                            Name = 'UIListLayout',
                                            Padding = UDim.new(0, 5),
                                            VerticalAlignment = Enum.VerticalAlignment.Center,
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                        }),
                                    },
                                }),
                                New('TextLabel')({
                                    Name = 'Title',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = Computed(function()
                                        local value = unwrap(numberValue)
                                        local formattedValue = string.format('%.' .. Slider.Rounding .. 'f', roundValue(value, Slider.Rounding))

                                        return formattedValue .. Slider.Suffix
                                    end),
                                    TextColor3 = animate(function()
                                        if isGrabbing:get() then
                                            return Theme.text:get()
                                        end

                                        return Theme.secondary_text:get()
                                    end, 40, 1),
                                    TextSize = 15,
                                    TextXAlignment = Enum.TextXAlignment.Right,
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    AutomaticSize = Enum.AutomaticSize.XY,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromScale(1, 0.5),
                                }),
                            },
                        }),
                    },
                    [OnEvent('InputBegan')] = function(inputObject)
                        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
                            isGrabbing:set(true)
                        end
                    end,
                    [OnEvent('InputEnded')] = function(inputObject)
                        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
                            isGrabbing:set(false)
                        end
                    end,
                })

                RunService.RenderStepped:Connect(function()
                    if not unwrap(isGrabbing) then
                        return
                    end

                    local bar = unwrap(barRef)
                    local absPosition = bar.AbsolutePosition.X
                    local absSize = bar.AbsoluteSize.X
                    local mouseDelta = math.min(math.max(0, UserInputService:GetMouseLocation().X - absPosition), absSize)
                    local newValue = Slider.Min + ((mouseDelta / absSize) * (Slider.Max - Slider.Min))

                    newValue = roundValue(newValue, Slider.Rounding)
                    newValue = math.min(newValue, Slider.Max)
                    newValue = math.max(newValue, Slider.Min)

                    numberValue:set(newValue)

                    Slider.Value = unwrap(numberValue)
                end)
                safeCallback(function()
                    Slider.Callback(unwrap(numberValue))
                end)

                function Slider:OnChanged(Func)
                    Slider.Changed = Func

                    Func(unwrap(numberValue))
                end
                function Slider:SetValue(Value)
                    numberValue:set(Value)

                    Slider.Value = unwrap(numberValue)
                end
                function Slider:UpdateMin(newValue)
                    Slider.Min = newValue

                    update()
                end
                function Slider:UpdateMax(newValue)
                    Slider.Max = newValue

                    update()
                end

                insertItem(self.Container, Slider.Root)

                unwrap(States.Library).Options[Idx] = Slider

                return Slider
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(11)

        return (function(...)
            local Utils = script.Parent.Parent.utils

            require(Utils.animate)
            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)

            require(Utils.safecallback)

            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local ForPairs = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local _ = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Table'

            function Element:New(Idx, props)
                local Table = {
                    Headers = props.Headers or {},
                    Rows = props.Rows or {},
                    Type = 'Table',
                }
                local Headers = Value({})
                local Rows = Value({})
                local Top = Value()

                Table.Root = New'Frame'{
                    Name = 'Table',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    [Children] = {
                        New'Frame'{
                            Name = 'TextHolder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 0),
                            [Children] = {
                                New'TextLabel'{
                                    Name = 'Title',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = props.Title,
                                    TextColor3 = Theme.secondary_text,
                                    TextSize = 15,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromOffset(0, 10),
                                    Size = UDim2.fromScale(1, 0),
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 5),
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                },
                                Computed(function()
                                    if props.Description then
                                        return New'TextLabel'{
                                            Name = 'Description',
                                            FontFace = Font.new('rbxassetid://12187365364'),
                                            RichText = true,
                                            Text = props.Description,
                                            TextColor3 = Theme.tertiary_text,
                                            TextSize = 15,
                                            TextWrapped = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                            Visible = true,
                                        }
                                    end

                                    return
                                end, Fusion.cleanup),
                            },
                        },
                        New'UIListLayout'{
                            Name = 'UIListLayout',
                            Padding = UDim.new(0, 8),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        },
                        New'Frame'{
                            Name = 'Holder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Theme.secondary_background,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 0),
                            [Children] = {
                                New'UIStroke'{
                                    Name = 'UIStroke',
                                    Color = Theme.stroke,
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                },
                                New'Frame'{
                                    [Ref] = Top,
                                    Name = 'Top',
                                    BackgroundColor3 = Theme.background,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    LayoutOrder = -1,
                                    Size = UDim2.new(1, 0, 0, 30),
                                    [Children] = {
                                        New'UIStroke'{
                                            Name = 'UIStroke',
                                            Color = Theme.stroke,
                                        },
                                        New'UIListLayout'{
                                            Name = 'UIListLayout',
                                            FillDirection = Enum.FillDirection.Horizontal,
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                        },
                                        ForPairs(Headers, function(
                                            index,
                                            value
                                        )
                                            return index, value
                                        end, Fusion.cleanup),
                                    },
                                },
                                New'Frame'{
                                    Name = 'Entry',
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Size = UDim2.new(1, 0, 0, 30),
                                    [Children] = {
                                        New'UIListLayout'{
                                            Name = 'UIListLayout',
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                        },
                                        ForPairs(Rows, function(index, value)
                                            return index, value
                                        end, Fusion.cleanup),
                                    },
                                },
                            },
                        },
                    },
                }

                function Table:Render()
                    Headers:set({})
                    Rows:set({})

                    for _, v in next, Table.Headers do
                        local Header = New'Frame'{
                            Name = 'Header',
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = Computed(function()
                                return UDim2.new(1 / #unwrap(Headers), 0, 1, 0)
                            end),
                            [Children] = {
                                New'Frame'{
                                    Name = 'UIStroke',
                                    BackgroundColor3 = Theme.stroke,
                                    Size = UDim2.new(0, 1, 1, 0),
                                    Position = UDim2.fromScale(1, 0),
                                },
                                New'TextLabel'{
                                    Name = 'Title',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = v,
                                    TextColor3 = Theme.secondary_text,
                                    TextSize = 14,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    TextTruncate = Enum.TextTruncate.AtEnd,
                                    Size = UDim2.fromScale(1, 1),
                                    [Children] = {
                                        New'UIPadding'{
                                            Name = 'UIPadding',
                                            PaddingLeft = UDim.new(0, 10),
                                        },
                                    },
                                },
                            },
                        }

                        insertItem(Headers, Header)
                    end
                    for _, v in next, Table.Rows do
                        local Entries = Value({})
                        local alternateBackground = Value(false)

                        if props.AlternateBackground and #unwrap(Rows) % 2 == 1 then
                            alternateBackground:set(true)
                        end

                        local Row = New'Frame'{
                            Name = 'Row',
                            BackgroundColor3 = Computed(function()
                                if alternateBackground:get() then
                                    return Theme.background:get()
                                end

                                return Theme.secondary_background:get()
                            end),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            LayoutOrder = -1,
                            Size = UDim2.new(1, 0, 0, 30),
                            [Children] = {
                                New'UIStroke'{
                                    Name = 'UIStroke',
                                    Color = Theme.stroke,
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                },
                                ForPairs(Entries, function(index, value)
                                    return index, value
                                end, Fusion.cleanup),
                            },
                        }

                        for _, Data in next, v do
                            local Entry = New'Frame'{
                                Name = 'Entry',
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = Computed(function()
                                    return UDim2.new(1 / #unwrap(Headers), 0, 1, 0)
                                end),
                                [Children] = {
                                    New'Frame'{
                                        Name = 'UIStroke',
                                        BackgroundColor3 = Theme.stroke,
                                        Size = UDim2.new(0, 1, 1, 0),
                                        Position = UDim2.fromScale(1, 0),
                                    },
                                    New'TextLabel'{
                                        Name = 'Title',
                                        FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                        Text = Data,
                                        TextColor3 = Theme.secondary_text,
                                        TextSize = 14,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        TextTruncate = Enum.TextTruncate.AtEnd,
                                        Size = UDim2.fromScale(1, 1),
                                        [Children] = {
                                            New'UIPadding'{
                                                Name = 'UIPadding',
                                                PaddingLeft = UDim.new(0, 10),
                                            },
                                        },
                                    },
                                },
                            }

                            insertItem(Entries, Entry)
                        end

                        insertItem(Rows, Row)
                    end
                end
                function Table:UpdateHeaders(newHeaders)
                    Table.Headers = newHeaders

                    Table:Render()
                end
                function Table:UpdateRows(newRows)
                    Table.Rows = newRows

                    Table:Render()
                end

                Table:Render()
                insertItem(self.Container, Table.Root)

                unwrap(States.Library).Options[Idx] = Table

                return Table
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(12)

        return (function(...)
            local Utils = script.Parent.Parent.utils

            require(Utils.animate)
            require(Utils.color3)
            require(Utils.unwrap)

            local insertItem = require(Utils.insertitem)

            require(Utils.safecallback)

            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)
            require(Packages.states)

            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local _ = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local _ = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local _ = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Text'

            function Element:New(props)
                local Toggle = {
                    Title = Value(props.Title) or nil,
                    Description = Value(props.Description) or nil,
                }

                Toggle.Root = New('Frame')({
                    Name = 'Text',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    [Children] = {
                        New('Frame')({
                            Name = 'TextHolder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, -80, 1, 0),
                            [Children] = {
                                Computed(function()
                                    if Toggle.Title then
                                        return New('TextLabel')({
                                            Name = 'Title',
                                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                            Text = Toggle.Title,
                                            TextColor3 = Theme.secondary_text,
                                            TextSize = 15,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                        })
                                    end

                                    return
                                end, Fusion.cleanup),
                                New('UIListLayout')({
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 5),
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                }),
                                Computed(function()
                                    if Toggle.Description then
                                        return New('TextLabel')({
                                            Name = 'Description',
                                            FontFace = Font.new('rbxassetid://12187365364'),
                                            RichText = true,
                                            Text = Toggle.Description,
                                            TextColor3 = Theme.tertiary_text,
                                            TextSize = 15,
                                            TextWrapped = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                            Visible = true,
                                        })
                                    end

                                    return
                                end, Fusion.cleanup),
                            },
                        }),
                    },
                })

                function Toggle:SetTitle(newValue)
                    Toggle.Title:set(newValue)
                end
                function Toggle:SetDescription(newValue)
                    Toggle.Description:set(newValue)
                end

                insertItem(self.Container, Toggle.Root)

                return Toggle
            end

            return Element
        end)()
    end,
    function()
        local wax, script, require = ImportGlobals(13)

        return (function(...)
            local Utils = script.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local safeCallback = require(Utils.safecallback)
            local Packages = script.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local _ = Fusion.ForPairs
            local Observer = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local _ = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.storage.theme)
            local Element = {}

            Element.__index = Element
            Element.__type = 'Toggle'

            function Element:New(Idx, props)
                local Toggle = {
                    Value = props.Default or false,
                    Callback = props.Callback or function(_) end,
                    Type = 'Toggle',
                    Changed = function(_) end,
                }
                local isToggled = Value()

                Toggle.Root = New'Frame'{
                    Name = props.Title,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    [Children] = {
                        New'Frame'{
                            Name = 'Addons',
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.fromScale(0, 1),
                            [Children] = {
                                New'ImageButton'{
                                    Name = 'Checkbox',
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    BackgroundColor3 = animate(function()
                                        if isToggled:get() then
                                            return Theme.accent:get()
                                        end

                                        return Theme.background:get()
                                    end, 40, 1),
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    LayoutOrder = 1,
                                    Position = UDim2.fromScale(1, 0.5),
                                    Size = UDim2.fromOffset(20, 20),
                                    [Children] = {
                                        New'UICorner'{
                                            Name = 'UICorner',
                                            CornerRadius = UDim.new(0, 2),
                                        },
                                        New'UIStroke'{
                                            Name = 'UIStroke',
                                            Color = Theme.stroke,
                                            Enabled = Computed(function()
                                                if not isToggled:get() then
                                                    return true
                                                end

                                                return false
                                            end),
                                        },
                                        New'ImageLabel'{
                                            Name = 'ImageLabel',
                                            Image = 'rbxassetid://128735638309771',
                                            ImageColor3 = Color3.fromRGB(0, 0, 0),
                                            ImageTransparency = animate(function(
                                            )
                                                if isToggled:get() then
                                                    return 0
                                                end

                                                return 1
                                            end, 40, 1),
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromScale(0.5, 0.5),
                                            Size = UDim2.fromOffset(14, 14),
                                        },
                                    },
                                    [OnEvent('InputEnded')] = function(Input)
                                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                            Toggle:SetValue(not isToggled:get())
                                        end
                                    end,
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 15),
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                },
                            },
                        },
                        New'Frame'{
                            Name = 'TextHolder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, -80, 1, 0),
                            [Children] = {
                                New'TextLabel'{
                                    Name = 'Title',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = props.Title,
                                    TextColor3 = animate(function()
                                        if isToggled:get() then
                                            return Theme.text:get()
                                        end

                                        return Theme.secondary_text:get()
                                    end, 40, 1),
                                    TextSize = 15,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromOffset(0, 10),
                                    Size = UDim2.fromScale(1, 0),
                                },
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 5),
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                },
                                Computed(function()
                                    if props.Description then
                                        return New'TextLabel'{
                                            Name = 'Description',
                                            FontFace = Font.new('rbxassetid://12187365364'),
                                            RichText = true,
                                            Text = props.Description,
                                            TextColor3 = Theme.tertiary_text,
                                            TextSize = 15,
                                            TextWrapped = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(0, 10),
                                            Size = UDim2.fromScale(1, 0),
                                            Visible = true,
                                        }
                                    end

                                    return
                                end, Fusion.cleanup),
                            },
                        },
                    },
                    [OnEvent('InputEnded')] = function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Toggle:SetValue(not isToggled:get())
                        end
                    end,
                }

                function Toggle:OnChanged(Func)
                    Toggle.Changed = Func

                    Func(Toggle.Value)
                end
                function Toggle:SetValue(v)
                    Toggle.Value = v

                    isToggled:set(v)
                end
                function Toggle:GetValue()
                    return Toggle.Value
                end

                Toggle:SetValue(Toggle.Value)

                local onToggleObserver = Observer(isToggled)

                onToggleObserver:onChange(function()
                    safeCallback(function()
                        Toggle.Callback(isToggled:get())
                        Toggle.Changed(isToggled:get())
                    end)
                end)
                insertItem(self.Container, Toggle.Root)

                unwrap(States.Library).Options[Idx] = Toggle

                return Toggle
            end

            return Element
        end)()
    end,
    [17] = function()
        local wax, script, require = ImportGlobals(17)

        return (function(...)
            local Utils = script.Parent.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)

            require(Utils.safecallback)

            local Packages = script.Parent.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local _ = Fusion.Computed
            local ForPairs = Fusion.ForPairs
            local _ = Fusion.Observer
            local OnChange = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.Parent.storage.theme)

            return function(props)
                local Category = {
                    Tabs = Value({}),
                    Collapsed = Value(false),
                    ExpandedHeight = Value(0),
                }
                local computedHeight = animate(function()
                    return Category.Collapsed:get() and UDim2.new(1, 0, 0, 40) or UDim2.new(1, 0, 0, unwrap(Category.ExpandedHeight) + 42)
                end, 50, 1)
                local ListLayout = Value()

                Category.Root = New('Frame')({
                    Name = 'Section',
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    LayoutOrder = props.Order,
                    Size = computedHeight,
                    ClipsDescendants = true,
                    [Children] = {
                        New('Frame')({
                            Name = 'Title',
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 40),
                            [Children] = {
                                New('TextLabel')({
                                    Name = 'TextLabel',
                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                    Text = props.Title,
                                    TextColor3 = Theme.secondary_text,
                                    TextSize = 17,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromOffset(14, 0),
                                    Size = UDim2.fromScale(0, 1),
                                }),
                                New('ImageButton')({
                                    Name = 'Collapse',
                                    Image = 'rbxassetid://107640924738262',
                                    ImageColor3 = Theme.tertiary_text,
                                    AnchorPoint = Vector2.new(1, 0.5),
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.new(1, -15, 0.5, -1),
                                    Size = UDim2.fromOffset(20, 20),
                                    Rotation = animate(function()
                                        if Category.Collapsed:get() then
                                            return 180
                                        end

                                        return 0
                                    end, 25, 1),
                                    [OnEvent('MouseButton1Click')] = function()
                                        Category.Collapsed:set(not Category.Collapsed:get())
                                    end,
                                }),
                            },
                        }),
                        New('UIListLayout')({
                            Name = 'UIListLayout',
                            Padding = UDim.new(0, 0),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }),
                        New('Frame')({
                            Name = 'Holder',
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 0),
                            [Children] = {
                                New('UIListLayout')({
                                    [Ref] = ListLayout,
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 13),
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                    [OnChange('AbsoluteContentSize')] = function(
                                        newSize
                                    )
                                        Category.ExpandedHeight:set(newSize.Y)
                                    end,
                                }),
                                ForPairs(Category.Tabs, function(index, value)
                                    return index, value
                                end, Fusion.cleanup),
                            },
                        }),
                    },
                })

                function Category:AddTab(Config)
                    local Tab = require(script.Parent.tab)({
                        Title = Config.Title,
                    })

                    insertItem(Category.Tabs, Tab.Root)

                    if not States.HasSelected:get() then
                        States.HasSelected:set(true)
                        Tab.Selected:set(true)
                    end

                    return Tab
                end

                Category.ExpandedHeight:set(unwrap(ListLayout).AbsoluteContentSize.Y)

                return Category
            end
        end)()
    end,
    [18] = function()
        local wax, script, require = ImportGlobals(18)

        return (function(...)
            local UserInputService = game:GetService('UserInputService')
            local _ = game:GetService('Workspace').CurrentCamera
            local Utils = script.Parent.Parent.Parent.utils
            local animate = require(Utils.animate)
            local colorUtils = require(Utils.color3)
            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local safeCallback = require(Utils.safecallback)
            local Packages = script.Parent.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local _ = Fusion.Computed
            local ForPairs = Fusion.ForPairs
            local _ = Fusion.ForValues
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.Parent.storage.theme)
            local Module = {Window = nil}

            function Module:init(window)
                Module.Window = window
            end
            function Module:Create(Config)
                local Dialog = {
                    Opened = Value(false),
                    Buttons = Value({}),
                    Connection = nil,
                }
                local Canvas = Value()

                Dialog.Root = New'TextButton'{
                    Name = 'Modal',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = animate(function()
                        if Dialog.Opened:get() then
                            return 0.5
                        end

                        return 1
                    end, 40, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 10,
                    Parent = Module.Window,
                    [Children] = {
                        New'Frame'{
                            [Ref] = Canvas,
                            Name = 'Canvas',
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Theme.secondary_background,
                            BackgroundTransparency = animate(function()
                                if Dialog.Opened:get() then
                                    return 0
                                end

                                return 1
                            end, 40, 1),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(500, 0),
                            [Children] = {
                                New'Frame'{
                                    Name = 'Holder',
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Size = UDim2.fromScale(1, 1),
                                    [Children] = {
                                        New'Frame'{
                                            Name = 'TextHolder',
                                            AutomaticSize = Enum.AutomaticSize.Y,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Size = UDim2.fromScale(1, 0),
                                            [Children] = {
                                                New'UIListLayout'{
                                                    Name = 'UIListLayout',
                                                    Padding = UDim.new(0, 5),
                                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                                },
                                                New'UIPadding'{
                                                    Name = 'UIPadding',
                                                    PaddingLeft = UDim.new(0, 20),
                                                    PaddingTop = UDim.new(0, 20),
                                                },
                                                New'TextLabel'{
                                                    Name = 'TextLabel',
                                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                                    Text = Config.Title,
                                                    TextColor3 = Theme.secondary_text,
                                                    TextSize = 17,
                                                    TextXAlignment = Enum.TextXAlignment.Left,
                                                    AutomaticSize = Enum.AutomaticSize.XY,
                                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                    BackgroundTransparency = 1,
                                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                    BorderSizePixel = 0,
                                                    Position = UDim2.fromOffset(15, 0),
                                                    TextTransparency = animate(function(
                                                    )
                                                        if Dialog.Opened:get() then
                                                            return 0
                                                        end

                                                        return 1
                                                    end, 40, 1),
                                                },
                                                New'TextLabel'{
                                                    Name = 'Description',
                                                    FontFace = Font.new('rbxassetid://12187365364'),
                                                    RichText = true,
                                                    Text = Config.Description,
                                                    TextColor3 = Theme.tertiary_text,
                                                    TextSize = 15,
                                                    TextWrapped = true,
                                                    TextXAlignment = Enum.TextXAlignment.Left,
                                                    AutomaticSize = Enum.AutomaticSize.Y,
                                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                    BackgroundTransparency = 1,
                                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                    BorderSizePixel = 0,
                                                    Position = UDim2.fromOffset(0, 10),
                                                    Size = UDim2.fromScale(1, 0),
                                                    TextTransparency = animate(function(
                                                    )
                                                        if Dialog.Opened:get() then
                                                            return 0
                                                        end

                                                        return 1
                                                    end, 40, 1),
                                                },
                                            },
                                        },
                                        New'Frame'{
                                            Name = 'Buttons',
                                            AnchorPoint = Vector2.new(0, 1),
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromScale(0, 1),
                                            Size = UDim2.new(1, 0, 0, 40),
                                            [Children] = {
                                                New'Frame'{
                                                    Name = 'Seperator',
                                                    BackgroundTransparency = animate(function(
                                                    )
                                                        if Dialog.Opened:get() then
                                                            return 0
                                                        end

                                                        return 1
                                                    end, 40, 1),
                                                    BackgroundColor3 = Theme.stroke,
                                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                    BorderSizePixel = 0,
                                                    Position = UDim2.fromOffset(0, 0),
                                                    Size = UDim2.new(1, 0, 0, 1),
                                                },
                                                New'Frame'{
                                                    Name = 'Holder',
                                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                    BackgroundTransparency = 1,
                                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                    BorderSizePixel = 0,
                                                    Size = UDim2.fromScale(1, 1),
                                                    [Children] = {
                                                        New'UIListLayout'{
                                                            Name = 'UIListLayout',
                                                            Padding = UDim.new(0, 5),
                                                            FillDirection = Enum.FillDirection.Horizontal,
                                                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                                            VerticalAlignment = Enum.VerticalAlignment.Center,
                                                        },
                                                        New'UIPadding'{
                                                            Name = 'UIPadding',
                                                            PaddingRight = UDim.new(0, 10),
                                                        },
                                                        ForPairs(Dialog.Buttons, function(
                                                            index,
                                                            value
                                                        )
                                                            return index, value
                                                        end, Fusion.cleanup),
                                                    },
                                                },
                                            },
                                        },
                                        New'UIListLayout'{
                                            Name = 'UIListLayout',
                                            Padding = UDim.new(0, 15),
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                        },
                                    },
                                },
                                New'UICorner'{
                                    Name = 'UICorner',
                                    CornerRadius = UDim.new(0, 4),
                                },
                                New'UIStroke'{
                                    Name = 'UIStroke',
                                    Color = Theme.stroke,
                                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                    Transparency = animate(function()
                                        if Dialog.Opened:get() then
                                            return 0
                                        end

                                        return 1
                                    end, 40, 1),
                                },
                            },
                        },
                    },
                }

                function Dialog:AddButton(Config)
                    local isHovering = Value(false)
                    local isHeldDown = Value(false)
                    local Button = New'TextButton'{
                        Name = 'Frame',
                        FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                        Text = Config.Title,
                        AutomaticSize = Enum.AutomaticSize.X,
                        TextColor3 = animate(function()
                            local state = Config.Style

                            if state == 'default' then
                                if unwrap(isHovering) and not unwrap(isHeldDown) then
                                    return colorUtils.lightenRGB(Theme.tertiary_text:get(), 15)
                                end

                                return Theme.tertiary_text:get()
                            elseif state == 'primary' then
                                if unwrap(isHovering) and not unwrap(isHeldDown) then
                                    return colorUtils.lightenRGB(Theme.text:get(), 15)
                                end

                                return Theme.text:get()
                            end
                        end, 40, 1),
                        TextSize = 14,
                        BackgroundTransparency = animate(function()
                            if Dialog.Opened:get() then
                                return 0
                            end

                            return 1
                        end, 40, 1),
                        BackgroundColor3 = animate(function()
                            local state = Config.Style

                            if state == 'default' then
                                if unwrap(isHovering) and not unwrap(isHeldDown) then
                                    return colorUtils.darkenRGB(Theme.background:get(), 5)
                                end

                                return Theme.background:get()
                            elseif state == 'primary' then
                                if unwrap(isHovering) and not unwrap(isHeldDown) then
                                    return colorUtils.darkenRGB(Theme.accent:get(), 15)
                                end

                                return Theme.accent:get()
                            end
                        end, 40, 1),
                        TextTransparency = animate(function()
                            if Dialog.Opened:get() then
                                return 0
                            end

                            return 1
                        end, 40, 1),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromOffset(0, 28),
                        [Children] = {
                            New'UIStroke'{
                                Name = 'UIStroke',
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                Color = Theme.stroke,
                                Transparency = animate(function()
                                    if Dialog.Opened:get() then
                                        return 0
                                    end

                                    return 1
                                end, 40, 1),
                            },
                            New'UICorner'{
                                Name = 'UICorner',
                                CornerRadius = UDim.new(0, 4),
                            },
                            New'UIPadding'{
                                Name = 'UIPadding',
                                PaddingLeft = UDim.new(0, 10),
                                PaddingRight = UDim.new(0, 10),
                            },
                        },
                        [OnEvent('InputEnded')] = function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                isHeldDown:set(false)
                                safeCallback(function()
                                    if Config.Callback ~= nil and typeof(Config.Callback) == 'function' then
                                        Config.Callback()
                                    end
                                end)
                                Dialog:Close()
                            end
                        end,
                        [OnEvent('InputBegan')] = function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                isHeldDown:set(true)
                            end
                        end,
                        [OnEvent('MouseEnter')] = function()
                            isHovering:set(true)
                        end,
                        [OnEvent('MouseLeave')] = function()
                            isHovering:set(false)
                            isHeldDown:set(false)
                        end,
                    }

                    insertItem(Dialog.Buttons, Button)
                end
                function Dialog:Close()
                    Dialog.Opened:set(false)
                    task.wait(0.25)
                    Dialog.Root:Destroy()
                    Dialog.Connection:Disconnect()
                end

                Dialog.Connection = UserInputService.InputBegan:Connect(function(
                    Input
                )
                    if unwrap(Canvas) == nil then
                        Dialog.Connection:Disconnect()
                    end
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        local AbsPos, AbsSize = unwrap(Canvas).AbsolutePosition, unwrap(Canvas).AbsoluteSize

                        if UserInputService:GetMouseLocation().X < AbsPos.X or UserInputService:GetMouseLocation().X > AbsPos.X + AbsSize.X or UserInputService:GetMouseLocation().Y < (AbsPos.Y - 20 - 1) or UserInputService:GetMouseLocation().Y > AbsPos.Y + AbsSize.Y then
                            Dialog:Close()
                        end
                    end
                end)

                table.insert(unwrap(States.Library).Connections, Dialog.Connection)
                Dialog.Opened:set(true)

                return Dialog
            end

            return Module
        end)()
    end,
    [19] = function()
        local wax, script, require = ImportGlobals(19)

        return (function(...)
            local Utils = script.Parent.Parent.Parent.utils

            require(Utils.animate)
            require(Utils.color3)
            require(Utils.unwrap)
            require(Utils.insertitem)

            local Packages = script.Parent.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)
            require(Packages.states)

            local Children = Fusion.Children
            local _ = Fusion.Computed
            local ForPairs = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local _ = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local _ = Fusion.Ref
            local New = Fusion.New
            local _ = game:GetService('Workspace').CurrentCamera
            local Theme = require(script.Parent.Parent.Parent.storage.theme)

            return function(props)
                local Section = {
                    Components = Value({}),
                }

                Section.Root = New'Frame'{
                    Name = 'Section',
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Theme.secondary_background,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -35, 0, 0),
                    [Children] = {
                        New'UIStroke'{
                            Name = 'UIStroke',
                            Color = Theme.stroke,
                        },
                        New'UIListLayout'{
                            Name = 'UIListLayout',
                            Padding = UDim.new(0, 0),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        },
                        New'TextLabel'{
                            Name = 'Title',
                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            Text = props.Title,
                            TextColor3 = Theme.tertiary_text,
                            TextSize = 18,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 40),
                        },
                        New'UIPadding'{
                            Name = 'UIPadding',
                            PaddingBottom = UDim.new(0, 10),
                            PaddingLeft = UDim.new(0, 15),
                            PaddingTop = UDim.new(0, 5),
                        },
                        New'Frame'{
                            Name = 'Holder',
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 0),
                            [Children] = {
                                New'UIListLayout'{
                                    Name = 'UIListLayout',
                                    Padding = UDim.new(0, 10),
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                    VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                },
                                New'UIPadding'{
                                    Name = 'UIPadding',
                                    PaddingRight = UDim.new(0, 15),
                                },
                                ForPairs(Section.Components, function(
                                    index,
                                    value
                                )
                                    return index, value
                                end, Fusion.cleanup),
                            },
                        },
                    },
                }

                return Section
            end
        end)()
    end,
    [20] = function()
        local wax, script, require = ImportGlobals(20)

        return (function(...)
            local Utils = script.Parent.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local insertItem = require(Utils.insertitem)
            local Packages = script.Parent.Parent.Parent.packages
            local Fusion = require(Packages.fusion)

            require(Packages.snapdragon)

            local States = require(Packages.states)
            local Children = Fusion.Children
            local _ = Fusion.Computed
            local ForPairs = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local _ = Fusion.Ref
            local New = Fusion.New
            local Theme = require(script.Parent.Parent.Parent.storage.theme)

            return function(props)
                local Tab = {
                    Selected = Value(false),
                    Sections = Value({}),
                    nSections = 0,
                }
                local Elements = unwrap(States.Elements)
                local componentHolder = New('ScrollingFrame')({
                    Name = props.Title,
                    ScrollBarImageColor3 = Theme.tertiary_text,
                    ScrollBarThickness = 2,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Selectable = false,
                    Size = UDim2.fromScale(1, 1),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    Visible = Tab.Selected,
                    [Children] = {
                        New('UIPadding')({
                            Name = 'UIPadding',
                            PaddingTop = UDim.new(0, 15),
                            PaddingBottom = UDim.new(0, 15),
                        }),
                        New('UIListLayout')({
                            Name = 'UIListLayout',
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 10),
                        }),
                        ForPairs(Tab.Sections, function(index, value)
                            return index, value
                        end, Fusion.cleanup),
                    },
                })

                Tab.Root = New('TextButton')({
                    Name = props.Title,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    [Children] = {
                        New('TextLabel')({
                            Name = 'TextLabel',
                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                            Text = props.Title,
                            TextColor3 = animate(function()
                                if Tab.Selected:get() then
                                    return unwrap(Theme.text)
                                else
                                    return unwrap(Theme.tertiary_text)
                                end
                            end, 25, 1),
                            TextSize = 15,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(15, 0),
                            Size = UDim2.new(1, -15, 0, -10),
                        }),
                        New('Frame')({
                            Name = 'Indicator',
                            BackgroundColor3 = Theme.accent,
                            BackgroundTransparency = animate(function()
                                if Tab.Selected:get() then
                                    return 0
                                end

                                return 1
                            end, 25, 1),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 15, 1, 0),
                            Size = animate(function()
                                if Tab.Selected:get() then
                                    return UDim2.fromOffset(15, 4)
                                else
                                    return UDim2.fromOffset(0, 4)
                                end
                            end, 20, 1),
                            Visible = Tab.Selected,
                            [Children] = {
                                New('UICorner')({
                                    Name = 'UICorner',
                                }),
                            },
                        }),
                        New('UIListLayout')({
                            Name = 'UIListLayout',
                            Padding = UDim.new(0, 8),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }),
                        New('UIPadding')({
                            Name = 'UIPadding',
                            PaddingLeft = UDim.new(0, 15),
                        }),
                    },
                    [OnEvent('MouseButton1Click')] = function()
                        Tab:SetValue(true)
                    end,
                })

                States.add('Tabs', Tab, props.Title)
                States.add('Containers', componentHolder, props.Title)

                function Tab:SetValue(bool)
                    for _, v in pairs(unwrap(States.Tabs))do
                        v.Selected:set(false)
                    end

                    Tab.Selected:set(bool)
                end

                local SectionModule = require(script.Parent.section)

                function Tab:AddSection(SectionConfig)
                    local Section = {}

                    Section.Component = SectionModule({
                        Title = SectionConfig.Title,
                        Order = Tab.nSections,
                    })
                    Section.Container = Section.Component.Components

                    insertItem(Tab.Sections, Section.Component.Root)

                    Tab.nSections += 1

                    setmetatable(Section, Elements)

                    return Section
                end

                return Tab
            end
        end)()
    end,
    [21] = function()
        local wax, script, require = ImportGlobals(21)

        return (function(...)
            local Utils = script.Parent.Parent.Parent.utils
            local animate = require(Utils.animate)

            require(Utils.color3)

            local unwrap = require(Utils.unwrap)
            local Packages = script.Parent.Parent.Parent.packages
            local Fusion = require(Packages.fusion)
            local Snapdragon = require(Packages.snapdragon)
            local States = require(Packages.states)
            local Theme = require(script.Parent.Parent.Parent.storage.theme)
            local Children = Fusion.Children
            local Computed = Fusion.Computed
            local ForPairs = Fusion.ForPairs
            local _ = Fusion.Observer
            local _ = Fusion.OnChange
            local OnEvent = Fusion.OnEvent
            local Value = Fusion.Value
            local _ = Fusion.Tween
            local Ref = Fusion.Ref
            local New = Fusion.New
            local Camera = game:GetService('Workspace').CurrentCamera
            local UserInputService = game:GetService('UserInputService')

            return function(props)
                local Window = {Categorys = 1}
                local openedState = Value(false)
                local TopbarRef = Value()
                local ResizeRef = Value()
                local Resizing, ResizePos = Value(), Value()
                local Size = Value({
                    X = props.Size.X.Offset,
                    Y = props.Size.Y.Offset,
                })

                Value({
                    X = props.Size.X.Offset,
                    Y = props.Size.Y.Offset,
                })

                local MinimizeHovering = Value(false)
                local MinimizeHeldDown = Value(false)
                local CloseHovering = Value(false)
                local CloseHeldDown = Value(false)
                local WindowScale = Value()

                Window.Root = New('Frame')({
                    Name = 'GUI',
                    BackgroundColor3 = Theme.background,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(Camera.ViewportSize.X / 2 - props.Size.X.Offset / 2, Camera.ViewportSize.Y / 2 - props.Size.Y.Offset / 2),
                    Size = Computed(function()
                        return UDim2.fromOffset(Size:get().X, Size:get().Y)
                    end),
                    Visible = openedState,
                    Active = true,
                    Interactable = true,
                    [Children] = {
                        New('UICorner')({
                            Name = 'UICorner',
                            CornerRadius = UDim.new(0, 4),
                        }),
                        New('UIStroke')({
                            Name = 'UIStroke',
                            Color = Theme.stroke,
                        }),
                        New('UIScale')({
                            [Ref] = WindowScale,
                            Name = 'UIScale',
                        }),
                        New('ImageLabel')({
                            Name = 'Shadow',
                            Image = 'rbxassetid://9313765853',
                            ImageColor3 = Theme.background,
                            ImageTransparency = 0.45,
                            ScaleType = Enum.ScaleType.Slice,
                            SliceCenter = Rect.new(45, 45, 45, 45),
                            SliceScale = 1.2,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(27, 42, 53),
                            ClipsDescendants = true,
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.new(1, 75, 1, 75),
                            ZIndex = -50,
                        }),
                        New('Frame')({
                            [Ref] = ResizeRef,
                            Name = 'ResizeFrame',
                            AnchorPoint = Vector2.new(1, 1),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromScale(1, 1),
                            Size = UDim2.fromOffset(16, 16),
                            [OnEvent('InputBegan')] = function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                    Resizing:set(true)
                                    ResizePos:set(input.Position)
                                end
                            end,
                        }),
                        New('Frame')({
                            [Ref] = TopbarRef,
                            Name = 'Topbar',
                            BackgroundColor3 = Theme.secondary_background,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 45),
                            ZIndex = 1,
                            [Children] = {
                                New('Frame')({
                                    Name = 'Seperator',
                                    BackgroundColor3 = Theme.stroke,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.new(0, 0, 1, -1),
                                    Size = UDim2.new(1, 0, 0, 1),
                                }),
                                New('UICorner')({
                                    Name = 'UICorner',
                                    CornerRadius = UDim.new(0, 4),
                                }),
                                New('Frame')({
                                    Name = 'TextHolder',
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromOffset(15, 0),
                                    Size = UDim2.new(1, -15, 1, 0),
                                    [Children] = {
                                        New('TextLabel')({
                                            Name = 'Title',
                                            FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                            Text = props.Title,
                                            TextColor3 = Theme.text,
                                            TextSize = 16,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            AutomaticSize = Enum.AutomaticSize.X,
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromOffset(15, 0),
                                            Size = UDim2.new(0, 5, 1, 0),
                                        }),
                                        New('UIListLayout')({
                                            Name = 'UIListLayout',
                                            Padding = UDim.new(0, 7),
                                            FillDirection = Enum.FillDirection.Horizontal,
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                            VerticalAlignment = Enum.VerticalAlignment.Center,
                                        }),
                                        New('Frame')({
                                            Name = 'TagHolder',
                                            AutomaticSize = Enum.AutomaticSize.X,
                                            BackgroundColor3 = Theme.accent,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Size = UDim2.fromOffset(0, 15),
                                            [Children] = {
                                                New('TextLabel')({
                                                    Name = 'TagTitle',
                                                    FontFace = Font.new('rbxassetid://12187365364', Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                                                    Text = props.Tag,
                                                    TextColor3 = Color3.fromRGB(0, 0, 0),
                                                    TextSize = 12,
                                                    AutomaticSize = Enum.AutomaticSize.X,
                                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                                    BackgroundTransparency = 1,
                                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                                    BorderSizePixel = 0,
                                                    Size = UDim2.fromScale(1, 1),
                                                }),
                                                New('UIPadding')({
                                                    Name = 'UIPadding',
                                                    PaddingLeft = UDim.new(0, 5),
                                                    PaddingRight = UDim.new(0, 5),
                                                }),
                                                New('UICorner')({
                                                    Name = 'UICorner',
                                                    CornerRadius = UDim.new(0, 4),
                                                }),
                                            },
                                        }),
                                    },
                                }),
                                New('Frame')({
                                    Name = 'ButtonHolder',
                                    AnchorPoint = Vector2.new(1, 0),
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.new(1, -15, 0, 0),
                                    Size = UDim2.new(1, -15, 1, 0),
                                    [Children] = {
                                        New('UIListLayout')({
                                            Name = 'UIListLayout',
                                            Padding = UDim.new(0, 10),
                                            FillDirection = Enum.FillDirection.Horizontal,
                                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                            VerticalAlignment = Enum.VerticalAlignment.Center,
                                        }),
                                        New('ImageButton')({
                                            Name = 'Minimize',
                                            Image = 'rbxassetid://95268421208163',
                                            ImageColor3 = animate(function()
                                                if MinimizeHeldDown:get() then
                                                    return Theme.secondary_text:get()
                                                end
                                                if MinimizeHovering:get() then
                                                    return Theme.text:get()
                                                end

                                                return Theme.tertiary_text:get()
                                            end, 25, 1),
                                            Active = false,
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromScale(0.5, 0.5),
                                            Selectable = false,
                                            Size = UDim2.fromOffset(22, 22),
                                            [OnEvent('InputEnded')] = function(
                                                Input
                                            )
                                                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                                    MinimizeHeldDown:set(false)
                                                    Window:Minimize()
                                                end
                                            end,
                                            [OnEvent('InputBegan')] = function(
                                                Input
                                            )
                                                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                                    MinimizeHeldDown:set(true)
                                                end
                                            end,
                                            [OnEvent('MouseEnter')] = function()
                                                MinimizeHovering:set(true)
                                            end,
                                            [OnEvent('MouseLeave')] = function()
                                                MinimizeHovering:set(false)
                                                MinimizeHeldDown:set(false)
                                            end,
                                        }),
                                        New('ImageButton')({
                                            Name = 'Close',
                                            Image = 'rbxassetid://118425905671666',
                                            ImageColor3 = animate(function()
                                                if CloseHeldDown:get() then
                                                    return Theme.secondary_text:get()
                                                end
                                                if CloseHovering:get() then
                                                    return Theme.text:get()
                                                end

                                                return Theme.tertiary_text:get()
                                            end, 25, 1),
                                            Active = false,
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                            BackgroundTransparency = 1,
                                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                                            BorderSizePixel = 0,
                                            Position = UDim2.fromScale(0.5, 0.5),
                                            Selectable = false,
                                            Size = UDim2.fromOffset(22, 22),
                                            [OnEvent('InputEnded')] = function(
                                                Input
                                            )
                                                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                                    CloseHeldDown:set(false)
                                                    States.toDestroy:set(true)
                                                end
                                            end,
                                            [OnEvent('InputBegan')] = function(
                                                Input
                                            )
                                                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                                    CloseHeldDown:set(true)
                                                end
                                            end,
                                            [OnEvent('MouseEnter')] = function()
                                                CloseHovering:set(true)
                                            end,
                                            [OnEvent('MouseLeave')] = function()
                                                CloseHovering:set(false)
                                                CloseHeldDown:set(false)
                                            end,
                                        }),
                                    },
                                }),
                            },
                        }),
                        New('Frame')({
                            Name = 'Tablist',
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(0, 45),
                            Size = UDim2.new(0, 200, 1, -45),
                            ZIndex = 5,
                            [Children] = {
                                New('ScrollingFrame')({
                                    Name = 'Tablist',
                                    ScrollBarImageColor3 = Color3.fromRGB(32, 32, 44),
                                    ScrollBarThickness = 0,
                                    ScrollingDirection = Enum.ScrollingDirection.Y,
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                    BackgroundTransparency = 1,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Selectable = false,
                                    Size = UDim2.new(1, 0, 1, -15),
                                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                                    CanvasSize = UDim2.new(0, 0, 0, 0),
                                    [Children] = {
                                        New('UIListLayout')({
                                            Name = 'UIListLayout',
                                            Padding = UDim.new(0, 10),
                                            SortOrder = Enum.SortOrder.LayoutOrder,
                                        }),
                                        New('UIPadding')({
                                            Name = 'UIPadding',
                                            PaddingTop = UDim.new(0, 5),
                                        }),
                                        ForPairs(States.Categorys, function(
                                            index,
                                            value
                                        )
                                            return index, value
                                        end, Fusion.cleanup),
                                    },
                                }),
                                New('Frame')({
                                    Name = 'Seperator',
                                    BackgroundColor3 = Theme.stroke,
                                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                                    BorderSizePixel = 0,
                                    Position = UDim2.fromScale(1, 0),
                                    Size = UDim2.new(0, -1, 1, 0),
                                }),
                            },
                        }),
                        New('Frame')({
                            Name = 'Containers',
                            AnchorPoint = Vector2.new(1, 0),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            Position = UDim2.new(1, 0, 0, 45),
                            Size = UDim2.new(1, -200, 1, -55),
                            SelectionGroup = true,
                            [Children] = {
                                ForPairs(States.Containers, function(
                                    index,
                                    value
                                )
                                    return index, value
                                end, Fusion.cleanup),
                            },
                        }),
                    },
                })

                UserInputService.InputChanged:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and Resizing:get() then
                        local StartSize = UDim2.fromOffset(Size:get().X, Size:get().Y)
                        local TargetSize = Vector3.new(StartSize.X.Offset, StartSize.Y.Offset, 0) + Vector3.new(1, 1, 0) * (input.Position - ResizePos:get())
                        local TargetSizeClamped = Vector2.new(math.clamp(TargetSize.X, 470, 2048), math.clamp(TargetSize.Y, 380, 2048))

                        Size:set({
                            X = TargetSizeClamped.X,
                            Y = TargetSizeClamped.Y,
                        })
                        ResizePos:set(input.Position)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if Resizing:get() then
                            Resizing:set(false)
                        end
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if type(unwrap(States.MinimizeKeybind)) == 'table' and unwrap(States.MinimizeKeybind).Type == 'Keybind' and not UserInputService:GetFocusedTextBox() then
                        if input.KeyCode.Name == unwrap(States.MinimizeKeybind).Value then
                            Window:Minimize()
                        end
                    elseif input.KeyCode == unwrap(States.MinimizeKey) and not UserInputService:GetFocusedTextBox() then
                        Window:Minimize()
                    end
                end)

                function Window:Minimize()
                    openedState:set(not openedState:get())

                    if not MinimizeNotif then
                        MinimizeNotif = true

                        unwrap(States.MinimizeKey)
                    end
                end

                local CategoryModule = require(script.Parent.category)

                function Window:AddCategory(CategoryConfig)
                    local Category = CategoryModule({
                        Title = CategoryConfig.Title,
                        Order = Window.Categorys,
                    })

                    States.add('Categorys', Category.Root, CategoryConfig.Title)

                    Window.Categorys += 1

                    return Category
                end

                local DialogModule = require(script.Parent.dialog)

                DialogModule:init(Window.Root)

                function Window:Dialog(Config)
                    local Dialog = DialogModule:Create(Config)

                    return Dialog
                end
                function Window:SetScale(Scale)
                    unwrap(WindowScale).Scale = Scale
                end

                States.add('Objects', Window.Root, props.Title)
                Snapdragon.createDragController(unwrap(TopbarRef), {
                    DragGui = unwrap(Window.Root),
                    SnapEnabled = true,
                }):Connect()
                openedState:set(true)

                return Window
            end
        end)()
    end,
    [22] = function()
        local wax, script, require = ImportGlobals(22)

        return (function(...)
            local Fusion = require(script.Parent.packages.fusion)
            local story = {
                fusion = Fusion,
                story = function(props)
                    local start = tick()
                    local Library = require(script.Parent)
                    local Window = Library:CreateWindow({
                        Title = 'ZEN X',
                        Tag = 'DEMON HUNTER',
                        Size = UDim2.fromOffset(800, 500),
                        Parent = props.target,
                        Debug = true,
                    })
                    local Categories = {
                        Universal = Window:AddCategory({
                            Title = 'UNIVERSAL',
                        }),
                        Settings = Window:AddCategory({
                            Title = 'SETTINGS',
                        }),
                        Movement = Window:AddCategory({
                            Title = 'MOVEMENT',
                        }),
                        Combat = Window:AddCategory({
                            Title = 'COMBAT',
                        }),
                        Misc = Window:AddCategory({
                            Title = 'MISC',
                        }),
                        Rage = Window:AddCategory({
                            Title = 'RAGE',
                        }),
                    }
                    local Tabs = {
                        Aimbot = Categories.Universal:AddTab({
                            Title = 'Aimbot',
                        }),
                        TriggerBot = Categories.Universal:AddTab({
                            Title = 'TriggerBot',
                        }),
                        Checks = Categories.Universal:AddTab({
                            Title = 'Checks',
                        }),
                        Visuals = Categories.Universal:AddTab({
                            Title = 'Visuals',
                        }),
                        Settings = Categories.Settings:AddTab({
                            Title = 'Settings',
                        }),
                        Theme = Categories.Settings:AddTab({
                            Title = 'Theme',
                        }),
                        Showcase = Categories.Settings:AddTab({
                            Title = 'Showcase',
                        }),
                        Configs = Categories.Settings:AddTab({
                            Title = 'Configs',
                        }),
                        Speed = Categories.Movement:AddTab({
                            Title = 'Speed',
                        }),
                        Flight = Categories.Movement:AddTab({
                            Title = 'Flight',
                        }),
                        Teleport = Categories.Movement:AddTab({
                            Title = 'Teleport',
                        }),
                        Bhop = Categories.Movement:AddTab({
                            Title = 'Bunny Hop',
                        }),
                        Weapons = Categories.Combat:AddTab({
                            Title = 'Weapons',
                        }),
                        Player = Categories.Combat:AddTab({
                            Title = 'Player',
                        }),
                        AutoParry = Categories.Combat:AddTab({
                            Title = 'Auto Parry',
                        }),
                        Reach = Categories.Combat:AddTab({
                            Title = 'Reach',
                        }),
                        World = Categories.Misc:AddTab({
                            Title = 'World',
                        }),
                        Exploits = Categories.Misc:AddTab({
                            Title = 'Exploits',
                        }),
                        Trolling = Categories.Misc:AddTab({
                            Title = 'Trolling',
                        }),
                        Farming = Categories.Misc:AddTab({
                            Title = 'Auto Farm',
                        }),
                        RageBot = Categories.Rage:AddTab({
                            Title = 'Rage Bot',
                        }),
                        AntiAim = Categories.Rage:AddTab({
                            Title = 'Anti Aim',
                        }),
                        Resolver = Categories.Rage:AddTab({
                            Title = 'Resolver',
                        }),
                    }
                    local AimbotSection = Tabs.Aimbot:AddSection({
                        Title = 'AIMBOT',
                    })

                    AimbotSection:AddColorpicker('colorpick22er', {
                        Title = 'oko2k323',
                        Description = 'Toggles the colorpicker',
                        Default = Color3.fromRGB(96, 205, 255),
                        Callback = function(value)
                            print(value)
                        end,
                    })
                    AimbotSection:AddToggle('AimbotToggle', {
                        Title = 'Aimbot',
                        Description = 'Toggles the Aimbot',
                        Default = false,
                        Callback = function()
                            print('Aimbot toggled')
                            Window:Dialog({
                                Title = 'Dialog',
                                Description = 'This is a dialog',
                                Buttons = {
                                    {
                                        Title = 'Button',
                                        Callback = function()
                                            print('Button pressed')
                                        end,
                                    },
                                },
                            })
                        end,
                    })
                    AimbotSection:AddToggle('OnePressModeToggle', {
                        Title = 'One-Press Mode',
                        Description = 'Uses the One-Press Mode instead of the Holding Mode',
                        Default = false,
                        Callback = function()
                            print('One-Press Mode toggled')
                        end,
                    })
                    AimbotSection:AddDropdown('AimMode', {
                        Title = 'Aim Mode',
                        Description = 'Changes the Aim Mode',
                        Values = {
                            'Camera',
                            'Silent',
                        },
                        Default = 'Camera',
                    })
                    AimbotSection:AddDropdown('SilentAimMethods', {
                        Title = 'Silent Aim Methods',
                        Description = 'Sets the Silent Aim Methods',
                        Values = {
                            'Mouse.Hit / Mouse.Target',
                            'GetMouseLocation',
                            'Raycast',
                            'FindPartOnRay',
                            'FindPartOnRayWithIgnoreList',
                            'FindPartOnRayWithWhitelist',
                        },
                        Multi = true,
                        Default = {},
                    })
                    AimbotSection:AddSlider('SilentAimChance', {
                        Title = 'Silent Aim Chance',
                        Description = 'Changes the Hit Chance for Silent Aim',
                        Default = 100,
                        Min = 1,
                        Max = 100,
                        Rounding = 1,
                    })

                    local AimOffsetSection = Tabs.Aimbot:AddSection({
                        Title = 'AIM OFFSET',
                    })

                    AimOffsetSection:AddToggle('UseOffsetToggle', {
                        Title = 'Use Offset',
                        Description = 'Toggles the Offset',
                        Default = false,
                        Callback = function()
                            print('Use Offset toggled')
                        end,
                    })
                    AimOffsetSection:AddDropdown('OffsetType', {
                        Title = 'Offset Type',
                        Description = 'Changes the Offset Type',
                        Values = {
                            'Static',
                            'Dynamic',
                            'Static & Dynamic',
                        },
                        Default = 'Static',
                    })
                    AimOffsetSection:AddSlider('StaticOffset', {
                        Title = 'Static Offset',
                        Description = 'Changes the Static Offset Increment',
                        Default = 25,
                        Min = 1,
                        Max = 50,
                        Rounding = 1,
                    })
                    AimOffsetSection:AddSlider('DynamicOffset', {
                        Title = 'Dynamic Offset',
                        Description = 'Changes the Dynamic Offset Increment',
                        Default = 25,
                        Min = 1,
                        Max = 50,
                        Rounding = 1,
                    })

                    local SimpleChecksSection = Tabs.Checks:AddSection({
                        Title = 'SIMPLE CHECKS',
                    })

                    SimpleChecksSection:AddToggle('AliveCheckToggle', {
                        Title = 'Alive Check',
                        Description = 'Toggles the Alive Check',
                        Default = true,
                        Callback = function()
                            print('Alive Check toggled')
                        end,
                    })
                    SimpleChecksSection:AddToggle('TeamCheckToggle', {
                        Title = 'Team Check',
                        Description = 'Toggles the Team Check',
                        Default = true,
                        Callback = function()
                            print('Team Check toggled')
                        end,
                    })
                    SimpleChecksSection:AddToggle('WallCheckToggle', {
                        Title = 'Wall Check',
                        Description = 'Toggles the Wall Check',
                        Default = true,
                        Callback = function()
                            print('Wall Check toggled')
                        end,
                    })
                    SimpleChecksSection:AddToggle('FriendCheckToggle', {
                        Title = 'Friend Check',
                        Description = 'Toggles the Friend Check',
                        Default = false,
                        Callback = function()
                            print('Friend Check toggled')
                        end,
                    })

                    local AdvancedChecksSection = Tabs.Checks:AddSection({
                        Title = 'ADVANCED CHECKS',
                    })

                    AdvancedChecksSection:AddToggle('FoVCheckToggle', {
                        Title = 'FoV Check',
                        Description = 'Toggles the FoV Check',
                        Default = true,
                        Callback = function()
                            print('FoV Check toggled')
                        end,
                    })
                    AdvancedChecksSection:AddSlider('FoVRadius', {
                        Title = 'FoV Radius',
                        Description = 'Changes the FoV Radius',
                        Default = 100,
                        Min = 10,
                        Max = 1000,
                        Rounding = 1,
                    })
                    AdvancedChecksSection:AddToggle('MagnitudeCheckToggle', {
                        Title = 'Magnitude Check',
                        Description = 'Toggles the Magnitude Check',
                        Default = false,
                        Callback = function()
                            print('Magnitude Check toggled')
                        end,
                    })

                    local FoVSection = Tabs.Visuals:AddSection({
                        Title = 'FOV',
                    })

                    FoVSection:AddToggle('ShowFoVToggle', {
                        Title = 'Show FoV',
                        Description = 'Graphically Displays the FoV Radius',
                        Default = true,
                        Callback = function()
                            print('Show FoV toggled')
                        end,
                    })
                    FoVSection:AddSlider('FovThickness', {
                        Title = 'FoV Thickness',
                        Description = 'Changes the FoV Thickness',
                        Default = 1,
                        Min = 1,
                        Max = 10,
                        Rounding = 1,
                    })
                    FoVSection:AddSlider('FovOpacity', {
                        Title = 'FoV Opacity',
                        Description = 'Changes the FoV Opacity',
                        Default = 0.5,
                        Min = 0.1,
                        Max = 1,
                        Rounding = 1,
                    })

                    local ESPSection = Tabs.Visuals:AddSection({
                        Title = 'ESP',
                    })

                    ESPSection:AddToggle('ESPToggle', {
                        Title = 'ESP',
                        Description = 'Toggles ESP Features',
                        Default = false,
                        Callback = function()
                            print('ESP toggled')
                        end,
                    })
                    ESPSection:AddToggle('BoxESPToggle', {
                        Title = 'Box ESP',
                        Description = 'Creates the ESP Box around Players',
                        Default = false,
                        Callback = function()
                            print('Box ESP toggled')
                        end,
                    })
                    ESPSection:AddToggle('NameESPToggle', {
                        Title = 'Name ESP',
                        Description = 'Shows Player Names',
                        Default = false,
                        Callback = function()
                            print('Name ESP toggled')
                        end,
                    })
                    ESPSection:AddDropdown('ESPFont', {
                        Title = 'ESP Font',
                        Description = 'Changes the ESP Font',
                        Values = {
                            'UI',
                            'System',
                            'Plex',
                            'Monospace',
                        },
                        Default = 'UI',
                    })

                    local UISection = Tabs.Settings:AddSection({
                        Title = 'UI SETTINGS',
                    })

                    UISection:AddDropdown('Theme', {
                        Title = 'Theme',
                        Description = 'Changes the UI Theme',
                        Values = {
                            'Default',
                            'Light',
                            'Dark',
                            'Discord',
                        },
                        Default = 'Default',
                    })
                    UISection:AddToggle('TransparencyToggle', {
                        Title = 'Transparency',
                        Description = 'Makes the UI Transparent',
                        Default = false,
                        Callback = function()
                            print('Transparency toggled')
                        end,
                    })

                    local NotificationsSection = Tabs.Settings:AddSection({
                        Title = 'NOTIFICATIONS',
                    })

                    NotificationsSection:AddToggle('ShowNotificationsToggle', {
                        Title = 'Show Notifications',
                        Description = 'Toggles the Notifications Show',
                        Default = true,
                        Callback = function()
                            print('Show Notifications toggled')
                        end,
                    })
                    NotificationsSection:AddToggle('ShowWarningsToggle', {
                        Title = 'Show Warnings',
                        Description = 'Toggles the Security Warnings Show',
                        Default = true,
                        Callback = function()
                            print('Show Warnings toggled')
                        end,
                    })

                    local ConfigSection = Tabs.Settings:AddSection({
                        Title = 'CONFIGURATION',
                    })

                    ConfigSection:AddButton({
                        Title = 'Import Configuration',
                        Style = 'primary',
                        Description = 'Load saved configuration',
                    })
                    ConfigSection:AddButton({
                        Title = 'Export Configuration',
                        Style = 'primary',
                        Description = 'Save current configuration',
                    })
                    ConfigSection:AddButton({
                        Title = 'Reset Configuration',
                        Style = 'primary',
                        Description = 'Reset to default settings',
                    })

                    local ThemeSection = Tabs.Theme:AddSection({
                        Title = 'THEME CUSTOMIZATION',
                    })

                    ThemeSection:AddDropdown('ThemePicker', {
                        Title = 'Theme',
                        Description = 'Select UI Theme',
                        Values = {
                            'dark',
                            'twilight',
                            'shadow',
                            'dusk',
                            'obsidian',
                            'charcoal',
                            'slate',
                            'onyx',
                            'ash',
                            'granite',
                            'cobalt',
                            'aurora',
                            'sunset',
                            'mocha',
                            'abyss',
                            'void',
                            'noir',
                        },
                        Default = 'noir',
                        Callback = function(value)
                            Library:SetTheme(value)
                        end,
                    })
                    ThemeSection:AddSlider('UIScale', {
                        Title = 'UI Scale',
                        Description = 'Adjusts the UI Size',
                        Default = 100,
                        Min = 75,
                        Max = 150,
                        Rounding = 1,
                    })
                    ThemeSection:AddSlider('BOpacity', {
                        Title = 'Background Opacity',
                        Description = 'Adjusts Background Transparency',
                        Default = 1,
                        Min = 0.1,
                        Max = 1,
                        Rounding = 1,
                    })
                    ThemeSection:AddSlider('RainbowSpeed', {
                        Title = 'Rainbow Speed',
                        Description = 'Adjusts Rainbow Effect Speed',
                        Default = 0.5,
                        Min = 0.1,
                        Max = 1,
                        Rounding = 1,
                    })

                    local SpeedSection = Tabs.Speed:AddSection({
                        Title = 'SPEED MODIFICATIONS',
                    })

                    SpeedSection:AddToggle('SpeedHackToggle', {
                        Title = 'Speed Hack',
                        Description = 'Modifies player movement speed',
                        Default = false,
                    })
                    SpeedSection:AddDropdown('SpeedMode', {
                        Title = 'Speed Mode',
                        Description = 'Select speed modification type',
                        Values = {
                            'CFrame',
                            'Velocity',
                            'WalkSpeed',
                            'Custom',
                        },
                        Default = 'CFrame',
                    })
                    SpeedSection:AddSlider('SpeedMultiplier', {
                        Title = 'Speed Multiplier',
                        Description = 'Adjusts speed multiplication factor',
                        Default = 2,
                        Min = 1,
                        Max = 10,
                        Rounding = 1,
                    })

                    local FlightSection = Tabs.Flight:AddSection({
                        Title = 'FLIGHT CONTROLS',
                    })

                    FlightSection:AddToggle('FlightToggle', {
                        Title = 'Flight',
                        Description = 'Enables player flight',
                        Default = false,
                    })
                    FlightSection:AddDropdown('FlightMode', {
                        Title = 'Flight Mode',
                        Description = 'Select flight behavior',
                        Values = {
                            'CFrame',
                            'Velocity',
                            'Floating',
                            'Noclip',
                        },
                        Default = 'CFrame',
                    })

                    local WeaponsSection = Tabs.Weapons:AddSection({
                        Title = 'WEAPON MODIFICATIONS',
                    })

                    WeaponsSection:AddToggle('NoRecoilToggle', {
                        Title = 'No Recoil',
                        Description = 'Removes weapon recoil',
                        Default = false,
                    })
                    WeaponsSection:AddToggle('NoSpreadToggle', {
                        Title = 'No Spread',
                        Description = 'Removes bullet spread',
                        Default = false,
                    })
                    WeaponsSection:AddSlider('FireRateMultiplier', {
                        Title = 'Fire Rate Multiplier',
                        Description = 'Modifies weapon fire rate',
                        Default = 1,
                        Min = 1,
                        Max = 5,
                        Rounding = 1,
                    })

                    local PlayerCombatSection = Tabs.Player:AddSection({
                        Title = 'PLAYER COMBAT',
                    })

                    PlayerCombatSection:AddToggle('AutoBlockToggle', {
                        Title = 'Auto Block',
                        Description = 'Automatically blocks incoming damage',
                        Default = false,
                    })
                    PlayerCombatSection:AddToggle('KillAuraToggle', {
                        Title = 'Kill Aura',
                        Description = 'Damages nearby players automatically',
                        Default = false,
                    })
                    PlayerCombatSection:AddSlider('KillAuraRange', {
                        Title = 'Kill Aura Range',
                        Description = 'Sets the kill aura radius',
                        Default = 10,
                        Min = 5,
                        Max = 30,
                        Rounding = 1,
                    })

                    local WorldSection = Tabs.World:AddSection({
                        Title = 'WORLD MODIFICATIONS',
                    })

                    WorldSection:AddToggle('FullbrightToggle', {
                        Title = 'Fullbright',
                        Description = 'Removes darkness and shadows',
                        Default = false,
                    })
                    WorldSection:AddToggle('XRayToggle', {
                        Title = 'X-Ray',
                        Description = 'See through walls',
                        Default = false,
                    })
                    WorldSection:AddDropdown('TimeOfDay', {
                        Title = 'Time of Day',
                        Description = 'Changes the lighting',
                        Values = {
                            'Day',
                            'Night',
                            'Dawn',
                            'Dusk',
                        },
                        Default = 'Day',
                    })

                    local ExploitsSection = Tabs.Exploits:AddSection({
                        Title = 'GAME EXPLOITS',
                    })

                    ExploitsSection:AddToggle('AntiKickToggle', {
                        Title = 'Anti-Kick',
                        Description = 'Attempts to prevent kicks',
                        Default = false,
                    })
                    ExploitsSection:AddToggle('AntiCheatBypassToggle', {
                        Title = 'Anti-Cheat Bypass',
                        Description = 'Attempts to bypass anti-cheat',
                        Default = false,
                    })
                    ExploitsSection:AddDropdown('BypassMode', {
                        Title = 'Bypass Mode',
                        Description = 'Select bypass method',
                        Values = {
                            'Basic',
                            'Advanced',
                            'Experimental',
                        },
                        Default = 'Basic',
                    })

                    local AdvancedESPSection = Tabs.Visuals:AddSection({
                        Title = 'ADVANCED ESP',
                    })

                    AdvancedESPSection:AddToggle('SkeletonESPToggle', {
                        Title = 'Skeleton ESP',
                        Description = 'Shows player bone structure',
                        Default = false,
                    })
                    AdvancedESPSection:AddToggle('HealthBarToggle', {
                        Title = 'Health Bars',
                        Description = 'Shows player health bars',
                        Default = false,
                    })
                    AdvancedESPSection:AddToggle('ChamsToggle', {
                        Title = 'Chams',
                        Description = 'Shows players through walls with custom rendering',
                        Default = false,
                    })
                    AdvancedESPSection:AddDropdown('ChamsStyle', {
                        Title = 'Chams Style',
                        Description = 'Changes the chams appearance',
                        Values = {
                            'Flat',
                            'Ghost',
                            'Pulse',
                            'Rainbow',
                        },
                        Default = 'Flat',
                    })

                    local TriggerMainSection = Tabs.TriggerBot:AddSection({
                        Title = 'TRIGGERBOT MAIN',
                    })

                    TriggerMainSection:AddToggle('TriggerBotToggle', {
                        Title = 'TriggerBot',
                        Description = 'Automatically shoots when crosshair is on target',
                        Default = false,
                    })
                    TriggerMainSection:AddDropdown('TriggerMode', {
                        Title = 'Trigger Mode',
                        Description = 'Select trigger activation method',
                        Values = {
                            'On Hover',
                            'On Key Hold',
                            'Toggle Mode',
                            'Smart Trigger',
                        },
                        Default = 'On Hover',
                    })
                    TriggerMainSection:AddSlider('TriggerDelay', {
                        Title = 'Trigger Delay',
                        Description = 'Delay before triggering (ms)',
                        Default = 100,
                        Min = 0,
                        Max = 500,
                        Rounding = 1,
                    })

                    local TriggerAdvancedSection = Tabs.TriggerBot:AddSection({
                        Title = 'ADVANCED TRIGGER',
                    })

                    TriggerAdvancedSection:AddToggle('SmartPredictionToggle', {
                        Title = 'Smart Prediction',
                        Description = 'Predicts target movement for better accuracy',
                        Default = false,
                    })
                    TriggerAdvancedSection:AddToggle('AutoStopToggle', {
                        Title = 'Auto Stop',
                        Description = 'Stops movement when triggering for better accuracy',
                        Default = false,
                    })
                    TriggerAdvancedSection:AddToggle('ReactionTimeSimulation', {
                        Title = 'Reaction Time Simulation',
                        Description = 'Simulates human reaction time',
                        Default = false,
                    })

                    local TriggerFilterSection = Tabs.TriggerBot:AddSection({
                        Title = 'TRIGGER FILTERS',
                    })

                    TriggerFilterSection:AddDropdown('HitboxPriority', {
                        Title = 'Hitbox Priority',
                        Description = 'Select priority hitboxes for trigger',
                        Values = {
                            'Head',
                            'Upper Torso',
                            'Lower Torso',
                            'Arms',
                            'Legs',
                        },
                        Multi = true,
                        Default = {
                            'Head',
                            'Upper Torso',
                        },
                    })
                    TriggerFilterSection:AddToggle('SmartTargetingToggle', {
                        Title = 'Smart Targeting',
                        Description = 'Prioritizes targets based on threat level',
                        Default = false,
                    })

                    local AutoParrySection = Tabs.AutoParry:AddSection({
                        Title = 'AUTO PARRY',
                    })

                    AutoParrySection:AddToggle('AutoParryToggle', {
                        Title = 'Auto Parry',
                        Description = 'Automatically parries incoming attacks',
                        Default = false,
                    })
                    AutoParrySection:AddDropdown('ParryMode', {
                        Title = 'Parry Mode',
                        Description = 'Select parry behavior',
                        Values = {
                            'Aggressive',
                            'Defensive',
                            'Balanced',
                            'Custom',
                        },
                        Default = 'Balanced',
                    })

                    local ReachSection = Tabs.Reach:AddSection({
                        Title = 'REACH MODIFICATIONS',
                    })

                    ReachSection:AddToggle('ReachToggle', {
                        Title = 'Reach',
                        Description = 'Extends attack range',
                        Default = false,
                    })
                    ReachSection:AddSlider('ReachMultiplier', {
                        Title = 'Reach Multiplier',
                        Description = 'Adjusts reach distance',
                        Default = 1.5,
                        Min = 1,
                        Max = 4,
                        Rounding = 1,
                    })

                    local RageBotSection = Tabs.RageBot:AddSection({
                        Title = 'RAGE BOT',
                    })

                    RageBotSection:AddToggle('RageBotToggle', {
                        Title = 'Rage Bot',
                        Description = 'Enables extreme targeting measures',
                        Default = false,
                    })
                    RageBotSection:AddDropdown('RageTargetingMode', {
                        Title = 'Targeting Mode',
                        Description = 'Select targeting behavior',
                        Values = {
                            'Closest',
                            'Most Damage',
                            'Random',
                            'Smart',
                        },
                        Default = 'Closest',
                    })

                    local AntiAimSection = Tabs.AntiAim:AddSection({
                        Title = 'ANTI AIM',
                    })

                    AntiAimSection:AddToggle('AntiAimToggle', {
                        Title = 'Anti Aim',
                        Description = 'Makes you harder to hit',
                        Default = false,
                    })
                    AntiAimSection:AddDropdown('AntiAimType', {
                        Title = 'Anti Aim Type',
                        Description = 'Select anti aim behavior',
                        Values = {
                            'Spin',
                            'Jitter',
                            'Static',
                            'Random',
                        },
                        Default = 'Spin',
                    })

                    local ResolverSection = Tabs.Resolver:AddSection({
                        Title = 'RESOLVER',
                    })

                    ResolverSection:AddToggle('ResolverToggle', {
                        Title = 'Resolver',
                        Description = 'Attempts to resolve anti-aim',
                        Default = false,
                    })
                    ResolverSection:AddDropdown('ResolverMode', {
                        Title = 'Resolver Mode',
                        Description = 'Select resolver method',
                        Values = {
                            'Brute Force',
                            'Prediction',
                            'Adaptive',
                            'Learning',
                        },
                        Default = 'Adaptive',
                    })

                    local TrollingSection = Tabs.Trolling:AddSection({
                        Title = 'TROLLING',
                    })

                    TrollingSection:AddToggle('VoiceSpamToggle', {
                        Title = 'Voice Command Spam',
                        Description = 'Spams voice commands',
                        Default = false,
                    })
                    TrollingSection:AddToggle('EmoteSpamToggle', {
                        Title = 'Emote Spam',
                        Description = 'Spams emotes',
                        Default = false,
                    })

                    local AutoFarmSection = Tabs.Farming:AddSection({
                        Title = 'AUTO FARMING',
                    })

                    AutoFarmSection:AddToggle('AutoFarmToggle', {
                        Title = 'Auto Farm',
                        Description = 'Automatically farms resources/kills',
                        Default = false,
                    })
                    AutoFarmSection:AddDropdown('FarmingMode', {
                        Title = 'Farming Mode',
                        Description = 'Select farming behavior',
                        Values = {
                            'XP Farm',
                            'Resource Farm',
                            'Kill Farm',
                            'Custom',
                        },
                        Default = 'XP Farm',
                    })

                    local BhopSection = Tabs.Bhop:AddSection({
                        Title = 'BUNNY HOP',
                    })

                    BhopSection:AddToggle('BhopToggle', {
                        Title = 'Bunny Hop',
                        Description = 'Automatically jumps for increased speed',
                        Default = false,
                    })
                    BhopSection:AddDropdown('BhopStyle', {
                        Title = 'Bhop Style',
                        Description = 'Select hopping pattern',
                        Values = {
                            'Normal',
                            'Rage',
                            'Legit',
                            'Custom',
                        },
                        Default = 'Normal',
                    })

                    local TeleportSection = Tabs.Teleport:AddSection({
                        Title = 'TELEPORT',
                    })

                    TeleportSection:AddButton({
                        Title = 'Teleport to Spawn',
                        Description = 'Instantly teleport to spawn point',
                        Style = 'default',
                        Callback = function()
                            local Dialog = Window:Dialog({
                                Title = 'DIALOG',
                                Description = 'This is the dialog component of the UI Library Kyanos.',
                            })

                            Dialog:AddButton({
                                Title = 'Go Back',
                                Style = 'default',
                            })
                            Dialog:AddButton({
                                Title = 'Continue',
                                Style = 'primary',
                                Callback = function()
                                    local SecondDialog = Window:Dialog({
                                        Title = 'ANOTHER DIALOG',
                                        Description = 
[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mollis dolor eget erat mattis, id mollis mauris cursus. Proin ornare sollicitudin odio, id posuere diam luctus id.]],
                                    })

                                    SecondDialog:AddButton({
                                        Title = 'OK',
                                        Style = 'default',
                                    })
                                end,
                            })
                        end,
                    })
                    TeleportSection:AddDropdown('SavedLocations', {
                        Title = 'Saved Locations',
                        Description = 'Select location to teleport',
                        Values = {
                            'Spawn',
                            'Base',
                            'Shop',
                            'Custom 1',
                            'Custom 2',
                        },
                        Default = 'Spawn',
                    })
                    TeleportSection:AddInput('WaypointInput', {
                        Title = 'Add Waypoint',
                        Description = 'Add and save a waypoint to teleport to.',
                        Default = 'Default',
                        Placeholder = 'Placeholder',
                        Numeric = false,
                        Finished = false,
                        Callback = function(Value)
                            print('Input changed:', Value)
                        end,
                    })

                    local ElementsSection = Tabs.Showcase:AddSection({
                        Title = 'UI ELEMENTS',
                    })

                    ElementsSection:AddToggle('ShowcaseToggle', {
                        Title = 'Toggle Element',
                        Description = 'Demonstrates the toggle UI element',
                        Default = false,
                    })
                    ElementsSection:AddSlider('ShowcaseSlider', {
                        Title = 'Slider Element',
                        Description = 'Demonstrates the slider UI element',
                        Default = 50,
                        Min = 0,
                        Max = 100,
                        Increment = 1,
                    })
                    ElementsSection:AddDropdown('ShowcaseDropdown', {
                        Title = 'Dropdown Element',
                        Description = 'Demonstrates the dropdown UI element',
                        Values = {
                            'Option 1',
                            'Option 2',
                            'Option 3',
                        },
                        Default = 'Option 1',
                    })
                    ElementsSection:AddColorpicker('ShowcaseColorPicker', {
                        Title = 'Color Picker Element',
                        Description = 'Demonstrates the color picker UI element',
                        Default = Color3.fromRGB(255, 255, 255),
                    })
                    ElementsSection:AddButton({
                        Title = 'Button Element',
                        Description = 'Demonstrates the button UI element',
                        Style = 'default',
                        Callback = function()
                            Window:Dialog({
                                Title = 'Dialog Element',
                                Description = 'Demonstrates the dialog UI element',
                                Buttons = {
                                    {
                                        Title = 'OK',
                                        Callback = function() end,
                                    },
                                },
                            })
                        end,
                    })
                    ElementsSection:AddInput('ShowcaseInput', {
                        Title = 'Text Input Element',
                        Description = 'Demonstrates the text input UI element',
                        Default = 'Sample text',
                        Placeholder = 'Type something...',
                    })
                    ElementsSection:AddKeybind('ShowcaseKeybind', {
                        Title = 'Keybind Element',
                        Description = 'Demonstrates the keybind UI element',
                        Default = Enum.KeyCode.E,
                    })
                    ElementsSection:AddButton({
                        Title = 'Primary Action',
                        Style = 'primary',
                        Description = 'Perform primary action',
                        Callback = function()
                            print('Primary button clicked')
                        end,
                    })
                    ElementsSection:AddButton({
                        Title = 'Danger Action',
                        Style = 'danger',
                        Description = 'Perform dangerous action',
                        Callback = function()
                            print('Danger button clicked')
                        end,
                    })
                    ElementsSection:AddButton({
                        Title = 'Warning Action',
                        Style = 'warning',
                        Description = 'Perform action with caution',
                        Callback = function()
                            print('Warning button clicked')
                        end,
                    })
                    ElementsSection:AddButton({
                        Title = 'Default Action',
                        Style = 'default',
                        Description = 'Perform default action',
                        Callback = function()
                            print('Default button clicked')
                        end,
                    })

                    local ShowcaseSection = Tabs.Showcase:AddSection({
                        Title = 'THEME PREVIEW',
                    })

                    ShowcaseSection:AddText({
                        Title = 'Preview Text',
                        Description = 'This is a text element.',
                    })
                    ShowcaseSection:AddDropdown('ShowcaseTheme', {
                        Title = 'Theme',
                        Description = 'Change the UI theme to preview',
                        Values = {
                            'dark',
                            'twilight',
                            'shadow',
                            'dusk',
                            'obsidian',
                            'charcoal',
                            'slate',
                            'onyx',
                            'ash',
                            'granite',
                            'cobalt',
                            'aurora',
                            'sunset',
                            'mocha',
                            'abyss',
                            'void',
                            'noir',
                        },
                        Default = 'dark',
                        Callback = function(value)
                            Library:SetTheme(value)
                        end,
                    })
                    print('Loaded in', tick() - start)

                    return function()
                        Library:Destroy()
                    end
                end,
            }

            return story
        end)()
    end,
    [24] = function()
        ImportGlobals(24)

        return (function(...)
            local damerau = {}

            function damerau.raw(s, t)
                if #s > #t then
                    t, s = s, t
                end

                local m, n = #s, #t
                local vn = table.create(n + 1, 0)

                for i = 1, n + 1 do
                    vn[i] = i - 1
                end

                local v0, v1 = table.clone(vn), table.clone(vn)

                for i = 1, m do
                    v1[1] = i - 1

                    for j = 1, n do
                        local cost = if s:sub(i, i) == t:sub(j, j)then 0 else 1

                        if i > 1 and j > 1 and s:sub(i, i) == t:sub(j - 1, j - 1) and s:sub(i - 1, i - 1) == t:sub(j, j) then
                            local noChangeCost = v1[j + 1]
                            local transpositionCost = vn[j - 1] + 1

                            v1[j + 1] = math.min(noChangeCost, transpositionCost)
                        else
                            local deletionCost = v0[j + 1] + 1
                            local insertionCost = v1[j] + 1
                            local substitutionCost = v0[j] + cost

                            v1[j + 1] = math.min(deletionCost, insertionCost, substitutionCost)
                        end
                    end

                    vn, v0, v1 = v0, v1, vn
                end

                return v0[n + 1]
            end
            function damerau.weighted(s, t)
                return damerau.raw(s, t) / (#s + #t)
            end

            return damerau
        end)()
    end,
    [25] = function()
        ImportGlobals(25)

        return (function(...)
            local pi = math.pi
            local abs = math.abs
            local clamp = math.clamp
            local exp = math.exp
            local rad = math.rad
            local sign = math.sign
            local sqrt = math.sqrt
            local tan = math.tan
            local ContextActionService = game:GetService('ContextActionService')
            local Players = game:GetService('Players')
            local RunService = game:GetService('RunService')

            game:GetService('StarterGui')

            local UserInputService = game:GetService('UserInputService')
            local Workspace = game:GetService('Workspace')
            local LocalPlayer = Players.LocalPlayer

            if not LocalPlayer then
                Players:GetPropertyChangedSignal('LocalPlayer'):Wait()

                LocalPlayer = Players.LocalPlayer
            end

            local Camera = Workspace.CurrentCamera

            Workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function(
            )
                local newCamera = Workspace.CurrentCamera

                if newCamera then
                    Camera = newCamera
                end
            end)

            local _ = Enum.ContextActionPriority.Low.Value
            local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
            local _ = {
                Enum.KeyCode.LeftShift,
                Enum.KeyCode.P,
            }
            local FREECAM_RENDER_ID = game:GetService('HttpService'):GenerateGUID(false)
            local NAV_GAIN = Vector3.new(1, 1, 1) * 64
            local PAN_GAIN = Vector2.new(0.75, 1) * 8
            local FOV_GAIN = 300
            local PITCH_LIMIT = rad(90)
            local VEL_STIFFNESS = 2
            local PAN_STIFFNESS = 3
            local FOV_STIFFNESS = 4
            local Spring = {}

            do
                Spring.__index = Spring

                function Spring.new(freq, pos)
                    local self = setmetatable({}, Spring)

                    self.f = freq
                    self.p = pos
                    self.v = pos * 0

                    return self
                end
                function Spring:Update(dt, goal)
                    local f = self.f * 2 * pi
                    local p0 = self.p
                    local v0 = self.v
                    local offset = goal - p0
                    local decay = exp(-f * dt)
                    local p1 = goal + (v0 * dt - offset * (f * dt + 1)) * decay
                    local v1 = (f * dt * (offset * f - v0) + v0) * decay

                    self.p = p1
                    self.v = v1

                    return p1
                end
                function Spring:Reset(pos)
                    self.p = pos
                    self.v = pos * 0
                end
            end

            local cameraPos = Vector3.new()
            local cameraRot = Vector2.new()
            local cameraFov = 0
            local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
            local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
            local fovSpring = Spring.new(FOV_STIFFNESS, 0)
            local Input = {}

            do
                local thumbstickCurve

                do
                    local K_CURVATURE = 2
                    local K_DEADZONE = 0.15
                    local fCurve = function(x)
                        return (exp(K_CURVATURE * x) - 1) / (exp(K_CURVATURE) - 1)
                    end
                    local fDeadzone = function(x)
                        return fCurve((x - K_DEADZONE) / (1 - K_DEADZONE))
                    end

                    function thumbstickCurve(x)
                        return sign(x) * clamp(fDeadzone(abs(x)), 0, 1)
                    end
                end

                local gamepad = {
                    ButtonX = 0,
                    ButtonY = 0,
                    DPadDown = 0,
                    DPadUp = 0,
                    ButtonL2 = 0,
                    ButtonR2 = 0,
                    Thumbstick1 = Vector2.new(),
                    Thumbstick2 = Vector2.new(),
                }
                local keyboard = {
                    W = 0,
                    A = 0,
                    S = 0,
                    D = 0,
                    E = 0,
                    Q = 0,
                    U = 0,
                    H = 0,
                    J = 0,
                    K = 0,
                    I = 0,
                    Y = 0,
                    Up = 0,
                    Down = 0,
                    LeftShift = 0,
                    RightShift = 0,
                }
                local mouse = {
                    Delta = Vector2.new(),
                    MouseWheel = 0,
                }
                local NAV_GAMEPAD_SPEED = Vector3.new(1, 1, 1)
                local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
                local PAN_MOUSE_SPEED = Vector2.new(1, 1) * (pi / 64)
                local PAN_GAMEPAD_SPEED = Vector2.new(1, 1) * (pi / 8)
                local FOV_WHEEL_SPEED = 1
                local FOV_GAMEPAD_SPEED = 0.25
                local NAV_ADJ_SPEED = 0.75
                local NAV_SHIFT_MUL = 0.25
                local navSpeed = 1

                function Input.Vel(dt)
                    navSpeed = clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4)

                    local kGamepad = Vector3.new(thumbstickCurve(gamepad.Thumbstick1.X), thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2), thumbstickCurve(
-gamepad.Thumbstick1.Y)) * NAV_GAMEPAD_SPEED
                    local kKeyboard = Vector3.new(keyboard.D - keyboard.A + keyboard.K - keyboard.H, keyboard.E - keyboard.Q + keyboard.I - keyboard.Y, keyboard.S - keyboard.W + keyboard.J - keyboard.U) * NAV_KEYBOARD_SPEED
                    local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

                    return (kGamepad + kKeyboard) * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
                end
                function Input.Pan(dt)
                    local kGamepad = Vector2.new(thumbstickCurve(gamepad.Thumbstick2.Y), thumbstickCurve(
-gamepad.Thumbstick2.X)) * PAN_GAMEPAD_SPEED
                    local kMouse = mouse.Delta * PAN_MOUSE_SPEED / (dt * 60)

                    mouse.Delta = Vector2.new()

                    return kGamepad + kMouse
                end
                function Input.Fov(dt)
                    local kGamepad = (gamepad.ButtonX - gamepad.ButtonY) * FOV_GAMEPAD_SPEED
                    local kMouse = mouse.MouseWheel * FOV_WHEEL_SPEED

                    mouse.MouseWheel = 0

                    return kGamepad + kMouse
                end

                do
                    local Keypress = function(action, state, input)
                        keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0

                        return Enum.ContextActionResult.Sink
                    end
                    local GpButton = function(action, state, input)
                        gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0

                        return Enum.ContextActionResult.Sink
                    end
                    local MousePan = function(action, state, input)
                        local delta = input.Delta

                        mouse.Delta = Vector2.new(-delta.y, -delta.x)

                        return Enum.ContextActionResult.Sink
                    end
                    local Thumb = function(action, state, input)
                        gamepad[input.KeyCode.Name] = input.Position

                        return Enum.ContextActionResult.Sink
                    end
                    local Trigger = function(action, state, input)
                        gamepad[input.KeyCode.Name] = input.Position.z

                        return Enum.ContextActionResult.Sink
                    end
                    local MouseWheel = function(action, state, input)
                        mouse[input.UserInputType.Name] = -input.Position.z

                        return Enum.ContextActionResult.Sink
                    end
                    local Zero = function(t)
                        for k, v in pairs(t)do
                            t[k] = v * 0
                        end
                    end

                    function Input.StartCapture()
                        ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. 'FreecamKeyboard', Keypress, false, INPUT_PRIORITY, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.Up, Enum.KeyCode.Down)
                        ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. 'FreecamMousePan', MousePan, false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
                        ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. 'FreecamMouseWheel', MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
                        ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. 'FreecamGamepadButton', GpButton, false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
                        ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. 'FreecamGamepadTrigger', Trigger, false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
                        ContextActionService:BindActionAtPriority(FREECAM_RENDER_ID .. 'FreecamGamepadThumbstick', Thumb, false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
                    end
                    function Input.StopCapture()
                        navSpeed = 1

                        Zero(gamepad)
                        Zero(keyboard)
                        Zero(mouse)
                        ContextActionService:UnbindAction(FREECAM_RENDER_ID .. 'FreecamKeyboard')
                        ContextActionService:UnbindAction(FREECAM_RENDER_ID .. 'FreecamMousePan')
                        ContextActionService:UnbindAction(FREECAM_RENDER_ID .. 'FreecamMouseWheel')
                        ContextActionService:UnbindAction(FREECAM_RENDER_ID .. 'FreecamGamepadButton')
                        ContextActionService:UnbindAction(FREECAM_RENDER_ID .. 'FreecamGamepadTrigger')
                        ContextActionService:UnbindAction(FREECAM_RENDER_ID .. 'FreecamGamepadThumbstick')
                    end
                end
            end

            local GetFocusDistance = function(cameraFrame)
                local znear = 0.1
                local viewport = Camera.ViewportSize
                local projy = 2 * tan(cameraFov / 2)
                local projx = viewport.x / viewport.y * projy
                local fx = cameraFrame.rightVector
                local fy = cameraFrame.upVector
                local fz = cameraFrame.lookVector
                local minVect = Vector3.new()
                local minDist = 512

                for x = 0, 1, 0.5 do
                    for y = 0, 1, 0.5 do
                        local cx = (x - 0.5) * projx
                        local cy = (y - 0.5) * projy
                        local offset = fx * cx - fy * cy + fz
                        local origin = cameraFrame.p + offset * znear
                        local _, hit = Workspace:FindPartOnRay(Ray.new(origin, offset.unit * minDist))
                        local dist = (hit - origin).magnitude

                        if minDist > dist then
                            minDist = dist
                            minVect = offset.unit
                        end
                    end
                end

                return fz:Dot(minVect) * minDist
            end
            local StepFreecam = function(dt)
                local vel = velSpring:Update(dt, Input.Vel(dt))
                local pan = panSpring:Update(dt, Input.Pan(dt))
                local fov = fovSpring:Update(dt, Input.Fov(dt))
                local zoomFactor = sqrt(tan(rad(35)) / tan(rad(cameraFov / 2)))

                cameraFov = clamp(cameraFov + fov * FOV_GAIN * (dt / zoomFactor), 1, 120)
                cameraRot = cameraRot + pan * PAN_GAIN * (dt / zoomFactor)
                cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y % (2 * pi))

                local cameraCFrame = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0) * CFrame.new(vel * NAV_GAIN * dt)

                cameraPos = cameraCFrame.p
                Camera.CFrame = cameraCFrame
                Camera.Focus = cameraCFrame * CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
                Camera.FieldOfView = cameraFov
            end
            local PlayerState = {}

            do
                local mouseBehavior
                local cameraFocus
                local cameraCFrame
                local cameraFieldOfView

                function PlayerState.Push()
                    cameraFieldOfView = Camera.FieldOfView
                    Camera.FieldOfView = 70
                    cameraCFrame = Camera.CFrame
                    cameraFocus = Camera.Focus
                    mouseBehavior = UserInputService.MouseBehavior
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                end
                function PlayerState.Pop()
                    Camera.FieldOfView = cameraFieldOfView
                    cameraFieldOfView = nil
                    Camera.CFrame = cameraCFrame
                    cameraCFrame = nil
                    Camera.Focus = cameraFocus
                    cameraFocus = nil
                    UserInputService.MouseBehavior = mouseBehavior
                    mouseBehavior = nil
                end
            end

            local StartFreecam = function()
                local cameraCFrame = Camera.CFrame

                cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
                cameraPos = cameraCFrame.p
                cameraFov = Camera.FieldOfView

                velSpring:Reset(Vector3.new())
                panSpring:Reset(Vector2.new())
                fovSpring:Reset(0)
                PlayerState.Push()
                RunService:BindToRenderStep(FREECAM_RENDER_ID, Enum.RenderPriority.Camera.Value + 1, StepFreecam)
                Input.StartCapture()
            end
            local StopFreecam = function()
                Input.StopCapture()
                RunService:UnbindFromRenderStep(FREECAM_RENDER_ID)
                PlayerState.Pop()
            end
            local enabled = false
            local EnableFreecam = function()
                if not enabled then
                    StartFreecam()

                    enabled = true
                end
            end
            local DisableFreecam = function()
                if enabled then
                    StopFreecam()

                    enabled = false
                end
            end

            return {
                EnableFreecam = EnableFreecam,
                DisableFreecam = DisableFreecam,
            }
        end)()
    end,
    [26] = function()
        local wax, script, require = ImportGlobals(26)

        return (function(...)
            require(script.PubTypes)

            local restrictRead = require(script.Utility.restrictRead)

            return (restrictRead('Fusion', {
                version = {
                    major = 0,
                    minor = 2,
                    isRelease = true,
                },
                New = require(script.Instances.New),
                Hydrate = require(script.Instances.Hydrate),
                Ref = require(script.Instances.Ref),
                Out = require(script.Instances.Out),
                Cleanup = require(script.Instances.Cleanup),
                Children = require(script.Instances.Children),
                OnEvent = require(script.Instances.OnEvent),
                OnChange = require(script.Instances.OnChange),
                Value = require(script.State.Value),
                Computed = require(script.State.Computed),
                ForPairs = require(script.State.ForPairs),
                ForKeys = require(script.State.ForKeys),
                ForValues = require(script.State.ForValues),
                Observer = require(script.State.Observer),
                Tween = require(script.Animation.Tween),
                Spring = require(script.Animation.Spring),
                cleanup = require(script.Utility.cleanup),
                doNothing = require(script.Utility.doNothing),
            }))
        end)()
    end,
    [28] = function()
        local wax, script, require = ImportGlobals(28)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local SpringScheduler = require(Package.Animation.SpringScheduler)

            require(Package.Types)

            local initDependency = require(Package.Dependencies.initDependency)
            local logError = require(Package.Logging.logError)
            local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
            local unpackType = require(Package.Animation.unpackType)
            local unwrap = require(Package.State.unwrap)
            local updateAll = require(Package.Dependencies.updateAll)
            local useDependency = require(Package.Dependencies.useDependency)
            local xtypeof = require(Package.Utility.xtypeof)
            local class = {}
            local CLASS_METATABLE = {__index = class}
            local WEAK_KEYS_METATABLE = {
                __mode = 'k',
            }

            function class:get(asDependency)
                if asDependency ~= false then
                    useDependency(self)
                end

                return self._currentValue
            end
            function class:setPosition(newValue)
                local newType = typeof(newValue)

                if newType ~= self._currentType then
                    logError('springTypeMismatch', nil, newType, self._currentType)
                end

                self._springPositions = unpackType(newValue, newType)
                self._currentValue = newValue

                SpringScheduler.add(self)
                updateAll(self)
            end
            function class:setVelocity(newValue)
                local newType = typeof(newValue)

                if newType ~= self._currentType then
                    logError('springTypeMismatch', nil, newType, self._currentType)
                end

                self._springVelocities = unpackType(newValue, newType)

                SpringScheduler.add(self)
            end
            function class:addVelocity(deltaValue)
                local deltaType = typeof(deltaValue)

                if deltaType ~= self._currentType then
                    logError('springTypeMismatch', nil, deltaType, self._currentType)
                end

                local springDeltas = unpackType(deltaValue, deltaType)

                for index, delta in ipairs(springDeltas)do
                    self._springVelocities[index] += delta
                end

                SpringScheduler.add(self)
            end
            function class:update()
                local goalValue = self._goalState:get(false)

                if goalValue == self._goalValue then
                    local damping = unwrap(self._damping)

                    if typeof(damping) ~= 'number' then
                        logErrorNonFatal('mistypedSpringDamping', nil, typeof(damping))
                    elseif damping < 0 then
                        logErrorNonFatal('invalidSpringDamping', nil, damping)
                    else
                        self._currentDamping = damping
                    end

                    local speed = unwrap(self._speed)

                    if typeof(speed) ~= 'number' then
                        logErrorNonFatal('mistypedSpringSpeed', nil, typeof(speed))
                    elseif speed < 0 then
                        logErrorNonFatal('invalidSpringSpeed', nil, speed)
                    else
                        self._currentSpeed = speed
                    end

                    return false
                else
                    self._goalValue = goalValue

                    local oldType = self._currentType
                    local newType = typeof(goalValue)

                    self._currentType = newType

                    local springGoals = unpackType(goalValue, newType)
                    local numSprings = #springGoals

                    self._springGoals = springGoals

                    if newType ~= oldType then
                        self._currentValue = self._goalValue

                        local springPositions = table.create(numSprings, 0)
                        local springVelocities = table.create(numSprings, 0)

                        for index, springGoal in ipairs(springGoals)do
                            springPositions[index] = springGoal
                        end

                        self._springPositions = springPositions
                        self._springVelocities = springVelocities

                        SpringScheduler.remove(self)

                        return true
                    elseif numSprings == 0 then
                        self._currentValue = self._goalValue

                        return true
                    else
                        SpringScheduler.add(self)

                        return false
                    end
                end
            end

            local Spring = function(goalState, speed, damping)
                if speed == nil then
                    speed = 10
                end
                if damping == nil then
                    damping = 1
                end

                local dependencySet = {[goalState] = true}

                if xtypeof(speed) == 'State' then
                    dependencySet[speed] = true
                end
                if xtypeof(damping) == 'State' then
                    dependencySet[damping] = true
                end

                local self = setmetatable({
                    type = 'State',
                    kind = 'Spring',
                    dependencySet = dependencySet,
                    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
                    _speed = speed,
                    _damping = damping,
                    _goalState = goalState,
                    _goalValue = nil,
                    _currentType = nil,
                    _currentValue = nil,
                    _currentSpeed = unwrap(speed),
                    _currentDamping = unwrap(damping),
                    _springPositions = nil,
                    _springGoals = nil,
                    _springVelocities = nil,
                }, CLASS_METATABLE)

                initDependency(self)

                goalState.dependentSet[self] = true

                self:update()

                return self
            end

            return Spring
        end)()
    end,
    [29] = function()
        local wax, script, require = ImportGlobals(29)

        return (function(...)
            local RunService = game:GetService('RunService')
            local Package = script.Parent.Parent

            require(Package.Types)

            local packType = require(Package.Animation.packType)
            local springCoefficients = require(Package.Animation.springCoefficients)
            local updateAll = require(Package.Dependencies.updateAll)
            local SpringScheduler = {}
            local EPSILON = 0.0001
            local activeSprings = {}
            local lastUpdateTime = os.clock()

            function SpringScheduler.add(spring)
                spring._lastSchedule = lastUpdateTime
                spring._startDisplacements = {}
                spring._startVelocities = {}

                for index, goal in ipairs(spring._springGoals)do
                    spring._startDisplacements[index] = spring._springPositions[index] - goal
                    spring._startVelocities[index] = spring._springVelocities[index]
                end

                activeSprings[spring] = true
            end
            function SpringScheduler.remove(spring)
                activeSprings[spring] = nil
            end

            local updateAllSprings = function()
                local springsToSleep = {}

                lastUpdateTime = os.clock()

                for spring in pairs(activeSprings)do
                    local posPos, posVel, velPos, velVel = springCoefficients(lastUpdateTime - spring._lastSchedule, spring._currentDamping, spring._currentSpeed)
                    local positions = spring._springPositions
                    local velocities = spring._springVelocities
                    local startDisplacements = spring._startDisplacements
                    local startVelocities = spring._startVelocities
                    local isMoving = false

                    for index, goal in ipairs(spring._springGoals)do
                        local oldDisplacement = startDisplacements[index]
                        local oldVelocity = startVelocities[index]
                        local newDisplacement = oldDisplacement * posPos + oldVelocity * posVel
                        local newVelocity = oldDisplacement * velPos + oldVelocity * velVel

                        if math.abs(newDisplacement) > EPSILON or math.abs(newVelocity) > EPSILON then
                            isMoving = true
                        end

                        positions[index] = newDisplacement + goal
                        velocities[index] = newVelocity
                    end

                    if not isMoving then
                        springsToSleep[spring] = true
                    end
                end
                for spring in pairs(activeSprings)do
                    spring._currentValue = packType(spring._springPositions, spring._currentType)

                    updateAll(spring)
                end
                for spring in pairs(springsToSleep)do
                    activeSprings[spring] = nil
                end
            end

            RunService:BindToRenderStep('__FusionSpringScheduler', Enum.RenderPriority.First.Value, updateAllSprings)

            return SpringScheduler
        end)()
    end,
    [30] = function()
        local wax, script, require = ImportGlobals(30)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local TweenScheduler = require(Package.Animation.TweenScheduler)

            require(Package.Types)

            local initDependency = require(Package.Dependencies.initDependency)
            local logError = require(Package.Logging.logError)
            local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
            local useDependency = require(Package.Dependencies.useDependency)
            local xtypeof = require(Package.Utility.xtypeof)
            local class = {}
            local CLASS_METATABLE = {__index = class}
            local WEAK_KEYS_METATABLE = {
                __mode = 'k',
            }

            function class:get(asDependency)
                if asDependency ~= false then
                    useDependency(self)
                end

                return self._currentValue
            end
            function class:update()
                local goalValue = self._goalState:get(false)

                if goalValue == self._nextValue and not self._currentlyAnimating then
                    return false
                end

                local tweenInfo = self._tweenInfo

                if self._tweenInfoIsState then
                    tweenInfo = tweenInfo:get()
                end
                if typeof(tweenInfo) ~= 'TweenInfo' then
                    logErrorNonFatal('mistypedTweenInfo', nil, typeof(tweenInfo))

                    return false
                end

                self._prevValue = self._currentValue
                self._nextValue = goalValue
                self._currentTweenStartTime = os.clock()
                self._currentTweenInfo = tweenInfo

                local tweenDuration = tweenInfo.DelayTime + tweenInfo.Time

                if tweenInfo.Reverses then
                    tweenDuration += tweenInfo.Time
                end

                tweenDuration *= tweenInfo.RepeatCount + 1

                self._currentTweenDuration = tweenDuration

                TweenScheduler.add(self)

                return false
            end

            local Tween = function(goalState, tweenInfo)
                local currentValue = goalState:get(false)

                if tweenInfo == nil then
                    tweenInfo = TweenInfo.new()
                end

                local dependencySet = {[goalState] = true}
                local tweenInfoIsState = xtypeof(tweenInfo) == 'State'

                if tweenInfoIsState then
                    dependencySet[tweenInfo] = true
                end

                local startingTweenInfo = tweenInfo

                if tweenInfoIsState then
                    startingTweenInfo = startingTweenInfo:get()
                end
                if typeof(startingTweenInfo) ~= 'TweenInfo' then
                    logError('mistypedTweenInfo', nil, typeof(startingTweenInfo))
                end

                local self = setmetatable({
                    type = 'State',
                    kind = 'Tween',
                    dependencySet = dependencySet,
                    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
                    _goalState = goalState,
                    _tweenInfo = tweenInfo,
                    _tweenInfoIsState = tweenInfoIsState,
                    _prevValue = currentValue,
                    _nextValue = currentValue,
                    _currentValue = currentValue,
                    _currentTweenInfo = tweenInfo,
                    _currentTweenDuration = 0,
                    _currentTweenStartTime = 0,
                    _currentlyAnimating = false,
                }, CLASS_METATABLE)

                initDependency(self)

                goalState.dependentSet[self] = true

                return self
            end

            return Tween
        end)()
    end,
    [31] = function()
        local wax, script, require = ImportGlobals(31)

        return (function(...)
            local RunService = game:GetService('RunService')
            local Package = script.Parent.Parent

            require(Package.Types)

            local getTweenRatio = require(Package.Animation.getTweenRatio)
            local lerpType = require(Package.Animation.lerpType)
            local updateAll = require(Package.Dependencies.updateAll)
            local TweenScheduler = {}
            local WEAK_KEYS_METATABLE = {
                __mode = 'k',
            }
            local allTweens = {}

            setmetatable(allTweens, WEAK_KEYS_METATABLE)

            function TweenScheduler.add(tween)
                allTweens[tween] = true
            end
            function TweenScheduler.remove(tween)
                allTweens[tween] = nil
            end

            local updateAllTweens = function()
                local now = os.clock()

                for tween in pairs(allTweens)do
                    local currentTime = now - tween._currentTweenStartTime

                    if currentTime > tween._currentTweenDuration then
                        if tween._currentTweenInfo.Reverses then
                            tween._currentValue = tween._prevValue
                        else
                            tween._currentValue = tween._nextValue
                        end

                        tween._currentlyAnimating = false

                        updateAll(tween)
                        TweenScheduler.remove(tween)
                    else
                        local ratio = getTweenRatio(tween._currentTweenInfo, currentTime)
                        local currentValue = lerpType(tween._prevValue, tween._nextValue, ratio)

                        tween._currentValue = currentValue
                        tween._currentlyAnimating = true

                        updateAll(tween)
                    end
                end
            end

            RunService:BindToRenderStep('__FusionTweenScheduler', Enum.RenderPriority.First.Value, updateAllTweens)

            return TweenScheduler
        end)()
    end,
    [32] = function()
        ImportGlobals(32)

        return (function(...)
            local TweenService = game:GetService('TweenService')
            local getTweenRatio = function(tweenInfo, currentTime)
                local delay = tweenInfo.DelayTime
                local duration = tweenInfo.Time
                local reverses = tweenInfo.Reverses
                local numCycles = 1 + tweenInfo.RepeatCount
                local easeStyle = tweenInfo.EasingStyle
                local easeDirection = tweenInfo.EasingDirection
                local cycleDuration = delay + duration

                if reverses then
                    cycleDuration += duration
                end
                if currentTime >= cycleDuration * numCycles then
                    return 1
                end

                local cycleTime = currentTime % cycleDuration

                if cycleTime <= delay then
                    return 0
                end

                local tweenProgress = (cycleTime - delay) / duration

                if tweenProgress > 1 then
                    tweenProgress = 2 - tweenProgress
                end

                local ratio = TweenService:GetValue(tweenProgress, easeStyle, easeDirection)

                return ratio
            end

            return getTweenRatio
        end)()
    end,
    [33] = function()
        local wax, script, require = ImportGlobals(33)

        return (function(...)
            local Package = script.Parent.Parent
            local Oklab = require(Package.Colour.Oklab)

            require(Package.PubTypes)

            local lerpType = function(from, to, ratio)
                local typeString = typeof(from)

                if typeof(to) == typeString then
                    if typeString == 'number' then
                        local to, from = to, from

                        return (to - from) * ratio + from
                    elseif typeString == 'CFrame' then
                        local to, from = to, from

                        return from:Lerp(to, ratio)
                    elseif typeString == 'Color3' then
                        local to, from = to, from
                        local fromLab = Oklab.to(from)
                        local toLab = Oklab.to(to)

                        return Oklab.from(fromLab:Lerp(toLab, ratio), false)
                    elseif typeString == 'ColorSequenceKeypoint' then
                        local to, from = to, from
                        local fromLab = Oklab.to(from.Value)
                        local toLab = Oklab.to(to.Value)

                        return ColorSequenceKeypoint.new((to.Time - from.Time) * ratio + from.Time, Oklab.from(fromLab:Lerp(toLab, ratio), false))
                    elseif typeString == 'DateTime' then
                        local to, from = to, from

                        return DateTime.fromUnixTimestampMillis((to.UnixTimestampMillis - from.UnixTimestampMillis) * ratio + from.UnixTimestampMillis)
                    elseif typeString == 'NumberRange' then
                        local to, from = to, from

                        return NumberRange.new((to.Min - from.Min) * ratio + from.Min, (to.Max - from.Max) * ratio + from.Max)
                    elseif typeString == 'NumberSequenceKeypoint' then
                        local to, from = to, from

                        return NumberSequenceKeypoint.new((to.Time - from.Time) * ratio + from.Time, (to.Value - from.Value) * ratio + from.Value, (to.Envelope - from.Envelope) * ratio + from.Envelope)
                    elseif typeString == 'PhysicalProperties' then
                        local to, from = to, from

                        return PhysicalProperties.new((to.Density - from.Density) * ratio + from.Density, (to.Friction - from.Friction) * ratio + from.Friction, (to.Elasticity - from.Elasticity) * ratio + from.Elasticity, (to.FrictionWeight - from.FrictionWeight) * ratio + from.FrictionWeight, (to.ElasticityWeight - from.ElasticityWeight) * ratio + from.ElasticityWeight)
                    elseif typeString == 'Ray' then
                        local to, from = to, from

                        return Ray.new(from.Origin:Lerp(to.Origin, ratio), from.Direction:Lerp(to.Direction, ratio))
                    elseif typeString == 'Rect' then
                        local to, from = to, from

                        return Rect.new(from.Min:Lerp(to.Min, ratio), from.Max:Lerp(to.Max, ratio))
                    elseif typeString == 'Region3' then
                        local to, from = to, from
                        local position = from.CFrame.Position:Lerp(to.CFrame.Position, ratio)
                        local halfSize = from.Size:Lerp(to.Size, ratio) / 2

                        return Region3.new(position - halfSize, position + halfSize)
                    elseif typeString == 'Region3int16' then
                        local to, from = to, from

                        return Region3int16.new(Vector3int16.new((to.Min.X - from.Min.X) * ratio + from.Min.X, (to.Min.Y - from.Min.Y) * ratio + from.Min.Y, (to.Min.Z - from.Min.Z) * ratio + from.Min.Z), Vector3int16.new((to.Max.X - from.Max.X) * ratio + from.Max.X, (to.Max.Y - from.Max.Y) * ratio + from.Max.Y, (to.Max.Z - from.Max.Z) * ratio + from.Max.Z))
                    elseif typeString == 'UDim' then
                        local to, from = to, from

                        return UDim.new((to.Scale - from.Scale) * ratio + from.Scale, (to.Offset - from.Offset) * ratio + from.Offset)
                    elseif typeString == 'UDim2' then
                        local to, from = to, from

                        return from:Lerp(to, ratio)
                    elseif typeString == 'Vector2' then
                        local to, from = to, from

                        return from:Lerp(to, ratio)
                    elseif typeString == 'Vector2int16' then
                        local to, from = to, from

                        return Vector2int16.new((to.X - from.X) * ratio + from.X, (to.Y - from.Y) * ratio + from.Y)
                    elseif typeString == 'Vector3' then
                        local to, from = to, from

                        return from:Lerp(to, ratio)
                    elseif typeString == 'Vector3int16' then
                        local to, from = to, from

                        return Vector3int16.new((to.X - from.X) * ratio + from.X, (to.Y - from.Y) * ratio + from.Y, (to.Z - from.Z) * ratio + from.Z)
                    end
                end
                if ratio < 0.5 then
                    return from
                else
                    return to
                end
            end

            return lerpType
        end)()
    end,
    [34] = function()
        local wax, script, require = ImportGlobals(34)

        return (function(...)
            local Package = script.Parent.Parent
            local Oklab = require(Package.Colour.Oklab)

            require(Package.PubTypes)

            local packType = function(numbers, typeString)
                if typeString == 'number' then
                    return numbers[1]
                elseif typeString == 'CFrame' then
                    return CFrame.new(numbers[1], numbers[2], numbers[3]) * CFrame.fromAxisAngle(Vector3.new(numbers[4], numbers[5], numbers[6]).Unit, numbers[7])
                elseif typeString == 'Color3' then
                    return Oklab.from(Vector3.new(numbers[1], numbers[2], numbers[3]), false)
                elseif typeString == 'ColorSequenceKeypoint' then
                    return ColorSequenceKeypoint.new(numbers[4], Oklab.from(Vector3.new(numbers[1], numbers[2], numbers[3]), false))
                elseif typeString == 'DateTime' then
                    return DateTime.fromUnixTimestampMillis(numbers[1])
                elseif typeString == 'NumberRange' then
                    return NumberRange.new(numbers[1], numbers[2])
                elseif typeString == 'NumberSequenceKeypoint' then
                    return NumberSequenceKeypoint.new(numbers[2], numbers[1], numbers[3])
                elseif typeString == 'PhysicalProperties' then
                    return PhysicalProperties.new(numbers[1], numbers[2], numbers[3], numbers[4], numbers[5])
                elseif typeString == 'Ray' then
                    return Ray.new(Vector3.new(numbers[1], numbers[2], numbers[3]), Vector3.new(numbers[4], numbers[5], numbers[6]))
                elseif typeString == 'Rect' then
                    return Rect.new(numbers[1], numbers[2], numbers[3], numbers[4])
                elseif typeString == 'Region3' then
                    local position = Vector3.new(numbers[1], numbers[2], numbers[3])
                    local halfSize = Vector3.new(numbers[4] / 2, numbers[5] / 2, numbers[6] / 2)

                    return Region3.new(position - halfSize, position + halfSize)
                elseif typeString == 'Region3int16' then
                    return Region3int16.new(Vector3int16.new(numbers[1], numbers[2], numbers[3]), Vector3int16.new(numbers[4], numbers[5], numbers[6]))
                elseif typeString == 'UDim' then
                    return UDim.new(numbers[1], numbers[2])
                elseif typeString == 'UDim2' then
                    return UDim2.new(numbers[1], numbers[2], numbers[3], numbers[4])
                elseif typeString == 'Vector2' then
                    return Vector2.new(numbers[1], numbers[2])
                elseif typeString == 'Vector2int16' then
                    return Vector2int16.new(numbers[1], numbers[2])
                elseif typeString == 'Vector3' then
                    return Vector3.new(numbers[1], numbers[2], numbers[3])
                elseif typeString == 'Vector3int16' then
                    return Vector3int16.new(numbers[1], numbers[2], numbers[3])
                else
                    return nil
                end
            end

            return packType
        end)()
    end,
    [35] = function()
        ImportGlobals(35)

        return (function(...)
            local springCoefficients = function(time, damping, speed)
                if time == 0 or speed == 0 then
                    return 1, 0, 0, 1
                end

                local posPos, posVel, velPos, velVel

                if damping > 1 then
                    local scaledTime = time * speed
                    local alpha = math.sqrt(damping ^ 2 - 1)
                    local scaledInvAlpha = -0.5 / alpha
                    local z1 = -alpha - damping
                    local z2 = 1 / z1
                    local expZ1 = math.exp(scaledTime * z1)
                    local expZ2 = math.exp(scaledTime * z2)

                    posPos = (expZ2 * z1 - expZ1 * z2) * scaledInvAlpha
                    posVel = (expZ1 - expZ2) * scaledInvAlpha / speed
                    velPos = (expZ2 - expZ1) * scaledInvAlpha * speed
                    velVel = (expZ1 * z1 - expZ2 * z2) * scaledInvAlpha
                elseif damping == 1 then
                    local scaledTime = time * speed
                    local expTerm = math.exp(-scaledTime)

                    posPos = expTerm * (1 + scaledTime)
                    posVel = expTerm * time
                    velPos = expTerm * (-scaledTime * speed)
                    velVel = expTerm * (1 - scaledTime)
                else
                    local scaledTime = time * speed
                    local alpha = math.sqrt(1 - damping ^ 2)
                    local invAlpha = 1 / alpha
                    local alphaTime = alpha * scaledTime
                    local expTerm = math.exp(-scaledTime * damping)
                    local sinTerm = expTerm * math.sin(alphaTime)
                    local cosTerm = expTerm * math.cos(alphaTime)
                    local sinInvAlpha = sinTerm * invAlpha
                    local sinInvAlphaDamp = sinInvAlpha * damping

                    posPos = sinInvAlphaDamp + cosTerm
                    posVel = sinInvAlpha
                    velPos = -(sinInvAlphaDamp * damping + sinTerm * alpha)
                    velVel = cosTerm - sinInvAlphaDamp
                end

                return posPos, posVel, velPos, velVel
            end

            return springCoefficients
        end)()
    end,
    [36] = function()
        local wax, script, require = ImportGlobals(36)

        return (function(...)
            local Package = script.Parent.Parent
            local Oklab = require(Package.Colour.Oklab)

            require(Package.PubTypes)

            local unpackType = function(value, typeString)
                if typeString == 'number' then
                    local value = value

                    return {value}
                elseif typeString == 'CFrame' then
                    local axis, angle = value:ToAxisAngle()

                    return {
                        value.X,
                        value.Y,
                        value.Z,
                        axis.X,
                        axis.Y,
                        axis.Z,
                        angle,
                    }
                elseif typeString == 'Color3' then
                    local lab = Oklab.to(value)

                    return {
                        lab.X,
                        lab.Y,
                        lab.Z,
                    }
                elseif typeString == 'ColorSequenceKeypoint' then
                    local lab = Oklab.to(value.Value)

                    return {
                        lab.X,
                        lab.Y,
                        lab.Z,
                        value.Time,
                    }
                elseif typeString == 'DateTime' then
                    return {
                        value.UnixTimestampMillis,
                    }
                elseif typeString == 'NumberRange' then
                    return {
                        value.Min,
                        value.Max,
                    }
                elseif typeString == 'NumberSequenceKeypoint' then
                    return {
                        value.Value,
                        value.Time,
                        value.Envelope,
                    }
                elseif typeString == 'PhysicalProperties' then
                    return {
                        value.Density,
                        value.Friction,
                        value.Elasticity,
                        value.FrictionWeight,
                        value.ElasticityWeight,
                    }
                elseif typeString == 'Ray' then
                    return {
                        value.Origin.X,
                        value.Origin.Y,
                        value.Origin.Z,
                        value.Direction.X,
                        value.Direction.Y,
                        value.Direction.Z,
                    }
                elseif typeString == 'Rect' then
                    return {
                        value.Min.X,
                        value.Min.Y,
                        value.Max.X,
                        value.Max.Y,
                    }
                elseif typeString == 'Region3' then
                    return {
                        value.CFrame.X,
                        value.CFrame.Y,
                        value.CFrame.Z,
                        value.Size.X,
                        value.Size.Y,
                        value.Size.Z,
                    }
                elseif typeString == 'Region3int16' then
                    return {
                        value.Min.X,
                        value.Min.Y,
                        value.Min.Z,
                        value.Max.X,
                        value.Max.Y,
                        value.Max.Z,
                    }
                elseif typeString == 'UDim' then
                    return {
                        value.Scale,
                        value.Offset,
                    }
                elseif typeString == 'UDim2' then
                    return {
                        value.X.Scale,
                        value.X.Offset,
                        value.Y.Scale,
                        value.Y.Offset,
                    }
                elseif typeString == 'Vector2' then
                    return {
                        value.X,
                        value.Y,
                    }
                elseif typeString == 'Vector2int16' then
                    return {
                        value.X,
                        value.Y,
                    }
                elseif typeString == 'Vector3' then
                    return {
                        value.X,
                        value.Y,
                        value.Z,
                    }
                elseif typeString == 'Vector3int16' then
                    return {
                        value.X,
                        value.Y,
                        value.Z,
                    }
                else
                    return {}
                end
            end

            return unpackType
        end)()
    end,
    [38] = function()
        ImportGlobals(38)

        return (function(...)
            local Oklab = {}

            function Oklab.to(rgb)
                local l = rgb.R * 0.4122214708 + rgb.G * 0.5363325363 + rgb.B * 0.0514459929
                local m = rgb.R * 0.2119034982 + rgb.G * 0.6806995451 + rgb.B * 0.1073969566
                local s = rgb.R * 0.0883024619 + rgb.G * 0.2817188376 + rgb.B * 0.6299787005
                local lRoot = l ^ (0.3333333333333333)
                local mRoot = m ^ (0.3333333333333333)
                local sRoot = s ^ (0.3333333333333333)

                return Vector3.new(lRoot * 0.2104542553 + mRoot * 0.793617785 - sRoot * 0.0040720468, lRoot * 1.9779984951 - mRoot * 2.428592205 + sRoot * 0.4505937099, lRoot * 0.0259040371 + mRoot * 0.7827717662 - sRoot * 0.808675766)
            end
            function Oklab.from(lab, unclamped)
                local lRoot = lab.X + lab.Y * 0.3963377774 + lab.Z * 0.2158037573
                local mRoot = lab.X - lab.Y * 0.1055613458 - lab.Z * 0.0638541728
                local sRoot = lab.X - lab.Y * 0.0894841775 - lab.Z * 1.291485548
                local l = lRoot ^ 3
                local m = mRoot ^ 3
                local s = sRoot ^ 3
                local red = l * 4.0767416621 - m * 3.3077115913 + s * 0.2309699292
                local green = l * -1.2684380046 + m * 2.6097574011 - s * 0.3413193965
                local blue = l * -4.196086299999999E-3 - m * 0.7034186147 + s * 1.707614701

                if not unclamped then
                    red = math.clamp(red, 0, 1)
                    green = math.clamp(green, 0, 1)
                    blue = math.clamp(blue, 0, 1)
                end

                return Color3.new(red, green, blue)
            end

            return Oklab
        end)()
    end,
    [40] = function()
        local wax, script, require = ImportGlobals(40)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local parseError = require(Package.Logging.parseError)
            local sharedState = require(Package.Dependencies.sharedState)
            local initialisedStack = sharedState.initialisedStack
            local initialisedStackCapacity = 0
            local captureDependencies = function(saveToSet, callback, ...)
                local prevDependencySet = sharedState.dependencySet

                sharedState.dependencySet = saveToSet

                sharedState.initialisedStackSize += 1

                local initialisedStackSize = sharedState.initialisedStackSize
                local initialisedSet

                if initialisedStackSize > initialisedStackCapacity then
                    initialisedSet = {}
                    initialisedStack[initialisedStackSize] = initialisedSet
                    initialisedStackCapacity = initialisedStackSize
                else
                    initialisedSet = initialisedStack[initialisedStackSize]

                    table.clear(initialisedSet)
                end

                local data = table.pack(xpcall(callback, parseError, ...))

                sharedState.dependencySet = prevDependencySet

                sharedState.initialisedStackSize -= 1

                return table.unpack(data, 1, data.n)
            end

            return captureDependencies
        end)()
    end,
    [41] = function()
        local wax, script, require = ImportGlobals(41)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local sharedState = require(Package.Dependencies.sharedState)
            local initialisedStack = sharedState.initialisedStack
            local initDependency = function(dependency)
                local initialisedStackSize = sharedState.initialisedStackSize

                for index, initialisedSet in ipairs(initialisedStack)do
                    if index > initialisedStackSize then
                        return
                    end

                    initialisedSet[dependency] = true
                end
            end

            return initDependency
        end)()
    end,
    [42] = function()
        local wax, script, require = ImportGlobals(42)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local dependencySet = nil
            local initialisedStack = {}
            local initialisedStackSize = 0

            return {
                dependencySet = dependencySet,
                initialisedStack = initialisedStack,
                initialisedStackSize = initialisedStackSize,
            }
        end)()
    end,
    [43] = function()
        local wax, script, require = ImportGlobals(43)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local updateAll = function(root)
                local counters = {}
                local flags = {}
                local queue = {}
                local queueSize = 0
                local queuePos = 1

                for object in root.dependentSet do
                    queueSize += 1

                    queue[queueSize] = object
                    flags[object] = true
                end

                while queuePos <= queueSize do
                    local next = queue[queuePos]
                    local counter = counters[next]

                    counters[next] = if counter == nil then 1 else counter + 1

                    if (next).dependentSet ~= nil then
                        for object in (next).dependentSet do
                            queueSize += 1

                            queue[queueSize] = object
                        end
                    end

                    queuePos += 1
                end

                queuePos = 1

                while queuePos <= queueSize do
                    local next = queue[queuePos]
                    local counter = counters[next] - 1

                    counters[next] = counter

                    if counter == 0 and flags[next] and next:update() and (next).dependentSet ~= nil then
                        for object in (next).dependentSet do
                            flags[object] = true
                        end
                    end

                    queuePos += 1
                end
            end

            return updateAll
        end)()
    end,
    [44] = function()
        local wax, script, require = ImportGlobals(44)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local sharedState = require(Package.Dependencies.sharedState)
            local initialisedStack = sharedState.initialisedStack
            local useDependency = function(dependency)
                local dependencySet = sharedState.dependencySet

                if dependencySet ~= nil then
                    local initialisedStackSize = sharedState.initialisedStackSize

                    if initialisedStackSize > 0 then
                        local initialisedSet = initialisedStack[initialisedStackSize]

                        if initialisedSet[dependency] ~= nil then
                            return
                        end
                    end

                    dependencySet[dependency] = true
                end
            end

            return useDependency
        end)()
    end,
    [46] = function()
        local wax, script, require = ImportGlobals(46)

        return (function(...)
            local Package = script.Parent.Parent
            local Observer = require(Package.State.Observer)

            require(Package.PubTypes)

            local logWarn = require(Package.Logging.logWarn)
            local xtypeof = require(Package.Utility.xtypeof)
            local EXPERIMENTAL_AUTO_NAMING = false
            local Children = {}

            Children.type = 'SpecialKey'
            Children.kind = 'Children'
            Children.stage = 'descendants'

            function Children:apply(propValue, applyTo, cleanupTasks)
                local newParented = {}
                local oldParented = {}
                local newDisconnects = {}
                local oldDisconnects = {}
                local updateQueued = false
                local queueUpdate
                local updateChildren = function()
                    if not updateQueued then
                        return
                    end

                    updateQueued = false
                    oldParented, newParented = newParented, oldParented
                    oldDisconnects, newDisconnects = newDisconnects, oldDisconnects

                    table.clear(newParented)
                    table.clear(newDisconnects)

                    local function processChild(child, autoName)
                        local kind = xtypeof(child)

                        if kind == 'Instance' then
                            newParented[child] = true

                            if oldParented[child] == nil then
                                child.Parent = applyTo
                            else
                                oldParented[child] = nil
                            end
                            if EXPERIMENTAL_AUTO_NAMING and autoName ~= nil then
                                child.Name = autoName
                            end
                        elseif kind == 'State' then
                            local value = child:get(false)

                            if value ~= nil then
                                processChild(value, autoName)
                            end

                            local disconnect = oldDisconnects[child]

                            if disconnect == nil then
                                disconnect = Observer(child):onChange(queueUpdate)
                            else
                                oldDisconnects[child] = nil
                            end

                            newDisconnects[child] = disconnect
                        elseif kind == 'table' then
                            for key, subChild in pairs(child)do
                                local keyType = typeof(key)
                                local subAutoName = nil

                                if keyType == 'string' then
                                    subAutoName = key
                                elseif keyType == 'number' and autoName ~= nil then
                                    subAutoName = autoName .. '_' .. key
                                end

                                processChild(subChild, subAutoName)
                            end
                        else
                            logWarn('unrecognisedChildType', kind)
                        end
                    end

                    if propValue ~= nil then
                        processChild(propValue)
                    end

                    for oldInstance in pairs(oldParented)do
                        oldInstance.Parent = nil
                    end
                    for oldState, disconnect in pairs(oldDisconnects)do
                        disconnect()
                    end
                end

                queueUpdate = function()
                    if not updateQueued then
                        updateQueued = true

                        task.defer(updateChildren)
                    end
                end

                table.insert(cleanupTasks, function()
                    propValue = nil
                    updateQueued = true

                    updateChildren()
                end)

                updateQueued = true

                updateChildren()
            end

            return Children
        end)()
    end,
    [47] = function()
        local wax, script, require = ImportGlobals(47)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local Cleanup = {}

            Cleanup.type = 'SpecialKey'
            Cleanup.kind = 'Cleanup'
            Cleanup.stage = 'observer'

            function Cleanup:apply(userTask, applyTo, cleanupTasks)
                table.insert(cleanupTasks, userTask)
            end

            return Cleanup
        end)()
    end,
    [48] = function()
        local wax, script, require = ImportGlobals(48)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local applyInstanceProps = require(Package.Instances.applyInstanceProps)
            local Hydrate = function(target)
                return function(props)
                    applyInstanceProps(props, target)

                    return target
                end
            end

            return Hydrate
        end)()
    end,
    [49] = function()
        local wax, script, require = ImportGlobals(49)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local applyInstanceProps = require(Package.Instances.applyInstanceProps)
            local defaultProps = require(Package.Instances.defaultProps)
            local logError = require(Package.Logging.logError)
            local New = function(className)
                return function(props)
                    local ok, instance = pcall(Instance.new, className)

                    if not ok then
                        logError('cannotCreateClass', nil, className)
                    end

                    local classDefaults = defaultProps[className]

                    if classDefaults ~= nil then
                        for defaultProp, defaultValue in pairs(classDefaults)do
                            instance[defaultProp] = defaultValue
                        end
                    end

                    applyInstanceProps(props, instance)

                    return instance
                end
            end

            return New
        end)()
    end,
    [50] = function()
        local wax, script, require = ImportGlobals(50)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local logError = require(Package.Logging.logError)
            local OnChange = function(propertyName)
                local changeKey = {}

                changeKey.type = 'SpecialKey'
                changeKey.kind = 'OnChange'
                changeKey.stage = 'observer'

                function changeKey:apply(callback, applyTo, cleanupTasks)
                    local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)

                    if not ok then
                        logError('cannotConnectChange', nil, applyTo.ClassName, propertyName)
                    elseif typeof(callback) ~= 'function' then
                        logError('invalidChangeHandler', nil, propertyName)
                    else
                        table.insert(cleanupTasks, event:Connect(function()
                            callback((applyTo)[propertyName])
                        end))
                    end
                end

                return changeKey
            end

            return OnChange
        end)()
    end,
    [51] = function()
        local wax, script, require = ImportGlobals(51)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local logError = require(Package.Logging.logError)
            local getProperty_unsafe = function(instance, property)
                return (instance)[property]
            end
            local OnEvent = function(eventName)
                local eventKey = {}

                eventKey.type = 'SpecialKey'
                eventKey.kind = 'OnEvent'
                eventKey.stage = 'observer'

                function eventKey:apply(callback, applyTo, cleanupTasks)
                    local ok, event = pcall(getProperty_unsafe, applyTo, eventName)

                    if not ok or typeof(event) ~= 'RBXScriptSignal' then
                        logError('cannotConnectEvent', nil, applyTo.ClassName, eventName)
                    elseif typeof(callback) ~= 'function' then
                        logError('invalidEventHandler', nil, eventName)
                    else
                        table.insert(cleanupTasks, event:Connect(callback))
                    end
                end

                return eventKey
            end

            return OnEvent
        end)()
    end,
    [52] = function()
        local wax, script, require = ImportGlobals(52)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local logError = require(Package.Logging.logError)
            local xtypeof = require(Package.Utility.xtypeof)
            local Out = function(propertyName)
                local outKey = {}

                outKey.type = 'SpecialKey'
                outKey.kind = 'Out'
                outKey.stage = 'observer'

                function outKey:apply(outState, applyTo, cleanupTasks)
                    local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)

                    if not ok then
                        logError('invalidOutProperty', nil, applyTo.ClassName, propertyName)
                    elseif xtypeof(outState) ~= 'State' or outState.kind ~= 'Value' then
                        logError('invalidOutType')
                    else
                        outState:set((applyTo)[propertyName])
                        table.insert(cleanupTasks, event:Connect(function()
                            outState:set((applyTo)[propertyName])
                        end))
                        table.insert(cleanupTasks, function()
                            outState:set(nil)
                        end)
                    end
                end

                return outKey
            end

            return Out
        end)()
    end,
    [53] = function()
        local wax, script, require = ImportGlobals(53)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local logError = require(Package.Logging.logError)
            local xtypeof = require(Package.Utility.xtypeof)
            local Ref = {}

            Ref.type = 'SpecialKey'
            Ref.kind = 'Ref'
            Ref.stage = 'observer'

            function Ref:apply(refState, applyTo, cleanupTasks)
                if xtypeof(refState) ~= 'State' or refState.kind ~= 'Value' then
                    logError('invalidRefType')
                else
                    refState:set(applyTo)
                    table.insert(cleanupTasks, function()
                        refState:set(nil)
                    end)
                end
            end

            return Ref
        end)()
    end,
    [54] = function()
        local wax, script, require = ImportGlobals(54)

        return (function(...)
            local Package = script.Parent.Parent
            local Observer = require(Package.State.Observer)

            require(Package.PubTypes)

            local cleanup = require(Package.Utility.cleanup)
            local logError = require(Package.Logging.logError)
            local xtypeof = require(Package.Utility.xtypeof)
            local setProperty_unsafe = function(instance, property, value)
                (instance)[property] = value
            end
            local testPropertyAssignable = function(instance, property)
                (instance)[property] = (instance)[property]
            end
            local setProperty = function(instance, property, value)
                if not pcall(setProperty_unsafe, instance, property, value) then
                    if not pcall(testPropertyAssignable, instance, property) then
                        if instance == nil then
                            logError('setPropertyNilRef', nil, property, tostring(value))
                        else
                            logError('cannotAssignProperty', nil, instance.ClassName, property)
                        end
                    else
                        local givenType = typeof(value)
                        local expectedType = typeof((instance)[property])

                        logError('invalidPropertyType', nil, instance.ClassName, property, expectedType, givenType)
                    end
                end
            end
            local bindProperty = function(
                instance,
                property,
                value,
                cleanupTasks
            )
                if xtypeof(value) == 'State' then
                    local willUpdate = false
                    local updateLater = function()
                        if not willUpdate then
                            willUpdate = true

                            task.defer(function()
                                willUpdate = false

                                setProperty(instance, property, value:get(false))
                            end)
                        end
                    end

                    setProperty(instance, property, value:get(false))
                    table.insert(cleanupTasks, Observer(value):onChange(updateLater))
                else
                    setProperty(instance, property, value)
                end
            end
            local applyInstanceProps = function(props, applyTo)
                local specialKeys = {
                    self = {},
                    descendants = {},
                    ancestor = {},
                    observer = {},
                }
                local cleanupTasks = {}

                for key, value in pairs(props)do
                    local keyType = xtypeof(key)

                    if keyType == 'string' then
                        if key ~= 'Parent' then
                            bindProperty(applyTo, key, value, cleanupTasks)
                        end
                    elseif keyType == 'SpecialKey' then
                        local stage = (key).stage
                        local keys = specialKeys[stage]

                        if keys == nil then
                            logError('unrecognisedPropertyStage', nil, stage)
                        else
                            keys[key] = value
                        end
                    else
                        logError('unrecognisedPropertyKey', nil, xtypeof(key))
                    end
                end
                for key, value in pairs(specialKeys.self)do
                    key:apply(value, applyTo, cleanupTasks)
                end
                for key, value in pairs(specialKeys.descendants)do
                    key:apply(value, applyTo, cleanupTasks)
                end

                if props.Parent ~= nil then
                    bindProperty(applyTo, 'Parent', props.Parent, cleanupTasks)
                end

                for key, value in pairs(specialKeys.ancestor)do
                    key:apply(value, applyTo, cleanupTasks)
                end
                for key, value in pairs(specialKeys.observer)do
                    key:apply(value, applyTo, cleanupTasks)
                end

                applyTo.Destroying:Connect(function()
                    cleanup(cleanupTasks)
                end)
            end

            return applyInstanceProps
        end)()
    end,
    [55] = function()
        ImportGlobals(55)

        return (function(...)
            return {
                ScreenGui = {
                    ResetOnSpawn = false,
                    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                },
                BillboardGui = {
                    ResetOnSpawn = false,
                    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                },
                SurfaceGui = {
                    ResetOnSpawn = false,
                    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                    SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
                    PixelsPerStud = 50,
                },
                Frame = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                },
                ScrollingFrame = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    ScrollBarImageColor3 = Color3.new(0, 0, 0),
                },
                TextLabel = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    Font = Enum.Font.SourceSans,
                    Text = '',
                    TextColor3 = Color3.new(0, 0, 0),
                    TextSize = 14,
                },
                TextButton = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Font = Enum.Font.SourceSans,
                    Text = '',
                    TextColor3 = Color3.new(0, 0, 0),
                    TextSize = 14,
                },
                TextBox = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    Font = Enum.Font.SourceSans,
                    Text = '',
                    TextColor3 = Color3.new(0, 0, 0),
                    TextSize = 14,
                },
                ImageLabel = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                },
                ImageButton = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                },
                ViewportFrame = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                },
                VideoFrame = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                },
                CanvasGroup = {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                },
            }
        end)()
    end,
    [57] = function()
        local wax, script, require = ImportGlobals(57)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.Types)

            local messages = require(Package.Logging.messages)
            local logError = function(messageID, errObj, ...)
                local formatString

                if messages[messageID] ~= nil then
                    formatString = messages[messageID]
                else
                    messageID = 'unknownMessage'
                    formatString = messages[messageID]
                end

                local errorString

                if errObj == nil then
                    errorString = string.format('[Fusion] ' .. formatString .. '\n(ID: ' .. messageID .. ')', 
...)
                else
                    formatString = formatString:gsub('ERROR_MESSAGE', errObj.message)
                    errorString = string.format('[Fusion] ' .. formatString .. '\n(ID: ' .. messageID .. ')\n---- Stack trace ----\n' .. errObj.trace, 
...)
                end

                error(errorString:gsub('\n', '\n    '), 0)
            end

            return logError
        end)()
    end,
    [58] = function()
        local wax, script, require = ImportGlobals(58)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.Types)

            local messages = require(Package.Logging.messages)
            local logErrorNonFatal = function(messageID, errObj, ...)
                local formatString

                if messages[messageID] ~= nil then
                    formatString = messages[messageID]
                else
                    messageID = 'unknownMessage'
                    formatString = messages[messageID]
                end

                local errorString

                if errObj == nil then
                    errorString = string.format('[Fusion] ' .. formatString .. '\n(ID: ' .. messageID .. ')', 
...)
                else
                    formatString = formatString:gsub('ERROR_MESSAGE', errObj.message)
                    errorString = string.format('[Fusion] ' .. formatString .. '\n(ID: ' .. messageID .. ')\n---- Stack trace ----\n' .. errObj.trace, 
...)
                end

                task.spawn(function(...)
                    error(errorString:gsub('\n', '\n    '), 0)
                end, ...)
            end

            return logErrorNonFatal
        end)()
    end,
    [59] = function()
        local wax, script, require = ImportGlobals(59)

        return (function(...)
            local Package = script.Parent.Parent
            local messages = require(Package.Logging.messages)
            local logWarn = function(messageID, ...)
                local formatString

                if messages[messageID] ~= nil then
                    formatString = messages[messageID]
                else
                    messageID = 'unknownMessage'
                    formatString = messages[messageID]
                end

                warn(string.format('[Fusion] ' .. formatString .. '\n(ID: ' .. messageID .. ')', 
...))
            end

            return logWarn
        end)()
    end,
    [60] = function()
        ImportGlobals(60)

        return (function(...)
            return {
                cannotAssignProperty = "The class type '%s' has no assignable property '%s'.",
                cannotConnectChange = "The %s class doesn't have a property called '%s'.",
                cannotConnectEvent = "The %s class doesn't have an event called '%s'.",
                cannotCreateClass = "Can't create a new instance of class '%s'.",
                computedCallbackError = 'Computed callback error: ERROR_MESSAGE',
                destructorNeededValue = 
[[To save instances into Values, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]],
                destructorNeededComputed = 
[[To return instances from Computeds, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]],
                multiReturnComputed = 
[[Returning multiple values from Computeds is discouraged, as behaviour will change soon - see discussion #189 on GitHub.]],
                destructorNeededForKeys = 
[[To return instances from ForKeys, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]],
                destructorNeededForValues = 
[[To return instances from ForValues, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]],
                destructorNeededForPairs = 
[[To return instances from ForPairs, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.]],
                duplicatePropertyKey = '',
                forKeysProcessorError = 'ForKeys callback error: ERROR_MESSAGE',
                forKeysKeyCollision = 
[[ForKeys should only write to output key '%s' once when processing key changes, but it wrote to it twice. Previously input key: '%s'; New input key: '%s']],
                forKeysDestructorError = 'ForKeys destructor error: ERROR_MESSAGE',
                forPairsDestructorError = 'ForPairs destructor error: ERROR_MESSAGE',
                forPairsKeyCollision = 
[[ForPairs should only write to output key '%s' once when processing key changes, but it wrote to it twice. Previous input pair: '[%s] = %s'; New input pair: '[%s] = %s']],
                forPairsProcessorError = 'ForPairs callback error: ERROR_MESSAGE',
                forValuesProcessorError = 'ForValues callback error: ERROR_MESSAGE',
                forValuesDestructorError = 'ForValues destructor error: ERROR_MESSAGE',
                invalidChangeHandler = 
[[The change handler for the '%s' property must be a function.]],
                invalidEventHandler = "The handler for the '%s' event must be a function.",
                invalidPropertyType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
                invalidRefType = 'Instance refs must be Value objects.',
                invalidOutType = '[Out] properties must be given Value objects.',
                invalidOutProperty = "The %s class doesn't have a property called '%s'.",
                invalidSpringDamping = 
[[The damping ratio for a spring must be >= 0. (damping was %.2f)]],
                invalidSpringSpeed = 'The speed of a spring must be >= 0. (speed was %.2f)',
                mistypedSpringDamping = 'The damping ratio for a spring must be a number. (got a %s)',
                mistypedSpringSpeed = 'The speed of a spring must be a number. (got a %s)',
                mistypedTweenInfo = 'The tween info of a tween must be a TweenInfo. (got a %s)',
                springTypeMismatch = "The type '%s' doesn't match the spring's type '%s'.",
                strictReadError = "'%s' is not a valid member of '%s'.",
                unknownMessage = 'Unknown error: ERROR_MESSAGE',
                unrecognisedChildType = "'%s' type children aren't accepted by `[Children]`.",
                unrecognisedPropertyKey = "'%s' keys aren't accepted in property tables.",
                unrecognisedPropertyStage = 
[['%s' isn't a valid stage for a special key to be applied at.]],
            }
        end)()
    end,
    [61] = function()
        local wax, script, require = ImportGlobals(61)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.Types)

            local parseError = function(err)
                return {
                    type = 'Error',
                    raw = err,
                    message = err:gsub('^.+:%d+:%s*', ''),
                    trace = debug.traceback(nil, 2),
                }
            end

            return parseError
        end)()
    end,
    [62] = function()
        ImportGlobals(62)

        return (function(...)
            return nil
        end)()
    end,
    [64] = function()
        local wax, script, require = ImportGlobals(64)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.Types)

            local captureDependencies = require(Package.Dependencies.captureDependencies)
            local initDependency = require(Package.Dependencies.initDependency)
            local isSimilar = require(Package.Utility.isSimilar)
            local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
            local logWarn = require(Package.Logging.logWarn)
            local needsDestruction = require(Package.Utility.needsDestruction)
            local useDependency = require(Package.Dependencies.useDependency)
            local class = {}
            local CLASS_METATABLE = {__index = class}
            local WEAK_KEYS_METATABLE = {
                __mode = 'k',
            }

            function class:get(asDependency)
                if asDependency ~= false then
                    useDependency(self)
                end

                return self._value
            end
            function class:update()
                for dependency in pairs(self.dependencySet)do
                    dependency.dependentSet[self] = nil
                end

                self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

                table.clear(self.dependencySet)

                local ok, newValue, newMetaValue = captureDependencies(self.dependencySet, self._processor)

                if ok then
                    if self._destructor == nil and needsDestruction(newValue) then
                        logWarn('destructorNeededComputed')
                    end
                    if newMetaValue ~= nil then
                        logWarn('multiReturnComputed')
                    end

                    local oldValue = self._value
                    local similar = isSimilar(oldValue, newValue)

                    if self._destructor ~= nil then
                        self._destructor(oldValue)
                    end

                    self._value = newValue

                    for dependency in pairs(self.dependencySet)do
                        dependency.dependentSet[self] = true
                    end

                    return not similar
                else
                    logErrorNonFatal('computedCallbackError', newValue)

                    self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

                    for dependency in pairs(self.dependencySet)do
                        dependency.dependentSet[self] = true
                    end

                    return false
                end
            end

            local Computed = function(processor, destructor)
                local self = setmetatable({
                    type = 'State',
                    kind = 'Computed',
                    dependencySet = {},
                    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
                    _oldDependencySet = {},
                    _processor = processor,
                    _destructor = destructor,
                    _value = nil,
                }, CLASS_METATABLE)

                initDependency(self)
                self:update()

                return self
            end

            return Computed
        end)()
    end,
    [65] = function()
        local wax, script, require = ImportGlobals(65)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)
            require(Package.Types)

            local captureDependencies = require(Package.Dependencies.captureDependencies)
            local cleanup = require(Package.Utility.cleanup)
            local initDependency = require(Package.Dependencies.initDependency)
            local logError = require(Package.Logging.logError)
            local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
            local logWarn = require(Package.Logging.logWarn)
            local needsDestruction = require(Package.Utility.needsDestruction)
            local parseError = require(Package.Logging.parseError)
            local useDependency = require(Package.Dependencies.useDependency)
            local class = {}
            local CLASS_METATABLE = {__index = class}
            local WEAK_KEYS_METATABLE = {
                __mode = 'k',
            }

            function class:get(asDependency)
                if asDependency ~= false then
                    useDependency(self)
                end

                return self._outputTable
            end
            function class:update()
                local inputIsState = self._inputIsState
                local newInputTable = if inputIsState then self._inputTable:get(false)else self._inputTable
                local oldInputTable = self._oldInputTable
                local outputTable = self._outputTable
                local keyOIMap = self._keyOIMap
                local keyIOMap = self._keyIOMap
                local meta = self._meta
                local didChange = false

                for dependency in pairs(self.dependencySet)do
                    dependency.dependentSet[self] = nil
                end

                self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

                table.clear(self.dependencySet)

                if inputIsState then
                    self._inputTable.dependentSet[self] = true
                    self.dependencySet[self._inputTable] = true
                end

                for newInKey, value in pairs(newInputTable)do
                    local keyData = self._keyData[newInKey]

                    if keyData == nil then
                        keyData = {
                            dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
                            oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
                            dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
                        }
                        self._keyData[newInKey] = keyData
                    end

                    local shouldRecalculate = oldInputTable[newInKey] == nil

                    if shouldRecalculate == false then
                        for dependency, oldValue in pairs(keyData.dependencyValues)do
                            if oldValue ~= dependency:get(false) then
                                shouldRecalculate = true

                                break
                            end
                        end
                    end
                    if shouldRecalculate then
                        keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

                        table.clear(keyData.dependencySet)

                        local processOK, newOutKey, newMetaValue = captureDependencies(keyData.dependencySet, self._processor, newInKey)

                        if processOK then
                            if self._destructor == nil and (needsDestruction(newOutKey) or needsDestruction(newMetaValue)) then
                                logWarn('destructorNeededForKeys')
                            end

                            local oldInKey = keyOIMap[newOutKey]
                            local oldOutKey = keyIOMap[newInKey]

                            if oldInKey ~= newInKey and newInputTable[oldInKey] ~= nil then
                                logError('forKeysKeyCollision', nil, tostring(newOutKey), tostring(oldInKey), tostring(newOutKey))
                            end
                            if oldOutKey ~= newOutKey and keyOIMap[oldOutKey] == newInKey then
                                local oldMetaValue = meta[oldOutKey]
                                local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldOutKey, oldMetaValue)

                                if not destructOK then
                                    logErrorNonFatal('forKeysDestructorError', err)
                                end

                                keyOIMap[oldOutKey] = nil
                                outputTable[oldOutKey] = nil
                                meta[oldOutKey] = nil
                            end

                            oldInputTable[newInKey] = value
                            meta[newOutKey] = newMetaValue
                            keyOIMap[newOutKey] = newInKey
                            keyIOMap[newInKey] = newOutKey
                            outputTable[newOutKey] = value
                            didChange = true
                        else
                            keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

                            logErrorNonFatal('forKeysProcessorError', newOutKey)
                        end
                    end

                    for dependency in pairs(keyData.dependencySet)do
                        keyData.dependencyValues[dependency] = dependency:get(false)
                        self.dependencySet[dependency] = true
                        dependency.dependentSet[self] = true
                    end
                end
                for outputKey, inputKey in pairs(keyOIMap)do
                    if newInputTable[inputKey] == nil then
                        local oldMetaValue = meta[outputKey]
                        local destructOK, err = xpcall(self._destructor or cleanup, parseError, outputKey, oldMetaValue)

                        if not destructOK then
                            logErrorNonFatal('forKeysDestructorError', err)
                        end

                        oldInputTable[inputKey] = nil
                        meta[outputKey] = nil
                        keyOIMap[outputKey] = nil
                        keyIOMap[inputKey] = nil
                        outputTable[outputKey] = nil
                        self._keyData[inputKey] = nil
                        didChange = true
                    end
                end

                return didChange
            end

            local ForKeys = function(inputTable, processor, destructor)
                local inputIsState = inputTable.type == 'State' and typeof(inputTable.get) == 'function'
                local self = setmetatable({
                    type = 'State',
                    kind = 'ForKeys',
                    dependencySet = {},
                    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
                    _oldDependencySet = {},
                    _processor = processor,
                    _destructor = destructor,
                    _inputIsState = inputIsState,
                    _inputTable = inputTable,
                    _oldInputTable = {},
                    _outputTable = {},
                    _keyOIMap = {},
                    _keyIOMap = {},
                    _keyData = {},
                    _meta = {},
                }, CLASS_METATABLE)

                initDependency(self)
                self:update()

                return self
            end

            return ForKeys
        end)()
    end,
    [66] = function()
        local wax, script, require = ImportGlobals(66)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)
            require(Package.Types)

            local captureDependencies = require(Package.Dependencies.captureDependencies)
            local cleanup = require(Package.Utility.cleanup)
            local initDependency = require(Package.Dependencies.initDependency)
            local logError = require(Package.Logging.logError)
            local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
            local logWarn = require(Package.Logging.logWarn)
            local needsDestruction = require(Package.Utility.needsDestruction)
            local parseError = require(Package.Logging.parseError)
            local useDependency = require(Package.Dependencies.useDependency)
            local class = {}
            local CLASS_METATABLE = {__index = class}
            local WEAK_KEYS_METATABLE = {
                __mode = 'k',
            }

            function class:get(asDependency)
                if asDependency ~= false then
                    useDependency(self)
                end

                return self._outputTable
            end
            function class:update()
                local inputIsState = self._inputIsState
                local newInputTable = if inputIsState then self._inputTable:get(false)else self._inputTable
                local oldInputTable = self._oldInputTable
                local keyIOMap = self._keyIOMap
                local meta = self._meta
                local didChange = false

                for dependency in pairs(self.dependencySet)do
                    dependency.dependentSet[self] = nil
                end

                self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

                table.clear(self.dependencySet)

                if inputIsState then
                    self._inputTable.dependentSet[self] = true
                    self.dependencySet[self._inputTable] = true
                end

                self._oldOutputTable, self._outputTable = self._outputTable, self._oldOutputTable

                local oldOutputTable = self._oldOutputTable
                local newOutputTable = self._outputTable

                table.clear(newOutputTable)

                for newInKey, newInValue in pairs(newInputTable)do
                    local keyData = self._keyData[newInKey]

                    if keyData == nil then
                        keyData = {
                            dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
                            oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
                            dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
                        }
                        self._keyData[newInKey] = keyData
                    end

                    local shouldRecalculate = oldInputTable[newInKey] ~= newInValue

                    if shouldRecalculate == false then
                        for dependency, oldValue in pairs(keyData.dependencyValues)do
                            if oldValue ~= dependency:get(false) then
                                shouldRecalculate = true

                                break
                            end
                        end
                    end
                    if shouldRecalculate then
                        keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

                        table.clear(keyData.dependencySet)

                        local processOK, newOutKey, newOutValue, newMetaValue = captureDependencies(keyData.dependencySet, self._processor, newInKey, newInValue)

                        if processOK then
                            if self._destructor == nil and (needsDestruction(newOutKey) or needsDestruction(newOutValue) or needsDestruction(newMetaValue)) then
                                logWarn('destructorNeededForPairs')
                            end
                            if newOutputTable[newOutKey] ~= nil then
                                local previousNewKey, previousNewValue

                                for inKey, outKey in pairs(keyIOMap)do
                                    if outKey == newOutKey then
                                        previousNewValue = newInputTable[inKey]

                                        if previousNewValue ~= nil then
                                            previousNewKey = inKey

                                            break
                                        end
                                    end
                                end

                                if previousNewKey ~= nil then
                                    logError('forPairsKeyCollision', nil, tostring(newOutKey), tostring(previousNewKey), tostring(previousNewValue), tostring(newInKey), tostring(newInValue))
                                end
                            end

                            local oldOutValue = oldOutputTable[newOutKey]

                            if oldOutValue ~= newOutValue then
                                local oldMetaValue = meta[newOutKey]

                                if oldOutValue ~= nil then
                                    local destructOK, err = xpcall(self._destructor or cleanup, parseError, newOutKey, oldOutValue, oldMetaValue)

                                    if not destructOK then
                                        logErrorNonFatal('forPairsDestructorError', err)
                                    end
                                end

                                oldOutputTable[newOutKey] = nil
                            end

                            oldInputTable[newInKey] = newInValue
                            keyIOMap[newInKey] = newOutKey
                            meta[newOutKey] = newMetaValue
                            newOutputTable[newOutKey] = newOutValue
                            didChange = true
                        else
                            keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

                            logErrorNonFatal('forPairsProcessorError', newOutKey)
                        end
                    else
                        local storedOutKey = keyIOMap[newInKey]

                        if newOutputTable[storedOutKey] ~= nil then
                            local previousNewKey, previousNewValue

                            for inKey, outKey in pairs(keyIOMap)do
                                if storedOutKey == outKey then
                                    previousNewValue = newInputTable[inKey]

                                    if previousNewValue ~= nil then
                                        previousNewKey = inKey

                                        break
                                    end
                                end
                            end

                            if previousNewKey ~= nil then
                                logError('forPairsKeyCollision', nil, tostring(storedOutKey), tostring(previousNewKey), tostring(previousNewValue), tostring(newInKey), tostring(newInValue))
                            end
                        end

                        newOutputTable[storedOutKey] = oldOutputTable[storedOutKey]
                    end

                    for dependency in pairs(keyData.dependencySet)do
                        keyData.dependencyValues[dependency] = dependency:get(false)
                        self.dependencySet[dependency] = true
                        dependency.dependentSet[self] = true
                    end
                end
                for oldOutKey, oldOutValue in pairs(oldOutputTable)do
                    if newOutputTable[oldOutKey] ~= oldOutValue then
                        local oldMetaValue = meta[oldOutKey]

                        if oldOutValue ~= nil then
                            local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldOutKey, oldOutValue, oldMetaValue)

                            if not destructOK then
                                logErrorNonFatal('forPairsDestructorError', err)
                            end
                        end
                        if newOutputTable[oldOutKey] == nil then
                            meta[oldOutKey] = nil
                            self._keyData[oldOutKey] = nil
                        end

                        didChange = true
                    end
                end
                for key in pairs(oldInputTable)do
                    if newInputTable[key] == nil then
                        oldInputTable[key] = nil
                        keyIOMap[key] = nil
                    end
                end

                return didChange
            end

            local ForPairs = function(inputTable, processor, destructor)
                local inputIsState = inputTable.type == 'State' and typeof(inputTable.get) == 'function'
                local self = setmetatable({
                    type = 'State',
                    kind = 'ForPairs',
                    dependencySet = {},
                    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
                    _oldDependencySet = {},
                    _processor = processor,
                    _destructor = destructor,
                    _inputIsState = inputIsState,
                    _inputTable = inputTable,
                    _oldInputTable = {},
                    _outputTable = {},
                    _oldOutputTable = {},
                    _keyIOMap = {},
                    _keyData = {},
                    _meta = {},
                }, CLASS_METATABLE)

                initDependency(self)
                self:update()

                return self
            end

            return ForPairs
        end)()
    end,
    [67] = function()
        local wax, script, require = ImportGlobals(67)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)
            require(Package.Types)

            local captureDependencies = require(Package.Dependencies.captureDependencies)
            local cleanup = require(Package.Utility.cleanup)
            local initDependency = require(Package.Dependencies.initDependency)
            local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
            local logWarn = require(Package.Logging.logWarn)
            local needsDestruction = require(Package.Utility.needsDestruction)
            local parseError = require(Package.Logging.parseError)
            local useDependency = require(Package.Dependencies.useDependency)
            local class = {}
            local CLASS_METATABLE = {__index = class}
            local WEAK_KEYS_METATABLE = {
                __mode = 'k',
            }

            function class:get(asDependency)
                if asDependency ~= false then
                    useDependency(self)
                end

                return self._outputTable
            end
            function class:update()
                local inputIsState = self._inputIsState
                local inputTable = if inputIsState then self._inputTable:get(false)else self._inputTable
                local outputValues = {}
                local didChange = false

                self._oldValueCache, self._valueCache = self._valueCache, self._oldValueCache

                local newValueCache = self._valueCache
                local oldValueCache = self._oldValueCache

                table.clear(newValueCache)

                for dependency in pairs(self.dependencySet)do
                    dependency.dependentSet[self] = nil
                end

                self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

                table.clear(self.dependencySet)

                if inputIsState then
                    self._inputTable.dependentSet[self] = true
                    self.dependencySet[self._inputTable] = true
                end

                for inKey, inValue in pairs(inputTable)do
                    local oldCachedValues = oldValueCache[inValue]
                    local shouldRecalculate = oldCachedValues == nil
                    local value, valueData, meta

                    if type(oldCachedValues) == 'table' and #oldCachedValues > 0 then
                        local valueInfo = table.remove(oldCachedValues, #oldCachedValues)

                        value = valueInfo.value
                        valueData = valueInfo.valueData
                        meta = valueInfo.meta

                        if #oldCachedValues <= 0 then
                            oldValueCache[inValue] = nil
                        end
                    elseif oldCachedValues ~= nil then
                        oldValueCache[inValue] = nil
                        shouldRecalculate = true
                    end
                    if valueData == nil then
                        valueData = {
                            dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
                            oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
                            dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
                        }
                    end
                    if shouldRecalculate == false then
                        for dependency, oldValue in pairs(valueData.dependencyValues)do
                            if oldValue ~= dependency:get(false) then
                                shouldRecalculate = true

                                break
                            end
                        end
                    end
                    if shouldRecalculate then
                        valueData.oldDependencySet, valueData.dependencySet = valueData.dependencySet, valueData.oldDependencySet

                        table.clear(valueData.dependencySet)

                        local processOK, newOutValue, newMetaValue = captureDependencies(valueData.dependencySet, self._processor, inValue)

                        if processOK then
                            if self._destructor == nil and (needsDestruction(newOutValue) or needsDestruction(newMetaValue)) then
                                logWarn('destructorNeededForValues')
                            end
                            if value ~= nil then
                                local destructOK, err = xpcall(self._destructor or cleanup, parseError, value, meta)

                                if not destructOK then
                                    logErrorNonFatal('forValuesDestructorError', err)
                                end
                            end

                            value = newOutValue
                            meta = newMetaValue
                            didChange = true
                        else
                            valueData.oldDependencySet, valueData.dependencySet = valueData.dependencySet, valueData.oldDependencySet

                            logErrorNonFatal('forValuesProcessorError', newOutValue)
                        end
                    end

                    local newCachedValues = newValueCache[inValue]

                    if newCachedValues == nil then
                        newCachedValues = {}
                        newValueCache[inValue] = newCachedValues
                    end

                    table.insert(newCachedValues, {
                        value = value,
                        valueData = valueData,
                        meta = meta,
                    })

                    outputValues[inKey] = value

                    for dependency in pairs(valueData.dependencySet)do
                        valueData.dependencyValues[dependency] = dependency:get(false)
                        self.dependencySet[dependency] = true
                        dependency.dependentSet[self] = true
                    end
                end
                for _oldInValue, oldCachedValueInfo in pairs(oldValueCache)do
                    for _, valueInfo in ipairs(oldCachedValueInfo)do
                        local oldValue = valueInfo.value
                        local oldMetaValue = valueInfo.meta
                        local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldValue, oldMetaValue)

                        if not destructOK then
                            logErrorNonFatal('forValuesDestructorError', err)
                        end

                        didChange = true
                    end

                    table.clear(oldCachedValueInfo)
                end

                self._outputTable = outputValues

                return didChange
            end

            local ForValues = function(inputTable, processor, destructor)
                local inputIsState = inputTable.type == 'State' and typeof(inputTable.get) == 'function'
                local self = setmetatable({
                    type = 'State',
                    kind = 'ForValues',
                    dependencySet = {},
                    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
                    _oldDependencySet = {},
                    _processor = processor,
                    _destructor = destructor,
                    _inputIsState = inputIsState,
                    _inputTable = inputTable,
                    _outputTable = {},
                    _valueCache = {},
                    _oldValueCache = {},
                }, CLASS_METATABLE)

                initDependency(self)
                self:update()

                return self
            end

            return ForValues
        end)()
    end,
    [68] = function()
        local wax, script, require = ImportGlobals(68)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)
            require(Package.Types)

            local initDependency = require(Package.Dependencies.initDependency)
            local class = {}
            local CLASS_METATABLE = {__index = class}
            local strongRefs = {}

            function class:update()
                for _, callback in pairs(self._changeListeners)do
                    task.spawn(callback)
                end

                return false
            end
            function class:onChange(callback)
                local uniqueIdentifier = {}

                self._numChangeListeners += 1

                self._changeListeners[uniqueIdentifier] = callback
                strongRefs[self] = true

                local disconnected = false

                return function()
                    if disconnected then
                        return
                    end

                    disconnected = true
                    self._changeListeners[uniqueIdentifier] = nil

                    self._numChangeListeners -= 1

                    if self._numChangeListeners == 0 then
                        strongRefs[self] = nil
                    end
                end
            end

            local Observer = function(watchedState)
                local self = setmetatable({
                    type = 'State',
                    kind = 'Observer',
                    dependencySet = {[watchedState] = true},
                    dependentSet = {},
                    _changeListeners = {},
                    _numChangeListeners = 0,
                }, CLASS_METATABLE)

                initDependency(self)

                watchedState.dependentSet[self] = true

                return self
            end

            return Observer
        end)()
    end,
    [69] = function()
        local wax, script, require = ImportGlobals(69)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.Types)

            local initDependency = require(Package.Dependencies.initDependency)
            local isSimilar = require(Package.Utility.isSimilar)
            local updateAll = require(Package.Dependencies.updateAll)
            local useDependency = require(Package.Dependencies.useDependency)
            local class = {}
            local CLASS_METATABLE = {__index = class}
            local WEAK_KEYS_METATABLE = {
                __mode = 'k',
            }

            function class:get(asDependency)
                if asDependency ~= false then
                    useDependency(self)
                end

                return self._value
            end
            function class:set(newValue, force)
                local oldValue = self._value

                if force or not isSimilar(oldValue, newValue) then
                    self._value = newValue

                    updateAll(self)
                end
            end

            local Value = function(initialValue)
                local self = setmetatable({
                    type = 'State',
                    kind = 'Value',
                    dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
                    _value = initialValue,
                }, CLASS_METATABLE)

                initDependency(self)

                return self
            end

            return Value
        end)()
    end,
    [70] = function()
        local wax, script, require = ImportGlobals(70)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.PubTypes)

            local xtypeof = require(Package.Utility.xtypeof)
            local unwrap = function(item, useDependency)
                return if xtypeof(item) == 'State'then(item):get(useDependency)else item
            end

            return unwrap
        end)()
    end,
    [71] = function()
        local wax, script, require = ImportGlobals(71)

        return (function(...)
            local Package = script.Parent

            require(Package.PubTypes)

            return nil
        end)()
    end,
    [73] = function()
        local wax, script, require = ImportGlobals(73)

        return (function(...)
            local Package = script.Parent.Parent

            require(Package.Types)

            return {
                type = 'Symbol',
                name = 'None',
            }
        end)()
    end,
    [74] = function()
        ImportGlobals(74)

        return (function(...)
            local function cleanupOne(task)
                local taskType = typeof(task)

                if taskType == 'Instance' then
                    task:Destroy()
                elseif taskType == 'RBXScriptConnection' then
                    task:Disconnect()
                elseif taskType == 'function' then
                    task()
                elseif taskType == 'table' then
                    if typeof(task.destroy) == 'function' then
                        task:destroy()
                    elseif typeof(task.Destroy) == 'function' then
                        task:Destroy()
                    elseif task[1] ~= nil then
                        for _, subtask in ipairs(task)do
                            cleanupOne(subtask)
                        end
                    end
                end
            end

            local cleanup = function(...)
                for index = 1, select('#', ...)do
                    cleanupOne(select(index, ...))
                end
            end

            return cleanup
        end)()
    end,
    [75] = function()
        ImportGlobals(75)

        return (function(...)
            local doNothing = function(...) end

            return doNothing
        end)()
    end,
    [76] = function()
        ImportGlobals(76)

        return (function(...)
            local isSimilar = function(a, b)
                if typeof(a) == 'table' then
                    return false
                else
                    return a == b
                end
            end

            return isSimilar
        end)()
    end,
    [77] = function()
        ImportGlobals(77)

        return (function(...)
            local needsDestruction = function(x)
                return typeof(x) == 'Instance'
            end

            return needsDestruction
        end)()
    end,
    [78] = function()
        local wax, script, require = ImportGlobals(78)

        return (function(...)
            local Package = script.Parent.Parent
            local logError = require(Package.Logging.logError)
            local restrictRead = function(tableName, strictTable)
                local metatable = getmetatable(strictTable)

                if metatable == nil then
                    metatable = {}

                    setmetatable(strictTable, metatable)
                end

                function metatable:__index(memberName)
                    logError('strictReadError', nil, tostring(memberName), tableName)
                end

                return strictTable
            end

            return restrictRead
        end)()
    end,
    [79] = function()
        ImportGlobals(79)

        return (function(...)
            local xtypeof = function(x)
                local typeString = typeof(x)

                if typeString == 'table' and typeof(x.type) == 'string' then
                    return x.type
                else
                    return typeString
                end
            end

            return xtypeof
        end)()
    end,
    [80] = function()
        ImportGlobals(80)

        return (function(...)
            local Maid = {}

            Maid.ClassName = 'Maid'

            function Maid.new()
                return setmetatable({_tasks = {}}, Maid)
            end
            function Maid.isMaid(value)
                return type(value) == 'table' and value.ClassName == 'Maid'
            end
            function Maid:__index(index)
                if Maid[index] then
                    return Maid[index]
                else
                    return self._tasks[index]
                end
            end
            function Maid:__newindex(index, newTask)
                if Maid[index] ~= nil then
                    error(("'%s' is reserved"):format(tostring(index)), 2)
                end

                local tasks = self._tasks
                local oldTask = tasks[index]

                if oldTask == newTask then
                    return
                end

                tasks[index] = newTask

                if oldTask then
                    if type(oldTask) == 'function' then
                        oldTask()
                    elseif typeof(oldTask) == 'RBXScriptConnection' then
                        oldTask:Disconnect()
                    elseif oldTask.Destroy then
                        oldTask:Destroy()
                    end
                end
            end
            function Maid:GiveTask(task)
                if not task then
                    error('Task cannot be false or nil', 2)
                end

                local taskId = #self._tasks + 1

                self[taskId] = task

                return taskId
            end
            function Maid:GivePromise(promise)
                if not promise:IsPending() then
                    return promise
                end

                local newPromise = promise.resolved(promise)
                local id = self:GiveTask(newPromise)

                newPromise:Finally(function()
                    self[id] = nil
                end)

                return newPromise
            end
            function Maid:DoCleaning()
                local tasks = self._tasks

                for index, task in pairs(tasks)do
                    if typeof(task) == 'RBXScriptConnection' then
                        tasks[index] = nil

                        task:Disconnect()
                    end
                end

                local index, task = next(tasks)

                while task ~= nil do
                    tasks[index] = nil

                    if type(task) == 'function' then
                        task()
                    elseif typeof(task) == 'RBXScriptConnection' then
                        task:Disconnect()
                    elseif task.Destroy then
                        task:Destroy()
                    end

                    index, task = next(tasks)
                end
            end

            Maid.Destroy = Maid.DoCleaning

            return Maid
        end)()
    end,
    [81] = function()
        ImportGlobals(81)

        return (function(...)
            local ERROR_NON_PROMISE_IN_LIST = 'Non-promise value passed into %s at index %s'
            local ERROR_NON_LIST = 'Please pass a list of promises to %s'
            local ERROR_NON_FUNCTION = 'Please pass a handler function to %s!'
            local MODE_KEY_METATABLE = {
                __mode = 'k',
            }
            local isCallable = function(value)
                if type(value) == 'function' then
                    return true
                end
                if type(value) == 'table' then
                    local metatable = getmetatable(value)

                    if metatable and type(rawget(metatable, '__call')) == 'function' then
                        return true
                    end
                end

                return false
            end
            local makeEnum = function(enumName, members)
                local enum = {}

                for _, memberName in ipairs(members)do
                    enum[memberName] = memberName
                end

                return setmetatable(enum, {
                    __index = function(_, k)
                        error(string.format('%s is not in %s!', k, enumName), 2)
                    end,
                    __newindex = function()
                        error(string.format('Creating new members in %s is not allowed!', enumName), 2)
                    end,
                })
            end
            local Error

            do
                Error = {
                    Kind = makeEnum('Promise.Error.Kind', {
                        'ExecutionError',
                        'AlreadyCancelled',
                        'NotResolvedInTime',
                        'TimedOut',
                    }),
                }
                Error.__index = Error

                function Error.new(options, parent)
                    options = options or {}

                    return setmetatable({
                        error = tostring(options.error) or '[This error has no error text.]',
                        trace = options.trace,
                        context = options.context,
                        kind = options.kind,
                        parent = parent,
                        createdTick = os.clock(),
                        createdTrace = debug.traceback(),
                    }, Error)
                end
                function Error.is(anything)
                    if type(anything) == 'table' then
                        local metatable = getmetatable(anything)

                        if type(metatable) == 'table' then
                            return rawget(anything, 'error') ~= nil and type(rawget(metatable, 'extend')) == 'function'
                        end
                    end

                    return false
                end
                function Error.isKind(anything, kind)
                    assert(kind ~= nil, 'Argument #2 to Promise.Error.isKind must not be nil')

                    return Error.is(anything) and anything.kind == kind
                end
                function Error:extend(options)
                    options = options or {}
                    options.kind = options.kind or self.kind

                    return Error.new(options, self)
                end
                function Error:getErrorChain()
                    local runtimeErrors = {self}

                    while runtimeErrors[#runtimeErrors].parent do
                        table.insert(runtimeErrors, runtimeErrors[#runtimeErrors].parent)
                    end

                    return runtimeErrors
                end
                function Error:__tostring()
                    local errorStrings = {
                        string.format('-- Promise.Error(%s) --', self.kind or '?'),
                    }

                    for _, runtimeError in ipairs(self:getErrorChain())do
                        table.insert(errorStrings, table.concat({
                            runtimeError.trace or runtimeError.error,
                            runtimeError.context,
                        }, '\n'))
                    end

                    return table.concat(errorStrings, '\n')
                end
            end

            local pack = function(...)
                return select('#', ...), {...}
            end
            local packResult = function(success, ...)
                return success, select('#', ...), {...}
            end
            local makeErrorHandler = function(traceback)
                assert(traceback ~= nil, 'traceback is nil')

                return function(err)
                    if type(err) == 'table' then
                        return err
                    end

                    return Error.new({
                        error = err,
                        kind = Error.Kind.ExecutionError,
                        trace = debug.traceback(tostring(err), 2),
                        context = 'Promise created at:\n\n' .. traceback,
                    })
                end
            end
            local runExecutor = function(traceback, callback, ...)
                return packResult(xpcall(callback, makeErrorHandler(traceback), 
...))
            end
            local createAdvancer = function(
                traceback,
                callback,
                resolve,
                reject
            )
                return function(...)
                    local ok, resultLength, result = runExecutor(traceback, callback, 
...)

                    if ok then
                        resolve(unpack(result, 1, resultLength))
                    else
                        reject(result[1])
                    end
                end
            end
            local isEmpty = function(t)
                return next(t) == nil
            end
            local Promise = {
                Error = Error,
                Status = makeEnum('Promise.Status', {
                    'Started',
                    'Resolved',
                    'Rejected',
                    'Cancelled',
                }),
                _getTime = os.clock,
                _timeEvent = game:GetService('RunService').Heartbeat,
                _unhandledRejectionCallbacks = {},
            }

            Promise.prototype = {}
            Promise.__index = Promise.prototype

            function Promise._new(traceback, callback, parent)
                if parent ~= nil and not Promise.is(parent) then
                    error('Argument #2 to Promise.new must be a promise or nil', 2)
                end

                local self = {
                    _thread = nil,
                    _source = traceback,
                    _status = Promise.Status.Started,
                    _values = nil,
                    _valuesLength = -1,
                    _unhandledRejection = true,
                    _queuedResolve = {},
                    _queuedReject = {},
                    _queuedFinally = {},
                    _cancellationHook = nil,
                    _parent = parent,
                    _consumers = setmetatable({}, MODE_KEY_METATABLE),
                }

                if parent and parent._status == Promise.Status.Started then
                    parent._consumers[self] = true
                end

                setmetatable(self, Promise)

                local resolve = function(...)
                    self:_resolve(...)
                end
                local reject = function(...)
                    self:_reject(...)
                end
                local onCancel = function(cancellationHook)
                    if cancellationHook then
                        if self._status == Promise.Status.Cancelled then
                            cancellationHook()
                        else
                            self._cancellationHook = cancellationHook
                        end
                    end

                    return self._status == Promise.Status.Cancelled
                end

                self._thread = coroutine.create(function()
                    local ok, _, result = runExecutor(self._source, callback, resolve, reject, onCancel)

                    if not ok then
                        reject(result[1])
                    end
                end)

                task.spawn(self._thread)

                return self
            end
            function Promise.new(executor)
                return Promise._new(debug.traceback(nil, 2), executor)
            end
            function Promise:__tostring()
                return string.format('Promise(%s)', self._status)
            end
            function Promise.defer(executor)
                local traceback = debug.traceback(nil, 2)
                local promise

                promise = Promise._new(traceback, function(
                    resolve,
                    reject,
                    onCancel
                )
                    local connection

                    connection = Promise._timeEvent:Connect(function()
                        connection:Disconnect()

                        local ok, _, result = runExecutor(traceback, executor, resolve, reject, onCancel)

                        if not ok then
                            reject(result[1])
                        end
                    end)
                end)

                return promise
            end

            Promise.async = Promise.defer

            function Promise.resolve(...)
                local length, values = pack(...)

                return Promise._new(debug.traceback(nil, 2), function(resolve)
                    resolve(unpack(values, 1, length))
                end)
            end
            function Promise.reject(...)
                local length, values = pack(...)

                return Promise._new(debug.traceback(nil, 2), function(
                    _,
                    reject
                )
                    reject(unpack(values, 1, length))
                end)
            end
            function Promise._try(traceback, callback, ...)
                local valuesLength, values = pack(...)

                return Promise._new(traceback, function(resolve)
                    resolve(callback(unpack(values, 1, valuesLength)))
                end)
            end
            function Promise.try(callback, ...)
                return Promise._try(debug.traceback(nil, 2), callback, ...)
            end
            function Promise._all(traceback, promises, amount)
                if type(promises) ~= 'table' then
                    error(string.format(ERROR_NON_LIST, 'Promise.all'), 3)
                end

                for i, promise in pairs(promises)do
                    if not Promise.is(promise) then
                        error(string.format(ERROR_NON_PROMISE_IN_LIST, 'Promise.all', tostring(i)), 3)
                    end
                end

                if #promises == 0 or amount == 0 then
                    return Promise.resolve({})
                end

                return Promise._new(traceback, function(
                    resolve,
                    reject,
                    onCancel
                )
                    local resolvedValues = {}
                    local newPromises = {}
                    local resolvedCount = 0
                    local rejectedCount = 0
                    local done = false
                    local cancel = function()
                        for _, promise in ipairs(newPromises)do
                            promise:cancel()
                        end
                    end
                    local resolveOne = function(i, ...)
                        if done then
                            return
                        end

                        resolvedCount = resolvedCount + 1

                        if amount == nil then
                            resolvedValues[i] = ...
                        else
                            resolvedValues[resolvedCount] = ...
                        end
                        if resolvedCount >= (amount or #promises) then
                            done = true

                            resolve(resolvedValues)
                            cancel()
                        end
                    end

                    onCancel(cancel)

                    for i, promise in ipairs(promises)do
                        newPromises[i] = promise:andThen(function(...)
                            resolveOne(i, ...)
                        end, function(...)
                            rejectedCount = rejectedCount + 1

                            if amount == nil or #promises - rejectedCount < amount then
                                cancel()

                                done = true

                                reject(...)
                            end
                        end)
                    end

                    if done then
                        cancel()
                    end
                end)
            end
            function Promise.all(promises)
                return Promise._all(debug.traceback(nil, 2), promises)
            end
            function Promise.fold(list, reducer, initialValue)
                assert(type(list) == 'table', 'Bad argument #1 to Promise.fold: must be a table')
                assert(isCallable(reducer), 'Bad argument #2 to Promise.fold: must be a function')

                local accumulator = Promise.resolve(initialValue)

                return Promise.each(list, function(resolvedElement, i)
                    accumulator = accumulator:andThen(function(
                        previousValueResolved
                    )
                        return reducer(previousValueResolved, resolvedElement, i)
                    end)
                end):andThen(function()
                    return accumulator
                end)
            end
            function Promise.some(promises, count)
                assert(type(count) == 'number', 'Bad argument #2 to Promise.some: must be a number')

                return Promise._all(debug.traceback(nil, 2), promises, count)
            end
            function Promise.any(promises)
                return Promise._all(debug.traceback(nil, 2), promises, 1):andThen(function(
                    values
                )
                    return values[1]
                end)
            end
            function Promise.allSettled(promises)
                if type(promises) ~= 'table' then
                    error(string.format(ERROR_NON_LIST, 'Promise.allSettled'), 2)
                end

                for i, promise in pairs(promises)do
                    if not Promise.is(promise) then
                        error(string.format(ERROR_NON_PROMISE_IN_LIST, 'Promise.allSettled', tostring(i)), 2)
                    end
                end

                if #promises == 0 then
                    return Promise.resolve({})
                end

                return Promise._new(debug.traceback(nil, 2), function(
                    resolve,
                    _,
                    onCancel
                )
                    local fates = {}
                    local newPromises = {}
                    local finishedCount = 0
                    local resolveOne = function(i, ...)
                        finishedCount = finishedCount + 1
                        fates[i] = ...

                        if finishedCount >= #promises then
                            resolve(fates)
                        end
                    end

                    onCancel(function()
                        for _, promise in ipairs(newPromises)do
                            promise:cancel()
                        end
                    end)

                    for i, promise in ipairs(promises)do
                        newPromises[i] = promise:finally(function(...)
                            resolveOne(i, ...)
                        end)
                    end
                end)
            end
            function Promise.race(promises)
                assert(type(promises) == 'table', string.format(ERROR_NON_LIST, 'Promise.race'))

                for i, promise in pairs(promises)do
                    assert(Promise.is(promise), string.format(ERROR_NON_PROMISE_IN_LIST, 'Promise.race', tostring(i)))
                end

                return Promise._new(debug.traceback(nil, 2), function(
                    resolve,
                    reject,
                    onCancel
                )
                    local newPromises = {}
                    local finished = false
                    local cancel = function()
                        for _, promise in ipairs(newPromises)do
                            promise:cancel()
                        end
                    end
                    local finalize = function(callback)
                        return function(...)
                            cancel()

                            finished = true

                            return callback(...)
                        end
                    end

                    if onCancel(finalize(reject)) then
                        return
                    end

                    for i, promise in ipairs(promises)do
                        newPromises[i] = promise:andThen(finalize(resolve), finalize(reject))
                    end

                    if finished then
                        cancel()
                    end
                end)
            end
            function Promise.each(list, predicate)
                assert(type(list) == 'table', string.format(ERROR_NON_LIST, 'Promise.each'))
                assert(isCallable(predicate), string.format(ERROR_NON_FUNCTION, 'Promise.each'))

                return Promise._new(debug.traceback(nil, 2), function(
                    resolve,
                    reject,
                    onCancel
                )
                    local results = {}
                    local promisesToCancel = {}
                    local cancelled = false
                    local cancel = function()
                        for _, promiseToCancel in ipairs(promisesToCancel)do
                            promiseToCancel:cancel()
                        end
                    end

                    onCancel(function()
                        cancelled = true

                        cancel()
                    end)

                    local preprocessedList = {}

                    for index, value in ipairs(list)do
                        if Promise.is(value) then
                            if value:getStatus() == Promise.Status.Cancelled then
                                cancel()

                                return reject(Error.new({
                                    error = 'Promise is cancelled',
                                    kind = Error.Kind.AlreadyCancelled,
                                    context = string.format(
[[The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.

That Promise was created at:

%s]], index, value._source),
                                }))
                            elseif value:getStatus() == Promise.Status.Rejected then
                                cancel()

                                return reject(select(2, value:await()))
                            end

                            local ourPromise = value:andThen(function(...)
                                return ...
                            end)

                            table.insert(promisesToCancel, ourPromise)

                            preprocessedList[index] = ourPromise
                        else
                            preprocessedList[index] = value
                        end
                    end
                    for index, value in ipairs(preprocessedList)do
                        if Promise.is(value) then
                            local success

                            success, value = value:await()

                            if not success then
                                cancel()

                                return reject(value)
                            end
                        end
                        if cancelled then
                            return
                        end

                        local predicatePromise = Promise.resolve(predicate(value, index))

                        table.insert(promisesToCancel, predicatePromise)

                        local success, result = predicatePromise:await()

                        if not success then
                            cancel()

                            return reject(result)
                        end

                        results[index] = result
                    end

                    resolve(results)
                end)
            end
            function Promise.is(object)
                if type(object) ~= 'table' then
                    return false
                end

                local objectMetatable = getmetatable(object)

                if objectMetatable == Promise then
                    return true
                elseif objectMetatable == nil then
                    return isCallable(object.andThen)
                elseif type(objectMetatable) == 'table' and type(rawget(objectMetatable, '__index')) == 'table' and isCallable(rawget(rawget(objectMetatable, '__index'), 'andThen')) then
                    return true
                end

                return false
            end
            function Promise.promisify(callback)
                return function(...)
                    return Promise._try(debug.traceback(nil, 2), callback, ...)
                end
            end

            do
                local first
                local connection

                function Promise.delay(seconds)
                    assert(type(seconds) == 'number', 'Bad argument #1 to Promise.delay, must be a number.')

                    if not (seconds >= 1.6666666666666665E-2) or seconds == math.huge then
                        seconds = 1.6666666666666665E-2
                    end

                    return Promise._new(debug.traceback(nil, 2), function(
                        resolve,
                        _,
                        onCancel
                    )
                        local startTime = Promise._getTime()
                        local endTime = startTime + seconds
                        local node = {
                            resolve = resolve,
                            startTime = startTime,
                            endTime = endTime,
                        }

                        if connection == nil then
                            first = node
                            connection = Promise._timeEvent:Connect(function()
                                local threadStart = Promise._getTime()

                                while first ~= nil and first.endTime < threadStart do
                                    local current = first

                                    first = current.next

                                    if first == nil then
                                        connection:Disconnect()

                                        connection = nil
                                    else
                                        first.previous = nil
                                    end

                                    current.resolve(Promise._getTime() - current.startTime)
                                end
                            end)
                        else
                            if first.endTime < endTime then
                                local current = first
                                local next = current.next

                                while next ~= nil and next.endTime < endTime do
                                    current = next
                                    next = current.next
                                end

                                current.next = node
                                node.previous = current

                                if next ~= nil then
                                    node.next = next
                                    next.previous = node
                                end
                            else
                                node.next = first
                                first.previous = node
                                first = node
                            end
                        end

                        onCancel(function()
                            local next = node.next

                            if first == node then
                                if next == nil then
                                    connection:Disconnect()

                                    connection = nil
                                else
                                    next.previous = nil
                                end

                                first = next
                            else
                                local previous = node.previous

                                previous.next = next

                                if next ~= nil then
                                    next.previous = previous
                                end
                            end
                        end)
                    end)
                end
            end

            function Promise.prototype:timeout(seconds, rejectionValue)
                local traceback = debug.traceback(nil, 2)

                return Promise.race({
                    Promise.delay(seconds):andThen(function()
                        return Promise.reject(rejectionValue == nil and Error.new({
                            kind = Error.Kind.TimedOut,
                            error = 'Timed out',
                            context = string.format('Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s', seconds, traceback),
                        }) or rejectionValue)
                    end),
                    self,
                })
            end
            function Promise.prototype:getStatus()
                return self._status
            end
            function Promise.prototype:_andThen(
                traceback,
                successHandler,
                failureHandler
            )
                self._unhandledRejection = false

                if self._status == Promise.Status.Cancelled then
                    local promise = Promise.new(function() end)

                    promise:cancel()

                    return promise
                end

                return Promise._new(traceback, function(
                    resolve,
                    reject,
                    onCancel
                )
                    local successCallback = resolve

                    if successHandler then
                        successCallback = createAdvancer(traceback, successHandler, resolve, reject)
                    end

                    local failureCallback = reject

                    if failureHandler then
                        failureCallback = createAdvancer(traceback, failureHandler, resolve, reject)
                    end
                    if self._status == Promise.Status.Started then
                        table.insert(self._queuedResolve, successCallback)
                        table.insert(self._queuedReject, failureCallback)
                        onCancel(function()
                            if self._status == Promise.Status.Started then
                                table.remove(self._queuedResolve, table.find(self._queuedResolve, successCallback))
                                table.remove(self._queuedReject, table.find(self._queuedReject, failureCallback))
                            end
                        end)
                    elseif self._status == Promise.Status.Resolved then
                        successCallback(unpack(self._values, 1, self._valuesLength))
                    elseif self._status == Promise.Status.Rejected then
                        failureCallback(unpack(self._values, 1, self._valuesLength))
                    end
                end, self)
            end
            function Promise.prototype:andThen(successHandler, failureHandler)
                assert(successHandler == nil or isCallable(successHandler), string.format(ERROR_NON_FUNCTION, 'Promise:andThen'))
                assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, 'Promise:andThen'))

                return self:_andThen(debug.traceback(nil, 2), successHandler, failureHandler)
            end
            function Promise.prototype:catch(failureHandler)
                assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, 'Promise:catch'))

                return self:_andThen(debug.traceback(nil, 2), nil, failureHandler)
            end
            function Promise.prototype:tap(tapHandler)
                assert(isCallable(tapHandler), string.format(ERROR_NON_FUNCTION, 'Promise:tap'))

                return self:_andThen(debug.traceback(nil, 2), function(...)
                    local callbackReturn = tapHandler(...)

                    if Promise.is(callbackReturn) then
                        local length, values = pack(...)

                        return callbackReturn:andThen(function()
                            return unpack(values, 1, length)
                        end)
                    end

                    return ...
                end)
            end
            function Promise.prototype:andThenCall(callback, ...)
                assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, 'Promise:andThenCall'))

                local length, values = pack(...)

                return self:_andThen(debug.traceback(nil, 2), function()
                    return callback(unpack(values, 1, length))
                end)
            end
            function Promise.prototype:andThenReturn(...)
                local length, values = pack(...)

                return self:_andThen(debug.traceback(nil, 2), function()
                    return unpack(values, 1, length)
                end)
            end
            function Promise.prototype:cancel()
                if self._status ~= Promise.Status.Started then
                    return
                end

                self._status = Promise.Status.Cancelled

                if self._cancellationHook then
                    self._cancellationHook()
                end

                coroutine.close(self._thread)

                if self._parent then
                    self._parent:_consumerCancelled(self)
                end

                for child in pairs(self._consumers)do
                    child:cancel()
                end

                self:_finalize()
            end
            function Promise.prototype:_consumerCancelled(consumer)
                if self._status ~= Promise.Status.Started then
                    return
                end

                self._consumers[consumer] = nil

                if next(self._consumers) == nil then
                    self:cancel()
                end
            end
            function Promise.prototype:_finally(traceback, finallyHandler)
                self._unhandledRejection = false

                local promise = Promise._new(traceback, function(
                    resolve,
                    reject,
                    onCancel
                )
                    local handlerPromise

                    onCancel(function()
                        self:_consumerCancelled(self)

                        if handlerPromise then
                            handlerPromise:cancel()
                        end
                    end)

                    local finallyCallback = resolve

                    if finallyHandler then
                        finallyCallback = function(...)
                            local callbackReturn = finallyHandler(...)

                            if Promise.is(callbackReturn) then
                                handlerPromise = callbackReturn

                                callbackReturn:finally(function(status)
                                    if status ~= Promise.Status.Rejected then
                                        resolve(self)
                                    end
                                end):catch(function(...)
                                    reject(...)
                                end)
                            else
                                resolve(self)
                            end
                        end
                    end
                    if self._status == Promise.Status.Started then
                        table.insert(self._queuedFinally, finallyCallback)
                    else
                        finallyCallback(self._status)
                    end
                end)

                return promise
            end
            function Promise.prototype:finally(finallyHandler)
                assert(finallyHandler == nil or isCallable(finallyHandler), string.format(ERROR_NON_FUNCTION, 'Promise:finally'))

                return self:_finally(debug.traceback(nil, 2), finallyHandler)
            end
            function Promise.prototype:finallyCall(callback, ...)
                assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, 'Promise:finallyCall'))

                local length, values = pack(...)

                return self:_finally(debug.traceback(nil, 2), function()
                    return callback(unpack(values, 1, length))
                end)
            end
            function Promise.prototype:finallyReturn(...)
                local length, values = pack(...)

                return self:_finally(debug.traceback(nil, 2), function()
                    return unpack(values, 1, length)
                end)
            end
            function Promise.prototype:awaitStatus()
                self._unhandledRejection = false

                if self._status == Promise.Status.Started then
                    local thread = coroutine.running()

                    self:finally(function()
                        task.spawn(thread)
                    end):catch(function() end)
                    coroutine.yield()
                end
                if self._status == Promise.Status.Resolved then
                    return self._status, unpack(self._values, 1, self._valuesLength)
                elseif self._status == Promise.Status.Rejected then
                    return self._status, unpack(self._values, 1, self._valuesLength)
                end

                return self._status
            end

            local awaitHelper = function(status, ...)
                return status == Promise.Status.Resolved, ...
            end

            function Promise.prototype:await()
                return awaitHelper(self:awaitStatus())
            end

            local expectHelper = function(status, ...)
                if status ~= Promise.Status.Resolved then
                    error((...) == nil and 'Expected Promise rejected with no value.' or (
...), 3)
                end

                return ...
            end

            function Promise.prototype:expect()
                return expectHelper(self:awaitStatus())
            end

            Promise.prototype.awaitValue = Promise.prototype.expect

            function Promise.prototype:_unwrap()
                if self._status == Promise.Status.Started then
                    error('Promise has not resolved or rejected.', 2)
                end

                local success = self._status == Promise.Status.Resolved

                return success, unpack(self._values, 1, self._valuesLength)
            end
            function Promise.prototype:_resolve(...)
                if self._status ~= Promise.Status.Started then
                    if Promise.is((...)) then
                        (...):_consumerCancelled(self)
                    end

                    return
                end
                if Promise.is((...)) then
                    if select('#', ...) > 1 then
                        local message = string.format(
[[When returning a Promise from andThen, extra arguments are discarded! See:

%s]], self._source)

                        warn(message)
                    end

                    local chainedPromise = ...
                    local promise = chainedPromise:andThen(function(...)
                        self:_resolve(...)
                    end, function(...)
                        local maybeRuntimeError = chainedPromise._values[1]

                        if chainedPromise._error then
                            maybeRuntimeError = Error.new({
                                error = chainedPromise._error,
                                kind = Error.Kind.ExecutionError,
                                context = 
[=[[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]]=],
                            })
                        end
                        if Error.isKind(maybeRuntimeError, Error.Kind.ExecutionError) then
                            return self:_reject(maybeRuntimeError:extend({
                                error = 'This Promise was chained to a Promise that errored.',
                                trace = '',
                                context = string.format(
[[The Promise at:

%s
...Rejected because it was chained to the following Promise, which encountered an error:
]], self._source),
                            }))
                        end

                        self:_reject(...)
                    end)

                    if promise._status == Promise.Status.Cancelled then
                        self:cancel()
                    elseif promise._status == Promise.Status.Started then
                        self._parent = promise
                        promise._consumers[self] = true
                    end

                    return
                end

                self._status = Promise.Status.Resolved
                self._valuesLength, self._values = pack(...)

                for _, callback in ipairs(self._queuedResolve)do
                    coroutine.wrap(callback)(...)
                end

                self:_finalize()
            end
            function Promise.prototype:_reject(...)
                if self._status ~= Promise.Status.Started then
                    return
                end

                self._status = Promise.Status.Rejected
                self._valuesLength, self._values = pack(...)

                if not isEmpty(self._queuedReject) then
                    for _, callback in ipairs(self._queuedReject)do
                        coroutine.wrap(callback)(...)
                    end
                else
                    local err = tostring((...))

                    coroutine.wrap(function()
                        Promise._timeEvent:Wait()

                        if not self._unhandledRejection then
                            return
                        end

                        local message = string.format('Unhandled Promise rejection:\n\n%s\n\n%s', err, self._source)

                        for _, callback in ipairs(Promise._unhandledRejectionCallbacks)do
                            task.spawn(callback, self, unpack(self._values, 1, self._valuesLength))
                        end

                        warn(message)
                    end)()
                end

                self:_finalize()
            end
            function Promise.prototype:_finalize()
                for _, callback in ipairs(self._queuedFinally)do
                    coroutine.wrap(callback)(self._status)
                end

                self._queuedFinally = nil
                self._queuedReject = nil
                self._queuedResolve = nil

                task.defer(coroutine.close, self._thread)
            end
            function Promise.prototype:now(rejectionValue)
                local traceback = debug.traceback(nil, 2)

                if self._status == Promise.Status.Resolved then
                    return self:_andThen(traceback, function(...)
                        return ...
                    end)
                else
                    return Promise.reject(rejectionValue == nil and Error.new({
                        kind = Error.Kind.NotResolvedInTime,
                        error = 'This Promise was not resolved in time for :now()',
                        context = ':now() was called at:\n\n' .. traceback,
                    }) or rejectionValue)
                end
            end
            function Promise.retry(callback, times, ...)
                assert(isCallable(callback), 'Parameter #1 to Promise.retry must be a function')
                assert(type(times) == 'number', 'Parameter #2 to Promise.retry must be a number')

                local args, length = {...}, select('#', ...)

                return Promise.resolve(callback(...)):catch(function(...)
                    if times > 0 then
                        return Promise.retry(callback, times - 1, unpack(args, 1, length))
                    else
                        return Promise.reject(...)
                    end
                end)
            end
            function Promise.retryWithDelay(callback, times, seconds, ...)
                assert(isCallable(callback), 'Parameter #1 to Promise.retry must be a function')
                assert(type(times) == 'number', 'Parameter #2 (times) to Promise.retry must be a number')
                assert(type(seconds) == 'number', 'Parameter #3 (seconds) to Promise.retry must be a number')

                local args, length = {...}, select('#', ...)

                return Promise.resolve(callback(...)):catch(function(...)
                    if times > 0 then
                        Promise.delay(seconds):await()

                        return Promise.retryWithDelay(callback, times - 1, seconds, unpack(args, 1, length))
                    else
                        return Promise.reject(...)
                    end
                end)
            end
            function Promise.fromEvent(event, predicate)
                predicate = predicate or function()
                    return true
                end

                return Promise._new(debug.traceback(nil, 2), function(
                    resolve,
                    _,
                    onCancel
                )
                    local connection
                    local shouldDisconnect = false
                    local disconnect = function()
                        connection:Disconnect()

                        connection = nil
                    end

                    connection = event:Connect(function(...)
                        local callbackValue = predicate(...)

                        if callbackValue == true then
                            resolve(...)

                            if connection then
                                disconnect()
                            else
                                shouldDisconnect = true
                            end
                        elseif type(callbackValue) ~= 'boolean' then
                            error('Promise.fromEvent predicate should always return a boolean')
                        end
                    end)

                    if shouldDisconnect and connection then
                        return disconnect()
                    end

                    onCancel(disconnect)
                end)
            end
            function Promise.onUnhandledRejection(callback)
                table.insert(Promise._unhandledRejectionCallbacks, callback)

                return function()
                    local index = table.find(Promise._unhandledRejectionCallbacks, callback)

                    if index then
                        table.remove(Promise._unhandledRejectionCallbacks, index)
                    end
                end
            end

            return Promise
        end)()
    end,
    [82] = function()
        local wax, script, require = ImportGlobals(82)

        return (function(...)
            local SnapdragonController = require(script.SnapdragonController)
            local SnapdragonRef = require(script.SnapdragonRef)
            local createDragController = function(...)
                return SnapdragonController.new(...)
            end
            local createRef = function(gui)
                return SnapdragonRef.new(gui)
            end
            local export

            export = {
                createDragController = createDragController,
                SnapdragonController = SnapdragonController,
                createRef = createRef,
            }
            export.default = export

            return export
        end)()
    end,
    [83] = function()
        ImportGlobals(83)

        return (function(...)
            local Maid = {}

            Maid.ClassName = 'Maid'

            function Maid.new()
                local self = {}

                self._tasks = {}

                return setmetatable(self, Maid)
            end
            function Maid:__index(index)
                if Maid[index] then
                    return Maid[index]
                else
                    return self._tasks[index]
                end
            end
            function Maid:__newindex(index, newTask)
                if Maid[index] ~= nil then
                    error(("'%s' is reserved"):format(tostring(index)), 2)
                end

                local tasks = self._tasks
                local oldTask = tasks[index]

                tasks[index] = newTask

                if oldTask then
                    if type(oldTask) == 'function' then
                        oldTask()
                    elseif typeof(oldTask) == 'RBXScriptConnection' then
                        oldTask:Disconnect()
                    elseif oldTask.Destroy then
                        oldTask:Destroy()
                    end
                end
            end
            function Maid:GiveTask(task)
                assert(task, 'Task cannot be false or nil')

                local taskId = #self._tasks + 1

                self[taskId] = task

                if type(task) == 'table' and not task.Destroy then
                    warn('[Maid.GiveTask] - Gave table task without .Destroy\n\n' .. debug.traceback())
                end

                return taskId
            end
            function Maid:GivePromise(promise)
                if not promise:IsPending() then
                    return promise
                end

                local newPromise = promise.resolved(promise)
                local id = self:GiveTask(newPromise)

                newPromise:Finally(function()
                    self[id] = nil
                end)

                return newPromise
            end
            function Maid:DoCleaning()
                local tasks = self._tasks

                for index, task in pairs(tasks)do
                    if typeof(task) == 'RBXScriptConnection' then
                        tasks[index] = nil

                        task:Disconnect()
                    end
                end

                local index, task = next(tasks)

                while task ~= nil do
                    tasks[index] = nil

                    if type(task) == 'function' then
                        task()
                    elseif typeof(task) == 'RBXScriptConnection' then
                        task:Disconnect()
                    elseif task.Destroy then
                        task:Destroy()
                    end

                    index, task = next(tasks)
                end
            end

            Maid.Destroy = Maid.DoCleaning

            return Maid
        end)()
    end,
    [84] = function()
        ImportGlobals(84)

        return (function(...)
            local Signal = {}

            Signal.__index = Signal

            function Signal.new()
                return setmetatable({
                    Bindable = Instance.new('BindableEvent'),
                }, Signal)
            end
            function Signal:Connect(Callback)
                return self.Bindable.Event:Connect(function(GetArgumentStack)
                    Callback(GetArgumentStack())
                end)
            end
            function Signal:Fire(...)
                local Arguments = {...}
                local n = select('#', ...)

                self.Bindable:Fire(function()
                    return unpack(Arguments, 1, n)
                end)
            end
            function Signal:Wait()
                return self.Bindable.Event:Wait()()
            end
            function Signal:Destroy()
                self.Bindable:Destroy()
            end

            return Signal
        end)()
    end,
    [85] = function()
        local wax, script, require = ImportGlobals(85)

        return (function(...)
            local UserInputService = game:GetService('UserInputService')
            local Maid = require(script.Parent.Maid)
            local Signal = require(script.Parent.Signal)
            local SnapdragonRef = require(script.Parent.SnapdragonRef)
            local objectAssign = require(script.Parent.objectAssign)
            local t = require(script.Parent.t)
            local MarginTypeCheck = t.interface({
                Vertical = t.optional(t.Vector2),
                Horizontal = t.optional(t.Vector2),
            })
            local AxisEnumCheck = t.literal('XY', 'X', 'Y')
            local DragRelativeToEnumCheck = t.literal('LayerCollector', 'Parent')
            local DragPositionModeEnumCheck = t.literal('Offset', 'Scale')
            local OptionsInterfaceCheck = t.interface({
                DragGui = t.union(t.instanceIsA('GuiObject'), SnapdragonRef.is),
                DragThreshold = t.number,
                DragGridSize = t.number,
                SnapMargin = MarginTypeCheck,
                SnapMarginThreshold = MarginTypeCheck,
                SnapAxis = AxisEnumCheck,
                DragAxis = AxisEnumCheck,
                DragRelativeTo = DragRelativeToEnumCheck,
                SnapEnabled = t.boolean,
                Debugging = t.boolean,
                DragPositionMode = DragPositionModeEnumCheck,
            })
            local SnapdragonController = {}

            SnapdragonController.__index = SnapdragonController

            local controllers = setmetatable({}, {
                __mode = 'k',
            })

            function SnapdragonController.new(gui, options)
                options = objectAssign({
                    DragGui = gui,
                    DragThreshold = 0,
                    DragGridSize = 0,
                    SnapMargin = {},
                    SnapMarginThreshold = {},
                    SnapEnabled = true,
                    DragEndedResetsPosition = false,
                    SnapAxis = 'XY',
                    DragAxis = 'XY',
                    Debugging = false,
                    DragRelativeTo = 'LayerCollector',
                    DragPositionMode = 'Scale',
                }, options)

                assert(OptionsInterfaceCheck(options))

                local self = setmetatable({}, SnapdragonController)
                local dragGui = options.DragGui

                self.dragGui = dragGui
                self.gui = gui
                self.debug = options.Debugging
                self.originPosition = dragGui.Position
                self.canDrag = options.CanDrag
                self.dragEndedResetsPosition = options.DragEndedResetsPosition
                self.snapEnabled = options.SnapEnabled
                self.snapAxis = options.SnapAxis
                self.dragAxis = options.DragAxis
                self.dragThreshold = options.DragThreshold
                self.dragRelativeTo = options.DragRelativeTo
                self.dragGridSize = options.DragGridSize
                self.dragPositionMode = options.DragPositionMode
                self._useAbsoluteCoordinates = false

                local DragEnded = Signal.new()
                local DragChanged = Signal.new()
                local DragBegan = Signal.new()

                self.DragEnded = DragEnded
                self.DragBegan = DragBegan
                self.DragChanged = DragChanged
                self.maid = Maid.new()

                self:SetSnapEnabled(options.SnapEnabled)
                self:SetSnapMargin(options.SnapMargin)
                self:SetSnapThreshold(options.SnapMarginThreshold)

                return self
            end
            function SnapdragonController:SetSnapEnabled(snapEnabled)
                assert(t.boolean(snapEnabled))

                self.snapEnabled = snapEnabled
            end
            function SnapdragonController:SetSnapMargin(snapMargin)
                assert(MarginTypeCheck(snapMargin))

                local snapVerticalMargin = snapMargin.Vertical or Vector2.new()
                local snapHorizontalMargin = snapMargin.Horizontal or Vector2.new()

                self.snapVerticalMargin = snapVerticalMargin
                self.snapHorizontalMargin = snapHorizontalMargin
            end
            function SnapdragonController:SetSnapThreshold(snapThreshold)
                assert(MarginTypeCheck(snapThreshold))

                local snapThresholdVertical = snapThreshold.Vertical or Vector2.new()
                local snapThresholdHorizontal = snapThreshold.Horizontal or Vector2.new()

                self.snapThresholdVertical = snapThresholdVertical
                self.snapThresholdHorizontal = snapThresholdHorizontal
            end
            function SnapdragonController:GetDragGui()
                local gui = self.dragGui

                if SnapdragonRef.is(gui) then
                    return gui:Get(), gui
                else
                    return gui, gui
                end
            end
            function SnapdragonController:GetGui()
                local gui = self.gui

                if SnapdragonRef.is(gui) then
                    return gui:Get()
                else
                    return gui
                end
            end
            function SnapdragonController:ResetPosition()
                self.dragGui.Position = self.originPosition
            end
            function SnapdragonController:__bindControllerBehaviour()
                local maid = self.maid
                local debug = self.debug
                local gui = self:GetGui()
                local dragGui = self:GetDragGui()
                local snap = self.snapEnabled
                local DragEnded = self.DragEnded
                local DragBegan = self.DragBegan
                local DragChanged = self.DragChanged
                local snapAxis = self.snapAxis
                local dragAxis = self.dragAxis
                local dragRelativeTo = self.dragRelativeTo
                local dragGridSize = self.dragGridSize
                local dragPositionMode = self.dragPositionMode
                local useAbsoluteCoordinates = self._useAbsoluteCoordinates
                local reachedExtents
                local dragging
                local dragInput
                local dragStart
                local startPos
                local guiStartPos
                local update = function(input)
                    local snapHorizontalMargin = self.snapHorizontalMargin
                    local snapVerticalMargin = self.snapVerticalMargin
                    local snapThresholdVertical = self.snapThresholdVertical
                    local snapThresholdHorizontal = self.snapThresholdHorizontal
                    local screenSize = workspace.CurrentCamera.ViewportSize
                    local delta = input.Position - dragStart

                    if dragAxis == 'X' then
                        delta = Vector3.new(delta.X, 0, 0)
                    elseif dragAxis == 'Y' then
                        delta = Vector3.new(0, delta.Y, 0)
                    end

                    gui = dragGui or gui
                    reachedExtents = {
                        X = 'Float',
                        Y = 'Float',
                    }

                    local host = gui:FindFirstAncestorOfClass('ScreenGui') or gui:FindFirstAncestorOfClass('PluginGui')
                    local topLeft = Vector2.new()

                    if host and dragRelativeTo == 'LayerCollector' then
                        screenSize = host.AbsoluteSize
                    elseif dragRelativeTo == 'Parent' then
                        assert(gui.Parent:IsA('GuiObject'), 
[[DragRelativeTo is set to Parent, but the parent is not a GuiObject!]])

                        screenSize = gui.Parent.AbsoluteSize
                    end
                    if snap then
                        local scaleOffsetX = screenSize.X * startPos.X.Scale
                        local scaleOffsetY = screenSize.Y * startPos.Y.Scale
                        local resultingOffsetX = startPos.X.Offset + delta.X
                        local resultingOffsetY = startPos.Y.Offset + delta.Y
                        local absSize = gui.AbsoluteSize + Vector2.new(snapHorizontalMargin.Y, snapVerticalMargin.Y + topLeft.Y)
                        local anchorOffset = Vector2.new(gui.AbsoluteSize.X * gui.AnchorPoint.X, gui.AbsoluteSize.Y * gui.AnchorPoint.Y)

                        if snapAxis == 'XY' or snapAxis == 'X' then
                            local computedMinX = snapHorizontalMargin.X + anchorOffset.X
                            local computedMaxX = screenSize.X - absSize.X + anchorOffset.X

                            if (resultingOffsetX + scaleOffsetX) > computedMaxX - snapThresholdHorizontal.Y then
                                resultingOffsetX = computedMaxX - scaleOffsetX
                                reachedExtents.X = 'Max'
                            elseif (resultingOffsetX + scaleOffsetX) < computedMinX + snapThresholdHorizontal.X then
                                resultingOffsetX = -scaleOffsetX + computedMinX
                                reachedExtents.X = 'Min'
                            end
                        end
                        if snapAxis == 'XY' or snapAxis == 'Y' then
                            local computedMinY = snapVerticalMargin.X + anchorOffset.Y
                            local computedMaxY = screenSize.Y - absSize.Y + anchorOffset.Y

                            if (resultingOffsetY + scaleOffsetY) > computedMaxY - snapThresholdVertical.Y then
                                resultingOffsetY = computedMaxY - scaleOffsetY
                                reachedExtents.Y = 'Max'
                            elseif (resultingOffsetY + scaleOffsetY) < computedMinY + snapThresholdVertical.X then
                                resultingOffsetY = -scaleOffsetY + computedMinY
                                reachedExtents.Y = 'Min'
                            end
                        end
                        if dragGridSize > 0 then
                            resultingOffsetX = math.floor(resultingOffsetX / dragGridSize) * dragGridSize
                            resultingOffsetY = math.floor(resultingOffsetY / dragGridSize) * dragGridSize
                        end
                        if dragPositionMode == 'Offset' then
                            local newPosition = UDim2.new(startPos.X.Scale, resultingOffsetX, startPos.Y.Scale, resultingOffsetY)

                            gui.Position = newPosition

                            DragChanged:Fire({GuiPosition = newPosition})
                        else
                            local newPosition = UDim2.new(startPos.X.Scale + (resultingOffsetX / screenSize.X), 0, startPos.Y.Scale + (resultingOffsetY / screenSize.Y), 0)

                            gui.Position = newPosition

                            DragChanged:Fire({
                                SnapAxis = snapAxis,
                                GuiPosition = newPosition,
                                DragPositionMode = dragPositionMode,
                            })
                        end
                    else
                        if dragGridSize > 0 then
                            delta = Vector2.new(math.floor(delta.X / dragGridSize) * dragGridSize, math.floor(delta.Y / dragGridSize) * dragGridSize)
                        end

                        local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

                        gui.Position = newPosition

                        DragChanged:Fire({GuiPosition = newPosition})
                    end
                end

                maid.guiInputBegan = gui.InputBegan:Connect(function(input)
                    local canDrag = true

                    if type(self.canDrag) == 'function' then
                        canDrag = self.canDrag()
                    end
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and canDrag then
                        dragging = true
                        dragStart = input.Position

                        local draggingGui = (dragGui or gui)

                        startPos = useAbsoluteCoordinates and UDim2.new(0, draggingGui.AbsolutePosition.X, 0, draggingGui.AbsolutePosition.Y) or draggingGui.Position
                        guiStartPos = draggingGui.Position

                        DragBegan:Fire({
                            AbsolutePosition = (dragGui or gui).AbsolutePosition,
                            InputPosition = dragStart,
                            GuiPosition = startPos,
                        })

                        if debug then
                            print('[snapdragon]', 'Drag began', input.Position)
                        end
                    end
                end)
                maid.guiInputEnded = gui.InputEnded:Connect(function(input)
                    if dragging and input.UserInputState == Enum.UserInputState.End and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        dragging = false

                        local draggingGui = (dragGui or gui)
                        local endPos = draggingGui.Position

                        DragEnded:Fire({
                            InputPosition = input.Position,
                            GuiPosition = endPos,
                            ReachedExtents = reachedExtents,
                            DraggedGui = dragGui or gui,
                        })

                        if debug then
                            print('[snapdragon]', 'Drag ended', input.Position)
                        end

                        local dragEndedResetsPosition = self.dragEndedResetsPosition

                        if dragEndedResetsPosition then
                            draggingGui.Position = guiStartPos
                        end
                    end
                end)
                maid.guiInputChanged = gui.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        dragInput = input
                    end
                end)
                maid.uisInputChanged = UserInputService.InputChanged:Connect(function(
                    input
                )
                    if input == dragInput and dragging then
                        update(input)
                    end
                end)
            end
            function SnapdragonController:Connect()
                if self.locked then
                    error('[SnapdragonController] Cannot connect locked controller!', 2)
                end

                local _, ref = self:GetDragGui()

                if not controllers[ref] or controllers[ref] == self then
                    controllers[ref] = self

                    self:__bindControllerBehaviour()
                else
                    error(
[[[SnapdragonController] This object is already bound to a controller]])
                end

                return self
            end
            function SnapdragonController:Disconnect()
                if self.locked then
                    error('[SnapdragonController] Cannot disconnect locked controller!', 2)
                end

                local _, ref = self:GetDragGui()
                local controller = controllers[ref]

                if controller then
                    self.maid:DoCleaning()

                    controllers[ref] = nil
                end
            end
            function SnapdragonController:Destroy()
                self:Disconnect()
                self.DragEnded:Destroy()
                self.DragBegan:Destroy()

                self.DragEnded = nil
                self.DragBegan = nil
                self.locked = true
            end

            return SnapdragonController
        end)()
    end,
    [86] = function()
        ImportGlobals(86)

        return (function(...)
            local refs = setmetatable({}, {
                __mode = 'k',
            })
            local SnapdragonRef = {}

            SnapdragonRef.__index = SnapdragonRef

            function SnapdragonRef.new(current)
                local ref = setmetatable({current = current}, SnapdragonRef)

                refs[ref] = ref

                return ref
            end
            function SnapdragonRef:Update(current)
                self.current = current
            end
            function SnapdragonRef:Get()
                return self.current
            end
            function SnapdragonRef.is(ref)
                return refs[ref] ~= nil
            end

            return SnapdragonRef
        end)()
    end,
    [87] = function()
        ImportGlobals(87)

        return (function(...)
            local Symbol = {}

            function Symbol.named(name)
                assert(type(name) == 'string', 'Symbols must be created using a string name!')

                local self = newproxy(true)
                local wrappedName = ('Symbol(%s)'):format(name)

                getmetatable(self).__tostring = function()
                    return wrappedName
                end

                return self
            end

            return Symbol
        end)()
    end,
    [88] = function()
        ImportGlobals(88)

        return (function(...)
            local objectAssign = function(target, ...)
                local targets = {...}

                for _, t in pairs(targets)do
                    for k, v in pairs(t)do
                        target[k] = v
                    end
                end

                return target
            end

            return objectAssign
        end)()
    end,
    [89] = function()
        ImportGlobals(89)

        return (function(...)
            local typeof = typeof or type
            local primitive = function(typeName)
                return function(value)
                    local valueType = typeof(value)

                    if valueType == typeName then
                        return true
                    else
                        return false, string.format('%s expected, got %s', typeName, valueType)
                    end
                end
            end
            local t = {}

            function t.any(value)
                if value ~= nil then
                    return true
                else
                    return false, 'any expected, got nil'
                end
            end

            t.boolean = primitive('boolean')
            t.thread = primitive('thread')
            t.callback = primitive('function')
            t.none = primitive('nil')
            t.string = primitive('string')
            t.table = primitive('table')
            t.userdata = primitive('userdata')

            function t.number(value)
                local valueType = typeof(value)

                if valueType == 'number' then
                    if value == value then
                        return true
                    else
                        return false, 'unexpected NaN value'
                    end
                else
                    return false, string.format('number expected, got %s', valueType)
                end
            end
            function t.nan(value)
                if value ~= value then
                    return true
                else
                    return false, 'unexpected non-NaN value'
                end
            end

            t.Axes = primitive('Axes')
            t.BrickColor = primitive('BrickColor')
            t.CFrame = primitive('CFrame')
            t.Color3 = primitive('Color3')
            t.ColorSequence = primitive('ColorSequence')
            t.ColorSequenceKeypoint = primitive('ColorSequenceKeypoint')
            t.DockWidgetPluginGuiInfo = primitive('DockWidgetPluginGuiInfo')
            t.Faces = primitive('Faces')
            t.Instance = primitive('Instance')
            t.NumberRange = primitive('NumberRange')
            t.NumberSequence = primitive('NumberSequence')
            t.NumberSequenceKeypoint = primitive('NumberSequenceKeypoint')
            t.PathWaypoint = primitive('PathWaypoint')
            t.PhysicalProperties = primitive('PhysicalProperties')
            t.Random = primitive('Random')
            t.Ray = primitive('Ray')
            t.Rect = primitive('Rect')
            t.Region3 = primitive('Region3')
            t.Region3int16 = primitive('Region3int16')
            t.TweenInfo = primitive('TweenInfo')
            t.UDim = primitive('UDim')
            t.UDim2 = primitive('UDim2')
            t.Vector2 = primitive('Vector2')
            t.Vector3 = primitive('Vector3')
            t.Vector3int16 = primitive('Vector3int16')
            t.Enum = primitive('Enum')
            t.EnumItem = primitive('EnumItem')
            t.RBXScriptSignal = primitive('RBXScriptSignal')
            t.RBXScriptConnection = primitive('RBXScriptConnection')

            function t.literal(...)
                local size = select('#', ...)

                if size == 1 then
                    local literal = ...

                    return function(value)
                        if value ~= literal then
                            return false, string.format('expected %s, got %s', tostring(literal), tostring(value))
                        end

                        return true
                    end
                else
                    local literals = {}

                    for i = 1, size do
                        local value = select(i, ...)

                        literals[i] = t.literal(value)
                    end

                    return t.union(table.unpack(literals, 1, size))
                end
            end

            t.exactly = t.literal

            function t.keyOf(keyTable)
                local keys = {}
                local length = 0

                for key in pairs(keyTable)do
                    length = length + 1
                    keys[length] = key
                end

                return t.literal(table.unpack(keys, 1, length))
            end
            function t.valueOf(valueTable)
                local values = {}
                local length = 0

                for _, value in pairs(valueTable)do
                    length = length + 1
                    values[length] = value
                end

                return t.literal(table.unpack(values, 1, length))
            end
            function t.integer(value)
                local success, errMsg = t.number(value)

                if not success then
                    return false, errMsg or ''
                end
                if value % 1 == 0 then
                    return true
                else
                    return false, string.format('integer expected, got %s', value)
                end
            end
            function t.numberMin(min)
                return function(value)
                    local success, errMsg = t.number(value)

                    if not success then
                        return false, errMsg or ''
                    end
                    if value >= min then
                        return true
                    else
                        return false, string.format('number >= %s expected, got %s', min, value)
                    end
                end
            end
            function t.numberMax(max)
                return function(value)
                    local success, errMsg = t.number(value)

                    if not success then
                        return false, errMsg
                    end
                    if value <= max then
                        return true
                    else
                        return false, string.format('number <= %s expected, got %s', max, value)
                    end
                end
            end
            function t.numberMinExclusive(min)
                return function(value)
                    local success, errMsg = t.number(value)

                    if not success then
                        return false, errMsg or ''
                    end
                    if min < value then
                        return true
                    else
                        return false, string.format('number > %s expected, got %s', min, value)
                    end
                end
            end
            function t.numberMaxExclusive(max)
                return function(value)
                    local success, errMsg = t.number(value)

                    if not success then
                        return false, errMsg or ''
                    end
                    if value < max then
                        return true
                    else
                        return false, string.format('number < %s expected, got %s', max, value)
                    end
                end
            end

            t.numberPositive = t.numberMinExclusive(0)
            t.numberNegative = t.numberMaxExclusive(0)

            function t.numberConstrained(min, max)
                assert(t.number(min) and t.number(max))

                local minCheck = t.numberMin(min)
                local maxCheck = t.numberMax(max)

                return function(value)
                    local minSuccess, minErrMsg = minCheck(value)

                    if not minSuccess then
                        return false, minErrMsg or ''
                    end

                    local maxSuccess, maxErrMsg = maxCheck(value)

                    if not maxSuccess then
                        return false, maxErrMsg or ''
                    end

                    return true
                end
            end
            function t.numberConstrainedExclusive(min, max)
                assert(t.number(min) and t.number(max))

                local minCheck = t.numberMinExclusive(min)
                local maxCheck = t.numberMaxExclusive(max)

                return function(value)
                    local minSuccess, minErrMsg = minCheck(value)

                    if not minSuccess then
                        return false, minErrMsg or ''
                    end

                    local maxSuccess, maxErrMsg = maxCheck(value)

                    if not maxSuccess then
                        return false, maxErrMsg or ''
                    end

                    return true
                end
            end
            function t.match(pattern)
                assert(t.string(pattern))

                return function(value)
                    local stringSuccess, stringErrMsg = t.string(value)

                    if not stringSuccess then
                        return false, stringErrMsg
                    end
                    if string.match(value, pattern) == nil then
                        return false, string.format('%q failed to match pattern %q', value, pattern)
                    end

                    return true
                end
            end
            function t.optional(check)
                assert(t.callback(check))

                return function(value)
                    if value == nil then
                        return true
                    end

                    local success, errMsg = check(value)

                    if success then
                        return true
                    else
                        return false, string.format('(optional) %s', errMsg or '')
                    end
                end
            end
            function t.tuple(...)
                local checks = {...}

                return function(...)
                    local args = {...}

                    for i, check in ipairs(checks)do
                        local success, errMsg = check(args[i])

                        if success == false then
                            return false, string.format('Bad tuple index #%s:\n\t%s', i, errMsg or '')
                        end
                    end

                    return true
                end
            end
            function t.keys(check)
                assert(t.callback(check))

                return function(value)
                    local tableSuccess, tableErrMsg = t.table(value)

                    if tableSuccess == false then
                        return false, tableErrMsg or ''
                    end

                    for key in pairs(value)do
                        local success, errMsg = check(key)

                        if success == false then
                            return false, string.format('bad key %s:\n\t%s', tostring(key), errMsg or '')
                        end
                    end

                    return true
                end
            end
            function t.values(check)
                assert(t.callback(check))

                return function(value)
                    local tableSuccess, tableErrMsg = t.table(value)

                    if tableSuccess == false then
                        return false, tableErrMsg or ''
                    end

                    for key, val in pairs(value)do
                        local success, errMsg = check(val)

                        if success == false then
                            return false, string.format('bad value for key %s:\n\t%s', tostring(key), errMsg or '')
                        end
                    end

                    return true
                end
            end
            function t.map(keyCheck, valueCheck)
                assert(t.callback(keyCheck), t.callback(valueCheck))

                local keyChecker = t.keys(keyCheck)
                local valueChecker = t.values(valueCheck)

                return function(value)
                    local keySuccess, keyErr = keyChecker(value)

                    if not keySuccess then
                        return false, keyErr or ''
                    end

                    local valueSuccess, valueErr = valueChecker(value)

                    if not valueSuccess then
                        return false, valueErr or ''
                    end

                    return true
                end
            end
            function t.set(valueCheck)
                return t.map(valueCheck, t.literal(true))
            end

            do
                local arrayKeysCheck = t.keys(t.integer)

                function t.array(check)
                    assert(t.callback(check))

                    local valuesCheck = t.values(check)

                    return function(value)
                        local keySuccess, keyErrMsg = arrayKeysCheck(value)

                        if keySuccess == false then
                            return false, string.format('[array] %s', keyErrMsg or '')
                        end

                        local arraySize = 0

                        for _ in ipairs(value)do
                            arraySize = arraySize + 1
                        end
                        for key in pairs(value)do
                            if key < 1 or key > arraySize then
                                return false, string.format('[array] key %s must be sequential', tostring(key))
                            end
                        end

                        local valueSuccess, valueErrMsg = valuesCheck(value)

                        if not valueSuccess then
                            return false, string.format('[array] %s', valueErrMsg or '')
                        end

                        return true
                    end
                end
                function t.strictArray(...)
                    local valueTypes = {...}

                    assert(t.array(t.callback)(valueTypes))

                    return function(value)
                        local keySuccess, keyErrMsg = arrayKeysCheck(value)

                        if keySuccess == false then
                            return false, string.format('[strictArray] %s', keyErrMsg or '')
                        end
                        if #valueTypes < #value then
                            return false, string.format('[strictArray] Array size exceeds limit of %d', #valueTypes)
                        end

                        for idx, typeFn in pairs(valueTypes)do
                            local typeSuccess, typeErrMsg = typeFn(value[idx])

                            if not typeSuccess then
                                return false, string.format('[strictArray] Array index #%d - %s', idx, typeErrMsg)
                            end
                        end

                        return true
                    end
                end
            end
            do
                local callbackArray = t.array(t.callback)

                function t.union(...)
                    local checks = {...}

                    assert(callbackArray(checks))

                    return function(value)
                        for _, check in ipairs(checks)do
                            if check(value) then
                                return true
                            end
                        end

                        return false, 'bad type for union'
                    end
                end

                t.some = t.union

                function t.intersection(...)
                    local checks = {...}

                    assert(callbackArray(checks))

                    return function(value)
                        for _, check in ipairs(checks)do
                            local success, errMsg = check(value)

                            if not success then
                                return false, errMsg or ''
                            end
                        end

                        return true
                    end
                end

                t.every = t.intersection
            end
            do
                local checkInterface = t.map(t.any, t.callback)

                function t.interface(checkTable)
                    assert(checkInterface(checkTable))

                    return function(value)
                        local tableSuccess, tableErrMsg = t.table(value)

                        if tableSuccess == false then
                            return false, tableErrMsg or ''
                        end

                        for key, check in pairs(checkTable)do
                            local success, errMsg = check(value[key])

                            if success == false then
                                return false, string.format('[interface] bad value for %s:\n\t%s', tostring(key), errMsg or '')
                            end
                        end

                        return true
                    end
                end
                function t.strictInterface(checkTable)
                    assert(checkInterface(checkTable))

                    return function(value)
                        local tableSuccess, tableErrMsg = t.table(value)

                        if tableSuccess == false then
                            return false, tableErrMsg or ''
                        end

                        for key, check in pairs(checkTable)do
                            local success, errMsg = check(value[key])

                            if success == false then
                                return false, string.format('[interface] bad value for %s:\n\t%s', tostring(key), errMsg or '')
                            end
                        end
                        for key in pairs(value)do
                            if not checkTable[key] then
                                return false, string.format('[interface] unexpected field %q', tostring(key))
                            end
                        end

                        return true
                    end
                end
            end

            function t.instanceOf(className, childTable)
                assert(t.string(className))

                local childrenCheck

                if childTable ~= nil then
                    childrenCheck = t.children(childTable)
                end

                return function(value)
                    local instanceSuccess, instanceErrMsg = t.Instance(value)

                    if not instanceSuccess then
                        return false, instanceErrMsg or ''
                    end
                    if value.ClassName ~= className then
                        return false, string.format('%s expected, got %s', className, value.ClassName)
                    end
                    if childrenCheck then
                        local childrenSuccess, childrenErrMsg = childrenCheck(value)

                        if not childrenSuccess then
                            return false, childrenErrMsg
                        end
                    end

                    return true
                end
            end

            t.instance = t.instanceOf

            function t.instanceIsA(className, childTable)
                assert(t.string(className))

                local childrenCheck

                if childTable ~= nil then
                    childrenCheck = t.children(childTable)
                end

                return function(value)
                    local instanceSuccess, instanceErrMsg = t.Instance(value)

                    if not instanceSuccess then
                        return false, instanceErrMsg or ''
                    end
                    if not value:IsA(className) then
                        return false, string.format('%s expected, got %s', className, value.ClassName)
                    end
                    if childrenCheck then
                        local childrenSuccess, childrenErrMsg = childrenCheck(value)

                        if not childrenSuccess then
                            return false, childrenErrMsg
                        end
                    end

                    return true
                end
            end
            function t.enum(enum)
                assert(t.Enum(enum))

                return function(value)
                    local enumItemSuccess, enumItemErrMsg = t.EnumItem(value)

                    if not enumItemSuccess then
                        return false, enumItemErrMsg
                    end
                    if value.EnumType == enum then
                        return true
                    else
                        return false, string.format('enum of %s expected, got enum of %s', tostring(enum), tostring(value.EnumType))
                    end
                end
            end

            do
                local checkWrap = t.tuple(t.callback, t.callback)

                function t.wrap(callback, checkArgs)
                    assert(checkWrap(callback, checkArgs))

                    return function(...)
                        assert(checkArgs(...))

                        return callback(...)
                    end
                end
            end

            function t.strict(check)
                return function(...)
                    assert(check(...))
                end
            end

            do
                local checkChildren = t.map(t.string, t.callback)

                function t.children(checkTable)
                    assert(checkChildren(checkTable))

                    return function(value)
                        local instanceSuccess, instanceErrMsg = t.Instance(value)

                        if not instanceSuccess then
                            return false, instanceErrMsg or ''
                        end

                        local childrenByName = {}

                        for _, child in ipairs(value:GetChildren())do
                            local name = child.Name

                            if checkTable[name] then
                                if childrenByName[name] then
                                    return false, string.format('Cannot process multiple children with the same name %q', name)
                                end

                                childrenByName[name] = child
                            end
                        end
                        for name, check in pairs(checkTable)do
                            local success, errMsg = check(childrenByName[name])

                            if not success then
                                return false, string.format('[%s.%s] %s', value:GetFullName(), name, errMsg or '')
                            end
                        end

                        return true
                    end
                end
            end

            return t
        end)()
    end,
    [90] = function()
        local wax, script, require = ImportGlobals(90)

        return (function(...)
            local Fusion = require(script.Parent.fusion)
            local Value = Fusion.Value
            local GlobalStates = {
                Theme = Value('charcoal'),
                Objects = Value({}),
                Categorys = Value({}),
                Tabs = Value({}),
                UILayouts = Value({}),
                Containers = Value({}),
                CurrentTab = Value(),
                Elements = Value(),
                Options = Value({}),
                Library = Value(),
                MinimizeKeybind = Value(),
                MinimizeKey = Value(Enum.KeyCode.K),
                Notifications = Value({}),
                FPSCheck = Value(true),
                PingCheck = Value(true),
                toDestroy = Value(false),
                HasSelected = Value(false),
            }

            function GlobalStates.add(state, value, name)
                if not GlobalStates[state] then
                    error('No global state named: ' .. state)
                end

                local globalState = GlobalStates[state]
                local newTable = table.clone(globalState:get())

                newTable[name] = value

                globalState:set(newTable)
            end

            return GlobalStates
        end)()
    end,
    [91] = function()
        ImportGlobals(91)

        return (function(...)
            local BLOCK = {
                0,
                1,
                2,
                3,
                4,
                5,
                6,
                7,
            }
            local WEDGE = {
                0,
                1,
                3,
                4,
                5,
                7,
            }
            local CORNER_WEDGE = {
                0,
                1,
                4,
                5,
                6,
            }
            local ViewportModelClass = {}

            ViewportModelClass.__index = ViewportModelClass
            ViewportModelClass.ClassName = 'ViewportModel'

            local getIndices = function(part)
                if part:IsA('WedgePart') then
                    return WEDGE
                elseif part:IsA('CornerWedgePart') then
                    return CORNER_WEDGE
                end

                return BLOCK
            end
            local getCorners = function(cf, size2, indices)
                local corners = {}

                for j, i in pairs(indices)do
                    corners[j] = cf * (size2 * Vector3.new(2 * (math.floor(i / 4) % 2) - 1, 2 * (math.floor(i / 2) % 2) - 1, 2 * (i % 2) - 1))
                end

                return corners
            end
            local getModelPointCloud = function(model)
                local points = {}

                for _, part in pairs(model:GetDescendants())do
                    if part:IsA('BasePart') then
                        local indices = getIndices(part)
                        local corners = getCorners(part.CFrame, part.Size / 2, indices)

                        for _, wp in pairs(corners)do
                            table.insert(points, wp)
                        end
                    end
                end

                return points
            end
            local viewProjectionEdgeHits = function(
                cloud,
                axis,
                depth,
                tanFov2
            )
                local max, min = -math.huge, math.huge

                for _, lp in pairs(cloud)do
                    local distance = depth - lp.Z
                    local halfSpan = tanFov2 * distance
                    local a = lp[axis] + halfSpan
                    local b = lp[axis] - halfSpan

                    max = math.max(max, a, b)
                    min = math.min(min, a, b)
                end

                return max, min
            end

            function ViewportModelClass.new(vpf, camera)
                local self = setmetatable({}, ViewportModelClass)

                self.Model = nil
                self.ViewportFrame = vpf
                self.Camera = camera
                self._points = {}
                self._modelCFrame = CFrame.new()
                self._modelSize = Vector3.new()
                self._modelRadius = 0
                self._viewport = {}

                self:Calibrate()

                return self
            end
            function ViewportModelClass:SetModel(model)
                self.Model = model

                local cf, size = model:GetBoundingBox()

                self._points = getModelPointCloud(model)
                self._modelCFrame = cf
                self._modelSize = size
                self._modelRadius = size.Magnitude / 2
            end
            function ViewportModelClass:Calibrate()
                local viewport = {}
                local size = self.ViewportFrame.AbsoluteSize

                viewport.aspect = size.X / size.Y
                viewport.yFov2 = math.rad(self.Camera.FieldOfView / 2)
                viewport.tanyFov2 = math.tan(viewport.yFov2)
                viewport.xFov2 = math.atan(viewport.tanyFov2 * viewport.aspect)
                viewport.tanxFov2 = math.tan(viewport.xFov2)
                viewport.cFov2 = math.atan(viewport.tanyFov2 * math.min(1, viewport.aspect))
                viewport.sincFov2 = math.sin(viewport.cFov2)
                self._viewport = viewport
            end
            function ViewportModelClass:GetFitDistance(focusPosition)
                local displacement = focusPosition and (focusPosition - self._modelCFrame.Position).Magnitude or 0
                local radius = self._modelRadius + displacement

                return radius / self._viewport.sincFov2
            end
            function ViewportModelClass:GetMinimumFitCFrame(orientation)
                if not self.Model then
                    return CFrame.new()
                end

                local rotation = orientation - orientation.Position
                local rInverse = rotation:Inverse()
                local wcloud = self._points
                local cloud = {
                    rInverse * wcloud[1],
                }
                local furthest = cloud[1].Z

                for i = 2, #wcloud do
                    local lp = rInverse * wcloud[i]

                    furthest = math.min(furthest, lp.Z)
                    cloud[i] = lp
                end

                local hMax, hMin = viewProjectionEdgeHits(cloud, 'X', furthest, self._viewport.tanxFov2)
                local vMax, vMin = viewProjectionEdgeHits(cloud, 'Y', furthest, self._viewport.tanyFov2)
                local distance = math.max(((hMax - hMin) / 2) / self._viewport.tanxFov2, ((vMax - vMin) / 2) / self._viewport.tanyFov2)

                return orientation * CFrame.new((hMax + hMin) / 2, (vMax + vMin) / 2, furthest + distance)
            end

            return ViewportModelClass
        end)()
    end,
    [93] = function()
        local wax, script, require = ImportGlobals(93)

        return (function(...)
            local Fusion = require(script.Parent.Parent.packages.fusion)
            local Computed = Fusion.Computed
            local States = require(script.Parent.Parent.packages.states)
            local animate = require(script.Parent.Parent.utils.animate)
            local THEME_COLOURS = {
                accent = {
                    dark = Color3.fromRGB(0, 110, 230),
                    twilight = Color3.fromRGB(115, 90, 235),
                    shadow = Color3.fromRGB(60, 180, 200),
                    dusk = Color3.fromRGB(235, 145, 48),
                    obsidian = Color3.fromRGB(110, 60, 190),
                    charcoal = Color3.fromRGB(70, 190, 220),
                    slate = Color3.fromRGB(95, 170, 230),
                    onyx = Color3.fromRGB(235, 125, 0),
                    ash = Color3.fromRGB(120, 120, 230),
                    granite = Color3.fromRGB(85, 180, 210),
                    cobalt = Color3.fromRGB(35, 135, 225),
                    aurora = Color3.fromRGB(85, 175, 210),
                    sunset = Color3.fromRGB(225, 72, 32),
                    mocha = Color3.fromRGB(170, 125, 225),
                    abyss = Color3.fromRGB(62, 80, 220),
                    void = Color3.fromRGB(115, 70, 205),
                    noir = Color3.fromRGB(120, 120, 120),
                },
                background = {
                    dark = Color3.fromRGB(15, 15, 15),
                    twilight = Color3.fromRGB(22, 22, 29),
                    shadow = Color3.fromRGB(18, 20, 25),
                    dusk = Color3.fromRGB(23, 21, 26),
                    obsidian = Color3.fromRGB(22, 22, 29),
                    charcoal = Color3.fromRGB(28, 28, 30),
                    slate = Color3.fromRGB(30, 33, 36),
                    onyx = Color3.fromRGB(24, 24, 26),
                    ash = Color3.fromRGB(26, 26, 31),
                    granite = Color3.fromRGB(25, 28, 32),
                    cobalt = Color3.fromRGB(21, 25, 31),
                    aurora = Color3.fromRGB(18, 25, 35),
                    sunset = Color3.fromRGB(25, 18, 20),
                    mocha = Color3.fromRGB(30, 30, 46),
                    abyss = Color3.fromRGB(10, 12, 16),
                    void = Color3.fromRGB(8, 8, 12),
                    noir = Color3.fromRGB(10, 10, 10),
                },
                secondary_background = {
                    dark = Color3.fromRGB(18, 18, 18),
                    twilight = Color3.fromRGB(26, 26, 34),
                    shadow = Color3.fromRGB(22, 24, 30),
                    dusk = Color3.fromRGB(27, 25, 31),
                    obsidian = Color3.fromRGB(28, 28, 36),
                    charcoal = Color3.fromRGB(35, 35, 37),
                    slate = Color3.fromRGB(37, 40, 44),
                    onyx = Color3.fromRGB(30, 30, 33),
                    ash = Color3.fromRGB(31, 31, 37),
                    granite = Color3.fromRGB(30, 33, 38),
                    cobalt = Color3.fromRGB(26, 31, 38),
                    aurora = Color3.fromRGB(22, 30, 42),
                    sunset = Color3.fromRGB(30, 22, 25),
                    mocha = Color3.fromRGB(35, 35, 51),
                    abyss = Color3.fromRGB(13, 15, 20),
                    void = Color3.fromRGB(12, 12, 16),
                    noir = Color3.fromRGB(13, 13, 13),
                },
                stroke = {
                    dark = Color3.fromRGB(27, 27, 27),
                    twilight = Color3.fromRGB(32, 32, 42),
                    shadow = Color3.fromRGB(28, 30, 38),
                    dusk = Color3.fromRGB(33, 31, 38),
                    obsidian = Color3.fromRGB(35, 35, 45),
                    charcoal = Color3.fromRGB(45, 45, 48),
                    slate = Color3.fromRGB(48, 52, 56),
                    onyx = Color3.fromRGB(40, 40, 44),
                    ash = Color3.fromRGB(38, 38, 46),
                    granite = Color3.fromRGB(42, 45, 50),
                    cobalt = Color3.fromRGB(35, 40, 48),
                    aurora = Color3.fromRGB(28, 38, 52),
                    sunset = Color3.fromRGB(38, 28, 32),
                    mocha = Color3.fromRGB(40, 40, 56),
                    abyss = Color3.fromRGB(16, 18, 24),
                    void = Color3.fromRGB(15, 15, 20),
                    noir = Color3.fromRGB(16, 16, 16),
                },
                text = {
                    dark = Color3.fromRGB(255, 255, 255),
                    twilight = Color3.fromRGB(240, 240, 245),
                    shadow = Color3.fromRGB(235, 235, 240),
                    dusk = Color3.fromRGB(250, 250, 255),
                    obsidian = Color3.fromRGB(230, 230, 235),
                    charcoal = Color3.fromRGB(240, 240, 245),
                    slate = Color3.fromRGB(235, 238, 240),
                    onyx = Color3.fromRGB(245, 245, 250),
                    ash = Color3.fromRGB(238, 238, 243),
                    granite = Color3.fromRGB(233, 236, 240),
                    cobalt = Color3.fromRGB(235, 240, 245),
                    aurora = Color3.fromRGB(235, 245, 255),
                    sunset = Color3.fromRGB(255, 245, 240),
                    mocha = Color3.fromRGB(205, 214, 244),
                    abyss = Color3.fromRGB(220, 225, 235),
                    void = Color3.fromRGB(220, 220, 230),
                    noir = Color3.fromRGB(220, 220, 220),
                },
                secondary_text = {
                    dark = Color3.fromRGB(150, 150, 150),
                    twilight = Color3.fromRGB(130, 135, 155),
                    shadow = Color3.fromRGB(125, 130, 150),
                    dusk = Color3.fromRGB(145, 150, 170),
                    obsidian = Color3.fromRGB(180, 180, 190),
                    charcoal = Color3.fromRGB(190, 190, 195),
                    slate = Color3.fromRGB(185, 188, 190),
                    onyx = Color3.fromRGB(195, 195, 200),
                    ash = Color3.fromRGB(175, 175, 185),
                    granite = Color3.fromRGB(170, 175, 180),
                    cobalt = Color3.fromRGB(165, 170, 180),
                    aurora = Color3.fromRGB(165, 180, 195),
                    sunset = Color3.fromRGB(180, 165, 160),
                    mocha = Color3.fromRGB(166, 173, 200),
                    abyss = Color3.fromRGB(140, 145, 160),
                    void = Color3.fromRGB(140, 140, 155),
                    noir = Color3.fromRGB(140, 140, 140),
                },
                tertiary_text = {
                    dark = Color3.fromRGB(100, 100, 100),
                    twilight = Color3.fromRGB(85, 90, 105),
                    shadow = Color3.fromRGB(80, 85, 100),
                    dusk = Color3.fromRGB(100, 105, 120),
                    obsidian = Color3.fromRGB(130, 130, 140),
                    charcoal = Color3.fromRGB(140, 140, 145),
                    slate = Color3.fromRGB(135, 138, 140),
                    onyx = Color3.fromRGB(145, 145, 150),
                    ash = Color3.fromRGB(125, 125, 135),
                    granite = Color3.fromRGB(120, 125, 130),
                    cobalt = Color3.fromRGB(115, 120, 130),
                    aurora = Color3.fromRGB(120, 130, 145),
                    sunset = Color3.fromRGB(130, 120, 115),
                    mocha = Color3.fromRGB(146, 158, 184),
                    abyss = Color3.fromRGB(120, 125, 140),
                    void = Color3.fromRGB(120, 120, 135),
                    noir = Color3.fromRGB(120, 120, 120),
                },
                danger = {
                    dark = Color3.fromRGB(220, 50, 47),
                    twilight = Color3.fromRGB(210, 55, 70),
                    shadow = Color3.fromRGB(205, 60, 75),
                    dusk = Color3.fromRGB(225, 65, 50),
                    obsidian = Color3.fromRGB(215, 45, 65),
                    charcoal = Color3.fromRGB(200, 55, 60),
                    slate = Color3.fromRGB(210, 50, 55),
                    onyx = Color3.fromRGB(225, 55, 45),
                    ash = Color3.fromRGB(205, 50, 65),
                    granite = Color3.fromRGB(200, 45, 55),
                    cobalt = Color3.fromRGB(215, 40, 50),
                    aurora = Color3.fromRGB(195, 55, 70),
                    sunset = Color3.fromRGB(230, 60, 45),
                    mocha = Color3.fromRGB(210, 45, 60),
                    abyss = Color3.fromRGB(190, 45, 55),
                    void = Color3.fromRGB(200, 40, 60),
                    noir = Color3.fromRGB(185, 45, 50),
                },
                warning = {
                    dark = Color3.fromRGB(215, 153, 33),
                    twilight = Color3.fromRGB(210, 145, 40),
                    shadow = Color3.fromRGB(205, 150, 45),
                    dusk = Color3.fromRGB(220, 155, 35),
                    obsidian = Color3.fromRGB(215, 140, 45),
                    charcoal = Color3.fromRGB(200, 145, 40),
                    slate = Color3.fromRGB(210, 150, 35),
                    onyx = Color3.fromRGB(225, 155, 30),
                    ash = Color3.fromRGB(205, 145, 45),
                    granite = Color3.fromRGB(200, 140, 35),
                    cobalt = Color3.fromRGB(215, 135, 30),
                    aurora = Color3.fromRGB(195, 150, 45),
                    sunset = Color3.fromRGB(230, 155, 30),
                    mocha = Color3.fromRGB(210, 140, 40),
                    abyss = Color3.fromRGB(190, 140, 35),
                    void = Color3.fromRGB(200, 135, 40),
                    noir = Color3.fromRGB(185, 140, 35),
                },
            }
            local currentTheme = States.Theme
            local currentColours = {}

            for colorName, colorOptions in pairs(THEME_COLOURS)do
                if type(colorOptions) == 'table' and type(colorOptions[next(colorOptions)]) == 'table' then
                    currentColours[colorName] = {}

                    for subColorName, subColorOptions in pairs(colorOptions)do
                        currentColours[colorName][subColorName] = Computed(function(
                        )
                            return subColorOptions[currentTheme:get()]
                        end)
                    end
                else
                    currentColours[colorName] = animate(function()
                        return colorOptions[currentTheme:get()]
                    end, 45, 1)
                end
            end

            return currentColours
        end)()
    end,
    [94] = function()
        local wax, script, require = ImportGlobals(94)

        return (function(...)
            local Fusion = require(script.Parent.packages.fusion)
            local story = {
                fusion = Fusion,
                story = function(props)
                    tick()

                    local Library = require(script.Parent)
                    local Window = Library:CreateWindow({
                        Title = 'KYANOS',
                        Tag = 'MEGA MANSION TYCOON',
                        Size = UDim2.fromOffset(800, 600),
                        Parent = props.target,
                        Debug = true,
                    })
                    local Categories = {
                        Test = Window:AddCategory({
                            Title = 'TESTING',
                        }),
                    }
                    local Tabs = {
                        TestUI = Categories.Test:AddTab({
                            Title = 'Test',
                        }),
                    }
                    local AimbotSection = Tabs.TestUI:AddSection({
                        Title = 'TEST',
                    })

                    AimbotSection:AddText({
                        Title = 'Instructions',
                        Description = 
[[Click "Add random entries" to add random entries to the table.
Toggling the "To Be toggled" will randomize the values of all elements.]],
                    })

                    local Dropdown = {
                        'Camera',
                        'Silent',
                    }

                    AimbotSection:AddToggle('Toggle', {
                        Title = 'Toggle the toggle',
                        Description = "Set's values of other UI elements randomly.",
                        Default = false,
                        Callback = function(v)
                            Library.Options.ToBeToggled:SetValue(v)
                            Library.Options.SilentAimChance:SetValue(math.random(1, 100))
                            Library.Options.AimMode:SetValue(Dropdown[math.random(1, #Dropdown)])
                        end,
                    })
                    AimbotSection:AddToggle('ToBeToggled', {
                        Title = 'To Be toggled',
                        Default = false,
                        Callback = function()
                            local Dialog = Window:Dialog({
                                Title = 'DIALOG',
                                Description = 'This is the dialog component of the UI Library Kyanos.',
                            })

                            Dialog:AddButton({
                                Title = 'Go Back',
                                Style = 'default',
                            })
                            Dialog:AddButton({
                                Title = 'Continue',
                                Style = 'primary',
                                Callback = function()
                                    local SecondDialog = Window:Dialog({
                                        Title = 'ANOTHER DIALOG',
                                        Description = 
[[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mollis dolor eget erat mattis, id mollis mauris cursus. Proin ornare sollicitudin odio, id posuere diam luctus id.]],
                                    })

                                    SecondDialog:AddButton({
                                        Title = 'OK',
                                        Style = 'default',
                                    })
                                end,
                            })
                        end,
                    })
                    AimbotSection:AddSlider('SilentAimChance', {
                        Title = 'Silent Aim Chance',
                        Description = 'Changes the Hit Chance for Silent Aim',
                        Default = 100,
                        Min = 1,
                        Max = 100,
                        Rounding = 1,
                    })
                    AimbotSection:AddDropdown('AimMode', {
                        Title = 'Aim Mode',
                        Description = 'Changes the Aim Mode',
                        Values = {
                            'Camera',
                            'Silent',
                        },
                        Default = 'Camera',
                    })

                    local Keybind = AimbotSection:AddKeybind('Keybind', {
                        Title = 'KeyBind',
                        Description = 'Automatically farms resources/kills',
                        Mode = 'Hold',
                        Default = 'LeftControl',
                        ChangedCallback = function(New)
                            print('Keybind changed:', New)
                        end,
                    })

                    task.spawn(function()
                        while true do
                            task.wait(1)

                            local state = Keybind:GetState()

                            if state then
                                print('Keybind is being held down')
                            end
                            if Library.Unloaded then
                                break
                            end
                        end
                    end)
                    AimbotSection:AddInput('WaypointInput', {
                        Title = 'Add Waypoint',
                        Description = 'Add and save a waypoint to teleport to.',
                        Default = 'Default',
                        Placeholder = 'Placeholder',
                        Numeric = false,
                        Finished = false,
                        Callback = function(Value)
                            print('Input changed:', Value)
                        end,
                    })

                    local demonSlayerMoves = {
                        {
                            'Water Surface Slash',
                            1234567890,
                            0.15,
                        },
                        {
                            'Hinokami Kagura',
                            2345678901,
                            0.28,
                        },
                        {
                            'Thunderclap and Flash',
                            3456789012,
                            0.18,
                        },
                        {
                            'Flame Dance',
                            4567890123,
                            0.22,
                        },
                        {
                            'Raging Sun',
                            5678901234,
                            0.25,
                        },
                        {
                            'Whirlpool',
                            6789012345,
                            0.3,
                        },
                        {
                            'Constant Flux',
                            7890123456,
                            0.21,
                        },
                        {
                            'Dance of the Fire God',
                            8901234567,
                            0.27,
                        },
                        {
                            'Clear Blue Sky',
                            9012345678,
                            0.24,
                        },
                        {
                            'Fifth Form: Blessed Rain After the Drought',
                            1357902468,
                            0.2,
                        },
                    }

                    AimbotSection:AddButton({
                        Title = 'Add random entries',
                        Style = 'default',
                        Callback = function()
                            local numberOfEntries = math.random(1, #demonSlayerMoves)
                            local newRows = {}

                            for i = 1, numberOfEntries do
                                local randomMove = demonSlayerMoves[math.random(1, #demonSlayerMoves)]

                                table.insert(newRows, randomMove)
                            end

                            Library.Options.Table:UpdateRows(newRows)
                        end,
                    })
                    AimbotSection:AddTable('Table', {
                        Title = 'Auto Parry Animations',
                        Description = 'All animations supported by the auto parry module',
                        Headers = {
                            'Animation Name',
                            'Animation ID',
                            'Timing',
                            'Confident?',
                        },
                        Rows = demonSlayerMoves,
                        AlternateBackground = true,
                    })

                    return function()
                        Library:Destroy()
                    end
                end,
            }

            return story
        end)()
    end,
    [96] = function()
        local wax, script, require = ImportGlobals(96)

        return (function(...)
            local Fusion = require(script.Parent.Parent.packages.fusion)
            local Spring = Fusion.Spring
            local Computed = Fusion.Computed

            return function(callback, speed, damping)
                return Spring(Computed(callback), speed, damping)
            end
        end)()
    end,
    [97] = function()
        ImportGlobals(97)

        return (function(...)
            local ColorUtils = {}

            function ColorUtils.darkenRGB(Color, factor)
                return Color3.fromRGB((Color.R * 255) - factor, (Color.G * 255) - factor, (Color.B * 255) - factor)
            end
            function ColorUtils.lightenRGB(Color, factor)
                return Color3.fromRGB((Color.R * 255) + factor, (Color.G * 255) + factor, (Color.B * 255) + factor)
            end

            return ColorUtils
        end)()
    end,
    [98] = function()
        local wax, script, require = ImportGlobals(98)

        return (function(...)
            local unwrap = require(script.Parent.unwrap)

            return function(container, element)
                local currentItems = unwrap(container)

                table.insert(currentItems, element)
                container:set(currentItems)
            end
        end)()
    end,
    [99] = function()
        ImportGlobals(99)

        return (function(...)
            local Player = {}
            local Players = game:GetService('Players')
            local ACCEPTED_ROOTS = {
                'HumanoidRootPart',
                'Torso',
                'UpperTorso',
                'LowerTorso',
                'Head',
            }
            local chunkMatch = function(chunk, str)
                if string.sub(chunk, 1, #str) == str then
                    return true
                end

                return false
            end

            function Player.getCharacter()
                local player = Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()

                return character
            end
            function Player.others()
                local players = Players:GetPlayers()
                local others = {}

                for _, player in players do
                    if player ~= Player.me() then
                        table.insert(others, player)
                    end
                end

                return others
            end
            function Player.getByName(name)
                local players = Players:GetPlayers()

                for _, player in players do
                    if chunkMatch(string.lower(player.Name), name) or chunkMatch(string.lower(player.DisplayName), name) then
                        return player
                    end
                end

                return nil
            end
            function Player.setPosition(position)
                local character = Player.getCharacter()

                character:PivotTo(position)
            end
            function Player.getRoot(player)
                for _, object in player.Character:GetChildren()do
                    if table.find(ACCEPTED_ROOTS, object.Name) then
                        return object
                    end
                end

                return nil
            end
            function Player.getHumanoid()
                return Player.getCharacter():FindFirstChildWhichIsA('Humanoid')
            end

            return Player
        end)()
    end,
    [100] = function()
        local wax, script, require = ImportGlobals(100)

        return (function(...)
            local Promise = require(script.Parent.Parent.packages.promise)

            return function(url)
                return Promise.new(function(resolve, reject)
                    local success, result = pcall(function()
                        return game:HttpGetAsync(url)
                    end)

                    if success then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end
        end)()
    end,
    [101] = function()
        ImportGlobals(101)

        return (function(...)
            return function(callback)
                local ok, result = pcall(callback)

                if not ok then
                    error(result)
                end

                return result
            end
        end)()
    end,
    [102] = function()
        ImportGlobals(102)

        return (function(...)
            return setmetatable({}, {
                __index = function(self, serviceName)
                    local service = game:GetService(serviceName)

                    self[serviceName] = service

                    return service
                end,
            })
        end)()
    end,
    [103] = function()
        ImportGlobals(103)

        return (function(...)
            return function(x, useDependency)
                if typeof(x) == 'table' and x.type == 'State' then
                    return x:get(useDependency)
                end

                return x
            end
        end)()
    end,
}
local ObjectTree = {
    {
        1,
        2,
        {
            'Kyanos',
        },
        {
            {
                94,
                2,
                {
                    'test.story',
                },
            },
            {
                2,
                2,
                {
                    'Elements',
                },
                {
                    {
                        7,
                        2,
                        {
                            'keybind',
                        },
                    },
                    {
                        3,
                        2,
                        {
                            'button',
                        },
                    },
                    {
                        6,
                        2,
                        {
                            'input',
                        },
                    },
                    {
                        4,
                        2,
                        {
                            'colorpicker',
                        },
                    },
                    {
                        9,
                        2,
                        {
                            'seperator',
                        },
                    },
                    {
                        12,
                        2,
                        {
                            'text',
                        },
                    },
                    {
                        11,
                        2,
                        {
                            'table',
                        },
                    },
                    {
                        10,
                        2,
                        {
                            'slider',
                        },
                    },
                    {
                        13,
                        2,
                        {
                            'toggle',
                        },
                    },
                    {
                        8,
                        2,
                        {
                            'radio',
                        },
                    },
                    {
                        5,
                        2,
                        {
                            'dropdown',
                        },
                    },
                },
            },
            {
                14,
                1,
                {
                    'components',
                },
                {
                    {
                        16,
                        1,
                        {
                            'window',
                        },
                        {
                            {
                                20,
                                2,
                                {
                                    'tab',
                                },
                            },
                            {
                                17,
                                2,
                                {
                                    'category',
                                },
                            },
                            {
                                19,
                                2,
                                {
                                    'section',
                                },
                            },
                            {
                                21,
                                2,
                                {
                                    'window',
                                },
                            },
                            {
                                18,
                                2,
                                {
                                    'dialog',
                                },
                            },
                        },
                    },
                    {
                        15,
                        1,
                        {
                            'notification',
                        },
                    },
                },
            },
            {
                95,
                1,
                {
                    'utils',
                },
                {
                    {
                        97,
                        2,
                        {
                            'color3',
                        },
                    },
                    {
                        99,
                        2,
                        {
                            'player',
                        },
                    },
                    {
                        98,
                        2,
                        {
                            'insertitem',
                        },
                    },
                    {
                        102,
                        2,
                        {
                            'services',
                        },
                    },
                    {
                        101,
                        2,
                        {
                            'safecallback',
                        },
                    },
                    {
                        100,
                        2,
                        {
                            'request',
                        },
                    },
                    {
                        96,
                        2,
                        {
                            'animate',
                        },
                    },
                    {
                        103,
                        2,
                        {
                            'unwrap',
                        },
                    },
                },
            },
            {
                92,
                1,
                {
                    'storage',
                },
                {
                    {
                        93,
                        2,
                        {
                            'theme',
                        },
                    },
                },
            },
            {
                22,
                2,
                {
                    'mock.story',
                },
            },
            {
                23,
                1,
                {
                    'packages',
                },
                {
                    {
                        91,
                        2,
                        {
                            'viewport',
                        },
                    },
                    {
                        90,
                        2,
                        {
                            'states',
                        },
                    },
                    {
                        26,
                        2,
                        {
                            'fusion',
                        },
                        {
                            {
                                27,
                                1,
                                {
                                    'Animation',
                                },
                                {
                                    {
                                        34,
                                        2,
                                        {
                                            'packType',
                                        },
                                    },
                                    {
                                        32,
                                        2,
                                        {
                                            'getTweenRatio',
                                        },
                                    },
                                    {
                                        31,
                                        2,
                                        {
                                            'TweenScheduler',
                                        },
                                    },
                                    {
                                        33,
                                        2,
                                        {
                                            'lerpType',
                                        },
                                    },
                                    {
                                        29,
                                        2,
                                        {
                                            'SpringScheduler',
                                        },
                                    },
                                    {
                                        28,
                                        2,
                                        {
                                            'Spring',
                                        },
                                    },
                                    {
                                        30,
                                        2,
                                        {
                                            'Tween',
                                        },
                                    },
                                    {
                                        36,
                                        2,
                                        {
                                            'unpackType',
                                        },
                                    },
                                    {
                                        35,
                                        2,
                                        {
                                            'springCoefficients',
                                        },
                                    },
                                },
                            },
                            {
                                45,
                                1,
                                {
                                    'Instances',
                                },
                                {
                                    {
                                        49,
                                        2,
                                        {
                                            'New',
                                        },
                                    },
                                    {
                                        47,
                                        2,
                                        {
                                            'Cleanup',
                                        },
                                    },
                                    {
                                        52,
                                        2,
                                        {
                                            'Out',
                                        },
                                    },
                                    {
                                        51,
                                        2,
                                        {
                                            'OnEvent',
                                        },
                                    },
                                    {
                                        53,
                                        2,
                                        {
                                            'Ref',
                                        },
                                    },
                                    {
                                        46,
                                        2,
                                        {
                                            'Children',
                                        },
                                    },
                                    {
                                        55,
                                        2,
                                        {
                                            'defaultProps',
                                        },
                                    },
                                    {
                                        54,
                                        2,
                                        {
                                            'applyInstanceProps',
                                        },
                                    },
                                    {
                                        48,
                                        2,
                                        {
                                            'Hydrate',
                                        },
                                    },
                                    {
                                        50,
                                        2,
                                        {
                                            'OnChange',
                                        },
                                    },
                                },
                            },
                            {
                                37,
                                1,
                                {
                                    'Colour',
                                },
                                {
                                    {
                                        38,
                                        2,
                                        {
                                            'Oklab',
                                        },
                                    },
                                },
                            },
                            {
                                63,
                                1,
                                {
                                    'State',
                                },
                                {
                                    {
                                        64,
                                        2,
                                        {
                                            'Computed',
                                        },
                                    },
                                    {
                                        66,
                                        2,
                                        {
                                            'ForPairs',
                                        },
                                    },
                                    {
                                        70,
                                        2,
                                        {
                                            'unwrap',
                                        },
                                    },
                                    {
                                        65,
                                        2,
                                        {
                                            'ForKeys',
                                        },
                                    },
                                    {
                                        68,
                                        2,
                                        {
                                            'Observer',
                                        },
                                    },
                                    {
                                        67,
                                        2,
                                        {
                                            'ForValues',
                                        },
                                    },
                                    {
                                        69,
                                        2,
                                        {
                                            'Value',
                                        },
                                    },
                                },
                            },
                            {
                                71,
                                2,
                                {
                                    'Types',
                                },
                            },
                            {
                                72,
                                1,
                                {
                                    'Utility',
                                },
                                {
                                    {
                                        75,
                                        2,
                                        {
                                            'doNothing',
                                        },
                                    },
                                    {
                                        79,
                                        2,
                                        {
                                            'xtypeof',
                                        },
                                    },
                                    {
                                        78,
                                        2,
                                        {
                                            'restrictRead',
                                        },
                                    },
                                    {
                                        74,
                                        2,
                                        {
                                            'cleanup',
                                        },
                                    },
                                    {
                                        73,
                                        2,
                                        {
                                            'None',
                                        },
                                    },
                                    {
                                        77,
                                        2,
                                        {
                                            'needsDestruction',
                                        },
                                    },
                                    {
                                        76,
                                        2,
                                        {
                                            'isSimilar',
                                        },
                                    },
                                },
                            },
                            {
                                62,
                                2,
                                {
                                    'PubTypes',
                                },
                            },
                            {
                                39,
                                1,
                                {
                                    'Dependencies',
                                },
                                {
                                    {
                                        44,
                                        2,
                                        {
                                            'useDependency',
                                        },
                                    },
                                    {
                                        40,
                                        2,
                                        {
                                            'captureDependencies',
                                        },
                                    },
                                    {
                                        41,
                                        2,
                                        {
                                            'initDependency',
                                        },
                                    },
                                    {
                                        42,
                                        2,
                                        {
                                            'sharedState',
                                        },
                                    },
                                    {
                                        43,
                                        2,
                                        {
                                            'updateAll',
                                        },
                                    },
                                },
                            },
                            {
                                56,
                                1,
                                {
                                    'Logging',
                                },
                                {
                                    {
                                        60,
                                        2,
                                        {
                                            'messages',
                                        },
                                    },
                                    {
                                        58,
                                        2,
                                        {
                                            'logErrorNonFatal',
                                        },
                                    },
                                    {
                                        59,
                                        2,
                                        {
                                            'logWarn',
                                        },
                                    },
                                    {
                                        61,
                                        2,
                                        {
                                            'parseError',
                                        },
                                    },
                                    {
                                        57,
                                        2,
                                        {
                                            'logError',
                                        },
                                    },
                                },
                            },
                        },
                    },
                    {
                        81,
                        2,
                        {
                            'promise',
                        },
                    },
                    {
                        24,
                        2,
                        {
                            'damerau',
                        },
                    },
                    {
                        80,
                        2,
                        {
                            'maid',
                        },
                    },
                    {
                        82,
                        2,
                        {
                            'snapdragon',
                        },
                        {
                            {
                                89,
                                2,
                                {
                                    't',
                                },
                            },
                            {
                                83,
                                2,
                                {
                                    'Maid',
                                },
                            },
                            {
                                87,
                                2,
                                {
                                    'Symbol',
                                },
                            },
                            {
                                84,
                                2,
                                {
                                    'Signal',
                                },
                            },
                            {
                                85,
                                2,
                                {
                                    'SnapdragonController',
                                },
                            },
                            {
                                86,
                                2,
                                {
                                    'SnapdragonRef',
                                },
                            },
                            {
                                88,
                                2,
                                {
                                    'objectAssign',
                                },
                            },
                        },
                    },
                    {
                        25,
                        2,
                        {
                            'freecam',
                        },
                    },
                },
            },
        },
    },
}
local LineOffsets = nil
local WaxVersion = '0.4.1'
local EnvName = 'WaxRuntime'
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION = string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION
local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t)
    return t
end
local coroutine_wrap = coroutine.wrap
local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

if _VERSION and string_sub(_VERSION, 1, 4) == 'Lune' then
    local RequireSuccess, LuneTaskLib = pcall(require, '@lune/task')

    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end
local ClassNameIdBindings = {
    [1] = 'Folder',
    [2] = 'ModuleScript',
    [3] = 'Script',
    [4] = 'LocalScript',
    [5] = 'StringValue',
}
local RefBindings = {}
local ScriptClosures = {}
local ScriptClosureRefIds = {}
local StoredModuleValues = {}
local ScriptsToRun = {}
local SharedEnvironment = {}
local RefChildren = {}
local InstanceMethods = {
    GetFullName = {
        {},
        function(self)
            local Path = self.Name
            local ObjectPointer = self.Parent

            while ObjectPointer do
                Path = ObjectPointer.Name .. '.' .. Path
                ObjectPointer = ObjectPointer.Parent
            end

            return Path
        end,
    },
    GetChildren = {
        {},
        function(self)
            local ReturnArray = {}

            for Child in next, RefChildren[self]do
                table_insert(ReturnArray, Child)
            end

            return ReturnArray
        end,
    },
    GetDescendants = {
        {},
        function(self)
            local ReturnArray = {}

            for Child in next, RefChildren[self]do
                table_insert(ReturnArray, Child)

                for _, Descendant in next, Child:GetDescendants()do
                    table_insert(ReturnArray, Descendant)
                end
            end

            return ReturnArray
        end,
    },
    FindFirstChild = {
        {
            'string',
            'boolean?',
        },
        function(self, name, recursive)
            local Children = RefChildren[self]

            for Child in next, Children do
                if Child.Name == name then
                    return Child
                end
            end

            if recursive then
                for Child in next, Children do
                    return Child:FindFirstChild(name, true)
                end
            end
        end,
    },
    FindFirstAncestor = {
        {
            'string',
        },
        function(self, name)
            local RefPointer = self.Parent

            while RefPointer do
                if RefPointer.Name == name then
                    return RefPointer
                end

                RefPointer = RefPointer.Parent
            end
        end,
    },
    WaitForChild = {
        {
            'string',
            'number?',
        },
        function(self, name)
            return self:FindFirstChild(name)
        end,
    },
}
local InstanceMethodProxies = {}

for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]
    local EvaluatedTypeInfo = {}

    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, '^([^%?]+)(%??)')

        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}

        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error('Argument ' .. RealArg .. ' missing or nil', 3)
            end
            if ExpectedType ~= 'any' and RealArgType ~= ExpectedType and not (RealArgType == 'nil' and IsOptional) then
                error('Argument ' .. ArgIndex .. ' expects type "' .. ExpectedType .. '", got "' .. RealArgType .. '"', 2)
            end
        end

        return Method(self, ...)
    end
end

local CreateRef = function(className, name, parent)
    local StringValue_Value
    local Children = setmetatable({}, {
        __mode = 'k',
    })
    local InvalidMember = function(member)
        error(member .. ' is not a valid (virtual) member of ' .. className .. ' "' .. name .. '"', 3)
    end
    local ReadOnlyProperty = function(property)
        error('Unable to assign (virtual) property ' .. property .. '. Property is read only', 3)
    end
    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false
    RefMetatable.__index = function(_, index)
        if index == 'ClassName' then
            return className
        elseif index == 'Name' then
            return name
        elseif index == 'Parent' then
            return parent
        elseif className == 'StringValue' and index == 'Value' then
            return StringValue_Value
        else
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        InvalidMember(index)
    end
    RefMetatable.__newindex = function(_, index, value)
        if index == 'ClassName' then
            ReadOnlyProperty(index)
        elseif index == 'Name' then
            name = value
        elseif index == 'Parent' then
            if value == Ref then
                return
            end
            if parent ~= nil then
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                RefChildren[value][Ref] = true
            end
        elseif className == 'StringValue' and index == 'Value' then
            StringValue_Value = value
        else
            InvalidMember(index)
        end
    end
    RefMetatable.__tostring = function()
        return name
    end

    setmetatable(Ref, RefMetatable)

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3]
    local Children = object[4]
    local ClassName = ClassNameIdBindings[ClassNameId]
    local Name = Properties and table_remove(Properties, 1) or ClassName
    local Ref = CreateRef(ClassName, Name, parent)

    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end
    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef('Folder', '[' .. EnvName .. ']')

for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName

    if ClassName == 'LocalScript' or ClassName == 'Script' then
        table_insert(ScriptsToRun, Ref)
    end
end

local LoadScript = function(scriptRef)
    local ScriptClassName = scriptRef.ClassName
    local StoredModuleValue = StoredModuleValues[scriptRef]

    if StoredModuleValue and ScriptClassName == 'ModuleScript' then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]
    local FormatError = function(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, '[^:]+:(%d+): (.+)')

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ':*: ' .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]
        local RealErrorLine = OriginalErrorLine - LineOffset + 1

        if RealErrorLine < 0 then
            RealErrorLine = '?'
        end

        return VirtualFullName .. ':' .. RealErrorLine .. ': ' .. BaseErrorMessage
    end

    if ScriptClassName == 'LocalScript' or ScriptClassName == 'Script' then
        local RunSuccess, ErrorMessage = pcall(Closure)

        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {
            pcall(Closure),
        }
        local RunSuccess = table_remove(PCallReturn, 1)

        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)

            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn

        return unpack(PCallReturn)
    end
end

function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]
    local RealCall = function(f, ...)
        local PCallReturn = {
            pcall(f, ...),
        }
        local CallSuccess = table_remove(PCallReturn, 1)

        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))
    local Global_wax = table_freeze({
        version = WaxVersion,
        envname = EnvName,
        shared = WaxShared,
        script = script,
        require = require,
    })
    local Global_script = ScriptRef
    local Global_require = function(module, ...)
        local ModuleArgType = type(module)
        local ErrorNonModuleScript = 'Attempted to call require with a non-ModuleScript'
        local ErrorSelfRequire = 'Attempted to call require with self'

        if ModuleArgType == 'table' and RefChildren[module] then
            if module.ClassName ~= 'ModuleScript' then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == 'string' and string_sub(module, 1, 1) ~= '@' then
            if #module == 0 then
                error('Attempted to call require with empty string', 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == '/' then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == './' then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch

            for PathMatch in string_gmatch(module, '([^/]*)/?')do
                local RealIndex = PathMatch

                if PathMatch == '..' then
                    RealIndex = 'Parent'
                end
                if RealIndex ~= '' then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)

                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent

                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end
                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= 'init' and PathMatch ~= 'init.server' and PathMatch ~= 'init.client' then
                        error('Virtual script path "' .. module .. '" not found', 2)
                    end
                end

                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= 'ModuleScript' then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end

return LoadScript(RealObjectRoot:GetChildren()[1])
