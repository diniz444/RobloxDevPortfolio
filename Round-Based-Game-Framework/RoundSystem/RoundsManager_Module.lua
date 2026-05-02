-- [[ ROUND MANAGER MODULE | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Core logic for game states, map rotation, and player session data.

local RoundModule = {}

-- // 1. MAP MANAGEMENT
-- FrozenMaps prevents the same map from being picked twice in a row.
local FrozenMaps = {}
local MAX_FROZEN_MAPS = 2
local MapsFolder = game.ReplicatedStorage:WaitForChild("Maps")
local maps = MapsFolder:GetChildren()

-- Randomly selects a map that isn't currently "frozen".
function RoundModule.ChooseMap()
	local availableMaps = {}
	
	-- Filter out frozen maps
	for _, map in pairs(maps) do
		if not table.find(FrozenMaps, map.Name) then
			table.insert(availableMaps, map)
		end
	end	
	
	-- Select a random map from the available pool
	local chosenMap = availableMaps[math.random(1, #availableMaps)]
	
	-- Add to frozen list and maintain max limit
	table.insert(FrozenMaps, chosenMap.Name)
	if #FrozenMaps > MAX_FROZEN_MAPS then
		table.remove(FrozenMaps, 1)
	end

	return chosenMap
end

-- // 2. ROUND STATE SYSTEM
-- Defines the possible phases of a game loop.
RoundModule.States = {
	OnLobby = "OnLobby",
	OnIntermission = "OnIntermission",
	OnRound = "OnRound",
	OnEnd = "OnEnd"
}

RoundModule.ActiveState = RoundModule.States.OnLobby

-- Updates the current phase of the game.
function RoundModule.ChangeState(state: string)
	RoundModule.ActiveState = state
end

-- // 3. SESSION PLAYER DATA (GEARS)
-- Internal table to track players currently in the round session.
local players = {}

-- Registers a player into the round session.
function RoundModule.AddPlayer(player: Player)
	if not players[player] then
		players[player] = {
			EquippedGear = nil,
		}
	end
end

-- Removes a player from the session (on leave or elimination).
function RoundModule.RemovePlayer(player: Player)
	if players[player] then
		players[player] = nil
	end
end

-- Assigns a gear to a player for the current round.
function RoundModule.EquipGear(player: Player, gear: string)
	if players[player] then
		if players[player].EquippedGear == nil then
			players[player].EquippedGear = gear
			return true
		end
	end
	return false
end

-- Clears the player's equipped gear slot.
function RoundModule.UnequipGear(player: Player, gear: string)
	if players[player] and players[player].EquippedGear == gear then
		players[player].EquippedGear = nil
		return true
	end
	return false
end

-- Returns the name of the gear the player is using.
function RoundModule.GetGear(player: Player)
	return players[player] and players[player].EquippedGear
end

-- Returns the entire table of active players.
function RoundModule.GetPlayers()
	return players
end

return RoundModule