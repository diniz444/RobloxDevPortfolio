-- [[ ROUND DISPLAY CONTROLLER | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Updates the main game status label based on server-side round states.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local roundLabel = script.Parent

-- // REMOTES
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local actualizeGUI = Remotes.Events.RoundSystem.ActualizeGUI

-- // CORE LOGIC
-- Listen for state updates from the Server Round Executor
actualizeGUI.OnClientEvent:Connect(function(state, duration, mapName, lastWinner, gameEndedOnTie, waitingForPlayers)
	
	if state == "OnLobby" then
		if waitingForPlayers then
			roundLabel.Text = "Waiting For Players..."
		else
			roundLabel.Text = "Intermission: " .. duration .. " seconds"
		end	
		
	elseif state == "OnIntermission" then
		local mapDisplay = mapName or "TBD"
		roundLabel.Text = "Map: " .. mapDisplay .. " | Starting in " .. duration .. "s"
		
	elseif state == "OnRound" then	
		roundLabel.Text = "Game ending in " .. duration .. " seconds"
		
	elseif state == "OnEnd" then
		if gameEndedOnTie then
			roundLabel.Text = "The game ended on a tie!"
		elseif lastWinner then
			roundLabel.Text = "Winner: " .. lastWinner.Name
		else
			roundLabel.Text = "Round Over"
		end
	end
end)