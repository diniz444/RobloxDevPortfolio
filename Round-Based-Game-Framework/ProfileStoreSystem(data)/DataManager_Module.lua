-- [[ DATA MANAGER API | PERSISTENT STORE SYSTEM ]]
-- Author: [diniz444]
-- Description: A secure, abstract API for managing player data and state synchronization.

local DataManager = {}

-- // PROFILE CACHE
-- Stores active ProfileService objects for session management.
DataManager.Profiles = {}

-- // PRIVATE UTILS
-- Internal function to update leaderstats only if they exist (prevents errors).
local function updateUI(player, folderName, statName, value)
	local folder = player:FindFirstChild(folderName)
	if folder and folder:FindFirstChild(statName) then
		folder[statName].Value = value
	end
end

-- // PUBLIC API FUNCTIONS

-- Abstract method to modify any numeric stat safely.
-- This prevents the need for 50 different functions like "AddCash", "AddLevel", etc.
function DataManager.UpdateStat(player: Player, statName: string, amount: number)
	local profile = DataManager.Profiles[player]
	if not (profile and profile.Data[statName]) then return end
	
	profile.Data[statName] += amount
	
	-- Automatic leaderstats sync
	updateUI(player, "leaderstats", statName, profile.Data[statName])
end

-- Secure method to decrement currency with built-in validation.
function DataManager.Purchase(player: Player, statName: string, cost: number): boolean
	local profile = DataManager.Profiles[player]
	if not profile then return false end
	
	-- Verify balance
	if profile.Data[statName] >= cost then
		profile.Data[statName] -= cost
		updateUI(player, "leaderstats", statName, profile.Data[statName])
		return true
	end
	
	return false
end

-- Generic Inventory Management
function DataManager.GrantItem(player: Player, collectionName: string, itemId: string)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	-- Logic: Check if the collection exists and store the item
	if not profile.Data[collectionName] then 
		profile.Data[collectionName] = {} 
	end
	
	profile.Data[collectionName][itemId] = true
end

-- Returns the raw profile for advanced server-side operations.
function DataManager.GetProfile(player: Player)
	return DataManager.Profiles[player]
end

return DataManager