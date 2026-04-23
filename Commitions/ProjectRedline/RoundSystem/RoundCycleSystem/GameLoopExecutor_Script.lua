-- [[ ROUND EXECUTOR | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Date: April 23, 2026
-- Description: Central game loop that coordinates state transitions, map selection, and role assignment.
-- "Veni, Vidi, Vici."

-------- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-------- Modules
local RoundModule = require(script.Parent:WaitForChild("RoundModule"))

-------- Communication (Bindables)
local Bindables = ServerStorage:WaitForChild("Bindables")
local GetMap = Bindables.MapSelectorSystem:WaitForChild("GetMap")
local DestroyMap = Bindables.MapSelectorSystem:WaitForChild("DestroyMap")
local GetRoles = Bindables.RoleSelectorSystem:WaitForChild("GetRoles")

-------- Values & Config
local Values = ReplicatedStorage:WaitForChild("Values").RoundCycleSystem.CycleVal
local TimerValue = Values.Timer
local StateValue = Values.State

local MinPlayers = 2

-------- Utility Functions

--- Handles the physical teleportation of players based on their assigned roles
local function SpawnPlayers(rolesInfo, Map)
	if not Map or not Map:FindFirstChild("Spawns") then 
		warn("CRITICAL: Map or Spawns folder missing!")
		return 
	end

	local survivorSpawns = Map.Spawns.SurvivorSpawns:GetChildren()
	local killerSpawns = Map.Spawns.KillerSpawns:GetChildren()
	
	-- Get the first available killer spawn point from the table
	local killerSpawnPoint = killerSpawns[1]

	for playerName, role in pairs(rolesInfo) do
		local player = Players:FindFirstChild(playerName)

		if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart

			if role == "Killer" and killerSpawnPoint then
				hrp.CFrame = killerSpawnPoint.CFrame + Vector3.new(0, 3, 0)
			elseif role == "Innocent" or role == "Survivor" then
				local randomSpawn = survivorSpawns[math.random(1, #survivorSpawns)]
				if randomSpawn then
					hrp.CFrame = randomSpawn.CFrame + Vector3.new(0, 3, 0)
				end
			end
		end
	end
end

---------- State Functions

--- Intermission logic: Waiting for the round to start
local function Intermission()
	if RoundModule.CurrentState == RoundModule.States.Intermission then
		local Duration = 50 

		for i = Duration, 0, -1 do
			if i == 49 then StateValue.Value = RoundModule.CurrentState end
			TimerValue.Value = RoundModule.FormatDuration(i)
			task.wait(1)
		end

		RoundModule.ChangeState(RoundModule.States.Cutscene)
		StateValue.Value = RoundModule.States.Cutscene
	end
end

--- Transition logic: Selecting map, assigning roles, and spawning players
local function Transition()
	if RoundModule.CurrentState == RoundModule.States.Cutscene then
		local rolesTable = GetRoles:Invoke() 
		local map = GetMap:Invoke()         
		
		SpawnPlayers(rolesTable, map)
		
		local Duration = 5 
		for i = Duration, 0, -1 do
			TimerValue.Value = RoundModule.FormatDuration(i)
			task.wait(1)
		end

		RoundModule.ChangeState(RoundModule.States.OnGame)
		StateValue.Value = RoundModule.States.OnGame
	end
end

--- Main Game logic: Active round countdown
local function OnGame()
	if RoundModule.CurrentState == RoundModule.States.OnGame then
		local Duration = 300

		for i = Duration, 0, -1 do
			TimerValue.Value = RoundModule.FormatDuration(i)
			task.wait(1)
		end

		RoundModule.ChangeState(RoundModule.States.Ending)
		StateValue.Value = RoundModule.States.Ending
	end
end

--- Round Ending logic: Cleaning up and resetting
local function Ending()
	if RoundModule.CurrentState == RoundModule.States.Ending then
		local Duration = 5
		for i = Duration, 0, -1 do
			TimerValue.Value = RoundModule.FormatDuration(i)
			task.wait(1)
		end

		DestroyMap:Fire()
		RoundModule.ChangeState(RoundModule.States.Intermission)
		StateValue.Value = RoundModule.States.Intermission
	end
end

---------- Main Game Loop

while true do
	task.wait(1)

	local currentPlayers = Players:GetPlayers()

	-- Security check for minimum player count
	if #currentPlayers < MinPlayers then
		if StateValue.Value ~= "Waiting" then
			RoundModule.ChangeState(RoundModule.States.Waiting)
			StateValue.Value = "Waiting"
			TimerValue.Value = "00:00"
			print("Waiting for more players...")
		end
		continue 
	end
	
	-- Start the cycle if players are ready
	if RoundModule.CurrentState == RoundModule.States.Waiting then
		RoundModule.ChangeState(RoundModule.States.Intermission)
	end
		
	-- State Orchestrator
	if RoundModule.CurrentState == RoundModule.States.Intermission then
		Intermission()
	elseif RoundModule.CurrentState == RoundModule.States.Cutscene then
		Transition()
	elseif RoundModule.CurrentState == RoundModule.States.OnGame then
		OnGame()
	elseif RoundModule.CurrentState == RoundModule.States.Ending then
		Ending()
	end
end