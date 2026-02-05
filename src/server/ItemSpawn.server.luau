local workspace = game:GetService("Workspace")

local generatedRooms = workspace:WaitForChild("GeneratedRooms")

-- Wait until ALL rooms are generateed
local expectedRoomCount = 100
while #generatedRooms:GetChildren() < expectedRoomCount do
	task.wait(0.1)
end

local function getItemSpawnParts()
	local spawnPoints = {}
	for _, descendant in generatedRooms:GetDescendants() do
		if descendant:IsA("Part") and descendant.Name == "ItemSpawn" then
			table.insert(spawnPoints, descendant)
		end
	end
	return spawnPoints
end

local stableCount = 0
local lastCount = 0
while true do
	local spawnPoints = getItemSpawnParts()
	if #spawnPoints > 0 then
		if #spawnPoints == lastCount then
			stableCount = stableCount + 1	
		else
			stableCount = 0
			lastCount = #spawnPoints
		end
		-- Require the count to be stable for 10 consecutive checks (~1 second)
		if stableCount >= 10 then
			break
			
			
		end
	end
	task.wait(0.1)
end

local spawnPoints = getItemSpawnParts()

print("Found ItemSpawn parts:")

local replicatedStorage = game:GetService("ReplicatedStorage")
local lootFolder = replicatedStorage:FindFirstChild("Loot")

if not lootFolder then
	warn("Loot folder does not exist in ReplicatedStorage!")
	return
end

local function chooseSpawn(spawnList)
	if #spawnList == 0 then
		warn("No spawn points found!")
		return nil
	end
	return spawnList[math.random(1, #spawnList)]
end

local function chooseItem()
	local lootItems = lootFolder:GetChildren()
	if #lootItems == 0 then
		warn("No loot items found in Loot folder!")
		return nil
	end
	return lootItems[math.random(1, #lootItems)]
end

-- number of items that can spawn around the map (can change later)
local numItemsToSpawn = 30

--stores available spawns
local availableSpawns = {}
for i, v in spawnPoints do
	table.insert(availableSpawns, v)
end

for i = 1, numItemsToSpawn do
	local _spawn = chooseSpawn(availableSpawns)
	local item = chooseItem()

	if _spawn and item then
		local clone = item:Clone()
		
		-- controls position/spawn of item
		if clone:IsA("Model") or clone:IsA("Part") then
			clone:PivotTo(_spawn.CFrame)
			clone.Parent = workspace
			for idx, sp in availableSpawns do
				if sp == _spawn then
					table.remove(availableSpawns, idx)
					break
				end
			end
		else
			clone:Destroy()
		end
	else
	end
end