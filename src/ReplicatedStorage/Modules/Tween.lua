local module = {}

module.new = function(Object, Changes, Time)
	local TweenService = game:GetService("TweenService")
	local Info = TweenInfo.new(
		Time,
		Enum.EasingStyle.Linear, -- EasingStyle
		Enum.EasingDirection.Out, -- EasingDirection
		0, -- Times repeteated
		false, -- Reversing
		0 -- Time Delay
		)
	local Action = TweenService:Create(Object, Info, Changes)
	return Action
end

return module