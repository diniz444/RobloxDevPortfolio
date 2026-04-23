-- [[ DYNAMIC RNG & PITY SYSTEM | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Core module for calculating item probability with a luck-based Pity System.
-- "Cogito, ergo sum."

local RNGModule = {}

-- Probability table for all available fruits
RNGModule.Fruits = {
	["Kilo"]   = {Chance = 500, Rarity = "Common"},
	["Flame"]  = {Chance = 400, Rarity = "Common"},
	["Gomu"]   = {Chance = 350, Rarity = "Rare"},
	["Spring"] = {Chance = 500, Rarity = "Common"},
	["Hito"]   = {Chance = 450, Rarity = "Rare"},
	["Gura"]   = {Chance = 200, Rarity = "Epic"},
	["Light"]  = {Chance = 150, Rarity = "Epic"},
	["Hie"]    = {Chance = 150, Rarity = "Epic"},
	["Magu"]   = {Chance = 150, Rarity = "Epic"},
	["Yami"]   = {Chance = 100, Rarity = "Legendary"},
	["Dragon"] = {Chance = 10,  Rarity = "Legendary"},
	["Neko"]   = {Chance = 10,  Rarity = "Legendary"},
	["Nika"]   = {Chance = 1,   Rarity = "God"}
}

--- Processes a randomized fruit roll for a specific player
-- @param player: The player instance requesting the roll
-- @return: Table containing selectedFruit name and selectedData
function RNGModule.Roll(player: Player)
	local totalWeight = 0
	local currentPity = player:GetAttribute("PityCount") or 0
	
	-- Calculates luck multiplier based on accumulated Pity
	local luckMultiplier = 1 + (currentPity / 100)
	
	local selectedFruit = nil
	local selectedData = nil
	
	-- 1. Calculate total dynamic weight based on luck
	for _, fruitData in pairs(RNGModule.Fruits) do
		if fruitData.Chance <= 200 then
			-- Apply luck multiplier to rare/epic+ items
			totalWeight += (fruitData.Chance * luckMultiplier)
		else
			totalWeight += fruitData.Chance
		end
	end
	
	-- 2. Generate random target weight
	local randomWeight = math.random(1, math.floor(totalWeight))
	local accumulatedWeight = 0
	
	-- 3. Selection loop: Locates the fruit corresponding to the random weight
	for fruitName, fruitData in pairs(RNGModule.Fruits) do
		local weightValue = fruitData.Chance
		
		-- Match luck logic used in totalWeight calculation
		if weightValue <= 200 then
			accumulatedWeight += (weightValue * luckMultiplier)
		else
			accumulatedWeight += weightValue
		end
		
		if randomWeight <= accumulatedWeight then
			selectedFruit = fruitName
			selectedData = fruitData
			break
		end
	end
	
	-- 4. Fallback mechanism to prevent nil returns
	if not selectedFruit then
		selectedFruit = "Kilo"
		selectedData = RNGModule.Fruits["Kilo"]
	end
	
	-- 5. Pity Logic: Increment for Common/Rare, reset for higher rarities
	local nextPityValue = 0 

	if selectedData.Rarity == "Common" or selectedData.Rarity == "Rare" then
		nextPityValue = currentPity + 1
	else
		-- Reset Pity after a successful rare pull
		nextPityValue = 0
	end

	-- Update player's persistent data via Attributes
	player:SetAttribute("PityCount", nextPityValue)

	-- Log results for server-side verification
	print(string.format("[RNG] Player: %s | Rolled: %s (%s) | Pity: %d -> %d", 
		player.Name, selectedFruit, selectedData.Rarity, currentPity, nextPityValue))
	
	return {
		selectedFruit = selectedFruit,
		selectedData = selectedData
	}
end

return RNGModule