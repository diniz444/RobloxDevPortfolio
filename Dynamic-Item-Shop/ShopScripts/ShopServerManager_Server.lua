-- [[ DYNAMIC  ITEM SHOP | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Central server controller for the shop economy and logic.
-- Manages player currency (leaderstats) and processes secure item purchases.

----- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----- MODULES
-- Core inventory logic for session-based item tracking
local InventoryModule = require(script.Parent:WaitForChild("InventoryManager"))

----- COMMUNICATION & DATA
local buyRemote = ReplicatedStorage:WaitForChild("Buy")
local itemsFolder = ReplicatedStorage:WaitForChild("ShopItens")
local increaseCurrencyRemote = ReplicatedStorage:WaitForChild("IncreaseCurrency")

----- ECONOMY SETUP (Leaderstats)
Players.PlayerAdded:Connect(function(player: Player)
	-- Create the leaderstats folder required for Roblox player lists
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	-- Initialize the main currency
	local currency = Instance.new("IntValue")
	currency.Name = "Currency"
	currency.Value = 0
	currency.Parent = leaderstats
	
	-- Register player in the Inventory Module
	InventoryModule.AddPlayer(player)
end)

----- SESSION CLEANUP
Players.PlayerRemoving:Connect(function(player: Player)
	-- Wipe player session data to maintain server performance
	InventoryModule.RemovePlayer(player)
end)

----- PURCHASE PROCESSING
-- Using OnServerInvoke to provide immediate feedback to the client
buyRemote.OnServerInvoke = function(player: Player, itemName: string)
	local item = itemsFolder:FindFirstChild(itemName)
	
	-- 1. Security Check: Validate item existence
	if not item then 
		warn("SECURITY: Player " .. player.Name .. " attempted to buy non-existent item: " .. itemName)
		return false 
	end
	
	local price = item:GetAttribute("Price")
	local currency = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Currency")
	
	-- 2. Transaction Check: Verify funds and process purchase
	if currency and currency.Value >= price then
		-- Deduct funds
		currency.Value -= price
		
		-- Update Inventory Module
		InventoryModule.AddItem(player, itemName)
		
		return true -- Successful purchase
	else
		-- Insufficient funds
		return false
	end
end

----- DEVELOPER TESTING TOOLS
-- Remote listener for the debug currency tool
increaseCurrencyRemote.OnServerEvent:Connect(function(player: Player)
	local currency = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Currency")
	
	if currency then
		currency.Value += 100
		print("DEBUG: Granted $100 to " .. player.Name)
	end
end)