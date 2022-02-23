local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local springmodule = require(script:WaitForChild("SpringModule"))
local tween = require(script.Tween)

local Vec3 = Vector3.new
local CF = CFrame.new

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild('Humanoid')

local Offset = Instance.new("NumberValue", script)
local OffsetCount = 2
local OffsetRight = true

Offset.Value = OffsetCount

Humanoid.WalkSpeed = 16

local Camera = game.Workspace.CurrentCamera


Camera.DiagonalFieldOfView = 41.838
Camera.FieldOfView = 44.19
Camera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
Camera.MaxAxisFieldOfView = 50

local controls = require(Player.PlayerScripts.PlayerModule):GetControls()

--controls:Disable()



Character:WaitForChild("HumanoidRootPart")

local Root = Character.Head

local TargetCF = CF((CF(Root.CFrame.Position) * CF(0, 0, 12)).Position, Root.Position)
local spring = springmodule.new(Camera.CFrame.Position, Vector3.new(), TargetCF.Position)
spring.rate = .5
spring.friction = 1
Camera.CameraType = Enum.CameraType.Scriptable

local CanChange = true

local cameraAngleX = 365
local cameraAngleY = -14

local Zoom = 30

local RightDown = false

UserInputService.InputBegan:Connect(function(key, chat)
	if key.UserInputType == Enum.UserInputType.MouseButton2 then
		RightDown = true
	end
end)

UserInputService.InputEnded:Connect(function(key, chat)
	if key.UserInputType == Enum.UserInputType.MouseButton2 then
		RightDown = false
	end
end)
local function playerInput(actionName, inputState, inputObject)
	-- Calculate camera/player rotation on input change
	if inputState == Enum.UserInputState.Change and CanChange and actionName == 'PlayerInput' then
		if RightDown then

			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			cameraAngleX = cameraAngleX - inputObject.Delta.X
			cameraAngleY = cameraAngleY - inputObject.Delta.Y

		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	elseif actionName == 'SwitchOffset' then
		
		
		if inputState == Enum.UserInputState.Begin then
			OffsetRight = not OffsetRight

			local side = OffsetRight and 1 or -1

			tween.new(Offset, {Value = OffsetCount * (side)}, .5):Play()
		end
		
	
	end
end

ContextActionService:BindAction("PlayerInput", playerInput, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
ContextActionService:BindAction("SwitchOffset", playerInput, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonR1)


local MaxZoom = Player.CameraMaxZoomDistance
local MinZoom = Player.CameraMinZoomDistance
local blockedRay = false

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		if Zoom >= 1 and Zoom <= MaxZoom then
			Zoom -= input.Position.Z*5
			if Zoom > MaxZoom then
				Zoom = MaxZoom
			elseif Zoom < MinZoom and not blockedRay then
				Zoom = MinZoom * 2
			end
			
		end
	end
end)

local Connection


Connection = RunService.RenderStepped:Connect(function(dt)

	if not Character then Connection:Disconnect() return end

	Camera.CameraType = Enum.CameraType.Scriptable

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {Character, workspace:FindFirstChild('Debris')}
	raycastParams.IgnoreWater = true

	-- Cast the ray
	local Rot = CFrame.Angles(0, math.rad(cameraAngleX*UserInputService.MouseDeltaSensitivity), 0) * CFrame.Angles(math.rad(cameraAngleY*UserInputService.MouseDeltaSensitivity), 0, 0)
	local BaseCF = (CF(Root.CFrame.Position) * Rot) * (CF(0, 0, Zoom)) 

	local raycastResult = workspace:Raycast(
		Root.Position,
		CF(Root.Position, Camera.CFrame.Position).LookVector * 30,
		raycastParams
	)
	
	
	if raycastResult ~= nil  then
		blockedRay = true
		local Mag = (Root.Position - raycastResult.Position).Magnitude
		if Mag < Zoom then
			BaseCF = (CF(Root.CFrame.Position) * Rot) * (CF(0, 0, Mag - 1))
		end
	else
		blockedRay = false
	end

	TargetCF = CF(BaseCF.Position, Root.Position)

	spring.target = TargetCF.Position
	spring:update()
	Camera.CFrame = CF((CF(spring.position)).Position, Root.Position) * (CF(Offset.Value, 0 ,0))



end)
-------------------------------------------------