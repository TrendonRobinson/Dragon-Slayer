--// Services
local Players = game:GetService('Players')
local ServerScriptService = game:GetService("ServerScriptService")

--// Modules
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ProfileService = require(script.Parent.ProfileService)
local RaycastHitbox = require(ServerScriptService.Modules.RaycastHitboxV4)

--// Variables
local ProfileTemplate = {
    --// Stats
    lvl = 1,
    xp = 0,

    coins = 0,

    strength = 1,
    speed = 1,
}

local ProfileStore = ProfileService.GetProfileStore(
    'PlayerData',
    ProfileTemplate
)

--// Class
local PlayerManager = {}
PlayerManager.__index = PlayerManager

function PlayerManager.new(_Player)
    
    local self = {
        Player = _Player,
        profile = nil
    }

    setmetatable(self, PlayerManager)

    return self
end


--HITBOX------------------------------------------------------------------------------------
function PlayerManager:HitboxManager()

    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {self.Character} --- remember to define our character!
    Params.FilterType = Enum.RaycastFilterType.Blacklist

    self.Hitbox.RaycastParams = Params
    self.Hitbox.OnHit:Connect(function(hit, humanoid)
        if humanoid.Health < 1 then return end

        local Gold = humanoid.Parent:GetAttribute('Gold')
        local Type = humanoid.Parent:GetAttribute('Type')
        local Level = humanoid.Parent:GetAttribute('Level')

        humanoid:TakeDamage(self.profile.Data.strength * 10)
        
        if humanoid.Health < 1 then
            self:IncrementCoins(Gold)
            self:IncrementXP(Level * 100 * .25)
        end
    end)
end
function PlayerManager:ConstructHitbox()
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    self.Sword = self.Character:WaitForChild('Sword')
    self.Hitbox = RaycastHitbox.new(self.Sword)
    self:HitboxManager()
end

function PlayerManager:ToggleHitbox(on)
    if on then
        self.Hitbox:HitStart()
    else 
        self.Hitbox:HitStop()
    end
end
--HITBOX------------------------------------------------------------------------------------

--DATA INCREMENT------------------------------------------------------------------------------------
function PlayerManager:IncrementCoins(amount)
    if amount then
        self.profile.Data['coins'] += amount
    else
        warn('PlayerManagerService: PlayerManager:IncrementCoins(amount) -> amount is nil')
    end
end

function PlayerManager:IncrementLevel()

end

function PlayerManager:IncrementXP(amount)
    self.profile.Data['xp'] += amount
end
--DATA INCREMENT------------------------------------------------------------------------------------
function PlayerManager:Init()

    --Player__572995537
    local profile = ProfileStore:LoadProfileAsync("Player__" .. self.Player.UserId)
    if profile ~= nil then
        profile:AddUserId(self.Player.UserId) -- GDPR compliance
        profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
        profile:ListenToRelease(function()
            self.profile = nil
            -- The profile could've been loaded on another Roblox server:
            self.Player:Kick()
        end)
        if self.Player:IsDescendantOf(Players) == true then
            self.profile = profile
            -- A profile has been successfully loaded:
        else
            -- PlayerManager left before the profile loaded:
            profile:Release()
        end
    else
        -- The profile couldn't be loaded possibly due to other
        --   Roblox servers trying to load this profile at the same time:
        self.Player:Kick() 
    end

    self:ConstructHitbox()

end


return PlayerManager