--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- local Signal = require(Knit.Util.Signal)

--// Knit Sercice
local PlayerService = Knit.CreateService { Name = "PlayerService", Client = {} }

--// Signals
PlayerService.Client.TestEvent = Knit.CreateSignal()

--// Client Methods
function PlayerService.Client:GetTest(player)
	
end

--// Knit Start&Init
function PlayerService:KnitStart()
	
end 

function PlayerService:KnitInit()

end 

return PlayerService