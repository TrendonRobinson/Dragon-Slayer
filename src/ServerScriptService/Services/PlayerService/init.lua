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
Client.constructHitbox = Knit.CreateSignal()

--// Client Methods
function PlayerService:GetTest(player)
	
end

--// Variables

-- Tables/Dictionaries
local Profiles = {}


--// Profile Management
Players.PlayerAdded:Connect(function(Player)

    Profiles[Player] = PlayerManager.new(Player)

    local Profile = Profiles[Player]
    Profile:Init()
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