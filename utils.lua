local Utils = {}

Utils.BASE_URL = "" -- set by main.lua at init

function Utils.httpGet(path)
    local url = Utils.BASE_URL .. path
    local ok, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok then
        warn("[Utils] HttpGet failed for: " .. url .. " — " .. tostring(result))
        return nil
    end
    return result
end

function Utils.loadModule(path)
    local source = Utils.httpGet(path)
    if not source or #source == 0 then
        warn("[Utils] Empty or nil source for: " .. path)
        return nil
    end
    local fn, err = loadstring(source)
    if not fn then
        warn("[Utils] Loadstring failed for: " .. path .. " — " .. tostring(err))
        return nil
    end
    return fn()
end

function Utils.notify(library, title, content, duration)
    library:Notify{
        Title = title,
        Content = content,
        Duration = duration or 5
    }
end

function Utils.getPlayer()
    return game:GetService("Players").LocalPlayer
end

function Utils.getCharacter()
    local player = Utils.getPlayer()
    return player and player.Character
end

function Utils.getHumanoid()
    local char = Utils.getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils.getRootPart()
    local char = Utils.getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

return Utils
