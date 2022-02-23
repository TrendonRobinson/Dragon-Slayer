local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load core module:
local Packages = ReplicatedStorage:FindFirstChild('Packages')

if not Packages then warn('Packages not found: Install knit from Toolbox') end

local Knit = require(Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)

Knit.Modules = ReplicatedStorage.Modules

-- Load all controllers:
for _, Controller in ipairs(ReplicatedStorage.Controllers:GetDescendants()) do
	if Controller:IsA("ModuleScript") then
		require(Controller)
	end
end

-- Load all components:
for _, v in ipairs(ReplicatedStorage.Components:GetDescendants()) do
	if v:IsA("ModuleScript") then
		local vModule = require(v)
		Component.new(vModule.Tag, vModule)
	end
end

-- Start Knit:
Knit.Start({ServicePromises = true}):andThen(function()
	print("KnitClient started")
end):catch(warn)
