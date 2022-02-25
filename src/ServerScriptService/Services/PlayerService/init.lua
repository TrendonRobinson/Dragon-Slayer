--// Services
local Players = game:GetService('Players')

--// Modules
local PlayerManager = require(script.Player)

--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--// Knit Sercice
local PlayerService = Knit.CreateService { Name = "PlayerManagerService", Client = {} }
local Client = PlayerService.Client

Client.onAttack = Knit.CreateSignal()
Client.renderCoins = Knit.CreateSignal()
Client.constructHitbox = Knit.CreateSignal()

--// Variables

-- Tables/Dictionaries
local Profiles = {}

--// Client Methods
function PlayerService.Client:GetWeapons(player)
	return Profiles[player].profile.Data.inventory
end

function PlayerService.Client:GetCoins(player)
	return Profiles[player].profile.Data.coins
end

function PlayerService.Client:EquipSword(player, weaponName)
	Profiles[player]:EquipSword(weaponName)
end

--// Methods
function PlayerService:GetTest(player)
	
end

function PlayerService:AddSwordToInventory(player, weaponName)
    Profiles[player]:AddWeaponToInventory(weaponName)
end


function PlayerService:EquipSword(player, weaponName)
    Profiles[player]:EquipSword(weaponName)
end

--// Profile Management
Players.PlayerAdded:Connect(function(Player)

    Profiles[Player] = PlayerManager.new(Player)

    local Profile = Profiles[Player]
    Profile:Init()

    local Character = Player.Character or Player.CharacterAdded:Wait()
    Profile:EquipSword(Profile.profile.Data.equiped)

end)

--// Knit Start&Init
function PlayerService:KnitStart()

    Client.onAttack:Connect(function(Player, on)
        local Profile = Profiles[Player]
        Profile:ToggleHitbox(on)
    end)

    Client.constructHitbox:Connect(function(Player)
        local Profile = Profiles[Player]
        Profile:ConstructHitbox()
    end)
	
end 

function PlayerService:KnitInit()

end 

return PlayerService