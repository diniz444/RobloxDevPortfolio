-- [[ ROLL UI INTERFACE | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Manages user input on the client-side and displays server-calculated RNG results.
-- "Cogito, ergo sum."

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- UI Elements
local RollButton = script.Parent:WaitForChild("RollButton")
local RolledText = script.Parent:WaitForChild("RolledLabel")

-- Communication Bridge
local RollFunction = ReplicatedStorage:WaitForChild("RollFunction")

local LocalPlayer = Players.LocalPlayer
local debounce = false

--- Listens for the button click to trigger the RNG process
RollButton.MouseButton1Click:Connect(function()
	-- Prevents multiple requests (spamming) while waiting for the server
	if debounce then return end
	debounce = true
	
	-- Invokes the server and waits for the RNG result
	local result = RollFunction:InvokeServer()
	
	if result and result.selectedFruit and result.selectedData then
		local fruitName = result.selectedFruit
		local fruitRarity = result.selectedData.Rarity
		
		-- Updates the UI with a formatted string
		RolledText.Text = string.format("%s rolled a %s %s!", LocalPlayer.Name, fruitName, fruitRarity)
	else
		warn("Failed to retrieve roll result from server.")
	end
	
	-- Anti-spam cooldown
	task.wait(0.5)
	debounce = false
end)