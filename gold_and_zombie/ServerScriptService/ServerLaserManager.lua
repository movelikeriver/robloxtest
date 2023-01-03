-- ServerScriptService/ServerLaserManager.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local eventsFolder = ReplicatedStorage.Events
local LASER_DAMAGE = 10

-- Find the handle of the tool the player is holding
local function getPlayerToolHandle(player)
	local weapon = player.Character:FindFirstChildOfClass("Tool")
	if weapon then
		return weapon:FindFirstChild("Handle")
	end
end


-- Notify all clients that a laser has been fired so they can display the laser
local function playerFiredLaser(playerFired, endPosition)
	local toolHandle = getPlayerToolHandle(playerFired)
	if toolHandle then
		eventsFolder.LaserFired:FireAllClients(playerFired, toolHandle, endPosition)
	end
end


function damageCharacter(playerFired, characterToDamage)
	local humanoid = characterToDamage:FindFirstChild("Humanoid")
	if humanoid then
		--print("damageCharacter: hit payer")
		-- Remove health from character
		humanoid.Health -= LASER_DAMAGE
	end
end

-- Connect events to appropriate functions
eventsFolder.DamageCharacter.OnServerEvent:Connect(damageCharacter)
eventsFolder.LaserFired.OnServerEvent:Connect(playerFiredLaser)
