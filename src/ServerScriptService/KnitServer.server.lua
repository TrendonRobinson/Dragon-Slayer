--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Core Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Services = script.Parent:WaitForChild("Services")

Knit.Modules = ReplicatedStorage.Modules


-- Load all services:
for _, Service in ipairs(Services:GetChildren()) do
	if Service:IsA("ModuleScript") then
		local s,e = pcall(function ()
			require(Service)
		end)

		if not s then
			warn("Failed to load " .. Service.Name .. " because: " .. e)
		end
	end
end

-- Load all components:
for _, v in ipairs(ServerScriptService.Components:GetDescendants()) do
	if v:IsA("ModuleScript") then
		local vModule = require(v)
	end
end


-- Component.Auto(script.Parent.Components)

Knit.Start():andThen(function()
	print("KnitServer started")
end):catch(warn)