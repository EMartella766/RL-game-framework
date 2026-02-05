local framework = require(game.ReplicatedStorage.Weapons.Framework)

local RunService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = players.LocalPlayer
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local hudWidthStuds = nil
local hudHeightStuds = nil

local distance = 10 --studs in front of the camera
local hudOrigin = camera.CFrame.Position + camera.CFrame.LookVector * distance
local lastCamCF = camera.CFrame
local guiLerpOffset = CFrame.new()

local lerpSpeed = 5

local visorGUI = replicatedStorage:WaitForChild("GUI"):WaitForChild("VisorGUI")
local parts = {}

local stamina = require(replicatedStorage:WaitForChild("StaminaModule"))
local compassModule = require(replicatedStorage:WaitForChild("GUI"):WaitForChild("VisorGUI"):WaitForChild("Compass"):WaitForChild("Directions"))
local labelWidth = 250
local xPos = 0
local currentAngle = 0
local fadeFrame = visorGUI:WaitForChild("Compass"):WaitForChild("SurfaceGui"):WaitForChild("FadeFrame")
local scrollingCompassFrame = visorGUI:WaitForChild("Compass"):WaitForChild("SurfaceGui"):WaitForChild("ScrollingCompassFrame")
-- Get player's humanoid for health display
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- access VisorStatusGUi text label 
local visorStatusLabel = nil
local visorStatusGUI = player.PlayerGui:FindFirstChild("VisorStatusGUI")
if visorStatusGUI then
    local frame = visorStatusGUI:FindFirstChildWhichIsA("Frame")
    if frame then
        visorStatusLabel = frame:FindFirstChildWhichIsA("TextLabel")
        if visorStatusLabel then
            visorStatusLabel.RichText = true
        end
    end
end

-- create the camPart at a fixed distance in front of the camera
local visorActive = false
local camPart = Instance.new("Part")
camPart.Size = Vector3.new(1,1,1)
camPart.Transparency = 1
camPart.Anchored = true
camPart.CanCollide = false
camPart.Parent = workspace

local originalPosition = camPart.Position

for i, v in pairs(workspace.GUI:GetChildren()) do
	if v:IsA("Part") then
		v:Destroy()
	end
end

for _, child in ipairs(visorGUI:GetChildren()) do
	if child:IsA("BasePart") then
		local clone = child:Clone()
		clone.Parent = workspace.GUI
		clone.Anchored = true
		clone.CanCollide = false
		parts[clone.Name] = clone
	end
end

-- gui elements created
local elementsGUI = {
	{Part = parts["Stamina"], Offset = CFrame.new(-4.3,-3,0), Rotation = CFrame.Angles(0,math.rad(-28),0)}, 
	{Part = parts["Health"], Offset = CFrame.new(4.3,-3,0), Rotation = CFrame.Angles(0,math.rad(28),0)},
	{Part = parts["Compass"], Offset = CFrame.new(0,-1,0), Rotation = CFrame.Angles(0,0,0)},
	{Part = parts["Ammo"], Offset = CFrame.new(4,3,0), Rotation = CFrame.Angles(0,math.rad(28),0)},
	{Part = parts["Slash"], Offset = CFrame.new(6,3.1,0), Rotation = CFrame.Angles(0,math.rad(28),0)},
	{Part = parts["MaxAmmo"], Offset = CFrame.new(8,3.3,0), Rotation = CFrame.Angles(0,math.rad(28),0)},
	{Part = parts["CurrentItem"], Offset = CFrame.new(6,4.3,0), Rotation = CFrame.Angles(0,math.rad(28),0)},
	
	  
}

-- store gui elements of part in table
local attachedGUIs = {}
for _, element in ipairs(elementsGUI) do
	attachedGUIs[element.Part] = {}
	if element.Part then
		for _, child in ipairs(element.Part:GetChildren()) do
			if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
				table.insert(attachedGUIs[element.Part], child)
			end
		end
	end
end

local function getHUDSize()
	local verticalFOV = math.rad(camera.FieldOfView)
	local aspect = screenSize.X / screenSize.Y
	local horizontalFOV = 2 * math.atan(aspect * math.tan(verticalFOV / 2))
	local hudWidthStuds = 2 * distance * math.tan(horizontalFOV / 2)
	local hudHeightStuds = 2 * distance * math.tan(verticalFOV / 2)

	return hudWidthStuds, hudHeightStuds
end

local function getCornerOffsets()
	local hudWidth, hudHeight = getHUDSize()

	local topLeft = CFrame.new(-hudWidth/2, hudHeight/2, 0)
	local topRight = CFrame.new(hudWidth/2, hudHeight/2, 0)
	local bottomLeft = CFrame.new(-hudWidth/2, -hudHeight/2, 0)
	local bottomRight = CFrame.new(hudWidth/2, -hudHeight/2, 0)
	local topCenter = CFrame.new(0, hudHeight/2, 0)

	elementsGUI[1].Position = topRight --Stamina
	elementsGUI[2].Position = topLeft --Health
	elementsGUI[3].Position = topCenter --Compass
	elementsGUI[4].Position = bottomLeft -- Ammo
	elementsGUI[5].Position = bottomLeft -- Slash
	elementsGUI[6].Position = bottomLeft --MaxAmmo
	elementsGUI[7].Position = bottomLeft -- CurrentItem
	
	--For ammo put weapon as position
	
end

local function getCameraYaw()
	local _, yaw, _ = camera.CFrame:ToOrientation()
	local degrees = math.deg(yaw)
	
	--Normalize to 0-360
	if degrees < 0 then
		degrees = degrees + 360
	end
	
	return degrees
end

local function drawCompass()
	
	local parent = workspace.GUI:WaitForChild("Compass"):WaitForChild("SurfaceGui"):WaitForChild("ScrollingCompassFrame")
	
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 0
	gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0),  
		NumberSequenceKeypoint.new(0.2, 1), 
		NumberSequenceKeypoint.new(0.8, 1), 
		NumberSequenceKeypoint.new(1, 0),   
	}
	gradient.Parent = workspace.GUI:WaitForChild("Compass"):WaitForChild("SurfaceGui"):WaitForChild("FadeFrame")
	
	local nextAngle = 0
	
	for i = 1,2 do
		for dirIndex, direction in ipairs(compassModule.Directions) do
			
			--Create tick
			local dirTick = Instance.new("Frame")
			dirTick.Size = UDim2.new(0,2,0,7)
			dirTick.Position = UDim2.new(0, xPos, 0, 0)
			dirTick.BackgroundColor3 = Color3.fromRGB(255, 48, 6)
			dirTick.BorderSizePixel = 0
			dirTick.Parent = parent
			dirTick.ZIndex = 1

			--Create Direction label
			local label = Instance.new("TextLabel")
			label.Name = direction
			label.AnchorPoint = Vector2.new(0.5,0)
			label.Size = UDim2.new(0, labelWidth, 1, 0)
			label.Position = UDim2.new(0,xPos, 0, 0)
			label.BackgroundTransparency = 1
			label.TextScaled = false
			label.TextSize = 25
			label.TextTransparency = 0
			label.Font = Enum.Font.Michroma
			label.TextColor3 = Color3.fromRGB(75, 198, 255)
			label.Text = direction
			label.ZIndex = 2
			label.Parent = parent
			
			for j = 1,2 do
				local stepWidth = labelWidth/3
				local anglePos = xPos + (stepWidth * j)
				--Center it at angle
				
				--Access next two positions in array
				local interAngles = compassModule.InterAngles[1+nextAngle]
				nextAngle += 1
				
				local angleOffset = 45

				local angleStep = (((dirIndex - 1) * 45) - angleOffset) + (15 * j)
				
				if angleStep >= 360 then
					angleStep -= 360
				elseif angleStep <= 0 then
						angleStep += 360
					
				end
				
				--Create angle label
				local angleLabel = Instance.new("TextLabel")
				angleLabel.Name = tostring(angleStep) .. "Deg"
				angleLabel.Size = UDim2.new(0, stepWidth, 1, 0)
				angleLabel.AnchorPoint = Vector2.new(0.5, 0)
				angleLabel.Position = UDim2.new(0, anglePos, 0, 0)
				angleLabel.BackgroundTransparency = 1
				angleLabel.TextScaled = false
				angleLabel.Font = Enum.Font.Michroma
				angleLabel.TextColor3 = Color3.fromRGB(47, 220, 255)
				angleLabel.Text = tostring(angleStep)
				angleLabel.TextSize = 10
				angleLabel.ZIndex = 3
				angleLabel.Parent = parent
				
			end
				
			xPos = xPos + labelWidth
			
		end
	end

	
end

drawCompass()

-- function to activate/deactivate visor GUI
local function setVisorActive(active)
	visorActive = active
	for _, element in ipairs(elementsGUI) do
		if element.Part then
			for _, gui in ipairs(attachedGUIs[element.Part]) do
				gui.Enabled = visorActive
			end
		end
	end
	-- change status text accordingly
	if visorStatusLabel then
		if visorActive then
			visorStatusLabel.Text = "Visor: <font color=\"rgb(0,255,0)\">On</font>"
		else
			visorStatusLabel.Text = "Visor: <font color=\"rgb(255,0,0)\">Off</font>"
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.M then
		setVisorActive(not visorActive)
	end
end)

-- Initialize visor state at start
setVisorActive(false)

RunService.RenderStepped:Connect(function(deltaTime)
	screenSize = camera.ViewportSize
	
	local currentCF = camera.CFrame
	local delta = lastCamCF:ToObjectSpace(currentCF)
	lastCamCF = currentCF
	
	--Extract X/Y rotation components (invert dy and dx)
	local dx, dy, _ = delta:ToOrientation()
	
	--Invert Y and X to get the correct rotation direction
	local offsetX = dy
	local offsetY = dx
	--Scale them into an offset
	local scaledOffset = CFrame.new(offsetX * 2, offsetY * 2, 0)
	
	--Clamp offset so that gui elements do not lerp too far
	local maxOffset = 2
	scaledOffset = CFrame.new(
		math.clamp(scaledOffset.X, -maxOffset, maxOffset),
		math.clamp(scaledOffset.Y, -maxOffset, maxOffset),
		0
	)
	
	getCornerOffsets()
	
	camPart.CFrame = camera.CFrame * CFrame.new(0,0,-10)
	
	local lerpAlpha = 1 - math.exp(-180 * deltaTime)
	
	guiLerpOffset = guiLerpOffset:Lerp(scaledOffset, lerpAlpha)

	for _, element in ipairs(elementsGUI) do
		local targetCFrame = camPart.CFrame * element.Position * element.Offset * element.Rotation
		element.Part:PivotTo(targetCFrame * guiLerpOffset)
	end
	
	--Update compass frame
	local degrees = getCameraYaw()
	local totalWidth = xPos
	--How many pixels per degree we move
	local pixelsPerDegree = (totalWidth/2) / 360
	
	
	local offset = degrees * pixelsPerDegree
	offset = offset % (totalWidth/2)
	
	local roundedDegree = math.floor(getCameraYaw())
	--Update scrolling frame gui
	local compass = parts["Compass"]
	
	if compass then
		for _, gui in ipairs(attachedGUIs[compass]) do
			if gui:IsA("SurfaceGui") then
				for _, obj in ipairs(gui:GetChildren()) do
					if obj:IsA("ScrollingFrame") then
						obj.CanvasSize = UDim2.new(0, xPos, 0, 42)
						obj.CanvasPosition = Vector2.new(offset,0)
					end
				end
			end
		end
	end
	
	--print(compassModule:GetClosestDirection(degrees))

	--update Stamina GUI element
	local staminaPart = parts["Stamina"]
	if staminaPart then
		for _, gui in ipairs(attachedGUIs[staminaPart]) do
			if gui:IsA("SurfaceGui") then
				for _, obj in ipairs(gui:GetChildren()) do
					if obj:IsA("TextLabel") then
						obj.Text = math.floor(stamina:Get()) .. "%"
					end
				end
			end
		end
	end
	
	--update Health GUI element
	local healthPart = parts["Health"]
	if healthPart then
		for _, gui in ipairs(attachedGUIs[healthPart]) do
			if gui:IsA("SurfaceGui") then
				for _, obj in ipairs(gui:GetChildren()) do
					if obj:IsA("TextLabel") then
						obj.Text = math.floor(humanoid.Health) .. "%"
					end
				end
			end
		end
	end
	
	--update currentItem
	local currentItemPart = parts["CurrentItem"]
	
	if currentItemPart then
		
		for _, gui in ipairs(attachedGUIs[currentItemPart]) do
			if gui:IsA("SurfaceGui") then
				for _, obj in ipairs(gui:GetChildren()) do
					if obj:IsA("TextLabel") and framework.module ~= nil then
						local currentSlot = framework.currentSlot
						obj.Text = framework.inventory[currentSlot]
					end
				end
			end
		end
	end
	
	--update MaxAmmo
	local maxAmmo = parts["MaxAmmo"]

	if maxAmmo then
		
		for _, gui in ipairs(attachedGUIs[maxAmmo]) do
			if gui:IsA("SurfaceGui") then
				for _, obj in ipairs(gui:GetChildren()) do
					if obj:IsA("TextLabel") and framework.module ~= nil then
						local maxAmmo = framework.module.maxAmmo
						obj.Text = maxAmmo
						
					end
				end
			end
		end
	end
	
	--update ammo
	local ammo = parts["Ammo"]

	if ammo then

		for _, gui in ipairs(attachedGUIs[ammo]) do
			if gui:IsA("SurfaceGui") then
				for _, obj in ipairs(gui:GetChildren()) do
					if obj:IsA("TextLabel") and framework.module ~= nil then
						local ammo = framework.module.ammo
						obj.Text = ammo
						
					end
				end
			end
		end
	end
	
end)

--Camera [forward] --> -Z
--Camera [right] --> along +X
--Camera [up] --> along +Y