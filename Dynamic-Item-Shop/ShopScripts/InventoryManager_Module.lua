-- [[ DYNAMIC ITEM SHOP | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Server-side module for managing player inventory states.
-- Handles session-based item ownership without persistent data storage.

local InventoryManager = {}

-- Table to store item lists for each active player (Key: UserId)
local playersItems = {}

--- Registers a player into the session-based inventory system
function InventoryManager.AddPlayer(player: Player)
	local key = player.UserId
	
	if playersItems[key] then return end
	
	playersItems[key] = {}
	print("DEBUG: " .. player.Name .. " registered in the inventory system.")
end

--- Removes a player and cleans up their data from memory
function InventoryManager.RemovePlayer(player: Player)
	local key = player.UserId
	
	if not playersItems[key] then return end
	
	playersItems[key] = nil
	print("DEBUG: Session data cleared for " .. player.Name)
end

--- Inserts a new item into the player's session inventory
function InventoryManager.AddItem(player: Player, itemName: string)
	local key = player.UserId
	
	if not playersItems[key] then return end
	
	-- Prevent duplicate items
	if table.find(playersItems[key], itemName) then return end
	
	table.insert(playersItems[key], itemName)
	
	-- Print the updated table for verification (matches your original logic)
	print("DEBUG: Updated inventory for " .. player.Name .. ":", playersItems[key])
end

--- Removes a specific item from the player's session inventory
function InventoryManager.RemoveItem(player: Player, itemName: string)
	local key = player.UserId
	
	if not playersItems[key] then return end
	
	local itemIndex = table.find(playersItems[key], itemName)
	
	if not itemIndex then return end
	
	table.remove(playersItems[key], itemIndex)
	print("DEBUG: " .. itemName .. " removed from " .. player.Name .. "'s inventory.")
end

--- Helper function: Checks if the player owns a specific item
function InventoryManager.HasItem(player: Player, itemName: string)
	local key = player.UserId
	if not playersItems[key] then return false end
	
	return table.find(playersItems[key], itemName) ~= nil
end

return InventoryManager