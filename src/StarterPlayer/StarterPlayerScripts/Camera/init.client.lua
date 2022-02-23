--// Services
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Modules
local springmodule = require(script:WaitForChild("SpringModule"))
local tween = require(script.Tween)

--// Shortened Library Assets
local Vec3 = Vector3.new
local CF = CFrame.new
local CFAngles = CFrame.Angles

--//  Necessities
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild('Humanoid')
local Hrp = Character:WaitForChild("HumanoidRootPart")

local Root = Character.Head

-- Camera Info
local Camera = game.Workspace.CurrentCamera
local cameraAngleX = 365
local cameraAngleY = -14

local Zoom = 30
local MaxZoom = Player.CameraMaxZoomDistance
local MinZoom = Player.CameraMinZoomDistance

local RightDown = false
local blockedRay = false

local Offset = Instance.new("NumberValue", script)
local OffsetCount = 2
local OffsetRight = true
Offset.Value = OffsetCount

Camera.DiagonalFieldOfView = 41.838
Camera.FieldOfView = 60--44.19
Camera.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
Camera.MaxAxisFieldOfView = 50

local TargetCF = CF((CF(Root.CFrame.Position) * CF(0, 0, 12)).Position, Root.Position)
local spring = springmodule.new(Camera.CFrame.Position, Vector3.new(), TargetCF.Position)
spring.rate = .5
spring.friction = 1
Camera.CameraType = Enum.CameraType.Scriptable


-- BodyRotation For ShiftLock
local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vec3(math.huge, math.huge, math.huge)
bodyGyro.P = 10000

-- Mouse Variables
local mouseLocked = false
local MouseBehavior = {
	Default = Enum.MouseBehavior.Default,
	LockCenter = Enum.MouseBehavior.LockCenter,
	LockCurrentPosition = Enum.MouseBehavior.LockCurrentPosition,
}




--------- RightClick Rotation ----------
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

--------- Mouse Movement Tracking ----------
function trackRotation(inputObject)
	-- Calculate camera/player rotation on input change
	cameraAngleX = cameraAngleX - inputObject.Delta.X
	cameraAngleY = cameraAngleY - inputObject.Delta.Y
end

function trackZoom(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
		if Zoom >= 1 and Zoom <= MaxZoom then
			Zoom -= inputObject.Position.Z*5
			if Zoom > MaxZoom then
				Zoom = MaxZoom
			elseif Zoom < MinZoom and not blockedRay then
				Zoom = MinZoom * 2
			end
			
		end
	end
end

--------- Getting Inputs to Handle Different Functionality ----------
local function playerInput(actionName, inputState, inputObject)
	if actionName == 'MouseMovement' then
		if inputState == Enum.UserInputState.Change then
			if RightDown then
				print('whats up')
				UserInputService.MouseBehavior = MouseBehavior.LockCurrentPosition
				trackRotation(inputObject)
			elseif inputState == Enum.UserInputState.Change and mouseLocked then
				UserInputService.MouseBehavior = MouseBehavior.LockCurrentPosition
				trackRotation(inputObject)
			else
				UserInputService.MouseBehavior = not mouseLocked and MouseBehavior.Default or MouseBehavior.LockCenter
			end
		end
	elseif actionName == 'LockSwitch' then
		if inputState == Enum.UserInputState.Begin then
			mouseLocked = not mouseLocked
			UserInputService.MouseBehavior = mouseLocked and MouseBehavior.LockCenter or MouseBehavior.Default
			bodyGyro.Parent = mouseLocked and Character.HumanoidRootPart or nil
		end
	elseif actionName == 'SwitchOffset' then

		if inputState == Enum.UserInputState.Begin then
			OffsetRight = not OffsetRight
			tween.new(Offset, {Value = OffsetCount * (OffsetRight and 1 or -1)}, .5):Play()
		end
	end
end

ContextActionService:BindAction("MouseMovement", playerInput, false, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch)
ContextActionService:BindAction("SwitchOffset", playerInput, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonR1)
ContextActionService:BindAction("LockSwitch", playerInput, false, Enum.KeyCode.LeftShift)
UserInputService.InputChanged:Connect(trackZoom)



local Connection
local Aim = CF()
local Rot = CF()

Connection = RunService.RenderStepped:Connect(function(dt)
	if not Character then Connection:Disconnect() return end -- Kill script if nothing character dies

	Camera.CameraType = Enum.CameraType.Scriptable

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {Character:GetDescendants(), workspace:FindFirstChild('Debris')}
	raycastParams.IgnoreWater = true

	-- Cast the ray
	local Rot = CFAngles(0, math.rad(cameraAngleX*UserInputService.MouseDeltaSensitivity), 0) * CFAngles(math.rad(cameraAngleY*UserInputService.MouseDeltaSensitivity), 0, 0)
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

	Aim = CF((CF(spring.position)).Position, Root.Position) * (CF(Offset.Value, 0 ,0))
	Rot = CF(Aim.Position, (Aim * CF(0, 0, -20).Position))
	-- Rot = CF(Rot.X, 0, Rot.Z)

	Camera.CFrame = Aim
	bodyGyro.CFrame = Rot


end)
-------------------------------------------------