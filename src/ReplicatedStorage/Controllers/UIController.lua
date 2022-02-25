--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


--// Knit
local Knit = require(ReplicatedStorage.Packages.Knit)

--// Knit Controllers
local UIController = Knit.CreateController { Name = "UIController" }


function UIController:KnitStart()
    --// Modules
    local Modules = Knit.Modules
    local Tween = require(Modules.Tween)

    -- // Knit Services
    local PlayerManagerService = Knit.GetService("PlayerManagerService")
    
    --// Variables
    local Camera = workspace.CurrentCamera
    local Player = game.Players.LocalPlayer
    local PlayerGui = Player.PlayerGui
    local MainGui  = PlayerGui:WaitForChild('Main')

    local Assets = game.ReplicatedStorage.Assets

    -- Inventory
    local Inventory = MainGui.Inventory
    local Toggle = Inventory.Toggle
    local Slots = Inventory.Slots
    local Slot = Assets.UI.WeaponSlot

    local SlotTable = {}

    -- Coins
    local Coins = MainGui.Coins
    local CoinIcon = Coins.Coin
    
    
    local Coin = Assets.UI.Coin

    PlayerManagerService:GetCoins()
    :andThen(function(count)
        Coins.Count.Text = count
    end)
    :catch(warn)

    --// Action
    Toggle.MouseButton1Click:Connect(function()
        local Active = not Slots.Visible
        Slots.Visible = Active
        if not Active then
            for i = #SlotTable, 1, -1 do SlotTable[i]:Destroy(); table.remove(SlotTable, i) end
        end

        PlayerManagerService:GetWeapons()
        :andThen(function(weapons)
            for key, object in pairs(weapons) do
                if not Active then break; end
                local WeaponSlot = Slot:Clone()
                WeaponSlot.Label.Text = key
                WeaponSlot.Parent = Slots

                WeaponSlot.MouseButton1Click:Connect(function()
                    PlayerManagerService:EquipSword(key)
                end)

                table.insert(SlotTable, WeaponSlot)
            end

            if Active then
                Slots.Visible = true
            end
            
        end)
        :catch(warn)
    end)


    PlayerManagerService.renderCoins:Connect(function(gold, worldPoint)
        for i = 1, gold do
            local vector, onScreen = Camera:WorldToScreenPoint(worldPoint)

            local Coin = Coin:Clone()
            Coin.Position = UDim2.fromOffset(vector.X, vector.Y)

            local Action = Tween.new(
                Coin, 
                {Position = UDim2.fromScale(CoinIcon.Position.X.Scale, CoinIcon.Position.Y.Scale)},
                .25
                )


            Coin.Parent = CoinIcon
            Action:Play()
            Action.Completed:Connect(function()
                Coin:Destroy()
            end)

            Coins.Count.Text = tonumber(Coins.Count.Text) + 1

            task.wait()
        end
    end)
end

return UIController

