local framework = require(game.ReplicatedStorage.Weapons.Framework)
local selectFunction = game.ReplicatedStorage.GUI.ClassSelector.BindableFunctions.Select
local openInventory = game.ReplicatedStorage.GUI.Inventory.CanOpen
local inventoryState = game.ReplicatedStorage.GUI.Inventory.InventoryOff

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local camera = game.Workspace.CurrentCamera
local humanoid = character:WaitForChild("Humanoid")
local classGUI = player.PlayerGui.ClassSelector.ClassSelectorGUI.LoadoutMenu

local lean = 0
local aimCF = CFrame.new()
local pos = CFrame.new()
local bob = nil
local sway = nil
local lerpedSway = CFrame.new()
local mouse = player:GetMouse()
local prevCamera = CFrame.new()
local fov = camera.FieldOfView
local currentFov = camera.FieldOfView
local targetFOV = camera.FieldOfView
local normalFov
local isTweening

local aiming = false
local canZoom = false
local reloading = false
local equipping = false
local sprinting = false
local shootFullAuto = false
local canPlay = false
local playerDied = false
local loadoutSelected = false
local debounce = false
local inventoryOff = true

local fireAnim = nil
local equipAnim = nil
local reloadAnim = nil
local trackFire = nil
local trackEquip = nil
local trackReload = nil
local animator = nil


function shoot()
	
	local origin = framework.viewmodel.Muzzle.Position
	local direction = camera.CFrame.LookVector * 1000
	local targetPoint = origin + direction
	
	sprinting = false
	if framework.module.mode == "semi" and framework.module.ammo ~= 0 then
		
		if fireAnim then
			trackFire.Looped = false
			trackFire:Play()
		end
		
		game.ReplicatedStorage.Weapons.Events.Shoot:FireServer(framework.viewmodel.Muzzle.Position, targetPoint, framework.module.damage, framework.module.headshot)
		framework.module.ammo -= 1
		
	end

	if framework.module.mode == "fullAuto" then
		shootFullAuto = true

		task.spawn(function()
			while shootFullAuto do
				if framework.module.ammo <= 0 then
					break
				else
					framework.module.ammo -= 1
					game.ReplicatedStorage.Weapons.Events.Shoot:FireServer(framework.viewmodel.Muzzle.Position, targetPoint, framework.module.damage, framework.module.headshot)
					task.wait(framework.module.fireRate)
				end

			end
		end)

	end
end


local function aimTween(aiming, zoom, time)
	
	if aiming then
		
		if framework.module.hasScope then
			
			local scope = framework.viewmodel.Scope
			
			for i,v in pairs(scope:GetChildren()) do
				if v:IsA("BasePart") then
					v.Transparency = 1
				end
			end
		end
		
		local tweenInfo = TweenInfo.new(
			time,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)

		local goal = {
			FieldOfView = zoom
		}

		local scopeZoom = tweenService:Create(camera, tweenInfo, goal)

		scopeZoom:Play()
	
		canZoom = true
			
	else
		
		local tweenInfo = TweenInfo.new(
			0.5,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In,
			0,
			false,
			0
		)

		local goal = {
			FieldOfView = 60
		}

		local scopeZoom = tweenService:Create(camera, tweenInfo, goal)

		scopeZoom:Play()
		
		canZoom = false

		if framework.module.hasScope then

			local scope = framework.viewmodel.Scope

			for i,v in pairs(scope:GetChildren()) do
				if v:IsA("BasePart") then
					v.Transparency = 0
				end
			end
		end
	end
	
	
	
end


local function scrollScope(input, scrollSpeed, minFov, maxFov)
	
	if canZoom and inventoryOff then
		currentFov -= input.Position.Z * scrollSpeed
		currentFov = math.clamp(currentFov, maxFov, minFov)
		targetFOV = currentFov

		local tween = tweenService:Create(camera, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = currentFov})
		tween:Play()
	end
	
end


local function cameraShake()
	
	if playerDied == false and framework.module ~= nil then
		local newCamera = framework.viewmodel.FakeCamera.CFrame:ToObjectSpace(framework.viewmodel.PrimaryPart.CFrame)
		camera.CFrame = camera.CFrame * newCamera:ToObjectSpace(prevCamera)
		prevCamera = newCamera
	end
	
end


local function swayLerp(a,b,t)
	return a + (b - a) * t
end


function resetSettings(item)
	local viewmodelFolder = game.ReplicatedStorage.Weapons.ViewModels
	local moduleFolder = game.ReplicatedStorage.Weapons.Modules
	
	if moduleFolder:FindFirstChild(item) and framework.module ~= nil then
		framework.module = require(moduleFolder:FindFirstChild(item))
		framework.module.ammo = framework.module.maxAmmo
	end
end


function loadItem(item)
	
	if reloading == false then
		
		local viewmodelFolder = game.ReplicatedStorage.Weapons.ViewModels
		local moduleFolder = game.ReplicatedStorage.Weapons.Modules

		for i, v in pairs(camera:GetChildren()) do
			if v:IsA("Model") then
				v:Destroy()
			end
		end

		--Get item settings
		if moduleFolder:FindFirstChild(item) then
			framework.module = require(moduleFolder:FindFirstChild(item))

			--Get item viewmodel
			if viewmodelFolder:FindFirstChild(item) then
				framework.viewmodel = viewmodelFolder:FindFirstChild(item):Clone()
				framework.viewmodel.Parent = camera

				if character:WaitForChild("Torso"):FindFirstChild("FireSound") then
					character:WaitForChild("Torso"):FindFirstChild("FireSound"):Destroy()
				end

				if framework.viewmodel and framework.module and character then
					local fireSound = Instance.new("Sound")
					fireSound.Parent = character.Torso
					fireSound.Name = "FireSound"
					fireSound.SoundId = framework.module.fireSound.SoundId

					fireAnim = Instance.new("Animation")
					fireAnim.Parent = framework.viewmodel
					fireAnim.Name = "Fire"
					fireAnim.AnimationId = framework.module.firingAnim

					equipAnim = Instance.new("Animation")
					equipAnim.Parent = framework.viewmodel
					equipAnim.Name = "Equip"
					equipAnim.AnimationId = framework.module.equipAnim

					reloadAnim = Instance.new("Animation")
					reloadAnim.Parent = framework.viewmodel
					reloadAnim.Name = "Reload"
					reloadAnim.AnimationId = framework.module.reloadAnim

					local animatorFire = framework.viewmodel.AnimationController.Animator
					trackFire = animatorFire:LoadAnimation(fireAnim)

					local animatorEquip = framework.viewmodel.AnimationController.Animator
					trackEquip = animatorEquip:LoadAnimation(equipAnim)

					local animatorReload = framework.viewmodel.AnimationController.Animator
					trackReload = animatorEquip:LoadAnimation(reloadAnim)
					
				end
				
				if framework.module.ammo then
					if framework.module.ammo > 0 then
						game.ReplicatedStorage.Weapons.Events.LoadSlot:FireServer(framework.inventory[framework.currentSlot], framework.module.fireSound.SoundId, framework.module.fireSound.Volume)
					end
				end
				
				
			end

		end
	end
	
end


inventoryState.Event:Connect(function(state)
	inventoryOff = state
	print(state)

end)


userInput.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.One and reloading == false and canPlay and inventoryOff then
		if framework.currentSlot ~= 1 then
			loadItem(framework.inventory[1])
			framework.currentSlot = 1
			
		end
	end

	if input.KeyCode == Enum.KeyCode.Two and reloading == false and canPlay and inventoryOff then
		if framework.currentSlot ~= 2 then
			loadItem(framework.inventory[2])
			framework.currentSlot = 2
			equipping = true
			
			--if equipAnim then
				--trackEquip.Looped = false
				--trackEquip.Priority = Enum.AnimationPriority.Action
				--trackEquip:Play()
				--print("isPLaying: ", trackEquip.IsPlaying)
				
				--wait(trackEquip.length)
				--equipping = false
			--end
			
		end
	end
	
	--if input.KeyCode == Enum.KeyCode.Three and reloading == false and canPlay then
		--if framework.currentSlot ~= 3 then
			--loadItem(framework.inventory[3])
			--framework.currentSlot = 3
			--equipping = true

		--end
	--end
	
	--if input.KeyCode == Enum.KeyCode.Four and reloading == false and canPlay then
		--if framework.currentSlot ~= 4 then
			--loadItem(framework.inventory[4])
			--framework.currentSlot = 4
			--equipping = true

		--end
	--end
	

	if input.UserInputType == Enum.UserInputType.MouseButton1 and canPlay then
		if character and framework.viewmodel and framework.module and reloading == false 
			and canPlay and not debounce and inventoryOff then
			
			debounce = true
			shoot()
			
			task.wait(framework.module.debounce)
			debounce = false

		end
	end
	
	if input.KeyCode == Enum.KeyCode.R and canPlay then
		reloading = true

		print("Reloading")
		
		--if reloadAnim then
			--trackReload.Looped = false
			--trackReload.Priority = Enum.AnimationPriority.Action
			--trackReload:Play()
		--end

		wait(trackReload.length)
		framework.module.ammo = framework.module.maxAmmo

		reloading = false
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 and reloading == false and sprinting == false and canPlay and inventoryOff then
		aiming = true
		aimTween(true, framework.module.zoomAim, framework.module.zoomTime)	
	end
	
end)


userInput.InputChanged:Connect(function(input)
	
	if input.UserInputType == Enum.UserInputType.MouseWheel and aiming and canPlay and inventoryOff then
		if framework.module.hasScope then
			print("Scrolling")
			local defaultFOV = 60
			local maxFOV = -100
			scrollScope(input, framework.module.zoomSpeed, defaultFOV, maxFOV)
		end
		
	end
end)


userInput.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton2 and canPlay and inventoryOff then
		aiming = false
		aimTween(false, 0, framework.module.zoomTime)
		
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 and inventoryOff then
		shootFullAuto = false
	end

end)


runService.RenderStepped:Connect(function(deltaTime)
	
	if classGUI then
		if classGUI.Visible == true then
			canPlay = false
		else
			--Use remote function here
			canPlay = true
			openInventory:Fire(true)
		end
	end
	
	--Ignore viewmodel so bullet doesn't collide with it
	mouse.TargetFilter = framework.viewmodel
	
	local velocity = character.PrimaryPart.AssemblyLinearVelocity.Magnitude
	
	if humanoid and framework.module ~= nil and canPlay and inventoryOff then
		if velocity < 1 then
			sprinting = false
			-- standing still = no bob
			bob = 0
			--Use lower frequencies
			sway = CFrame.Angles(
				math.cos(tick() * 1.5) * 0.01,
				math.sin(tick() * 2) * 0.015,
				0)
		elseif humanoid.WalkSpeed <= 8 then
			-- crouch bob
			sprinting = false
			bob = math.sin(tick() * 6) * 0.05
			sway = CFrame.Angles(math.cos(tick() * 0.5) * .05, math.sin(tick() * 8) * .1, 0)
		elseif humanoid.WalkSpeed < 19 then
			-- normal walking bob
			sprinting = false
			bob = math.sin(tick() * 10) * 0.05
			sway = CFrame.Angles(math.cos(tick() * 2) * .025, math.sin(tick() * 4) * .025, 0)
		elseif humanoid.WalkSpeed >= 19 and aiming == false then
			-- sprinting bob
			warn(humanoid.WalkSpeed)
			
			sprinting = true
			bob = math.sin(tick() * 12) * 0.1
			sway = CFrame.Angles(math.cos(tick() * 2) * .04, math.sin(tick() * 4) * .1, 0) * framework.module.sprintCF
		end

		pos = pos:Lerp(CFrame.new(0, bob, 0) * sway, .04)

	end
	
	
	for i, v in pairs(camera:GetChildren()) do
		if v:IsA("Model") then
			
			local mouseDelta = userInput:GetMouseDelta()
			
			if aiming and framework.viewmodel ~= nil and framework.module.canAim and canPlay then
				local aimOffset = framework.viewmodel.AimPart.CFrame:ToObjectSpace(framework.viewmodel.PrimaryPart.CFrame)
				aimCF = aimCF:Lerp(aimOffset, framework.module.aimSmooth)
				
				lean = swayLerp(lean, math.clamp(mouseDelta.X, -10, 10), deltaTime * 7)
				v:PivotTo(camera.CFrame * aimCF * CFrame.Angles(0,0,math.rad(lean)))
			else
				aimCF = aimCF:Lerp(CFrame.new(0,0,0), 0.1)
				
				lean = swayLerp(lean, math.clamp(mouseDelta.X, -10, 10), deltaTime * 7)
				v:PivotTo(camera.CFrame * aimCF * pos * CFrame.Angles(0,0,math.rad(lean)))
			end
			
		end
	end
	
	cameraShake()
	
end)


game.ReplicatedStorage.Weapons.Events.PlayerAdded.OnClientEvent:Connect(function(ply, char)
	
	player = game.Players.LocalPlayer
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	classGUI = player.PlayerGui.ClassSelector.ClassSelectorGUI.LoadoutMenu
	
	userInput.MouseIconEnabled = true
	userInput.MouseBehavior = Enum.MouseBehavior.Default
	
	classGUI.Visible = true
	
	local currentLoadout = nil
	loadoutSelected = false
	
	classGUI.Hunter.MouseButton1Click:Connect(function()
		classGUI.PrimaryWeapon.Text = framework.loadouts.hunter[1]
		classGUI.SecondaryWeapon.Text = framework.loadouts.hunter[2]
		currentLoadout = "hunter"
	end)
	
	classGUI.Healer.MouseButton1Click:Connect(function()
		classGUI.PrimaryWeapon.Text = framework.loadouts.healer[1]
		classGUI.SecondaryWeapon.Text = framework.loadouts.healer[2]
		currentLoadout = "healer"
	end)
	
	classGUI.Select.MouseButton1Click:Connect(function()
		
		if currentLoadout ~= nil then
			classGUI.Visible = false
			framework.inventory[1] = framework.loadouts[currentLoadout][1]
			framework.inventory[2] = framework.loadouts[currentLoadout][2]
			loadoutSelected = true
			
			--Reset Settings
			resetSettings(framework.inventory[1])
			resetSettings(framework.inventory[2])
			
			playerDied = false

			--Load loadout
			loadItem(framework.inventory[1])
			framework.currentSlot = 1
			print("loaded first slot")
			
			userInput.MouseIconEnabled = false
			userInput.MouseBehavior = Enum.MouseBehavior.LockCenter
			
		else
			warn("Select a laodout brotato chip")
		end
		
	end)
	
	
	humanoid.Died:Connect(function()
		print("Died")
		playerDied = true
		
		if classGUI then
			classGUI.Visible = false
		end

		if framework.viewmodel then
			framework.viewmodel:Destroy()
		end

	end)
	
end)



