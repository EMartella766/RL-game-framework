local replicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local character = player.Character
local humanoid = player.Character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera
--setting up camera behaviors for first person
camera.CameraType = Enum.CameraType.Scriptable
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
UserInputService.MouseIconEnabled = false
UserInputService.WindowFocused:Connect(function() 
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = true
end)

--bob and sway
local bobSpeed = .2
local bobDistance = 2
local bobWalkMulti = 55
local walkVelocity = 16

--FOV
local defaultFOV = 60
local targetFOV = 60 -- changes in gameplay
local fovChange = 0
local maxFOVvelocity = 10
local FOVsmooth = 3

-- Mouse look settings
local sensitivity =  .4 --default value
local unlockMouseButton = Enum.KeyCode.F
local maxVerticalAngle = math.rad(80) 
local camOffset = 2
local turnLeanAmt = 320 --higher, less. Lower, more
local turnLeanSmoothing = .9 --higher, slower. Lower, faster
local turnLeanMax = .2 

local camSmooth = 16

local targetCFrame = CFrame.new()
local targetRot = CFrame.Angles(0, 0, 0)
local verticalAngle = 0 --keeps track of up/down for clamping
local horizontalAngle = 0
local zAngle = 0

humanoid.WalkSpeed = 16

local function UpdateCameraRotation(change)
	local c = change * sensitivity
	horizontalAngle += math.rad(c.x)
	zAngle = math.clamp(zAngle + (c.x / turnLeanAmt), -turnLeanMax, turnLeanMax) 
	verticalAngle = math.clamp(verticalAngle + math.rad(c.y), -maxVerticalAngle, maxVerticalAngle)

	targetRot = CFrame.Angles(0, horizontalAngle, 0) * CFrame.Angles(verticalAngle, 0, 0)
end

local function UpdateCameraPosition()
	if character and character.PrimaryPart then
		
		local velocity = character.PrimaryPart.AssemblyLinearVelocity.Magnitude
		local bobPos = 0

		if velocity < 1 then
			-- standing still = no bob
			bobPos = 0
		elseif humanoid.WalkSpeed <= 8 then
			-- crouch bob
			bobPos = math.sin(tick() * 6) * 0.2
		elseif humanoid.WalkSpeed < 19 then
			-- normal walking bob
			bobPos = math.sin(tick() * 10) * 0.4
		elseif humanoid.WalkSpeed >= 19 then
			-- sprinting bob
			bobPos = math.sin(tick() * 14) * 0.6
		end

		local offset = Vector3.new(0, bobPos, 0)
		local targetPosition = character.PrimaryPart.Position + offset
		targetCFrame = CFrame.new(targetPosition) * targetRot
	
	end
end

local function SmoothCameraZAxis(deltaTime)
	local amt = deltaTime / turnLeanSmoothing

	-- Smoothly reduce zAngle toward 0
	if zAngle > 0 then
		zAngle = math.max(zAngle - amt, 0)
	elseif zAngle < 0 then
		zAngle = math.min(zAngle + amt, 0)
	end

	-- Apply zAngle to targetRot
	local zRotation = CFrame.Angles(0, 0, zAngle)
	targetRot = CFrame.Angles(0, horizontalAngle, 0) * CFrame.Angles(verticalAngle, 0, 0) * zRotation
end

local function UpdateFOV(deltaTime)
	if not player.Character or not player.Character.PrimaryPart then
		return
	end

	local velocity = player.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude
	local normalizedVelocity = math.clamp(velocity / maxFOVvelocity, 0, 1)
	targetFOV = defaultFOV + (normalizedVelocity * fovChange)

	-- Interpolate the camera's FOV smoothly
	--camera.FieldOfView = camera.FieldOfView + (targetFOV - camera.FieldOfView) * deltaTime * FOVsmooth
end


UserInputService.InputChanged:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		UpdateCameraRotation(-Vector3.new(input.Delta.X, input.Delta.Y, 0))
	end
end)

UserInputService.InputBegan:Connect(function(input, process)
	if process then return end

	if input.KeyCode == unlockMouseButton then
		if UserInputService.MouseIconEnabled then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end
	end
end)

UserInputService.TouchMoved:Connect(function(touch, processed)
	if processed then return end

	UpdateCameraRotation(-Vector3.new(touch.Delta.X, touch.Delta.Y, 0))
end)

RunService.RenderStepped:Connect(function(deltaTime)
	
	UpdateCameraPosition()
	SmoothCameraZAxis(deltaTime)
	--UpdateFOV(deltaTime)

	
	
	
	for _, child in ipairs(character:GetDescendants()) do
		if child:IsA("BasePart") or child:IsA("Decal") then
			child.Transparency = 1
		end
	end
	--task.wait(2)
	--for _, child in ipairs(character:GetDescendants()) do
		--if child:IsA("BasePart") or child:IsA("Decal") then
			--child.Transparency = 1
		--end
	--end
	
	local alpha = 1 - math.exp(-camSmooth * deltaTime)

	camera.CFrame = camera.CFrame:Lerp(targetCFrame, alpha)

	--make sure the character's rotation (on the Y) is the same as the cam
	if character and character.PrimaryPart then
		--local _, camY, _ = camera.CFrame:ToOrientation()
		--character:SetPrimaryPartCFrame(CFrame.new(character.PrimaryPart.Position) * CFrame.Angles(0, camY, 0))
		-- Only rotate character, don’t re-pivot the whole rig
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if hrp then
			local pos = hrp.Position
			local _, camY, _ = camera.CFrame:ToOrientation()
			--Set autoRotate to false as else it would cause jitters duo to conflict between our script and the HumanoidRootPart physics
			humanoid.AutoRotate = false
			hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, camY, 0)
		end
	end
end)