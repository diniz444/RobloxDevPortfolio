-- [[ SELECT ROLE INTERFACE | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Date: April 23, 2026
-- Description: Bridges the Round Executor with the Role Module via BindableFunctions.
-- "Divide et Impera."

-------- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-------- Modules
local RoleModule = require(script.Parent:WaitForChild("SelectRoleModule"))

-------- Communication (Bindables)
-- This Bindable allows other server scripts to trigger the role selection process
local Bindables = ServerStorage:WaitForChild("Bindables")
local GetRoles = Bindables.RoleSelectorSystem:WaitForChild("GetRoles")

-------- Event Listeners

--- Initializes new players with the default 'Innocent' attribute
Players.PlayerAdded:Connect(function(player)
	RoleModule.AddInnocentAttribute(player)
end)

--- Callback for the BindableFunction
-- Returns a dictionary: { [PlayerName] = Role }
GetRoles.OnInvoke = function()
	local rolesTable = RoleModule.SelectRole()
	
	-- Optional: Logging for debug purposes (can be removed for production)
	print("Roles have been assigned for the current round.")
	
	return rolesTable
end