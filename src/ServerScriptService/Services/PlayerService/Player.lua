--// Services
local Players = game:GetService('Players')
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ProfileService = require(script.Parent.ProfileService)
local RaycastHitbox = require(ServerScriptService.Modules.RaycastHitboxV4)

--// Variables
local ProfileTemplate = {
    --// Stats
    lvl = 1,
    xp = 0,

<<<<<<< HEAD
    coins = 0,

    inventory = {
        Default = 1
    },

    equiped = 'Default',


=======
>>>>>>> 6887c98e3ea953328f8ec7f65d75d789f6e2ca4e
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
    local PlayerManagerService = Knit.GetService('PlayerManagerService')
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {self.Character} --- remember to define our character!
    Params.FilterType = Enum.RaycastFilterType.Blacklist

    self.Hitbox.RaycastParams = Params
    self.Hitbox.OnHit:Connect(function(hit, humanoid)
<<<<<<< HEAD
        if humanoid.Health < 1 then return end

        local Gold = humanoid.Parent:GetAttribute('Gold')
        local Type = humanoid.Parent:GetAttribute('Type')
        local Level = humanoid.Parent:GetAttribute('Level')

        humanoid:TakeDamage(self.profile.Data.strength * 300)
        
        if humanoid.Health < 1 then
            PlayerManagerService.Client.renderCoins:Fire(self.Player, Gold, humanoid.Parent.PrimaryPart.Position)
            self:IncrementCoins(Gold or 0)
            self:IncrementXP(Level * 100 * .25)
            if Type == 'DragonBoss' then self:TriggerDropChance() end
        end
=======
        humanoid:TakeDamage(200)
>>>>>>> 6887c98e3ea953328f8ec7f65d75d789f6e2ca4e
    end)
end
function PlayerManager:ConstructHitbox()
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
<<<<<<< HEAD

    if not self.Character:FindFirstChild('Sword') then
        self:EquipSword(self.profile.Data.equiped)
    end

=======
>>>>>>> 6887c98e3ea953328f8ec7f65d75d789f6e2ca4e
    self.Character.Humanoid.WalkSpeed = 50
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

--DROP CHANCE------------------------------------------------------------------------------------
function PlayerManager:TriggerDropChance()

end
--DROP CHANCE------------------------------------------------------------------------------------

--INVENTORY-----------------------------------------------------------------------------------
function PlayerManager:MonitorCharacter()
    local Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    
    Character.ChildAdded:Connect(function(Object)
        if Object:GetAttribute('Weapon') then
            self:ConstructHitbox()
        end
    end)

    self.Player.CharacterAdded:Connect(function()
        self:MonitorCharacter()
        self:EquipSword(self.profile.Data.equiped)
    end)
end
function PlayerManager:AddWeaponToInventory(weaponName)
    if self.profile.Data.inventory[weaponName] then
        self.profile.Data.inventory[weaponName] += 1
    else
        self.profile.Data.inventory[weaponName] = 1
    end
end

function PlayerManager:EquipSword(weaponName)
    if not ReplicatedStorage.Assets.Swords.Weapon:FindFirstChild(weaponName) then
        error('"'..weaponName..'" does not exist in weapon database')
    elseif not self.profile.Data.inventory[weaponName] then
        error('Player does not own weapon')
    end
    local SwordClone = ReplicatedStorage.Assets.Swords.Weapon[weaponName]:Clone()
    SwordClone.Name = 'Sword'

    local Character = self.Player.Character
    local RightHand = Character.RightHand
    local PivotOffset = SwordClone.PivotOffset
    
    if Character:FindFirstChild('Sword') then
        Character.Sword:Destroy()
    end
    if RightHand:FindFirstChild('Weld') then
    	RightHand.Weld:Destroy()
	end

    local Weld = Instance.new('Weld')
    Weld.Part0 = SwordClone
    Weld.Part1 = RightHand
    Weld.C0 = PivotOffset--CFrame.new(PivotOffset.X, PivotOffset.Y, PivotOffset.Z) * CFrame.fromEulerAnglesXYZ(PivotOffset.X, 0, 0)
    Weld.Parent = RightHand
    
    SwordClone.Parent = Character
    self.profile.Data.equiped = weaponName
end
--INVENTORY------------------------------------------------------------------------------------

--DATA INCREMENT------------------------------------------------------------------------------------
function PlayerManager:IncrementCoins(amount)
    if amount then
        self.profile.Data['coins'] += amount
    else
        warn('PlayerManagerService: PlayerManager:IncrementCoins(amount) -> amount is nil; No gold was earned.')
    end
end

function PlayerManager:IncrementLevel()

end

function PlayerManager:IncrementXP(amount)
    self.profile.Data['xp'] += amount
end
--DATA INCREMENT------------------------------------------------------------------------------------
function PlayerManager:Init()

    --Player_572995537
    --Player__572995537
    local profile = ProfileStore:LoadProfileAsync("Player_" .. self.Player.UserId)
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
    self:MonitorCharacter()

end


return PlayerManager