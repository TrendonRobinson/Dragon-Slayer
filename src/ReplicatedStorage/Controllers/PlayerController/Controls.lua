------------------------------------------------------------------------------
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")
local ContextActionService = game:GetService('ContextActionService')

local Animations = ReplicatedStorage.Animations
local SwordSwings = Animations.SwordSwings

------------------------------------------------------------------------------
local PlayerControls = {}
PlayerControls.__index = PlayerControls

function PlayerControls.new()
	
	local Player = game.Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()

	local info = {}
	setmetatable(info, PlayerControls)
	
	info.Player = Player
	info.Character = Character
	info.Humanoid = Character:WaitForChild('Humanoid')

	info.canAttack = true
	info.canEvade = true

	info.attackCount = 1
	info.maxAttackCount = #SwordSwings:GetChildren()
	

	return info
end
------------------------------------------------------------------------------





function PlayerControls:init(PlayerService)
	local function playerInput(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin and actionName == 'Swing' and self.canAttack then
			self.attackCount = self.attackCount == self.maxAttackCount and 1 or self.attackCount
			
			self.canAttack = false
			self.canEvade = false
			
			PlayerService.onAttack:Fire(true)
			

			local currentAnimation = SwordSwings[actionName..self.attackCount]
			
			local loadedAnimation = self.Humanoid:LoadAnimation(currentAnimation)
			loadedAnimation:Play()
			loadedAnimation.Stopped:Wait()			
			

			self.attackCount += 1
			self.canAttack = true
			self.canEvade = true

			PlayerService.onAttack:Fire(false)
		elseif actionName == 'Evade' and self.canEvade then
			if inputState == Enum.UserInputState.Begin then

			end
		end
	end
	
	
	ContextActionService:BindAction("Swing", playerInput, false, Enum.UserInputType.MouseButton1)
	
	
	
	
	
end


return PlayerControls
