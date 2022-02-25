--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)


--// Component
local Tag = "DragonBoss"
local Dragon = Component.new({Tag = Tag})

--// Libraries Shortened
local rand = math.random
local radius = 10

--// Variables
local Animations = ReplicatedStorage.Animations[Tag]

function Dragon:Construct()
    self._trove = Trove.new()
end

function Dragon:FindNearestPlayer(position)
	local found
	local last = math.huge
    local maxDistance = 15
	for _,plyr in pairs(game.Players:GetPlayers()) do
		local distance = plyr:DistanceFromCharacter(position)
		if distance < last and distance < maxDistance then
			found = plyr
			last = distance
		end
	end
	return found
end

function Dragon:NearByPlayer()
    local Enemy = self:FindNearestPlayer(self.Instance.PrimaryPart.Position)
    if Enemy then
        return Enemy
    else
        task.wait()
        self:Patrol()
    end
end

function Dragon:Patrol()
    while --[[not self:NearByPlayer()]] true do
        self.Humanoid:MoveTo(self.Focal + Vector3.new(rand(-radius, radius), 0, rand(-radius, radius)))
        self.Humanoid.MoveToFinished:Wait()
        task.wait(rand(2, 5))
    end
end

function Dragon:Start()
    self.Humanoid = self.Instance.Humanoid
    self.Focal = self.Instance.PrimaryPart.Position
    self:Patrol()
end

function Dragon:Stop()
    self._trove:Destroy()
end

return Dragon