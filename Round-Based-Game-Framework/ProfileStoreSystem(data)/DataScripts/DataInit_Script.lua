-- [[ DATA INITIALIZER SYSTEM | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Robust data management system using ProfileService for fail-safe saving.
-- Usage: Place this script in ServerScriptService and ensure Libraries/Data folders exist.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- // CONFIGURATION & PATHS
-- Change these paths if you organize your folders differently
local LIBRARIES_FOLDER = ServerScriptService:WaitForChild("DataSaveSystem"):WaitForChild("Libraries")
local DATA_FOLDER = ServerScriptService:WaitForChild("DataSaveSystem"):WaitForChild("DataScripts")

local ProfileStoreModule = require(LIBRARIES_FOLDER:WaitForChild("ProfileStore"))
local DataTemplate = require(DATA_FOLDER:WaitForChild("Template"))
local DataManager = require(DATA_FOLDER:WaitForChild("DataManager"))

-- // SYSTEM SETTINGS
-- Automatically switches between Test and Live data keys to prevent Studio testing from overwriting real player data.
local function GetDataScope()
	return RunService:IsStudio() and "TestData_v1" or "ProductionData_v1"
end

local PlayerProfileStore = ProfileStoreModule.New(GetDataScope(), DataTemplate)

-- // PLAYER INITIALIZATION
-- Handles the creation of Leaderstats and game-specific value objects.
local function InitializePlayer(player: Player, profile)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Helper function to create ValueObjects quickly
	local function createValue(name, value, parent)
		local valObj = Instance.new("IntValue")
		valObj.Name = name
		valObj.Value = value
		valObj.Parent = parent
		return valObj
	end

	-- Initializing leaderstats from Profile Data
	createValue("Kills", profile.Data.Kills or 0, leaderstats)
	createValue("Wins", profile.Data.Wins or 0, leaderstats)
	createValue("Cash", profile.Data.Cash or 0, leaderstats)
end

-- // SESSION MANAGEMENT
local function OnPlayerAdded(player: Player)
	local profile = PlayerProfileStore:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,	
	})
	
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- Compliance with GDPR/Data Rights
		profile:Reconcile() -- Fills in missing data if the Template is updated
		
		-- Handles unexpected session ends (e.g. server crashes)
		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[player] = nil
			player:Kick("Data session ended unexpectedly. Please rejoin.")
		end)
	
		if player.Parent == Players then
			DataManager.Profiles[player] = profile
			InitializePlayer(player, profile)
		else
			profile:EndSession()
		end
	else
		-- If profile is already being used in another server (Session Locking)
		player:Kick("Data Error: Your data is currently locked in another server session.")
	end
end

-- // CONNECTIONS
-- Handle players already in the server (Studio testing or late script execution)
for _, player in Players:GetPlayers() do
	task.spawn(OnPlayerAdded, player)
end

Players.PlayerAdded:Connect(OnPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = DataManager.Profiles[player]
	if profile then
		profile:EndSession()
		DataManager.Profiles[player] = nil
	end
end)

print("[DataInit]: System loaded successfully.")