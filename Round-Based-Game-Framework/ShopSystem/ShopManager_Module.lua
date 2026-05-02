-- [[ SHOP MANAGER MODULE | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Handles item pricing and player inventory retrieval.
-- Consumes data from DataManager to ensure persistent transactions.

local ShopRules = {}

-- // SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- // DEPENDENCIES
local DataManager = require(ServerScriptService.DataSaveSystem.Data.DataManager)

-- // ITEM DATABASE
-- Prices and Item names. 0 = Free/Starter item.
ShopRules.Items = {
	["Sword"] = 0,
	["Slingshot"] = 15,
	-- Add more items here
}

-- // CORE FUNCTIONS

-- Retrieves the player's inventory directly from their saved profile.
function ShopRules.GetPlayerInventory(player: Player)
	local profile = DataManager.GetProfile(player)
	if profile then
		return profile.Data.Inventory
	end
	return nil
end

-- Returns the price list for all available gears.
function ShopRules.GetGearsPrice()
	return ShopRules.Items
end

return ShopRules