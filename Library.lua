-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)local HttpService = game:GetService("HttpService")

-- < Packages >
local Fusion = require("packages/fusion")
local States = require("packages/states")

local ElementsTable = require("Elements")

-- < Variables >
local Children = Fusion.Children
local ForPairs = Fusion.ForPairs
local New = Fusion.New
local Observer = Fusion.Observer

local Library = {
	Version = "1.0.0",
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
	error(string.format("Invalid method call: %s", Key))
end

local function initElementComponent(ElementComponent, Container, Type, ScrollFrame)
	ElementComponent.Container = Container
	ElementComponent.Type = Type
	ElementComponent.ScrollFrame = ScrollFrame
	ElementComponent.Library = Library
end

for _, ElementComponent in ipairs(ElementsTable) do
	Elements["Add" .. ElementComponent.__type] = function(self, Idx, Config)
		initElementComponent(ElementComponent, self.Container, self.Type, self.ScrollFrame)
		return ElementComponent:New(Idx, Config)
	end
end

States.Elements:set(Elements)

function Library:CreateWindow(Config)
	assert(Config.Title, "[WINDOW] Missing Title")
	assert(Config.Title, "[WINDOW] Missing Tag")

	if Library.Window then
		error("[WINDOW] Window already exists")
		return
	end

	if not Library.GUI then
		if Config.Debug then
			local GUI = New("Frame")({
				Name = "Frame",
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
			local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
			local GUI = New("ScreenGui")({
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
	Library.Theme = Config.Theme or "Dark"

	local Window = require("components/window/window")(Config)
	Library.Window = Window

	return Window
end

function Library:SetTheme(theme)
	States.Theme:set(theme)
end

function Library:Destroy()
	print("Destroying")
	if Library.Connections then
		for _, v in pairs(Library.Connections) do
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

end)() end,
    function()local wax,script,require=ImportGlobals(2)local ImportGlobals return (function(...)local Elements = {}

-- Load all Element modules
local ElementModules = {
    "Elements/slider",
    "Elements/dropdown"
}

for _, modulePath in ipairs(ElementModules) do
    table.insert(Elements, require(modulePath))
end

return Elements
end)() end,
    function()local wax,script,require=ImportGlobals(3)local ImportGlobals return (function(...)--[[
    button.lua
]]

-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

-- < Types >
type ButtonProps = {
	Title: string,
	Style: string,
	Callback: (...any) -> ...any?,
}

local Element = {}
Element.__index = Element
Element.__type = "Button"

function Element:New(props: ButtonProps)
	assert(props.Title, "[BUTTON] Missing Title")
	assert(props.Style, "[BUTTON] Missing Style")

	local Button = {
		Callback = props.Callback or function(_) end,
		Style = string.lower(props.Style),
		Type = "Button",
	}

	local isHovering = Value(false)
	local isHeldDown = Value(false)

	Button.Root = New("Frame")({
		Name = "Button",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0),

		[Children] = {
			New("TextButton")({
				Name = "TextButton",
				FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text = props.Title,
				TextColor3 = animate(function()
					local state = Button.Style
					if state == "default" then
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

					if state == "primary" then
						color = unwrap(Theme.accent)
					elseif state == "danger" then
						color = unwrap(Theme.danger)
					elseif state == "warning" then
						color = unwrap(Theme.warning)
					else -- default
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
					New("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 4),
					}),
					New("UIStroke")({
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Color = animate(function()
							local color
							local state = Button.Style

							if state == "primary" then
								color = unwrap(Theme.accent)
							elseif state == "danger" then
								color = unwrap(Theme.danger)
							elseif state == "warning" then
								color = unwrap(Theme.warning)
							else -- default
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
					New("UIPadding")({
						Name = "UIPadding",
						PaddingBottom = UDim.new(0, 8),
						PaddingLeft = UDim.new(0, 16),
						PaddingRight = UDim.new(0, 16),
						PaddingTop = UDim.new(0, 8),
					}),
					New("UIGradient")({
						Name = "UIGradient",
						Rotation = 90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 0.125),
						}),
					}),
				},

				[OnEvent("Activated")] = function()
					safeCallback(function()
						Button.Callback()
					end)
				end,

				[OnEvent("InputEnded")] = function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						isHeldDown:set(false)
					end
				end,

				[OnEvent("InputBegan")] = function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						isHeldDown:set(true)
					end
				end,

				[OnEvent("MouseEnter")] = function()
					isHovering:set(true)
				end,

				[OnEvent("MouseLeave")] = function()
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

end)() end,
    function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")

-- < Types >
type ColorpickerProps = {
	Title: string,
    Description: string?,
}

local Element = {}
Element.__index = Element
Element.__type = "Colorpicker"

function Element:New(Idx, props: ColorpickerProps)
    local Colorpicker = {
        Title = Value(props.Title) or nil,
        Description = Value(props.Description) or nil,
        Value = Value(props.Default or Color3.fromRGB(255, 255, 255)),
        Type = "Colorpicker",
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

    -- UI Element References
    local Root = Value()
    local Container = Value()
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
    local TextHolder = Value()
    local Title = Value()
    local Description = Value()
    local Visualize = Value()

    local HSVColor = Value(Color3.fromHSV(Colorpicker.H, 1, 1))
    local SubmitColor = Value(Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V))

    local function updateAssetsColors()
		unwrap(HSV).BackgroundColor3 = Color3.fromHSV(Colorpicker.H, 1, 1)	
		unwrap(Submit).BackgroundColor3 = Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V)
		unwrap(Hex).Text = Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V):ToHex()
		unwrap(RGB).Text = string.format("%d, %d, %d", unwrap(Submit).BackgroundColor3.R * 255, unwrap(Submit).BackgroundColor3.G * 255, unwrap(Submit).BackgroundColor3.B * 255)
    end

    local function updateDragPositions()
		unwrap(SliderDrag).Position = UDim2.new(Colorpicker.H, 0, 0.5, 0)
		unwrap(HSVDrag).Position = UDim2.new(Colorpicker.S, 0, 1 - Colorpicker.V, 0)
    end

    local function RecalculatePickerPosition()
        local visualizerPos = unwrap(Visualize).AbsolutePosition
        local visualizerSize = unwrap(Visualize).AbsoluteSize
        local picker = unwrap(ColorpickerFrame)
        
        picker.Position = UDim2.fromOffset(visualizerPos.X, visualizerPos.Y + visualizerSize.Y + 5)
    end

    Colorpicker.Picker = New "TextButton" {
        [Ref] = ColorpickerFrame,
        Name = "Colorpicker",
        BackgroundColor3 = Theme.background,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(241, 0),
        ZIndex = 9999,
        Visible = Colorpicker.Opened,
        Parent = unwrap(States.Library).GUI,
    
        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0, 4),
            },
    
            New "UIStroke" {
                Name = "UIStroke",
                Color = Theme.stroke,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            },
    
            New "Frame" {
                [Ref] = Holder,
                Name = "Holder",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 9999,
    
                [Children] = {
                    New "ImageLabel" {
                        [Ref] = HSV,
                        Name = "HSV",
                        Image = "rbxassetid://4155801252",
                        BackgroundColor3 = Color3.fromRGB(255, 138, 21),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.0928, 0.0357),
                        Size = UDim2.new(1, 0, 0, 140),
                        ZIndex = 9999,
    
                        [Children] = {
                            New "ImageButton" {
                                [Ref] = HSVDrag,
                                Name = "Drag",
                                Image = "http://www.roblox.com/asset/?id=4805639000",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(27, 42, 53),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromOffset(20, 20),
                                ZIndex = 9999,

                                [OnEvent("InputBegan")] = function(input)
                                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                        hsvDragging:set(true)
                                        local inputChanged; inputChanged = UserInputService.InputChanged:Connect(function(input)
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
                                
                                        local inputEnded; inputEnded = UserInputService.InputEnded:Connect(function(input)
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
    
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0, 4),
                            },
    
                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Theme.stroke,
                            },
                        }
                    },
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 10),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
    
                    New "UIPadding" {
                        Name = "UIPadding",
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 10),
                        PaddingTop = UDim.new(0, 10),
                    },
    
                    New "Frame" {
                        [Ref] = Slider,
                        Name = "Slider",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderColor3 = Color3.fromRGB(27, 42, 53),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.0253, 0.744),
                        Size = UDim2.new(1, 0, 0, 18),
                        ZIndex = 9999,
    
                        [Children] = {
                            New "UIGradient" {
                                Name = "UIGradient",
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
    
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0, 4),
                            },
    
                            New "ImageButton" {
                                [Ref] = SliderDrag,
                                Name = "Drag",
                                Image = "http://www.roblox.com/asset/?id=4805639000",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(27, 42, 53),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromOffset(20, 20),
                                ZIndex = 9999,
                                
                                [OnEvent "InputBegan"] = function(Input)
                                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                        sliderDragging:set(true)
                                        local inputChanged; inputChanged = UserInputService.InputChanged:Connect(function(input)
                                            if sliderDragging:get() and input.UserInputType == Enum.UserInputType.MouseMovement then
                                                local percentX = math.clamp((input.Position.X - unwrap(Slider).AbsolutePosition.X) / unwrap(Slider).AbsoluteSize.X, 0, 1)
                                                Colorpicker.H = percentX
                                
                                                unwrap(SliderDrag).Position = UDim2.new(percentX, 0, 0.5, 0)
                                                updateAssetsColors()
                                            end
                                        end)
                                
                                        local inputEnded; inputEnded = UserInputService.InputEnded:Connect(function(input)
                                            if sliderDragging:get() and input.UserInputType == Enum.UserInputType.MouseButton1 then
                                                inputChanged:Disconnect()
                                                inputEnded:Disconnect()
                                                sliderDragging:set(false)
                                            end
                                        end)
                                        table.insert(unwrap(States.Library).Connections, inputChanged)
                                        table.insert(unwrap(States.Library).Connections, inputEnded)
                                    end
                                end
                            },
                        }
                    },
    
                    New "Frame" {
                        [Ref] = HexRGBContainer,
                        Name = "HEXRGB",
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 0),
                        ZIndex = 9999,
    
                        [Children] = {
                            New "UIListLayout" {
                                Name = "UIListLayout",
                                Padding = UDim.new(0, 6),
                                FillDirection = Enum.FillDirection.Horizontal,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            },
    
                            New "TextBox" {
                                [Ref] = Hex,
                                Name = "HEX",
                                CursorPosition = -1,
                                FontFace = Font.new(
                                    "rbxassetid://12187365364",
                                    Enum.FontWeight.Medium,
                                    Enum.FontStyle.Normal
                                ),
                                PlaceholderColor3 = Theme.tertiary_text,
                                PlaceholderText = "HEX",
                                Text = "",
                                TextColor3 = Theme.secondary_text,
                                TextSize = 14,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.new(0.5, -3, 0, 25),
                                ZIndex = 9999,
    
                                [Children] = {
                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                        Color = Theme.stroke,
                                    },
    
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0, 2),
                                    },
                                },

                                [OnEvent "FocusLost"] = function()
                                    if string.match(unwrap(Hex).Text, "^%x%x%x%x%x%x$") then
                                        Colorpicker.H, Colorpicker.S, Colorpicker.V = Color3.fromHex(unwrap(Hex).Text):ToHSV()
                                    end
                            
                                    updateAssetsColors()
                                    updateDragPositions()
                                end
                            },
    
                            New "TextBox" {
                                [Ref] = RGB,
                                Name = "RGB",
                                FontFace = Font.new(
                                    "rbxassetid://12187365364",
                                    Enum.FontWeight.Medium,
                                    Enum.FontStyle.Normal
                                ),
                                PlaceholderColor3 = Theme.tertiary_text,
                                PlaceholderText = "RGB",
                                Text = "",
                                TextColor3 = Theme.secondary_text,
                                TextSize = 14,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.new(0.5, -3, 0, 25),
                                ZIndex = 9999,
    
                                [Children] = {
                                    New "UIStroke" {
                                        Name = "UIStroke",
                                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                        Color = Theme.stroke,
                                    },
    
                                    New "UICorner" {
                                        Name = "UICorner",
                                        CornerRadius = UDim.new(0, 2),
                                    },
                                },

                                [OnEvent "FocusLost"] = function()
                                    if string.match(unwrap(RGB).Text, "^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$") then
                                        local r, g, b = string.match(unwrap(RGB).Text, "^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
                                        r, g, b = math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255)
                                        Colorpicker.H, Colorpicker.S, Colorpicker.V = Color3.fromRGB(r, g, b):ToHSV()
                                    end
                            
                                    updateAssetsColors()
                                    updateDragPositions()
                                end
                            },
                        }
                    },
    
                    New "TextButton" {
                        [Ref] = Submit,
                        Name = "TextButton",
                        FontFace = Font.new(
                            "rbxassetid://12187365364",
                            Enum.FontWeight.Medium,
                            Enum.FontStyle.Normal
                        ),
                        Text = "Submit",
                        TextColor3 = Theme.text,
                        TextSize = 14,
                        BackgroundColor3 = animate(function()
                            return SubmitColor:get()
                        end, 40, 1),
                        Size = UDim2.new(1, 0, 0, 25),
                        ZIndex = 9999,
    
                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0, 2),
                            },
    
                            New "UIStroke" {
                                Name = "UIStroke",
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                Color = Theme.stroke,
                            },
                        },

                        [OnEvent "InputEnded"] = function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                local color = Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V)
                                Colorpicker.Value:set(color)
                                unwrap(Submit).BackgroundColor3 = color
                                Colorpicker.Changed(color)
                                Colorpicker.Callback(color)
                            end
                        end,
                    },
                }
            },
    
            New "UISizeConstraint" {
                Name = "UISizeConstraint",
                MinSize = Vector2.new(240, 255),
            },
    
            New "ImageLabel" {
                Name = "EShadow",
                Image = "rbxassetid://9313765853",
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
        }
    }

    Colorpicker.Root = New "Frame" {
        [Ref] = Root,
        Name = "Text",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
    
        [Children] = {
            New "Frame" {
                Name = "Addons",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.fromScale(0, 1),
            
                [Children] = {
                    New "Frame" {
                        [Ref] = Visualize,
                        Name = "Visualize",
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
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0, 3),
                            },
                        },

                        [OnEvent "InputEnded"] = function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                                Colorpicker.Opened:set(not Colorpicker.Opened:get())
                            end
                        end,
                    },
            
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 15),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    },
                }
            },
            New "Frame" {
                Name = "TextHolder",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -80, 1, 0),
    
                [Children] = {
                    New "TextLabel" {
                        Name = "Title",
                        FontFace = Font.new(
                            "rbxassetid://12187365364",
                            Enum.FontWeight.Medium,
                            Enum.FontStyle.Normal
                        ),
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
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 5),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
    
                    Computed(function()
                        if props.Description then
                            return New "TextLabel" {
                                Name = "Description",
                                FontFace = Font.new("rbxassetid://12187365364"),
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
                    end, Fusion.cleanup)
                }
            },
        },
    }

    Observer(Colorpicker.Opened):onChange(function()
        if Colorpicker.Opened:get() then
            local escapeConnection = UserInputService.InputBegan:Connect(function(Input)
                if Input.KeyCode == Enum.KeyCode.Escape then
                    Colorpicker:Close()
                end
            end)
            table.insert(unwrap(States.Library).Connections, escapeConnection)
            
            -- Track position changes of the visualizer
            local positionConnection = unwrap(Visualize):GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
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
end)() end,
    function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera

-- < Utils >
local animate = require("utils/animate")
local colorUtils = require("utils/color3")
local unwrap = require("utils/unwrap")
local insertItem = require("utils/insertitem")
local safeCallback = require("utils/safecallback")

-- < Packages >
local Fusion = require("packages/fusion")
local Snapdragon = require("packages/snapdragon")
local States = require("packages/states")

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local ForValues = Fusion.ForValues
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

function Element:New(Idx, props)
	local Dropdown = {
		Values = props.Values,
		Value = props.Default,
		Multi = props.Multi,
		Buttons = {},
		Opened = Value(false),
		Callback = props.Callback or function(_) end,
		Type = "Dropdown",
		Changed = function(_) end,
	}

	local DropdownInner = Value()
	local DropdownHolder = Value()
	local DropdownHolderListLayout = Value()
	local DropdownDisplay = Value()

	local function onOpened(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dropdown.Opened:set(not Dropdown.Opened:get())
		end
	end

	local function RecalculateListPosition()
		local innerPosition = unwrap(DropdownInner).AbsolutePosition
		local innerSize = unwrap(DropdownInner).AbsoluteSize
		local holder = unwrap(DropdownHolder)

		-- Position the holder directly below the inner with a small offset
		holder.Position = UDim2.fromOffset(innerPosition.X, innerPosition.Y + innerSize.Y + 5)
	end

	local function ContinuousPositionCalculation()
		while Dropdown.Opened:get() do
			RecalculateListPosition()
			task.wait()
		end
	end

	local function RecalculateListSize()
		if #Dropdown.Values > 10 then
			--unwrap(DropdownHolder).Size = UDim2.fromOffset(200, 392)
			return 350
		else
			--unwrap(DropdownHolder).Size = UDim2.fromOffset(200, unwrap(DropdownHolderListLayout).AbsoluteContentSize.Y + 10)
			return unwrap(DropdownHolderListLayout).AbsoluteContentSize.Y + 10
		end
	end

	local function RecalculateCanvasSize()
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

	Dropdown.Holder = New("ScrollingFrame")({
		[Ref] = DropdownHolder,

		Name = "Frame",
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
			New("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 2),
			}),

			New("UIStroke")({
				Name = "UIStroke",
				Color = Theme.stroke,
				Transparency = animate(function()
					local state = Dropdown.Opened:get()
					if state then
						return 0
					end
					return 1
				end, 15, 1),
			}),

			New("UIListLayout")({
				[Ref] = DropdownHolderListLayout,

				Name = "UIListLayout",
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			New("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
			}),

			New("UISizeConstraint")({
				Name = "UISizeConstraint",
				MinSize = Vector2.new(200, 0),
			}),
		},
	})

	Dropdown.Root = New("Frame")({
		Name = "Dropdown",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0),

		[Children] = {
			New("Frame")({
				Name = "Addons",
				AnchorPoint = Vector2.new(1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0, 1),

				[Children] = {
					New("UIListLayout")({
						Name = "UIListLayout",
						Padding = UDim.new(0, 15),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					New("TextButton")({
						[Ref] = DropdownInner,

						Name = "Interact",
						FontFace = Font.new("rbxassetid://12187365364"),
						Text = "",
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
							New("UICorner")({
								Name = "UICorner",
								CornerRadius = UDim.new(0, 2),
							}),

							New("ImageLabel")({
								Name = "Icon",
								Image = "rbxassetid://88197529571865",
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

							New("UIStroke")({
								Name = "UIStroke",
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Theme.stroke,
							}),

							New("TextLabel")({
								[Ref] = DropdownDisplay,
								Name = "Values",
								FontFace = Font.new("rbxassetid://12187365364"),
								Text = "--",
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
						[OnEvent("InputEnded")] = onOpened,
					}),
				},
			}),

			New("Frame")({
				Name = "TextHolder",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, -190, 1, 0),

				[Children] = {
					New("TextLabel")({
						Name = "Title",
						FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
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

					New("UIListLayout")({
						Name = "UIListLayout",
						Padding = UDim.new(0, 5),
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Computed(function()
						if props.Description then
							return New("TextLabel")({
								Name = "Description",
								FontFace = Font.new("rbxassetid://12187365364"),
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
		local Str = ""

		if Dropdown.Multi then
			for Idx, Value in next, Values do
				if Dropdown.Value[Value] then
					Str = Str .. Value .. ", "
				end
			end
			Str = Str:sub(1, #Str - 2)
		else
			Str = Dropdown.Value or ""
		end

		unwrap(DropdownDisplay).Text = (Str == "" and "--" or Str)
	end

	function Dropdown:BuildDropdownList()
		local Values = Dropdown.Values
		local Buttons = {}

		for _, Element in next, unwrap(DropdownHolder):GetChildren() do
			if Element:IsA("TextButton") then
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

			local Button = New("TextButton")({
				Name = "OptionButton",
				FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text = Value1, -- Use the value as button text
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
					New("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 2),
					}),

					New("UIPadding")({
						Name = "UIPadding",
						PaddingLeft = UDim.new(0, 5),
					}),
				},

				[OnEvent("InputBegan")] = function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
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

	local DropCon = UserInputService.InputBegan:Connect(function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			local AbsPos, AbsSize = unwrap(DropdownHolder).AbsolutePosition, unwrap(DropdownHolder).AbsoluteSize
			if
				Dropdown.Opened:get()
				and (
					UserInputService:GetMouseLocation().X < AbsPos.X
					or UserInputService:GetMouseLocation().X > AbsPos.X + AbsSize.X
					or UserInputService:GetMouseLocation().Y < AbsPos.Y
				)
			then
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

	if type(props.Default) == "string" then
		local Idx = table.find(Dropdown.Values, props.Default)
		if Idx then
			table.insert(Defaults, Idx)
		end
	elseif type(props.Default) == "table" then
		for _, Value in next, props.Default do
			local Idx = table.find(Dropdown.Values, Value)
			if Idx then
				table.insert(Defaults, Idx)
			end
		end
	elseif type(props.Default) == "number" and Dropdown.Values[props.Default] ~= nil then
		table.insert(Defaults, props.Default)
	end

	if next(Defaults) then
		for i = 1, #Defaults do
			local Index = Defaults[i]
			if Dropdown.Multi then
				Dropdown.Value[Dropdown.Values[Index]] = true
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

--[[]]

end)() end,
    function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)--[[
    input.lua
]]

-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

-- < Types >
type InputProps = {
	Title: string,
    Description: string?,
    Default: string?,
    Numeric: boolean?,
    Finished: boolean?,
    Placeholder: string?,
    Callback: (...any) -> ...any?,
}

local Element = {}
Element.__index = Element
Element.__type = "Input"

function Element:New(Idx, props: InputProps)
    local Input = {
		Value = props.Default or "",
		Numeric = props.Numeric or false,
		Finished = props.Finished or false,
		Callback = props.Callback or function() end,
        Placeholder = props.Placeholder or "...",
		Type = "Input",
        Changed = function(_) end,
    }

    local Box = Value()
    local isFocused = Value(false)

    Input.Root = New "Frame" {
        Name = "Textbox",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0),
    
        [Children] = {
            New "Frame" {
                Name = "Addons",
                AnchorPoint = Vector2.new(1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.fromScale(0, 1),
    
                [Children] = {
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 15),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    },
    
                    New "Frame" {
                        Name = "Holder",
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Theme.background,
                        BackgroundTransparency = 0,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Size = UDim2.fromScale(0, 1),
    
                        [Children] = {
                            New "TextBox" {
                                [Ref] = Box,

                                Name = "Input",
                                FontFace = Font.new(
                                    "rbxassetid://12187365364",
                                    Enum.FontWeight.Regular,
                                    Enum.FontStyle.Normal
                                ),
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
                                    --[[New "UISizeConstraint" {
                                        Name = "UISizeConstraint",
                                        MaxSize = Vector2.new(200, math.huge),
                                        MinSize = Vector2.new(10, 0),
                                    },]]

                                    New "UIPadding" {
                                        Name = "UIPadding",
                                        PaddingLeft = UDim.new(0, 10),
                                    }
                                },

                                [OnEvent("Focused")] = function()
                                    isFocused:set(true)
                                end,

                                [OnEvent("FocusLost")] = function()
                                    isFocused:set(false)
                                end

                            },
    
                            New "UIListLayout" {
                                Name = "UIListLayout",
                                FillDirection = Enum.FillDirection.Horizontal,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                            },
    
                            New "UIStroke" {
                                Name = "UIStroke",
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                                Color = Theme.stroke,
                            },
    
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0, 2),
                            },
    
                            New "UIPadding" {
                                Name = "UIPadding",
                                PaddingRight = UDim.new(0, 10),
                            },
                        }
                    },
                }
            },
    
            New "Frame" {
                Name = "TextHolder",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -80, 1, 0),
    
                [Children] = {
                    New "TextLabel" {
                        Name = "Title",
                        FontFace = Font.new(
                            "rbxassetid://12187365364",
                            Enum.FontWeight.Medium,
                            Enum.FontStyle.Normal
                        ),
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
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 5),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
    
                    Computed(function()
                        if props.Description then
                            return New "TextLabel" {
                                Name = "Description",
                                FontFace = Font.new("rbxassetid://12187365364"),
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
                    end, Fusion.cleanup)
                }
            },
        }
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
		local Con = unwrap(Box):GetPropertyChangedSignal("Text"):Connect(function()
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
end)() end,
    function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)--[[
    keybind.lua
]]

local UserInputService = game:GetService("UserInputService")

-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

-- < Types >
type KeybindProps = {
	Title: string,
	Description: string?,
	Default: boolean?,
	Callback: (...any) -> ...any?,
	Mode: string?,
}

local Element = {}
Element.__index = Element
Element.__type = "Keybind"

function Element:New(Idx, props: KeybindProps)
	local Keybind = {
		Value = props.Default,
		Toggled = false,
		Mode = props.Mode or "Toggle",
		Type = "Keybind",
		Callback = props.Callback or function(_) end,
		Changed = function(_) end,
		Clicked = function(_) end,
	}

	local Picking = Value(false)
	local KeybindDisplay = Value()

	Keybind.Root = New("Frame")({
		Name = "Keybind",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0),

		[Children] = {
			New("Frame")({
				Name = "Addons",
				AnchorPoint = Vector2.new(1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0, 1),

				[Children] = {
					New("UIListLayout")({
						Name = "UIListLayout",
						Padding = UDim.new(0, 15),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					New("TextButton")({
						[Ref] = KeybindDisplay,
						Name = "Interact",
						FontFace = Font.new("rbxassetid://12187365364"),
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
							New("UICorner")({
								Name = "UICorner",
								CornerRadius = UDim.new(0, 2),
							}),

							New("UIStroke")({
								Name = "UIStroke",
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Theme.stroke,
							}),

							New("UIPadding")({
								Name = "UIPadding",
								PaddingLeft = UDim.new(0, 11),
								PaddingRight = UDim.new(0, 10),
							}),
						},

						[OnEvent("InputBegan")] = function(Input)
							if
								Input.UserInputType == Enum.UserInputType.MouseButton1
								or Input.UserInputType == Enum.UserInputType.Touch
							then
								local Display = unwrap(KeybindDisplay)
								if not Display then
									return
								end
								Picking:set(true)
								Display.Text = "..."

								task.wait(0.2)

								local Event
								Event = UserInputService.InputBegan:Connect(function(Input)
									local Key

									if Input.UserInputType == Enum.UserInputType.Keyboard then
										Key = Input.KeyCode.Name
									elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
										Key = "MouseLeft"
									elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
										Key = "MouseRight"
									end

									local EndedEvent
									EndedEvent = UserInputService.InputEnded:Connect(function(Input)
										if
											Input.KeyCode.Name == Key
											or Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
											or Key == "MouseRight"
												and Input.UserInputType == Enum.UserInputType.MouseButton2
										then
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

			New("Frame")({
				Name = "TextHolder",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, -80, 1, 0),

				[Children] = {
					New("TextLabel")({
						Name = "Title",
						FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
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

					New("UIListLayout")({
						Name = "UIListLayout",
						Padding = UDim.new(0, 5),
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Computed(function()
						if props.Description then
							return New("TextLabel")({
								Name = "Description",
								FontFace = Font.new("rbxassetid://12187365364"),
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
		if UserInputService:GetFocusedTextBox() and Keybind.Mode ~= "Always" then
			return false
		end

		if Keybind.Mode == "Always" then
			return true
		elseif Keybind.Mode == "Hold" then
			if Keybind.Value == "None" then
				return false
			end

			local Key = Keybind.Value

			if Key == "MouseLeft" or Key == "MouseRight" then
				return Key == "MouseLeft" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
					or Key == "MouseRight"
						and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
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

	table.insert(
		unwrap(States.Library).Connections,
		UserInputService.InputBegan:Connect(function(Input)
			if not Picking:get() and not UserInputService:GetFocusedTextBox() then
				if Keybind.Mode == "Toggle" then
					local Key = Keybind.Value

					if Key == "MouseLeft" or Key == "MouseRight" then
						if
							Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
							or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2
						then
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
		end)
	)

	insertItem(self.Container, Keybind.Root)
	unwrap(States.Library).Options[Idx] = Keybind

	return Keybind
end

return Element

end)() end,
    function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

-- < Types >
type RadioGroupProps = {
    Title: string,
    Options: {string},
    Default: string?,
    Callback: (...any) -> ...any?,
}

local Element = {}
Element.__index = Element
Element.__type = "Radio"

function Element:New(Idx, props: RadioGroupProps)
    local RadioGroup = {
        Title = props.Title,
        Options = props.Options,
        Default = props.Default or props.Options[1],
        Callback = props.Callback or function() end,
        Changed = function() end,
    }

    local selectedOption = Value(RadioGroup.Default)

    RadioGroup.Root = New "Frame" {
        Name = "RadioGroup",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0),

        [Children] = {
            New "TextLabel" {
                Name = "Title",
                Text = RadioGroup.Title,
                FontFace = Font.new(
                    "rbxassetid://12187365364",
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                ),
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

            New "UIListLayout" {
                Name = "UIListLayout",
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
            },

            ForPairs(RadioGroup.Options, function(index, option)
                return index, New "TextButton" {
                    Name = "RadioButton",
                    Text = option,
                    FontFace = Font.new(
                        "rbxassetid://12187365364",
                        Enum.FontWeight.Medium,
                        Enum.FontStyle.Normal
                    ),
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
                        New "UICorner" {
                            Name = "UICorner",
                            CornerRadius = UDim.new(0, 2),
                        },

                        New "UIStroke" {
                            Name = "UIStroke",
                            Color = Theme.stroke,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        },
                        
                        New "UIPadding" {
                            Name = "UIPadding",
                            PaddingLeft = UDim.new(0, 11),
                        },

                        New "ImageLabel" {
                            Name = "RadioIcon",
                            Image = "rbxassetid://128735638309771",
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

                    [OnEvent("Activated")] = function()
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
end)() end,
    function()local wax,script,require=ImportGlobals(9)local ImportGlobals return (function(...)-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

local Element = {}
Element.__index = Element
Element.__type = "Seperator"

function Element:New()
	local Seperator = {}
	Seperator.Root = New("Frame")({
		Name = "Seperator",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Interactable = false,
		Size = UDim2.new(1, 0, 0, 0),

		[Children] = {
			New("Frame")({
				Name = "Frame",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Theme.stroke,
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(1, 0, 0, 0),
				[Children] = {
					New("UIStroke")({
						Name = "UIStroke",
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

end)() end,
    function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)--[[
    slider.lua
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- < Utils >
local animate = require("utils/animate")
local colorUtils = require("utils/color3")
local unwrap = require("utils/unwrap")
local insertItem = require("utils/insertitem")
local safeCallback = require("utils/safecallback")

-- < Packages >
local Fusion = require("packages/fusion")
local Snapdragon = require("packages/snapdragon")
local States = require("packages/states")

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

-- < Types >
type SliderProps = {
	Title: string,
	Description: string?,
	Default: boolean?,
	Callback: (...any) -> ...any?,
	Rounding: number?,
}

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, props: SliderProps)
	local Slider = {
		Title = props.Title,
		Suffix = props.Suffix or "",
		Default = props.Default,
		Min = props.Min,
		Max = props.Max,
		Value = props.Default or props.Min,
		Rounding = props.Rounding or 0,
		Type = "Slider",
		Callback = props.Callback or function() end,
		Changed = function() end,
	}

	local function roundValue(value, decimalPlaces)
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

	Slider.Root = New("Frame")({
		Name = "Slider",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0),

		[Children] = {
			New("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			New("Frame")({
				[Ref] = barRef,
				Name = "Bar",
				BackgroundColor3 = Theme.secondary_background,
				BorderSizePixel = 0,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0, 0.6),
				Size = UDim2.new(1, 0, 0, 5),

				[Children] = {
					New("UIStroke")({
						Name = "UIStroke",
						Color = Theme.stroke,
					}),

					New("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 2),
					}),

					New("Frame")({
						Name = "Progress",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Theme.accent,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0, 0.5),
						Size = animate(function()
							return barSize:get()
						end, 40, 1),

						[Children] = {
							New("UIStroke")({
								Name = "UIStroke",
								Color = Theme.stroke,
							}),

							New("UICorner")({
								Name = "UICorner",
								CornerRadius = UDim.new(0, 2),
							}),

							New("Frame")({
								Name = "Drag",
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
									New("UICorner")({
										Name = "UICorner",
										CornerRadius = UDim.new(1, 0),
									}),
								},

								[OnEvent("MouseEnter")] = function()
									isHoveringCircle:set(true)
								end,
								[OnEvent("MouseLeave")] = function()
									isHoveringCircle:set(false)
								end,
							}),
						},
					}),
				},

				[OnEvent("InputBegan")] = function(inputObject)
					if
						inputObject.UserInputType == Enum.UserInputType.MouseButton1
						or inputObject.UserInputType == Enum.UserInputType.Touch
					then
						isGrabbing:set(true)
					end
				end,

				[OnEvent("InputEnded")] = function(inputObject)
					if
						inputObject.UserInputType == Enum.UserInputType.MouseButton1
						or inputObject.UserInputType == Enum.UserInputType.Touch
					then
						isGrabbing:set(false)
					end
				end,
			}),

			New("Frame")({
				Name = "TextHolder",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0),

				[Children] = {
					New("Frame")({
						Name = "Text",
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.fromScale(1, 0),

						[Children] = {
							New("TextLabel")({
								Name = "Title",
								FontFace = Font.new(
									"rbxassetid://12187365364",
									Enum.FontWeight.Medium,
									Enum.FontStyle.Normal
								),
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
									return New("TextLabel")({
										Name = "Description",
										FontFace = Font.new("rbxassetid://12187365364"),
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
										Size = UDim2.new(1, -50, 0, 0),
										Visible = true,
									})
								end
								return
							end, Fusion.cleanup),

							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0, 5),
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
						},
					}),

					New("TextLabel")({
						Name = "Title",
						FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
						Text = Computed(function()
							local value = unwrap(numberValue)
							local formattedValue =
								string.format("%." .. Slider.Rounding .. "f", roundValue(value, Slider.Rounding))

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

		[OnEvent("InputBegan")] = function(inputObject)
			if
				inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch
			then
				isGrabbing:set(true)
			end
		end,

		[OnEvent("InputEnded")] = function(inputObject)
			if
				inputObject.UserInputType == Enum.UserInputType.MouseButton1
				or inputObject.UserInputType == Enum.UserInputType.Touch
			then
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

end)() end,
    function()local wax,script,require=ImportGlobals(11)local ImportGlobals return (function(...)--[[
    Table.lua
]]

-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

-- < Types >
type TableProps = {
	Title: string,
    Description: string?,
    Default: string?,
    Callback: (...any) -> ...any?,
}

local Element = {}
Element.__index = Element
Element.__type = "Table"

function Element:New(Idx, props: TableProps)
    local Table = {
        Headers = props.Headers or {},
        Rows = props.Rows or {},
		Type = "Table",
    }

    local Headers = Value({})
    local Rows = Value({})

    local Top = Value()

    Table.Root = New "Frame" {
        Name = "Table",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0),
    
        [Children] = {
            New "Frame" {
                Name = "TextHolder",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
    
                [Children] = {
                    New "TextLabel" {
                        Name = "Title",
                        FontFace = Font.new(
                            "rbxassetid://12187365364",
                            Enum.FontWeight.Medium,
                            Enum.FontStyle.Normal
                        ),
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
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 5),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
    
                    Computed(function()
                        if props.Description then
                            return New "TextLabel" {
                                Name = "Description",
                                FontFace = Font.new("rbxassetid://12187365364"),
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
                    end, Fusion.cleanup)
                }
            },
    
            New "UIListLayout" {
                Name = "UIListLayout",
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
            },
    
            New "Frame" {
                Name = "Holder",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.secondary_background,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 0),
    
                [Children] = {
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Theme.stroke,
                    },
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
    
                    New "Frame" {
                        [Ref] = Top,

                        Name = "Top",
                        BackgroundColor3 = Theme.background,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        LayoutOrder = -1,
                        Size = UDim2.new(1, 0, 0, 30),
    
                        [Children] = {
                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Theme.stroke,
                            },

                            New "UIListLayout" {
                                Name = "UIListLayout",
                                FillDirection = Enum.FillDirection.Horizontal,
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            },

                            ForPairs(Headers, function(index, value)
                                return index, value
                            end, Fusion.cleanup)
                        }
                    },
    
                    New "Frame" {
                        Name = "Entry",
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        [Children] = {
                            New "UIListLayout" {
                                Name = "UIListLayout",
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            },

                            ForPairs(Rows, function(index, value)
                                return index, value
                            end, Fusion.cleanup)
                        }
                    },
                }
            },
        }
    }

    function Table:Render()
        Headers:set({})
        Rows:set({})

        for _,v in next, Table.Headers do
            local Header = New "Frame" {
                Name = "Header",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = Computed(function()
                    return UDim2.new(1 / #unwrap(Headers), 0, 1, 0)
                end),
            
                [Children] = {
                    New "Frame" {
                        Name = "UIStroke",
                        BackgroundColor3 = Theme.stroke,
                        Size = UDim2.new(0, 1, 1, 0),
                        Position = UDim2.fromScale(1, 0)
                    },
            
                    New "TextLabel" {
                        Name = "Title",
                        FontFace = Font.new(
                            "rbxassetid://12187365364",
                            Enum.FontWeight.Medium,
                            Enum.FontStyle.Normal
                        ),
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
                            New "UIPadding" {
                                Name = "UIPadding",
                                PaddingLeft = UDim.new(0, 10),
                            },
                        }
                    },
                }
            }

            insertItem(Headers, Header)
        end

        for _,v in next, Table.Rows do
            local Entries = Value({})

            local alternateBackground = Value(false)
            if props.AlternateBackground and #unwrap(Rows) % 2 == 1 then
                alternateBackground:set(true)
            end

            local Row = New "Frame" {
                Name = "Row",
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
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Theme.stroke,
                    },

                    New "UIListLayout" {
                        Name = "UIListLayout",
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },

                    ForPairs(Entries, function(index, value)
                        return index, value
                    end, Fusion.cleanup)
                }
            }
            for _, Data in next, v do
                local Entry = New "Frame" {
                    Name = "Entry",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = Computed(function()
                        return UDim2.new(1 / #unwrap(Headers), 0, 1, 0)
                    end),
                
                    [Children] = {
                        New "Frame" {
                            Name = "UIStroke",
                            BackgroundColor3 = Theme.stroke,
                            Size = UDim2.new(0, 1, 1, 0),
                            Position = UDim2.fromScale(1, 0)
                        },
                
                        New "TextLabel" {
                            Name = "Title",
                            FontFace = Font.new(
                                "rbxassetid://12187365364",
                                Enum.FontWeight.Medium,
                                Enum.FontStyle.Normal
                            ),
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
                                New "UIPadding" {
                                    Name = "UIPadding",
                                    PaddingLeft = UDim.new(0, 10),
                                },
                            }
                        },
                    }
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
end)() end,
    function()local wax,script,require=ImportGlobals(12)local ImportGlobals return (function(...)--[[
    toggle.lua
]]

-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

-- < Types >
type ToggleProps = {
	Title: string,
	Description: string?,
}

local Element = {}
Element.__index = Element
Element.__type = "Text"

function Element:New(props: ToggleProps)
	local Toggle = {
		Title = Value(props.Title) or nil,
		Description = Value(props.Description) or nil,
	}

	Toggle.Root = New("Frame")({
		Name = "Text",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),

		[Children] = {
			New("Frame")({
				Name = "TextHolder",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, -80, 1, 0),

				[Children] = {
					Computed(function()
						if Toggle.Title then
							return New("TextLabel")({
								Name = "Title",
								FontFace = Font.new(
									"rbxassetid://12187365364",
									Enum.FontWeight.Medium,
									Enum.FontStyle.Normal
								),
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

					New("UIListLayout")({
						Name = "UIListLayout",
						Padding = UDim.new(0, 5),
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),

					Computed(function()
						if Toggle.Description then
							return New("TextLabel")({
								Name = "Description",
								FontFace = Font.new("rbxassetid://12187365364"),
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

end)() end,
    function()local wax,script,require=ImportGlobals(13)local ImportGlobals return (function(...)--[[
    toggle.lua
]]


-- < Utils >
local Utils = script.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.storage.theme)

-- < Types >
type ToggleProps = {
	Title: string,
    Description: string?,
    Default: boolean?,
    Callback: (...any) -> ...any?,
}

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

function Element:New(Idx, props: ToggleProps)
    local Toggle = {
        Value = props.Default or false,
        Callback = props.Callback or function(_) end,
        Type = "Toggle",
        Changed = function(_) end,
    }

    local isToggled = Value()

	Toggle.Root = New "Frame" {
        Name = props.Title,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
    
        [Children] = {
            New "Frame" {
                Name = "Addons",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.fromScale(0, 1),
    
                [Children] = {
                    New "ImageButton" {
                        Name = "Checkbox",
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
                            New "UICorner" {
                                Name = "UICorner",
                                CornerRadius = UDim.new(0, 2),
                            },

                            New "UIStroke" {
                                Name = "UIStroke",
                                Color = Theme.stroke,
                                Enabled = Computed(function()
                                    if not isToggled:get() then 
                                        return true
                                    end
                                    return false
                                end),
                            },
    
                            New "ImageLabel" {
                                Name = "ImageLabel",
                                Image = "rbxassetid://128735638309771",
                                ImageColor3 = Color3.fromRGB(0, 0, 0),
                                ImageTransparency = animate(function()
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

                        [OnEvent("InputEnded")] = function(Input)
                            if
                            Input.UserInputType == Enum.UserInputType.MouseButton1
                            or Input.UserInputType == Enum.UserInputType.Touch
                        then
                            Toggle:SetValue(not isToggled:get())
                        end
                        end,
                    },
    
                    --[[New "ImageButton" {
                        Name = "ImageButton",
                        Image = "rbxassetid://86391022976797",
                        ImageColor3 = Color3.fromRGB(72, 77, 89),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromOffset(16, 16),
                    },]]
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 15),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    },
                }
            },
    
            New "Frame" {
                Name = "TextHolder",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -80, 1, 0),
    
                [Children] = {
                    New "TextLabel" {
                        Name = "Title",
                        FontFace = Font.new(
                            "rbxassetid://12187365364",
                            Enum.FontWeight.Medium,
                            Enum.FontStyle.Normal
                        ),
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
    
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 5),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    },
    
                    Computed(function()
                        if props.Description then
                            return New "TextLabel" {
                                Name = "Description",
                                FontFace = Font.new("rbxassetid://12187365364"),
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
                    end, Fusion.cleanup)
                }
            },
        },

        [OnEvent("InputEnded")] = function(Input)
            if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
            Toggle:SetValue(not isToggled:get())
		end
        end,
    }

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
        Func(Toggle.Value)
    end

    function Toggle:SetValue(v: boolean)
        Toggle.Value = v
        isToggled:set(v)
    end

    function Toggle:GetValue()
        return Toggle.Value
    end

    Toggle:SetValue(Toggle.Value)
    local onToggleObserver = Observer(isToggled); onToggleObserver:onChange(function()
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
end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals return (function(...)-- < Utils >
local Utils = script.Parent.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.Parent.storage.theme)

-- < Types >
type CategoryProps = {
	Title: string,
	Order: number,
}

return function(props: CategoryProps)
	local Category = {
		Tabs = Value({}),
		Collapsed = Value(false),
		ExpandedHeight = Value(0), -- We will compute this based on the content
	}

	local computedHeight = animate(function()
		return Category.Collapsed:get() and UDim2.new(1, 0, 0, 40)
			or UDim2.new(1, 0, 0, unwrap(Category.ExpandedHeight) + 42)
	end, 50, 1)

	local ListLayout = Value()

	-- Root frame for the category
	Category.Root = New("Frame")({
		Name = "Section",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		LayoutOrder = props.Order,
		Size = computedHeight,
		ClipsDescendants = true,

		[Children] = {
			New("Frame")({
				Name = "Title",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 40),

				[Children] = {
					New("TextLabel")({
						Name = "TextLabel",
						FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
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

					New("ImageButton")({
						Name = "Collapse",
						Image = "rbxassetid://107640924738262",
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

						[OnEvent("MouseButton1Click")] = function()
							Category.Collapsed:set(not Category.Collapsed:get())
						end,
					}),
				},
			}),

			New("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			New("Frame")({
				Name = "Holder",
				-- No AutomaticSize, controlled manually
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 0),

				[Children] = {
					New("UIListLayout")({
						[Ref] = ListLayout,
						Name = "UIListLayout",
						Padding = UDim.new(0, 13),
						SortOrder = Enum.SortOrder.LayoutOrder,
						[OnChange("AbsoluteContentSize")] = function(newSize)
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

end)() end,
    [18] = function()local wax,script,require=ImportGlobals(18)local ImportGlobals return (function(...)local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera

-- < Utils >
local Utils = script.Parent.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)
local safeCallback = require(Utils.safecallback)

-- < Packages >
local Packages = script.Parent.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)


-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local ForValues = Fusion.ForValues
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
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

    Dialog.Root = New "TextButton" {
        Name = "Modal",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = animate(function()
            if Dialog.Opened:get() then return 0.5 end
            return 1
        end, 40, 1),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 10,
        Parent = Module.Window,
    
        [Children] = {
            New "Frame" {
                [Ref] = Canvas,
                Name = "Canvas",
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.secondary_background,
                BackgroundTransparency = animate(function()
                    if Dialog.Opened:get() then return 0 end
                    return 1
                end, 40, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(500, 0),
    
                [Children] = {
                    New "Frame" {
                        Name = "Holder",
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
    
                        [Children] = {
                            New "Frame" {
                                Name = "TextHolder",
                                AutomaticSize = Enum.AutomaticSize.Y,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 0),
    
                                [Children] = {
                                    New "UIListLayout" {
                                        Name = "UIListLayout",
                                        Padding = UDim.new(0, 5),
                                        SortOrder = Enum.SortOrder.LayoutOrder,
                                    },
    
                                    New "UIPadding" {
                                        Name = "UIPadding",
                                        PaddingLeft = UDim.new(0, 20),
                                        PaddingTop = UDim.new(0, 20),
                                    },
    
                                    New "TextLabel" {
                                        Name = "TextLabel",
                                        FontFace = Font.new(
                                            "rbxassetid://12187365364",
                                            Enum.FontWeight.Medium,
                                            Enum.FontStyle.Normal
                                        ),
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
                                        TextTransparency = animate(function()
                                            if Dialog.Opened:get() then return 0 end
                                            return 1
                                        end, 40, 1),
                                    },
    
                                    New "TextLabel" {
                                        Name = "Description",
                                        FontFace = Font.new("rbxassetid://12187365364"),
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
                                        TextTransparency = animate(function()
                                            if Dialog.Opened:get() then return 0 end
                                            return 1
                                        end, 40, 1),
                                    },
                                }
                            },
    
                            New "Frame" {
                                Name = "Buttons",
                                AnchorPoint = Vector2.new(0, 1),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.fromScale(0, 1),
                                Size = UDim2.new(1, 0, 0, 40),
    
                                [Children] = {
                                    New "Frame" {
                                        Name = "Seperator",
                                        BackgroundTransparency = animate(function()
                                            if Dialog.Opened:get() then return 0 end
                                            return 1
                                        end, 40, 1),
                                        BackgroundColor3 = Theme.stroke,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Position = UDim2.fromOffset(0, 0),
                                        Size = UDim2.new(1, 0, 0, 1),
                                    },
    
                                    New "Frame" {
                                        Name = "Holder",
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                        BackgroundTransparency = 1,
                                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                                        BorderSizePixel = 0,
                                        Size = UDim2.fromScale(1, 1),
    
                                        [Children] = {
                                            New "UIListLayout" {
                                                Name = "UIListLayout",
                                                Padding = UDim.new(0, 5),
                                                FillDirection = Enum.FillDirection.Horizontal,
                                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                                SortOrder = Enum.SortOrder.LayoutOrder,
                                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                            },
    
                                            New "UIPadding" {
                                                Name = "UIPadding",
                                                PaddingRight = UDim.new(0, 10),
                                            },

                                            ForPairs(Dialog.Buttons, function(index, value)
                                                return index, value
                                            end, Fusion.cleanup),
                                        }
                                    },
                                }
                            },
    
                            New "UIListLayout" {
                                Name = "UIListLayout",
                                Padding = UDim.new(0, 15),
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            },
                        }
                    },
    
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0, 4),
                    },
    
                    New "UIStroke" {
                        Name = "UIStroke",
                        Color = Theme.stroke,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Transparency = animate(function()
                            if Dialog.Opened:get() then return 0 end
                            return 1
                        end, 40, 1),
                    },
                }
            },
        }
    }

    function Dialog:AddButton(Config)
        local isHovering = Value(false)
        local isHeldDown = Value(false)

        local Button = New "TextButton" {
            Name = "Frame",
            FontFace = Font.new(
                "rbxassetid://12187365364",
                Enum.FontWeight.Medium,
                Enum.FontStyle.Normal
            ),
            Text = Config.Title,
            AutomaticSize = Enum.AutomaticSize.X,
            TextColor3 = animate(function()
                local state = Config.Style
                if state == "default" then
                    if unwrap(isHovering) and not unwrap(isHeldDown) then
                        return colorUtils.lightenRGB(Theme.tertiary_text:get(), 15)
                    end

                    return Theme.tertiary_text:get()
                elseif state == "primary" then
                    if unwrap(isHovering) and not unwrap(isHeldDown) then
                        return colorUtils.lightenRGB(Theme.text:get(), 15)
                    end

                    return Theme.text:get()
                end
            end, 40, 1),
            TextSize = 14,
            BackgroundTransparency = animate(function()
                if Dialog.Opened:get() then return 0 end
                return 1
            end, 40, 1),
            BackgroundColor3 = animate(function()
                local state = Config.Style
                if state == "default" then
                    if unwrap(isHovering) and not unwrap(isHeldDown) then
                        return colorUtils.darkenRGB(Theme.background:get(), 5)
                    end

                    return Theme.background:get()
                elseif state == "primary" then
                    if unwrap(isHovering) and not unwrap(isHeldDown) then
                        return colorUtils.darkenRGB(Theme.accent:get(), 15)
                    end

                    return Theme.accent:get()
                end
            end, 40, 1),
            TextTransparency = animate(function()
                if Dialog.Opened:get() then return 0 end
                return 1
            end, 40, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(0, 28),

            [Children] = {
                New "UIStroke" {
                    Name = "UIStroke",
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = Theme.stroke,
                    Transparency = animate(function()
                        if Dialog.Opened:get() then return 0 end
                        return 1
                    end, 40, 1),
                },

                New "UICorner" {
                    Name = "UICorner",
                    CornerRadius = UDim.new(0, 4),
                },

                New "UIPadding" {
                    Name = "UIPadding",
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                },
            },

            [OnEvent("InputEnded")] = function(Input)
                if
                Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.Touch
            then
                isHeldDown:set(false)
                safeCallback(function()
                    if Config.Callback ~= nil and typeof(Config.Callback) == "function" then
                        Config.Callback()
                    end
                end)
                Dialog:Close()
            end
            end,

            [OnEvent("InputBegan")] = function(Input)
                if
                Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.Touch
            then
                isHeldDown:set(true)
            end
            end,

            [OnEvent("MouseEnter")] = function()
                isHovering:set(true)
            end,

            [OnEvent("MouseLeave")] = function()
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

    Dialog.Connection = UserInputService.InputBegan:Connect(function(Input)
        if unwrap(Canvas) == nil then
            Dialog.Connection:Disconnect()
        end

		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			local AbsPos, AbsSize = unwrap(Canvas).AbsolutePosition, unwrap(Canvas).AbsoluteSize
			if
                UserInputService:GetMouseLocation().X < AbsPos.X
				or UserInputService:GetMouseLocation().X > AbsPos.X + AbsSize.X
				or UserInputService:GetMouseLocation().Y < (AbsPos.Y - 20 - 1)
				or UserInputService:GetMouseLocation().Y > AbsPos.Y + AbsSize.Y
			then
				Dialog:Close()
			end
		end
    end)
    table.insert(unwrap(States.Library).Connections, Dialog.Connection)

    Dialog.Opened:set(true)
    return Dialog
end

return Module
end)() end,
    [19] = function()local wax,script,require=ImportGlobals(19)local ImportGlobals return (function(...)-- < Utils >
local Utils = script.Parent.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)

-- < Packages >
local Packages = script.Parent.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Components >
--local Scroll = require(script.Parent.scroll)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

local Camera = game:GetService("Workspace").CurrentCamera
--[[
		Position = UDim2.fromOffset(
			Camera.ViewportSize.X / 2 - Config.Size.X.Offset / 2,
			Camera.ViewportSize.Y / 2 - Config.Size.Y.Offset / 2
		),
]]

-- < Theme >
local Theme = require(script.Parent.Parent.Parent.storage.theme)

-- < Types >
type SectionProps = {
	Title: string,
	Order: number,
}

return function(props: SectionProps)
	local Section = {
        Components = Value({})
	}

	Section.Root = New "Frame" {
        Name = "Section",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.secondary_background,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -35, 0, 0),
    
        [Children] = {
            New "UIStroke" {
                Name = "UIStroke",
                Color = Theme.stroke,
            },
    
            New "UIListLayout" {
                Name = "UIListLayout",
                Padding = UDim.new(0, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
            },
    
            New "TextLabel" {
                Name = "Title",
                FontFace = Font.new(
                    "rbxassetid://12187365364",
                    Enum.FontWeight.SemiBold,
                    Enum.FontStyle.Normal
                ),
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
    
            New "UIPadding" {
                Name = "UIPadding",
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 5),
            },
    
            New "Frame" {
                Name = "Holder",
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 0),
    
                [Children] = {
                    New "UIListLayout" {
                        Name = "UIListLayout",
                        Padding = UDim.new(0, 10),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                    },
    
                    New "UIPadding" {
                        Name = "UIPadding",
                        PaddingRight = UDim.new(0, 15),
                        --PaddingBottom = UDim.new(0, 0)
                    },

                    ForPairs(Section.Components, function(index, value)
						return index, value
					end, Fusion.cleanup),
                }
            },
        }
    }

    

	return Section
end
end)() end,
    [20] = function()local wax,script,require=ImportGlobals(20)local ImportGlobals return (function(...)-- < Utils >
local Utils = script.Parent.Parent.Parent.utils
local animate = require(Utils.animate)
local colorUtils = require(Utils.color3)
local unwrap = require(Utils.unwrap)
local insertItem = require(Utils.insertitem)

-- < Packages >
local Packages = script.Parent.Parent.Parent.packages
local Fusion = require(Packages.fusion)
local Snapdragon = require(Packages.snapdragon)
local States = require(Packages.states)

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

-- < Theme >
local Theme = require(script.Parent.Parent.Parent.storage.theme)

-- < Types >
type TabProps = {
	Title: string,
}

return function(props: TabProps)
	local Tab = {
		Selected = Value(false),
		Sections = Value({}),
		nSections = 0,
	}

	local Elements = unwrap(States.Elements)

	local componentHolder = New("ScrollingFrame")({
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
			New("UIPadding")({
				Name = "UIPadding",
				PaddingTop = UDim.new(0, 15),
				PaddingBottom = UDim.new(0, 15),
			}),

			New("UIListLayout")({
				Name = "UIListLayout",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10),
			}),

			ForPairs(Tab.Sections, function(index, value)
				return index, value
			end, Fusion.cleanup),
		},
	})

	Tab.Root = New("TextButton")({
		Name = props.Title,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0),

		[Children] = {
			New("TextLabel")({
				Name = "TextLabel",
				FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
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

			New("Frame")({
				Name = "Indicator",
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
					New("UICorner")({
						Name = "UICorner",
					}),
				},
			}),

			New("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			New("UIPadding")({
				Name = "UIPadding",
				PaddingLeft = UDim.new(0, 15),
			}),
		},

		[OnEvent("MouseButton1Click")] = function()
			Tab:SetValue(true)
		end,
	})

	States.add("Tabs", Tab, props.Title)
	States.add("Containers", componentHolder, props.Title)

	function Tab:SetValue(bool)
		for _, v in pairs(unwrap(States.Tabs)) do
			v.Selected:set(false)
		end

		Tab.Selected:set(bool)
	end

	local SectionModule = require(script.Parent.section)
	function Tab:AddSection(SectionConfig)
		local Section = {}
		Section.Component = SectionModule({ Title = SectionConfig.Title, Order = Tab.nSections })
		Section.Container = Section.Component.Components

		insertItem(Tab.Sections, Section.Component.Root)
		Tab.nSections += 1

		setmetatable(Section, Elements)
		return Section
	end

	return Tab
end

end)() end,
    [21] = function()local wax,script,require=ImportGlobals(21)local ImportGlobals return (function(...)-- < Utils >
local animate = require("../../utils/animate")
local colorUtils = require("../../utils/color3")
local unwrap = require("../../utils/unwrap")
local insertItem = require("../../utils/insertitem")

-- < Packages >
local Fusion = require("../../packages/fusion")
local Snapdragon = require("../../packages/snapdragon")
local States = require("../../packages/states")

-- < Theme >
local Theme = require("../../storage/theme")

-- < Variables >
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs
local Observer = Fusion.Observer
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local Ref = Fusion.Ref
local New = Fusion.New

local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- < Types >
type WindowProps = {
	Title: string,
	Tag: string,
	Size: UDim2,
}

return function(props: WindowProps)
	local Window = {
		Categorys = 1,
	}

	local openedState = Value(false)

	local TopbarRef = Value()

	local ResizeRef = Value()
	local Resizing, ResizePos = Value(), Value()
	local Size = Value({ X = props.Size.X.Offset, Y = props.Size.Y.Offset })
	local SizeTemp = Value({ X = props.Size.X.Offset, Y = props.Size.Y.Offset })

	local MinimizeHovering = Value(false)
	local MinimizeHeldDown = Value(false)

	local CloseHovering = Value(false)
	local CloseHeldDown = Value(false)

	local WindowScale = Value()

	Window.Root = New("Frame")({
		Name = "GUI",
		BackgroundColor3 = Theme.background,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(
			Camera.ViewportSize.X / 2 - props.Size.X.Offset / 2,
			Camera.ViewportSize.Y / 2 - props.Size.Y.Offset / 2
		),
		Size = Computed(function()
			return UDim2.fromOffset(Size:get().X, Size:get().Y)
		end),
		Visible = openedState,
		Active = true,
		Interactable = true,

		[Children] = {
			New("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 4),
			}),

			New("UIStroke")({
				Name = "UIStroke",
				Color = Theme.stroke,
			}),

			New("UIScale")({
				[Ref] = WindowScale,
				Name = "UIScale",
			}),

			New("ImageLabel")({
				Name = "Shadow",
				Image = "rbxassetid://9313765853",
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

			New("Frame")({
				[Ref] = ResizeRef,

				Name = "ResizeFrame",
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(1, 1),
				Size = UDim2.fromOffset(16, 16),

				[OnEvent("InputBegan")] = function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						Resizing:set(true)
						ResizePos:set(input.Position)
					end
				end,
			}),

			New("Frame")({
				[Ref] = TopbarRef,

				Name = "Topbar",
				BackgroundColor3 = Theme.secondary_background,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 45),
				ZIndex = 1,

				[Children] = {
					New("Frame")({
						Name = "Seperator",
						BackgroundColor3 = Theme.stroke,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(0, 0, 1, -1),
						Size = UDim2.new(1, 0, 0, 1),
					}),

					New("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 4),
					}),

					New("Frame")({
						Name = "TextHolder",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(15, 0),
						Size = UDim2.new(1, -15, 1, 0),

						[Children] = {
							New("TextLabel")({
								Name = "Title",
								FontFace = Font.new(
									"rbxassetid://12187365364",
									Enum.FontWeight.Medium,
									Enum.FontStyle.Normal
								),
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

							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0, 7),
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),

							New("Frame")({
								Name = "TagHolder",
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundColor3 = Theme.accent,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Size = UDim2.fromOffset(0, 15),

								[Children] = {
									New("TextLabel")({
										Name = "TagTitle",
										FontFace = Font.new(
											"rbxassetid://12187365364",
											Enum.FontWeight.Medium,
											Enum.FontStyle.Normal
										),
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

									New("UIPadding")({
										Name = "UIPadding",
										PaddingLeft = UDim.new(0, 5),
										PaddingRight = UDim.new(0, 5),
									}),

									New("UICorner")({
										Name = "UICorner",
										CornerRadius = UDim.new(0, 4),
									}),
								},
							}),
						},
					}),

					New("Frame")({
						Name = "ButtonHolder",
						AnchorPoint = Vector2.new(1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.new(1, -15, 0, 0),
						Size = UDim2.new(1, -15, 1, 0),

						[Children] = {
							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0, 10),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Right,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),

							New("ImageButton")({
								Name = "Minimize",
								Image = "rbxassetid://95268421208163",
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

								[OnEvent("InputEnded")] = function(Input)
									if
										Input.UserInputType == Enum.UserInputType.MouseButton1
										or Input.UserInputType == Enum.UserInputType.Touch
									then
										MinimizeHeldDown:set(false)
										Window:Minimize()
									end
								end,

								[OnEvent("InputBegan")] = function(Input)
									if
										Input.UserInputType == Enum.UserInputType.MouseButton1
										or Input.UserInputType == Enum.UserInputType.Touch
									then
										MinimizeHeldDown:set(true)
									end
								end,

								[OnEvent("MouseEnter")] = function()
									MinimizeHovering:set(true)
								end,

								[OnEvent("MouseLeave")] = function()
									MinimizeHovering:set(false)
									MinimizeHeldDown:set(false)
								end,
							}),

							New("ImageButton")({
								Name = "Close",
								Image = "rbxassetid://118425905671666",
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

								[OnEvent("InputEnded")] = function(Input)
									if
										Input.UserInputType == Enum.UserInputType.MouseButton1
										or Input.UserInputType == Enum.UserInputType.Touch
									then
										CloseHeldDown:set(false)
										States.toDestroy:set(true)
									end
								end,

								[OnEvent("InputBegan")] = function(Input)
									if
										Input.UserInputType == Enum.UserInputType.MouseButton1
										or Input.UserInputType == Enum.UserInputType.Touch
									then
										CloseHeldDown:set(true)
									end
								end,

								[OnEvent("MouseEnter")] = function()
									CloseHovering:set(true)
								end,

								[OnEvent("MouseLeave")] = function()
									CloseHovering:set(false)
									CloseHeldDown:set(false)
								end,
							}),
						},
					}),
				},
			}),

			New("Frame")({
				Name = "Tablist",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 45),
				Size = UDim2.new(0, 200, 1, -45),
				ZIndex = 5,

				[Children] = {
					New("ScrollingFrame")({
						Name = "Tablist",
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
							New("UIListLayout")({
								Name = "UIListLayout",
								Padding = UDim.new(0, 10),
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),

							New("UIPadding")({
								Name = "UIPadding",
								PaddingTop = UDim.new(0, 5),
							}),

							ForPairs(States.Categorys, function(index, value)
								return index, value
							end, Fusion.cleanup),
						},
					}),

					New("Frame")({
						Name = "Seperator",
						BackgroundColor3 = Theme.stroke,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.new(0, -1, 1, 0),
					}),
				},
			}),

			New("Frame")({
				Name = "Containers",
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
					ForPairs(States.Containers, function(index, value)
						return index, value
					end, Fusion.cleanup),
				},
			}),
		},
	})

	-- < Resizing handlers >
	UserInputService.InputChanged:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			and Resizing:get()
		then
			local StartSize = UDim2.fromOffset(Size:get().X, Size:get().Y)
			local TargetSize = Vector3.new(StartSize.X.Offset, StartSize.Y.Offset, 0)
				+ Vector3.new(1, 1, 0) * (input.Position - ResizePos:get())
			local TargetSizeClamped =
				Vector2.new(math.clamp(TargetSize.X, 470, 2048), math.clamp(TargetSize.Y, 380, 2048))

			Size:set({ X = TargetSizeClamped.X, Y = TargetSizeClamped.Y })
			ResizePos:set(input.Position)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if Resizing:get() then
				Resizing:set(false)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if
			type(unwrap(States.MinimizeKeybind)) == "table"
			and unwrap(States.MinimizeKeybind).Type == "Keybind"
			and not UserInputService:GetFocusedTextBox()
		then
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
			local Key = unwrap(States.MinimizeKey)
			--[[self.Library:Notify({
				Title = "Interface",
				Content = "Press " .. Key .. " to toggle the interface.",
				Duration = 6
			})]]
		end
	end

	-- < Category handler >
	local CategoryModule = require(script.Parent.category)
	function Window:AddCategory(CategoryConfig)
		local Category = CategoryModule({ Title = CategoryConfig.Title, Order = Window.Categorys })

		States.add("Categorys", Category.Root, CategoryConfig.Title)
		Window.Categorys += 1

		return Category
	end

	-- < Dialog handler >
	local DialogModule = require(script.Parent.dialog)
	DialogModule:init(Window.Root)
	function Window:Dialog(Config)
		local Dialog = DialogModule:Create(Config)
		return Dialog
	end

	function Window:SetScale(Scale)
		unwrap(WindowScale).Scale = Scale
	end

	-- < Window global states >
	States.add("Objects", Window.Root, props.Title)

	-- < Window dragging >
	Snapdragon.createDragController(unwrap(TopbarRef), {
		DragGui = unwrap(Window.Root),
		SnapEnabled = true,
	}):Connect()

	--< Window open / close >
	openedState:set(true)

	--[[exitObserver:onChange(function()
		if unwrap(exitState) then
			Window:Destroy()
		end
	end)]]

	return Window
end

end)() end,
    [22] = function()local wax,script,require=ImportGlobals(22)local ImportGlobals return (function(...)--[[
	File: app.story.lua
	Returns the app component for use with hoarcekat
]]

local Fusion = require(script.Parent.packages.fusion)

local story = {
	fusion = Fusion,
	story = function(props)
		local start = tick()

		local Library = require(script.Parent)

		local Window = Library:CreateWindow({
			Title = "ZEN X",
			Tag = "DEMON HUNTER",
			Size = UDim2.fromOffset(800, 500),
			Parent = props.target,
			Debug = true,
		})

		local Categories = {
			Universal = Window:AddCategory({ Title = "UNIVERSAL" }),
			Settings = Window:AddCategory({ Title = "SETTINGS" }),
			Movement = Window:AddCategory({ Title = "MOVEMENT" }),
			Combat = Window:AddCategory({ Title = "COMBAT" }),
			Misc = Window:AddCategory({ Title = "MISC" }),
			Rage = Window:AddCategory({ Title = "RAGE" }), -- New Category
		}

		local Tabs = {
			-- Universal Tabs
			Aimbot = Categories.Universal:AddTab({ Title = "Aimbot" }),
			TriggerBot = Categories.Universal:AddTab({ Title = "TriggerBot" }),
			Checks = Categories.Universal:AddTab({ Title = "Checks" }),
			Visuals = Categories.Universal:AddTab({ Title = "Visuals" }),

			-- Settings Tabs
			Settings = Categories.Settings:AddTab({ Title = "Settings" }),
			Theme = Categories.Settings:AddTab({ Title = "Theme" }),
			Showcase = Categories.Settings:AddTab({ Title = "Showcase" }), -- New Showcase tab
			Configs = Categories.Settings:AddTab({ Title = "Configs" }), -- New Tab

			-- Movement Tabs
			Speed = Categories.Movement:AddTab({ Title = "Speed" }),
			Flight = Categories.Movement:AddTab({ Title = "Flight" }),
			Teleport = Categories.Movement:AddTab({ Title = "Teleport" }), -- New Tab
			Bhop = Categories.Movement:AddTab({ Title = "Bunny Hop" }), -- New Tab

			-- Combat Tabs
			Weapons = Categories.Combat:AddTab({ Title = "Weapons" }),
			Player = Categories.Combat:AddTab({ Title = "Player" }),
			AutoParry = Categories.Combat:AddTab({ Title = "Auto Parry" }), -- New Tab
			Reach = Categories.Combat:AddTab({ Title = "Reach" }), -- New Tab

			-- Misc Tabs
			World = Categories.Misc:AddTab({ Title = "World" }),
			Exploits = Categories.Misc:AddTab({ Title = "Exploits" }),
			Trolling = Categories.Misc:AddTab({ Title = "Trolling" }), -- New Tab
			Farming = Categories.Misc:AddTab({ Title = "Auto Farm" }), -- New Tab

			-- Rage Tabs
			RageBot = Categories.Rage:AddTab({ Title = "Rage Bot" }), -- New Tab
			AntiAim = Categories.Rage:AddTab({ Title = "Anti Aim" }), -- New Tab
			Resolver = Categories.Rage:AddTab({ Title = "Resolver" }), -- New Tab
		}

		-- Aimbot Tab
		local AimbotSection = Tabs.Aimbot:AddSection({ Title = "AIMBOT" })

		AimbotSection:AddColorpicker("colorpick22er", {
			Title = "oko2k323",
			Description = "Toggles the colorpicker",
			Default = Color3.fromRGB(96, 205, 255),
			Callback = function(value)
				print(value)
			end,
		})

		AimbotSection:AddToggle("AimbotToggle", {
			Title = "Aimbot",
			Description = "Toggles the Aimbot",
			Default = false,
			Callback = function()
				print("Aimbot toggled")
				Window:Dialog({
					Title = "Dialog",
					Description = "This is a dialog",
					Buttons = {
						{
							Title = "Button",
							Callback = function()
								print("Button pressed")
							end,
						},
					},
				})
			end,
		})

		AimbotSection:AddToggle("OnePressModeToggle", {
			Title = "One-Press Mode",
			Description = "Uses the One-Press Mode instead of the Holding Mode",
			Default = false,
			Callback = function()
				print("One-Press Mode toggled")
			end,
		})

		AimbotSection:AddDropdown("AimMode", {
			Title = "Aim Mode",
			Description = "Changes the Aim Mode",
			Values = { "Camera", "Silent" },
			Default = "Camera",
		})

		AimbotSection:AddDropdown("SilentAimMethods", {
			Title = "Silent Aim Methods",
			Description = "Sets the Silent Aim Methods",
			Values = {
				"Mouse.Hit / Mouse.Target",
				"GetMouseLocation",
				"Raycast",
				"FindPartOnRay",
				"FindPartOnRayWithIgnoreList",
				"FindPartOnRayWithWhitelist",
			},
			Multi = true,
			Default = {},
		})

		AimbotSection:AddSlider("SilentAimChance", {
			Title = "Silent Aim Chance",
			Description = "Changes the Hit Chance for Silent Aim",
			Default = 100,
			Min = 1,
			Max = 100,
			Rounding = 1,
		})

		-- Aim Offset Section
		local AimOffsetSection = Tabs.Aimbot:AddSection({ Title = "AIM OFFSET" })

		AimOffsetSection:AddToggle("UseOffsetToggle", {
			Title = "Use Offset",
			Description = "Toggles the Offset",
			Default = false,
			Callback = function()
				print("Use Offset toggled")
			end,
		})

		AimOffsetSection:AddDropdown("OffsetType", {
			Title = "Offset Type",
			Description = "Changes the Offset Type",
			Values = { "Static", "Dynamic", "Static & Dynamic" },
			Default = "Static",
		})

		AimOffsetSection:AddSlider("StaticOffset", {
			Title = "Static Offset",
			Description = "Changes the Static Offset Increment",
			Default = 25,
			Min = 1,
			Max = 50,
			Rounding = 1,
		})

		AimOffsetSection:AddSlider("DynamicOffset", {
			Title = "Dynamic Offset",
			Description = "Changes the Dynamic Offset Increment",
			Default = 25,
			Min = 1,
			Max = 50,
			Rounding = 1,
		})

		-- Checks Tab
		local SimpleChecksSection = Tabs.Checks:AddSection({ Title = "SIMPLE CHECKS" })

		SimpleChecksSection:AddToggle("AliveCheckToggle", {
			Title = "Alive Check",
			Description = "Toggles the Alive Check",
			Default = true,
			Callback = function()
				print("Alive Check toggled")
			end,
		})

		SimpleChecksSection:AddToggle("TeamCheckToggle", {
			Title = "Team Check",
			Description = "Toggles the Team Check",
			Default = true,
			Callback = function()
				print("Team Check toggled")
			end,
		})

		SimpleChecksSection:AddToggle("WallCheckToggle", {
			Title = "Wall Check",
			Description = "Toggles the Wall Check",
			Default = true,
			Callback = function()
				print("Wall Check toggled")
			end,
		})

		SimpleChecksSection:AddToggle("FriendCheckToggle", {
			Title = "Friend Check",
			Description = "Toggles the Friend Check",
			Default = false,
			Callback = function()
				print("Friend Check toggled")
			end,
		})

		-- Advanced Checks Section
		local AdvancedChecksSection = Tabs.Checks:AddSection({ Title = "ADVANCED CHECKS" })

		AdvancedChecksSection:AddToggle("FoVCheckToggle", {
			Title = "FoV Check",
			Description = "Toggles the FoV Check",
			Default = true,
			Callback = function()
				print("FoV Check toggled")
			end,
		})

		AdvancedChecksSection:AddSlider("FoVRadius", {
			Title = "FoV Radius",
			Description = "Changes the FoV Radius",
			Default = 100,
			Min = 10,
			Max = 1000,
			Rounding = 1,
		})

		AdvancedChecksSection:AddToggle("MagnitudeCheckToggle", {
			Title = "Magnitude Check",
			Description = "Toggles the Magnitude Check",
			Default = false,
			Callback = function()
				print("Magnitude Check toggled")
			end,
		})

		-- Visuals Tab
		local FoVSection = Tabs.Visuals:AddSection({ Title = "FOV" })

		FoVSection:AddToggle("ShowFoVToggle", {
			Title = "Show FoV",
			Description = "Graphically Displays the FoV Radius",
			Default = true,
			Callback = function()
				print("Show FoV toggled")
			end,
		})

		FoVSection:AddSlider("FovThickness", {
			Title = "FoV Thickness",
			Description = "Changes the FoV Thickness",
			Default = 1,
			Min = 1,
			Max = 10,
			Rounding = 1,
		})

		FoVSection:AddSlider("FovOpacity", {
			Title = "FoV Opacity",
			Description = "Changes the FoV Opacity",
			Default = 0.5,
			Min = 0.1,
			Max = 1,
			Rounding = 1,
		})

		-- ESP Section
		local ESPSection = Tabs.Visuals:AddSection({ Title = "ESP" })

		ESPSection:AddToggle("ESPToggle", {
			Title = "ESP",
			Description = "Toggles ESP Features",
			Default = false,
			Callback = function()
				print("ESP toggled")
			end,
		})

		ESPSection:AddToggle("BoxESPToggle", {
			Title = "Box ESP",
			Description = "Creates the ESP Box around Players",
			Default = false,
			Callback = function()
				print("Box ESP toggled")
			end,
		})

		ESPSection:AddToggle("NameESPToggle", {
			Title = "Name ESP",
			Description = "Shows Player Names",
			Default = false,
			Callback = function()
				print("Name ESP toggled")
			end,
		})

		ESPSection:AddDropdown("ESPFont", {
			Title = "ESP Font",
			Description = "Changes the ESP Font",
			Values = { "UI", "System", "Plex", "Monospace" },
			Default = "UI",
		})

		-- Settings Tab
		local UISection = Tabs.Settings:AddSection({ Title = "UI SETTINGS" })

		UISection:AddDropdown("Theme", {
			Title = "Theme",
			Description = "Changes the UI Theme",
			Values = { "Default", "Light", "Dark", "Discord" },
			Default = "Default",
		})

		UISection:AddToggle("TransparencyToggle", {
			Title = "Transparency",
			Description = "Makes the UI Transparent",
			Default = false,
			Callback = function()
				print("Transparency toggled")
			end,
		})

		-- Notifications Section
		local NotificationsSection = Tabs.Settings:AddSection({ Title = "NOTIFICATIONS" })

		NotificationsSection:AddToggle("ShowNotificationsToggle", {
			Title = "Show Notifications",
			Description = "Toggles the Notifications Show",
			Default = true,
			Callback = function()
				print("Show Notifications toggled")
			end,
		})

		NotificationsSection:AddToggle("ShowWarningsToggle", {
			Title = "Show Warnings",
			Description = "Toggles the Security Warnings Show",
			Default = true,
			Callback = function()
				print("Show Warnings toggled")
			end,
		})

		-- Configuration Section
		local ConfigSection = Tabs.Settings:AddSection({ Title = "CONFIGURATION" })

		ConfigSection:AddButton({
			Title = "Import Configuration",
			Style = "primary",
			Description = "Load saved configuration",
		})

		ConfigSection:AddButton({
			Title = "Export Configuration",
			Style = "primary",
			Description = "Save current configuration",
		})

		ConfigSection:AddButton({
			Title = "Reset Configuration",
			Style = "primary",
			Description = "Reset to default settings",
		})

		-- Theme Tab
		local ThemeSection = Tabs.Theme:AddSection({ Title = "THEME CUSTOMIZATION" })

		ThemeSection:AddDropdown("ThemePicker", {
			Title = "Theme",
			Description = "Select UI Theme",
			Values = {
				"dark",
				"twilight",
				"shadow",
				"dusk",
				"obsidian",
				"charcoal",
				"slate",
				"onyx",
				"ash",
				"granite",
				"cobalt",
				"aurora",
				"sunset",
				"mocha",
				"abyss",
				"void",
				"noir",
			},
			Default = "noir",
			Callback = function(value)
				Library:SetTheme(value)
			end,
		})

		ThemeSection:AddSlider("UIScale", {
			Title = "UI Scale",
			Description = "Adjusts the UI Size",
			Default = 100,
			Min = 75,
			Max = 150,
			Rounding = 1,
		})

		ThemeSection:AddSlider("BOpacity", {
			Title = "Background Opacity",
			Description = "Adjusts Background Transparency",
			Default = 1,
			Min = 0.1,
			Max = 1,
			Rounding = 1,
		})

		ThemeSection:AddSlider("RainbowSpeed", {
			Title = "Rainbow Speed",
			Description = "Adjusts Rainbow Effect Speed",
			Default = 0.5,
			Min = 0.1,
			Max = 1,
			Rounding = 1,
		})

		-- New Movement Features
		local SpeedSection = Tabs.Speed:AddSection({ Title = "SPEED MODIFICATIONS" })

		SpeedSection:AddToggle("SpeedHackToggle", {
			Title = "Speed Hack",
			Description = "Modifies player movement speed",
			Default = false,
		})

		SpeedSection:AddDropdown("SpeedMode", {
			Title = "Speed Mode",
			Description = "Select speed modification type",
			Values = { "CFrame", "Velocity", "WalkSpeed", "Custom" },
			Default = "CFrame",
		})

		SpeedSection:AddSlider("SpeedMultiplier", {
			Title = "Speed Multiplier",
			Description = "Adjusts speed multiplication factor",
			Default = 2,
			Min = 1,
			Max = 10,
			Rounding = 1,
		})

		-- Flight Features
		local FlightSection = Tabs.Flight:AddSection({ Title = "FLIGHT CONTROLS" })

		FlightSection:AddToggle("FlightToggle", {
			Title = "Flight",
			Description = "Enables player flight",
			Default = false,
		})

		FlightSection:AddDropdown("FlightMode", {
			Title = "Flight Mode",
			Description = "Select flight behavior",
			Values = { "CFrame", "Velocity", "Floating", "Noclip" },
			Default = "CFrame",
		})

		-- Combat Features
		local WeaponsSection = Tabs.Weapons:AddSection({ Title = "WEAPON MODIFICATIONS" })

		WeaponsSection:AddToggle("NoRecoilToggle", {
			Title = "No Recoil",
			Description = "Removes weapon recoil",
			Default = false,
		})

		WeaponsSection:AddToggle("NoSpreadToggle", {
			Title = "No Spread",
			Description = "Removes bullet spread",
			Default = false,
		})

		WeaponsSection:AddSlider("FireRateMultiplier", {
			Title = "Fire Rate Multiplier",
			Description = "Modifies weapon fire rate",
			Default = 1,
			Min = 1,
			Max = 5,
			Rounding = 1,
		})

		-- Player Combat Features
		local PlayerCombatSection = Tabs.Player:AddSection({ Title = "PLAYER COMBAT" })

		PlayerCombatSection:AddToggle("AutoBlockToggle", {
			Title = "Auto Block",
			Description = "Automatically blocks incoming damage",
			Default = false,
		})

		PlayerCombatSection:AddToggle("KillAuraToggle", {
			Title = "Kill Aura",
			Description = "Damages nearby players automatically",
			Default = false,
		})

		PlayerCombatSection:AddSlider("KillAuraRange", {
			Title = "Kill Aura Range",
			Description = "Sets the kill aura radius",
			Default = 10,
			Min = 5,
			Max = 30,
			Rounding = 1,
		})

		-- World Features
		local WorldSection = Tabs.World:AddSection({ Title = "WORLD MODIFICATIONS" })

		WorldSection:AddToggle("FullbrightToggle", {
			Title = "Fullbright",
			Description = "Removes darkness and shadows",
			Default = false,
		})

		WorldSection:AddToggle("XRayToggle", {
			Title = "X-Ray",
			Description = "See through walls",
			Default = false,
		})

		WorldSection:AddDropdown("TimeOfDay", {
			Title = "Time of Day",
			Description = "Changes the lighting",
			Values = { "Day", "Night", "Dawn", "Dusk" },
			Default = "Day",
		})

		-- Exploits Features
		local ExploitsSection = Tabs.Exploits:AddSection({ Title = "GAME EXPLOITS" })

		ExploitsSection:AddToggle("AntiKickToggle", {
			Title = "Anti-Kick",
			Description = "Attempts to prevent kicks",
			Default = false,
		})

		ExploitsSection:AddToggle("AntiCheatBypassToggle", {
			Title = "Anti-Cheat Bypass",
			Description = "Attempts to bypass anti-cheat",
			Default = false,
		})

		ExploitsSection:AddDropdown("BypassMode", {
			Title = "Bypass Mode",
			Description = "Select bypass method",
			Values = { "Basic", "Advanced", "Experimental" },
			Default = "Basic",
		})

		-- Additional ESP Features
		local AdvancedESPSection = Tabs.Visuals:AddSection({ Title = "ADVANCED ESP" })

		AdvancedESPSection:AddToggle("SkeletonESPToggle", {
			Title = "Skeleton ESP",
			Description = "Shows player bone structure",
			Default = false,
		})

		AdvancedESPSection:AddToggle("HealthBarToggle", {
			Title = "Health Bars",
			Description = "Shows player health bars",
			Default = false,
		})

		AdvancedESPSection:AddToggle("ChamsToggle", {
			Title = "Chams",
			Description = "Shows players through walls with custom rendering",
			Default = false,
		})

		AdvancedESPSection:AddDropdown("ChamsStyle", {
			Title = "Chams Style",
			Description = "Changes the chams appearance",
			Values = { "Flat", "Ghost", "Pulse", "Rainbow" },
			Default = "Flat",
		})

		-- Expanded TriggerBot Features
		local TriggerMainSection = Tabs.TriggerBot:AddSection({ Title = "TRIGGERBOT MAIN" })

		TriggerMainSection:AddToggle("TriggerBotToggle", {
			Title = "TriggerBot",
			Description = "Automatically shoots when crosshair is on target",
			Default = false,
		})

		TriggerMainSection:AddDropdown("TriggerMode", {
			Title = "Trigger Mode",
			Description = "Select trigger activation method",
			Values = { "On Hover", "On Key Hold", "Toggle Mode", "Smart Trigger" },
			Default = "On Hover",
		})

		TriggerMainSection:AddSlider("TriggerDelay", {
			Title = "Trigger Delay",
			Description = "Delay before triggering (ms)",
			Default = 100,
			Min = 0,
			Max = 500,
			Rounding = 1,
		})

		local TriggerAdvancedSection = Tabs.TriggerBot:AddSection({ Title = "ADVANCED TRIGGER" })

		TriggerAdvancedSection:AddToggle("SmartPredictionToggle", {
			Title = "Smart Prediction",
			Description = "Predicts target movement for better accuracy",
			Default = false,
		})

		TriggerAdvancedSection:AddToggle("AutoStopToggle", {
			Title = "Auto Stop",
			Description = "Stops movement when triggering for better accuracy",
			Default = false,
		})

		TriggerAdvancedSection:AddToggle("ReactionTimeSimulation", {
			Title = "Reaction Time Simulation",
			Description = "Simulates human reaction time",
			Default = false,
		})

		local TriggerFilterSection = Tabs.TriggerBot:AddSection({ Title = "TRIGGER FILTERS" })

		TriggerFilterSection:AddDropdown("HitboxPriority", {
			Title = "Hitbox Priority",
			Description = "Select priority hitboxes for trigger",
			Values = { "Head", "Upper Torso", "Lower Torso", "Arms", "Legs" },
			Multi = true,
			Default = { "Head", "Upper Torso" },
		})

		TriggerFilterSection:AddToggle("SmartTargetingToggle", {
			Title = "Smart Targeting",
			Description = "Prioritizes targets based on threat level",
			Default = false,
		})

		-- New Auto Parry Features
		local AutoParrySection = Tabs.AutoParry:AddSection({ Title = "AUTO PARRY" })

		AutoParrySection:AddToggle("AutoParryToggle", {
			Title = "Auto Parry",
			Description = "Automatically parries incoming attacks",
			Default = false,
		})

		AutoParrySection:AddDropdown("ParryMode", {
			Title = "Parry Mode",
			Description = "Select parry behavior",
			Values = { "Aggressive", "Defensive", "Balanced", "Custom" },
			Default = "Balanced",
		})

		-- New Reach Features
		local ReachSection = Tabs.Reach:AddSection({ Title = "REACH MODIFICATIONS" })

		ReachSection:AddToggle("ReachToggle", {
			Title = "Reach",
			Description = "Extends attack range",
			Default = false,
		})

		ReachSection:AddSlider("ReachMultiplier", {
			Title = "Reach Multiplier",
			Description = "Adjusts reach distance",
			Default = 1.5,
			Min = 1,
			Max = 4,
			Rounding = 1,
		})

		-- New Rage Bot Features
		local RageBotSection = Tabs.RageBot:AddSection({ Title = "RAGE BOT" })

		RageBotSection:AddToggle("RageBotToggle", {
			Title = "Rage Bot",
			Description = "Enables extreme targeting measures",
			Default = false,
		})

		RageBotSection:AddDropdown("RageTargetingMode", {
			Title = "Targeting Mode",
			Description = "Select targeting behavior",
			Values = { "Closest", "Most Damage", "Random", "Smart" },
			Default = "Closest",
		})

		-- New Anti Aim Features
		local AntiAimSection = Tabs.AntiAim:AddSection({ Title = "ANTI AIM" })

		AntiAimSection:AddToggle("AntiAimToggle", {
			Title = "Anti Aim",
			Description = "Makes you harder to hit",
			Default = false,
		})

		AntiAimSection:AddDropdown("AntiAimType", {
			Title = "Anti Aim Type",
			Description = "Select anti aim behavior",
			Values = { "Spin", "Jitter", "Static", "Random" },
			Default = "Spin",
		})

		-- New Resolver Features
		local ResolverSection = Tabs.Resolver:AddSection({ Title = "RESOLVER" })

		ResolverSection:AddToggle("ResolverToggle", {
			Title = "Resolver",
			Description = "Attempts to resolve anti-aim",
			Default = false,
		})

		ResolverSection:AddDropdown("ResolverMode", {
			Title = "Resolver Mode",
			Description = "Select resolver method",
			Values = { "Brute Force", "Prediction", "Adaptive", "Learning" },
			Default = "Adaptive",
		})

		-- New Trolling Features
		local TrollingSection = Tabs.Trolling:AddSection({ Title = "TROLLING" })

		TrollingSection:AddToggle("VoiceSpamToggle", {
			Title = "Voice Command Spam",
			Description = "Spams voice commands",
			Default = false,
		})

		TrollingSection:AddToggle("EmoteSpamToggle", {
			Title = "Emote Spam",
			Description = "Spams emotes",
			Default = false,
		})

		-- New Auto Farm Features
		local AutoFarmSection = Tabs.Farming:AddSection({ Title = "AUTO FARMING" })

		AutoFarmSection:AddToggle("AutoFarmToggle", {
			Title = "Auto Farm",
			Description = "Automatically farms resources/kills",
			Default = false,
		})

		AutoFarmSection:AddDropdown("FarmingMode", {
			Title = "Farming Mode",
			Description = "Select farming behavior",
			Values = { "XP Farm", "Resource Farm", "Kill Farm", "Custom" },
			Default = "XP Farm",
		})

		-- New Bunny Hop Features
		local BhopSection = Tabs.Bhop:AddSection({ Title = "BUNNY HOP" })

		BhopSection:AddToggle("BhopToggle", {
			Title = "Bunny Hop",
			Description = "Automatically jumps for increased speed",
			Default = false,
		})

		BhopSection:AddDropdown("BhopStyle", {
			Title = "Bhop Style",
			Description = "Select hopping pattern",
			Values = { "Normal", "Rage", "Legit", "Custom" },
			Default = "Normal",
		})

		-- New Teleport Features
		local TeleportSection = Tabs.Teleport:AddSection({ Title = "TELEPORT" })

		TeleportSection:AddButton({
			Title = "Teleport to Spawn",
			Description = "Instantly teleport to spawn point",
			Style = "default",
			Callback = function()
				local Dialog = Window:Dialog({
					Title = "DIALOG",
					Description = "This is the dialog component of the UI Library Kyanos.",
				})
				Dialog:AddButton({ Title = "Go Back", Style = "default" })
				Dialog:AddButton({
					Title = "Continue",
					Style = "primary",
					Callback = function()
						local SecondDialog = Window:Dialog({
							Title = "ANOTHER DIALOG",
							Description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mollis dolor eget erat mattis, id mollis mauris cursus. Proin ornare sollicitudin odio, id posuere diam luctus id.",
						})
						SecondDialog:AddButton({ Title = "OK", Style = "default" })
					end,
				})
			end,
		})

		TeleportSection:AddDropdown("SavedLocations", {
			Title = "Saved Locations",
			Description = "Select location to teleport",
			Values = { "Spawn", "Base", "Shop", "Custom 1", "Custom 2" },
			Default = "Spawn",
		})

		TeleportSection:AddInput("WaypointInput", {
			Title = "Add Waypoint",
			Description = "Add and save a waypoint to teleport to.",
			Default = "Default",
			Placeholder = "Placeholder",
			Numeric = false, -- Only allows numbers
			Finished = false, -- Only calls callback when you press enter
			Callback = function(Value)
				print("Input changed:", Value)
			end,
		})

		local ElementsSection = Tabs.Showcase:AddSection({ Title = "UI ELEMENTS" })

		ElementsSection:AddToggle("ShowcaseToggle", {
			Title = "Toggle Element",
			Description = "Demonstrates the toggle UI element",
			Default = false,
		})

		ElementsSection:AddSlider("ShowcaseSlider", {
			Title = "Slider Element",
			Description = "Demonstrates the slider UI element",
			Default = 50,
			Min = 0,
			Max = 100,
			Increment = 1,
		})

		ElementsSection:AddDropdown("ShowcaseDropdown", {
			Title = "Dropdown Element",
			Description = "Demonstrates the dropdown UI element",
			Values = { "Option 1", "Option 2", "Option 3" },
			Default = "Option 1",
		})

		ElementsSection:AddColorpicker("ShowcaseColorPicker", {
			Title = "Color Picker Element",
			Description = "Demonstrates the color picker UI element",
			Default = Color3.fromRGB(255, 255, 255),
		})

		ElementsSection:AddButton({
			Title = "Button Element",
			Description = "Demonstrates the button UI element",
			Style = "default",
			Callback = function()
				Window:Dialog({
					Title = "Dialog Element",
					Description = "Demonstrates the dialog UI element",
					Buttons = {
						{
							Title = "OK",
							Callback = function() end,
						},
					},
				})
			end,
		})

		ElementsSection:AddInput("ShowcaseInput", {
			Title = "Text Input Element",
			Description = "Demonstrates the text input UI element",
			Default = "Sample text",
			Placeholder = "Type something...",
		})

		ElementsSection:AddKeybind("ShowcaseKeybind", {
			Title = "Keybind Element",
			Description = "Demonstrates the keybind UI element",
			Default = Enum.KeyCode.E,
		})

		ElementsSection:AddButton({
			Title = "Primary Action",
			Style = "primary",
			Description = "Perform primary action",
			Callback = function()
				print("Primary button clicked")
			end,
		})

		ElementsSection:AddButton({
			Title = "Danger Action",
			Style = "danger",
			Description = "Perform dangerous action",
			Callback = function()
				print("Danger button clicked")
			end,
		})

		ElementsSection:AddButton({
			Title = "Warning Action",
			Style = "warning",
			Description = "Perform action with caution",
			Callback = function()
				print("Warning button clicked")
			end,
		})

		ElementsSection:AddButton({
			Title = "Default Action",
			Style = "default",
			Description = "Perform default action",
			Callback = function()
				print("Default button clicked")
			end,
		})

		-- Add Showcase Tab content
		local ShowcaseSection = Tabs.Showcase:AddSection({ Title = "THEME PREVIEW" })

		ShowcaseSection:AddText({ Title = "Preview Text", Description = "This is a text element." })

		ShowcaseSection:AddDropdown("ShowcaseTheme", {
			Title = "Theme",
			Description = "Change the UI theme to preview",
			Values = {
				"dark",
				"twilight",
				"shadow",
				"dusk",
				"obsidian",
				"charcoal",
				"slate",
				"onyx",
				"ash",
				"granite",
				"cobalt",
				"aurora",
				"sunset",
				"mocha",
				"abyss",
				"void",
				"noir",
			},
			Default = "dark",
			Callback = function(value)
				Library:SetTheme(value)
			end,
		})
		print("Loaded in", tick() - start)

		return function()
			Library:Destroy()
		end
	end,
}

return story

end)() end,
    [24] = function()local wax,script,require=ImportGlobals(24)local ImportGlobals return (function(...)--!strict
local damerau = {}

--[[
    [Wikipedia: Damerau Levenshtein Distance](https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance)

    @param s the string to measure from
    @param t the string to measure to
    @return the amount of changes are needed to change `s` to `t`
]]
function damerau.raw(s: string, t: string): number
	-- switch s and t if s is longer than t
	if #s > #t then
		t, s = s, t
	end

	local m, n = #s, #t

	local vn = table.create(n + 1, 0)

	-- initialize vn so that each value is its index (-1 because lua)
	-- so that it is the edit distance from an empty s to t
	for i = 1, n + 1 do
		vn[i] = i - 1
	end

	local v0, v1 = table.clone(vn), table.clone(vn)

	for i = 1, m do
		v1[1] = i - 1

		for j = 1, n do
			local cost = if s:sub(i, i) == t:sub(j, j) then 0 else 1

			-- check whether this and previous character can be switched
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

		-- shift all arrays up by one
		vn, v0, v1 = v0, v1, vn
	end

	return v0[n + 1]
end

--[[
    A weighted version of damerau levenshtein so that the returned value is 0-1.

    @see damerau.raw

    @param s the string to measure from
    @param t the string to measure to
    @return percentage of `s` that needs to change to convert it to `t` (0-1)
]]
function damerau.weighted(s: string, t: string): number
	return damerau.raw(s, t) / (#s + #t)
end

return damerau

end)() end,
    [25] = function()local wax,script,require=ImportGlobals(25)local ImportGlobals return (function(...)-- https://raw.githubusercontent.com/richie0866/orca/320f43f28373864bb7cd1b9634c337ca77fcee03/src/jobs/helpers/freecam/init.lua
------------------------------------------------------------------------
-- Freecam
-- Cinematic free camera for spectating and video production.
------------------------------------------------------------------------

local pi = math.pi
local abs = math.abs
local clamp = math.clamp
local exp = math.exp
local rad = math.rad
local sign = math.sign
local sqrt = math.sqrt
local tan = math.tan

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = Workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

------------------------------------------------------------------------

local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
local FREECAM_MACRO_KB = { Enum.KeyCode.LeftShift, Enum.KeyCode.P }

local FREECAM_RENDER_ID = game:GetService("HttpService"):GenerateGUID(false)

local NAV_GAIN = Vector3.new(1, 1, 1) * 64
local PAN_GAIN = Vector2.new(0.75, 1) * 8
local FOV_GAIN = 300

local PITCH_LIMIT = rad(90)

local VEL_STIFFNESS = 2.0
local PAN_STIFFNESS = 3.0
local FOV_STIFFNESS = 4.0

------------------------------------------------------------------------

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

------------------------------------------------------------------------

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 0

local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
local fovSpring = Spring.new(FOV_STIFFNESS, 0)

------------------------------------------------------------------------

local Input = {}
do
	local thumbstickCurve
	do
		local K_CURVATURE = 2.0
		local K_DEADZONE = 0.15

		local function fCurve(x)
			return (exp(K_CURVATURE * x) - 1) / (exp(K_CURVATURE) - 1)
		end

		local function fDeadzone(x)
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
	local FOV_WHEEL_SPEED = 1.0
	local FOV_GAMEPAD_SPEED = 0.25
	local NAV_ADJ_SPEED = 0.75
	local NAV_SHIFT_MUL = 0.25

	local navSpeed = 1

	function Input.Vel(dt)
		navSpeed = clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4)

		local kGamepad = Vector3.new(
			thumbstickCurve(gamepad.Thumbstick1.X),
			thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
			thumbstickCurve(-gamepad.Thumbstick1.Y)
		) * NAV_GAMEPAD_SPEED

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A + keyboard.K - keyboard.H,
			keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
			keyboard.S - keyboard.W + keyboard.J - keyboard.U
		) * NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

		return (kGamepad + kKeyboard) * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kGamepad = Vector2.new(thumbstickCurve(gamepad.Thumbstick2.Y), thumbstickCurve(-gamepad.Thumbstick2.X))
			* PAN_GAMEPAD_SPEED
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
		local function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		local function GpButton(action, state, input)
			gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		local function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		local function Thumb(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position
			return Enum.ContextActionResult.Sink
		end

		local function Trigger(action, state, input)
			gamepad[input.KeyCode.Name] = input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function MouseWheel(action, state, input)
			mouse[input.UserInputType.Name] = -input.Position.z
			return Enum.ContextActionResult.Sink
		end

		local function Zero(t)
			for k, v in pairs(t) do
				t[k] = v * 0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority(
				FREECAM_RENDER_ID .. "FreecamKeyboard",
				Keypress,
				false,
				INPUT_PRIORITY,
				Enum.KeyCode.W, -- Enum.KeyCode.U,
				Enum.KeyCode.A, -- Enum.KeyCode.H,
				Enum.KeyCode.S, -- Enum.KeyCode.J,
				Enum.KeyCode.D, -- Enum.KeyCode.K,
				Enum.KeyCode.E, -- Enum.KeyCode.I,
				Enum.KeyCode.Q, -- Enum.KeyCode.Y,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority(
				FREECAM_RENDER_ID .. "FreecamMousePan",
				MousePan,
				false,
				INPUT_PRIORITY,
				Enum.UserInputType.MouseMovement
			)
			ContextActionService:BindActionAtPriority(
				FREECAM_RENDER_ID .. "FreecamMouseWheel",
				MouseWheel,
				false,
				INPUT_PRIORITY,
				Enum.UserInputType.MouseWheel
			)
			ContextActionService:BindActionAtPriority(
				FREECAM_RENDER_ID .. "FreecamGamepadButton",
				GpButton,
				false,
				INPUT_PRIORITY,
				Enum.KeyCode.ButtonX,
				Enum.KeyCode.ButtonY
			)
			ContextActionService:BindActionAtPriority(
				FREECAM_RENDER_ID .. "FreecamGamepadTrigger",
				Trigger,
				false,
				INPUT_PRIORITY,
				Enum.KeyCode.ButtonR2,
				Enum.KeyCode.ButtonL2
			)
			ContextActionService:BindActionAtPriority(
				FREECAM_RENDER_ID .. "FreecamGamepadThumbstick",
				Thumb,
				false,
				INPUT_PRIORITY,
				Enum.KeyCode.Thumbstick1,
				Enum.KeyCode.Thumbstick2
			)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(gamepad)
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamKeyboard")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamMousePan")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamMouseWheel")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamGamepadButton")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamGamepadTrigger")
			ContextActionService:UnbindAction(FREECAM_RENDER_ID .. "FreecamGamepadThumbstick")
		end
	end
end

local function GetFocusDistance(cameraFrame)
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

------------------------------------------------------------------------

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))
	local fov = fovSpring:Update(dt, Input.Fov(dt))

	local zoomFactor = sqrt(tan(rad(70 / 2)) / tan(rad(cameraFov / 2)))

	cameraFov = clamp(cameraFov + fov * FOV_GAIN * (dt / zoomFactor), 1, 120)
	cameraRot = cameraRot + pan * PAN_GAIN * (dt / zoomFactor)
	cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y % (2 * pi))

	local cameraCFrame = CFrame.new(cameraPos)
		* CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)
		* CFrame.new(vel * NAV_GAIN * dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame * CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

------------------------------------------------------------------------

local PlayerState = {}
do
	local mouseBehavior
	local mouseIconEnabled
	local cameraType
	local cameraFocus
	local cameraCFrame
	local cameraFieldOfView
	local screenGuis = {}
	local coreGuis = {
		Backpack = true,
		Chat = true,
		Health = true,
		PlayerList = true,
	}
	local setCores = {
		BadgesNotificationsActive = true,
		PointsNotificationsActive = true,
	}

	-- Save state and set up for freecam
	function PlayerState.Push()
		-- for name in pairs(coreGuis) do
		-- 	coreGuis[name] = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType[name])
		-- 	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], false)
		-- end
		-- for name in pairs(setCores) do
		-- 	setCores[name] = StarterGui:GetCore(name)
		-- 	StarterGui:SetCore(name, false)
		-- end
		-- local playergui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		-- if playergui then
		-- 	for _, gui in pairs(playergui:GetChildren()) do
		-- 		if gui:IsA("ScreenGui") and gui.Enabled then
		-- 			screenGuis[#screenGuis + 1] = gui
		-- 			gui.Enabled = false
		-- 		end
		-- 	end
		-- end

		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		-- cameraType = Camera.CameraType
		-- Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		-- mouseIconEnabled = UserInputService.MouseIconEnabled
		-- UserInputService.MouseIconEnabled = false

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	-- Restore state
	function PlayerState.Pop()
		-- for name, isEnabled in pairs(coreGuis) do
		-- 	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
		-- end
		-- for name, isEnabled in pairs(setCores) do
		-- 	StarterGui:SetCore(name, isEnabled)
		-- end
		-- for _, gui in pairs(screenGuis) do
		-- 	if gui.Parent then
		-- 		gui.Enabled = true
		-- 	end
		-- end

		Camera.FieldOfView = cameraFieldOfView
		cameraFieldOfView = nil

		-- Camera.CameraType = cameraType
		-- cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		-- UserInputService.MouseIconEnabled = mouseIconEnabled
		-- mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

local function StartFreecam()
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

local function StopFreecam()
	Input.StopCapture()
	RunService:UnbindFromRenderStep(FREECAM_RENDER_ID)
	PlayerState.Pop()
end

------------------------------------------------------------------------

local enabled = false

local function EnableFreecam()
	if not enabled then
		StartFreecam()
		enabled = true
	end
end

local function DisableFreecam()
	if enabled then
		StopFreecam()
		enabled = false
	end
end

return {
	EnableFreecam = EnableFreecam,
	DisableFreecam = DisableFreecam,
}

end)() end,
    [26] = function()local wax,script,require=ImportGlobals(26)local ImportGlobals return (function(...)--!strict

--[[
	The entry point for the Fusion library.
]]

local PubTypes = require(script.PubTypes)
local restrictRead = require(script.Utility.restrictRead)

export type StateObject<T> = PubTypes.StateObject<T>
export type CanBeState<T> = PubTypes.CanBeState<T>
export type Symbol = PubTypes.Symbol
export type Value<T> = PubTypes.Value<T>
export type Computed<T> = PubTypes.Computed<T>
export type ForPairs<KO, VO> = PubTypes.ForPairs<KO, VO>
export type ForKeys<KI, KO> = PubTypes.ForKeys<KI, KO>
export type ForValues<VI, VO> = PubTypes.ForKeys<VI, VO>
export type Observer = PubTypes.Observer
export type Tween<T> = PubTypes.Tween<T>
export type Spring<T> = PubTypes.Spring<T>

type Fusion = {
	version: PubTypes.Version,

	New: (className: string) -> (propertyTable: PubTypes.PropertyTable) -> Instance,
	Hydrate: (target: Instance) -> (propertyTable: PubTypes.PropertyTable) -> Instance,
	Ref: PubTypes.SpecialKey,
	Cleanup: PubTypes.SpecialKey,
	Children: PubTypes.SpecialKey,
	Out: PubTypes.SpecialKey,
	OnEvent: (eventName: string) -> PubTypes.SpecialKey,
	OnChange: (propertyName: string) -> PubTypes.SpecialKey,

	Value: <T>(initialValue: T) -> Value<T>,
	Computed: <T>(callback: () -> T, destructor: (T) -> ()?) -> Computed<T>,
	ForPairs: <KI, VI, KO, VO, M>(
		inputTable: CanBeState<{ [KI]: VI }>,
		processor: (KI, VI) -> (KO, VO, M?),
		destructor: (KO, VO, M?) -> ()?
	) -> ForPairs<KO, VO>,
	ForKeys: <KI, KO, M>(
		inputTable: CanBeState<{ [KI]: any }>,
		processor: (KI) -> (KO, M?),
		destructor: (KO, M?) -> ()?
	) -> ForKeys<KO, any>,
	ForValues: <VI, VO, M>(
		inputTable: CanBeState<{ [any]: VI }>,
		processor: (VI) -> (VO, M?),
		destructor: (VO, M?) -> ()?
	) -> ForValues<any, VO>,
	Observer: (watchedState: StateObject<any>) -> Observer,

	Tween: <T>(goalState: StateObject<T>, tweenInfo: TweenInfo?) -> Tween<T>,
	Spring: <T>(goalState: StateObject<T>, speed: number?, damping: number?) -> Spring<T>,

	cleanup: (...any) -> (),
	doNothing: (...any) -> (),
}

return restrictRead("Fusion", {
	version = { major = 0, minor = 2, isRelease = true },

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
}) :: Fusion

end)() end,
    [28] = function()local wax,script,require=ImportGlobals(28)local ImportGlobals return (function(...)--!nonstrict

--[[
	Constructs a new computed state object, which follows the value of another
	state object using a spring simulation.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local SpringScheduler = require(Package.Animation.SpringScheduler)
local Types = require(Package.Types)
local initDependency = require(Package.Dependencies.initDependency)
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local unpackType = require(Package.Animation.unpackType)
local unwrap = require(Package.State.unwrap)
local updateAll = require(Package.Dependencies.updateAll)
local useDependency = require(Package.Dependencies.useDependency)
local xtypeof = require(Package.Utility.xtypeof)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

--[[
	Returns the current value of this Spring object.
	The object will be registered as a dependency unless `asDependency` is false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._currentValue
end

--[[
	Sets the position of the internal springs, meaning the value of this
	Spring will jump to the given value. This doesn't affect velocity.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function class:setPosition(newValue: PubTypes.Animatable)
	local newType = typeof(newValue)
	if newType ~= self._currentType then
		logError("springTypeMismatch", nil, newType, self._currentType)
	end

	self._springPositions = unpackType(newValue, newType)
	self._currentValue = newValue
	SpringScheduler.add(self)
	updateAll(self)
end

--[[
	Sets the velocity of the internal springs, overwriting the existing velocity
	of this Spring. This doesn't affect position.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function class:setVelocity(newValue: PubTypes.Animatable)
	local newType = typeof(newValue)
	if newType ~= self._currentType then
		logError("springTypeMismatch", nil, newType, self._currentType)
	end

	self._springVelocities = unpackType(newValue, newType)
	SpringScheduler.add(self)
end

--[[
	Adds to the velocity of the internal springs, on top of the existing
	velocity of this Spring. This doesn't affect position.

	If the type doesn't match the current type of the spring, an error will be
	thrown.
]]
function class:addVelocity(deltaValue: PubTypes.Animatable)
	local deltaType = typeof(deltaValue)
	if deltaType ~= self._currentType then
		logError("springTypeMismatch", nil, deltaType, self._currentType)
	end

	local springDeltas = unpackType(deltaValue, deltaType)
	for index, delta in ipairs(springDeltas) do
		self._springVelocities[index] += delta
	end
	SpringScheduler.add(self)
end

--[[
	Called when the goal state changes value, or when the speed or damping has
	changed.
]]
function class:update(): boolean
	local goalValue = self._goalState:get(false)

	-- figure out if this was a goal change or a speed/damping change
	if goalValue == self._goalValue then
		-- speed/damping change
		local damping = unwrap(self._damping)
		if typeof(damping) ~= "number" then
			logErrorNonFatal("mistypedSpringDamping", nil, typeof(damping))
		elseif damping < 0 then
			logErrorNonFatal("invalidSpringDamping", nil, damping)
		else
			self._currentDamping = damping
		end

		local speed = unwrap(self._speed)
		if typeof(speed) ~= "number" then
			logErrorNonFatal("mistypedSpringSpeed", nil, typeof(speed))
		elseif speed < 0 then
			logErrorNonFatal("invalidSpringSpeed", nil, speed)
		else
			self._currentSpeed = speed
		end

		return false
	else
		-- goal change - reconfigure spring to target new goal
		self._goalValue = goalValue

		local oldType = self._currentType
		local newType = typeof(goalValue)
		self._currentType = newType

		local springGoals = unpackType(goalValue, newType)
		local numSprings = #springGoals
		self._springGoals = springGoals

		if newType ~= oldType then
			-- if the type changed, snap to the new value and rebuild the
			-- position and velocity tables
			self._currentValue = self._goalValue

			local springPositions = table.create(numSprings, 0)
			local springVelocities = table.create(numSprings, 0)
			for index, springGoal in ipairs(springGoals) do
				springPositions[index] = springGoal
			end
			self._springPositions = springPositions
			self._springVelocities = springVelocities

			-- the spring may have been animating before, so stop that
			SpringScheduler.remove(self)
			return true

			-- otherwise, the type hasn't changed, just the goal...
		elseif numSprings == 0 then
			-- if the type isn't animatable, snap to the new value
			self._currentValue = self._goalValue
			return true
		else
			-- if it's animatable, let it animate to the goal
			SpringScheduler.add(self)
			return false
		end
	end
end

local function Spring<T>(
	goalState: PubTypes.Value<T>,
	speed: PubTypes.CanBeState<number>?,
	damping: PubTypes.CanBeState<number>?
): Types.Spring<T>
	-- apply defaults for speed and damping
	if speed == nil then
		speed = 10
	end
	if damping == nil then
		damping = 1
	end

	local dependencySet = { [goalState] = true }
	if xtypeof(speed) == "State" then
		dependencySet[speed] = true
	end
	if xtypeof(damping) == "State" then
		dependencySet[damping] = true
	end

	local self = setmetatable({
		type = "State",
		kind = "Spring",
		dependencySet = dependencySet,
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
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
	-- add this object to the goal state's dependent set
	goalState.dependentSet[self] = true
	self:update()

	return self
end

return Spring

end)() end,
    [29] = function()local wax,script,require=ImportGlobals(29)local ImportGlobals return (function(...)--!strict

--[[
	Manages batch updating of spring objects.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Types = require(Package.Types)
local packType = require(Package.Animation.packType)
local springCoefficients = require(Package.Animation.springCoefficients)
local updateAll = require(Package.Dependencies.updateAll)

type Set<T> = { [T]: any }
type Spring = Types.Spring<any>

local SpringScheduler = {}

local EPSILON = 0.0001
local activeSprings: Set<Spring> = {}
local lastUpdateTime = os.clock()

function SpringScheduler.add(spring: Spring)
	-- we don't necessarily want to use the most accurate time - here we snap to
	-- the last update time so that springs started within the same frame have
	-- identical time steps
	spring._lastSchedule = lastUpdateTime
	spring._startDisplacements = {}
	spring._startVelocities = {}
	for index, goal in ipairs(spring._springGoals) do
		spring._startDisplacements[index] = spring._springPositions[index] - goal
		spring._startVelocities[index] = spring._springVelocities[index]
	end

	activeSprings[spring] = true
end

function SpringScheduler.remove(spring: Spring)
	activeSprings[spring] = nil
end

local function updateAllSprings()
	local springsToSleep: Set<Spring> = {}
	lastUpdateTime = os.clock()

	for spring in pairs(activeSprings) do
		local posPos, posVel, velPos, velVel =
			springCoefficients(lastUpdateTime - spring._lastSchedule, spring._currentDamping, spring._currentSpeed)

		local positions = spring._springPositions
		local velocities = spring._springVelocities
		local startDisplacements = spring._startDisplacements
		local startVelocities = spring._startVelocities
		local isMoving = false

		for index, goal in ipairs(spring._springGoals) do
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

	for spring in pairs(activeSprings) do
		spring._currentValue = packType(spring._springPositions, spring._currentType)
		updateAll(spring)
	end

	for spring in pairs(springsToSleep) do
		activeSprings[spring] = nil
	end
end

RunService:BindToRenderStep("__FusionSpringScheduler", Enum.RenderPriority.First.Value, updateAllSprings)

return SpringScheduler

end)() end,
    [30] = function()local wax,script,require=ImportGlobals(30)local ImportGlobals return (function(...)--!nonstrict

--[[
	Constructs a new computed state object, which follows the value of another
	state object using a tween.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local TweenScheduler = require(Package.Animation.TweenScheduler)
local Types = require(Package.Types)
local initDependency = require(Package.Dependencies.initDependency)
local logError = require(Package.Logging.logError)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local useDependency = require(Package.Dependencies.useDependency)
local xtypeof = require(Package.Utility.xtypeof)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

--[[
	Returns the current value of this Tween object.
	The object will be registered as a dependency unless `asDependency` is false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._currentValue
end

--[[
	Called when the goal state changes value; this will initiate a new tween.
	Returns false as the current value doesn't change right away.
]]
function class:update(): boolean
	local goalValue = self._goalState:get(false)

	-- if the goal hasn't changed, then this is a TweenInfo change.
	-- in that case, if we're not currently animating, we can skip everything
	if goalValue == self._nextValue and not self._currentlyAnimating then
		return false
	end

	local tweenInfo = self._tweenInfo
	if self._tweenInfoIsState then
		tweenInfo = tweenInfo:get()
	end

	-- if we receive a bad TweenInfo, then error and stop the update
	if typeof(tweenInfo) ~= "TweenInfo" then
		logErrorNonFatal("mistypedTweenInfo", nil, typeof(tweenInfo))
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

	-- start animating this tween
	TweenScheduler.add(self)

	return false
end

local function Tween<T>(
	goalState: PubTypes.StateObject<PubTypes.Animatable>,
	tweenInfo: PubTypes.CanBeState<TweenInfo>?
): Types.Tween<T>
	local currentValue = goalState:get(false)

	-- apply defaults for tween info
	if tweenInfo == nil then
		tweenInfo = TweenInfo.new()
	end

	local dependencySet = { [goalState] = true }
	local tweenInfoIsState = xtypeof(tweenInfo) == "State"

	if tweenInfoIsState then
		dependencySet[tweenInfo] = true
	end

	local startingTweenInfo = tweenInfo
	if tweenInfoIsState then
		startingTweenInfo = startingTweenInfo:get()
	end

	-- If we start with a bad TweenInfo, then we don't want to construct a Tween
	if typeof(startingTweenInfo) ~= "TweenInfo" then
		logError("mistypedTweenInfo", nil, typeof(startingTweenInfo))
	end

	local self = setmetatable({
		type = "State",
		kind = "Tween",
		dependencySet = dependencySet,
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_goalState = goalState,
		_tweenInfo = tweenInfo,
		_tweenInfoIsState = tweenInfoIsState,

		_prevValue = currentValue,
		_nextValue = currentValue,
		_currentValue = currentValue,

		-- store current tween into separately from 'real' tween into, so it
		-- isn't affected by :setTweenInfo() until next change
		_currentTweenInfo = tweenInfo,
		_currentTweenDuration = 0,
		_currentTweenStartTime = 0,
		_currentlyAnimating = false,
	}, CLASS_METATABLE)

	initDependency(self)
	-- add this object to the goal state's dependent set
	goalState.dependentSet[self] = true

	return self
end

return Tween

end)() end,
    [31] = function()local wax,script,require=ImportGlobals(31)local ImportGlobals return (function(...)--!strict

--[[
	Manages batch updating of tween objects.
]]

local RunService = game:GetService("RunService")

local Package = script.Parent.Parent
local Types = require(Package.Types)
local getTweenRatio = require(Package.Animation.getTweenRatio)
local lerpType = require(Package.Animation.lerpType)
local updateAll = require(Package.Dependencies.updateAll)

local TweenScheduler = {}

type Set<T> = { [T]: any }
type Tween = Types.Tween<any>

local WEAK_KEYS_METATABLE = { __mode = "k" }

-- all the tweens currently being updated
local allTweens: Set<Tween> = {}
setmetatable(allTweens, WEAK_KEYS_METATABLE)

--[[
	Adds a Tween to be updated every render step.
]]
function TweenScheduler.add(tween: Tween)
	allTweens[tween] = true
end

--[[
	Removes a Tween from the scheduler.
]]
function TweenScheduler.remove(tween: Tween)
	allTweens[tween] = nil
end

--[[
	Updates all Tween objects.
]]
local function updateAllTweens()
	local now = os.clock()
	-- FIXME: Typed Luau doesn't understand this loop yet
	for tween: Tween in pairs(allTweens :: any) do
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

RunService:BindToRenderStep("__FusionTweenScheduler", Enum.RenderPriority.First.Value, updateAllTweens)

return TweenScheduler

end)() end,
    [32] = function()local wax,script,require=ImportGlobals(32)local ImportGlobals return (function(...)--!strict

--[[
	Given a `tweenInfo` and `currentTime`, returns a ratio which can be used to
	tween between two values over time.
]]

local TweenService = game:GetService("TweenService")

local function getTweenRatio(tweenInfo: TweenInfo, currentTime: number): number
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

end)() end,
    [33] = function()local wax,script,require=ImportGlobals(33)local ImportGlobals return (function(...)--!strict

--[[
	Linearly interpolates the given animatable types by a ratio.
	If the types are different or not animatable, then the first value will be
	returned for ratios below 0.5, and the second value for 0.5 and above.

	FIXME: This function uses a lot of redefinitions to suppress false positives
	from the Luau typechecker - ideally these wouldn't be required
]]

local Package = script.Parent.Parent
local Oklab = require(Package.Colour.Oklab)
local PubTypes = require(Package.PubTypes)

local function lerpType(from: any, to: any, ratio: number): any
	local typeString = typeof(from)

	if typeof(to) == typeString then
		-- both types must match for interpolation to make sense
		if typeString == "number" then
			local to, from = to :: number, from :: number
			return (to - from) * ratio + from
		elseif typeString == "CFrame" then
			local to, from = to :: CFrame, from :: CFrame
			return from:Lerp(to, ratio)
		elseif typeString == "Color3" then
			local to, from = to :: Color3, from :: Color3
			local fromLab = Oklab.to(from)
			local toLab = Oklab.to(to)
			return Oklab.from(fromLab:Lerp(toLab, ratio), false)
		elseif typeString == "ColorSequenceKeypoint" then
			local to, from = to :: ColorSequenceKeypoint, from :: ColorSequenceKeypoint
			local fromLab = Oklab.to(from.Value)
			local toLab = Oklab.to(to.Value)
			return ColorSequenceKeypoint.new(
				(to.Time - from.Time) * ratio + from.Time,
				Oklab.from(fromLab:Lerp(toLab, ratio), false)
			)
		elseif typeString == "DateTime" then
			local to, from = to :: DateTime, from :: DateTime
			return DateTime.fromUnixTimestampMillis(
				(to.UnixTimestampMillis - from.UnixTimestampMillis) * ratio + from.UnixTimestampMillis
			)
		elseif typeString == "NumberRange" then
			local to, from = to :: NumberRange, from :: NumberRange
			return NumberRange.new((to.Min - from.Min) * ratio + from.Min, (to.Max - from.Max) * ratio + from.Max)
		elseif typeString == "NumberSequenceKeypoint" then
			local to, from = to :: NumberSequenceKeypoint, from :: NumberSequenceKeypoint
			return NumberSequenceKeypoint.new(
				(to.Time - from.Time) * ratio + from.Time,
				(to.Value - from.Value) * ratio + from.Value,
				(to.Envelope - from.Envelope) * ratio + from.Envelope
			)
		elseif typeString == "PhysicalProperties" then
			local to, from = to :: PhysicalProperties, from :: PhysicalProperties
			return PhysicalProperties.new(
				(to.Density - from.Density) * ratio + from.Density,
				(to.Friction - from.Friction) * ratio + from.Friction,
				(to.Elasticity - from.Elasticity) * ratio + from.Elasticity,
				(to.FrictionWeight - from.FrictionWeight) * ratio + from.FrictionWeight,
				(to.ElasticityWeight - from.ElasticityWeight) * ratio + from.ElasticityWeight
			)
		elseif typeString == "Ray" then
			local to, from = to :: Ray, from :: Ray
			return Ray.new(from.Origin:Lerp(to.Origin, ratio), from.Direction:Lerp(to.Direction, ratio))
		elseif typeString == "Rect" then
			local to, from = to :: Rect, from :: Rect
			return Rect.new(from.Min:Lerp(to.Min, ratio), from.Max:Lerp(to.Max, ratio))
		elseif typeString == "Region3" then
			local to, from = to :: Region3, from :: Region3
			-- FUTURE: support rotated Region3s if/when they become constructable
			local position = from.CFrame.Position:Lerp(to.CFrame.Position, ratio)
			local halfSize = from.Size:Lerp(to.Size, ratio) / 2
			return Region3.new(position - halfSize, position + halfSize)
		elseif typeString == "Region3int16" then
			local to, from = to :: Region3int16, from :: Region3int16
			return Region3int16.new(
				Vector3int16.new(
					(to.Min.X - from.Min.X) * ratio + from.Min.X,
					(to.Min.Y - from.Min.Y) * ratio + from.Min.Y,
					(to.Min.Z - from.Min.Z) * ratio + from.Min.Z
				),
				Vector3int16.new(
					(to.Max.X - from.Max.X) * ratio + from.Max.X,
					(to.Max.Y - from.Max.Y) * ratio + from.Max.Y,
					(to.Max.Z - from.Max.Z) * ratio + from.Max.Z
				)
			)
		elseif typeString == "UDim" then
			local to, from = to :: UDim, from :: UDim
			return UDim.new(
				(to.Scale - from.Scale) * ratio + from.Scale,
				(to.Offset - from.Offset) * ratio + from.Offset
			)
		elseif typeString == "UDim2" then
			local to, from = to :: UDim2, from :: UDim2
			return from:Lerp(to, ratio)
		elseif typeString == "Vector2" then
			local to, from = to :: Vector2, from :: Vector2
			return from:Lerp(to, ratio)
		elseif typeString == "Vector2int16" then
			local to, from = to :: Vector2int16, from :: Vector2int16
			return Vector2int16.new((to.X - from.X) * ratio + from.X, (to.Y - from.Y) * ratio + from.Y)
		elseif typeString == "Vector3" then
			local to, from = to :: Vector3, from :: Vector3
			return from:Lerp(to, ratio)
		elseif typeString == "Vector3int16" then
			local to, from = to :: Vector3int16, from :: Vector3int16
			return Vector3int16.new(
				(to.X - from.X) * ratio + from.X,
				(to.Y - from.Y) * ratio + from.Y,
				(to.Z - from.Z) * ratio + from.Z
			)
		end
	end

	-- fallback case: the types are different or not animatable
	if ratio < 0.5 then
		return from
	else
		return to
	end
end

return lerpType

end)() end,
    [34] = function()local wax,script,require=ImportGlobals(34)local ImportGlobals return (function(...)--!strict

--[[
	Packs an array of numbers into a given animatable data type.
	If the type is not animatable, nil will be returned.

	FUTURE: When Luau supports singleton types, those could be used in
	conjunction with intersection types to make this function fully statically
	type checkable.
]]

local Package = script.Parent.Parent
local Oklab = require(Package.Colour.Oklab)
local PubTypes = require(Package.PubTypes)

local function packType(numbers: { number }, typeString: string): PubTypes.Animatable?
	if typeString == "number" then
		return numbers[1]
	elseif typeString == "CFrame" then
		return CFrame.new(numbers[1], numbers[2], numbers[3])
			* CFrame.fromAxisAngle(Vector3.new(numbers[4], numbers[5], numbers[6]).Unit, numbers[7])
	elseif typeString == "Color3" then
		return Oklab.from(Vector3.new(numbers[1], numbers[2], numbers[3]), false)
	elseif typeString == "ColorSequenceKeypoint" then
		return ColorSequenceKeypoint.new(numbers[4], Oklab.from(Vector3.new(numbers[1], numbers[2], numbers[3]), false))
	elseif typeString == "DateTime" then
		return DateTime.fromUnixTimestampMillis(numbers[1])
	elseif typeString == "NumberRange" then
		return NumberRange.new(numbers[1], numbers[2])
	elseif typeString == "NumberSequenceKeypoint" then
		return NumberSequenceKeypoint.new(numbers[2], numbers[1], numbers[3])
	elseif typeString == "PhysicalProperties" then
		return PhysicalProperties.new(numbers[1], numbers[2], numbers[3], numbers[4], numbers[5])
	elseif typeString == "Ray" then
		return Ray.new(Vector3.new(numbers[1], numbers[2], numbers[3]), Vector3.new(numbers[4], numbers[5], numbers[6]))
	elseif typeString == "Rect" then
		return Rect.new(numbers[1], numbers[2], numbers[3], numbers[4])
	elseif typeString == "Region3" then
		-- FUTURE: support rotated Region3s if/when they become constructable
		local position = Vector3.new(numbers[1], numbers[2], numbers[3])
		local halfSize = Vector3.new(numbers[4] / 2, numbers[5] / 2, numbers[6] / 2)
		return Region3.new(position - halfSize, position + halfSize)
	elseif typeString == "Region3int16" then
		return Region3int16.new(
			Vector3int16.new(numbers[1], numbers[2], numbers[3]),
			Vector3int16.new(numbers[4], numbers[5], numbers[6])
		)
	elseif typeString == "UDim" then
		return UDim.new(numbers[1], numbers[2])
	elseif typeString == "UDim2" then
		return UDim2.new(numbers[1], numbers[2], numbers[3], numbers[4])
	elseif typeString == "Vector2" then
		return Vector2.new(numbers[1], numbers[2])
	elseif typeString == "Vector2int16" then
		return Vector2int16.new(numbers[1], numbers[2])
	elseif typeString == "Vector3" then
		return Vector3.new(numbers[1], numbers[2], numbers[3])
	elseif typeString == "Vector3int16" then
		return Vector3int16.new(numbers[1], numbers[2], numbers[3])
	else
		return nil
	end
end

return packType

end)() end,
    [35] = function()local wax,script,require=ImportGlobals(35)local ImportGlobals return (function(...)--!strict

--[[
	Returns a 2x2 matrix of coefficients for a given time, damping and speed.
	Specifically, this returns four coefficients - posPos, posVel, velPos, and
	velVel - which can be multiplied with position and velocity like so:

	local newPosition = oldPosition * posPos + oldVelocity * posVel
	local newVelocity = oldPosition * velPos + oldVelocity * velVel

	Special thanks to AxisAngle for helping to improve numerical precision.
]]

local function springCoefficients(time: number, damping: number, speed: number): (number, number, number, number)
	-- if time or speed is 0, then the spring won't move
	if time == 0 or speed == 0 then
		return 1, 0, 0, 1
	end
	local posPos, posVel, velPos, velVel

	if damping > 1 then
		-- overdamped spring
		-- solution to the characteristic equation:
		-- z = -ζω ± Sqrt[ζ^2 - 1] ω
		-- x[t] -> x0(e^(t z2) z1 - e^(t z1) z2)/(z1 - z2)
		--		 + v0(e^(t z1) - e^(t z2))/(z1 - z2)
		-- v[t] -> x0(z1 z2(-e^(t z1) + e^(t z2)))/(z1 - z2)
		--		 + v0(z1 e^(t z1) - z2 e^(t z2))/(z1 - z2)

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
		-- critically damped spring
		-- x[t] -> x0(e^-tω)(1+tω) + v0(e^-tω)t
		-- v[t] -> x0(t ω^2)(-e^-tω) + v0(1 - tω)(e^-tω)

		local scaledTime = time * speed
		local expTerm = math.exp(-scaledTime)

		posPos = expTerm * (1 + scaledTime)
		posVel = expTerm * time
		velPos = expTerm * (-scaledTime * speed)
		velVel = expTerm * (1 - scaledTime)
	else
		-- underdamped spring
		-- factored out of the solutions to the characteristic equation:
		-- α = Sqrt[1 - ζ^2]
		-- x[t] -> x0(e^-tζω)(α Cos[tα] + ζω Sin[tα])/α
		--       + v0(e^-tζω)(Sin[tα])/α
		-- v[t] -> x0(-e^-tζω)(α^2 + ζ^2 ω^2)(Sin[tα])/α
		--       + v0(e^-tζω)(α Cos[tα] - ζω Sin[tα])/α

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

end)() end,
    [36] = function()local wax,script,require=ImportGlobals(36)local ImportGlobals return (function(...)--!strict

--[[
	Unpacks an animatable type into an array of numbers.
	If the type is not animatable, an empty array will be returned.

	FIXME: This function uses a lot of redefinitions to suppress false positives
	from the Luau typechecker - ideally these wouldn't be required

	FUTURE: When Luau supports singleton types, those could be used in
	conjunction with intersection types to make this function fully statically
	type checkable.
]]

local Package = script.Parent.Parent
local Oklab = require(Package.Colour.Oklab)
local PubTypes = require(Package.PubTypes)

local function unpackType(value: any, typeString: string): { number }
	if typeString == "number" then
		local value = value :: number
		return { value }
	elseif typeString == "CFrame" then
		-- FUTURE: is there a better way of doing this? doing distance
		-- calculations on `angle` may be incorrect
		local axis, angle = value:ToAxisAngle()
		return { value.X, value.Y, value.Z, axis.X, axis.Y, axis.Z, angle }
	elseif typeString == "Color3" then
		local lab = Oklab.to(value)
		return { lab.X, lab.Y, lab.Z }
	elseif typeString == "ColorSequenceKeypoint" then
		local lab = Oklab.to(value.Value)
		return { lab.X, lab.Y, lab.Z, value.Time }
	elseif typeString == "DateTime" then
		return { value.UnixTimestampMillis }
	elseif typeString == "NumberRange" then
		return { value.Min, value.Max }
	elseif typeString == "NumberSequenceKeypoint" then
		return { value.Value, value.Time, value.Envelope }
	elseif typeString == "PhysicalProperties" then
		return { value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight }
	elseif typeString == "Ray" then
		return {
			value.Origin.X,
			value.Origin.Y,
			value.Origin.Z,
			value.Direction.X,
			value.Direction.Y,
			value.Direction.Z,
		}
	elseif typeString == "Rect" then
		return { value.Min.X, value.Min.Y, value.Max.X, value.Max.Y }
	elseif typeString == "Region3" then
		-- FUTURE: support rotated Region3s if/when they become constructable
		return {
			value.CFrame.X,
			value.CFrame.Y,
			value.CFrame.Z,
			value.Size.X,
			value.Size.Y,
			value.Size.Z,
		}
	elseif typeString == "Region3int16" then
		return { value.Min.X, value.Min.Y, value.Min.Z, value.Max.X, value.Max.Y, value.Max.Z }
	elseif typeString == "UDim" then
		return { value.Scale, value.Offset }
	elseif typeString == "UDim2" then
		return { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset }
	elseif typeString == "Vector2" then
		return { value.X, value.Y }
	elseif typeString == "Vector2int16" then
		return { value.X, value.Y }
	elseif typeString == "Vector3" then
		return { value.X, value.Y, value.Z }
	elseif typeString == "Vector3int16" then
		return { value.X, value.Y, value.Z }
	else
		return {}
	end
end

return unpackType

end)() end,
    [38] = function()local wax,script,require=ImportGlobals(38)local ImportGlobals return (function(...)--!strict

--[[
	Provides functions for converting Color3s into Oklab space, for more
	perceptually uniform colour blending.

	See: https://bottosson.github.io/posts/oklab/
]]

local Oklab = {}

-- Converts a Color3 in RGB space to a Vector3 in Oklab space.
function Oklab.to(rgb: Color3): Vector3
	local l = rgb.R * 0.4122214708 + rgb.G * 0.5363325363 + rgb.B * 0.0514459929
	local m = rgb.R * 0.2119034982 + rgb.G * 0.6806995451 + rgb.B * 0.1073969566
	local s = rgb.R * 0.0883024619 + rgb.G * 0.2817188376 + rgb.B * 0.6299787005

	local lRoot = l ^ (1 / 3)
	local mRoot = m ^ (1 / 3)
	local sRoot = s ^ (1 / 3)

	return Vector3.new(
		lRoot * 0.2104542553 + mRoot * 0.7936177850 - sRoot * 0.0040720468,
		lRoot * 1.9779984951 - mRoot * 2.4285922050 + sRoot * 0.4505937099,
		lRoot * 0.0259040371 + mRoot * 0.7827717662 - sRoot * 0.8086757660
	)
end

-- Converts a Vector3 in CIELAB space to a Color3 in RGB space.
-- The Color3 will be clamped by default unless specified otherwise.
function Oklab.from(lab: Vector3, unclamped: boolean?): Color3
	local lRoot = lab.X + lab.Y * 0.3963377774 + lab.Z * 0.2158037573
	local mRoot = lab.X - lab.Y * 0.1055613458 - lab.Z * 0.0638541728
	local sRoot = lab.X - lab.Y * 0.0894841775 - lab.Z * 1.2914855480

	local l = lRoot ^ 3
	local m = mRoot ^ 3
	local s = sRoot ^ 3

	local red = l * 4.0767416621 - m * 3.3077115913 + s * 0.2309699292
	local green = l * -1.2684380046 + m * 2.6097574011 - s * 0.3413193965
	local blue = l * -0.0041960863 - m * 0.7034186147 + s * 1.7076147010

	if not unclamped then
		red = math.clamp(red, 0, 1)
		green = math.clamp(green, 0, 1)
		blue = math.clamp(blue, 0, 1)
	end

	return Color3.new(red, green, blue)
end

return Oklab

end)() end,
    [40] = function()local wax,script,require=ImportGlobals(40)local ImportGlobals return (function(...)--!strict

--[[
	Calls the given callback, and stores any used external dependencies.
	Arguments can be passed in after the callback.
	If the callback completed successfully, returns true and the returned value,
	otherwise returns false and the error thrown.
	The callback shouldn't yield or run asynchronously.

	NOTE: any calls to useDependency() inside the callback (even if inside any
	nested captureDependencies() call) will not be included in the set, to avoid
	self-dependencies.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local parseError = require(Package.Logging.parseError)
local sharedState = require(Package.Dependencies.sharedState)

type Set<T> = { [T]: any }

local initialisedStack = sharedState.initialisedStack
local initialisedStackCapacity = 0

local function captureDependencies(saveToSet: Set<PubTypes.Dependency>, callback: (...any) -> any, ...): (boolean, any)
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

end)() end,
    [41] = function()local wax,script,require=ImportGlobals(41)local ImportGlobals return (function(...)--!strict

--[[
	Registers the creation of an object which can be used as a dependency.

	This is used to make sure objects don't capture dependencies originating
	from inside of themselves.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local sharedState = require(Package.Dependencies.sharedState)

local initialisedStack = sharedState.initialisedStack

local function initDependency(dependency: PubTypes.Dependency)
	local initialisedStackSize = sharedState.initialisedStackSize

	for index, initialisedSet in ipairs(initialisedStack) do
		if index > initialisedStackSize then
			return
		end

		initialisedSet[dependency] = true
	end
end

return initDependency

end)() end,
    [42] = function()local wax,script,require=ImportGlobals(42)local ImportGlobals return (function(...)--!strict

--[[
	Stores shared state for dependency management functions.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

type Set<T> = { [T]: any }

-- The set where used dependencies should be saved to.
local dependencySet: Set<PubTypes.Dependency>? = nil

-- A stack of sets where newly created dependencies should be stored.
local initialisedStack: { Set<PubTypes.Dependency> } = {}
local initialisedStackSize = 0

return {
	dependencySet = dependencySet,
	initialisedStack = initialisedStack,
	initialisedStackSize = initialisedStackSize,
}

end)() end,
    [43] = function()local wax,script,require=ImportGlobals(43)local ImportGlobals return (function(...)--!strict

--[[
	Given a reactive object, updates all dependent reactive objects.
	Objects are only ever updated after all of their dependencies are updated,
	are only ever updated once, and won't be updated if their dependencies are
	unchanged.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

type Set<T> = { [T]: any }
type Descendant = (PubTypes.Dependent & PubTypes.Dependency) | PubTypes.Dependent

-- Credit: https://blog.elttob.uk/2022/11/07/sets-efficient-topological-search.html
local function updateAll(root: PubTypes.Dependency)
	local counters: { [Descendant]: number } = {}
	local flags: { [Descendant]: boolean } = {}
	local queue: { Descendant } = {}
	local queueSize = 0
	local queuePos = 1

	for object in root.dependentSet do
		queueSize += 1
		queue[queueSize] = object
		flags[object] = true
	end

	-- Pass 1: counting up
	while queuePos <= queueSize do
		local next = queue[queuePos]
		local counter = counters[next]
		counters[next] = if counter == nil then 1 else counter + 1
		if (next :: any).dependentSet ~= nil then
			for object in (next :: any).dependentSet do
				queueSize += 1
				queue[queueSize] = object
			end
		end
		queuePos += 1
	end

	-- Pass 2: counting down + processing
	queuePos = 1
	while queuePos <= queueSize do
		local next = queue[queuePos]
		local counter = counters[next] - 1
		counters[next] = counter
		if counter == 0 and flags[next] and next:update() and (next :: any).dependentSet ~= nil then
			for object in (next :: any).dependentSet do
				flags[object] = true
			end
		end
		queuePos += 1
	end
end

return updateAll

end)() end,
    [44] = function()local wax,script,require=ImportGlobals(44)local ImportGlobals return (function(...)--!strict

--[[
	If a target set was specified by captureDependencies(), this will add the
	given dependency to the target set.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local sharedState = require(Package.Dependencies.sharedState)

local initialisedStack = sharedState.initialisedStack

local function useDependency(dependency: PubTypes.Dependency)
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

end)() end,
    [46] = function()local wax,script,require=ImportGlobals(46)local ImportGlobals return (function(...)--!strict

--[[
	A special key for property tables, which parents any given descendants into
	an instance.
]]

local Package = script.Parent.Parent
local Observer = require(Package.State.Observer)
local PubTypes = require(Package.PubTypes)
local logWarn = require(Package.Logging.logWarn)
local xtypeof = require(Package.Utility.xtypeof)

type Set<T> = { [T]: boolean }

-- Experimental flag: name children based on the key used in the [Children] table
local EXPERIMENTAL_AUTO_NAMING = false

local Children = {}
Children.type = "SpecialKey"
Children.kind = "Children"
Children.stage = "descendants"

function Children:apply(propValue: any, applyTo: Instance, cleanupTasks: { PubTypes.Task })
	local newParented: Set<Instance> = {}
	local oldParented: Set<Instance> = {}

	-- save disconnection functions for state object observers
	local newDisconnects: { [PubTypes.StateObject<any>]: () -> () } = {}
	local oldDisconnects: { [PubTypes.StateObject<any>]: () -> () } = {}

	local updateQueued = false
	local queueUpdate: () -> ()

	-- Rescans this key's value to find new instances to parent and state objects
	-- to observe for changes; then unparents instances no longer found and
	-- disconnects observers for state objects no longer present.
	local function updateChildren()
		if not updateQueued then
			return -- this update may have been canceled by destruction, etc.
		end
		updateQueued = false

		oldParented, newParented = newParented, oldParented
		oldDisconnects, newDisconnects = newDisconnects, oldDisconnects
		table.clear(newParented)
		table.clear(newDisconnects)

		local function processChild(child: any, autoName: string?)
			local kind = xtypeof(child)

			if kind == "Instance" then
				-- case 1; single instance

				newParented[child] = true
				if oldParented[child] == nil then
					-- wasn't previously present

					-- TODO: check for ancestry conflicts here
					child.Parent = applyTo
				else
					-- previously here; we want to reuse, so remove from old
					-- set so we don't encounter it during unparenting
					oldParented[child] = nil
				end

				if EXPERIMENTAL_AUTO_NAMING and autoName ~= nil then
					child.Name = autoName
				end
			elseif kind == "State" then
				-- case 2; state object

				local value = child:get(false)
				-- allow nil to represent the absence of a child
				if value ~= nil then
					processChild(value, autoName)
				end

				local disconnect = oldDisconnects[child]
				if disconnect == nil then
					-- wasn't previously present
					disconnect = Observer(child):onChange(queueUpdate)
				else
					-- previously here; we want to reuse, so remove from old
					-- set so we don't encounter it during unparenting
					oldDisconnects[child] = nil
				end

				newDisconnects[child] = disconnect
			elseif kind == "table" then
				-- case 3; table of objects

				for key, subChild in pairs(child) do
					local keyType = typeof(key)
					local subAutoName: string? = nil

					if keyType == "string" then
						subAutoName = key
					elseif keyType == "number" and autoName ~= nil then
						subAutoName = autoName .. "_" .. key
					end

					processChild(subChild, subAutoName)
				end
			else
				logWarn("unrecognisedChildType", kind)
			end
		end

		if propValue ~= nil then
			-- `propValue` is set to nil on cleanup, so we don't process children
			-- in that case
			processChild(propValue)
		end

		-- unparent any children that are no longer present
		for oldInstance in pairs(oldParented) do
			oldInstance.Parent = nil
		end

		-- disconnect observers which weren't reused
		for oldState, disconnect in pairs(oldDisconnects) do
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

	-- perform initial child parenting
	updateQueued = true
	updateChildren()
end

return Children :: PubTypes.SpecialKey

end)() end,
    [47] = function()local wax,script,require=ImportGlobals(47)local ImportGlobals return (function(...)--!strict

--[[
	A special key for property tables, which adds user-specified tasks to be run
	when the instance is destroyed.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)

local Cleanup = {}
Cleanup.type = "SpecialKey"
Cleanup.kind = "Cleanup"
Cleanup.stage = "observer"

function Cleanup:apply(userTask: any, applyTo: Instance, cleanupTasks: { PubTypes.Task })
	table.insert(cleanupTasks, userTask)
end

return Cleanup

end)() end,
    [48] = function()local wax,script,require=ImportGlobals(48)local ImportGlobals return (function(...)--!strict

--[[
	Processes and returns an existing instance, with options for setting
	properties, event handlers and other attributes on the instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)

local function Hydrate(target: Instance)
	return function(props: PubTypes.PropertyTable): Instance
		applyInstanceProps(props, target)
		return target
	end
end

return Hydrate

end)() end,
    [49] = function()local wax,script,require=ImportGlobals(49)local ImportGlobals return (function(...)--!strict

--[[
	Constructs and returns a new instance, with options for setting properties,
	event handlers and other attributes on the instance right away.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)
local defaultProps = require(Package.Instances.defaultProps)
local logError = require(Package.Logging.logError)

local function New(className: string)
	return function(props: PubTypes.PropertyTable): Instance
		local ok, instance = pcall(Instance.new, className)

		if not ok then
			logError("cannotCreateClass", nil, className)
		end

		local classDefaults = defaultProps[className]
		if classDefaults ~= nil then
			for defaultProp, defaultValue in pairs(classDefaults) do
				instance[defaultProp] = defaultValue
			end
		end

		applyInstanceProps(props, instance)

		return instance
	end
end

return New

end)() end,
    [50] = function()local wax,script,require=ImportGlobals(50)local ImportGlobals return (function(...)--!strict

--[[
	Constructs special keys for property tables which connect property change
	listeners to an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)

local function OnChange(propertyName: string): PubTypes.SpecialKey
	local changeKey = {}
	changeKey.type = "SpecialKey"
	changeKey.kind = "OnChange"
	changeKey.stage = "observer"

	function changeKey:apply(callback: any, applyTo: Instance, cleanupTasks: { PubTypes.Task })
		local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)
		if not ok then
			logError("cannotConnectChange", nil, applyTo.ClassName, propertyName)
		elseif typeof(callback) ~= "function" then
			logError("invalidChangeHandler", nil, propertyName)
		else
			table.insert(
				cleanupTasks,
				event:Connect(function()
					callback((applyTo :: any)[propertyName])
				end)
			)
		end
	end

	return changeKey
end

return OnChange

end)() end,
    [51] = function()local wax,script,require=ImportGlobals(51)local ImportGlobals return (function(...)--!strict

--[[
	Constructs special keys for property tables which connect event listeners to
	an instance.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)

local function getProperty_unsafe(instance: Instance, property: string)
	return (instance :: any)[property]
end

local function OnEvent(eventName: string): PubTypes.SpecialKey
	local eventKey = {}
	eventKey.type = "SpecialKey"
	eventKey.kind = "OnEvent"
	eventKey.stage = "observer"

	function eventKey:apply(callback: any, applyTo: Instance, cleanupTasks: { PubTypes.Task })
		local ok, event = pcall(getProperty_unsafe, applyTo, eventName)
		if not ok or typeof(event) ~= "RBXScriptSignal" then
			logError("cannotConnectEvent", nil, applyTo.ClassName, eventName)
		elseif typeof(callback) ~= "function" then
			logError("invalidEventHandler", nil, eventName)
		else
			table.insert(cleanupTasks, event:Connect(callback))
		end
	end

	return eventKey
end

return OnEvent

end)() end,
    [52] = function()local wax,script,require=ImportGlobals(52)local ImportGlobals return (function(...)--!strict

--[[
	A special key for property tables, which allows users to extract values from
	an instance into an automatically-updated Value object.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)

local function Out(propertyName: string): PubTypes.SpecialKey
	local outKey = {}
	outKey.type = "SpecialKey"
	outKey.kind = "Out"
	outKey.stage = "observer"

	function outKey:apply(outState: any, applyTo: Instance, cleanupTasks: { PubTypes.Task })
		local ok, event = pcall(applyTo.GetPropertyChangedSignal, applyTo, propertyName)
		if not ok then
			logError("invalidOutProperty", nil, applyTo.ClassName, propertyName)
		elseif xtypeof(outState) ~= "State" or outState.kind ~= "Value" then
			logError("invalidOutType")
		else
			outState:set((applyTo :: any)[propertyName])
			table.insert(
				cleanupTasks,
				event:Connect(function()
					outState:set((applyTo :: any)[propertyName])
				end)
			)
			table.insert(cleanupTasks, function()
				outState:set(nil)
			end)
		end
	end

	return outKey
end

return Out

end)() end,
    [53] = function()local wax,script,require=ImportGlobals(53)local ImportGlobals return (function(...)--!strict

--[[
	A special key for property tables, which stores a reference to the instance
	in a user-provided Value object.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)

local Ref = {}
Ref.type = "SpecialKey"
Ref.kind = "Ref"
Ref.stage = "observer"

function Ref:apply(refState: any, applyTo: Instance, cleanupTasks: { PubTypes.Task })
	if xtypeof(refState) ~= "State" or refState.kind ~= "Value" then
		logError("invalidRefType")
	else
		refState:set(applyTo)
		table.insert(cleanupTasks, function()
			refState:set(nil)
		end)
	end
end

return Ref

end)() end,
    [54] = function()local wax,script,require=ImportGlobals(54)local ImportGlobals return (function(...)--!strict

--[[
	Applies a table of properties to an instance, including binding to any
	given state objects and applying any special keys.

	No strong reference is kept by default - special keys should take care not
	to accidentally hold strong references to instances forever.

	If a key is used twice, an error will be thrown. This is done to avoid
	double assignments or double bindings. However, some special keys may want
	to enable such assignments - in which case unique keys should be used for
	each occurence.
]]

local Package = script.Parent.Parent
local Observer = require(Package.State.Observer)
local PubTypes = require(Package.PubTypes)
local cleanup = require(Package.Utility.cleanup)
local logError = require(Package.Logging.logError)
local xtypeof = require(Package.Utility.xtypeof)

local function setProperty_unsafe(instance: Instance, property: string, value: any)
	(instance :: any)[property] = value
end

local function testPropertyAssignable(instance: Instance, property: string)
	(instance :: any)[property] = (instance :: any)[property]
end

local function setProperty(instance: Instance, property: string, value: any)
	if not pcall(setProperty_unsafe, instance, property, value) then
		if not pcall(testPropertyAssignable, instance, property) then
			if instance == nil then
				-- reference has been lost
				logError("setPropertyNilRef", nil, property, tostring(value))
			else
				-- property is not assignable
				logError("cannotAssignProperty", nil, instance.ClassName, property)
			end
		else
			-- property is assignable, but this specific assignment failed
			-- this typically implies the wrong type was received
			local givenType = typeof(value)
			local expectedType = typeof((instance :: any)[property])
			logError("invalidPropertyType", nil, instance.ClassName, property, expectedType, givenType)
		end
	end
end

local function bindProperty(
	instance: Instance,
	property: string,
	value: PubTypes.CanBeState<any>,
	cleanupTasks: { PubTypes.Task }
)
	if xtypeof(value) == "State" then
		-- value is a state object - assign and observe for changes
		local willUpdate = false
		local function updateLater()
			if not willUpdate then
				willUpdate = true
				task.defer(function()
					willUpdate = false
					setProperty(instance, property, value:get(false))
				end)
			end
		end

		setProperty(instance, property, value:get(false))
		table.insert(cleanupTasks, Observer(value :: any):onChange(updateLater))
	else
		-- value is a constant - assign once only
		setProperty(instance, property, value)
	end
end

local function applyInstanceProps(props: PubTypes.PropertyTable, applyTo: Instance)
	local specialKeys = {
		self = {} :: { [PubTypes.SpecialKey]: any },
		descendants = {} :: { [PubTypes.SpecialKey]: any },
		ancestor = {} :: { [PubTypes.SpecialKey]: any },
		observer = {} :: { [PubTypes.SpecialKey]: any },
	}
	local cleanupTasks = {}

	for key, value in pairs(props) do
		local keyType = xtypeof(key)

		if keyType == "string" then
			if key ~= "Parent" then
				bindProperty(applyTo, key :: string, value, cleanupTasks)
			end
		elseif keyType == "SpecialKey" then
			local stage = (key :: PubTypes.SpecialKey).stage
			local keys = specialKeys[stage]
			if keys == nil then
				logError("unrecognisedPropertyStage", nil, stage)
			else
				keys[key] = value
			end
		else
			-- we don't recognise what this key is supposed to be
			logError("unrecognisedPropertyKey", nil, xtypeof(key))
		end
	end

	for key, value in pairs(specialKeys.self) do
		key:apply(value, applyTo, cleanupTasks)
	end
	for key, value in pairs(specialKeys.descendants) do
		key:apply(value, applyTo, cleanupTasks)
	end

	if props.Parent ~= nil then
		bindProperty(applyTo, "Parent", props.Parent, cleanupTasks)
	end

	for key, value in pairs(specialKeys.ancestor) do
		key:apply(value, applyTo, cleanupTasks)
	end
	for key, value in pairs(specialKeys.observer) do
		key:apply(value, applyTo, cleanupTasks)
	end

	applyTo.Destroying:Connect(function()
		cleanup(cleanupTasks)
	end)
end

return applyInstanceProps

end)() end,
    [55] = function()local wax,script,require=ImportGlobals(55)local ImportGlobals return (function(...)--!strict

--[[
	Stores 'sensible default' properties to be applied to instances created by
	the New function.
]]

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
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14,
	},

	TextButton = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Color3.new(0, 0, 0),
		TextSize = 14,
	},

	TextBox = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		ClearTextOnFocus = false,

		Font = Enum.Font.SourceSans,
		Text = "",
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

end)() end,
    [57] = function()local wax,script,require=ImportGlobals(57)local ImportGlobals return (function(...)--!strict

--[[
	Utility function to log a Fusion-specific error.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local messages = require(Package.Logging.messages)

local function logError(messageID: string, errObj: Types.Error?, ...)
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	local errorString
	if errObj == nil then
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...)
	else
		formatString = formatString:gsub("ERROR_MESSAGE", errObj.message)
		errorString = string.format(
			"[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")\n---- Stack trace ----\n" .. errObj.trace,
			...
		)
	end

	error(errorString:gsub("\n", "\n    "), 0)
end

return logError

end)() end,
    [58] = function()local wax,script,require=ImportGlobals(58)local ImportGlobals return (function(...)--!strict

--[[
	Utility function to log a Fusion-specific error, without halting execution.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local messages = require(Package.Logging.messages)

local function logErrorNonFatal(messageID: string, errObj: Types.Error?, ...)
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	local errorString
	if errObj == nil then
		errorString = string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...)
	else
		formatString = formatString:gsub("ERROR_MESSAGE", errObj.message)
		errorString = string.format(
			"[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")\n---- Stack trace ----\n" .. errObj.trace,
			...
		)
	end

	task.spawn(function(...)
		error(errorString:gsub("\n", "\n    "), 0)
	end, ...)
end

return logErrorNonFatal

end)() end,
    [59] = function()local wax,script,require=ImportGlobals(59)local ImportGlobals return (function(...)--!strict

--[[
	Utility function to log a Fusion-specific warning.
]]

local Package = script.Parent.Parent
local messages = require(Package.Logging.messages)

local function logWarn(messageID, ...)
	local formatString: string

	if messages[messageID] ~= nil then
		formatString = messages[messageID]
	else
		messageID = "unknownMessage"
		formatString = messages[messageID]
	end

	warn(string.format("[Fusion] " .. formatString .. "\n(ID: " .. messageID .. ")", ...))
end

return logWarn

end)() end,
    [60] = function()local wax,script,require=ImportGlobals(60)local ImportGlobals return (function(...)--!strict

--[[
	Stores templates for different kinds of logging messages.
]]

return {
	cannotAssignProperty = "The class type '%s' has no assignable property '%s'.",
	cannotConnectChange = "The %s class doesn't have a property called '%s'.",
	cannotConnectEvent = "The %s class doesn't have an event called '%s'.",
	cannotCreateClass = "Can't create a new instance of class '%s'.",
	computedCallbackError = "Computed callback error: ERROR_MESSAGE",
	destructorNeededValue = "To save instances into Values, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	destructorNeededComputed = "To return instances from Computeds, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	multiReturnComputed = "Returning multiple values from Computeds is discouraged, as behaviour will change soon - see discussion #189 on GitHub.",
	destructorNeededForKeys = "To return instances from ForKeys, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	destructorNeededForValues = "To return instances from ForValues, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	destructorNeededForPairs = "To return instances from ForPairs, provide a destructor function. This will be an error soon - see discussion #183 on GitHub.",
	duplicatePropertyKey = "",
	forKeysProcessorError = "ForKeys callback error: ERROR_MESSAGE",
	forKeysKeyCollision = "ForKeys should only write to output key '%s' once when processing key changes, but it wrote to it twice. Previously input key: '%s'; New input key: '%s'",
	forKeysDestructorError = "ForKeys destructor error: ERROR_MESSAGE",
	forPairsDestructorError = "ForPairs destructor error: ERROR_MESSAGE",
	forPairsKeyCollision = "ForPairs should only write to output key '%s' once when processing key changes, but it wrote to it twice. Previous input pair: '[%s] = %s'; New input pair: '[%s] = %s'",
	forPairsProcessorError = "ForPairs callback error: ERROR_MESSAGE",
	forValuesProcessorError = "ForValues callback error: ERROR_MESSAGE",
	forValuesDestructorError = "ForValues destructor error: ERROR_MESSAGE",
	invalidChangeHandler = "The change handler for the '%s' property must be a function.",
	invalidEventHandler = "The handler for the '%s' event must be a function.",
	invalidPropertyType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	invalidRefType = "Instance refs must be Value objects.",
	invalidOutType = "[Out] properties must be given Value objects.",
	invalidOutProperty = "The %s class doesn't have a property called '%s'.",
	invalidSpringDamping = "The damping ratio for a spring must be >= 0. (damping was %.2f)",
	invalidSpringSpeed = "The speed of a spring must be >= 0. (speed was %.2f)",
	mistypedSpringDamping = "The damping ratio for a spring must be a number. (got a %s)",
	mistypedSpringSpeed = "The speed of a spring must be a number. (got a %s)",
	mistypedTweenInfo = "The tween info of a tween must be a TweenInfo. (got a %s)",
	springTypeMismatch = "The type '%s' doesn't match the spring's type '%s'.",
	strictReadError = "'%s' is not a valid member of '%s'.",
	unknownMessage = "Unknown error: ERROR_MESSAGE",
	unrecognisedChildType = "'%s' type children aren't accepted by `[Children]`.",
	unrecognisedPropertyKey = "'%s' keys aren't accepted in property tables.",
	unrecognisedPropertyStage = "'%s' isn't a valid stage for a special key to be applied at.",
}

end)() end,
    [61] = function()local wax,script,require=ImportGlobals(61)local ImportGlobals return (function(...)--!strict

--[[
	An xpcall() error handler to collect and parse useful information about
	errors, such as clean messages and stack traces.

	TODO: this should have a 'type' field for runtime type checking!
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

local function parseError(err: string): Types.Error
	return {
		type = "Error",
		raw = err,
		message = err:gsub("^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 2),
	}
end

return parseError

end)() end,
    [62] = function()local wax,script,require=ImportGlobals(62)local ImportGlobals return (function(...)--!strict

--[[
	Stores common public-facing type information for Fusion APIs.
]]

type Set<T> = { [T]: any }

--[[
	General use types
]]

-- A unique symbolic value.
export type Symbol = {
	type: string, -- replace with "Symbol" when Luau supports singleton types
	name: string,
}

-- Types that can be expressed as vectors of numbers, and so can be animated.
export type Animatable =
	number
	| CFrame
	| Color3
	| ColorSequenceKeypoint
	| DateTime
	| NumberRange
	| NumberSequenceKeypoint
	| PhysicalProperties
	| Ray
	| Rect
	| Region3
	| Region3int16
	| UDim
	| UDim2
	| Vector2
	| Vector2int16
	| Vector3
	| Vector3int16

-- A task which can be accepted for cleanup.
export type Task =
	Instance
	| RBXScriptConnection
	| () -> () | { destroy: (any) -> () } | { Destroy: (any) -> () } | { Task }

-- Script-readable version information.
export type Version = {
	major: number,
	minor: number,
	isRelease: boolean,
}
--[[
	Generic reactive graph types
]]

-- A graph object which can have dependents.
export type Dependency = {
	dependentSet: Set<Dependent>,
}

-- A graph object which can have dependencies.
export type Dependent = {
	update: (Dependent) -> boolean,
	dependencySet: Set<Dependency>,
}

-- An object which stores a piece of reactive state.
export type StateObject<T> = Dependency & {
	type: string, -- replace with "State" when Luau supports singleton types
	kind: string,
	get: (StateObject<T>, asDependency: boolean?) -> T,
}

-- Either a constant value of type T, or a state object containing type T.
export type CanBeState<T> = StateObject<T> | T

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type Value<T> = StateObject<T> & {
	-- kind: "State" (add this when Luau supports singleton types)
	set: (Value<T>, newValue: any, force: boolean?) -> (),
}

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = StateObject<T> & Dependent & {
	-- kind: "Computed" (add this when Luau supports singleton types)
}

-- A state object whose value is derived from other objects using a callback.
export type ForPairs<KO, VO> = StateObject<{ [KO]: VO }> & Dependent & {
	-- kind: "ForPairs" (add this when Luau supports singleton types)
}
-- A state object whose value is derived from other objects using a callback.
export type ForKeys<KO, V> = StateObject<{ [KO]: V }> & Dependent & {
	-- kind: "ForKeys" (add this when Luau supports singleton types)
}
-- A state object whose value is derived from other objects using a callback.
export type ForValues<K, VO> = StateObject<{ [K]: VO }> & Dependent & {
	-- kind: "ForKeys" (add this when Luau supports singleton types)
}

-- A state object which follows another state object using tweens.
export type Tween<T> = StateObject<T> & Dependent & {
	-- kind: "Tween" (add this when Luau supports singleton types)
}

-- A state object which follows another state object using spring simulation.
export type Spring<T> = StateObject<T> & Dependent & {
	-- kind: "Spring" (add this when Luau supports singleton types)
	-- Uncomment when ENABLE_PARAM_SETTERS is enabled
	-- setPosition: (Spring<T>, newValue: Animatable) -> (),
	-- setVelocity: (Spring<T>, newValue: Animatable) -> (),
	-- addVelocity: (Spring<T>, deltaValue: Animatable) -> ()
}

-- An object which can listen for updates on another state object.
export type Observer = Dependent & {
	-- kind: "Observer" (add this when Luau supports singleton types)
	onChange: (Observer, callback: () -> ()) -> () -> (),
}

--[[
	Instance related types
]]

-- Denotes children instances in an instance or component's property table.
export type SpecialKey = {
	type: string, -- replace with "SpecialKey" when Luau supports singleton types
	kind: string,
	stage: string, -- replace with "self" | "descendants" | "ancestor" | "observer" when Luau supports singleton types
	apply: (SpecialKey, value: any, applyTo: Instance, cleanupTasks: { Task }) -> (),
}

-- A collection of instances that may be parented to another instance.
export type Children = Instance | StateObject<Children> | { [any]: Children }

-- A table that defines an instance's properties, handlers and children.
export type PropertyTable = { [string | SpecialKey]: any }

return nil

end)() end,
    [64] = function()local wax,script,require=ImportGlobals(64)local ImportGlobals return (function(...)--!nonstrict

--[[
	Constructs and returns objects which can be used to model derived reactive
	state.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local captureDependencies = require(Package.Dependencies.captureDependencies)
local initDependency = require(Package.Dependencies.initDependency)
local isSimilar = require(Package.Utility.isSimilar)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logWarn = require(Package.Logging.logWarn)
local needsDestruction = require(Package.Utility.needsDestruction)
local useDependency = require(Package.Dependencies.useDependency)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

--[[
	Returns the last cached value calculated by this Computed object.
	The computed object will be registered as a dependency unless `asDependency`
	is false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._value
end

--[[
	Recalculates this Computed's cached value and dependencies.
	Returns true if it changed, or false if it's identical.
]]
function class:update(): boolean
	-- remove this object from its dependencies' dependent sets
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	-- we need to create a new, empty dependency set to capture dependencies
	-- into, but in case there's an error, we want to restore our old set of
	-- dependencies. by using this table-swapping solution, we can avoid the
	-- overhead of allocating new tables each update.
	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	local ok, newValue, newMetaValue = captureDependencies(self.dependencySet, self._processor)

	if ok then
		if self._destructor == nil and needsDestruction(newValue) then
			logWarn("destructorNeededComputed")
		end

		if newMetaValue ~= nil then
			logWarn("multiReturnComputed")
		end

		local oldValue = self._value
		local similar = isSimilar(oldValue, newValue)
		if self._destructor ~= nil then
			self._destructor(oldValue)
		end
		self._value = newValue

		-- add this object to the dependencies' dependent sets
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return not similar
	else
		-- this needs to be non-fatal, because otherwise it'd disrupt the
		-- update process
		logErrorNonFatal("computedCallbackError", newValue)

		-- restore old dependencies, because the new dependencies may be corrupt
		self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet

		-- restore this object in the dependencies' dependent sets
		for dependency in pairs(self.dependencySet) do
			dependency.dependentSet[self] = true
		end

		return false
	end
end

local function Computed<T>(processor: () -> T, destructor: ((T) -> ())?): Types.Computed<T>
	local self = setmetatable({
		type = "State",
		kind = "Computed",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
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

end)() end,
    [65] = function()local wax,script,require=ImportGlobals(65)local ImportGlobals return (function(...)--!nonstrict

--[[
	Constructs a new ForKeys state object which maps keys of an array using
	a `processor` function.

	Optionally, a `destructor` function can be specified for cleaning up
	calculated keys. If omitted, the default cleanup function will be used instead.

	Optionally, a `meta` value can be returned in the processor function as the
	second value to pass data from the processor to the destructor.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
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

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

--[[
	Returns the current value of this ForKeys object.
	The object will be registered as a dependency unless `asDependency` is false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._outputTable
end

--[[
	Called when the original table is changed.

	This will firstly find any keys meeting any of the following criteria:

	- they were not previously present
	- a dependency used during generation of this value has changed

	It will recalculate those key pairs, storing information about any
	dependencies used in the processor callback during output key generation,
	and save the new key to the output array with the same value. If it is
	overwriting an older value, that older value will be passed to the
	destructor for cleanup.

	Finally, this function will find keys that are no longer present, and remove
	their output keys from the output table and pass them to the destructor.
]]

function class:update(): boolean
	local inputIsState = self._inputIsState
	local newInputTable = if inputIsState then self._inputTable:get(false) else self._inputTable
	local oldInputTable = self._oldInputTable
	local outputTable = self._outputTable

	local keyOIMap = self._keyOIMap
	local keyIOMap = self._keyIOMap
	local meta = self._meta

	local didChange = false

	-- clean out main dependency set
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	-- if the input table is a state object, add it as a dependency
	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	-- STEP 1: find keys that changed or were not previously present
	for newInKey, value in pairs(newInputTable) do
		-- get or create key data
		local keyData = self._keyData[newInKey]

		if keyData == nil then
			keyData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._keyData[newInKey] = keyData
		end

		-- check if the key is new
		local shouldRecalculate = oldInputTable[newInKey] == nil

		-- check if the key's dependencies have changed
		if shouldRecalculate == false then
			for dependency, oldValue in pairs(keyData.dependencyValues) do
				if oldValue ~= dependency:get(false) then
					shouldRecalculate = true
					break
				end
			end
		end

		-- recalculate the output key if necessary
		if shouldRecalculate then
			keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet
			table.clear(keyData.dependencySet)

			local processOK, newOutKey, newMetaValue =
				captureDependencies(keyData.dependencySet, self._processor, newInKey)

			if processOK then
				if self._destructor == nil and (needsDestruction(newOutKey) or needsDestruction(newMetaValue)) then
					logWarn("destructorNeededForKeys")
				end

				local oldInKey = keyOIMap[newOutKey]
				local oldOutKey = keyIOMap[newInKey]

				-- check for key collision
				if oldInKey ~= newInKey and newInputTable[oldInKey] ~= nil then
					logError("forKeysKeyCollision", nil, tostring(newOutKey), tostring(oldInKey), tostring(newOutKey))
				end

				-- check for a changed output key
				if oldOutKey ~= newOutKey and keyOIMap[oldOutKey] == newInKey then
					-- clean up the old calculated value
					local oldMetaValue = meta[oldOutKey]

					local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldOutKey, oldMetaValue)
					if not destructOK then
						logErrorNonFatal("forKeysDestructorError", err)
					end

					keyOIMap[oldOutKey] = nil
					outputTable[oldOutKey] = nil
					meta[oldOutKey] = nil
				end

				-- update the stored data for this key
				oldInputTable[newInKey] = value
				meta[newOutKey] = newMetaValue
				keyOIMap[newOutKey] = newInKey
				keyIOMap[newInKey] = newOutKey
				outputTable[newOutKey] = value

				-- if we had to recalculate the output, then we did change
				didChange = true
			else
				-- restore old dependencies, because the new dependencies may be corrupt
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forKeysProcessorError", newOutKey)
			end
		end

		-- save dependency values and add to main dependency set
		for dependency in pairs(keyData.dependencySet) do
			keyData.dependencyValues[dependency] = dependency:get(false)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end

	-- STEP 2: find keys that were removed
	for outputKey, inputKey in pairs(keyOIMap) do
		if newInputTable[inputKey] == nil then
			-- clean up the old calculated value
			local oldMetaValue = meta[outputKey]

			local destructOK, err = xpcall(self._destructor or cleanup, parseError, outputKey, oldMetaValue)
			if not destructOK then
				logErrorNonFatal("forKeysDestructorError", err)
			end

			-- remove data
			oldInputTable[inputKey] = nil
			meta[outputKey] = nil
			keyOIMap[outputKey] = nil
			keyIOMap[inputKey] = nil
			outputTable[outputKey] = nil
			self._keyData[inputKey] = nil

			-- if we removed a key, then the table/state changed
			didChange = true
		end
	end

	return didChange
end

local function ForKeys<KI, KO, M>(
	inputTable: PubTypes.CanBeState<{ [KI]: any }>,
	processor: (KI) -> (KO, M?),
	destructor: (KO, M?) -> ()?
): Types.ForKeys<KI, KO, M>
	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"

	local self = setmetatable({
		type = "State",
		kind = "ForKeys",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
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

end)() end,
    [66] = function()local wax,script,require=ImportGlobals(66)local ImportGlobals return (function(...)--!nonstrict

--[[
	Constructs a new ForPairs object which maps pairs of a table using
	a `processor` function.

	Optionally, a `destructor` function can be specified for cleaning up values.
	If omitted, the default cleanup function will be used instead.

	Additionally, a `meta` table/value can optionally be returned to pass data created
	when running the processor to the destructor when the created object is cleaned up.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
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

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

--[[
	Returns the current value of this ForPairs object.
	The object will be registered as a dependency unless `asDependency` is false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._outputTable
end

--[[
	Called when the original table is changed.

	This will firstly find any keys meeting any of the following criteria:

	- they were not previously present
	- their associated value has changed
	- a dependency used during generation of this value has changed

	It will recalculate those key/value pairs, storing information about any
	dependencies used in the processor callback during value generation, and
	save the new key/value pair to the output array. If it is overwriting an
	older key/value pair, that older pair will be passed to the destructor
	for cleanup.

	Finally, this function will find keys that are no longer present, and remove
	their key/value pairs from the output table and pass them to the destructor.
]]
function class:update(): boolean
	local inputIsState = self._inputIsState
	local newInputTable = if inputIsState then self._inputTable:get(false) else self._inputTable
	local oldInputTable = self._oldInputTable

	local keyIOMap = self._keyIOMap
	local meta = self._meta

	local didChange = false

	-- clean out main dependency set
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end

	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	-- if the input table is a state object, add it as a dependency
	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	-- clean out output table
	self._oldOutputTable, self._outputTable = self._outputTable, self._oldOutputTable

	local oldOutputTable = self._oldOutputTable
	local newOutputTable = self._outputTable
	table.clear(newOutputTable)

	-- Step 1: find key/value pairs that changed or were not previously present

	for newInKey, newInValue in pairs(newInputTable) do
		-- get or create key data
		local keyData = self._keyData[newInKey]

		if keyData == nil then
			keyData = {
				dependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				oldDependencySet = setmetatable({}, WEAK_KEYS_METATABLE),
				dependencyValues = setmetatable({}, WEAK_KEYS_METATABLE),
			}
			self._keyData[newInKey] = keyData
		end

		-- check if the pair is new or changed
		local shouldRecalculate = oldInputTable[newInKey] ~= newInValue

		-- check if the pair's dependencies have changed
		if shouldRecalculate == false then
			for dependency, oldValue in pairs(keyData.dependencyValues) do
				if oldValue ~= dependency:get(false) then
					shouldRecalculate = true
					break
				end
			end
		end

		-- recalculate the output pair if necessary
		if shouldRecalculate then
			keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet
			table.clear(keyData.dependencySet)

			local processOK, newOutKey, newOutValue, newMetaValue =
				captureDependencies(keyData.dependencySet, self._processor, newInKey, newInValue)

			if processOK then
				if
					self._destructor == nil
					and (needsDestruction(newOutKey) or needsDestruction(newOutValue) or needsDestruction(newMetaValue))
				then
					logWarn("destructorNeededForPairs")
				end

				-- if this key was already written to on this run-through, throw a fatal error.
				if newOutputTable[newOutKey] ~= nil then
					-- figure out which key/value pair previously wrote to this key
					local previousNewKey, previousNewValue
					for inKey, outKey in pairs(keyIOMap) do
						if outKey == newOutKey then
							previousNewValue = newInputTable[inKey]
							if previousNewValue ~= nil then
								previousNewKey = inKey
								break
							end
						end
					end

					if previousNewKey ~= nil then
						logError(
							"forPairsKeyCollision",
							nil,
							tostring(newOutKey),
							tostring(previousNewKey),
							tostring(previousNewValue),
							tostring(newInKey),
							tostring(newInValue)
						)
					end
				end

				local oldOutValue = oldOutputTable[newOutKey]

				if oldOutValue ~= newOutValue then
					local oldMetaValue = meta[newOutKey]
					if oldOutValue ~= nil then
						local destructOK, err =
							xpcall(self._destructor or cleanup, parseError, newOutKey, oldOutValue, oldMetaValue)
						if not destructOK then
							logErrorNonFatal("forPairsDestructorError", err)
						end
					end

					oldOutputTable[newOutKey] = nil
				end

				-- update the stored data for this key/value pair
				oldInputTable[newInKey] = newInValue
				keyIOMap[newInKey] = newOutKey
				meta[newOutKey] = newMetaValue
				newOutputTable[newOutKey] = newOutValue

				-- if we had to recalculate the output, then we did change
				didChange = true
			else
				-- restore old dependencies, because the new dependencies may be corrupt
				keyData.oldDependencySet, keyData.dependencySet = keyData.dependencySet, keyData.oldDependencySet

				logErrorNonFatal("forPairsProcessorError", newOutKey)
			end
		else
			local storedOutKey = keyIOMap[newInKey]

			-- check for key collision
			if newOutputTable[storedOutKey] ~= nil then
				-- figure out which key/value pair previously wrote to this key
				local previousNewKey, previousNewValue
				for inKey, outKey in pairs(keyIOMap) do
					if storedOutKey == outKey then
						previousNewValue = newInputTable[inKey]

						if previousNewValue ~= nil then
							previousNewKey = inKey
							break
						end
					end
				end

				if previousNewKey ~= nil then
					logError(
						"forPairsKeyCollision",
						nil,
						tostring(storedOutKey),
						tostring(previousNewKey),
						tostring(previousNewValue),
						tostring(newInKey),
						tostring(newInValue)
					)
				end
			end

			-- copy the stored key/value pair into the new output table
			newOutputTable[storedOutKey] = oldOutputTable[storedOutKey]
		end

		-- save dependency values and add to main dependency set
		for dependency in pairs(keyData.dependencySet) do
			keyData.dependencyValues[dependency] = dependency:get(false)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end

	-- STEP 2: find keys that were removed
	for oldOutKey, oldOutValue in pairs(oldOutputTable) do
		-- check if this key/value pair is in the new output table
		if newOutputTable[oldOutKey] ~= oldOutValue then
			-- clean up the old output pair
			local oldMetaValue = meta[oldOutKey]
			if oldOutValue ~= nil then
				local destructOK, err =
					xpcall(self._destructor or cleanup, parseError, oldOutKey, oldOutValue, oldMetaValue)
				if not destructOK then
					logErrorNonFatal("forPairsDestructorError", err)
				end
			end

			-- check if the key was completely removed from the output table
			if newOutputTable[oldOutKey] == nil then
				meta[oldOutKey] = nil
				self._keyData[oldOutKey] = nil
			end

			didChange = true
		end
	end

	for key in pairs(oldInputTable) do
		if newInputTable[key] == nil then
			oldInputTable[key] = nil
			keyIOMap[key] = nil
		end
	end

	return didChange
end

local function ForPairs<KI, VI, KO, VO, M>(
	inputTable: PubTypes.CanBeState<{ [KI]: VI }>,
	processor: (KI, VI) -> (KO, VO, M?),
	destructor: (KO, VO, M?) -> ()?
): Types.ForPairs<KI, VI, KO, VO, M>
	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"

	local self = setmetatable({
		type = "State",
		kind = "ForPairs",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
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

end)() end,
    [67] = function()local wax,script,require=ImportGlobals(67)local ImportGlobals return (function(...)--!nonstrict

--[[
	Constructs a new ForValues object which maps values of a table using
	a `processor` function.

	Optionally, a `destructor` function can be specified for cleaning up values.
	If omitted, the default cleanup function will be used instead.

	Additionally, a `meta` table/value can optionally be returned to pass data created
	when running the processor to the destructor when the created object is cleaned up.
]]
local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local captureDependencies = require(Package.Dependencies.captureDependencies)
local cleanup = require(Package.Utility.cleanup)
local initDependency = require(Package.Dependencies.initDependency)
local logErrorNonFatal = require(Package.Logging.logErrorNonFatal)
local logWarn = require(Package.Logging.logWarn)
local needsDestruction = require(Package.Utility.needsDestruction)
local parseError = require(Package.Logging.parseError)
local useDependency = require(Package.Dependencies.useDependency)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

--[[
	Returns the current value of this ForValues object.
	The object will be registered as a dependency unless `asDependency` is false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._outputTable
end

--[[
	Called when the original table is changed.

	This will firstly find any values meeting any of the following criteria:

	- they were not previously present
	- a dependency used during generation of this value has changed

	It will recalculate those values, storing information about any dependencies
	used in the processor callback during value generation, and save the new value
	to the output array with the same key. If it is overwriting an older value,
	that older value will be passed to the destructor for cleanup.

	Finally, this function will find values that are no longer present, and remove
	their values from the output table and pass them to the destructor. You can re-use
	the same value multiple times and this will function will update them as little as
	possible; reusing the same values where possible.
]]
function class:update(): boolean
	local inputIsState = self._inputIsState
	local inputTable = if inputIsState then self._inputTable:get(false) else self._inputTable
	local outputValues = {}

	local didChange = false

	-- clean out value cache
	self._oldValueCache, self._valueCache = self._valueCache, self._oldValueCache
	local newValueCache = self._valueCache
	local oldValueCache = self._oldValueCache
	table.clear(newValueCache)

	-- clean out main dependency set
	for dependency in pairs(self.dependencySet) do
		dependency.dependentSet[self] = nil
	end
	self._oldDependencySet, self.dependencySet = self.dependencySet, self._oldDependencySet
	table.clear(self.dependencySet)

	-- if the input table is a state object, add it as a dependency
	if inputIsState then
		self._inputTable.dependentSet[self] = true
		self.dependencySet[self._inputTable] = true
	end

	-- STEP 1: find values that changed or were not previously present
	for inKey, inValue in pairs(inputTable) do
		-- check if the value is new or changed
		local oldCachedValues = oldValueCache[inValue]
		local shouldRecalculate = oldCachedValues == nil

		-- get a cached value and its dependency/meta data if available
		local value, valueData, meta

		if type(oldCachedValues) == "table" and #oldCachedValues > 0 then
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

		-- check if the value's dependencies have changed
		if shouldRecalculate == false then
			for dependency, oldValue in pairs(valueData.dependencyValues) do
				if oldValue ~= dependency:get(false) then
					shouldRecalculate = true
					break
				end
			end
		end

		-- recalculate the output value if necessary
		if shouldRecalculate then
			valueData.oldDependencySet, valueData.dependencySet = valueData.dependencySet, valueData.oldDependencySet
			table.clear(valueData.dependencySet)

			local processOK, newOutValue, newMetaValue =
				captureDependencies(valueData.dependencySet, self._processor, inValue)

			if processOK then
				if self._destructor == nil and (needsDestruction(newOutValue) or needsDestruction(newMetaValue)) then
					logWarn("destructorNeededForValues")
				end

				-- pass the old value to the destructor if it exists
				if value ~= nil then
					local destructOK, err = xpcall(self._destructor or cleanup, parseError, value, meta)
					if not destructOK then
						logErrorNonFatal("forValuesDestructorError", err)
					end
				end

				-- store the new value and meta data
				value = newOutValue
				meta = newMetaValue
				didChange = true
			else
				-- restore old dependencies, because the new dependencies may be corrupt
				valueData.oldDependencySet, valueData.dependencySet =
					valueData.dependencySet, valueData.oldDependencySet

				logErrorNonFatal("forValuesProcessorError", newOutValue)
			end
		end

		-- store the value and its dependency/meta data
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

		-- save dependency values and add to main dependency set
		for dependency in pairs(valueData.dependencySet) do
			valueData.dependencyValues[dependency] = dependency:get(false)

			self.dependencySet[dependency] = true
			dependency.dependentSet[self] = true
		end
	end

	-- STEP 2: find values that were removed
	-- for tables of data, we just need to check if it's still in the cache
	for _oldInValue, oldCachedValueInfo in pairs(oldValueCache) do
		for _, valueInfo in ipairs(oldCachedValueInfo) do
			local oldValue = valueInfo.value
			local oldMetaValue = valueInfo.meta

			local destructOK, err = xpcall(self._destructor or cleanup, parseError, oldValue, oldMetaValue)
			if not destructOK then
				logErrorNonFatal("forValuesDestructorError", err)
			end

			didChange = true
		end

		table.clear(oldCachedValueInfo)
	end

	self._outputTable = outputValues

	return didChange
end

local function ForValues<VI, VO, M>(
	inputTable: PubTypes.CanBeState<{ [any]: VI }>,
	processor: (VI) -> (VO, M?),
	destructor: (VO, M?) -> ()?
): Types.ForValues<VI, VO, M>
	local inputIsState = inputTable.type == "State" and typeof(inputTable.get) == "function"

	local self = setmetatable({
		type = "State",
		kind = "ForValues",
		dependencySet = {},
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
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

end)() end,
    [68] = function()local wax,script,require=ImportGlobals(68)local ImportGlobals return (function(...)--!nonstrict

--[[
	Constructs a new state object which can listen for updates on another state
	object.

	FIXME: enabling strict types here causes free types to leak
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local Types = require(Package.Types)
local initDependency = require(Package.Dependencies.initDependency)

type Set<T> = { [T]: any }

local class = {}
local CLASS_METATABLE = { __index = class }

-- Table used to hold Observer objects in memory.
local strongRefs: Set<Types.Observer> = {}

--[[
	Called when the watched state changes value.
]]
function class:update(): boolean
	for _, callback in pairs(self._changeListeners) do
		task.spawn(callback)
	end
	return false
end

--[[
	Adds a change listener. When the watched state changes value, the listener
	will be fired.

	Returns a function which, when called, will disconnect the change listener.
	As long as there is at least one active change listener, this Observer
	will be held in memory, preventing GC, so disconnecting is important.
]]
function class:onChange(callback: () -> ()): () -> ()
	local uniqueIdentifier = {}

	self._numChangeListeners += 1
	self._changeListeners[uniqueIdentifier] = callback

	-- disallow gc (this is important to make sure changes are received)
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
			-- allow gc if all listeners are disconnected
			strongRefs[self] = nil
		end
	end
end

local function Observer(watchedState: PubTypes.Value<any>): Types.Observer
	local self = setmetatable({
		type = "State",
		kind = "Observer",
		dependencySet = { [watchedState] = true },
		dependentSet = {},
		_changeListeners = {},
		_numChangeListeners = 0,
	}, CLASS_METATABLE)

	initDependency(self)
	-- add this object to the watched state's dependent set
	watchedState.dependentSet[self] = true

	return self
end

return Observer

end)() end,
    [69] = function()local wax,script,require=ImportGlobals(69)local ImportGlobals return (function(...)--!nonstrict

--[[
	Constructs and returns objects which can be used to model independent
	reactive state.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local initDependency = require(Package.Dependencies.initDependency)
local isSimilar = require(Package.Utility.isSimilar)
local updateAll = require(Package.Dependencies.updateAll)
local useDependency = require(Package.Dependencies.useDependency)

local class = {}

local CLASS_METATABLE = { __index = class }
local WEAK_KEYS_METATABLE = { __mode = "k" }

--[[
	Returns the value currently stored in this State object.
	The state object will be registered as a dependency unless `asDependency` is
	false.
]]
function class:get(asDependency: boolean?): any
	if asDependency ~= false then
		useDependency(self)
	end
	return self._value
end

--[[
	Updates the value stored in this State object.

	If `force` is enabled, this will skip equality checks and always update the
	state object and any dependents - use this with care as this can lead to
	unnecessary updates.
]]
function class:set(newValue: any, force: boolean?)
	local oldValue = self._value
	if force or not isSimilar(oldValue, newValue) then
		self._value = newValue
		updateAll(self)
	end
end

local function Value<T>(initialValue: T): Types.State<T>
	local self = setmetatable({
		type = "State",
		kind = "Value",
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_value = initialValue,
	}, CLASS_METATABLE)

	initDependency(self)

	return self
end

return Value

end)() end,
    [70] = function()local wax,script,require=ImportGlobals(70)local ImportGlobals return (function(...)--!strict

--[[
	A common interface for accessing the values of state objects or constants.
]]

local Package = script.Parent.Parent
local PubTypes = require(Package.PubTypes)
local xtypeof = require(Package.Utility.xtypeof)

local function unwrap<T>(item: PubTypes.CanBeState<T>, useDependency: boolean?): T
	return if xtypeof(item) == "State" then (item :: PubTypes.StateObject<T>):get(useDependency) else item :: T
end

return unwrap

end)() end,
    [71] = function()local wax,script,require=ImportGlobals(71)local ImportGlobals return (function(...)--!strict

--[[
	Stores common type information used internally.

	These types may be used internally so Fusion code can type-check, but
	should never be exposed to public users, as these definitions are fair game
	for breaking changes.
]]

local Package = script.Parent
local PubTypes = require(Package.PubTypes)

type Set<T> = { [T]: any }

--[[
	General use types
]]

-- A symbol that represents the absence of a value.
export type None = PubTypes.Symbol & {
	-- name: "None" (add this when Luau supports singleton types)
}

-- Stores useful information about Luau errors.
export type Error = {
	type: string, -- replace with "Error" when Luau supports singleton types
	raw: string,
	message: string,
	trace: string,
}

--[[
	Specific reactive graph types
]]

-- A state object whose value can be set at any time by the user.
export type State<T> = PubTypes.Value<T> & {
	_value: T,
}

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = PubTypes.Computed<T> & {
	_oldDependencySet: Set<PubTypes.Dependency>,
	_callback: () -> T,
	_value: T,
}

-- A state object whose value is derived from other objects using a callback.
export type ForPairs<KI, VI, KO, VO, M> = PubTypes.ForPairs<KO, VO> & {
	_oldDependencySet: Set<PubTypes.Dependency>,
	_processor: (KI, VI) -> (KO, VO),
	_destructor: (VO, M?) -> (),
	_inputIsState: boolean,
	_inputTable: PubTypes.CanBeState<{ [KI]: VI }>,
	_oldInputTable: { [KI]: VI },
	_outputTable: { [KO]: VO },
	_oldOutputTable: { [KO]: VO },
	_keyIOMap: { [KI]: KO },
	_meta: { [KO]: M? },
	_keyData: {
		[KI]: {
			dependencySet: Set<PubTypes.Dependency>,
			oldDependencySet: Set<PubTypes.Dependency>,
			dependencyValues: { [PubTypes.Dependency]: any },
		},
	},
}

-- A state object whose value is derived from other objects using a callback.
export type ForKeys<KI, KO, M> = PubTypes.ForKeys<KO, any> & {
	_oldDependencySet: Set<PubTypes.Dependency>,
	_processor: (KI) -> KO,
	_destructor: (KO, M?) -> (),
	_inputIsState: boolean,
	_inputTable: PubTypes.CanBeState<{ [KI]: KO }>,
	_oldInputTable: { [KI]: KO },
	_outputTable: { [KO]: any },
	_keyOIMap: { [KO]: KI },
	_meta: { [KO]: M? },
	_keyData: {
		[KI]: {
			dependencySet: Set<PubTypes.Dependency>,
			oldDependencySet: Set<PubTypes.Dependency>,
			dependencyValues: { [PubTypes.Dependency]: any },
		},
	},
}

-- A state object whose value is derived from other objects using a callback.
export type ForValues<VI, VO, M> = PubTypes.ForValues<any, VO> & {
	_oldDependencySet: Set<PubTypes.Dependency>,
	_processor: (VI) -> VO,
	_destructor: (VO, M?) -> (),
	_inputIsState: boolean,
	_inputTable: PubTypes.CanBeState<{ [VI]: VO }>,
	_outputTable: { [any]: VI },
	_valueCache: { [VO]: any },
	_oldValueCache: { [VO]: any },
	_meta: { [VO]: M? },
	_valueData: {
		[VI]: {
			dependencySet: Set<PubTypes.Dependency>,
			oldDependencySet: Set<PubTypes.Dependency>,
			dependencyValues: { [PubTypes.Dependency]: any },
		},
	},
}

-- A state object which follows another state object using tweens.
export type Tween<T> = PubTypes.Tween<T> & {
	_goalState: State<T>,
	_tweenInfo: TweenInfo,
	_prevValue: T,
	_nextValue: T,
	_currentValue: T,
	_currentTweenInfo: TweenInfo,
	_currentTweenDuration: number,
	_currentTweenStartTime: number,
	_currentlyAnimating: boolean,
}

-- A state object which follows another state object using spring simulation.
export type Spring<T> = PubTypes.Spring<T> & {
	_speed: PubTypes.CanBeState<number>,
	_speedIsState: boolean,
	_lastSpeed: number,
	_damping: PubTypes.CanBeState<number>,
	_dampingIsState: boolean,
	_lastDamping: number,
	_goalState: State<T>,
	_goalValue: T,
	_currentType: string,
	_currentValue: T,
	_springPositions: { number },
	_springGoals: { number },
	_springVelocities: { number },
}

-- An object which can listen for updates on another state object.
export type Observer = PubTypes.Observer & {
	_changeListeners: Set<() -> ()>,
	_numChangeListeners: number,
}

return nil

end)() end,
    [73] = function()local wax,script,require=ImportGlobals(73)local ImportGlobals return (function(...)--!strict

--[[
	A symbol for representing nil values in contexts where nil is not usable.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)

return {
	type = "Symbol",
	name = "None",
} :: Types.None

end)() end,
    [74] = function()local wax,script,require=ImportGlobals(74)local ImportGlobals return (function(...)--!strict

--[[
	Cleans up the tasks passed in as the arguments.
	A task can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]

local function cleanupOne(task: any)
	local taskType = typeof(task)

	-- case 1: Instance
	if taskType == "Instance" then
		task:Destroy()

	-- case 2: RBXScriptConnection
	elseif taskType == "RBXScriptConnection" then
		task:Disconnect()

	-- case 3: callback
	elseif taskType == "function" then
		task()
	elseif taskType == "table" then
		-- case 4: destroy() function
		if typeof(task.destroy) == "function" then
			task:destroy()

		-- case 5: Destroy() function
		elseif typeof(task.Destroy) == "function" then
			task:Destroy()

		-- case 6: array of tasks
		elseif task[1] ~= nil then
			for _, subtask in ipairs(task) do
				cleanupOne(subtask)
			end
		end
	end
end

local function cleanup(...: any)
	for index = 1, select("#", ...) do
		cleanupOne(select(index, ...))
	end
end

return cleanup

end)() end,
    [75] = function()local wax,script,require=ImportGlobals(75)local ImportGlobals return (function(...)--!strict

--[[
	An empty function. Often used as a destructor to indicate no destruction.
]]

local function doNothing(...: any) end

return doNothing

end)() end,
    [76] = function()local wax,script,require=ImportGlobals(76)local ImportGlobals return (function(...)--!strict
--[[
    Returns true if A and B are 'similar' - i.e. any user of A would not need
    to recompute if it changed to B.
]]

local function isSimilar(a: any, b: any): boolean
	-- HACK: because tables are mutable data structures, don't make assumptions
	-- about similarity from equality for now (see issue #44)
	if typeof(a) == "table" then
		return false
	else
		return a == b
	end
end

return isSimilar

end)() end,
    [77] = function()local wax,script,require=ImportGlobals(77)local ImportGlobals return (function(...)--!strict

--[[
    Returns true if the given value is not automatically memory managed, and
    requires manual cleanup.
]]

local function needsDestruction(x: any): boolean
	return typeof(x) == "Instance"
end

return needsDestruction

end)() end,
    [78] = function()local wax,script,require=ImportGlobals(78)local ImportGlobals return (function(...)--!strict

--[[
	Restricts the reading of missing members for a table.
]]

local Package = script.Parent.Parent
local logError = require(Package.Logging.logError)

type table = { [any]: any }

local function restrictRead(tableName: string, strictTable: table): table
	-- FIXME: Typed Luau doesn't recognise this correctly yet
	local metatable = getmetatable(strictTable :: any)

	if metatable == nil then
		metatable = {}
		setmetatable(strictTable, metatable)
	end

	function metatable:__index(memberName)
		logError("strictReadError", nil, tostring(memberName), tableName)
	end

	return strictTable
end

return restrictRead

end)() end,
    [79] = function()local wax,script,require=ImportGlobals(79)local ImportGlobals return (function(...)--!strict

--[[
	Extended typeof, designed for identifying custom objects.
	If given a table with a `type` string, returns that.
	Otherwise, returns `typeof()` the argument.
]]

local function xtypeof(x: any)
	local typeString = typeof(x)

	if typeString == "table" and typeof(x.type) == "string" then
		return x.type
	else
		return typeString
	end
end

return xtypeof

end)() end,
    [80] = function()local wax,script,require=ImportGlobals(80)local ImportGlobals return (function(...)---	Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy
-- @classmod Maid
-- @see Signal

local Maid = {}
Maid.ClassName = "Maid"

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid.isMaid(value)
	return type(value) == "table" and value.ClassName == "Maid"
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up. Tasks given to a maid will be cleaned when
--  maid[index] is set to a different value.
-- @usage
-- Maid[key] = (function)         Adds a task to perform
-- Maid[key] = (event connection) Manages an event connection
-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
--                                it is destroyed.
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
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
	if not task then
		error("Task cannot be false or nil", 2)
	end

	local taskId = #self._tasks+1
	self[taskId] = task

	return taskId
end

function Maid:GivePromise(promise)
	if not promise:IsPending() then
		return promise
	end

	local newPromise = promise.resolved(promise)
	local id = self:GiveTask(newPromise)

	-- Ensure GC
	newPromise:Finally(function()
		self[id] = nil
	end)

	return newPromise
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
		index, task = next(tasks)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

return Maid
end)() end,
    [81] = function()local wax,script,require=ImportGlobals(81)local ImportGlobals return (function(...)--[[
	An implementation of Promises similar to Promise/A+.
]]

local ERROR_NON_PROMISE_IN_LIST = "Non-promise value passed into %s at index %s"
local ERROR_NON_LIST = "Please pass a list of promises to %s"
local ERROR_NON_FUNCTION = "Please pass a handler function to %s!"
local MODE_KEY_METATABLE = { __mode = "k" }

local function isCallable(value)
	if type(value) == "function" then
		return true
	end

	if type(value) == "table" then
		local metatable = getmetatable(value)
		if metatable and type(rawget(metatable, "__call")) == "function" then
			return true
		end
	end

	return false
end

--[[
	Creates an enum dictionary with some metamethods to prevent common mistakes.
]]
local function makeEnum(enumName, members)
	local enum = {}

	for _, memberName in ipairs(members) do
		enum[memberName] = memberName
	end

	return setmetatable(enum, {
		__index = function(_, k)
			error(string.format("%s is not in %s!", k, enumName), 2)
		end,
		__newindex = function()
			error(string.format("Creating new members in %s is not allowed!", enumName), 2)
		end,
	})
end

--[=[
	An object to represent runtime errors that occur during execution.
	Promises that experience an error like this will be rejected with
	an instance of this object.

	@class Error
]=]
local Error
do
	Error = {
		Kind = makeEnum("Promise.Error.Kind", {
			"ExecutionError",
			"AlreadyCancelled",
			"NotResolvedInTime",
			"TimedOut",
		}),
	}
	Error.__index = Error

	function Error.new(options, parent)
		options = options or {}
		return setmetatable({
			error = tostring(options.error) or "[This error has no error text.]",
			trace = options.trace,
			context = options.context,
			kind = options.kind,
			parent = parent,
			createdTick = os.clock(),
			createdTrace = debug.traceback(),
		}, Error)
	end

	function Error.is(anything)
		if type(anything) == "table" then
			local metatable = getmetatable(anything)

			if type(metatable) == "table" then
				return rawget(anything, "error") ~= nil and type(rawget(metatable, "extend")) == "function"
			end
		end

		return false
	end

	function Error.isKind(anything, kind)
		assert(kind ~= nil, "Argument #2 to Promise.Error.isKind must not be nil")

		return Error.is(anything) and anything.kind == kind
	end

	function Error:extend(options)
		options = options or {}

		options.kind = options.kind or self.kind

		return Error.new(options, self)
	end

	function Error:getErrorChain()
		local runtimeErrors = { self }

		while runtimeErrors[#runtimeErrors].parent do
			table.insert(runtimeErrors, runtimeErrors[#runtimeErrors].parent)
		end

		return runtimeErrors
	end

	function Error:__tostring()
		local errorStrings = {
			string.format("-- Promise.Error(%s) --", self.kind or "?"),
		}

		for _, runtimeError in ipairs(self:getErrorChain()) do
			table.insert(
				errorStrings,
				table.concat({
					runtimeError.trace or runtimeError.error,
					runtimeError.context,
				}, "\n")
			)
		end

		return table.concat(errorStrings, "\n")
	end
end

--[[
	Packs a number of arguments into a table and returns its length.

	Used to cajole varargs without dropping sparse values.
]]
local function pack(...)
	return select("#", ...), { ... }
end

--[[
	Returns first value (success), and packs all following values.
]]
local function packResult(success, ...)
	return success, select("#", ...), { ... }
end

local function makeErrorHandler(traceback)
	assert(traceback ~= nil, "traceback is nil")

	return function(err)
		-- If the error object is already a table, forward it directly.
		-- Should we extend the error here and add our own trace?

		if type(err) == "table" then
			return err
		end

		return Error.new({
			error = err,
			kind = Error.Kind.ExecutionError,
			trace = debug.traceback(tostring(err), 2),
			context = "Promise created at:\n\n" .. traceback,
		})
	end
end

--[[
	Calls a Promise executor with error handling.
]]
local function runExecutor(traceback, callback, ...)
	return packResult(xpcall(callback, makeErrorHandler(traceback), ...))
end

--[[
	Creates a function that invokes a callback with correct error handling and
	resolution mechanisms.
]]
local function createAdvancer(traceback, callback, resolve, reject)
	return function(...)
		local ok, resultLength, result = runExecutor(traceback, callback, ...)

		if ok then
			resolve(unpack(result, 1, resultLength))
		else
			reject(result[1])
		end
	end
end

local function isEmpty(t)
	return next(t) == nil
end

--[=[
	An enum value used to represent the Promise's status.
	@interface Status
	@tag enum
	@within Promise
	.Started "Started" -- The Promise is executing, and not settled yet.
	.Resolved "Resolved" -- The Promise finished successfully.
	.Rejected "Rejected" -- The Promise was rejected.
	.Cancelled "Cancelled" -- The Promise was cancelled before it finished.
]=]
--[=[
	@prop Status Status
	@within Promise
	@readonly
	@tag enums
	A table containing all members of the `Status` enum, e.g., `Promise.Status.Resolved`.
]=]
--[=[
	A Promise is an object that represents a value that will exist in the future, but doesn't right now.
	Promises allow you to then attach callbacks that can run once the value becomes available (known as *resolving*),
	or if an error has occurred (known as *rejecting*).

	@class Promise
	@__index prototype
]=]
local Promise = {
	Error = Error,
	Status = makeEnum("Promise.Status", { "Started", "Resolved", "Rejected", "Cancelled" }),
	_getTime = os.clock,
	_timeEvent = game:GetService("RunService").Heartbeat,
	_unhandledRejectionCallbacks = {},
}
Promise.prototype = {}
Promise.__index = Promise.prototype

function Promise._new(traceback, callback, parent)
	if parent ~= nil and not Promise.is(parent) then
		error("Argument #2 to Promise.new must be a promise or nil", 2)
	end

	local self = {
		-- The executor thread.
		_thread = nil,

		-- Used to locate where a promise was created
		_source = traceback,

		_status = Promise.Status.Started,

		-- A table containing a list of all results, whether success or failure.
		-- Only valid if _status is set to something besides Started
		_values = nil,

		-- Lua doesn't like sparse arrays very much, so we explicitly store the
		-- length of _values to handle middle nils.
		_valuesLength = -1,

		-- Tracks if this Promise has no error observers..
		_unhandledRejection = true,

		-- Queues representing functions we should invoke when we update!
		_queuedResolve = {},
		_queuedReject = {},
		_queuedFinally = {},

		-- The function to run when/if this promise is cancelled.
		_cancellationHook = nil,

		-- The "parent" of this promise in a promise chain. Required for
		-- cancellation propagation upstream.
		_parent = parent,

		-- Consumers are Promises that have chained onto this one.
		-- We track them for cancellation propagation downstream.
		_consumers = setmetatable({}, MODE_KEY_METATABLE),
	}

	if parent and parent._status == Promise.Status.Started then
		parent._consumers[self] = true
	end

	setmetatable(self, Promise)

	local function resolve(...)
		self:_resolve(...)
	end

	local function reject(...)
		self:_reject(...)
	end

	local function onCancel(cancellationHook)
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

--[=[
	Construct a new Promise that will be resolved or rejected with the given callbacks.

	If you `resolve` with a Promise, it will be chained onto.

	You can safely yield within the executor function and it will not block the creating thread.

	```lua
	local myFunction()
		return Promise.new(function(resolve, reject, onCancel)
			wait(1)
			resolve("Hello world!")
		end)
	end

	myFunction():andThen(print)
	```

	You do not need to use `pcall` within a Promise. Errors that occur during execution will be caught and turned into a rejection automatically. If `error()` is called with a table, that table will be the rejection value. Otherwise, string errors will be converted into `Promise.Error(Promise.Error.Kind.ExecutionError)` objects for tracking debug information.

	You may register an optional cancellation hook by using the `onCancel` argument:

	* This should be used to abort any ongoing operations leading up to the promise being settled.
	* Call the `onCancel` function with a function callback as its only argument to set a hook which will in turn be called when/if the promise is cancelled.
	* `onCancel` returns `true` if the Promise was already cancelled when you called `onCancel`.
	* Calling `onCancel` with no argument will not override a previously set cancellation hook, but it will still return `true` if the Promise is currently cancelled.
	* You can set the cancellation hook at any time before resolving.
	* When a promise is cancelled, calls to `resolve` or `reject` will be ignored, regardless of if you set a cancellation hook or not.

	:::caution
	If the Promise is cancelled, the `executor` thread is closed with `coroutine.close` after the cancellation hook is called.

	You must perform any cleanup code in the cancellation hook: any time your executor yields, it **may never resume**.
	:::

	@param executor (resolve: (...: any) -> (), reject: (...: any) -> (), onCancel: (abortHandler?: () -> ()) -> boolean) -> ()
	@return Promise
]=]
function Promise.new(executor)
	return Promise._new(debug.traceback(nil, 2), executor)
end

function Promise:__tostring()
	return string.format("Promise(%s)", self._status)
end

--[=[
	The same as [Promise.new](/api/Promise#new), except execution begins after the next `Heartbeat` event.

	This is a spiritual replacement for `spawn`, but it does not suffer from the same [issues](https://eryn.io/gist/3db84579866c099cdd5bb2ff37947cec) as `spawn`.

	```lua
	local function waitForChild(instance, childName, timeout)
	  return Promise.defer(function(resolve, reject)
		local child = instance:WaitForChild(childName, timeout)

		;(child and resolve or reject)(child)
	  end)
	end
	```

	@param executor (resolve: (...: any) -> (), reject: (...: any) -> (), onCancel: (abortHandler?: () -> ()) -> boolean) -> ()
	@return Promise
]=]
function Promise.defer(executor)
	local traceback = debug.traceback(nil, 2)
	local promise
	promise = Promise._new(traceback, function(resolve, reject, onCancel)
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

-- Backwards compatibility
Promise.async = Promise.defer

--[=[
	Creates an immediately resolved Promise with the given value.

	```lua
	-- Example using Promise.resolve to deliver cached values:
	function getSomething(name)
		if cache[name] then
			return Promise.resolve(cache[name])
		else
			return Promise.new(function(resolve, reject)
				local thing = getTheThing()
				cache[name] = thing

				resolve(thing)
			end)
		end
	end
	```

	@param ... any
	@return Promise<...any>
]=]
function Promise.resolve(...)
	local length, values = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(resolve)
		resolve(unpack(values, 1, length))
	end)
end

--[=[
	Creates an immediately rejected Promise with the given value.

	:::caution
	Something needs to consume this rejection (i.e. `:catch()` it), otherwise it will emit an unhandled Promise rejection warning on the next frame. Thus, you should not create and store rejected Promises for later use. Only create them on-demand as needed.
	:::

	@param ... any
	@return Promise<...any>
]=]
function Promise.reject(...)
	local length, values = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(_, reject)
		reject(unpack(values, 1, length))
	end)
end

--[[
	Runs a non-promise-returning function as a Promise with the
  given arguments.
]]
function Promise._try(traceback, callback, ...)
	local valuesLength, values = pack(...)

	return Promise._new(traceback, function(resolve)
		resolve(callback(unpack(values, 1, valuesLength)))
	end)
end

--[=[
	Begins a Promise chain, calling a function and returning a Promise resolving with its return value. If the function errors, the returned Promise will be rejected with the error. You can safely yield within the Promise.try callback.

	:::info
	`Promise.try` is similar to [Promise.promisify](#promisify), except the callback is invoked immediately instead of returning a new function.
	:::

	```lua
	Promise.try(function()
		return math.random(1, 2) == 1 and "ok" or error("Oh an error!")
	end)
		:andThen(function(text)
			print(text)
		end)
		:catch(function(err)
			warn("Something went wrong")
		end)
	```

	@param callback (...: T...) -> ...any
	@param ... T... -- Additional arguments passed to `callback`
	@return Promise
]=]
function Promise.try(callback, ...)
	return Promise._try(debug.traceback(nil, 2), callback, ...)
end

--[[
	Returns a new promise that:
		* is resolved when all input promises resolve
		* is rejected if ANY input promises reject
]]
function Promise._all(traceback, promises, amount)
	if type(promises) ~= "table" then
		error(string.format(ERROR_NON_LIST, "Promise.all"), 3)
	end

	-- We need to check that each value is a promise here so that we can produce
	-- a proper error rather than a rejected promise with our error.
	for i, promise in pairs(promises) do
		if not Promise.is(promise) then
			error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.all", tostring(i)), 3)
		end
	end

	-- If there are no values then return an already resolved promise.
	if #promises == 0 or amount == 0 then
		return Promise.resolve({})
	end

	return Promise._new(traceback, function(resolve, reject, onCancel)
		-- An array to contain our resolved values from the given promises.
		local resolvedValues = {}
		local newPromises = {}

		-- Keep a count of resolved promises because just checking the resolved
		-- values length wouldn't account for promises that resolve with nil.
		local resolvedCount = 0
		local rejectedCount = 0
		local done = false

		local function cancel()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end

		-- Called when a single value is resolved and resolves if all are done.
		local function resolveOne(i, ...)
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

		-- We can assume the values inside `promises` are all promises since we
		-- checked above.
		for i, promise in ipairs(promises) do
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

--[=[
	Accepts an array of Promises and returns a new promise that:
	* is resolved after all input promises resolve.
	* is rejected if *any* input promises reject.

	:::info
	Only the first return value from each promise will be present in the resulting array.
	:::

	After any input Promise rejects, all other input Promises that are still pending will be cancelled if they have no other consumers.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.all(promises)
	```

	@param promises {Promise<T>}
	@return Promise<{T}>
]=]
function Promise.all(promises)
	return Promise._all(debug.traceback(nil, 2), promises)
end

--[=[
	Folds an array of values or promises into a single value. The array is traversed sequentially.

	The reducer function can return a promise or value directly. Each iteration receives the resolved value from the previous, and the first receives your defined initial value.

	The folding will stop at the first rejection encountered.
	```lua
	local basket = {"blueberry", "melon", "pear", "melon"}
	Promise.fold(basket, function(cost, fruit)
		if fruit == "blueberry" then
			return cost -- blueberries are free!
		else
			-- call a function that returns a promise with the fruit price
			return fetchPrice(fruit):andThen(function(fruitCost)
				return cost + fruitCost
			end)
		end
	end, 0)
	```

	@since v3.1.0
	@param list {T | Promise<T>}
	@param reducer (accumulator: U, value: T, index: number) -> U | Promise<U>
	@param initialValue U
]=]
function Promise.fold(list, reducer, initialValue)
	assert(type(list) == "table", "Bad argument #1 to Promise.fold: must be a table")
	assert(isCallable(reducer), "Bad argument #2 to Promise.fold: must be a function")

	local accumulator = Promise.resolve(initialValue)
	return Promise.each(list, function(resolvedElement, i)
		accumulator = accumulator:andThen(function(previousValueResolved)
			return reducer(previousValueResolved, resolvedElement, i)
		end)
	end):andThen(function()
		return accumulator
	end)
end

--[=[
	Accepts an array of Promises and returns a Promise that is resolved as soon as `count` Promises are resolved from the input array. The resolved array values are in the order that the Promises resolved in. When this Promise resolves, all other pending Promises are cancelled if they have no other consumers.

	`count` 0 results in an empty array. The resultant array will never have more than `count` elements.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.some(promises, 2) -- Only resolves with first 2 promises to resolve
	```

	@param promises {Promise<T>}
	@param count number
	@return Promise<{T}>
]=]
function Promise.some(promises, count)
	assert(type(count) == "number", "Bad argument #2 to Promise.some: must be a number")

	return Promise._all(debug.traceback(nil, 2), promises, count)
end

--[=[
	Accepts an array of Promises and returns a Promise that is resolved as soon as *any* of the input Promises resolves. It will reject only if *all* input Promises reject. As soon as one Promises resolves, all other pending Promises are cancelled if they have no other consumers.

	Resolves directly with the value of the first resolved Promise. This is essentially [[Promise.some]] with `1` count, except the Promise resolves with the value directly instead of an array with one element.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.any(promises) -- Resolves with first value to resolve (only rejects if all 3 rejected)
	```

	@param promises {Promise<T>}
	@return Promise<T>
]=]
function Promise.any(promises)
	return Promise._all(debug.traceback(nil, 2), promises, 1):andThen(function(values)
		return values[1]
	end)
end

--[=[
	Accepts an array of Promises and returns a new Promise that resolves with an array of in-place Statuses when all input Promises have settled. This is equivalent to mapping `promise:finally` over the array of Promises.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.allSettled(promises)
	```

	@param promises {Promise<T>}
	@return Promise<{Status}>
]=]
function Promise.allSettled(promises)
	if type(promises) ~= "table" then
		error(string.format(ERROR_NON_LIST, "Promise.allSettled"), 2)
	end

	-- We need to check that each value is a promise here so that we can produce
	-- a proper error rather than a rejected promise with our error.
	for i, promise in pairs(promises) do
		if not Promise.is(promise) then
			error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.allSettled", tostring(i)), 2)
		end
	end

	-- If there are no values then return an already resolved promise.
	if #promises == 0 then
		return Promise.resolve({})
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
		-- An array to contain our resolved values from the given promises.
		local fates = {}
		local newPromises = {}

		-- Keep a count of resolved promises because just checking the resolved
		-- values length wouldn't account for promises that resolve with nil.
		local finishedCount = 0

		-- Called when a single value is resolved and resolves if all are done.
		local function resolveOne(i, ...)
			finishedCount = finishedCount + 1

			fates[i] = ...

			if finishedCount >= #promises then
				resolve(fates)
			end
		end

		onCancel(function()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end)

		-- We can assume the values inside `promises` are all promises since we
		-- checked above.
		for i, promise in ipairs(promises) do
			newPromises[i] = promise:finally(function(...)
				resolveOne(i, ...)
			end)
		end
	end)
end

--[=[
	Accepts an array of Promises and returns a new promise that is resolved or rejected as soon as any Promise in the array resolves or rejects.

	:::warning
	If the first Promise to settle from the array settles with a rejection, the resulting Promise from `race` will reject.

	If you instead want to tolerate rejections, and only care about at least one Promise resolving, you should use [Promise.any](#any) or [Promise.some](#some) instead.
	:::

	All other Promises that don't win the race will be cancelled if they have no other consumers.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.race(promises) -- Only returns 1st value to resolve or reject
	```

	@param promises {Promise<T>}
	@return Promise<T>
]=]
function Promise.race(promises)
	assert(type(promises) == "table", string.format(ERROR_NON_LIST, "Promise.race"))

	for i, promise in pairs(promises) do
		assert(Promise.is(promise), string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.race", tostring(i)))
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local newPromises = {}
		local finished = false

		local function cancel()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end

		local function finalize(callback)
			return function(...)
				cancel()
				finished = true
				return callback(...)
			end
		end

		if onCancel(finalize(reject)) then
			return
		end

		for i, promise in ipairs(promises) do
			newPromises[i] = promise:andThen(finalize(resolve), finalize(reject))
		end

		if finished then
			cancel()
		end
	end)
end

--[=[
	Iterates serially over the given an array of values, calling the predicate callback on each value before continuing.

	If the predicate returns a Promise, we wait for that Promise to resolve before moving on to the next item
	in the array.

	:::info
	`Promise.each` is similar to `Promise.all`, except the Promises are ran in order instead of all at once.

	But because Promises are eager, by the time they are created, they're already running. Thus, we need a way to defer creation of each Promise until a later time.

	The predicate function exists as a way for us to operate on our data instead of creating a new closure for each Promise. If you would prefer, you can pass in an array of functions, and in the predicate, call the function and return its return value.
	:::

	```lua
	Promise.each({
		"foo",
		"bar",
		"baz",
		"qux"
	}, function(value, index)
		return Promise.delay(1):andThen(function()
		print(("%d) Got %s!"):format(index, value))
		end)
	end)

	--[[
		(1 second passes)
		> 1) Got foo!
		(1 second passes)
		> 2) Got bar!
		(1 second passes)
		> 3) Got baz!
		(1 second passes)
		> 4) Got qux!
	]]
	```

	If the Promise a predicate returns rejects, the Promise from `Promise.each` is also rejected with the same value.

	If the array of values contains a Promise, when we get to that point in the list, we wait for the Promise to resolve before calling the predicate with the value.

	If a Promise in the array of values is already Rejected when `Promise.each` is called, `Promise.each` rejects with that value immediately (the predicate callback will never be called even once). If a Promise in the list is already Cancelled when `Promise.each` is called, `Promise.each` rejects with `Promise.Error(Promise.Error.Kind.AlreadyCancelled`). If a Promise in the array of values is Started at first, but later rejects, `Promise.each` will reject with that value and iteration will not continue once iteration encounters that value.

	Returns a Promise containing an array of the returned/resolved values from the predicate for each item in the array of values.

	If this Promise returned from `Promise.each` rejects or is cancelled for any reason, the following are true:
	- Iteration will not continue.
	- Any Promises within the array of values will now be cancelled if they have no other consumers.
	- The Promise returned from the currently active predicate will be cancelled if it hasn't resolved yet.

	@since 3.0.0
	@param list {T | Promise<T>}
	@param predicate (value: T, index: number) -> U | Promise<U>
	@return Promise<{U}>
]=]
function Promise.each(list, predicate)
	assert(type(list) == "table", string.format(ERROR_NON_LIST, "Promise.each"))
	assert(isCallable(predicate), string.format(ERROR_NON_FUNCTION, "Promise.each"))

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local results = {}
		local promisesToCancel = {}

		local cancelled = false

		local function cancel()
			for _, promiseToCancel in ipairs(promisesToCancel) do
				promiseToCancel:cancel()
			end
		end

		onCancel(function()
			cancelled = true

			cancel()
		end)

		-- We need to preprocess the list of values and look for Promises.
		-- If we find some, we must register our andThen calls now, so that those Promises have a consumer
		-- from us registered. If we don't do this, those Promises might get cancelled by something else
		-- before we get to them in the series because it's not possible to tell that we plan to use it
		-- unless we indicate it here.

		local preprocessedList = {}

		for index, value in ipairs(list) do
			if Promise.is(value) then
				if value:getStatus() == Promise.Status.Cancelled then
					cancel()
					return reject(Error.new({
						error = "Promise is cancelled",
						kind = Error.Kind.AlreadyCancelled,
						context = string.format(
							"The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s",
							index,
							value._source
						),
					}))
				elseif value:getStatus() == Promise.Status.Rejected then
					cancel()
					return reject(select(2, value:await()))
				end

				-- Chain a new Promise from this one so we only cancel ours
				local ourPromise = value:andThen(function(...)
					return ...
				end)

				table.insert(promisesToCancel, ourPromise)
				preprocessedList[index] = ourPromise
			else
				preprocessedList[index] = value
			end
		end

		for index, value in ipairs(preprocessedList) do
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

--[=[
	Checks whether the given object is a Promise via duck typing. This only checks if the object is a table and has an `andThen` method.

	@param object any
	@return boolean -- `true` if the given `object` is a Promise.
]=]
function Promise.is(object)
	if type(object) ~= "table" then
		return false
	end

	local objectMetatable = getmetatable(object)

	if objectMetatable == Promise then
		-- The Promise came from this library.
		return true
	elseif objectMetatable == nil then
		-- No metatable, but we should still chain onto tables with andThen methods
		return isCallable(object.andThen)
	elseif
		type(objectMetatable) == "table"
		and type(rawget(objectMetatable, "__index")) == "table"
		and isCallable(rawget(rawget(objectMetatable, "__index"), "andThen"))
	then
		-- Maybe this came from a different or older Promise library.
		return true
	end

	return false
end

--[=[
	Wraps a function that yields into one that returns a Promise.

	Any errors that occur while executing the function will be turned into rejections.

	:::info
	`Promise.promisify` is similar to [Promise.try](#try), except the callback is returned as a callable function instead of being invoked immediately.
	:::

	```lua
	local sleep = Promise.promisify(wait)

	sleep(1):andThen(print)
	```

	```lua
	local isPlayerInGroup = Promise.promisify(function(player, groupId)
		return player:IsInGroup(groupId)
	end)
	```

	@param callback (...: any) -> ...any
	@return (...: any) -> Promise
]=]
function Promise.promisify(callback)
	return function(...)
		return Promise._try(debug.traceback(nil, 2), callback, ...)
	end
end

--[=[
	Returns a Promise that resolves after `seconds` seconds have passed. The Promise resolves with the actual amount of time that was waited.

	This function is **not** a wrapper around `wait`. `Promise.delay` uses a custom scheduler which provides more accurate timing. As an optimization, cancelling this Promise instantly removes the task from the scheduler.

	:::warning
	Passing `NaN`, infinity, or a number less than 1/60 is equivalent to passing 1/60.
	:::

	```lua
		Promise.delay(5):andThenCall(print, "This prints after 5 seconds")
	```

	@function delay
	@within Promise
	@param seconds number
	@return Promise<number>
]=]
do
	-- uses a sorted doubly linked list (queue) to achieve O(1) remove operations and O(n) for insert

	-- the initial node in the linked list
	local first
	local connection

	function Promise.delay(seconds)
		assert(type(seconds) == "number", "Bad argument #1 to Promise.delay, must be a number.")
		-- If seconds is -INF, INF, NaN, or less than 1 / 60, assume seconds is 1 / 60.
		-- This mirrors the behavior of wait()
		if not (seconds >= 1 / 60) or seconds == math.huge then
			seconds = 1 / 60
		end

		return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
			local startTime = Promise._getTime()
			local endTime = startTime + seconds

			local node = {
				resolve = resolve,
				startTime = startTime,
				endTime = endTime,
			}

			if connection == nil then -- first is nil when connection is nil
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
			else -- first is non-nil
				if first.endTime < endTime then -- if `node` should be placed after `first`
					-- we will insert `node` between `current` and `next`
					-- (i.e. after `current` if `next` is nil)
					local current = first
					local next = current.next

					while next ~= nil and next.endTime < endTime do
						current = next
						next = current.next
					end

					-- `current` must be non-nil, but `next` could be `nil` (i.e. last item in list)
					current.next = node
					node.previous = current

					if next ~= nil then
						node.next = next
						next.previous = node
					end
				else
					-- set `node` to `first`
					node.next = first
					first.previous = node
					first = node
				end
			end

			onCancel(function()
				-- remove node from queue
				local next = node.next

				if first == node then
					if next == nil then -- if `node` is the first and last
						connection:Disconnect()
						connection = nil
					else -- if `node` is `first` and not the last
						next.previous = nil
					end
					first = next
				else
					local previous = node.previous
					-- since `node` is not `first`, then we know `previous` is non-nil
					previous.next = next

					if next ~= nil then
						next.previous = previous
					end
				end
			end)
		end)
	end
end

--[=[
	Returns a new Promise that resolves if the chained Promise resolves within `seconds` seconds, or rejects if execution time exceeds `seconds`. The chained Promise will be cancelled if the timeout is reached.

	Rejects with `rejectionValue` if it is non-nil. If a `rejectionValue` is not given, it will reject with a `Promise.Error(Promise.Error.Kind.TimedOut)`. This can be checked with [[Error.isKind]].

	```lua
	getSomething():timeout(5):andThen(function(something)
		-- got something and it only took at max 5 seconds
	end):catch(function(e)
		-- Either getting something failed or the time was exceeded.

		if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
			warn("Operation timed out!")
		else
			warn("Operation encountered an error!")
		end
	end)
	```

	Sugar for:

	```lua
	Promise.race({
		Promise.delay(seconds):andThen(function()
			return Promise.reject(
				rejectionValue == nil
				and Promise.Error.new({ kind = Promise.Error.Kind.TimedOut })
				or rejectionValue
			)
		end),
		promise
	})
	```

	@param seconds number
	@param rejectionValue? any -- The value to reject with if the timeout is reached
	@return Promise
]=]
function Promise.prototype:timeout(seconds, rejectionValue)
	local traceback = debug.traceback(nil, 2)

	return Promise.race({
		Promise.delay(seconds):andThen(function()
			return Promise.reject(rejectionValue == nil and Error.new({
				kind = Error.Kind.TimedOut,
				error = "Timed out",
				context = string.format(
					"Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s",
					seconds,
					traceback
				),
			}) or rejectionValue)
		end),
		self,
	})
end

--[=[
	Returns the current Promise status.

	@return Status
]=]
function Promise.prototype:getStatus()
	return self._status
end

--[[
	Creates a new promise that receives the result of this promise.

	The given callbacks are invoked depending on that result.
]]
function Promise.prototype:_andThen(traceback, successHandler, failureHandler)
	self._unhandledRejection = false

	-- If we are already cancelled, we return a cancelled Promise
	if self._status == Promise.Status.Cancelled then
		local promise = Promise.new(function() end)
		promise:cancel()

		return promise
	end

	-- Create a new promise to follow this part of the chain
	return Promise._new(traceback, function(resolve, reject, onCancel)
		-- Our default callbacks just pass values onto the next promise.
		-- This lets success and failure cascade correctly!

		local successCallback = resolve
		if successHandler then
			successCallback = createAdvancer(traceback, successHandler, resolve, reject)
		end

		local failureCallback = reject
		if failureHandler then
			failureCallback = createAdvancer(traceback, failureHandler, resolve, reject)
		end

		if self._status == Promise.Status.Started then
			-- If we haven't resolved yet, put ourselves into the queue
			table.insert(self._queuedResolve, successCallback)
			table.insert(self._queuedReject, failureCallback)

			onCancel(function()
				-- These are guaranteed to exist because the cancellation handler is guaranteed to only
				-- be called at most once
				if self._status == Promise.Status.Started then
					table.remove(self._queuedResolve, table.find(self._queuedResolve, successCallback))
					table.remove(self._queuedReject, table.find(self._queuedReject, failureCallback))
				end
			end)
		elseif self._status == Promise.Status.Resolved then
			-- This promise has already resolved! Trigger success immediately.
			successCallback(unpack(self._values, 1, self._valuesLength))
		elseif self._status == Promise.Status.Rejected then
			-- This promise died a terrible death! Trigger failure immediately.
			failureCallback(unpack(self._values, 1, self._valuesLength))
		end
	end, self)
end

--[=[
	Chains onto an existing Promise and returns a new Promise.

	:::warning
	Within the failure handler, you should never assume that the rejection value is a string. Some rejections within the Promise library are represented by [[Error]] objects. If you want to treat it as a string for debugging, you should call `tostring` on it first.
	:::

	You can return a Promise from the success or failure handler and it will be chained onto.

	Calling `andThen` on a cancelled Promise returns a cancelled Promise.

	:::tip
	If the Promise returned by `andThen` is cancelled, `successHandler` and `failureHandler` will not run.

	To run code no matter what, use [Promise:finally].
	:::

	@param successHandler (...: any) -> ...any
	@param failureHandler? (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:andThen(successHandler, failureHandler)
	assert(successHandler == nil or isCallable(successHandler), string.format(ERROR_NON_FUNCTION, "Promise:andThen"))
	assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, "Promise:andThen"))

	return self:_andThen(debug.traceback(nil, 2), successHandler, failureHandler)
end

--[=[
	Shorthand for `Promise:andThen(nil, failureHandler)`.

	Returns a Promise that resolves if the `failureHandler` worked without encountering an additional error.

	:::warning
	Within the failure handler, you should never assume that the rejection value is a string. Some rejections within the Promise library are represented by [[Error]] objects. If you want to treat it as a string for debugging, you should call `tostring` on it first.
	:::

	Calling `catch` on a cancelled Promise returns a cancelled Promise.

	:::tip
	If the Promise returned by `catch` is cancelled,  `failureHandler` will not run.

	To run code no matter what, use [Promise:finally].
	:::

	@param failureHandler (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:catch(failureHandler)
	assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, "Promise:catch"))
	return self:_andThen(debug.traceback(nil, 2), nil, failureHandler)
end

--[=[
	Similar to [Promise.andThen](#andThen), except the return value is the same as the value passed to the handler. In other words, you can insert a `:tap` into a Promise chain without affecting the value that downstream Promises receive.

	```lua
		getTheValue()
		:tap(print)
		:andThen(function(theValue)
			print("Got", theValue, "even though print returns nil!")
		end)
	```

	If you return a Promise from the tap handler callback, its value will be discarded but `tap` will still wait until it resolves before passing the original value through.

	@param tapHandler (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:tap(tapHandler)
	assert(isCallable(tapHandler), string.format(ERROR_NON_FUNCTION, "Promise:tap"))
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

--[=[
	Attaches an `andThen` handler to this Promise that calls the given callback with the predefined arguments. The resolved value is discarded.

	```lua
		promise:andThenCall(someFunction, "some", "arguments")
	```

	This is sugar for

	```lua
		promise:andThen(function()
		return someFunction("some", "arguments")
		end)
	```

	@param callback (...: any) -> any
	@param ...? any -- Additional arguments which will be passed to `callback`
	@return Promise
]=]
function Promise.prototype:andThenCall(callback, ...)
	assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:andThenCall"))
	local length, values = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end)
end

--[=[
	Attaches an `andThen` handler to this Promise that discards the resolved value and returns the given value from it.

	```lua
		promise:andThenReturn("some", "values")
	```

	This is sugar for

	```lua
		promise:andThen(function()
			return "some", "values"
		end)
	```

	:::caution
	Promises are eager, so if you pass a Promise to `andThenReturn`, it will begin executing before `andThenReturn` is reached in the chain. Likewise, if you pass a Promise created from [[Promise.reject]] into `andThenReturn`, it's possible that this will trigger the unhandled rejection warning. If you need to return a Promise, it's usually best practice to use [[Promise.andThen]].
	:::

	@param ... any -- Values to return from the function
	@return Promise
]=]
function Promise.prototype:andThenReturn(...)
	local length, values = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end)
end

--[=[
	Cancels this promise, preventing the promise from resolving or rejecting. Does not do anything if the promise is already settled.

	Cancellations will propagate upwards and downwards through chained promises.

	Promises will only be cancelled if all of their consumers are also cancelled. This is to say that if you call `andThen` twice on the same promise, and you cancel only one of the child promises, it will not cancel the parent promise until the other child promise is also cancelled.

	```lua
		promise:cancel()
	```
]=]
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

	for child in pairs(self._consumers) do
		child:cancel()
	end

	self:_finalize()
end

--[[
	Used to decrease the number of consumers by 1, and if there are no more,
	cancel this promise.
]]
function Promise.prototype:_consumerCancelled(consumer)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._consumers[consumer] = nil

	if next(self._consumers) == nil then
		self:cancel()
	end
end

--[[
	Used to set a handler for when the promise resolves, rejects, or is
	cancelled.
]]
function Promise.prototype:_finally(traceback, finallyHandler)
	self._unhandledRejection = false

	local promise = Promise._new(traceback, function(resolve, reject, onCancel)
		local handlerPromise

		onCancel(function()
			-- The finally Promise is not a proper consumer of self. We don't care about the resolved value.
			-- All we care about is running at the end. Therefore, if self has no other consumers, it's safe to
			-- cancel. We don't need to hold out cancelling just because there's a finally handler.
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

					callbackReturn
						:finally(function(status)
							if status ~= Promise.Status.Rejected then
								resolve(self)
							end
						end)
						:catch(function(...)
							reject(...)
						end)
				else
					resolve(self)
				end
			end
		end

		if self._status == Promise.Status.Started then
			-- The promise is not settled, so queue this.
			table.insert(self._queuedFinally, finallyCallback)
		else
			-- The promise already settled or was cancelled, run the callback now.
			finallyCallback(self._status)
		end
	end)

	return promise
end

--[=[
	Set a handler that will be called regardless of the promise's fate. The handler is called when the promise is
	resolved, rejected, *or* cancelled.

	Returns a new Promise that:
	- resolves with the same values that this Promise resolves with.
	- rejects with the same values that this Promise rejects with.
	- is cancelled if this Promise is cancelled.

	If the value you return from the handler is a Promise:
	- We wait for the Promise to resolve, but we ultimately discard the resolved value.
	- If the returned Promise rejects, the Promise returned from `finally` will reject with the rejected value from the
	*returned* promise.
	- If the `finally` Promise is cancelled, and you returned a Promise from the handler, we cancel that Promise too.

	Otherwise, the return value from the `finally` handler is entirely discarded.

	:::note Cancellation
	As of Promise v4, `Promise:finally` does not count as a consumer of the parent Promise for cancellation purposes.
	This means that if all of a Promise's consumers are cancelled and the only remaining callbacks are finally handlers,
	the Promise is cancelled and the finally callbacks run then and there.

	Cancellation still propagates through the `finally` Promise though: if you cancel the `finally` Promise, it can cancel
	its parent Promise if it had no other consumers. Likewise, if the parent Promise is cancelled, the `finally` Promise
	will also be cancelled.
	:::

	```lua
	local thing = createSomething()

	doSomethingWith(thing)
		:andThen(function()
			print("It worked!")
			-- do something..
		end)
		:catch(function()
			warn("Oh no it failed!")
		end)
		:finally(function()
			-- either way, destroy thing

			thing:Destroy()
		end)

	```

	@param finallyHandler (status: Status) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:finally(finallyHandler)
	assert(finallyHandler == nil or isCallable(finallyHandler), string.format(ERROR_NON_FUNCTION, "Promise:finally"))
	return self:_finally(debug.traceback(nil, 2), finallyHandler)
end

--[=[
	Same as `andThenCall`, except for `finally`.

	Attaches a `finally` handler to this Promise that calls the given callback with the predefined arguments.

	@param callback (...: any) -> any
	@param ...? any -- Additional arguments which will be passed to `callback`
	@return Promise
]=]
function Promise.prototype:finallyCall(callback, ...)
	assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:finallyCall"))
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end)
end

--[=[
	Attaches a `finally` handler to this Promise that discards the resolved value and returns the given value from it.

	```lua
		promise:finallyReturn("some", "values")
	```

	This is sugar for

	```lua
		promise:finally(function()
			return "some", "values"
		end)
	```

	@param ... any -- Values to return from the function
	@return Promise
]=]
function Promise.prototype:finallyReturn(...)
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end)
end

--[=[
	Yields the current thread until the given Promise completes. Returns the Promise's status, followed by the values that the promise resolved or rejected with.

	@yields
	@return Status -- The Status representing the fate of the Promise
	@return ...any -- The values the Promise resolved or rejected with.
]=]
function Promise.prototype:awaitStatus()
	self._unhandledRejection = false

	if self._status == Promise.Status.Started then
		local thread = coroutine.running()

		self
			:finally(function()
				task.spawn(thread)
			end)
			-- The finally promise can propagate rejections, so we attach a catch handler to prevent the unhandled
			-- rejection warning from appearing
			:catch(
				function() end
			)

		coroutine.yield()
	end

	if self._status == Promise.Status.Resolved then
		return self._status, unpack(self._values, 1, self._valuesLength)
	elseif self._status == Promise.Status.Rejected then
		return self._status, unpack(self._values, 1, self._valuesLength)
	end

	return self._status
end

local function awaitHelper(status, ...)
	return status == Promise.Status.Resolved, ...
end

--[=[
	Yields the current thread until the given Promise completes. Returns true if the Promise resolved, followed by the values that the promise resolved or rejected with.

	:::caution
	If the Promise gets cancelled, this function will return `false`, which is indistinguishable from a rejection. If you need to differentiate, you should use [[Promise.awaitStatus]] instead.
	:::

	```lua
		local worked, value = getTheValue():await()

	if worked then
		print("got", value)
	else
		warn("it failed")
	end
	```

	@yields
	@return boolean -- `true` if the Promise successfully resolved
	@return ...any -- The values the Promise resolved or rejected with.
]=]
function Promise.prototype:await()
	return awaitHelper(self:awaitStatus())
end

local function expectHelper(status, ...)
	if status ~= Promise.Status.Resolved then
		error((...) == nil and "Expected Promise rejected with no value." or (...), 3)
	end

	return ...
end

--[=[
	Yields the current thread until the given Promise completes. Returns the values that the promise resolved with.

	```lua
	local worked = pcall(function()
		print("got", getTheValue():expect())
	end)

	if not worked then
		warn("it failed")
	end
	```

	This is essentially sugar for:

	```lua
	select(2, assert(promise:await()))
	```

	**Errors** if the Promise rejects or gets cancelled.

	@error any -- Errors with the rejection value if this Promise rejects or gets cancelled.
	@yields
	@return ...any -- The values the Promise resolved with.
]=]
function Promise.prototype:expect()
	return expectHelper(self:awaitStatus())
end

-- Backwards compatibility
Promise.prototype.awaitValue = Promise.prototype.expect

--[[
	Intended for use in tests.

	Similar to await(), but instead of yielding if the promise is unresolved,
	_unwrap will throw. This indicates an assumption that a promise has
	resolved.
]]
function Promise.prototype:_unwrap()
	if self._status == Promise.Status.Started then
		error("Promise has not resolved or rejected.", 2)
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

	-- If the resolved value was a Promise, we chain onto it!
	if Promise.is((...)) then
		-- Without this warning, arguments sometimes mysteriously disappear
		if select("#", ...) > 1 then
			local message = string.format(
				"When returning a Promise from andThen, extra arguments are " .. "discarded! See:\n\n%s",
				self._source
			)
			warn(message)
		end

		local chainedPromise = ...

		local promise = chainedPromise:andThen(function(...)
			self:_resolve(...)
		end, function(...)
			local maybeRuntimeError = chainedPromise._values[1]

			-- Backwards compatibility < v2
			if chainedPromise._error then
				maybeRuntimeError = Error.new({
					error = chainedPromise._error,
					kind = Error.Kind.ExecutionError,
					context = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]",
				})
			end

			if Error.isKind(maybeRuntimeError, Error.Kind.ExecutionError) then
				return self:_reject(maybeRuntimeError:extend({
					error = "This Promise was chained to a Promise that errored.",
					trace = "",
					context = string.format(
						"The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n",
						self._source
					),
				}))
			end

			self:_reject(...)
		end)

		if promise._status == Promise.Status.Cancelled then
			self:cancel()
		elseif promise._status == Promise.Status.Started then
			-- Adopt ourselves into promise for cancellation propagation.
			self._parent = promise
			promise._consumers[self] = true
		end

		return
	end

	self._status = Promise.Status.Resolved
	self._valuesLength, self._values = pack(...)

	-- We assume that these callbacks will not throw errors.
	for _, callback in ipairs(self._queuedResolve) do
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

	-- If there are any rejection handlers, call those!
	if not isEmpty(self._queuedReject) then
		-- We assume that these callbacks will not throw errors.
		for _, callback in ipairs(self._queuedReject) do
			coroutine.wrap(callback)(...)
		end
	else
		-- At this point, no one was able to observe the error.
		-- An error handler might still be attached if the error occurred
		-- synchronously. We'll wait one tick, and if there are still no
		-- observers, then we should put a message in the console.

		local err = tostring((...))

		coroutine.wrap(function()
			Promise._timeEvent:Wait()

			-- Someone observed the error, hooray!
			if not self._unhandledRejection then
				return
			end

			-- Build a reasonable message
			local message = string.format("Unhandled Promise rejection:\n\n%s\n\n%s", err, self._source)

			for _, callback in ipairs(Promise._unhandledRejectionCallbacks) do
				task.spawn(callback, self, unpack(self._values, 1, self._valuesLength))
			end

			warn(message)
		end)()
	end

	self:_finalize()
end

--[[
	Calls any :finally handlers. We need this to be a separate method and
	queue because we must call all of the finally callbacks upon a success,
	failure, *and* cancellation.
]]
function Promise.prototype:_finalize()
	for _, callback in ipairs(self._queuedFinally) do
		-- Purposefully not passing values to callbacks here, as it could be the
		-- resolved values, or rejected errors. If the developer needs the values,
		-- they should use :andThen or :catch explicitly.
		coroutine.wrap(callback)(self._status)
	end

	self._queuedFinally = nil
	self._queuedReject = nil
	self._queuedResolve = nil

	task.defer(coroutine.close, self._thread)
end

--[=[
	Chains a Promise from this one that is resolved if this Promise is already resolved, and rejected if it is not resolved at the time of calling `:now()`. This can be used to ensure your `andThen` handler occurs on the same frame as the root Promise execution.

	```lua
	doSomething()
		:now()
		:andThen(function(value)
			print("Got", value, "synchronously.")
		end)
	```

	If this Promise is still running, Rejected, or Cancelled, the Promise returned from `:now()` will reject with the `rejectionValue` if passed, otherwise with a `Promise.Error(Promise.Error.Kind.NotResolvedInTime)`. This can be checked with [[Error.isKind]].

	@param rejectionValue? any -- The value to reject with if the Promise isn't resolved
	@return Promise
]=]
function Promise.prototype:now(rejectionValue)
	local traceback = debug.traceback(nil, 2)
	if self._status == Promise.Status.Resolved then
		return self:_andThen(traceback, function(...)
			return ...
		end)
	else
		return Promise.reject(rejectionValue == nil and Error.new({
			kind = Error.Kind.NotResolvedInTime,
			error = "This Promise was not resolved in time for :now()",
			context = ":now() was called at:\n\n" .. traceback,
		}) or rejectionValue)
	end
end

--[=[
	Repeatedly calls a Promise-returning function up to `times` number of times, until the returned Promise resolves.

	If the amount of retries is exceeded, the function will return the latest rejected Promise.

	```lua
	local function canFail(a, b, c)
		return Promise.new(function(resolve, reject)
			-- do something that can fail

			local failed, thing = doSomethingThatCanFail(a, b, c)

			if failed then
				reject("it failed")
			else
				resolve(thing)
			end
		end)
	end

	local MAX_RETRIES = 10
	local value = Promise.retry(canFail, MAX_RETRIES, "foo", "bar", "baz") -- args to send to canFail
	```

	@since 3.0.0
	@param callback (...: P) -> Promise<T>
	@param times number
	@param ...? P
	@return Promise<T>
]=]
function Promise.retry(callback, times, ...)
	assert(isCallable(callback), "Parameter #1 to Promise.retry must be a function")
	assert(type(times) == "number", "Parameter #2 to Promise.retry must be a number")

	local args, length = { ... }, select("#", ...)

	return Promise.resolve(callback(...)):catch(function(...)
		if times > 0 then
			return Promise.retry(callback, times - 1, unpack(args, 1, length))
		else
			return Promise.reject(...)
		end
	end)
end

--[=[
	Repeatedly calls a Promise-returning function up to `times` number of times, waiting `seconds` seconds between each
	retry, until the returned Promise resolves.

	If the amount of retries is exceeded, the function will return the latest rejected Promise.

	@since v3.2.0
	@param callback (...: P) -> Promise<T>
	@param times number
	@param seconds number
	@param ...? P
	@return Promise<T>
]=]
function Promise.retryWithDelay(callback, times, seconds, ...)
	assert(isCallable(callback), "Parameter #1 to Promise.retry must be a function")
	assert(type(times) == "number", "Parameter #2 (times) to Promise.retry must be a number")
	assert(type(seconds) == "number", "Parameter #3 (seconds) to Promise.retry must be a number")

	local args, length = { ... }, select("#", ...)

	return Promise.resolve(callback(...)):catch(function(...)
		if times > 0 then
			Promise.delay(seconds):await()

			return Promise.retryWithDelay(callback, times - 1, seconds, unpack(args, 1, length))
		else
			return Promise.reject(...)
		end
	end)
end

--[=[
	Converts an event into a Promise which resolves the next time the event fires.

	The optional `predicate` callback, if passed, will receive the event arguments and should return `true` or `false`, based on if this fired event should resolve the Promise or not. If `true`, the Promise resolves. If `false`, nothing happens and the predicate will be rerun the next time the event fires.

	The Promise will resolve with the event arguments.

	:::tip
	This function will work given any object with a `Connect` method. This includes all Roblox events.
	:::

	```lua
	-- Creates a Promise which only resolves when `somePart` is touched
	-- by a part named `"Something specific"`.
	return Promise.fromEvent(somePart.Touched, function(part)
		return part.Name == "Something specific"
	end)
	```

	@since 3.0.0
	@param event Event -- Any object with a `Connect` method. This includes all Roblox events.
	@param predicate? (...: P) -> boolean -- A function which determines if the Promise should resolve with the given value, or wait for the next event to check again.
	@return Promise<P>
]=]
function Promise.fromEvent(event, predicate)
	predicate = predicate or function()
		return true
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
		local connection
		local shouldDisconnect = false

		local function disconnect()
			connection:Disconnect()
			connection = nil
		end

		-- We use shouldDisconnect because if the callback given to Connect is called before
		-- Connect returns, connection will still be nil. This happens with events that queue up
		-- events when there's nothing connected, such as RemoteEvents

		connection = event:Connect(function(...)
			local callbackValue = predicate(...)

			if callbackValue == true then
				resolve(...)

				if connection then
					disconnect()
				else
					shouldDisconnect = true
				end
			elseif type(callbackValue) ~= "boolean" then
				error("Promise.fromEvent predicate should always return a boolean")
			end
		end)

		if shouldDisconnect and connection then
			return disconnect()
		end

		onCancel(disconnect)
	end)
end

--[=[
	Registers a callback that runs when an unhandled rejection happens. An unhandled rejection happens when a Promise
	is rejected, and the rejection is not observed with `:catch`.

	The callback is called with the actual promise that rejected, followed by the rejection values.

	@since v3.2.0
	@param callback (promise: Promise, ...: any) -- A callback that runs when an unhandled rejection happens.
	@return () -> () -- Function that unregisters the `callback` when called
]=]
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

end)() end,
    [82] = function()local wax,script,require=ImportGlobals(82)local ImportGlobals return (function(...)local SnapdragonController = require("packages/snapdragon/SnapdragonController")
local SnapdragonRef = require("packages/snapdragon/SnapdragonRef")

local function createDragController(...)
	return SnapdragonController.new(...)
end

local function createRef(gui)
	return SnapdragonRef.new(gui)
end

local export
export = {
	createDragController = createDragController,
	SnapdragonController = SnapdragonController,
	createRef = createRef,
}
-- roblox-ts `default` support
export.default = export
return export

end)() end,
    [83] = function()local wax,script,require=ImportGlobals(83)local ImportGlobals return (function(...)-- Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy
-- @classmod Maid
-- @see Signal

local Maid = {}
Maid.ClassName = "Maid"

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new()
	local self = {}

	self._tasks = {}

	return setmetatable(self, Maid)
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up
-- @usage
-- Maid[key] = (function)         Adds a task to perform
-- Maid[key] = (event connection) Manages an event connection
-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
--                                it is destroyed.
function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]
	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
	assert(task, "Task cannot be false or nil")

	local taskId = #self._tasks + 1
	self[taskId] = task

	if type(task) == "table" and not task.Destroy then
		warn("[Maid.GiveTask] - Gave table task without .Destroy\n\n" .. debug.traceback())
	end

	return taskId
end

function Maid:GivePromise(promise)
	if not promise:IsPending() then
		return promise
	end

	local newPromise = promise.resolved(promise)
	local id = self:GiveTask(newPromise)

	-- Ensure GC
	newPromise:Finally(function()
		self[id] = nil
	end)

	return newPromise
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	local tasks = self._tasks

	-- Disconnect all events first as we know this is safe
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	-- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
		index, task = next(tasks)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

return Maid

end)() end,
    [84] = function()local wax,script,require=ImportGlobals(84)local ImportGlobals return (function(...)local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		Bindable = Instance.new("BindableEvent"),
	}, Signal)
end

function Signal:Connect(Callback)
	return self.Bindable.Event:Connect(function(GetArgumentStack)
		Callback(GetArgumentStack())
	end)
end

function Signal:Fire(...)
	local Arguments = { ... }
	local n = select("#", ...)

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

end)() end,
    [85] = function()local wax,script,require=ImportGlobals(85)local ImportGlobals return (function(...)local UserInputService = game:GetService("UserInputService")

local Maid = require(script.Parent.Maid)
local Signal = require(script.Parent.Signal)
local SnapdragonRef = require(script.Parent.SnapdragonRef)
local objectAssign = require(script.Parent.objectAssign)
local t = require(script.Parent.t)

local MarginTypeCheck = t.interface({
	Vertical = t.optional(t.Vector2),
	Horizontal = t.optional(t.Vector2),
})

local AxisEnumCheck = t.literal("XY", "X", "Y")
local DragRelativeToEnumCheck = t.literal("LayerCollector", "Parent")
local DragPositionModeEnumCheck = t.literal("Offset", "Scale")

local OptionsInterfaceCheck = t.interface({
	DragGui = t.union(t.instanceIsA("GuiObject"), SnapdragonRef.is),
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

local controllers = setmetatable({}, { __mode = "k" })

function SnapdragonController.new(gui, options)
	options = objectAssign({
		DragGui = gui,
		DragThreshold = 0,
		DragGridSize = 0,
		SnapMargin = {},
		SnapMarginThreshold = {},
		SnapEnabled = true,
		DragEndedResetsPosition = false,
		SnapAxis = "XY",
		DragAxis = "XY",
		Debugging = false,
		DragRelativeTo = "LayerCollector",
		DragPositionMode = "Scale",
	}, options)

	assert(OptionsInterfaceCheck(options))

	local self = setmetatable({}, SnapdragonController)
	-- Basic immutable values
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

	-- Internal stuff
	self._useAbsoluteCoordinates = false

	-- Events
	local DragEnded = Signal.new()
	local DragChanged = Signal.new()
	local DragBegan = Signal.new()
	self.DragEnded = DragEnded
	self.DragBegan = DragBegan
	self.DragChanged = DragChanged

	-- Advanced stuff
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

	local function update(input)
		local snapHorizontalMargin = self.snapHorizontalMargin
		local snapVerticalMargin = self.snapVerticalMargin
		local snapThresholdVertical = self.snapThresholdVertical
		local snapThresholdHorizontal = self.snapThresholdHorizontal

		local screenSize = workspace.CurrentCamera.ViewportSize
		local delta = input.Position - dragStart

		if dragAxis == "X" then
			delta = Vector3.new(delta.X, 0, 0)
		elseif dragAxis == "Y" then
			delta = Vector3.new(0, delta.Y, 0)
		end

		gui = dragGui or gui
		reachedExtents = {
			X = "Float",
			Y = "Float",
		}

		local host = gui:FindFirstAncestorOfClass("ScreenGui") or gui:FindFirstAncestorOfClass("PluginGui")
		local topLeft = Vector2.new()
		if host and dragRelativeTo == "LayerCollector" then
			screenSize = host.AbsoluteSize
		elseif dragRelativeTo == "Parent" then
			assert(gui.Parent:IsA("GuiObject"), "DragRelativeTo is set to Parent, but the parent is not a GuiObject!")
			screenSize = gui.Parent.AbsoluteSize
		end

		if snap then
			local scaleOffsetX = screenSize.X * startPos.X.Scale
			local scaleOffsetY = screenSize.Y * startPos.Y.Scale
			local resultingOffsetX = startPos.X.Offset + delta.X
			local resultingOffsetY = startPos.Y.Offset + delta.Y
			local absSize = gui.AbsoluteSize + Vector2.new(snapHorizontalMargin.Y, snapVerticalMargin.Y + topLeft.Y)

			local anchorOffset =
				Vector2.new(gui.AbsoluteSize.X * gui.AnchorPoint.X, gui.AbsoluteSize.Y * gui.AnchorPoint.Y)

			if snapAxis == "XY" or snapAxis == "X" then
				local computedMinX = snapHorizontalMargin.X + anchorOffset.X
				local computedMaxX = screenSize.X - absSize.X + anchorOffset.X

				if (resultingOffsetX + scaleOffsetX) > computedMaxX - snapThresholdHorizontal.Y then
					resultingOffsetX = computedMaxX - scaleOffsetX
					reachedExtents.X = "Max"
				elseif (resultingOffsetX + scaleOffsetX) < computedMinX + snapThresholdHorizontal.X then
					resultingOffsetX = -scaleOffsetX + computedMinX
					reachedExtents.X = "Min"
				end
			end

			if snapAxis == "XY" or snapAxis == "Y" then
				local computedMinY = snapVerticalMargin.X + anchorOffset.Y
				local computedMaxY = screenSize.Y - absSize.Y + anchorOffset.Y

				if (resultingOffsetY + scaleOffsetY) > computedMaxY - snapThresholdVertical.Y then
					resultingOffsetY = computedMaxY - scaleOffsetY
					reachedExtents.Y = "Max"
				elseif (resultingOffsetY + scaleOffsetY) < computedMinY + snapThresholdVertical.X then
					resultingOffsetY = -scaleOffsetY + computedMinY
					reachedExtents.Y = "Min"
				end
			end

			if dragGridSize > 0 then
				resultingOffsetX = math.floor(resultingOffsetX / dragGridSize) * dragGridSize
				resultingOffsetY = math.floor(resultingOffsetY / dragGridSize) * dragGridSize
			end

			if dragPositionMode == "Offset" then
				local newPosition = UDim2.new(startPos.X.Scale, resultingOffsetX, startPos.Y.Scale, resultingOffsetY)

				gui.Position = newPosition

				DragChanged:Fire({
					GuiPosition = newPosition,
				})
			else
				local newPosition = UDim2.new(
					startPos.X.Scale + (resultingOffsetX / screenSize.X),
					0,
					startPos.Y.Scale + (resultingOffsetY / screenSize.Y),
					0
				)

				gui.Position = newPosition

				DragChanged:Fire({
					SnapAxis = snapAxis,
					GuiPosition = newPosition,
					DragPositionMode = dragPositionMode,
				})
			end
		else
			if dragGridSize > 0 then
				delta = Vector2.new(
					math.floor(delta.X / dragGridSize) * dragGridSize,
					math.floor(delta.Y / dragGridSize) * dragGridSize
				)
			end

			local newPosition =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			gui.Position = newPosition
			DragChanged:Fire({
				GuiPosition = newPosition,
			})
		end
	end

	maid.guiInputBegan = gui.InputBegan:Connect(function(input)
		local canDrag = true
		if type(self.canDrag) == "function" then
			canDrag = self.canDrag()
		end

		if
			(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and canDrag
		then
			dragging = true
			dragStart = input.Position
			local draggingGui = (dragGui or gui)
			startPos = useAbsoluteCoordinates
					and UDim2.new(0, draggingGui.AbsolutePosition.X, 0, draggingGui.AbsolutePosition.Y)
				or draggingGui.Position
			guiStartPos = draggingGui.Position
			DragBegan:Fire({
				AbsolutePosition = (dragGui or gui).AbsolutePosition,
				InputPosition = dragStart,
				GuiPosition = startPos,
			})
			if debug then
				print("[snapdragon]", "Drag began", input.Position)
			end
		end
	end)

	maid.guiInputEnded = gui.InputEnded:Connect(function(input)
		if
			dragging
			and input.UserInputState == Enum.UserInputState.End
			and (
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			dragging = false

			local draggingGui = (dragGui or gui)
			local endPos = draggingGui.Position --useAbsoluteCoordinates
			--and UDim2.new(0, draggingGui.AbsolutePosition.X, 0, draggingGui.AbsolutePosition.Y)
			--or draggingGui.Position

			DragEnded:Fire({
				InputPosition = input.Position,
				GuiPosition = endPos,
				ReachedExtents = reachedExtents,
				DraggedGui = dragGui or gui,
			})
			if debug then
				print("[snapdragon]", "Drag ended", input.Position)
			end

			-- Enable the ability to "reset" the position automatically.
			-- This will be used for stuff like roact-dnd
			local dragEndedResetsPosition = self.dragEndedResetsPosition
			if dragEndedResetsPosition then
				draggingGui.Position = guiStartPos
			end
		end
	end)

	maid.guiInputChanged = gui.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end)

	maid.uisInputChanged = UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function SnapdragonController:Connect()
	if self.locked then
		error("[SnapdragonController] Cannot connect locked controller!", 2)
	end

	local _, ref = self:GetDragGui()

	if not controllers[ref] or controllers[ref] == self then
		controllers[ref] = self
		self:__bindControllerBehaviour()
	else
		error("[SnapdragonController] This object is already bound to a controller")
	end
	return self
end

function SnapdragonController:Disconnect()
	if self.locked then
		error("[SnapdragonController] Cannot disconnect locked controller!", 2)
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

end)() end,
    [86] = function()local wax,script,require=ImportGlobals(86)local ImportGlobals return (function(...)local refs = setmetatable({}, { __mode = "k" })

local SnapdragonRef = {}
SnapdragonRef.__index = SnapdragonRef

function SnapdragonRef.new(current)
	local ref = setmetatable({
		current = current,
	}, SnapdragonRef)
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

end)() end,
    [87] = function()local wax,script,require=ImportGlobals(87)local ImportGlobals return (function(...)--[[
	A 'Symbol' is an opaque marker type.

	Symbols have the type 'userdata', but when printed to the console, the name
	of the symbol is shown.
]]

local Symbol = {}

--[[
	Creates a Symbol with the given name.

	When printed or coerced to a string, the symbol will turn into the string
	given as its name.
]]
function Symbol.named(name)
	assert(type(name) == "string", "Symbols must be created using a string name!")

	local self = newproxy(true)

	local wrappedName = ("Symbol(%s)"):format(name)

	getmetatable(self).__tostring = function()
		return wrappedName
	end

	return self
end

return Symbol

end)() end,
    [88] = function()local wax,script,require=ImportGlobals(88)local ImportGlobals return (function(...)local function objectAssign(target, ...)
	local targets = { ... }
	for _, t in pairs(targets) do
		for k, v in pairs(t) do
			target[k] = v
		end
	end
	return target
end

return objectAssign

end)() end,
    [89] = function()local wax,script,require=ImportGlobals(89)local ImportGlobals return (function(...)-- t: a runtime typechecker for Roblox

-- regular lua compatibility
local typeof = typeof or type

local function primitive(typeName)
	return function(value)
		local valueType = typeof(value)
		if valueType == typeName then
			return true
		else
			return false, string.format("%s expected, got %s", typeName, valueType)
		end
	end
end

local t = {}

--[[**
	matches any type except nil

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
function t.any(value)
	if value ~= nil then
		return true
	else
		return false, "any expected, got nil"
	end
end

--Lua primitives

--[[**
	ensures Lua primitive boolean type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.boolean = primitive("boolean")

--[[**
	ensures Lua primitive thread type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.thread = primitive("thread")

--[[**
	ensures Lua primitive callback type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.callback = primitive("function")

--[[**
	ensures Lua primitive none type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.none = primitive("nil")

--[[**
	ensures Lua primitive string type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.string = primitive("string")

--[[**
	ensures Lua primitive table type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.table = primitive("table")

--[[**
	ensures Lua primitive userdata type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.userdata = primitive("userdata")

--[[**
	ensures value is a number and non-NaN

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
function t.number(value)
	local valueType = typeof(value)
	if valueType == "number" then
		if value == value then
			return true
		else
			return false, "unexpected NaN value"
		end
	else
		return false, string.format("number expected, got %s", valueType)
	end
end

--[[**
	ensures value is NaN

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
function t.nan(value)
	if value ~= value then
		return true
	else
		return false, "unexpected non-NaN value"
	end
end

-- roblox types

--[[**
	ensures Roblox Axes type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Axes = primitive("Axes")

--[[**
	ensures Roblox BrickColor type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.BrickColor = primitive("BrickColor")

--[[**
	ensures Roblox CFrame type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.CFrame = primitive("CFrame")

--[[**
	ensures Roblox Color3 type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Color3 = primitive("Color3")

--[[**
	ensures Roblox ColorSequence type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.ColorSequence = primitive("ColorSequence")

--[[**
	ensures Roblox ColorSequenceKeypoint type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.ColorSequenceKeypoint = primitive("ColorSequenceKeypoint")

--[[**
	ensures Roblox DockWidgetPluginGuiInfo type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.DockWidgetPluginGuiInfo = primitive("DockWidgetPluginGuiInfo")

--[[**
	ensures Roblox Faces type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Faces = primitive("Faces")

--[[**
	ensures Roblox Instance type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Instance = primitive("Instance")

--[[**
	ensures Roblox NumberRange type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.NumberRange = primitive("NumberRange")

--[[**
	ensures Roblox NumberSequence type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.NumberSequence = primitive("NumberSequence")

--[[**
	ensures Roblox NumberSequenceKeypoint type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.NumberSequenceKeypoint = primitive("NumberSequenceKeypoint")

--[[**
	ensures Roblox PathWaypoint type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.PathWaypoint = primitive("PathWaypoint")

--[[**
	ensures Roblox PhysicalProperties type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.PhysicalProperties = primitive("PhysicalProperties")

--[[**
	ensures Roblox Random type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Random = primitive("Random")

--[[**
	ensures Roblox Ray type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Ray = primitive("Ray")

--[[**
	ensures Roblox Rect type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Rect = primitive("Rect")

--[[**
	ensures Roblox Region3 type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Region3 = primitive("Region3")

--[[**
	ensures Roblox Region3int16 type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Region3int16 = primitive("Region3int16")

--[[**
	ensures Roblox TweenInfo type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.TweenInfo = primitive("TweenInfo")

--[[**
	ensures Roblox UDim type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.UDim = primitive("UDim")

--[[**
	ensures Roblox UDim2 type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.UDim2 = primitive("UDim2")

--[[**
	ensures Roblox Vector2 type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Vector2 = primitive("Vector2")

--[[**
	ensures Roblox Vector3 type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Vector3 = primitive("Vector3")

--[[**
	ensures Roblox Vector3int16 type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Vector3int16 = primitive("Vector3int16")

-- roblox enum types

--[[**
	ensures Roblox Enum type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.Enum = primitive("Enum")

--[[**
	ensures Roblox EnumItem type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.EnumItem = primitive("EnumItem")

--[[**
	ensures Roblox RBXScriptSignal type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.RBXScriptSignal = primitive("RBXScriptSignal")

--[[**
	ensures Roblox RBXScriptConnection type

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
t.RBXScriptConnection = primitive("RBXScriptConnection")

--[[**
	ensures value is a given literal value

	@param literal The literal to use

	@returns A function that will return true iff the condition is passed
**--]]
function t.literal(...)
	local size = select("#", ...)
	if size == 1 then
		local literal = ...
		return function(value)
			if value ~= literal then
				return false, string.format("expected %s, got %s", tostring(literal), tostring(value))
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

--[[**
	DEPRECATED
	Please use t.literal
**--]]
t.exactly = t.literal

--[[**
	Returns a t.union of each key in the table as a t.literal

	@param keyTable The table to get keys from

	@returns True iff the condition is satisfied, false otherwise
**--]]
function t.keyOf(keyTable)
	local keys = {}
	local length = 0
	for key in pairs(keyTable) do
		length = length + 1
		keys[length] = key
	end

	return t.literal(table.unpack(keys, 1, length))
end

--[[**
	Returns a t.union of each value in the table as a t.literal

	@param valueTable The table to get values from

	@returns True iff the condition is satisfied, false otherwise
**--]]
function t.valueOf(valueTable)
	local values = {}
	local length = 0
	for _, value in pairs(valueTable) do
		length = length + 1
		values[length] = value
	end

	return t.literal(table.unpack(values, 1, length))
end

--[[**
	ensures value is an integer

	@param value The value to check against

	@returns True iff the condition is satisfied, false otherwise
**--]]
function t.integer(value)
	local success, errMsg = t.number(value)
	if not success then
		return false, errMsg or ""
	end

	if value % 1 == 0 then
		return true
	else
		return false, string.format("integer expected, got %s", value)
	end
end

--[[**
	ensures value is a number where min <= value

	@param min The minimum to use

	@returns A function that will return true iff the condition is passed
**--]]
function t.numberMin(min)
	return function(value)
		local success, errMsg = t.number(value)
		if not success then
			return false, errMsg or ""
		end

		if value >= min then
			return true
		else
			return false, string.format("number >= %s expected, got %s", min, value)
		end
	end
end

--[[**
	ensures value is a number where value <= max

	@param max The maximum to use

	@returns A function that will return true iff the condition is passed
**--]]
function t.numberMax(max)
	return function(value)
		local success, errMsg = t.number(value)
		if not success then
			return false, errMsg
		end

		if value <= max then
			return true
		else
			return false, string.format("number <= %s expected, got %s", max, value)
		end
	end
end

--[[**
	ensures value is a number where min < value

	@param min The minimum to use

	@returns A function that will return true iff the condition is passed
**--]]
function t.numberMinExclusive(min)
	return function(value)
		local success, errMsg = t.number(value)
		if not success then
			return false, errMsg or ""
		end

		if min < value then
			return true
		else
			return false, string.format("number > %s expected, got %s", min, value)
		end
	end
end

--[[**
	ensures value is a number where value < max

	@param max The maximum to use

	@returns A function that will return true iff the condition is passed
**--]]
function t.numberMaxExclusive(max)
	return function(value)
		local success, errMsg = t.number(value)
		if not success then
			return false, errMsg or ""
		end

		if value < max then
			return true
		else
			return false, string.format("number < %s expected, got %s", max, value)
		end
	end
end

--[[**
	ensures value is a number where value > 0

	@returns A function that will return true iff the condition is passed
**--]]
t.numberPositive = t.numberMinExclusive(0)

--[[**
	ensures value is a number where value < 0

	@returns A function that will return true iff the condition is passed
**--]]
t.numberNegative = t.numberMaxExclusive(0)

--[[**
	ensures value is a number where min <= value <= max

	@param min The minimum to use
	@param max The maximum to use

	@returns A function that will return true iff the condition is passed
**--]]
function t.numberConstrained(min, max)
	assert(t.number(min) and t.number(max))
	local minCheck = t.numberMin(min)
	local maxCheck = t.numberMax(max)

	return function(value)
		local minSuccess, minErrMsg = minCheck(value)
		if not minSuccess then
			return false, minErrMsg or ""
		end

		local maxSuccess, maxErrMsg = maxCheck(value)
		if not maxSuccess then
			return false, maxErrMsg or ""
		end

		return true
	end
end

--[[**
	ensures value is a number where min < value < max

	@param min The minimum to use
	@param max The maximum to use

	@returns A function that will return true iff the condition is passed
**--]]
function t.numberConstrainedExclusive(min, max)
	assert(t.number(min) and t.number(max))
	local minCheck = t.numberMinExclusive(min)
	local maxCheck = t.numberMaxExclusive(max)

	return function(value)
		local minSuccess, minErrMsg = minCheck(value)
		if not minSuccess then
			return false, minErrMsg or ""
		end

		local maxSuccess, maxErrMsg = maxCheck(value)
		if not maxSuccess then
			return false, maxErrMsg or ""
		end

		return true
	end
end

--[[**
	ensures value matches string pattern

	@param string pattern to check against

	@returns A function that will return true iff the condition is passed
**--]]
function t.match(pattern)
	assert(t.string(pattern))
	return function(value)
		local stringSuccess, stringErrMsg = t.string(value)
		if not stringSuccess then
			return false, stringErrMsg
		end

		if string.match(value, pattern) == nil then
			return false, string.format("%q failed to match pattern %q", value, pattern)
		end

		return true
	end
end

--[[**
	ensures value is either nil or passes check

	@param check The check to use

	@returns A function that will return true iff the condition is passed
**--]]
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
			return false, string.format("(optional) %s", errMsg or "")
		end
	end
end

--[[**
	matches given tuple against tuple type definition

	@param ... The type definition for the tuples

	@returns A function that will return true iff the condition is passed
**--]]
function t.tuple(...)
	local checks = { ... }
	return function(...)
		local args = { ... }
		for i, check in ipairs(checks) do
			local success, errMsg = check(args[i])
			if success == false then
				return false, string.format("Bad tuple index #%s:\n\t%s", i, errMsg or "")
			end
		end

		return true
	end
end

--[[**
	ensures all keys in given table pass check

	@param check The function to use to check the keys

	@returns A function that will return true iff the condition is passed
**--]]
function t.keys(check)
	assert(t.callback(check))
	return function(value)
		local tableSuccess, tableErrMsg = t.table(value)
		if tableSuccess == false then
			return false, tableErrMsg or ""
		end

		for key in pairs(value) do
			local success, errMsg = check(key)
			if success == false then
				return false, string.format("bad key %s:\n\t%s", tostring(key), errMsg or "")
			end
		end

		return true
	end
end

--[[**
	ensures all values in given table pass check

	@param check The function to use to check the values

	@returns A function that will return true iff the condition is passed
**--]]
function t.values(check)
	assert(t.callback(check))
	return function(value)
		local tableSuccess, tableErrMsg = t.table(value)
		if tableSuccess == false then
			return false, tableErrMsg or ""
		end

		for key, val in pairs(value) do
			local success, errMsg = check(val)
			if success == false then
				return false, string.format("bad value for key %s:\n\t%s", tostring(key), errMsg or "")
			end
		end

		return true
	end
end

--[[**
	ensures value is a table and all keys pass keyCheck and all values pass valueCheck

	@param keyCheck The function to use to check the keys
	@param valueCheck The function to use to check the values

	@returns A function that will return true iff the condition is passed
**--]]
function t.map(keyCheck, valueCheck)
	assert(t.callback(keyCheck), t.callback(valueCheck))
	local keyChecker = t.keys(keyCheck)
	local valueChecker = t.values(valueCheck)

	return function(value)
		local keySuccess, keyErr = keyChecker(value)
		if not keySuccess then
			return false, keyErr or ""
		end

		local valueSuccess, valueErr = valueChecker(value)
		if not valueSuccess then
			return false, valueErr or ""
		end

		return true
	end
end

--[[**
	ensures value is a table and all keys pass valueCheck and all values are true

	@param valueCheck The function to use to check the values

	@returns A function that will return true iff the condition is passed
**--]]
function t.set(valueCheck)
	return t.map(valueCheck, t.literal(true))
end

do
	local arrayKeysCheck = t.keys(t.integer)
	--[[**
		ensures value is an array and all values of the array match check

		@param check The check to compare all values with

		@returns A function that will return true iff the condition is passed
	**--]]
	function t.array(check)
		assert(t.callback(check))
		local valuesCheck = t.values(check)

		return function(value)
			local keySuccess, keyErrMsg = arrayKeysCheck(value)
			if keySuccess == false then
				return false, string.format("[array] %s", keyErrMsg or "")
			end

			-- # is unreliable for sparse arrays
			-- Count upwards using ipairs to avoid false positives from the behavior of #
			local arraySize = 0

			for _ in ipairs(value) do
				arraySize = arraySize + 1
			end

			for key in pairs(value) do
				if key < 1 or key > arraySize then
					return false, string.format("[array] key %s must be sequential", tostring(key))
				end
			end

			local valueSuccess, valueErrMsg = valuesCheck(value)
			if not valueSuccess then
				return false, string.format("[array] %s", valueErrMsg or "")
			end

			return true
		end
	end

	--[[**
		ensures value is an array of a strict makeup and size

		@param check The check to compare all values with

		@returns A function that will return true iff the condition is passed
	**--]]
	function t.strictArray(...)
		local valueTypes = { ... }
		assert(t.array(t.callback)(valueTypes))

		return function(value)
			local keySuccess, keyErrMsg = arrayKeysCheck(value)
			if keySuccess == false then
				return false, string.format("[strictArray] %s", keyErrMsg or "")
			end

			-- If there's more than the set array size, disallow
			if #valueTypes < #value then
				return false, string.format("[strictArray] Array size exceeds limit of %d", #valueTypes)
			end

			for idx, typeFn in pairs(valueTypes) do
				local typeSuccess, typeErrMsg = typeFn(value[idx])
				if not typeSuccess then
					return false, string.format("[strictArray] Array index #%d - %s", idx, typeErrMsg)
				end
			end

			return true
		end
	end
end

do
	local callbackArray = t.array(t.callback)
	--[[**
		creates a union type

		@param ... The checks to union

		@returns A function that will return true iff the condition is passed
	**--]]
	function t.union(...)
		local checks = { ... }
		assert(callbackArray(checks))

		return function(value)
			for _, check in ipairs(checks) do
				if check(value) then
					return true
				end
			end

			return false, "bad type for union"
		end
	end

	--[[**
		Alias for t.union
	**--]]
	t.some = t.union

	--[[**
		creates an intersection type

		@param ... The checks to intersect

		@returns A function that will return true iff the condition is passed
	**--]]
	function t.intersection(...)
		local checks = { ... }
		assert(callbackArray(checks))

		return function(value)
			for _, check in ipairs(checks) do
				local success, errMsg = check(value)
				if not success then
					return false, errMsg or ""
				end
			end

			return true
		end
	end

	--[[**
		Alias for t.intersection
	**--]]
	t.every = t.intersection
end

do
	local checkInterface = t.map(t.any, t.callback)
	--[[**
		ensures value matches given interface definition

		@param checkTable The interface definition

		@returns A function that will return true iff the condition is passed
	**--]]
	function t.interface(checkTable)
		assert(checkInterface(checkTable))
		return function(value)
			local tableSuccess, tableErrMsg = t.table(value)
			if tableSuccess == false then
				return false, tableErrMsg or ""
			end

			for key, check in pairs(checkTable) do
				local success, errMsg = check(value[key])
				if success == false then
					return false, string.format("[interface] bad value for %s:\n\t%s", tostring(key), errMsg or "")
				end
			end

			return true
		end
	end

	--[[**
		ensures value matches given interface definition strictly

		@param checkTable The interface definition

		@returns A function that will return true iff the condition is passed
	**--]]
	function t.strictInterface(checkTable)
		assert(checkInterface(checkTable))
		return function(value)
			local tableSuccess, tableErrMsg = t.table(value)
			if tableSuccess == false then
				return false, tableErrMsg or ""
			end

			for key, check in pairs(checkTable) do
				local success, errMsg = check(value[key])
				if success == false then
					return false, string.format("[interface] bad value for %s:\n\t%s", tostring(key), errMsg or "")
				end
			end

			for key in pairs(value) do
				if not checkTable[key] then
					return false, string.format("[interface] unexpected field %q", tostring(key))
				end
			end

			return true
		end
	end
end

--[[**
	ensure value is an Instance and it's ClassName matches the given ClassName

	@param className The class name to check for

	@returns A function that will return true iff the condition is passed
**--]]
function t.instanceOf(className, childTable)
	assert(t.string(className))

	local childrenCheck
	if childTable ~= nil then
		childrenCheck = t.children(childTable)
	end

	return function(value)
		local instanceSuccess, instanceErrMsg = t.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg or ""
		end

		if value.ClassName ~= className then
			return false, string.format("%s expected, got %s", className, value.ClassName)
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

--[[**
	ensure value is an Instance and it's ClassName matches the given ClassName by an IsA comparison

	@param className The class name to check for

	@returns A function that will return true iff the condition is passed
**--]]
function t.instanceIsA(className, childTable)
	assert(t.string(className))

	local childrenCheck
	if childTable ~= nil then
		childrenCheck = t.children(childTable)
	end

	return function(value)
		local instanceSuccess, instanceErrMsg = t.Instance(value)
		if not instanceSuccess then
			return false, instanceErrMsg or ""
		end

		if not value:IsA(className) then
			return false, string.format("%s expected, got %s", className, value.ClassName)
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

--[[**
	ensures value is an enum of the correct type

	@param enum The enum to check

	@returns A function that will return true iff the condition is passed
**--]]
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
			return false, string.format("enum of %s expected, got enum of %s", tostring(enum), tostring(value.EnumType))
		end
	end
end

do
	local checkWrap = t.tuple(t.callback, t.callback)

	--[[**
		wraps a callback in an assert with checkArgs

		@param callback The function to wrap
		@param checkArgs The functon to use to check arguments in the assert

		@returns A function that first asserts using checkArgs and then calls callback
	**--]]
	function t.wrap(callback, checkArgs)
		assert(checkWrap(callback, checkArgs))
		return function(...)
			assert(checkArgs(...))
			return callback(...)
		end
	end
end

--[[**
	asserts a given check

	@param check The function to wrap with an assert

	@returns A function that simply wraps the given check in an assert
**--]]
function t.strict(check)
	return function(...)
		assert(check(...))
	end
end

do
	local checkChildren = t.map(t.string, t.callback)

	--[[**
		Takes a table where keys are child names and values are functions to check the children against.
		Pass an instance tree into the function.
		If at least one child passes each check, the overall check passes.

		Warning! If you pass in a tree with more than one child of the same name, this function will always return false

		@param checkTable The table to check against

		@returns A function that checks an instance tree
	**--]]
	function t.children(checkTable)
		assert(checkChildren(checkTable))

		return function(value)
			local instanceSuccess, instanceErrMsg = t.Instance(value)
			if not instanceSuccess then
				return false, instanceErrMsg or ""
			end

			local childrenByName = {}
			for _, child in ipairs(value:GetChildren()) do
				local name = child.Name
				if checkTable[name] then
					if childrenByName[name] then
						return false, string.format("Cannot process multiple children with the same name %q", name)
					end

					childrenByName[name] = child
				end
			end

			for name, check in pairs(checkTable) do
				local success, errMsg = check(childrenByName[name])
				if not success then
					return false, string.format("[%s.%s] %s", value:GetFullName(), name, errMsg or "")
				end
			end

			return true
		end
	end
end

return t

end)() end,
    [90] = function()local wax,script,require=ImportGlobals(90)local ImportGlobals return (function(...)local Fusion = require(script.Parent.fusion)
local Value = Fusion.Value

local GlobalStates = {
	-- < Window states >
	Theme = Value("charcoal"),
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

	-- < Notification states >
	Notifications = Value({}),

	-- < Other states >
	FPSCheck = Value(true),
	PingCheck = Value(true),
	toDestroy = Value(false),
	HasSelected = Value(false),
}

function GlobalStates.add(state: string, value: any, name: string)
	if not GlobalStates[state] then
		error("No global state named: " .. state)
	end

	local globalState = GlobalStates[state]
	local newTable = table.clone(globalState:get())
	newTable[name] = value

	globalState:set(newTable)
end

return GlobalStates

end)() end,
    [91] = function()local wax,script,require=ImportGlobals(91)local ImportGlobals return (function(...)--[[
MIT License

Copyright (c) 2021 EgoMoose

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

local BLOCK = { 0, 1, 2, 3, 4, 5, 6, 7 }
local WEDGE = { 0, 1, 3, 4, 5, 7 }
local CORNER_WEDGE = { 0, 1, 4, 5, 6 }

-- Class

local ViewportModelClass = {}
ViewportModelClass.__index = ViewportModelClass
ViewportModelClass.ClassName = "ViewportModel"

-- Private

local function getIndices(part)
	if part:IsA("WedgePart") then
		return WEDGE
	elseif part:IsA("CornerWedgePart") then
		return CORNER_WEDGE
	end
	return BLOCK
end

local function getCorners(cf, size2, indices)
	local corners = {}
	for j, i in pairs(indices) do
		corners[j] = cf
			* (size2 * Vector3.new(2 * (math.floor(i / 4) % 2) - 1, 2 * (math.floor(i / 2) % 2) - 1, 2 * (i % 2) - 1))
	end
	return corners
end

local function getModelPointCloud(model)
	local points = {}
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local indices = getIndices(part)
			local corners = getCorners(part.CFrame, part.Size / 2, indices)
			for _, wp in pairs(corners) do
				table.insert(points, wp)
			end
		end
	end
	return points
end

local function viewProjectionEdgeHits(cloud, axis, depth, tanFov2)
	local max, min = -math.huge, math.huge

	for _, lp in pairs(cloud) do
		local distance = depth - lp.Z
		local halfSpan = tanFov2 * distance

		local a = lp[axis] + halfSpan
		local b = lp[axis] - halfSpan

		max = math.max(max, a, b)
		min = math.min(min, a, b)
	end

	return max, min
end

-- Public Constructors

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

-- Public Methods

-- Used to set the model that is being focused on
-- should be used for new models and/or a change in the current model
-- e.g. parts added/removed from the model or the model cframe changed
function ViewportModelClass:SetModel(model)
	self.Model = model

	local cf, size = model:GetBoundingBox()

	self._points = getModelPointCloud(model)
	self._modelCFrame = cf
	self._modelSize = size
	self._modelRadius = size.Magnitude / 2
end

-- Should be called when something about the viewport frame / camera changes
-- e.g. the frame size or the camera field of view
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

-- returns a fixed distance that is guarnteed to encapsulate the full model
-- this is useful for when you want to rotate freely around an object w/o expensive calculations
-- focus position can be used to set the origin of where the camera's looking
-- otherwise the model's center is assumed
function ViewportModelClass:GetFitDistance(focusPosition)
	local displacement = focusPosition and (focusPosition - self._modelCFrame.Position).Magnitude or 0
	local radius = self._modelRadius + displacement

	return radius / self._viewport.sincFov2
end

-- returns the optimal camera cframe that would be needed to best fit
-- the model in the viewport frame at the given orientation.
-- keep in mind this functions best when the model's point-cloud is correct
-- as such models that rely heavily on meshesh, csg, etc will only return an accurate
-- result as their point cloud
function ViewportModelClass:GetMinimumFitCFrame(orientation)
	if not self.Model then
		return CFrame.new()
	end

	local rotation = orientation - orientation.Position
	local rInverse = rotation:Inverse()

	local wcloud = self._points
	local cloud = { rInverse * wcloud[1] }
	local furthest = cloud[1].Z

	for i = 2, #wcloud do
		local lp = rInverse * wcloud[i]
		furthest = math.min(furthest, lp.Z)
		cloud[i] = lp
	end

	local hMax, hMin = viewProjectionEdgeHits(cloud, "X", furthest, self._viewport.tanxFov2)
	local vMax, vMin = viewProjectionEdgeHits(cloud, "Y", furthest, self._viewport.tanyFov2)

	local distance =
		math.max(((hMax - hMin) / 2) / self._viewport.tanxFov2, ((vMax - vMin) / 2) / self._viewport.tanyFov2)

	return orientation * CFrame.new((hMax + hMin) / 2, (vMax + vMin) / 2, furthest + distance)
end

--

return ViewportModelClass

end)() end,
    [93] = function()local wax,script,require=ImportGlobals(93)local ImportGlobals return (function(...)local Fusion = require(script.Parent.Parent.packages.fusion)
local Computed = Fusion.Computed
local States = require(script.Parent.Parent.packages.states)
local animate = require(script.Parent.Parent.utils.animate)

local THEME_COLOURS = {
	accent = {
		dark = Color3.fromRGB(0, 110, 230), -- Brighter blue
		twilight = Color3.fromRGB(115, 90, 235), -- Brighter purple
		shadow = Color3.fromRGB(60, 180, 200), -- Brighter cyan
		dusk = Color3.fromRGB(235, 145, 48), -- Brighter orange
		obsidian = Color3.fromRGB(110, 60, 190), -- Brighter purple
		charcoal = Color3.fromRGB(70, 190, 220), -- Brighter cyan
		slate = Color3.fromRGB(95, 170, 230), -- Brighter blue
		onyx = Color3.fromRGB(235, 125, 0), -- Brighter amber
		ash = Color3.fromRGB(120, 120, 230), -- Brighter lavender
		granite = Color3.fromRGB(85, 180, 210), -- Brighter teal
		cobalt = Color3.fromRGB(35, 135, 225), -- Brighter blue
		aurora = Color3.fromRGB(85, 175, 210), -- Brighter cyan
		sunset = Color3.fromRGB(225, 72, 32), -- Brighter orange-red
		mocha = Color3.fromRGB(170, 125, 225), -- Brighter mauve
		abyss = Color3.fromRGB(62, 80, 220), -- Brighter deep blue
		void = Color3.fromRGB(115, 70, 205), -- Brighter deep purple
		noir = Color3.fromRGB(120, 120, 120), -- Brighter gray
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
		mocha = Color3.fromRGB(30, 30, 46), -- Catppuccin Mocha Base
		abyss = Color3.fromRGB(10, 12, 16), -- Very dark blue-tinted black
		void = Color3.fromRGB(8, 8, 12), -- Extremely dark purple-tinted
		noir = Color3.fromRGB(10, 10, 10), -- Nearly black
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
		mocha = Color3.fromRGB(35, 35, 51), -- Catppuccin Mocha Surface0
		abyss = Color3.fromRGB(13, 15, 20), -- Slightly lighter abyss
		void = Color3.fromRGB(12, 12, 16), -- Slightly lighter void
		noir = Color3.fromRGB(13, 13, 13), -- Slightly lighter noir
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
		mocha = Color3.fromRGB(40, 40, 56), -- Catppuccin Mocha Surface1
		abyss = Color3.fromRGB(16, 18, 24), -- Abyss stroke
		void = Color3.fromRGB(15, 15, 20), -- Void stroke
		noir = Color3.fromRGB(16, 16, 16), -- Noir stroke
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
		mocha = Color3.fromRGB(205, 214, 244), -- Catppuccin Mocha Text
		abyss = Color3.fromRGB(220, 225, 235), -- Soft blue-white
		void = Color3.fromRGB(220, 220, 230), -- Soft purple-white
		noir = Color3.fromRGB(220, 220, 220), -- Soft white
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
		mocha = Color3.fromRGB(166, 173, 200), -- Catppuccin Mocha Subtext0
		abyss = Color3.fromRGB(140, 145, 160), -- Muted blue-white
		void = Color3.fromRGB(140, 140, 155), -- Muted purple-white
		noir = Color3.fromRGB(140, 140, 140), -- Muted white
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
		mocha = Color3.fromRGB(146, 158, 184), -- Catppuccin Mocha Subtext1
		abyss = Color3.fromRGB(120, 125, 140), -- Darker blue-white
		void = Color3.fromRGB(120, 120, 135), -- Darker purple-white
		noir = Color3.fromRGB(120, 120, 120), -- Darker white
	},

	danger = {
		dark = Color3.fromRGB(220, 50, 47), -- Deep red
		twilight = Color3.fromRGB(210, 55, 70), -- Muted red
		shadow = Color3.fromRGB(205, 60, 75), -- Cool red
		dusk = Color3.fromRGB(225, 65, 50), -- Warm red
		obsidian = Color3.fromRGB(215, 45, 65), -- Rich red
		charcoal = Color3.fromRGB(200, 55, 60), -- Grayish red
		slate = Color3.fromRGB(210, 50, 55), -- Cool red
		onyx = Color3.fromRGB(225, 55, 45), -- Bright red
		ash = Color3.fromRGB(205, 50, 65), -- Muted red
		granite = Color3.fromRGB(200, 45, 55), -- Deep red
		cobalt = Color3.fromRGB(215, 40, 50), -- Rich red
		aurora = Color3.fromRGB(195, 55, 70), -- Cool red
		sunset = Color3.fromRGB(230, 60, 45), -- Warm red
		mocha = Color3.fromRGB(210, 45, 60), -- Deep red
		abyss = Color3.fromRGB(190, 45, 55), -- Dark red
		void = Color3.fromRGB(200, 40, 60), -- Deep purple-red
		noir = Color3.fromRGB(185, 45, 50), -- Dark red
	},

	warning = {
		dark = Color3.fromRGB(215, 153, 33), -- Deep amber
		twilight = Color3.fromRGB(210, 145, 40), -- Muted gold
		shadow = Color3.fromRGB(205, 150, 45), -- Cool amber
		dusk = Color3.fromRGB(220, 155, 35), -- Warm amber
		obsidian = Color3.fromRGB(215, 140, 45), -- Rich gold
		charcoal = Color3.fromRGB(200, 145, 40), -- Grayish amber
		slate = Color3.fromRGB(210, 150, 35), -- Cool gold
		onyx = Color3.fromRGB(225, 155, 30), -- Bright amber
		ash = Color3.fromRGB(205, 145, 45), -- Muted amber
		granite = Color3.fromRGB(200, 140, 35), -- Deep amber
		cobalt = Color3.fromRGB(215, 135, 30), -- Rich amber
		aurora = Color3.fromRGB(195, 150, 45), -- Cool amber
		sunset = Color3.fromRGB(230, 155, 30), -- Warm gold
		mocha = Color3.fromRGB(210, 140, 40), -- Deep amber
		abyss = Color3.fromRGB(190, 140, 35), -- Dark amber
		void = Color3.fromRGB(200, 135, 40), -- Deep purple-amber
		noir = Color3.fromRGB(185, 140, 35), -- Dark amber
	},
}

local currentTheme = States.Theme

local currentColours = {}
for colorName, colorOptions in pairs(THEME_COLOURS) do
	if type(colorOptions) == "table" and type(colorOptions[next(colorOptions)]) == "table" then
		currentColours[colorName] = {}
		for subColorName, subColorOptions in pairs(colorOptions) do
			currentColours[colorName][subColorName] = Computed(function()
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

end)() end,
    [94] = function()local wax,script,require=ImportGlobals(94)local ImportGlobals return (function(...)--[[
	File: app.story.lua
]]

local Fusion = require(script.Parent.packages.fusion)

local story = {
	fusion = Fusion,
	story = function(props)
		local start = tick()

		local Library = require(script.Parent)

		local Window = Library:CreateWindow({
			Title = "KYANOS",
			Tag = "MEGA MANSION TYCOON",
			Size = UDim2.fromOffset(800, 600),
			Parent = props.target,
			Debug = true
		})
		
		local Categories = {
			Test = Window:AddCategory({ Title = "TESTING" }),
		}
		
		local Tabs = {
			TestUI = Categories.Test:AddTab({ Title = "Test" }),
		}

		local AimbotSection = Tabs.TestUI:AddSection({ Title = "TEST" })

		AimbotSection:AddText({Title = "Instructions", Description = "Click \"Add random entries\" to add random entries to the table.\nToggling the \"To Be toggled\" will randomize the values of all elements."})
		
		local Dropdown = {"Camera", "Silent"}
		AimbotSection:AddToggle("Toggle", {
			Title = "Toggle the toggle",
			Description = "Set's values of other UI elements randomly.",
			Default = false,
			Callback = function(v)
				Library.Options.ToBeToggled:SetValue(v)
				Library.Options.SilentAimChance:SetValue(math.random(1, 100))
				Library.Options.AimMode:SetValue(Dropdown[math.random(1, #Dropdown)])
			end
		})

		--[[AimbotSection:AddRadio("uniqueId1", {
			Title = "Select an Option",
			Options = {"Option 1", "Option 2", "Option 3"},
			Default = "Option 2",
			Callback = function(selectedOption)
				print("Selected option:", selectedOption)
			end,
		})]]

		AimbotSection:AddToggle("ToBeToggled", {
			Title = "To Be toggled",
			Default = false,
			Callback = function()
				local Dialog = Window:Dialog({Title = "DIALOG", Description = "This is the dialog component of the UI Library Kyanos."})
				Dialog:AddButton({Title = "Go Back", Style = "default"})
				Dialog:AddButton({Title = "Continue", Style = "primary", Callback = function()
					local SecondDialog = Window:Dialog({Title = "ANOTHER DIALOG", Description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mollis dolor eget erat mattis, id mollis mauris cursus. Proin ornare sollicitudin odio, id posuere diam luctus id."})
					SecondDialog:AddButton({Title = "OK", Style = "default"})
				end})
			end
		})

		AimbotSection:AddSlider("SilentAimChance", {
			Title = "Silent Aim Chance",
			Description = "Changes the Hit Chance for Silent Aim",
			Default = 100,
			Min = 1,
			Max = 100,
			Rounding = 1
		})

		AimbotSection:AddDropdown("AimMode", {
			Title = "Aim Mode",
			Description = "Changes the Aim Mode",
			Values = { "Camera", "Silent" },
			Default = "Camera"
		})

		local Keybind = AimbotSection:AddKeybind("Keybind", {
			Title = "KeyBind",
			Description = "Automatically farms resources/kills",
			Mode = "Hold",
			Default = "LeftControl",
			ChangedCallback = function(New)
				print("Keybind changed:", New)
			end
		})
		task.spawn(function()
			while true do
				task.wait(1)
				local state = Keybind:GetState()
				if state then
					print("Keybind is being held down")
				end
				if Library.Unloaded then break end
			end
		end)

		AimbotSection:AddInput("WaypointInput", {
			Title = "Add Waypoint",
			Description = "Add and save a waypoint to teleport to.",
			Default = "Default",
			Placeholder = "Placeholder",
			Numeric = false, -- Only allows numbers
			Finished = false, -- Only calls callback when you press enter
			Callback = function(Value)
				print("Input changed:", Value)
			end
		})

local demonSlayerMoves = {
    { "Water Surface Slash", 1234567890, 0.15 },
    { "Hinokami Kagura", 2345678901, 0.28 },
    { "Thunderclap and Flash", 3456789012, 0.18 },
    { "Flame Dance", 4567890123, 0.22 },
    { "Raging Sun", 5678901234, 0.25 },
    { "Whirlpool", 6789012345, 0.30 },
    { "Constant Flux", 7890123456, 0.21 },
    { "Dance of the Fire God", 8901234567, 0.27 },
    { "Clear Blue Sky", 9012345678, 0.24 },
    { "Fifth Form: Blessed Rain After the Drought", 1357902468, 0.20 }
}

-- Random entry button
AimbotSection:AddButton({
    Title = "Add random entries",
    Style = "default",
    Callback = function()
        local numberOfEntries = math.random(1, #demonSlayerMoves)
        local newRows = {}

        for i = 1, numberOfEntries do
            -- Select a random move from the list
            local randomMove = demonSlayerMoves[math.random(1, #demonSlayerMoves)]
            -- Add the move to the new rows table
            table.insert(newRows, randomMove)
        end

        -- Update the table with multiple new random moves
        Library.Options.Table:UpdateRows(newRows)
    end
})

-- Initial table component with existing data
AimbotSection:AddTable("Table", {
    Title = "Auto Parry Animations",
    Description = "All animations supported by the auto parry module",
    Headers = { "Animation Name", "Animation ID", "Timing", "Confident?"},
    Rows = demonSlayerMoves,
	AlternateBackground = true,
})

		return function()
			Library:Destroy()
		end
    end
}

return story
end)() end,
    [96] = function()local wax,script,require=ImportGlobals(96)local ImportGlobals return (function(...)local Fusion = require("packages/fusion")
local Spring = Fusion.Spring
local Computed = Fusion.Computed

return function(callback, speed, damping)
	return Spring(Computed(callback), speed, damping)
end

end)() end,
    [97] = function()local wax,script,require=ImportGlobals(97)local ImportGlobals return (function(...)local ColorUtils = {}

function ColorUtils.darkenRGB(Color, factor: number)
	return Color3.fromRGB((Color.R * 255) - factor, (Color.G * 255) - factor, (Color.B * 255) - factor)
end

function ColorUtils.lightenRGB(Color, factor: number)
	return Color3.fromRGB((Color.R * 255) + factor, (Color.G * 255) + factor, (Color.B * 255) + factor)
end

return ColorUtils

end)() end,
    [98] = function()local wax,script,require=ImportGlobals(98)local ImportGlobals return (function(...)local unwrap = require("utils/unwrap")

return function(container, element)
    local currentItems = unwrap(container)
    table.insert(currentItems, element)
    container:set(currentItems)
end
end)() end,
    [99] = function()local wax,script,require=ImportGlobals(99)local ImportGlobals return (function(...)local Player = {}

local Players = game:GetService("Players")

local ACCEPTED_ROOTS = {
	"HumanoidRootPart",
	"Torso",
	"UpperTorso",
	"LowerTorso",
	"Head",
}

local function chunkMatch(chunk, str)
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

function Player.getByName(name: string)
	local players = Players:GetPlayers()

	for _, player in players do
		if chunkMatch(string.lower(player.Name), name) or chunkMatch(string.lower(player.DisplayName), name) then
			return player
		end
	end

	return nil
end

function Player.setPosition(position: CFrame)
	local character = Player.getCharacter()

	character:PivotTo(position)
end

function Player.getRoot(player)
	for _, object in player.Character:GetChildren() do
		if table.find(ACCEPTED_ROOTS, object.Name) then
			return object
		end
	end

	return nil
end

function Player.getHumanoid()
	return Player.getCharacter():FindFirstChildWhichIsA("Humanoid")
end

return Player

end)() end,
    [100] = function()local wax,script,require=ImportGlobals(100)local ImportGlobals return (function(...)local Promise = require("packages/promise")

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

end)() end,
    [101] = function()local wax,script,require=ImportGlobals(101)local ImportGlobals return (function(...)return function(callback: () -> ...any): thread
	local ok, result = pcall(callback)

	if not ok then
		error(result)
	end

	return result
end

end)() end,
    [102] = function()local wax,script,require=ImportGlobals(102)local ImportGlobals return (function(...)return setmetatable({}, {
	__index = function(self, serviceName)
		local service = game:GetService(serviceName)
		self[serviceName] = service

		return service
	end,
})

end)() end,
    [103] = function()local wax,script,require=ImportGlobals(103)local ImportGlobals return (function(...)return function(x: any, useDependency: boolean?): any
	if typeof(x) == "table" and x.type == "State" then
		return x:get(useDependency)
	end

	return x
end

end)() end
} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        2,
        {
            "Kyanos"
        },
        {
            {
                22,
                2,
                {
                    "mock.story"
                }
            },
            {
                14,
                1,
                {
                    "components"
                },
                {
                    {
                        15,
                        1,
                        {
                            "notification"
                        }
                    },
                    {
                        16,
                        1,
                        {
                            "window"
                        },
                        {
                            {
                                18,
                                2,
                                {
                                    "dialog"
                                }
                            },
                            {
                                21,
                                2,
                                {
                                    "window"
                                }
                            },
                            {
                                17,
                                2,
                                {
                                    "category"
                                }
                            },
                            {
                                20,
                                2,
                                {
                                    "tab"
                                }
                            },
                            {
                                19,
                                2,
                                {
                                    "section"
                                }
                            }
                        }
                    }
                }
            },
            {
                95,
                1,
                {
                    "utils"
                },
                {
                    {
                        103,
                        2,
                        {
                            "unwrap"
                        }
                    },
                    {
                        97,
                        2,
                        {
                            "color3"
                        }
                    },
                    {
                        101,
                        2,
                        {
                            "safecallback"
                        }
                    },
                    {
                        102,
                        2,
                        {
                            "services"
                        }
                    },
                    {
                        100,
                        2,
                        {
                            "request"
                        }
                    },
                    {
                        96,
                        2,
                        {
                            "animate"
                        }
                    },
                    {
                        99,
                        2,
                        {
                            "player"
                        }
                    },
                    {
                        98,
                        2,
                        {
                            "insertitem"
                        }
                    }
                }
            },
            {
                94,
                2,
                {
                    "test.story"
                }
            },
            {
                23,
                1,
                {
                    "packages"
                },
                {
                    {
                        91,
                        2,
                        {
                            "viewport"
                        }
                    },
                    {
                        90,
                        2,
                        {
                            "states"
                        }
                    },
                    {
                        81,
                        2,
                        {
                            "promise"
                        }
                    },
                    {
                        82,
                        2,
                        {
                            "snapdragon"
                        },
                        {
                            {
                                84,
                                2,
                                {
                                    "Signal"
                                }
                            },
                            {
                                83,
                                2,
                                {
                                    "Maid"
                                }
                            },
                            {
                                89,
                                2,
                                {
                                    "t"
                                }
                            },
                            {
                                86,
                                2,
                                {
                                    "SnapdragonRef"
                                }
                            },
                            {
                                85,
                                2,
                                {
                                    "SnapdragonController"
                                }
                            },
                            {
                                87,
                                2,
                                {
                                    "Symbol"
                                }
                            },
                            {
                                88,
                                2,
                                {
                                    "objectAssign"
                                }
                            }
                        }
                    },
                    {
                        24,
                        2,
                        {
                            "damerau"
                        }
                    },
                    {
                        25,
                        2,
                        {
                            "freecam"
                        }
                    },
                    {
                        80,
                        2,
                        {
                            "maid"
                        }
                    },
                    {
                        26,
                        2,
                        {
                            "fusion"
                        },
                        {
                            {
                                63,
                                1,
                                {
                                    "State"
                                },
                                {
                                    {
                                        70,
                                        2,
                                        {
                                            "unwrap"
                                        }
                                    },
                                    {
                                        68,
                                        2,
                                        {
                                            "Observer"
                                        }
                                    },
                                    {
                                        69,
                                        2,
                                        {
                                            "Value"
                                        }
                                    },
                                    {
                                        65,
                                        2,
                                        {
                                            "ForKeys"
                                        }
                                    },
                                    {
                                        67,
                                        2,
                                        {
                                            "ForValues"
                                        }
                                    },
                                    {
                                        66,
                                        2,
                                        {
                                            "ForPairs"
                                        }
                                    },
                                    {
                                        64,
                                        2,
                                        {
                                            "Computed"
                                        }
                                    }
                                }
                            },
                            {
                                71,
                                2,
                                {
                                    "Types"
                                }
                            },
                            {
                                37,
                                1,
                                {
                                    "Colour"
                                },
                                {
                                    {
                                        38,
                                        2,
                                        {
                                            "Oklab"
                                        }
                                    }
                                }
                            },
                            {
                                39,
                                1,
                                {
                                    "Dependencies"
                                },
                                {
                                    {
                                        43,
                                        2,
                                        {
                                            "updateAll"
                                        }
                                    },
                                    {
                                        42,
                                        2,
                                        {
                                            "sharedState"
                                        }
                                    },
                                    {
                                        44,
                                        2,
                                        {
                                            "useDependency"
                                        }
                                    },
                                    {
                                        41,
                                        2,
                                        {
                                            "initDependency"
                                        }
                                    },
                                    {
                                        40,
                                        2,
                                        {
                                            "captureDependencies"
                                        }
                                    }
                                }
                            },
                            {
                                72,
                                1,
                                {
                                    "Utility"
                                },
                                {
                                    {
                                        76,
                                        2,
                                        {
                                            "isSimilar"
                                        }
                                    },
                                    {
                                        79,
                                        2,
                                        {
                                            "xtypeof"
                                        }
                                    },
                                    {
                                        77,
                                        2,
                                        {
                                            "needsDestruction"
                                        }
                                    },
                                    {
                                        75,
                                        2,
                                        {
                                            "doNothing"
                                        }
                                    },
                                    {
                                        74,
                                        2,
                                        {
                                            "cleanup"
                                        }
                                    },
                                    {
                                        78,
                                        2,
                                        {
                                            "restrictRead"
                                        }
                                    },
                                    {
                                        73,
                                        2,
                                        {
                                            "None"
                                        }
                                    }
                                }
                            },
                            {
                                45,
                                1,
                                {
                                    "Instances"
                                },
                                {
                                    {
                                        47,
                                        2,
                                        {
                                            "Cleanup"
                                        }
                                    },
                                    {
                                        50,
                                        2,
                                        {
                                            "OnChange"
                                        }
                                    },
                                    {
                                        48,
                                        2,
                                        {
                                            "Hydrate"
                                        }
                                    },
                                    {
                                        46,
                                        2,
                                        {
                                            "Children"
                                        }
                                    },
                                    {
                                        55,
                                        2,
                                        {
                                            "defaultProps"
                                        }
                                    },
                                    {
                                        52,
                                        2,
                                        {
                                            "Out"
                                        }
                                    },
                                    {
                                        53,
                                        2,
                                        {
                                            "Ref"
                                        }
                                    },
                                    {
                                        54,
                                        2,
                                        {
                                            "applyInstanceProps"
                                        }
                                    },
                                    {
                                        49,
                                        2,
                                        {
                                            "New"
                                        }
                                    },
                                    {
                                        51,
                                        2,
                                        {
                                            "OnEvent"
                                        }
                                    }
                                }
                            },
                            {
                                62,
                                2,
                                {
                                    "PubTypes"
                                }
                            },
                            {
                                27,
                                1,
                                {
                                    "Animation"
                                },
                                {
                                    {
                                        34,
                                        2,
                                        {
                                            "packType"
                                        }
                                    },
                                    {
                                        33,
                                        2,
                                        {
                                            "lerpType"
                                        }
                                    },
                                    {
                                        32,
                                        2,
                                        {
                                            "getTweenRatio"
                                        }
                                    },
                                    {
                                        28,
                                        2,
                                        {
                                            "Spring"
                                        }
                                    },
                                    {
                                        36,
                                        2,
                                        {
                                            "unpackType"
                                        }
                                    },
                                    {
                                        35,
                                        2,
                                        {
                                            "springCoefficients"
                                        }
                                    },
                                    {
                                        29,
                                        2,
                                        {
                                            "SpringScheduler"
                                        }
                                    },
                                    {
                                        31,
                                        2,
                                        {
                                            "TweenScheduler"
                                        }
                                    },
                                    {
                                        30,
                                        2,
                                        {
                                            "Tween"
                                        }
                                    }
                                }
                            },
                            {
                                56,
                                1,
                                {
                                    "Logging"
                                },
                                {
                                    {
                                        59,
                                        2,
                                        {
                                            "logWarn"
                                        }
                                    },
                                    {
                                        60,
                                        2,
                                        {
                                            "messages"
                                        }
                                    },
                                    {
                                        57,
                                        2,
                                        {
                                            "logError"
                                        }
                                    },
                                    {
                                        58,
                                        2,
                                        {
                                            "logErrorNonFatal"
                                        }
                                    },
                                    {
                                        61,
                                        2,
                                        {
                                            "parseError"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            },
            {
                92,
                1,
                {
                    "storage"
                },
                {
                    {
                        93,
                        2,
                        {
                            "theme"
                        }
                    }
                }
            },
            {
                2,
                2,
                {
                    "Elements"
                },
                {
                    {
                        8,
                        2,
                        {
                            "radio"
                        }
                    },
                    {
                        6,
                        2,
                        {
                            "input"
                        }
                    },
                    {
                        5,
                        2,
                        {
                            "dropdown"
                        }
                    },
                    {
                        3,
                        2,
                        {
                            "button"
                        }
                    },
                    {
                        7,
                        2,
                        {
                            "keybind"
                        }
                    },
                    {
                        12,
                        2,
                        {
                            "text"
                        }
                    },
                    {
                        9,
                        2,
                        {
                            "seperator"
                        }
                    },
                    {
                        13,
                        2,
                        {
                            "toggle"
                        }
                    },
                    {
                        11,
                        2,
                        {
                            "table"
                        }
                    },
                    {
                        10,
                        2,
                        {
                            "slider"
                        }
                    },
                    {
                        4,
                        2,
                        {
                            "colorpicker"
                        }
                    }
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    8,
    154,
    168,
    394,
    1038,
    1655,
    1954,
    2302,
    2477,
    2552,
    2933,
    3309,
    3457,
    [17] = 3728,
    [18] = 3896,
    [19] = 4292,
    [20] = 4423,
    [21] = 4606,
    [22] = 5143,
    [24] = 6113,
    [25] = 6185,
    [26] = 6688,
    [28] = 6774,
    [29] = 6992,
    [30] = 7082,
    [31] = 7219,
    [32] = 7291,
    [33] = 7335,
    [34] = 7463,
    [35] = 7530,
    [36] = 7614,
    [38] = 7698,
    [40] = 7753,
    [41] = 7805,
    [42] = 7835,
    [43] = 7860,
    [44] = 7921,
    [46] = 7952,
    [47] = 8099,
    [48] = 8121,
    [49] = 8142,
    [50] = 8179,
    [51] = 8218,
    [52] = 8256,
    [53] = 8300,
    [54] = 8331,
    [55] = 8464,
    [57] = 8575,
    [58] = 8612,
    [59] = 8651,
    [60] = 8676,
    [61] = 8723,
    [62] = 8747,
    [64] = 8892,
    [65] = 9007,
    [66] = 9247,
    [67] = 9554,
    [68] = 9795,
    [69] = 9880,
    [70] = 9944,
    [71] = 9961,
    [73] = 10109,
    [74] = 10124,
    [75] = 10178,
    [76] = 10189,
    [77] = 10208,
    [78] = 10222,
    [79] = 10252,
    [80] = 10273,
    [81] = 10402,
    [82] = 12461,
    [83] = 12483,
    [84] = 12607,
    [85] = 12642,
    [86] = 13037,
    [87] = 13065,
    [88] = 13097,
    [89] = 13110,
    [90] = 14291,
    [91] = 14335,
    [93] = 14525,
    [94] = 14733,
    [96] = 14898,
    [97] = 14907,
    [98] = 14920,
    [99] = 14928,
    [100] = 15003,
    [101] = 15020,
    [102] = 15031,
    [103] = 15041
}

-- Misc AOT variable imports
local WaxVersion = "0.4.1"
local EnvName = "WaxRuntime"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, true)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
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
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
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

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
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

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
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
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "table" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == ".." then
                    RealIndex = "Parent"
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot:GetChildren()[1])
