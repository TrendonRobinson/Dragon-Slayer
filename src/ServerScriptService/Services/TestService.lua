--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Signal = require(Knit.Util.Signal)

--// Knit Sercice
local TestService = Knit.CreateService { Name = "TestService", Client = {} }

--// Signals
TestService.Client.TestEvent = Signal.new()

--// Client Methods
function TestService.Client:GetTest(player)
	
end

--// Knit Start&Init
function TestService:KnitStart()
	TestService.Client.TestEvent:Fire()
end 

function TestService:KnitInit()

end 

return TestService