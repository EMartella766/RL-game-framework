local CoreEvent = game.ReplicatedStorage:WaitForChild("CoreEvent")
local ItemFolder = game.ServerStorage:WaitForChild("ItemFolder")

CoreEvent.OnServerEvent:Connect(function(plr, eventtype, Arg1)
	local character = plr.Character
	
	if eventtype == "ClassSelector" then
		local ClassName = Arg1
		
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("Tool") then
				v:Destroy()
			end
		end
		
		for i, v in pairs(plr.Backpack:GetChildren()) do 
			if v:IsA("Tool") then
				v:Destroy()
			end
		end
		
		for i, v in pairs(ItemFolder:GetChildren()) do
			if v.Name == ClassName then
				for j,f in pairs(v:GetChildren()) do 
					if f:IsA("Tool") then
						local Item = f:Clone()
						Item.Parent = plr.Backpack
					end
				end
			end
		end
	end
end)