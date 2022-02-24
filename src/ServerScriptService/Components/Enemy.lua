--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)


--// Knit Services
print(Knit)

--// Component
local Tag = "Enemy"
local Enemy = Component.new({Tag = Tag})

--// Variables


function Enemy:Construct()
    self._trove = Trove.new()
end

function Enemy:Start()
    self.Humanoid = self.Instance.Humanoid

    
end

function Enemy:Stop()
    self._trove:Destroy()
end

return Enemy