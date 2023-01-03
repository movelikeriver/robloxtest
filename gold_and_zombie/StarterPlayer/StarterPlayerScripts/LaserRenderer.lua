-- StarterPlayer/StarterPlayerScripts/LaserRenderer.lua

local LaserRenderer = {}

local SHOT_DURATION = 0.15 -- Time that the laser is visible for

-- Create a laser beam from a start position towards an end position
function LaserRenderer.createLaser(toolHandle, endPosition)
	local startPosition = toolHandle.Position
	local laserDistance = (startPosition - endPosition).Magnitude
	local laserCFrame = CFrame.lookAt(startPosition, endPosition) * CFrame.new(0, 0, -laserDistance / 2)
	local laserPart = Instance.new("Part")
	laserPart.Size = Vector3.new(0.2, 0.2, laserDistance)
	laserPart.CFrame = laserCFrame
	laserPart.Anchored = true
	laserPart.CanCollide = false
	laserPart.Color = Color3.fromRGB(225, 0, 0)
	laserPart.Material = Enum.Material.Neon
	laserPart.Parent = workspace

	-- Add laser beam to the Debris service to be removed & cleaned up
	game.Debris:AddItem(laserPart, SHOT_DURATION)
end


return LaserRenderer
