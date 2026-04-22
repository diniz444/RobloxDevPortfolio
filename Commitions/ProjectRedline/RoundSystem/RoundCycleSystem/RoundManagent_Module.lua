-- [[ ROUND MANAGEMENT MODULE | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Core state machine and utility functions for game cycle control.
-- Usage: Require this module in the Server Executor to manage round transitions and time formatting.
-- "Veni, Vidi, Vici."

local RoundModule = {}

------- State Control

--- Table storing all possible game states
RoundModule.States = {
	[`Intermission`] = `Intermission`,
	[`Waiting`] = `Waiting`,
	[`Cutscene`] = `Cutscene`,
	[`OnGame`] = `OnGame`,
	[`Ending`] = `Ending`,
}

--- Stores the current game state (Defaults to Intermission)
RoundModule.CurrentState = RoundModule.States.Intermission

--- Function to handle state transitions
RoundModule.ChangeState = function(newState: string)
	-- Validates if the state exists and prevents redundant transitions
	if RoundModule.States[newState] and RoundModule.CurrentState ~= newState then
		RoundModule.CurrentState = newState
		print(`Current State: {RoundModule.CurrentState}`)
	end
end

------ Time Formatting (Min:Sec)

function RoundModule.FormatDuration(seconds: number)
	-- Divides seconds into 60-second groups (e.g., 240s = 4m)
	local minutes = math.floor(seconds / 60)

	-- Calculates the remainder (e.g., 125s / 60 = 2m, 5s remainder)
	local remainder = seconds % 60

	-- Returns formatted string as "m:ss"
	return string.format(`%d:%02d`, minutes, remainder)
end

return RoundModule