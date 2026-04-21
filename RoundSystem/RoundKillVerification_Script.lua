-- [[ KILL VERIFICATION SYSTEM | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Detects player deaths via 'creator' tags and rewards the killer.
-- This script integrates with DataManager to persist kill statistics.

local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataSaveSystem.Data.DataManager)

-- // CORE LOGIC

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		
		if humanoid then
			humanoid.Died:Connect(function()
				-- Search for the 'creator' tag usually inserted by weapons/tools
				local tag = humanoid:FindFirstChild("creator")
				
				if tag and tag.Value then
					local killer = tag.Value
					
					-- Ensure the killer is a Player and not themselves (Reset)
					if killer:IsA("Player") and killer ~= player then
						DataManager.AddKill(killer, 1) -- Dá a kill para o assassino
						print("Confirmed: " .. killer.Name .. " eliminated " .. player.Name)
					end
				end
			end)
		end
	end)
end)