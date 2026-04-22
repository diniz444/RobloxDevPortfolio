-- [[ MAP MANAGER SYSTEM | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Handles map lifecycle (Cloning/Destroying) via BindableEvents.
-- "Cogito, ergo sum."

-- [[ SERVICES ]]
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [[ MODULES ]]
local MapSelectorModule = require(script.Parent:WaitForChild("MapSelectorModule"))

-- [[ VARIABLES ]]
local actualMap = nil -- Reference to the currently active map in Workspace

-- [[ BINDABLES ]]
local BindablesFolder = ServerStorage:WaitForChild("Bindables")
local MapSystemEvents = BindablesFolder:WaitForChild("MapSelectorSystem")

local GetMapEvent = MapSystemEvents:WaitForChild("GetMap")
local DestroyMapEvent = MapSystemEvents:WaitForChild("DestroyMap")

-- [[ FUNCTIONS ]]

--- Selects a random map from the module, clones it, and places it in Workspace.
local function OnChooseMap()
	-- Prevent overlapping maps if one already exists
	if actualMap then
		actualMap:Destroy()
	end

	local mapTemplate = MapSelectorModule.GetRandomMap()
	
	if mapTemplate then
		actualMap = mapTemplate:Clone()
		actualMap.Name = "ActiveMap" -- Standardizing name for internal logic if needed
		actualMap.Parent = workspace
		
		print("📦 Map System: Successfully loaded [" .. mapTemplate.Name .. "]")
	else
		warn("⚠️ Map System: Failed to retrieve a map from Module.")
	end
end

--- Cleans up the current map from Workspace.
local function OnDeleteMap()
	if actualMap then
		local mapName = actualMap.Name
		actualMap:Destroy()
		actualMap = nil
		
		print("🧹 Map System: Map cleared.")
	else
		print("ℹ️ Map System: No map to delete.")
	end
end

-- [[ CONNECTIONS ]]

-- Listen for signals from the Round System
GetMapEvent.Event:Connect(OnChooseMap)
DestroyMapEvent.Event:Connect(OnDeleteMap)