-- [[ UI STATE SYNCHRONIZER | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Client-side controller to sync Game State and Timer values with the HUD.
-- Usage: Place as a LocalScript inside the ScreenGui/MainFrame.
-- "Veni, Vidi, Vici."

-------- VARIABLES

-- Data Values (ReplicatedStorage)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CycleVal = ReplicatedStorage:WaitForChild("Values"):WaitForChild("RoundCycleSystem").CycleVal

local StateValue = CycleVal:WaitForChild("State")
local TimerValue = CycleVal:WaitForChild("Timer")

-- UI Elements
local StateText = script.Parent:WaitForChild("StateText")
local TimerText = script.Parent:WaitForChild("TimerText")

----FUNCTIONS

local function UpdateStateUI(val)
		-- Updates the HUD label based on the current state
	if val == "Intermission" then
		StateText.Text = "On Intermission"

	elseif val == "Cutscene" then
		StateText.Text = "On Cutscene"

	elseif val == "OnGame" then
		StateText.Text = "On Game"

	elseif val == "Ending" then
		StateText.Text = "On Ending"
		
	elseif val == "Waiting" then
		StateText.Text = `Waiting for more players`
	end
end

local function UpdateTimerUI(val)
	-- Directly displays the formatted MM:SS string sent by the server
	TimerText.Text = val
end

-------- EVENTS

--- Syncs the UI text whenever the Game State changes
StateValue.Changed:Connect(UpdateStateUI)

--- Syncs the timer display whenever the time value is updated by the server
TimerValue.Changed:Connect(UpdateTimerUI)

UpdateStateUI(StateValue.Value)

UpdateTimerUI(TimerValue.Value)