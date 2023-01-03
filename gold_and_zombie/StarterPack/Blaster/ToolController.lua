-- StarterPack/Blaster/ToolController.lua

local UserInputService = game:GetService("UserInputService") 
local Players = game:GetService("Players") 
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaserRenderer = require(Players.LocalPlayer.PlayerScripts.LaserRenderer)

local tool = script.Parent
local eventsFolder = ReplicatedStorage.Events 

local MAX_MOUSE_DISTANCE = 1000
local MAX_LASER_DISTANCE = 500
local FIRE_RATE = 0.3 
local timeOfPreviousShot = 0

-- Check if enough time has passed since previous shot was fired
local function canShootWeapon()
	local currentTime = tick()
	if currentTime - timeOfPreviousShot < FIRE_RATE then
		return false
	end
	return true
end


local function getWorldMousePosition()
	local mouseLocation = UserInputService:GetMouseLocation()
	
	--print("mouse pos: ", mouseLocation.X, mouseLocation.Y)
	
	-- Create a ray from the 2D mouse location
	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	
	-- The unit direction vector of the ray multiplied by a maximum distance
	local directionVector = screenToWorldRay.Direction * MAX_MOUSE_DISTANCE

	-- Raycast from the ray's origin towards its direction
	local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector)
	
	if raycastResult then
		--print(raycastResult.Position)
		-- Return the 3D point of intersection
		return raycastResult.Position
	else
		--print("not hit any object")
		-- No object was hit so calculate the position at the end of the ray
		return screenToWorldRay.Origin + directionVector
	end
end

local function fireWeapon()
	local mouseLocation = getWorldMousePosition()

	-- Calculate a normalised direction vector and multiply by laser distance
	local targetDirection = (mouseLocation - tool.Handle.Position).Unit

	-- The direction to fire the weapon multiplied by a maximum distance
	local directionVector = targetDirection * MAX_LASER_DISTANCE

	-- Ignore the player's character to prevent them from damaging themselves
	local weaponRaycastParams = RaycastParams.new()
	weaponRaycastParams.FilterDescendantsInstances = {Players.LocalPlayer.Character}
	
	local weaponRaycastResult = workspace:Raycast(tool.Handle.Position, directionVector, weaponRaycastParams)
	-- Check if any objects were hit between the start and end position
	local hitPosition
	if weaponRaycastResult then
		--print("hit position")
		hitPosition = weaponRaycastResult.Position
				
		-- The instance hit will be a child of a character model
		-- If a humanoid is found in the model then it's likely a player's character
		local characterModel = weaponRaycastResult.Instance:FindFirstAncestorOfClass("Model")
		if characterModel then
			local humanoid = characterModel:FindFirstChild("Humanoid")
			if humanoid then
				--print("Player hit")
				eventsFolder.DamageCharacter:FireServer(characterModel) 
			end
		end
	else
		--print("not hit position")
		-- Calculate the end position based on maximum laser distance
		hitPosition = tool.Handle.Position + directionVector
	end
	
	eventsFolder.LaserFired:FireServer(hitPosition)
	LaserRenderer.createLaser(tool.Handle, hitPosition) 
end


local function toolEquipped()
	tool.Handle.Equip:Play()
end

local function toolActivated()
	if canShootWeapon() then
		tool.Handle.Activate:Play()
		fireWeapon()
	end
	
end

-- Connect events to appropriate functions 
tool.Equipped:Connect(toolEquipped)
tool.Activated:Connect(toolActivated)
