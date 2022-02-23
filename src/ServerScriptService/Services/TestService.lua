--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- local Signal = require(Knit.Util.Signal)

--// Knit Sercice
local TestService = Knit.CreateService { Name = "TestService", Client = {} }

--// Signals
TestService.Client.TestEvent = Knit.CreateSignal()

--// Client Methods
function TestService.Client:GetTest(player)
	
end

--// Knit Start&Init
function TestService:KnitStart()
	
end 

function TestService:KnitInit()

end 

return TestService