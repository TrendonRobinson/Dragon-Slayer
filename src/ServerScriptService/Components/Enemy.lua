--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService('CollectionService')

--// Modules
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)


--// Knit Services

--// Component
local Tag = "Enemy"
local Enemy = Component.new({Tag = Tag})

--// Variables
local Assets = ReplicatedStorage.Assets
local Drops = Assets.Swords.Drops

function PartToRegion3(obj)
	local abs = math.abs

	local cf = obj.CFrame -- this causes a LuaBridge invocation + heap allocation to create CFrame object - expensive! - but no way around it. we need the cframe
	local size = obj.Size -- this causes a LuaBridge invocation + heap allocation to create Vector3 object - expensive! - but no way around it
	local sx, sy, sz = size.X, size.Y, size.Z -- this causes 3 Lua->C++ invocations

	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components() -- this causes 1 Lua->C++ invocations and gets all components of cframe in one go, with no allocations

	-- https://zeuxcg.org/2010/10/17/aabb-from-obb-with-component-wise-abs/
	local wsx = 0.5 * (abs(R00) * sx + abs(R01) * sy + abs(R02) * sz) -- this requires 3 Lua->C++ invocations to call abs, but no hash lookups since we cached abs value above; otherwise this is just a bunch of local ops
	local wsy = 0.5 * (abs(R10) * sx + abs(R11) * sy + abs(R12) * sz) -- same
	local wsz = 0.5 * (abs(R20) * sx + abs(R21) * sy + abs(R22) * sz) -- same
	
	-- just a bunch of local ops
	local minx = x - wsx
	local miny = y - wsy
	local minz = z - wsz

	local maxx = x + wsx
	local maxy = y + wsy
	local maxz = z + wsz

	local minv, maxv = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)
	return Region3.new(minv, maxv)
end

--// Libraries Shortened
local rand = math.random

function Enemy:Construct()
    self.trove = Trove.new()
end

function Enemy:isInstaceAttackable(targetInstance)
	local targetHumanoid = targetInstance and targetInstance.Parent and targetInstance.Parent:FindFirstChild("Humanoid")
	if not targetHumanoid then
		return false
	end

	local isAttackable = false
	local distance = (self.Instance.HumanoidRootPart.Position - targetInstance.Position).Magnitude

	if distance <= self.ATTACK_RADIUS then
		local ray = Ray.new(
			self.Instance.HumanoidRootPart.Position,
			(targetInstance.Parent.HumanoidRootPart.Position - self.Instance.HumanoidRootPart.Position).Unit * distance
		)

		local part = workspace:FindPartOnRayWithIgnoreList(ray, {
			targetInstance.Parent, self.Instance,
		}, false, true)

		if
			targetInstance ~= self.Instance and
			targetInstance:IsDescendantOf(workspace) and
			targetHumanoid.Health > 0 and
			targetHumanoid:GetState() ~= Enum.HumanoidStateType.Dead and
			not CollectionService:HasTag(targetInstance.Parent, Tag) and
			not part
		then
			isAttackable = true
		end
	end

	return isAttackable
end

function Enemy:FireBreath(selection)
	print(selection, self.attackAnimations)
	self.attackAnimations[selection]:Play()

	task.wait(.8)

	local hitPart = Instance.new("Part")
	hitPart.Size = self.HITBOX_SIZE/2
	hitPart.Transparency = 1
	hitPart.CanCollide = false
	hitPart.Anchored = true
	hitPart.CFrame = self.Instance.HumanoidRootPart.CFrame * CFrame.new(0, 0, -self.HITBOX_SIZE.Z*.5)
	
	hitPart.Parent = workspace

	task.wait(.2)

	local hitTouchingParts = workspace:GetPartsInPart(hitPart)

	-- Destroy the hitPart before it results in physics updates on touched parts
	
	hitPart:Destroy()

	return hitTouchingParts
end

function Enemy:WingBeat(selection)
	self.attackAnimations[selection]:Play()
	self.currentAnimationTrack = self.wingBeatAnimation

	task.wait(.8)

	local hitPart = Instance.new("Part")
	hitPart.Size = self.HITBOX_SIZE/2
	hitPart.Transparency = 1
	hitPart.CanCollide = false
	hitPart.Anchored = true
	hitPart.CFrame = self.Instance.HumanoidRootPart.CFrame * CFrame.new(0, 0, -self.HITBOX_SIZE.Z*.5)
	
	hitPart.Parent = workspace

	task.wait(.2)

	local hitTouchingParts = workspace:GetPartsInPart(hitPart)

	-- Destroy the hitPart before it results in physics updates on touched parts
	
	hitPart:Destroy()

	return hitTouchingParts
end

function Enemy:AnimationStopped()
	for i, track in pairs(self.attackAnimations) do
		self.trove:Connect(track.Stopped, function()

			self.Humanoid.WalkSpeed = self.originalWalkSpeed
			self.startPosition = self.Instance.PrimaryPart.Position
			self.attacking = false
			if not self:NearByPlayer() then self:Patrol() end
		end)
	end
end

function Enemy:Attack(selection)
	self.attacking = true
	self.lastAttackTime = tick()

	local hitTouchingParts
	self.Humanoid.WalkSpeed = 0
	
	if selection == 1 then
		hitTouchingParts = self:WingBeat(selection)
	else
		hitTouchingParts = self:FireBreath(selection)
	end

	-- Find humanoids to damage
	local attackedHumanoids	= {}
	for _, part in pairs(hitTouchingParts) do
		local parentModel = part:FindFirstAncestorOfClass("Model")
		if self:isInstaceAttackable(part) and not attackedHumanoids[parentModel]	then
			attackedHumanoids[parentModel.Humanoid] = true
		end
	end

	for humanoid in pairs(attackedHumanoids) do
		humanoid:TakeDamage(self.ATTACK_DAMAGE)
	end


	task.wait(1.5)
	if not self:NearByPlayer() then self:Patrol() end
end

function Enemy:FindNearestPlayer(position)
	local found
	local last = math.huge
    local maxDistance = self.ATTACK_RADIUS
	for _,plyr in pairs(game.Players:GetPlayers()) do
		local distance = plyr:DistanceFromCharacter(position)
		if distance < last and distance < maxDistance then
			found = plyr
			last = distance
		end
	end
	return found
end

function Enemy:ChaseTarget(TargetEnemy, Position)
	TargetEnemy.Character:WaitForChild('HumanoidRootPart')
	self.Humanoid:MoveTo(TargetEnemy.Character.PrimaryPart.Position)

	local Nearest = self:FindNearestPlayer(self.Instance.PrimaryPart.Position)
	

    self.Humanoid.MoveToFinished:Wait()
	if Nearest then

		local Distance = Nearest:DistanceFromCharacter(Position)
		if Distance < self.HITBOX_SIZE.Magnitude*.75 then
			self:Attack(math.random(1, 2))
		elseif Distance < self.ATTACK_RADIUS then
			self:ChaseTarget(TargetEnemy, self.Instance.PrimaryPart.Position)
		end
	else 
		self:Patrol()
	end
	
end

function Enemy:NearByPlayer()
	local Position = self.Instance.PrimaryPart.Position
    local TargetEnemy = self:FindNearestPlayer(Position)
    if TargetEnemy then
		self.attacking = true
        self:ChaseTarget(TargetEnemy, Position)
    else
        task.wait()
		return false
    end
end

function Enemy:Patrol()
    while not self.attacking do
		if self:NearByPlayer() then break; end
        self.Humanoid:MoveTo(self.startPosition + Vector3.new(rand(-self.ATTACK_RADIUS, self.ATTACK_RADIUS), 0, rand(-self.ATTACK_RADIUS, self.ATTACK_RADIUS)))
        self.Humanoid.MoveToFinished:Wait()
        task.wait()
    end
	self:NearByPlayer()
end

function Enemy:Died()
	self:Stop()
end

function Enemy:ServicePrep()
	self.Services = {
		PlayerManagerService = Knit.GetService('PlayerManagerService')
	}
end

function Enemy:WeaponDrop()
	local Drops = Drops:GetChildren()
		local Root = self.Instance.PrimaryPart
		local SwordDrop = Drops[math.random(1, #Drops)]:Clone()

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {workspace.Enemies:GetDescendants(), self.Instance}
		raycastParams.IgnoreWater = true

		local raycastResult = workspace:Raycast(
			Root.Position,
			CFrame.new(Root.Position + Vector3.new(0,5,0), Root.Position - Vector3.new(0,20,0)).LookVector * 30,
			raycastParams
		)

		if raycastResult then
			SwordDrop.CFrame = (
				CFrame.new(raycastResult.Position) *
				CFrame.new(0, SwordDrop.Size.Y / 2, 0) *
				CFrame.fromEulerAnglesXYZ(math.pi, 0, 0)
			)
		else
			SwordDrop.CFrame = Root.CFrame * CFrame.fromEulerAnglesXYZ(math.pi, 0, 0)
		end

		SwordDrop.Parent = workspace.Ignorable
end

function Enemy:Start()
	local Type = self.Instance:GetAttribute('Type')
    self.Humanoid = self.Instance.Humanoid
	self.attackAnimations = {
		self.Humanoid:LoadAnimation(ReplicatedStorage.Animations[Type]['FireBreath']),
		self.Humanoid:LoadAnimation(ReplicatedStorage.Animations[Type]['WingBeat'])
	}

	self.originalWalkSpeed = self.Humanoid.WalkSpeed
	self.startPosition = self.Instance.PrimaryPart.Position

	self.HITBOX_SIZE = self.Instance:GetExtentsSize()
	self.ATTACK_DAMAGE = self.Instance:GetAttribute('Level') * 10
	self.ATTACK_STAND_TIME = 1
	self.ATTACK_RADIUS = 25
	self.HEALTH = math.ceil(100 * math.sqrt(self.Instance:GetAttribute('Level')))

	self.attacking = false
	self.Humanoid.MaxHealth = self.HEALTH
	self.Humanoid.Health = self.HEALTH
	
	task.spawn(function()
		self:ServicePrep()
		self:AnimationStopped()
	end)

	self.Humanoid.Died:Connect(function()
		local chance = math.rad(1, 5)
		if chance == 1 then
			self:WeaponDrop()
		end
		task.wait(6.1)
		self:Died()
	end)
    self:Patrol()
end



function Enemy:Stop()
    self.trove:Destroy()
	local s, e = pcall(function()
        self.Instance:Destroy()
    end)
end

return Enemy