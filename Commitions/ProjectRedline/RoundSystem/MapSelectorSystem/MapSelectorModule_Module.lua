-- [[ MAP SELECTOR MODULE | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Handles randomized map selection with a history system to prevent repetition.
-- Usage: Require this module to retrieve a map object that hasn't been played recently.
-- "Alea Iacta Est."

local MapSelectorModule = {}

-- [[ VARIABLES ]]
local MapsFolder = game.ReplicatedStorage:WaitForChild("Maps")
local Maps = MapsFolder:GetChildren()

-- History system to prevent picking the same map twice (or more) in a row
local FrozenMaps = {}

-- [[ CONFIGURATION ]]
-- Adjust this based on your map count. 1 means the last map is unpickable.
local MAX_FROZEN_MAPS = 1 

-- [[ CORE FUNCTIONS ]]

--- Selects a random map while filtering out recently played ones.
--- @return Instance (The chosen Map Model)
function MapSelectorModule.GetRandomMap()
	local availableMaps = {}
	
	-- 1. Filtering: Only add maps that are NOT in the Frozen list
	for _, map in ipairs(Maps) do
		if not table.find(FrozenMaps, map.Name) then
			table.insert(availableMaps, map)
		end
	end
	
	-- 2. Safety Check: If all maps are frozen or folder is empty, reset history
	if #availableMaps == 0 then
		warn("MapSelector: No available maps found or all are frozen. Resetting history.")
		FrozenMaps = {}
		availableMaps = Maps
	end
	
	-- 3. Random Selection
	local randomIndex = math.random(1, #availableMaps)
	local chosenMap = availableMaps[randomIndex]

	-- 4. History Management: Push new map to frozen list
	table.insert(FrozenMaps, chosenMap.Name)
	
	-- Pop the oldest map if we exceed the allowed history size
	if #FrozenMaps > MAX_FROZEN_MAPS then
		table.remove(FrozenMaps, 1)
	end
	
	print("🗺️ Map Selected: " .. chosenMap.Name)
	return chosenMap
end

return MapSelectorModule