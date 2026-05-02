-- [[ SHOP SERVER EXECUTOR | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Handles server-side shop transactions and GUI updates.
-- This script validates purchases and communicates with DataManager.

local ShopModule = require(script.Parent.ShopRules)
local DataManager = require(game.ServerScriptService.DataSaveSystem.Data.DataManager)

-- // SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // REMOTES
local ShopRemotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopEvents = ShopRemotes.Events.ShopSystem
local ShopFunctions = ShopRemotes.Functions.ShopSystem

local updateGUI = ShopEvents.UpdateGUI
local openedGUI = ShopEvents.OpenedGUI
local updateMoneyGUI = ShopEvents.UpdateMoneyGUI
local buyItemFunction = ShopFunctions.BuyItem

-- // 1. GUI SYNCHRONIZATION

-- Sends ownership and price data to the client to refresh the Shop UI.
local function UpdateShopGui(player: Player)
	local ownedItems = ShopModule.GetPlayerInventory(player)
	local itemPrices = ShopModule.GetGearsPrice()

	if ownedItems and itemPrices then
		updateGUI:FireClient(player, ownedItems, itemPrices)
	end
end

-- Refresh UI when the player opens the Shop.
openedGUI.OnServerEvent:Connect(function(player: Player)
	UpdateShopGui(player)
	
	local profile = DataManager.GetProfile(player)
	if profile then
		updateMoneyGUI:FireClient(player, profile.Data.Cash)
	end
end)

-- // 2. TRANSACTION LOGIC

-- Validates and processes item purchases.
buyItemFunction.OnServerInvoke = function(player: Player, gear: Tool)
	local gearName = gear.Name
	local profile = DataManager.GetProfile(player)
	
	if not profile then return false end
	
	local inventory = profile.Data.Inventory
	local itemPrices = ShopModule.GetGearsPrice()
	local price = itemPrices[gearName]
	
	-- Security check: Verify if price exists and player doesn't already own the item
	if price and inventory[gearName] == false then
		-- Check if player has enough currency
		if profile.Data.Cash >= price then
			-- Process transaction via DataManager
			DataManager.RemoveCash(player, price)
			inventory[gearName] = true
			
			-- Sync GUI after purchase
			UpdateShopGui(player)
			return true -- Transaction Successful
		end
	end
	
	return false -- Transaction Failed
end