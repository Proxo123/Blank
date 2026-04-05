local module = {}

function module.init(Window, Library, Utils, Env)
    local Tab = Window:CreateTab{
        Title = "Movement",
        Icon = "phosphor-person-simple-run-bold"
    }

    local Options = Library.Options
    local SprintModule = nil
    local infStaminaConn = nil
    local originals = {}

    local function getSprint()
        if SprintModule then return SprintModule end
        local ok, mod = pcall(require, game.ReplicatedStorage.Systems.Character.Game.Sprinting)
        if ok and mod then
            SprintModule = mod
            originals.StaminaLoss = mod.StaminaLoss or 10
            originals.StaminaGain = mod.StaminaGain or 20
            originals.MaxStamina = mod.MaxStamina or 100
        end
        return SprintModule
    end

    Tab:CreateToggle("InfStamina", {
        Title = "Infinite Stamina",
        Description = "Prevents stamina from draining while sprinting",
        Default = false,
        Callback = function(value)
            local sprint = getSprint()
            if not sprint then
                Utils.notify(Library, "Movement", "Sprinting module not loaded yet", 3)
                return
            end
            if value then
                sprint.StaminaLossDisabled = true
                sprint.Stamina = sprint.MaxStamina
                sprint.__staminaChangedEvent:Fire(sprint.MaxStamina)
                local char = Utils.getCharacter()
                if char then
                    char:SetAttribute("StaminaPenaltyActive", nil)
                end
                infStaminaConn = game:GetService("RunService").Heartbeat:Connect(function()
                    sprint.StaminaLossDisabled = true
                    if sprint.Stamina < sprint.MaxStamina then
                        sprint.Stamina = sprint.MaxStamina
                        sprint.__staminaChangedEvent:Fire(sprint.MaxStamina)
                    end
                    sprint.timeUntilStaminaRecovers = 0
                    local c = Utils.getCharacter()
                    if c then
                        c:SetAttribute("StaminaPenaltyActive", nil)
                    end
                end)
            else
                sprint.StaminaLossDisabled = false
                if infStaminaConn then
                    infStaminaConn:Disconnect()
                    infStaminaConn = nil
                end
            end
        end
    })

    Tab:CreateSlider("DrainRate", {
        Title = "Stamina Drain Rate",
        Description = "How fast stamina drains while sprinting (default 10)",
        Default = 10,
        Min = 0,
        Max = 50,
        Rounding = 1,
        Callback = function(value)
            local sprint = getSprint()
            if sprint then
                sprint.StaminaLoss = value
            end
        end
    })

    Tab:CreateSlider("MaxStam", {
        Title = "Max Stamina",
        Description = "Maximum stamina pool (default 100)",
        Default = 100,
        Min = 10,
        Max = 500,
        Rounding = 0,
        Callback = function(value)
            local sprint = getSprint()
            if sprint then
                sprint.MaxStamina = value
                if sprint.Stamina > value then
                    sprint.Stamina = value
                    sprint.__staminaChangedEvent:Fire(value)
                end
            end
        end
    })

    Tab:CreateSlider("RegenRate", {
        Title = "Stamina Regen Rate",
        Description = "How fast stamina recovers (default 20)",
        Default = 20,
        Min = 0,
        Max = 100,
        Rounding = 1,
        Callback = function(value)
            local sprint = getSprint()
            if sprint then
                sprint.StaminaGain = value
            end
        end
    })

    Tab:CreateButton{
        Title = "Reset Defaults",
        Description = "Restore stamina values to game defaults",
        Callback = function()
            local sprint = getSprint()
            if not sprint then return end

            if infStaminaConn then
                infStaminaConn:Disconnect()
                infStaminaConn = nil
            end
            sprint.StaminaLossDisabled = false
            sprint.StaminaLoss = originals.StaminaLoss
            sprint.StaminaGain = originals.StaminaGain
            sprint.MaxStamina = originals.MaxStamina
            sprint.Stamina = originals.MaxStamina
            sprint.__staminaChangedEvent:Fire(originals.MaxStamina)
            sprint.timeUntilStaminaRecovers = 0

            Options.InfStamina:SetValue(false)
            Options.DrainRate:SetValue(originals.StaminaLoss)
            Options.MaxStam:SetValue(originals.MaxStamina)
            Options.RegenRate:SetValue(originals.StaminaGain)

            Utils.notify(Library, "Movement", "Reset to game defaults", 3)
        end
    }
end

return module
