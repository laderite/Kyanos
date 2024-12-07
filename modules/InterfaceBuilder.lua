local InterfaceBuilder = {
    Options = {},
    Library = nil,
    Sense = nil,
}

function InterfaceBuilder:SetLibrary(Library)
    self.Library = Library
end

function InterfaceBuilder:BuildInterfaceSection(Tab)
    assert(self.Library, "Library not set! Please call SetLibrary first.")
    assert(Tab, "Tab argument missing!")

    -- Shared Settings Section
    local Section = Tab:AddSection({ Title = "INTERFACE" })

    Section:AddDropdown("ShowcaseTheme", {
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
            "mocha",
        },
        Default = "dark",
        Callback = function(value)
            self.Library:SetTheme(value)
        end,
    })

    Section:AddSlider("UIScale", {
        Title = "UI Scale",
        Description = "Adjusts the UI Size",
        Default = 100,
        Min = 75,
        Max = 150,
        Rounding = 1,
        Callback = function(value)
            self.Library.Window:SetScale(value / 100)
        end,
    })
end

return InterfaceBuilder
