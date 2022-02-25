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

local console = {
    log = print
}

local EnemyMarkers = workspace.EnemyMarkers
local EnemyCount = #EnemyMarkers:GetChildren()
local DeathCount = Instance.new("NumberValue")

local Enemies = Instance.new("Folder")
Enemies.Parent = workspace

--// Knit Start&Init
function EnemyService:KnitStart()

    --// Services
    local PlayerManagerService = Knit.GetService('PlayerManagerService')
	
    local Element = EnemyMarkers:GetAttribute('Type')

    DeathCount.Changed:Connect(function(value)
        PlayerManagerService.Client.renderDeathCount:FireAll(EnemyCount-DeathCount.Value)
        if DeathCount.Value == EnemyCount then
            PlayerManagerService:ConcludeGame()
        end
        console.log(DeathCount.Value..'/'..EnemyCount)
    end)
    

    for _, marker in pairs(EnemyMarkers:GetChildren()) do
        local Connect
        local Dragon = Assets[Element][Element..marker.Name]:Clone()
        Dragon:SetPrimaryPartCFrame(marker.CFrame)
        Dragon.Parent = Enemies

        Connect = Dragon.Humanoid.Died:Connect(function()
            DeathCount.Value += 1
            Connect:Disconnect()
        end)

        marker.Transparency = 1
    end
end 

function EnemyService:KnitInit()

end 

return EnemyService