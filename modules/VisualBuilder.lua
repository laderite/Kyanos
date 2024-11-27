local VisualBuilder = {
    Options = {},
    Library = nil,
    Sense = nil
}

function VisualBuilder:SetLibrary(Library)
    self.Library = Library
end

function VisualBuilder:SetSense(Sense)
    self.Sense = Sense
end

local function addESPSection(self, Tab, teamType)
    local settings = self.Sense.teamSettings[teamType]
    local capitalizedTeam = teamType:sub(1,1):upper() .. teamType:sub(2)
    local Section = Tab:AddSection(capitalizedTeam .. " ESP")

    -- Main Toggle
    self.Options[teamType .. "Enabled"] = Section:AddToggle(teamType .. "Enabled", {
        Title = capitalizedTeam .. " ESP Enabled",
        Default = settings.enabled,
        Callback = function(Value)
            settings.enabled = Value
        end
    })

    -- Box Settings
    local BoxSection = Tab:AddSection(capitalizedTeam .. " Box Settings")

    self.Options[teamType .. "Box"] = BoxSection:AddToggle(teamType .. "Box", {
        Title = "Box ESP",
        Default = settings.box,
        Callback = function(Value)
            settings.box = Value
        end
    })

    self.Options[teamType .. "BoxColor"] = BoxSection:AddColorpicker(teamType .. "BoxColor", {
        Title = "Box Color",
        Default = settings.boxColor[1],
        Callback = function(Value)
            settings.boxColor[1] = Value
        end
    })

    self.Options[teamType .. "BoxTransparency"] = BoxSection:AddSlider(teamType .. "BoxTransparency", {
        Title = "Box Transparency",
        Default = settings.boxColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.boxColor[2] = Value
        end
    })

    self.Options[teamType .. "BoxOutline"] = BoxSection:AddToggle(teamType .. "BoxOutline", {
        Title = "Box Outline",
        Default = settings.boxOutline,
        Callback = function(Value)
            settings.boxOutline = Value
        end
    })

    self.Options[teamType .. "BoxOutlineColor"] = BoxSection:AddColorpicker(teamType .. "BoxOutlineColor", {
        Title = "Box Outline Color",
        Default = settings.boxOutlineColor[1],
        Callback = function(Value)
            settings.boxOutlineColor[1] = Value
        end
    })

    self.Options[teamType .. "BoxFill"] = BoxSection:AddToggle(teamType .. "BoxFill", {
        Title = "Box Fill",
        Default = settings.boxFill,
        Callback = function(Value)
            settings.boxFill = Value
        end
    })

    self.Options[teamType .. "BoxFillColor"] = BoxSection:AddColorpicker(teamType .. "BoxFillColor", {
        Title = "Box Fill Color",
        Default = settings.boxFillColor[1],
        Callback = function(Value)
            settings.boxFillColor[1] = Value
        end
    })

    self.Options[teamType .. "BoxFillTransparency"] = BoxSection:AddSlider(teamType .. "BoxFillTransparency", {
        Title = "Box Fill Transparency",
        Default = settings.boxFillColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.boxFillColor[2] = Value
        end
    })

    -- Box3D Settings
    local Box3DSection = Tab:AddSection(capitalizedTeam .. " 3D Box Settings")

    self.Options[teamType .. "Box3D"] = Box3DSection:AddToggle(teamType .. "Box3D", {
        Title = "3D Box",
        Default = settings.box3d,
        Callback = function(Value)
            settings.box3d = Value
        end
    })

    self.Options[teamType .. "Box3DColor"] = Box3DSection:AddColorpicker(teamType .. "Box3DColor", {
        Title = "3D Box Color",
        Default = settings.box3dColor[1],
        Callback = function(Value)
            settings.box3dColor[1] = Value
        end
    })

    self.Options[teamType .. "Box3DTransparency"] = Box3DSection:AddSlider(teamType .. "Box3DTransparency", {
        Title = "3D Box Transparency",
        Default = settings.box3dColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.box3dColor[2] = Value
        end
    })

    -- Health Bar Settings
    local HealthSection = Tab:AddSection(capitalizedTeam .. " Health Settings")

    self.Options[teamType .. "HealthBar"] = HealthSection:AddToggle(teamType .. "HealthBar", {
        Title = "Health Bar",
        Default = settings.healthBar,
        Callback = function(Value)
            settings.healthBar = Value
        end
    })

    self.Options[teamType .. "HealthyColor"] = HealthSection:AddColorpicker(teamType .. "HealthyColor", {
        Title = "Full Health Color",
        Default = settings.healthyColor,
        Callback = function(Value)
            settings.healthyColor = Value
        end
    })

    self.Options[teamType .. "DyingColor"] = HealthSection:AddColorpicker(teamType .. "DyingColor", {
        Title = "Low Health Color",
        Default = settings.dyingColor,
        Callback = function(Value)
            settings.dyingColor = Value
        end
    })

    self.Options[teamType .. "HealthBarOutline"] = HealthSection:AddToggle(teamType .. "HealthBarOutline", {
        Title = "Health Bar Outline",
        Default = settings.healthBarOutline,
        Callback = function(Value)
            settings.healthBarOutline = Value
        end
    })

    self.Options[teamType .. "HealthBarOutlineColor"] = HealthSection:AddColorpicker(teamType .. "HealthBarOutlineColor", {
        Title = "Health Bar Outline Color",
        Default = settings.healthBarOutlineColor[1],
        Callback = function(Value)
            settings.healthBarOutlineColor[1] = Value
        end
    })

    self.Options[teamType .. "HealthText"] = HealthSection:AddToggle(teamType .. "HealthText", {
        Title = "Health Text",
        Default = settings.healthText,
        Callback = function(Value)
            settings.healthText = Value
        end
    })

    self.Options[teamType .. "HealthTextColor"] = HealthSection:AddColorpicker(teamType .. "HealthTextColor", {
        Title = "Health Text Color",
        Default = settings.healthTextColor[1],
        Callback = function(Value)
            settings.healthTextColor[1] = Value
        end
    })

    self.Options[teamType .. "HealthTextTransparency"] = HealthSection:AddSlider(teamType .. "HealthTextTransparency", {
        Title = "Health Text Transparency",
        Default = settings.healthTextColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.healthTextColor[2] = Value
        end
    })

    self.Options[teamType .. "HealthTextOutline"] = HealthSection:AddToggle(teamType .. "HealthTextOutline", {
        Title = "Health Text Outline",
        Default = settings.healthTextOutline,
        Callback = function(Value)
            settings.healthTextOutline = Value
        end
    })

    self.Options[teamType .. "HealthTextOutlineColor"] = HealthSection:AddColorpicker(teamType .. "HealthTextOutlineColor", {
        Title = "Health Text Outline Color",
        Default = settings.healthTextOutlineColor,
        Callback = function(Value)
            settings.healthTextOutlineColor = Value
        end
    })

    -- Name Settings
    local NameSection = Tab:AddSection(capitalizedTeam .. " Name Settings")

    self.Options[teamType .. "Name"] = NameSection:AddToggle(teamType .. "Name", {
        Title = "Show Name",
        Default = settings.name,
        Callback = function(Value)
            settings.name = Value
        end
    })

    self.Options[teamType .. "NameColor"] = NameSection:AddColorpicker(teamType .. "NameColor", {
        Title = "Name Color",
        Default = settings.nameColor[1],
        Callback = function(Value)
            settings.nameColor[1] = Value
        end
    })

    self.Options[teamType .. "NameOutline"] = NameSection:AddToggle(teamType .. "NameOutline", {
        Title = "Name Outline",
        Default = settings.nameOutline,
        Callback = function(Value)
            settings.nameOutline = Value
        end
    })

    self.Options[teamType .. "NameOutlineColor"] = NameSection:AddColorpicker(teamType .. "NameOutlineColor", {
        Title = "Name Outline Color",
        Default = settings.nameOutlineColor,
        Callback = function(Value)
            settings.nameOutlineColor = Value
        end
    })

    -- Distance Settings
    local DistanceSection = Tab:AddSection(capitalizedTeam .. " Distance Settings")

    self.Options[teamType .. "Distance"] = DistanceSection:AddToggle(teamType .. "Distance", {
        Title = "Show Distance",
        Default = settings.distance,
        Callback = function(Value)
            settings.distance = Value
        end
    })

    self.Options[teamType .. "DistanceColor"] = DistanceSection:AddColorpicker(teamType .. "DistanceColor", {
        Title = "Distance Color",
        Default = settings.distanceColor[1],
        Callback = function(Value)
            settings.distanceColor[1] = Value
        end
    })

    self.Options[teamType .. "DistanceOutline"] = DistanceSection:AddToggle(teamType .. "DistanceOutline", {
        Title = "Distance Text Outline",
        Default = settings.distanceOutline,
        Callback = function(Value)
            settings.distanceOutline = Value
        end
    })

    self.Options[teamType .. "DistanceOutlineColor"] = DistanceSection:AddColorpicker(teamType .. "DistanceOutlineColor", {
        Title = "Distance Outline Color",
        Default = settings.distanceOutlineColor,
        Callback = function(Value)
            settings.distanceOutlineColor = Value
        end
    })

    -- Tracer Settings
    local TracerSection = Tab:AddSection(capitalizedTeam .. " Tracer Settings")

    self.Options[teamType .. "Tracer"] = TracerSection:AddToggle(teamType .. "Tracer", {
        Title = "Show Tracers",
        Default = settings.tracer,
        Callback = function(Value)
            settings.tracer = Value
        end
    })

    self.Options[teamType .. "TracerOrigin"] = TracerSection:AddDropdown(teamType .. "TracerOrigin", {
        Title = "Tracer Origin",
        Default = settings.tracerOrigin,
        Values = {"Top", "Bottom", "Center", "Mouse"},
        Callback = function(Value)
            settings.tracerOrigin = Value
        end
    })

    self.Options[teamType .. "TracerColor"] = TracerSection:AddColorpicker(teamType .. "TracerColor", {
        Title = "Tracer Color",
        Default = settings.tracerColor[1],
        Callback = function(Value)
            settings.tracerColor[1] = Value
        end
    })

    self.Options[teamType .. "TracerTransparency"] = TracerSection:AddSlider(teamType .. "TracerTransparency", {
        Title = "Tracer Transparency",
        Default = settings.tracerColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.tracerColor[2] = Value
        end
    })

    self.Options[teamType .. "TracerOutline"] = TracerSection:AddToggle(teamType .. "TracerOutline", {
        Title = "Tracer Outline",
        Default = settings.tracerOutline,
        Callback = function(Value)
            settings.tracerOutline = Value
        end
    })

    self.Options[teamType .. "TracerOutlineColor"] = TracerSection:AddColorpicker(teamType .. "TracerOutlineColor", {
        Title = "Tracer Outline Color",
        Default = settings.tracerOutlineColor[1],
        Callback = function(Value)
            settings.tracerOutlineColor[1] = Value
        end
    })

    -- Chams Settings
    local ChamsSection = Tab:AddSection(capitalizedTeam .. " Chams Settings")

    self.Options[teamType .. "Chams"] = ChamsSection:AddToggle(teamType .. "Chams", {
        Title = "Chams",
        Default = settings.chams,
        Callback = function(Value)
            settings.chams = Value
        end
    })

    self.Options[teamType .. "ChamsVisibleOnly"] = ChamsSection:AddToggle(teamType .. "ChamsVisibleOnly", {
        Title = "Visible Only",
        Default = settings.chamsVisibleOnly,
        Callback = function(Value)
            settings.chamsVisibleOnly = Value
        end
    })

    self.Options[teamType .. "ChamsFillColor"] = ChamsSection:AddColorpicker(teamType .. "ChamsFillColor", {
        Title = "Fill Color",
        Default = settings.chamsFillColor[1],
        Callback = function(Value)
            settings.chamsFillColor[1] = Value
        end
    })

    self.Options[teamType .. "ChamsFillTransparency"] = ChamsSection:AddSlider(teamType .. "ChamsFillTransparency", {
        Title = "Fill Transparency",
        Default = settings.chamsFillColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.chamsFillColor[2] = Value
        end
    })

    self.Options[teamType .. "ChamsOutlineColor"] = ChamsSection:AddColorpicker(teamType .. "ChamsOutlineColor", {
        Title = "Outline Color",
        Default = settings.chamsOutlineColor[1],
        Callback = function(Value)
            settings.chamsOutlineColor[1] = Value
        end
    })

    self.Options[teamType .. "ChamsOutlineTransparency"] = ChamsSection:AddSlider(teamType .. "ChamsOutlineTransparency", {
        Title = "Outline Transparency",
        Default = settings.chamsOutlineColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.chamsOutlineColor[2] = Value
        end
    })

    -- Weapon Settings
    local WeaponSection = Tab:AddSection(capitalizedTeam .. " Weapon Settings")

    self.Options[teamType .. "Weapon"] = WeaponSection:AddToggle(teamType .. "Weapon", {
        Title = "Show Weapon",
        Default = settings.weapon,
        Callback = function(Value)
            settings.weapon = Value
        end
    })

    self.Options[teamType .. "WeaponColor"] = WeaponSection:AddColorpicker(teamType .. "WeaponColor", {
        Title = "Weapon Text Color",
        Default = settings.weaponColor[1],
        Callback = function(Value)
            settings.weaponColor[1] = Value
        end
    })

    self.Options[teamType .. "WeaponTransparency"] = WeaponSection:AddSlider(teamType .. "WeaponTransparency", {
        Title = "Weapon Text Transparency",
        Default = settings.weaponColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.weaponColor[2] = Value
        end
    })

    self.Options[teamType .. "WeaponOutline"] = WeaponSection:AddToggle(teamType .. "WeaponOutline", {
        Title = "Weapon Text Outline",
        Default = settings.weaponOutline,
        Callback = function(Value)
            settings.weaponOutline = Value
        end
    })

    self.Options[teamType .. "WeaponOutlineColor"] = WeaponSection:AddColorpicker(teamType .. "WeaponOutlineColor", {
        Title = "Weapon Outline Color",
        Default = settings.weaponOutlineColor,
        Callback = function(Value)
            settings.weaponOutlineColor = Value
        end
    })

    -- Off-Screen Arrow Settings
    local ArrowSection = Tab:AddSection(capitalizedTeam .. " Off-Screen Arrow")

    self.Options[teamType .. "OffScreenArrow"] = ArrowSection:AddToggle(teamType .. "OffScreenArrow", {
        Title = "Show Off-Screen Arrows",
        Default = settings.offScreenArrow,
        Callback = function(Value)
            settings.offScreenArrow = Value
        end
    })

    self.Options[teamType .. "OffScreenArrowColor"] = ArrowSection:AddColorpicker(teamType .. "OffScreenArrowColor", {
        Title = "Arrow Color",
        Default = settings.offScreenArrowColor[1],
        Callback = function(Value)
            settings.offScreenArrowColor[1] = Value
        end
    })

    self.Options[teamType .. "OffScreenArrowTransparency"] = ArrowSection:AddSlider(teamType .. "OffScreenArrowTransparency", {
        Title = "Arrow Transparency",
        Default = settings.offScreenArrowColor[2],
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(Value)
            settings.offScreenArrowColor[2] = Value
        end
    })

    self.Options[teamType .. "OffScreenArrowSize"] = ArrowSection:AddSlider(teamType .. "OffScreenArrowSize", {
        Title = "Arrow Size",
        Default = settings.offScreenArrowSize,
        Min = 5,
        Max = 50,
        Rounding = 0,
        Callback = function(Value)
            settings.offScreenArrowSize = Value
        end
    })

    self.Options[teamType .. "OffScreenArrowRadius"] = ArrowSection:AddSlider(teamType .. "OffScreenArrowRadius", {
        Title = "Arrow Radius",
        Default = settings.offScreenArrowRadius,
        Min = 50,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
            settings.offScreenArrowRadius = Value
        end
    })

    self.Options[teamType .. "OffScreenArrowOutline"] = ArrowSection:AddToggle(teamType .. "OffScreenArrowOutline", {
        Title = "Arrow Outline",
        Default = settings.offScreenArrowOutline,
        Callback = function(Value)
            settings.offScreenArrowOutline = Value
        end
    })

    self.Options[teamType .. "OffScreenArrowOutlineColor"] = ArrowSection:AddColorpicker(teamType .. "OffScreenArrowOutlineColor", {
        Title = "Arrow Outline Color",
        Default = settings.offScreenArrowOutlineColor[1],
        Callback = function(Value)
            settings.offScreenArrowOutlineColor[1] = Value
        end
    })
end

function VisualBuilder:BuildVisualSection(Tab)
    assert(self.Library, "Library not set! Please call SetLibrary first.")
    assert(Tab, "Tab argument missing!")
    assert(self.Sense, "Sense instance missing! Please provide it in the constructor.")

    -- Shared Settings Section
    local SharedSection = Tab:AddSection("Shared Settings")

    self.Options.TextSize = SharedSection:AddSlider("TextSize", {
        Title = "Text Size",
        Default = self.Sense.sharedSettings.textSize,
        Min = 8,
        Max = 24,
        Rounding = 0,
        Callback = function(Value)
            self.Sense.sharedSettings.textSize = Value
        end
    })

    self.Options.TextFont = SharedSection:AddDropdown("TextFont", {
        Title = "Text Font",
        Default = "UI",
        Values = {"UI", "System", "Plex", "Monospace"},
        Callback = function(Value)
            local fontMap = {
                UI = 2,
                System = 1,
                Plex = 3,
                Monospace = 4
            }
            self.Sense.sharedSettings.textFont = fontMap[Value]
        end
    })

    self.Options.LimitDistance = SharedSection:AddToggle("LimitDistance", {
        Title = "Limit Distance",
        Default = self.Sense.sharedSettings.limitDistance,
        Callback = function(Value)
            self.Sense.sharedSettings.limitDistance = Value
        end
    })

    self.Options.MaxDistance = SharedSection:AddSlider("MaxDistance", {
        Title = "Max Distance",
        Default = self.Sense.sharedSettings.maxDistance,
        Min = 50,
        Max = 2000,
        Rounding = 0,
        Suffix = " studs",
        Callback = function(Value)
            self.Sense.sharedSettings.maxDistance = Value
        end
    })

    self.Options.UseTeamColor = SharedSection:AddToggle("UseTeamColor", {
        Title = "Use Team Colors",
        Default = self.Sense.sharedSettings.useTeamColor,
        Callback = function(Value)
            self.Sense.sharedSettings.useTeamColor = Value
        end
    })

    -- Add Enemy and Friendly sections
    addESPSection(self, Tab, "enemy")
    addESPSection(self, Tab, "friendly")
end

return VisualBuilder
