local framework = require(game.ReplicatedStorage.Weapons.Framework)
local openInventory = game.ReplicatedStorage.GUI.Inventory.CanOpen
local inventoryOff = game.ReplicatedStorage.GUI.Inventory.InventoryOff
local playerService = game:GetService("Players")
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local player = playerService.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()


local inventoryGUI
local inventory

local canOpen = false
local lockMouse = false

if character then
	inventoryGUI = player.PlayerGui.Inventory.InventoryGUI
	inventory = inventoryGUI.InventoryContainer
	itemBar = inventoryGUI.ItemBar
end

--Generate grid layout
local function generateGrid(totalBlocks)
	
	--Get width and height of container
	local width = inventory.AbsoluteSize.X
	local height = inventory.AbsoluteSize.Y
	
	local blockW = 0.1
	local blockH = 0.1
	
	local stepWidth = 0
	local stepHeight = 0.1
	
	for i = 1,totalBlocks do
		
		local block = Instance.new("Frame")
		block.Size = UDim2.new(blockW, 0, blockH, 0)
		block.Position = UDim2.new(stepWidth,0 , stepHeight, 0)
		block.BackgroundTransparency = 0.3
		block.BackgroundColor3 = Color3.fromRGB(108, 103, 88)
		block.BorderSizePixel = 1
		block.BorderColor3 = Color3.fromRGB(255, 255, 255)
		block.Parent = inventory
		
		local constraint = Instance.new("UIAspectRatioConstraint")
		constraint.Parent = block
		
		local slot = Instance.new("Frame")
		slot.Size = UDim2.new(blockW, 0, blockH, 0)
		slot.Name = "Slot"..i
		slot.Position = UDim2.new(stepWidth, 0 , stepHeight, 0)
		slot.BackgroundTransparency = 0.5
		slot.BackgroundColor3 = Color3.fromRGB(108, 5, 51)
		slot.BorderSizePixel = 0
		slot.Parent = inventory
		
		local constraintSlot = Instance.new("UIAspectRatioConstraint")
		constraintSlot.Parent = slot

		local dragDetector = Instance.new("UIDragDetector")
		dragDetector.Parent = slot
		dragDetector.Enabled = true
		
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Item"
		imageLabel.AnchorPoint = Vector2.new(0,0)
		imageLabel.Size = UDim2.new(0.9, 0, 0.9, 0)
		imageLabel.Position = UDim2.new(0, 0 , 0, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = ""
		imageLabel.Parent = slot
		
		local constraint = Instance.new("UIAspectRatioConstraint")
		constraint.Parent = imageLabel
		
		stepWidth += (blockW + 0.01)
		
		if (stepWidth + blockW) >= 1 then
			stepHeight += (blockH + 0.01)
			stepWidth = 0
		end
	end
	
end


local function generateBarGrid(totalBlocks)
	
	
	--Get width and height of container
	local width = inventory.AbsoluteSize.X
	local height = inventory.AbsoluteSize.Y

	local blockW = 0.1
	local blockH = 1

	local stepWidth = 0
	local stepHeight = 0.1
	
	itemBar.BackgroundTransparency = 1

	for i = 1,totalBlocks do

		local block = Instance.new("Frame")
		block.Size = UDim2.new(blockW, 0, blockH, 0)
		block.Position = UDim2.new(stepWidth,0 , stepHeight, 0)
		block.BackgroundTransparency = 1
		block.BackgroundColor3 = Color3.fromRGB(108, 103, 88)
		block.Parent = itemBar
		
		--Add outline
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Parent = block

		local constraint = Instance.new("UIAspectRatioConstraint")
		constraint.Parent = block

		local slot = Instance.new("Frame")
		slot.Size = UDim2.new(blockW, 0, blockH, 0)
		slot.Name = "Slot"..i
		slot.Position = UDim2.new(stepWidth, 0 , stepHeight, 0)
		slot.BackgroundTransparency = 0.5
		slot.BackgroundColor3 = Color3.fromRGB(108, 5, 51)
		slot.BorderSizePixel = 0
		slot.Parent = itemBar

		local constraintSlot = Instance.new("UIAspectRatioConstraint")
		constraintSlot.Parent = slot

		local dragDetector = Instance.new("UIDragDetector")
		dragDetector.Parent = slot
		dragDetector.Enabled = true

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Item"
		imageLabel.AnchorPoint = Vector2.new(0,0)
		imageLabel.Size = UDim2.new(0.9, 0, 0.9, 0)
		imageLabel.Position = UDim2.new(0, 0 , 0, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = ""
		imageLabel.Parent = slot

		local constraint = Instance.new("UIAspectRatioConstraint")
		constraint.Parent = imageLabel

		stepWidth += (blockW + 0.01)

		if (stepWidth + blockW) >= 1 then
			stepWidth = 0
		end
	end
end

local function dragItemsInventory()
	
	for i, slot in ipairs(inventory:GetChildren()) do
		
		if slot:IsA("Frame") and string.match(slot.Name, "^Slot%d+") then
			
			local item = slot:FindFirstChild("Item")
			local dragDetector = slot:FindFirstChildWhichIsA("UIDragDetector")

			if not item or not dragDetector then
				continue
			end

			--Slot original position
			local startPosition
			--What slot mouse is currently over
			local mouseIsInSlot

			dragDetector.DragStart:Connect(function()

				--When u start dragging slot, remember its position
				startPosition = slot.Position
				print(startPosition)
				slot.ZIndex = 10

			end)

			dragDetector.DragEnd:Connect(function()

				if mouseIsInSlot ~= nil then

					slot.Position = mouseIsInSlot.Position
					mouseIsInSlot.Position = startPosition
					
					mouseIsInSlot.ZIndex = 9
				else

					slot.Position = startPosition
				end


			end)

			for _, targetSlot in ipairs(inventory:GetChildren()) do
				if targetSlot:IsA("Frame") and string.match(targetSlot.Name  , "^Slot%d+") then

					targetSlot.MouseEnter:Connect(function()
						mouseIsInSlot = targetSlot

					end)

					targetSlot.MouseLeave:Connect(function()

						mouseIsInSlot = nil
					end)

				end

			end
			
		end
	end
end


local function addItems()
	
	local moduleFolder = game.ReplicatedStorage.Weapons.Modules
	
	if framework.inventory then
		
		for i = 1,2 do

			if moduleFolder:FindFirstChild(framework.inventory[i]) and inventory.Visible == true then
				--warn(framework.inventory[i])
				framework.module = require(moduleFolder:FindFirstChild(framework.inventory[i]))
				
				--Modify first image label
				if inventory:FindFirstChild("Slot1"):FindFirstChildOfClass("ImageLabel") then
					
					local itemImage = inventory:FindFirstChild("Slot"..i):FindFirstChildOfClass("ImageLabel")
					
					itemImage.Image = framework.module.icon
				end
			end
		end
		
	end
	
	
end

--"I" key to open inventory
userInput.InputBegan:Connect(function(input, gameProcessed)
	
	if gameProcessed then
		return end

	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.I and canOpen then
			
			--Toggle between open and closed
			inventory.Visible = not inventory.Visible
			
			lockMouse = not lockMouse
			
			if lockMouse then
				userInput.MouseIconEnabled = true
				userInput.MouseBehavior = Enum.MouseBehavior.Default
				controls:Disable()
				inventoryOff:Fire(false)
			else
				userInput.MouseIconEnabled = false
				userInput.MouseBehavior = Enum.MouseBehavior.LockCenter
				controls:Enable()
				inventoryOff:Fire(true)
			end
			
			
			if inventory.Visible == true then
				generateGrid(30)
				generateBarGrid(9)
				--addItems()
				dragItemsInventory()
				
			end
		end
	end
	
end)

openInventory.Event:Connect(function(open)
	canOpen = open
	
end)

runService.RenderStepped:Connect(function()
	
	
	if inventory.Visible and canOpen then

		addItems()
		
	else
		
		for i, slot in pairs(inventory:GetChildren()) do
			if slot:IsA("Frame") then
				slot:Destroy()
			end
			
		end
		
	end
end)



