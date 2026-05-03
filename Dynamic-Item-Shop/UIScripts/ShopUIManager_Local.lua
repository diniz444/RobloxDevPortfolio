-- [[ DYNAMIC ITEM SHOP | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Client-side controller for the dynamic shop system. 
-- Handles UI generation, purchase requests, and visual/audio feedback.

---- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

---- UI ELEMENTS
local scrollFrame = script.Parent:WaitForChild("ScrollingFrame")
local itemTemplate = ReplicatedStorage:WaitForChild("Template")

---- DATA & COMMUNICATION
local itemsFolder = ReplicatedStorage:WaitForChild("ShopItens") 
local buyRemote = ReplicatedStorage:WaitForChild("Buy")

---- VISUAL EFFECTS (TWEENING REMOTES)
local hoverUpEvent = ReplicatedStorage:WaitForChild("PropUP")
local hoverDownEvent = ReplicatedStorage:WaitForChild("PropDOWN")

---- AUDIO ASSETS
local successSound = SoundService:WaitForChild("BuySound")
local errorSound = SoundService:WaitForChild("ErrorSound")

---- CORE LOGIC: DYNAMIC SHOP GENERATION
for _, itemData in ipairs(itemsFolder:GetChildren()) do
	
	-- Setup Template Clone
	local newSlot = itemTemplate:Clone()
	local isSuccess = nil
	
	local labelItemName = newSlot:FindFirstChild("ItemName")
	local labelPrice = newSlot:FindFirstChild("PriceName")
	local imageIcon = newSlot:FindFirstChild("ItemImage")
	local btnBuy = newSlot:FindFirstChild("BuyButton")
	local labelBought = newSlot:FindFirstChild("Bought")
	
	-- Apply Item Data
	newSlot.Name = itemData.Name
	labelItemName.Text = itemData.Name
	
	local imageID = itemData:GetAttribute("ImageID") -- Handled as string from attributes
	local priceValue = itemData:GetAttribute("Price")
	
	labelPrice.Text = "R$ " .. tostring(priceValue) 
	imageIcon.Image = "rbxassetid://" .. imageID
	
	newSlot.Parent = scrollFrame
	
	---- PURCHASE INTERACTION
	btnBuy.MouseButton1Click:Connect(function()
		-- Invoke Server to validate purchase
		isSuccess = buyRemote:InvokeServer(itemData.Name)
		
		if isSuccess then
			-- Success Feedback
			successSound:Play()
			
			btnBuy.Visible = false
			btnBuy.Active = false
			labelBought.Visible = true
		else
			-- Error Feedback (Insufficient Funds)
			errorSound:Play()
			
			btnBuy.Text = "NOT ENOUGH CASH"
			btnBuy.Active = false
			btnBuy.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
			
			task.delay(2, function()
				btnBuy.Text = "BUY"
				btnBuy.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
				btnBuy.Active = true
			end)
		end
	end)
	
	---- UI POLISH: HOVER EFFECTS
	btnBuy.MouseEnter:Connect(function()
		hoverUpEvent:Fire(btnBuy)
	end)
	
	btnBuy.MouseLeave:Connect(function()
		hoverDownEvent:Fire(btnBuy)
	end)
	
	labelBought.MouseEnter:Connect(function()
		hoverUpEvent:Fire(labelBought)
	end)
	
	labelBought.MouseLeave:Connect(function()
		hoverDownEvent:Fire(labelBought)
	end)
end