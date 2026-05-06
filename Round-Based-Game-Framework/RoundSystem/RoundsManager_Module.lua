-- [[ ROUND MANAGER MODULE | GAME ARCHITECTURE ]]
-- Author: [diniz444]
-- Description: Core logic for game states, map rotation history, and session-specific equipment tracking.

local RoundModule = {}

-- // 1. MAP ROTATION MANAGEMENT
-- History buffer to prevent the same map from being selected consecutively.
local FrozenMaps = {}
local MAX_FROZEN_MAPS = 2
local MapsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Maps")
local maps = MapsFolder:GetChildren()

-- Selects a map using a filtered pool to ensure gameplay variety.
function RoundModule.ChooseMap()
	local availableMaps = {}
	
	-- Filter out maps currently in the "Frozen" history buffer
	for _, map in ipairs(maps) do
		if not table.find(FrozenMaps, map.Name) then
			table.insert(availableMaps, map)
		end
	end	
	
	-- Select random map from the validated pool
	local chosenMap = availableMaps[math.random(1, #availableMaps)]
	
	-- Update history buffer and maintain size limit
	table.insert(FrozenMaps, chosenMap.Name)
	if #FrozenMaps > MAX_FROZEN_MAPS then
		table.remove(FrozenMaps, 1)
	end

	return chosenMap
end

-- // 2. STATE MACHINE
-- Standardized phases for the global game loop synchronization.
RoundModule.States = {
	OnLobby = "OnLobby",
	OnIntermission = "OnIntermission",
	OnRound = "OnRound",
	OnEnd = "OnEnd"
}

RoundModule.ActiveState = RoundModule.States.OnLobby

-- Transitions the game to a new phase.
function RoundModule.ChangeState(state: string)
	RoundModule.ActiveState = state
end

-- // 3. VOLATILE SESSION DATA
-- Internal dictionary to track player equipment and status during the active session.
local players = {}

-- Initializes a player's session profile.
function RoundModule.AddPlayer(player: Player)
	if not players[player] then
		players[player] = {
			EquippedGear = nil,
		}
	end
end

-- Cleanup: Removes player from session (essential to prevent memory leaks).
function RoundModule.RemovePlayer(player: Player)
	players[player] = nil
end

-- Logic for assigning gear; includes validation to prevent multi-equipping.
function RoundModule.EquipGear(player: Player, gear: string): boolean
	local session = players[player]
	if session and session.EquippedGear == nil then
		session.EquippedGear = gear
		return true
	end
	return false
end

-- Validates and clears the specific gear slot.
function RoundModule.UnequipGear(player: Player, gear: string): boolean
	local session = players[player]
	if session and session.EquippedGear == gear then
		session.EquippedGear = nil
		return true
	end
	return false
end

-- API Getters
function RoundModule.GetGear(player: Player)
	return players[player] and players[player].EquippedGear
end

function RoundModule.GetPlayers()
	return players
end

return RoundModule