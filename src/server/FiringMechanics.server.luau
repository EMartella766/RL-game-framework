local cut = false

game.ReplicatedStorage.Weapons.Events.LoadSlot.OnServerEvent:Connect(function(player, item, soundId, volume)
	print("Slot loaded")
	for i, v in pairs(player.Character.Torso:GetChildren()) do
		if v.Name == "FireSound" then
			v:Destroy()
		end
	end
	
	local fireSound = Instance.new("Sound")
	fireSound.Parent = player.Character.Torso
	fireSound.Name = "FireSound"
	fireSound.Volume = volume
	fireSound.SoundId = soundId
	
	if fireSound.SoundId == "rbxassetid://89597710473544" then
		fireSound.TimePosition = 0.2
		cut = true
	end
	
	print(item)
	local tpWeapons = game.ReplicatedStorage.Weapons.TPS
	
end)



game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		game.ReplicatedStorage.Weapons.Events.PlayerAdded:FireClient(player, character)
	end)
end)


game.ReplicatedStorage.Weapons.Events.Shoot.OnServerEvent:Connect(function(player, MuzzlePos, mousePos, damage, headshot)

	if player.Character then
		local sound = player.Character.Torso:FindFirstChild("FireSound")

		if sound then
			sound:Play()
		elseif sound and cut then
			sound:Play()
			task.wait(3)
			sound:Stop()
			
			cut = false
			
		
		end

		local bullet = Instance.new("Part")
		bullet.Name = "Bullet"
		bullet.Parent = game.Workspace
		bullet.CanCollide = false
		bullet.Anchored = false
		bullet.Size = Vector3.new(.1, .1, 1)
		bullet.CFrame = CFrame.new(MuzzlePos, mousePos)
		bullet.Material = Enum.Material.Neon
		bullet.BrickColor = BrickColor.new("Cool yellow")

		bullet:SetNetworkOwner(player)

		local bodyVelo = Instance.new("BodyVelocity")
		bodyVelo.Parent = bullet
		bodyVelo.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelo.Velocity = bullet.CFrame.LookVector * 100

		bullet.Touched:Connect(function(hit)
			bullet:Destroy()

			if hit.Parent ~= player.Character then
				if hit then
					if hit.Parent:FindFirstChild("Humanoid") then
						if hit.Name == "Head" then
							hit.Parent:FindFirstChild("Humanoid"):TakeDamage(headshot)
						else
							hit.Parent:FindFirstChild("Humanoid"):TakeDamage(damage)
						end

						print("Hit")
					end
				end
			end

		end)

		wait(25)
		bullet:Destroy()

	end
end)