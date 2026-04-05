--// Module Template
--// 1. Copy this file and rename it (e.g. "myfeature.lua")
--// 2. Add the name (without .lua) to MODULE_LIST in main.lua
--// 3. Build your UI and logic inside init()

local module = {}

function module.init(Window, Library, Utils)
    local Tab = Window:CreateTab{
        Title = "Template",
        Icon = "phosphor-puzzle-piece-bold"
    }

    -- Example: paragraph
    Tab:CreateParagraph("Info", {
        Title = "Template Module",
        Content = "Replace this with your own logic."
    })

    -- Example: toggle
    local enabled = false
    Tab:CreateToggle("TemplateToggle", {
        Title = "Enable Feature",
        Default = false,
        Callback = function(value)
            enabled = value
            print("[Template] Toggled:", value)
        end
    })

    -- Example: button
    Tab:CreateButton{
        Title = "Do Something",
        Description = "Runs a one-time action",
        Callback = function()
            Utils.notify(Library, "Template", "Button clicked!")
        end
    }
end

return module
