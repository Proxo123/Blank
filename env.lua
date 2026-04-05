local Env = {}

Env.executor = "Unknown"
Env.missing = {}

local function resolve(...)
    for _, v in ipairs({...}) do
        if type(v) == "function" then
            return v
        end
    end
    return nil
end

local function resolveNested(path)
    local parts = path:split(".")
    local current = getgenv and getgenv() or _G
    for _, part in ipairs(parts) do
        if type(current) ~= "table" then return nil end
        current = current[part]
    end
    return type(current) == "function" and current or nil
end

local function safeResolve(name, ...)
    local fn = resolve(...)
    if not fn then
        table.insert(Env.missing, name)
    end
    return fn
end

local function detect()
    local ok, name = pcall(function()
        if identifyexecutor then
            return identifyexecutor()
        end
    end)
    if ok and name then
        Env.executor = name
        return
    end

    ok, name = pcall(function()
        if getexecutorname then
            return getexecutorname()
        end
    end)
    if ok and name then
        Env.executor = name
        return
    end

    if syn then Env.executor = "Synapse"
    elseif fluxus then Env.executor = "Fluxus"
    elseif SENTINEL_V2 then Env.executor = "Sentinel"
    elseif KRNL_LOADED then Env.executor = "Krnl"
    elseif Celery then Env.executor = "Celery"
    elseif COMET_LOADED then Env.executor = "Comet"
    end
end

local function map()
    Env.request = safeResolve("request",
        request, http_request,
        resolveNested("syn.request"),
        resolveNested("http.request"),
        resolveNested("fluxus.request")
    )

    Env.hookFunction = safeResolve("hookfunction",
        hookfunction, detour_function, replaceclosure
    )

    Env.hookMetamethod = safeResolve("hookmetamethod",
        hookmetamethod
    )

    Env.newCClosure = safeResolve("newcclosure",
        newcclosure
    )

    Env.getRawMetatable = safeResolve("getrawmetatable",
        getrawmetatable
    )

    Env.setReadonly = safeResolve("setreadonly",
        setreadonly, make_writeable
    )

    Env.isExecutorClosure = safeResolve("isexecutorclosure",
        isexecutorclosure, checkclosure, is_synapse_function, isourclosure
    )

    Env.checkCaller = safeResolve("checkcaller",
        checkcaller
    )

    Env.getConnections = safeResolve("getconnections",
        getconnections, get_signal_cons
    )

    Env.fireSignal = safeResolve("firesignal",
        firesignal
    )

    Env.fireClickDetector = safeResolve("fireclickdetector",
        fireclickdetector
    )

    Env.fireProximityPrompt = safeResolve("fireproximityprompt",
        fireproximityprompt
    )

    Env.fireTouchInterest = safeResolve("firetouchinterest",
        firetouchinterest
    )

    Env.setIdentity = safeResolve("setidentity",
        setidentity, setthreadidentity, setthreadcontext,
        resolveNested("syn.set_thread_identity")
    )

    Env.getIdentity = safeResolve("getidentity",
        getidentity, getthreadidentity, getthreadcontext,
        resolveNested("syn.get_thread_identity")
    )

    Env.setClipboard = safeResolve("setclipboard",
        setclipboard, toclipboard,
        resolveNested("syn.write_clipboard")
    )

    Env.setFpsCap = safeResolve("setfpscap",
        setfpscap
    )

    Env.getGenv = safeResolve("getgenv", getgenv)
    Env.getRenv = safeResolve("getrenv", getrenv)
    Env.getSenv = safeResolve("getsenv", getsenv)

    Env.getInstances = safeResolve("getinstances", getinstances)
    Env.getNilInstances = safeResolve("getnilinstances", getnilinstances)
    Env.getScripts = safeResolve("getscripts", getscripts)
    Env.getLoadedModules = safeResolve("getloadedmodules", getloadedmodules)
    Env.decompile = safeResolve("decompile", decompile)
    Env.cloneRef = safeResolve("cloneref", cloneref)
    Env.compareInstances = safeResolve("compareinstances", compareinstances)

    Env.readFile = safeResolve("readfile", readfile)
    Env.writeFile = safeResolve("writefile", writefile)
    Env.appendFile = safeResolve("appendfile", appendfile)
    Env.isFile = safeResolve("isfile", isfile)
    Env.isFolder = safeResolve("isfolder", isfolder)
    Env.makeFolder = safeResolve("makefolder", makefolder)
    Env.listFiles = safeResolve("listfiles", listfiles)
    Env.delFile = safeResolve("delfile", delfile)
    Env.delFolder = safeResolve("delfolder", delfolder)

    Env.queueOnTeleport = safeResolve("queue_on_teleport",
        queue_on_teleport,
        resolveNested("syn.queue_on_teleport")
    )

    Env.protectGui = safeResolve("protect_gui",
        protect_gui, gethui,
        resolveNested("syn.protect_gui")
    )

    Env.mouse1Click = safeResolve("mouse1click", mouse1click)
    Env.mouse2Click = safeResolve("mouse2click", mouse2click)
    Env.mouseMoveRel = safeResolve("mousemoverel", mousemoverel)
    Env.mouseMoveAbs = safeResolve("mousemoveabs", mousemoveabs)
    Env.keyPress = safeResolve("keypress", keypress)
    Env.keyRelease = safeResolve("keyrelease", keyrelease)

    Env.hasDrawing = typeof(Drawing) == "table" and Drawing.new ~= nil

    Env.crypt = {}
    local cryptLib = type(crypt) == "table" and crypt or {}

    Env.crypt.base64Encode = safeResolve("base64encode",
        cryptLib.base64encode, cryptLib.base64_encode, base64_encode
    )
    Env.crypt.base64Decode = safeResolve("base64decode",
        cryptLib.base64decode, cryptLib.base64_decode, base64_decode
    )
end

function Env.has(name)
    return Env[name] ~= nil
end

function Env.call(name, ...)
    local fn = Env[name]
    if not fn then
        warn("[Env] " .. name .. " is not available on " .. Env.executor)
        return nil
    end
    return fn(...)
end

function Env.safeCall(name, ...)
    local fn = Env[name]
    if not fn then return false, nil end
    local ok, result = pcall(fn, ...)
    if not ok then
        warn("[Env] " .. name .. " errored: " .. tostring(result))
        return false, nil
    end
    return true, result
end

function Env.require(name)
    if not Env[name] then
        error("[Env] Required function '" .. name .. "' is missing on " .. Env.executor, 2)
    end
    return Env[name]
end

function Env.wrap(fn)
    if Env.newCClosure then
        return Env.newCClosure(fn)
    end
    return fn
end

function Env.getReport()
    local report = {}
    report.executor = Env.executor
    report.missing = Env.missing
    report.missingCount = #Env.missing
    report.hasDrawing = Env.hasDrawing
    report.hasFilesystem = Env.readFile ~= nil and Env.writeFile ~= nil
    report.hasHooking = Env.hookFunction ~= nil
    report.hasMetatableAccess = Env.getRawMetatable ~= nil
    report.hasInputControl = Env.mouse1Click ~= nil
    report.hasConnections = Env.getConnections ~= nil
    report.hasTeleportQueue = Env.queueOnTeleport ~= nil
    return report
end

detect()
map()

return Env
