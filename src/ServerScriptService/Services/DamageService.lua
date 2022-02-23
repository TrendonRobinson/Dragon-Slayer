--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- local Signal = require(Knit.Util.Signal)

--// Knit Sercice
local DamageService = Knit.CreateService { Name = "DamageService", Client = {} }

--// Signals
DamageService.Client.TestEvent = Knit.CreateSignal()

--// Client Methods
function DamageService.Client:GetTest(player)
	
end

--// Knit Start&Init
function DamageService:KnitStart()
	
end 

function DamageService:KnitInit()

end 

return DamageService