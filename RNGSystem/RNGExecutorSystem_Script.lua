-- [[ RNG EXECUTOR SYSTEM | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Handles player data initialization and bridges Client requests to the RNG Module.
-- "Cogito, ergo sum."

local RNGModule = require(game.ServerScriptService.RNGModule)
local Players = game:GetService("Players")

-- RemoteFunction used to handle synchronous roll requests from the client
local RollFunction = game.ReplicatedStorage:WaitForChild("RollFunction")

--- Initializes player attributes upon joining the server
-- Ensures every player has a starting PityCount of 0
Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("PityCount", 0)
end)

--- Listens for client-side roll requests
-- Calls the core RNG Module logic and returns the result to the caller
-- @param player: The player who invoked the RemoteFunction
-- @return table: The fruit name and data returned by the module
RollFunction.OnServerInvoke = function(player)
	local result = RNGModule.Roll(player)
	
	return result
end