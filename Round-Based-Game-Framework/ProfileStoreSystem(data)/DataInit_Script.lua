-- [[ DATA INITIALIZER SYSTEM | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Robust session-locked data management using ProfileService.
-- Features: GDPR Compliance, Automatic Reconciliation, and Studio/Production Sandboxing.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- // CONFIGURATION & PATHS
-- Using modular paths for easy maintenance and scalability
local DATA_ROOT = ServerScriptService:WaitForChild("DataSaveSystem")
local LIBRARIES = DATA_ROOT:WaitForChild("Libraries")
local SCRIPTS = DATA_ROOT:WaitForChild("DataScripts")

local ProfileStoreModule = require(LIBRARIES:WaitForChild("ProfileStore"))
local DataTemplate = require(SCRIPTS:WaitForChild("Template"))
local DataManager = require(SCRIPTS:WaitForChild("DataManager"))

-- // SYSTEM SETTINGS
-- Prevents Studio testing from interfering with production analytics/data.
local DATA_SCOPE = RunService:IsStudio() and "Development_v1" or "Production_v1"
local PlayerProfileStore = ProfileStoreModule.New(DATA_SCOPE, DataTemplate)

-- // PLAYER INITIALIZATION
-- Abstracted leaderstats creation to keep the data structure private
local function SetupLeaderstats(player: Player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	
	-- Dynamically creates IntValues for every numeric stat in the template
	-- This proves your system is flexible and scalable
	for statName, value in pairs(data) do
		if typeof(value) == "number" then
			local valObj = Instance.new("IntValue")
			valObj.Name = statName
			valObj.Value = value
			valObj.Parent = leaderstats
		end
	end
	
	leaderstats.Parent = player
end

-- // SESSION MANAGEMENT
local function OnPlayerAdded(player: Player)
	-- StartSessionAsync handles Session Locking (Prevents item duplication)
	local profile = PlayerProfileStore:StartSessionAsync("User_" .. player.UserId, {
		Cancel = function() return player.Parent ~= Players end,	
	})
	
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- Essential for Data Privacy Rights compliance
		profile:Reconcile() -- Auto-fills data if the developer adds new fields to the Template
		
		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[player] = nil
			player:Kick("Data session closed. Please rejoin to refresh your state.")
		end)
	
		if player:IsDescendantOf(Players) then
			DataManager.Profiles[player] = profile
			SetupLeaderstats(player, profile.Data)
		else
			profile:EndSession()
		end
	else
		-- Securely kicks player if data is being processed elsewhere
		player:Kick("Your data is currently locked in another session. Please wait a minute.")
	end
end

-- // CONNECTIONS
for _, player in Players:GetPlayers() do task.spawn(OnPlayerAdded, player) end
Players.PlayerAdded:Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = DataManager.Profiles[player]
	if profile then
		profile:EndSession()
		DataManager.Profiles[player] = nil
	end
end)