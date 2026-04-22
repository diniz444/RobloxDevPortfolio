--[[
    @title: Dynamic Weighted RNG Module with Pity System
    @author: 
    @description: A modular system for item rolling using probability weights. 
                  Includes a dynamic luck multiplier (Pity System) that increases 
                  rarity chances based on player attempts.
    @version: 1.0
]]

local RNGModule = {}

-- [[ Configuration Table ]]
RNGModule.Fruits = {
	-- ADD YOUR ITENS HERE
	-- ["Name"] = {Weight = 100, Rarity = "Common"},
}

--- Rolls for a random fruit based on weight and pity count.
-- @param PityCount number: The current number of failed rare rolls for the player.
-- @return string, number: The name of the fruit rolled and the updated Pity count.
function RNGModule.Roll(PityCount)
	local totalWeight = 0
	local currentPity = PityCount or 0
	
	-- Luck multiplier: 1% increase per pity point (e.g., 100 pity = 2x luck)
	local luckMultiplier = 1 + (currentPity / 100)
	
	-- 1. Calculate Total Weight (Dynamic)
	for _, fruitData in pairs(RNGModule.Fruits) do
		-- Rare fruits (Weight <= 200) get the luck boost
		if fruitData.Weight <= 200 then
			totalWeight += (fruitData.Weight * luckMultiplier)
		else
			totalWeight += fruitData.Weight
		end
	end
	
	-- Check if the table is empty to avoid errors
	if totalWeight <= 0 then 
		warn("RNGModule: No fruits found in the configuration table!")
		return nil, currentPity 
	end

	local randomWeight = math.random(1, math.floor(totalWeight))
	local accumulatedWeight = 0
	
	-- 2. Probability Mapping Loop
	for fruitName, fruitData in pairs(RNGModule.Fruits) do
		local weightValue = fruitData.Weight
		
		-- Apply same luck logic here to keep the "ruler" consistent
		if weightValue <= 200 then
			accumulatedWeight += (weightValue * luckMultiplier)
		else
			accumulatedWeight += weightValue
		end
		
		-- Check if roll falls within this fruit's range
		if randomWeight <= accumulatedWeight then
			
			-- Update Pity: Reset on Rare+, Increment on Common/Rare
			local newPity = currentPity
			if fruitData.Rarity == "Common" or fruitData.Rarity == "Rare" then
				newPity += 1
			else
				newPity = 0
			end
			
			return fruitName, newPity
		end
	end
end

return RNGModule