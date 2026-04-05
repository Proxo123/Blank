local module = {}

function module.init(Window, Library, Utils, Env)
    local Tab = Window:CreateTab{
        Title = "Player",
        Icon = "phosphor-user-bold"
    }

    Tab:CreateButton{
        Title = "Environment Info",
        Description = "Dump executor, player, and game details to dev console (F9)",
        Callback = function()
            local report = Env.getReport()
            local player = Utils.getPlayer()

            local lines = {
                "========== ENVIRONMENT ==========",
                "Executor: " .. report.executor,
                "Missing Functions: " .. report.missingCount,
                "Drawing: " .. tostring(report.hasDrawing),
                "Filesystem: " .. tostring(report.hasFilesystem),
                "Hooking: " .. tostring(report.hasHooking),
                "Metatable Access: " .. tostring(report.hasMetatableAccess),
                "Input Control: " .. tostring(report.hasInputControl),
                "Connections: " .. tostring(report.hasConnections),
                "Teleport Queue: " .. tostring(report.hasTeleportQueue),
                "",
                "========== PLAYER ==========",
                "Username: " .. player.Name,
                "Display Name: " .. player.DisplayName,
                "User ID: " .. tostring(player.UserId),
                "Account Age: " .. tostring(player.AccountAge) .. " days",
                "Membership: " .. tostring(player.MembershipType),
                "",
                "========== GAME ==========",
                "Place ID: " .. tostring(game.PlaceId),
                "Game ID: " .. tostring(game.GameId),
                "Job ID: " .. game.JobId,
            }

            if report.missingCount > 0 then
                table.insert(lines, "")
                table.insert(lines, "========== MISSING FUNCTIONS ==========")
                for _, fn in ipairs(report.missing) do
                    table.insert(lines, "  - " .. fn)
                end
            end

            for _, line in ipairs(lines) do
                print(line)
            end

            Utils.notify(Library, "Info", "Printed to dev console (F9)", 5)
        end
    }
end

return module
