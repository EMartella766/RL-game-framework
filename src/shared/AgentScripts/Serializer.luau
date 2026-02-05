local Serializer = {}

--StateId --> int32 (4 bytes)
--ActionId --> int8 (1 byte)
--Q-value --> float32 (4 bytes)
--Each record --> 9 bytes

-- Memory management (buffer)

function Serializer.encode(Q)
	--return buffer
	--Convert string and signed integers into raw bytes
	--In other words a compact binary representation
	
	local entries = {}
	
	--flatten Q-table
	for stateID, actions in pairs(Q) do
		for actionID, value in pairs(actions) do
			table.insert(entries, {stateID, actionID, value})
		end
	end
	
	local entrySize = 9
	local buf = buffer.create(#entries * entrySize)
	
	local offset = 0
	
	for _, entry in ipairs(entries) do
		local stateID = entry[1]
		local actionID = entry[2]
		local value = entry[3]
		
		-- Safety check
		if type(stateID) ~= "number" or type(actionID) ~= "number" or type(value) ~= "number" then
			warn("Non-number detected in Q-table:", stateID, actionID, value)
			continue
		end

		
		buffer.writei32(buf, offset, stateID)
		offset += 4
		
		buffer.writei8(buf, offset, actionID)
		offset += 1
		
		buffer.writef32(buf, offset, value)
		offset += 4
	end
	
	return buf
	
end
	

function Serializer.decode(buffer)
	
	local Q = {}
	
	local entrySize = 0
	local bufferLength = buffer.len(buffer)
	
	local offset = 0
	
	while offset < bufferLength do
		local stateID = buffer.readi32(buffer, offset)
		offset += 4
		
		local actionID = buffer.readi8(buffer, offset)
		offset += 1
		
		local value = buffer.readf32(buffer, offset)
		offset += 4
		
		--Check if stateID is already in Q, if not insert nested table
		Q[stateID] = Q[stateID] or {}
		--Set Q value from read stateID and actionID pair
		Q[stateID][actionID] = value
	end
	
	return Q
	
end

return Serializer
