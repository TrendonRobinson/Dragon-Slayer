local spring = {}

function spring.new(Position, Velocity, Target)
	local self = setmetatable({}, {__index = spring})

	self.position = Position
	self.velocity = Velocity
	self.target = Target
	self.rate = 1
	self.friction = 1

	return self

end


function spring:update()
	local difference = (self.target - self.position)
	local force = difference * self.rate;
	self.velocity = (self.velocity *(1-self.friction))+force 
	-- Velocity = Velocity Multplied by the 1 - friction and you add the sum of that <==== to the amount of force you want applied
	self.position = self.position + self.velocity

	-- Position =  Position + Velocity
end

return spring