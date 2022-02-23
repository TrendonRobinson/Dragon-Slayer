local Tween = {}

--// Services
local TweenService = game:GetService("TweenService")


--// Functions
function Tween.new(Object, Changes, Time)
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

return Tween