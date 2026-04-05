local BASE_URL = ... or "https://raw.githubusercontent.com/Proxo123/Blank/main/"

local Library = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau", true))()

local envSource = game:HttpGet(BASE_URL .. "env.lua", true)
local Env = loadstring(envSource)()

local utilsSource = game:HttpGet(BASE_URL .. "utils.lua", true)
local Utils = loadstring(utilsSource)()
Utils.BASE_URL = BASE_URL
Utils.Env = Env
Utils.debug = true

local report = Env.getReport()
if report.missingCount > 0 then
    warn("[Env] Executor: " .. report.executor .. " — Missing " .. report.missingCount .. " function(s):")
    for _, fn in ipairs(report.missing) do
        warn("  - " .. fn)
    end
end

local Window = Library:CreateWindow{
    Title = "Blank",
    SubTitle = "v1.0.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
}

local MODULE_LIST = {
    "example",
}

local loadedModules = {}

for _, name in ipairs(MODULE_LIST) do
    local path = "modules/" .. name .. ".lua"
    local ok, mod = pcall(Utils.loadModule, path)
    if ok and mod then
        loadedModules[name] = mod
    else
        warn("[Main] Failed to load module: " .. name .. " — " .. tostring(mod))
    end
end

for name, mod in pairs(loadedModules) do
    if type(mod.init) == "function" then
        local ok, err = pcall(mod.init, Window, Library, Utils, Env)
        if not ok then
            warn("[Main] Module init error (" .. name .. "): " .. tostring(err))
        end
    end
end

local SettingsTab = Window:CreateTab{
    Title = "Settings",
    Icon = "settings"
}

SettingsTab:CreateToggle("DebugToggle", {
    Title = "Debug Mode",
    Description = "Print debug info to dev console",
    Default = true,
    Callback = function(value)
        Utils.debug = value
    end
})

InterfaceManager:SetLibrary(Library)
InterfaceManager:SetFolder("Blank")
InterfaceManager:BuildInterfaceSection(SettingsTab)

Window:SelectTab(1)

Library:Notify{
    Title = "Blank",
    Content = report.executor .. " | " .. report.missingCount .. " missing fn",
    Duration = 5
}
