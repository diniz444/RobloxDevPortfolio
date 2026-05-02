-- [[ DATA MANAGER MODULE | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Global API for managing player statistics, economy, and inventory.
-- This module acts as a middleman between the game logic and the ProfileService data.

local DataManager = {}

-- // PROFILE CACHE
-- Stores active profiles for all connected players.
DataManager.Profiles = {}

-- // SETTINGS
local CASH_PER_KILL = 5
local CASH_PER_WIN = 15

-- // PUBLIC API FUNCTIONS

-- Adds Kills and rewards the player with Cash.
function DataManager.AddKill(player: Player, amount: number)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	profile.Data.Kills += amount
	profile.Data.Cash += (amount * CASH_PER_KILL)
	
	-- Syncing with Leaderstats
	if player:FindFirstChild("leaderstats") then
		player.leaderstats.Kills.Value = profile.Data.Kills
		player.leaderstats.Cash.Value = profile.Data.Cash
	end
end

-- Adds Wins and rewards the player with a larger amount of Cash.
function DataManager.AddWin(player: Player, amount: number)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	profile.Data.Wins += amount
	profile.Data.Cash += (amount * CASH_PER_WIN)
	
	if player:FindFirstChild("leaderstats") then
		player.leaderstats.Wins.Value = profile.Data.Wins
		player.leaderstats.Cash.Value = profile.Data.Cash
	end
end

-- Adds a specific amount of Cash to the player's profile.
function DataManager.AddCash(player: Player, amount: number)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	profile.Data.Cash += amount
	
	if player:FindFirstChild("leaderstats") then
		player.leaderstats.Cash.Value = profile.Data.Cash
	end
end

-- Safely removes Cash (Prevents negative values).
function DataManager.RemoveCash(player: Player, amount: number)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	-- Ensuring the player doesn't go below 0
	if profile.Data.Cash >= amount then
		profile.Data.Cash -= amount
	else
		profile.Data.Cash = 0
	end
	
	if player:FindFirstChild("leaderstats") then
		player.leaderstats.Cash.Value = profile.Data.Cash
	end
end

-- Registers an item in the player's persistent inventory.
function DataManager.AddItemToInventory(player: Player, itemName: string)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	-- Inventory is stored as a dictionary for fast lookup
	profile.Data.Inventory[itemName] = true
end

-- Returns the player's profile object for custom manipulations.
function DataManager.GetProfile(player: Player)
	return DataManager.Profiles[player]
end

return DataManager