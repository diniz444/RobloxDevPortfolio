-- [[ SHOP TRANSACTION ORCHESTRATOR | SECURE VERSION ]]
-- Author: [diniz444]
-- Description: Server-side handler for economic transactions. 
-- Implements strict validation to prevent exploit-based currency manipulation.

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // DEPENDENCIES
local ShopModule = require(script.Parent:WaitForChild("ShopManager_Module"))
local DataManager = require(ServerScriptService:WaitForChild("DataSaveSystem"):WaitForChild("DataScripts"):WaitForChild("DataManager"))

-- // NETWORKING SETUP
local ShopRemotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopEvents = ShopRemotes:WaitForChild("Events"):WaitForChild("ShopSystem")
local ShopFunctions = ShopRemotes:WaitForChild("Functions"):WaitForChild("ShopSystem")

-- Remote Signals
local SyncShopUI = ShopEvents:WaitForChild("UpdateGUI")
local OnShopOpened = ShopEvents:WaitForChild("OpenedGUI")
local BuyItemRequest = ShopFunctions:WaitForChild("BuyItem")

-- // 1. STATE SYNCHRONIZATION

-- Synchronizes the client's view with the server's authoritative data.
local function RefreshClientView(player: Player)
	local inventory = ShopModule.GetPlayerInventory(player)
	local catalog = ShopModule.GetCatalog()

	if inventory and catalog then
		SyncShopUI:FireClient(player, inventory, catalog)
	end
end

-- Handles the initial handshake when a player interacts with the Shop NPC/UI.
OnShopOpened.OnServerEvent:Connect(function(player: Player)
	RefreshClientView(player)
end)

-- // 2. SECURE TRANSACTION ENGINE

-- OnServerInvoke is used to provide immediate feedback (Success/Fail) to the client.
BuyItemRequest.OnServerInvoke = function(player: Player, itemId: string): boolean
	-- 1. Identity & Data Integrity Check
	local profile = DataManager.GetProfile(player)
	if not (profile and typeof(itemId) == "string") then 
		return false 
	end
	
	-- 2. Business Logic Validation (Price, Ownership, Existence)
	local isValid, reason = ShopModule.ValidatePurchase(player, itemId)
	
	if isValid then
		local itemData = ShopModule.GetItemData(itemId)
		local price = itemData.Price
		
		-- 3. Atomic Transaction: Check balance and deduct in a single sequence
		-- This prevents 'race conditions' where a player could buy two items at once
		local success = DataManager.Purchase(player, "Cash", price)
		
		if success then
			-- 4. Grant Item & Update State
			DataManager.GrantItem(player, "Inventory", itemId)
			
			-- Final Sync to ensure UI reflects new balance and ownership
			RefreshClientView(player)
			print(string.format("[Shop]: %s purchased %s for %d", player.Name, itemId, price))
			return true
		end
	end
	
	warn(string.format("[Shop]: Transaction failed for %s. Reason: %s", player.Name, reason or "Unknown"))
	return false
end