-- [[ SELECT ROLE MODULE | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Date: April 23, 2026
-- Description: Core logic for RNG-based role distribution and player attribute management.
-- "Divide et Impera."

local SelectRoleModule = {}

-- Constant role definitions to prevent string typos
SelectRoleModule.Roles = {
	Survivor = "Survivor",
	Killer = "Killer",
}

--- Assigns the default 'Survivor' attribute to a player
function SelectRoleModule.AddInnocentAttribute(player: Player)
	player:SetAttribute("Role", SelectRoleModule.Roles.Survivor)
end

--- Assigns the 'Killer' attribute to a specific player
function SelectRoleModule.AddKillerAttribute(player: Player)
	player:SetAttribute("Role", SelectRoleModule.Roles.Killer)
end

--- Core Logic: Selects a random killer and maps all player roles to a dictionary
function SelectRoleModule.SelectRole()
	local players = game:GetService("Players"):GetPlayers()
	local playersRolesResult = {}
	
	-- Safety check for empty servers
	if #players == 0 then return playersRolesResult end
	
	-- 1. Reset all players to Survivor status
	for _, player in ipairs(players) do
		player:SetAttribute("Role", SelectRoleModule.Roles.Survivor)
	end
	
	-- 2. Select a random Killer
	local killerIndex = math.random(1, #players)
	local killerPlayer = players[killerIndex]
	
	if killerPlayer then
		SelectRoleModule.AddKillerAttribute(killerPlayer)
	end
	
	-- 3. Populate the results table for the Round Executor
	for _, player in ipairs(players) do
		playersRolesResult[player.Name] = player:GetAttribute("Role")
	end

	return playersRolesResult
end

return SelectRoleModule