local module = {}

function module.init(Window, Library, Utils, Env)
    local Tab = Window:CreateTab{
        Title = "Template",
        Icon = "phosphor-puzzle-piece-bold"
    }

    Tab:CreateParagraph("Info", {
        Title = "Template Module",
        Content = "Replace this with your own logic."
    })

    local enabled = false
    Tab:CreateToggle("TemplateToggle", {
        Title = "Enable Feature",
        Default = false,
        Callback = function(value)
            enabled = value
        end
    })

    Tab:CreateButton{
        Title = "Do Something",
        Description = "Runs a one-time action",
        Callback = function()
            Utils.notify(Library, "Template", "Button clicked!")
        end
    }
end

return module
