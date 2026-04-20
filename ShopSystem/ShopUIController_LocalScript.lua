-- [[ SHOP UI CONTROLLER | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Manages the Shop frontend, including dynamic item generation, 
-- purchasing, and the Equip/Unequip system.

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // UI ELEMENTS
local mainFrame = script.Parent.Frame
local exitButton = script.Parent.ExitButton
local moneyLabel = script.Parent.MoneyLabel
local proximityPrompt = workspace:WaitForChild("Lobby").Seller.Prompt

-- // REMOTES
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopEvents = Remotes.Events.ShopSystem
local ShopFunctions = Remotes.Functions.ShopSystem
local RoundFunctions = Remotes.Functions.RoundSystem

-- // 1. UI VISIBILITY CONTROL

proximityPrompt.Triggered:Connect(function()
	mainFrame.Visible = true
	exitButton.Visible = true
	moneyLabel.Visible = true
	ShopEvents.OpenedGUI:FireServer()
end)

exitButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	exitButton.Visible = false
	moneyLabel.Visible = false
end)

-- // 2. DYNAMIC ITEM GENERATION

local gearList = ReplicatedStorage:WaitForChild("Gears"):GetChildren()
local gearTemplate = ReplicatedStorage:WaitForChild("GUIsTemplate").ShopGUI.GearFrame

for _, gear in pairs(gearList) do
	local newFrame = gearTemplate:Clone()
	newFrame.Name = gear.Name
	newFrame.GearName.Text = gear.Name
	newFrame.GearIcon.Image = gear.TextureId
	newFrame.Parent = mainFrame
	
	local equipBtn = newFrame.EquipButton
	local unequipBtn = newFrame.UnequipButton
	local buyBtn = newFrame.BuyButton
	local warnLabel = newFrame.WarnLabel
	
	-- // EQUIP / UNEQUIP LOGIC
	equipBtn.MouseButton1Click:Connect(function()
		if RoundFunctions.EquipGear:InvokeServer(gear) then
			equipBtn.Visible = false
			unequipBtn.Visible = true
		end
	end)
	
	unequipBtn.MouseButton1Click:Connect(function()
		if RoundFunctions.UnequipGear:InvokeServer(gear) then
			equipBtn.Visible = true
			unequipBtn.Visible = false
		end
	end)
	
	-- // PURCHASE LOGIC
	buyBtn.MouseButton1Click:Connect(function()
		local success = ShopFunctions.BuyItem:InvokeServer(gear)
		
		if not success then
			warnLabel.Visible = true
			warnLabel.Text = "Cannot afford or error!"
			task.delay(2, function() warnLabel.Visible = false end)
		end
	end)
end

-- // 3. DATA SYNCHRONIZATION (Server -> Client)

-- Updates button states (Buy vs Equip) and prices based on server data
ShopEvents.UpdateGUI.OnClientEvent:Connect(function(ownedItems, itemPrices)
	for _, gear in pairs(gearList) do
		local itemFrame = mainFrame:FindFirstChild(gear.Name)
		if itemFrame then
			local isOwned = ownedItems[gear.Name] == true
			
			itemFrame.BuyButton.Visible = not isOwned
			itemFrame.EquipButton.Visible = isOwned
			itemFrame.PriceLabel.Visible = not isOwned
			
			if itemPrices[gear.Name] then
				itemFrame.PriceLabel.Text = "Price: $" .. itemPrices[gear.Name]
			end
		end
	end
end)

-- // 4. CURRENCY DISPLAY

local function updateMoney(value)
	moneyLabel.Text = "Cash: $" .. tostring(value)
end

-- Update via Leaderstats change or Direct Remote
player:WaitForChild("leaderstats").Cash.Changed:Connect(updateMoney)
ShopEvents.UpdateMoneyGUI.OnClientEvent:Connect(updateMoney)