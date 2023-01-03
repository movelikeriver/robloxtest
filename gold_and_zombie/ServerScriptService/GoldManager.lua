-- ServerScriptService/GoldManager.lua

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local goldChunksFolder = workspace:WaitForChild("GoldChunks")
local eventsFolder = ReplicatedStorage.Events

local goldStore = DataStoreService:GetDataStore("PlayerGold")
local random = Random.new()

-- Table to store each player's gold during the current session
local playerGold = {}

local GOLD_VALUE = 10
local GOLD_REGENERATION_BOUNDS = {
	minX = -35,
	maxX = 190,
	minZ = -40,
	maxZ = 50
}
local GOLD_REGEN_DELAY = 2
local AUTOSAVE_INTERVAL = 30


local function processGoldTouch(chunk, chunkValue, player)
	-- Temporarily "destroy" gold chunk
	chunk.Parent = nil

	-- Update gold value in session table
	local playerUserID = player.UserId
	if playerGold[playerUserID] then
		playerGold[playerUserID] += chunkValue
	else
		playerGold[playerUserID] = chunkValue
	end

	-- Update player UI and play collection sound
	local uiValue = playerGold[playerUserID] or 0
	print("touch: ", playerUserID, uiValue)
	player:SetAttribute("GoldValue", uiValue)
	eventsFolder.UIEvent:FireClient(player, {gold = uiValue, doTween = true, showAlert = false})

	-- Regenerate gold chunk after delay
	wait(GOLD_REGEN_DELAY)
	local nextPositionX = random:NextInteger(GOLD_REGENERATION_BOUNDS.minX, GOLD_REGENERATION_BOUNDS.maxX)
	local nextPositionZ = random:NextInteger(GOLD_REGENERATION_BOUNDS.minZ, GOLD_REGENERATION_BOUNDS.maxZ)
	print(nextPositionX, nextPositionZ)
	chunk.CFrame = CFrame.new(nextPositionX, 50, nextPositionZ)
	chunk.Parent = workspace.GoldChunks
	chunk:SetAttribute("DropCollided", false)
end

-- Initially connect all gold chunks to touch detection
local goldChunks = goldChunksFolder:GetChildren()

for _, chunk in ipairs(goldChunks) do
	chunk.Touched:Connect(function(otherPart)
		local partParent = otherPart.Parent
		local player = Players:GetPlayerFromCharacter(partParent)
		if player then
			processGoldTouch(chunk, GOLD_VALUE, player)
		end
	end)
end

local function saveData(dataStoreKey, value)
	local setSuccess, errorMessage = pcall(function()
		--print("saveData", dataStoreKey, value)
		goldStore:SetAsync(dataStoreKey, value)
	end)
	if not setSuccess then
		--print("errorMessage: ", errorMessage)
		warn(errorMessage)
	end
end

local function onPlayerRemoving(player)
	--print("onPlayerRemoving")

	-- Update data store key
	local playerUserID = player.UserId
	if playerGold[playerUserID] then
		saveData(playerUserID, playerGold[playerUserID])
	end
end

local function onPlayerAdded(player)
	--print("onPlayerAdded")
	
	-- Initially get player's gold from data store
	local playerUserID = player.UserId
	local success, storedGold = pcall(function()
		return goldStore:GetAsync(playerUserID)
	end)
	if success then
		local currentGold = storedGold or 0
		playerGold[playerUserID] = currentGold
		uiEvent:FireClient(player, {gold = currentGold, doTween = false, showAlert = false})
	else
		uiEvent:FireClient(player, {showAlert = true})
	end

	-- Queue data auto-save in coroutine
	coroutine.wrap(function()
		while wait(AUTOSAVE_INTERVAL) do
			if playerGold[playerUserID] then
				saveData(playerUserID, playerGold[playerUserID])
			end
		end
	end)()
end

-- Score


--game.Workspace.GoldChunks.GoldRock.Touched:Connect(function(hit)
--	if hit.Parent:WaitForChild("Humanoid") then
--		game.Workspace.GoldChunks.GoldRock:Destroy()
--	end	
--end)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)