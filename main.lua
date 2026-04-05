local BASE_URL = ... or "https://raw.githubusercontent.com/Proxo123/Blank/main/"

local Library = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau", true))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau", true))()

local envSource = game:HttpGet(BASE_URL .. "env.lua", true)
local Env = loadstring(envSource)()

local utilsSource = game:HttpGet(BASE_URL .. "utils.lua", true)
local Utils = loadstring(utilsSource)()
Utils.BASE_URL = BASE_URL
Utils.Env = Env

local Window = Library:CreateWindow{
    Title = "My Script",
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
    else
        warn("[Main] Module '" .. name .. "' has no init function")
    end
end

local SettingsTab = Window:CreateTab{
    Title = "Settings",
    Icon = "settings"
}

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}

InterfaceManager:SetFolder("MyScript")
SaveManager:SetFolder("MyScript/config")

InterfaceManager:BuildInterfaceSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

Window:SelectTab(1)

local envReport = Env.getReport()
Library:Notify{
    Title = "My Script",
    Content = "Loaded " .. #MODULE_LIST .. " module(s) on " .. envReport.executor .. " (" .. envReport.missingCount .. " missing fn).",
    Duration = 5
}

SaveManager:LoadAutoloadConfig()
