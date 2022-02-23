--// Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')

--// Knit
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

--// Knit Sercice
local EnemyService = Knit.CreateService { Name = "EnemyService", Client = {} }

--// Signals
EnemyService.Client.TestEvent = Knit.CreateSignal()

--// Client Methods
function EnemyService.Client:GetTest(player)
	
end

--// Variables
local Assets = ReplicatedStorage.Assets.Enemies

local Enemies = Instance.new("Folder")
Enemies.Parent = workspace

--// Knit Start&Init
function EnemyService:KnitStart()
	local EnemyMarkers = workspace.EnemyMarkers
    local Element = EnemyMarkers:GetAttribute('Type')

    for _, marker in pairs(EnemyMarkers:GetChildren()) do
        local Dragon = Assets[Element][Element..marker.Name]:Clone()
        Dragon:SetPrimaryPartCFrame(marker.CFrame)
        Dragon.Parent = Enemies
    end
end 

function EnemyService:KnitInit()

end 

return EnemyService