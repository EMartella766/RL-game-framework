local replicatedStorage = game:GetService("ReplicatedStorage")

local assetFolder = replicatedStorage.MapGeneration.RoomsTest

local function Generate(startingPos, MaxRooms)
	
	local currentNumOfRooms = 0
	local lastGenerated
	
	--Pass in prevRoom
	local function Branchout(Model:Model)
		wait()
		for i,v in pairs(Model:GetChildren()) do
			
			if v:IsA("BasePart") and v.Name == "Exit" then
				
				--Generate newRoom
				local newRoom = assetFolder:GetChildren()[math.random(1,#assetFolder:GetChildren())]:Clone()
				
				newRoom.PrimaryPart = newRoom.Entrance

				--Join the newRoom to the previous room by setting the CFrame of the new room's entrance to the previous room's exit
				newRoom:PivotTo(v.CFrame)
				
				local newRoomBase = newRoom:WaitForChild("Base")
				
				local partsInCheckBox = game.Workspace:GetPartsInPart(newRoomBase)
				
				if #partsInCheckBox>0 or currentNumOfRooms >= MaxRooms then
					v.Transparency = 0
					v.Color = Color3.fromRGB(255, 0, 0)
					v.Position = v.Position + v.CFrame.UpVector * -2
					v.CanCollide = true
					
					newRoom:Destroy()
					
				else
					
					newRoom.Parent = game.Workspace.GeneratedRooms
					
					currentNumOfRooms += 1
					
					coroutine.wrap(Branchout)(newRoom)
					v:Destroy()
					
				end
				
			end
		end
	end
	
	local startingRoom = replicatedStorage:WaitForChild("MapGeneration"):WaitForChild("Start"):Clone()
	startingRoom.Parent = game.Workspace.GeneratedRooms
	startingRoom:PivotTo(CFrame.new(startingPos))
	currentNumOfRooms += 1
	lastGenerated = tick()
	
	Branchout(startingRoom)
	
	while currentNumOfRooms < MaxRooms do
		
		print("Running")
		wait(.5)
		
		if tick() - lastGenerated > 2 then
			print("Error... Retrying")
			game.Workspace.GeneratedRooms:ClearAllChildren()
			Generate(startingPos, MaxRooms)
			return
		end
	end
	
	warn("Done")
	
	
end

Generate(Vector3.new(0,40,0), 10)