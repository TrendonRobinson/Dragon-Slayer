--// Services
local Players = game:GetService('Players')
local TeleportService = game:GetService("TeleportService")

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
Client.renderDeathCount = Knit.CreateSignal()

--// Variables

-- Tables/Dictionaries
local Profiles = {}
local LevelsDicitonary = {
    Volcano = '8935075373',
    Northada = '8916832766'
}

local LevelTable = {
    'Volcano',
    'Northada',
}

--// Check For Profile
function ProfileHasLoaded(player)
    repeat
        task.wait()
    until Profiles[player]['profile']
end

--// Client Methods
function PlayerService.Client:GetWeapons(player)
    ProfileHasLoaded(player)
	return Profiles[player].profile.Data.inventory
end

function PlayerService.Client:GetCoins(player)
    ProfileHasLoaded(player)
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

function PlayerService:ConcludeGame(player, weaponName)
    local CurrentLevel = workspace.Static:GetAttribute('Map')
    local CurrentLevelIndex
    local TeleportTo

    for i, Level in ipairs(LevelTable) do
        if CurrentLevel == Level then
            CurrentLevelIndex = i
        end
    end

    TeleportTo = LevelTable[CurrentLevelIndex + 1] or LevelTable[1]

    local success, result = pcall(function()
        return TeleportService:TeleportPartyAsync(LevelsDicitonary[TeleportTo], game.Players:GetPlayers())
    end)

    if success then
        local jobId = result
        print("Players teleported to "..jobId)
    else
        warn(result)
    end

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