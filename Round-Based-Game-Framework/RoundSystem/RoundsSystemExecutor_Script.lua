-- [[ ROUND SYSTEM ORCHESTRATOR | FRAMEWORK VERSION ]]
-- Author: [diniz444]
-- Description: High-level game loop controller. Handles state transitions, 
-- session life-cycles, and environmental cleanup.

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // DEPENDENCIES
-- Paths are kept relative to showcase modular architecture
local RoundModule = require(script.Parent:WaitForChild("RoundModule"))
local DataManager = require(script.Parent.Parent:WaitForChild("DataManager"))

-- // CONFIGURATION & NETWORKING
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RoundEvents = Remotes:WaitForChild("Events"):WaitForChild("RoundSystem")
local UpdateUI = RoundEvents:WaitForChild("ActualizeGUI")

-- // SESSION VARIABLES
local currentMap = nil
local activeContestants = {}
local lastMatchResult = {Winner = nil, IsTie = false}

-- // 1. CONTESTANT MANAGEMENT
local function InitializeSession()
	table.clear(activeContestants)
	
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(activeContestants, player)
		
		-- Logic to handle mid-round elimination
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		
		humanoid.Died:Once(function()
			local index = table.find(activeContestants, player)
			if index then table.remove(activeContestants, index) end
		end)
	end
end

-- // 2. WORLD LOGIC
local function DeployEnvironment()
	local mapTemplate = RoundModule.ChooseMap()
	if mapTemplate then
		currentMap = mapTemplate:Clone()
		currentMap.Parent = workspace
		return mapTemplate.Name
	end
end

local function CleanupEnvironment()
	if currentMap then
		currentMap:Destroy()
		currentMap = nil
	end
end

-- // 3. STATE HANDLERS (The Orquestration)

local function HandleLobby()
	local timer = 15
	while timer > 0 do
		timer -= 1
		local playerCount = #Players:GetPlayers()
		
		-- UI Sync: Passing state, timer, and requirement status
		UpdateUI:FireAllClients(RoundModule.States.OnLobby, timer, nil, nil, false, playerCount < 2)
		
		if playerCount >= 2 and timer == 0 then
			RoundModule.ChangeState(RoundModule.States.OnIntermission)
		elseif playerCount < 2 then
			timer = 15 -- Reset countdown if requirements aren't met
		end
		task.wait(1)
	end
end

local function HandleIntermission()
	local mapName = DeployEnvironment()
	local timer = 5
	
	while timer > 0 do
		timer -= 1
		UpdateUI:FireAllClients(RoundModule.States.OnIntermission, timer, mapName)
		
		if timer == 0 then
			InitializeSession()
			-- Abstracted: Teleportation and Gear distribution logic goes here
			RoundModule.ChangeState(RoundModule.States.OnRound)
		end
		task.wait(1)
	end
end

local function HandleRound()
	local timer = 120 -- Default round duration
	while timer > 0 do
		timer -= 1
		UpdateUI:FireAllClients(RoundModule.States.OnRound, timer)
		
		-- Win Condition Check
		if #activeContestants <= 1 then
			lastMatchResult.Winner = activeContestants[1]
			lastMatchResult.IsTie = (#activeContestants == 0)
			
			if lastMatchResult.Winner then
				DataManager.UpdateStat(lastMatchResult.Winner, "Wins", 1)
			end
			
			RoundModule.ChangeState(RoundModule.States.OnEnd)
			break
		end
		task.wait(1)
	end
end

local function HandleEnd()
	local timer = 5
	-- Abstracted: Post-round cleanup (Teleport to lobby, Unequip gears)
	
	while timer > 0 do
		timer -= 1
		UpdateUI:FireAllClients(RoundModule.States.OnEnd, timer, nil, lastMatchResult.Winner, lastMatchResult.IsTie)
		
		if timer == 0 then
			CleanupEnvironment()
			RoundModule.ChangeState(RoundModule.States.OnLobby)
		end
		task.wait(1)
	end
end

-- // 4. MAIN ENGINE
-- Using a robust state-check loop to drive the game
while true do
	local currentState = RoundModule.ActiveState
	
	if currentState == RoundModule.States.OnLobby then HandleLobby()
	elseif currentState == RoundModule.States.OnIntermission then HandleIntermission()
	elseif currentState == RoundModule.States.OnRound then HandleRound()
	elseif currentState == RoundModule.States.OnEnd then HandleEnd()
	end
	
	task.wait(0.5)
end