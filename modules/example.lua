local module = {}

function module.init(Window, Library, Utils, Env)
    local Tab = Window:CreateTab{
        Title = "Player",
        Icon = "phosphor-user-bold"
    }

    local Options = Library.Options
    local DEFAULT_SPEED = 16
    local DEFAULT_JUMP = 50

    Tab:CreateSlider("WalkSpeed", {
        Title = "Walk Speed",
        Description = "Adjust your character's walk speed",
        Default = DEFAULT_SPEED,
        Min = 0,
        Max = 200,
        Rounding = 0,
        Callback = function(value)
            local humanoid = Utils.getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    })

    Tab:CreateSlider("JumpPower", {
        Title = "Jump Power",
        Description = "Adjust your character's jump power",
        Default = DEFAULT_JUMP,
        Min = 0,
        Max = 500,
        Rounding = 0,
        Callback = function(value)
            local humanoid = Utils.getHumanoid()
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    })

    local infJumpConnection = nil

    Tab:CreateToggle("InfiniteJump", {
        Title = "Infinite Jump",
        Default = false,
        Callback = function(value)
            if value then
                infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                    local humanoid = Utils.getHumanoid()
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            else
                if infJumpConnection then
                    infJumpConnection:Disconnect()
                    infJumpConnection = nil
                end
            end
        end
    })

    local noclipEnabled = false
    local noclipConnection = nil

    Tab:CreateToggle("Noclip", {
        Title = "Noclip",
        Description = "Walk through walls",
        Default = false,
        Callback = function(value)
            noclipEnabled = value
            if value then
                noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                    if noclipEnabled then
                        local char = Utils.getCharacter()
                        if char then
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end)
            else
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
            end
        end
    })

    Tab:CreateButton{
        Title = "Reset Defaults",
        Description = "Reset walk speed and jump power to normal",
        Callback = function()
            local humanoid = Utils.getHumanoid()
            if humanoid then
                humanoid.WalkSpeed = DEFAULT_SPEED
                humanoid.JumpPower = DEFAULT_JUMP
            end
            Options.WalkSpeed:SetValue(DEFAULT_SPEED)
            Options.JumpPower:SetValue(DEFAULT_JUMP)
            Utils.notify(Library, "Player", "Reset to defaults.")
        end
    }
end

return module
