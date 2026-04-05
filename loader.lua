--// Loader — paste this into your executor, or use a loadstring pointing to this file.
--// This is the only URL you ever need. Everything else is fetched relative to BASE_URL.

local BASE_URL = "https://raw.githubusercontent.com/Proxo123/Blank/main/"

local function httpGet(path)
    return game:HttpGet(BASE_URL .. path, true)
end

local mainSource = httpGet("main.lua")
assert(mainSource and #mainSource > 0, "[Loader] Failed to fetch main.lua")

loadstring(mainSource)(BASE_URL)
