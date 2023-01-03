-- StarterPlayer/StarterPlayerScripts/ClientLaserManager.lua

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LaserRenderer = require(script.Parent:WaitForChild("LaserRenderer"))
local eventsFolder = ReplicatedStorage.Events

-- Display another player's laser
local function createPlayerLaser(playerWhoShot, toolHandle, endPosition)
	if playerWhoShot ~= Players.LocalPlayer then
		LaserRenderer.createLaser(toolHandle, endPosition)
	end
end

eventsFolder.LaserFired.OnClientEvent:Connect(createPlayerLaser)
