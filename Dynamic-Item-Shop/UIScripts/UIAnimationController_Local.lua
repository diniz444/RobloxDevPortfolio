-- [[ DYNAMIC ITEM SHOP | ROBLOX PORTFOLIO ]]
-- Author: [diniz444]
-- Description: Universal UI animation controller using TweenService.
-- Listens to hover events to create dynamic "pop-up" effects on buttons and labels.

---- SERVICES
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---- TWEEN CONFIGURATION
-- Smooth Sine easing for a natural feel
local animationInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local HOVER_UP_PROPS = {
	["Size"] = UDim2.new(0, 162, 0, 27),
}

local HOVER_DOWN_PROPS = {
	["Size"] = UDim2.new(0, 158, 0, 23)
}

---- COMMUNICATION (BindableEvents)
-- Using BindableEvents for internal client communication
local hoverUpEvent = ReplicatedStorage:WaitForChild("PropUP")
local hoverDownEvent = ReplicatedStorage:WaitForChild("PropDOWN")

---- CORE LOGIC: ANIMATION LISTENERS
-- Listens for any UI element sent via the event and applies the "Grow" effect
hoverUpEvent.Event:Connect(function(targetButton)
	if targetButton then
		TweenService:Create(targetButton, animationInfo, HOVER_UP_PROPS):Play()
	end
end)

-- Listens for any UI element sent via the event and applies the "Shrink" effect
hoverDownEvent.Event:Connect(function(targetButton)
	if targetButton then
		TweenService:Create(targetButton, animationInfo, HOVER_DOWN_PROPS):Play()
	end
end)