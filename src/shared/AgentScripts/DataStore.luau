--Responsible for saving/loading Q table
--Agent memory + optimization
--Serialization

-- Why persistence.lua should not be a class
-- It doesn't learn nor update so it does not represent an entity in our world,
-- making it a service not an object
local Memory = {}
local serializer = require(script.Parent.Serializer)

local dataStoreService = game:GetService("DataStoreService")
local qTableDS = dataStoreService:GetDataStore("QTable")

--Workflow to store Q table:
--Environment --> Agent --> Serializer --> Data Store

function Memory.save(key, QTable)
	
	local success, error = pcall(function()
		--Store Qtable in data store
		--Serialize Qtable
		local bufferedData = serializer.encode(QTable)
		qTableDS:SetAsync(key, bufferedData)
	end)
	
	if not success then
		warn("Err Code #34: Qtable save failed ~ Desc: ", error)
	end
	
	return success
	--Could add RemoveAsync to remove old Qtable (for instance when new round starts)
end

function Memory.load(key)
	
	local success, result = pcall(function()
		--Load Qtable from data store
		local stored = qTableDS:GetAsync(key)
		--return deserialized qTable
		return stored and serializer.decode(stored) or nil
	end)
	
	if not success then
		warn("Err Code #35: Qtable load failed")
		return nil
	end
	
	--return Serialized data
	--Can store either as JSON or using Buffers
	--JSON stores it as lots of text while buffers store it
	--as raw bytes
	return result
	
	
end

return Memory