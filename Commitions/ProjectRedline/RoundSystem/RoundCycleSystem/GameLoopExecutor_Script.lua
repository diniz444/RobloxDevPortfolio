-- [[ GAME LOOP EXECUTOR | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Central game loop that coordinates state transitions and round logic.
-- Usage: Place in ServerScriptService. Dependent on RoundModule and Timer/State Values.
-- "Veni, Vidi, Vici."

-- ta tudo em ingles pra deixar aesthetic kdslhdioshfiohdih

-------- Variables
local RoundModule = require(script.Parent.RoundModule)

local GetMap = game.ServerStorage.Bindables.MapSelectorSystem:WaitForChild(`GetMap`)

local DestroyMap = game.ServerStorage.Bindables.MapSelectorSystem:WaitForChild(`DestroyMap`)

local TimerValue = game.ReplicatedStorage:WaitForChild(`Values`).RoundCycleSystem.CycleVal.Timer
local StateValue = game.ReplicatedStorage:WaitForChild(`Values`).RoundCycleSystem.CycleVal.State

local MinPlayers = 2

---------- State Functions

--- Intermission logic
local function Intermission()
	if RoundModule.CurrentState == RoundModule.States.Intermission then
		local Duration = 50 -- Customizable duration

		for i = Duration, 0, -1 do
			Duration = i

			-- Syncs state value to GUI at the start of the countdown
			if Duration == 49 then
				StateValue.Value = RoundModule.CurrentState
			end

			local minutes = RoundModule.FormatDuration(Duration)
			TimerValue.Value = minutes

			print(`On ` .. StateValue.Value .. ` for ` .. minutes)
			task.wait(1)
		end

		if Duration == 0 then
			-- Logic to execute when intermission ends
			RoundModule.ChangeState(RoundModule.States.Cutscene)
			StateValue.Value = RoundModule.States.Cutscene
		end
	end
end

--- Transition/Cutscene logic
local function Transition()
	if RoundModule.CurrentState == RoundModule.States.Cutscene then
		local Duration = 5 -- Valor placeholder
		
		GetMap:Fire()
		
		for i = Duration, 0, -1 do
			Duration = i
			local minutes = RoundModule.FormatDuration(Duration)
			TimerValue.Value = minutes

			print(`On ` .. StateValue.Value .. ` for ` .. minutes)
			task.wait(1)
		end

		if Duration == 0 then
			RoundModule.ChangeState(RoundModule.States.OnGame)
			StateValue.Value = RoundModule.States.OnGame
		end
	end
end

--- Main Game logic
local function OnGame()
	if RoundModule.CurrentState == RoundModule.States.OnGame then
		local Duration = 300

		for i = Duration, 0, -1 do
			Duration = i
			local minutes = RoundModule.FormatDuration(Duration)
			TimerValue.Value = minutes

			print(`On ` .. StateValue.Value .. ` for ` .. minutes)
			task.wait(1)
		end

		if Duration == 0 then
			RoundModule.ChangeState(RoundModule.States.Ending)
			StateValue.Value = RoundModule.States.Ending
		end
	end
end

--- Round Ending logic
local function Ending()
	if RoundModule.CurrentState == RoundModule.States.Ending then
		local Duration = 5

		for i = Duration, 0, -1 do
			Duration = i
			local minutes = RoundModule.FormatDuration(Duration)
			TimerValue.Value = minutes

			print(`On ` .. StateValue.Value .. ` for ` .. minutes)
			task.wait(1)
		end

		if Duration == 0 then
			DestroyMap:Fire()
			RoundModule.ChangeState(RoundModule.States.Intermission)
			StateValue.Value = RoundModule.States.Intermission
		end
	end
end

----- Main Game Loop (The Core)

while true do
	task.wait(1)

	-- [[ SECURITY CHECK | WAITING FOR PLAYERS ]]
	if #game.Players:GetPlayers() < MinPlayers then
		
		
		
		if StateValue.Value ~= "Waiting" then
			RoundModule.ChangeState(RoundModule.States.Waiting)
			
			StateValue.Value = RoundModule.States.Waiting
			TimerValue.Value = "00:00"

			print("Waiting for more players to join...")
		end
		
	

		continue 
	end
	
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