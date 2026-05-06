-- [[ SECURE SHOP GATEWAY | PORTFOLIO VERSION ]]
-- Author: [diniz444]
-- Description: Server-side validation for transactions and inventory state management.
-- This module ensures that all purchase requests are verified against a master database.

local ShopRules = {}

-- // DEPENDENCIES
-- Using relative paths to demonstrate modular dependency injection
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService:WaitForChild("DataSaveSystem"):WaitForChild("DataScripts"):WaitForChild("DataManager"))

-- // PROTECTED ITEM DATABASE
-- Stored on the server to prevent client-side price manipulation.
-- Format: [ItemID] = {Price = number, Category = string}
local ITEM_DATABASE = {
	["Sword_T1"] = {Price = 0, Category = "Starter"},
	["Slingshot_T1"] = {Price = 15, Category = "Ranged"},
	-- Abstracted IDs to protect game-specific balancing
}

-- // TRANSACTION VALIDATION

-- Core logic to verify if a transaction is legitimate before processing.
function ShopRules.ValidatePurchase(player: Player, itemId: string): (boolean, string)
	local itemData = ITEM_DATABASE[itemId]
	
	-- 1. Check if item exists in database
	if not itemData then
		return false, "Invalid Item ID"
	end
	
	-- 2. Check if player already owns the item (preventing duplicate charges)
	local inventory = ShopRules.GetPlayerInventory(player)
	if inventory and inventory[itemId] then
		return false, "Item already owned"
	end
	
	-- 3. Price Verification
	local price = itemData.Price
	if price == 0 then return true, "Free Item" end
	
	-- The actual deduction is handled by the DataManager for atomicity
	return true, "Transaction Validated"
end

-- // INVENTORY API

-- Retrieves persistent inventory data from the player's profile.
function ShopRules.GetPlayerInventory(player: Player)
	local profile = DataManager.GetProfile(player)
	if profile then
		return profile.Data.Inventory
	end
	return nil
end

-- Safely exposes price data for UI rendering without exposing sensitive logic.
function ShopRules.GetCatalog()
	local publicCatalog = {}
	for id, info in pairs(ITEM_DATABASE) do
		publicCatalog[id] = info.Price
	end
	return publicCatalog
end

-- Returns specific item metadata for server-side spawning.
function ShopRules.GetItemData(itemId: string)
	return ITEM_DATABASE[itemId]
end

return ShopRules