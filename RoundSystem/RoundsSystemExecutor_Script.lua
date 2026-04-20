-- [[ ROUND SYSTEM EXECUTOR | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Handles the main game loop, player teleports, map lifecycle, and winners.
-- This script connects the RoundModule logic with the actual Game World.

local RoundModule = require(game.ServerScriptService.RoundSystem.RoundModule)
local DataManager = require(game.ServerScriptService.DataSaveSystem.Data.DataManager)

-- // SERVICES & REMOTES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Events = Remotes.Events.RoundSystem
local Functions = Remotes.Functions.RoundSystem

local actualizeGUI = Events.ActualizeGUI
local equipgear = Functions.EquipGear
local unequipgear = Functions.UnequipGear

-- // VARIABLES
local lastwinner = nil
local lastmatchtie = false
local actualmap = nil
local alivePlayers = {}

-- // 1. PLAYER SESSION MANAGEMENT

-- Track alive players and handle deaths
local function SetUpTable()
	for _, player in ipairs(game.Players:GetPlayers()) do
		if not table.find(alivePlayers, player) then 
			table.insert(alivePlayers, player)
		end
		
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		
		humanoid.Died:Connect(function()
			local index = table.find(alivePlayers, player)
			if index then
				table.remove(alivePlayers, index)
			end
		end)
	end
end

-- // 2. GEAR SYSTEM HANDLERS

local function GiveGears()
	local sessionPlayers = RoundModule.GetPlayers()
	for player, data in pairs(sessionPlayers) do
		local gear = data.EquippedGear
		if gear then
			gear:Clone().Parent = player.Backpack
		end
	end
end

local function RemoveGears()
	local sessionPlayers = RoundModule.GetPlayers()
	for player, data in pairs(sessionPlayers) do
		local gear = data.EquippedGear
		if gear then
			local backpackGear = player.Backpack:FindFirstChild(gear.Name)
			local charGear = player.Character:FindFirstChild(gear.Name)
			if backpackGear then backpackGear:Destroy() end
			if charGear then charGear:Destroy() end
		end
	end
end

-- // 3. MAP & WORLD MANAGEMENT

local function ChooseMap()
	local map = RoundModule.ChooseMap()
	if map then
		actualmap = map:Clone()
		actualmap.Parent = workspace
		print("Map chosen: " .. map.Name)
		return map.Name
	end
end

local function DestroyMap()
	if actualmap then
		actualmap:Destroy()
		actualmap = nil
	end
end

-- // 4. TELEPORT & UTILS

local function TPToLobby()
	local lobby = workspace:WaitForChild("Lobby")
	local spawnCF = lobby.SpawnLocation.CFrame
	
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character:PivotTo(spawnCF + Vector3.new(0, 5, 0))
		end
	end
end

local function TPToMap(spawns: Folder)
	local spawnPoints = spawns:GetChildren()
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local randomSpawn = spawnPoints[math.random(1, #spawnPoints)]
			player.Character:PivotTo(randomSpawn.CFrame + Vector3.new(0, 5, 0))
		end
	end
end

-- // 5. ROUND STATES (THE LOOP)

local function OnLobby()
	local duration = 10
	while duration > 0 do
		duration -= 1
		local playerCount = #game.Players:GetPlayers()
		
		if playerCount < 2 then
			actualizeGUI:FireAllClients(RoundModule.States.OnLobby, duration, nil, lastwinner, false, true)
			duration = 10 -- Reset intermission if not enough players
		else
			actualizeGUI:FireAllClients(RoundModule.States.OnLobby, duration)
			if duration == 0 then RoundModule.ChangeState(RoundModule.States.OnIntermission) end
		end
		task.wait(1)
	end
end

local function OnIntermission()
	local mapName = ChooseMap()
	local duration = 3
	while duration > 0 do
		duration -= 1
		actualizeGUI:FireAllClients(RoundModule.States.OnIntermission, duration, mapName)
		if duration == 0 then
			SetUpTable()
			TPToMap(actualmap.Spawns)
			GiveGears()
			RoundModule.ChangeState(RoundModule.States.OnRound)
		end
		task.wait(1)
	end
end

local function OnRound()
	local duration = 10 -- Adjust as needed
	while duration > 0 do
		duration -= 1
		actualizeGUI:FireAllClients(RoundModule.States.OnRound, duration)
		
		if #alivePlayers == 1 then
			lastwinner = alivePlayers[1]
			DataManager.AddWin(lastwinner, 1)
			lastmatchtie = false
			RoundModule.ChangeState(RoundModule.States.OnEnd)
			break
		elseif duration == 0 or #alivePlayers == 0 then
			lastmatchtie = true
			lastwinner = nil
			RoundModule.ChangeState(RoundModule.States.OnEnd)
			break
		end
		task.wait(1)
	end
end

local function OnEnd()
	local duration = 3
	RemoveGears()
	alivePlayers = {}
	TPToLobby()
	
	while duration > 0 do
		duration -= 1
		actualizeGUI:FireAllClients(RoundModule.States.OnEnd, duration, actualmap, lastwinner, lastmatchtie)
		if duration == 0 then
			DestroyMap()
			RoundModule.ChangeState(RoundModule.States.OnLobby)
		end
		task.wait(1)
	end
end

-- // 6. MAIN GAME LOOP
while true do
	local state = RoundModule.ActiveState
	if state == RoundModule.States.OnLobby then OnLobby()
	elseif state == RoundModule.States.OnIntermission then OnIntermission()
	elseif state == RoundModule.States.OnRound then OnRound()
	elseif state == RoundModule.States.OnEnd then OnEnd()
	end
	task.wait(0.1)
end