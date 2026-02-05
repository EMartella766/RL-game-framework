local Agent = {}
Agent.__index = Agent

function Agent:new()
	
	self = {
		
		Q = {},
		
		--Fixed actions so we can directly store here
		actionMap = {
			chase = 0,
			search = 1,
			wait = 2,
		},
		
		--Use an index instead of strings
		--Strings take a lot of bytes to store
		--Reverse lookup for actions (if we want to access string states for debugging)
		reverseActionMap = {
			[0] = "chase",
			[1] = "search",
			[2] = "wait",
		},
		
		
		--States are generated dynamically
		stateMap = {},
		reverseStateMap = {},
		nextStateId = 0,
		
		--Parameters
		alpha = 0.9, --Learning rate: how fast Q-values update when new info arrives
		gamma = 0.9, -- Discount factor: How much future rewards matter
		epsilon = 0.2, -- Exploration rate: Probability of random exploration
	}
	
	setmetatable(self, Agent)
	return self
end

--Q values: Expected reward for taking an action in that state (stored expectations)

--Q-table: The agent's "memory"
--Each entry answers "if I am in this state and take this action how good would that be?"
--Q("3-7", "lower") = 0.42 --> Expected reward

--Access Q-values
--Returns Q(s, a); unseen state-action pair defaults to 0
function Agent:getQ(stateID, actionID)
	self.Q[stateID] = self.Q[stateID] or {}
	return self.Q[stateID][actionID] or 0

end


--Nested table
--Running time O(1) --> Constant
--If we had rows we would have to go through each row making it linear


--Update Q-values
function Agent:setQ(stateID, actionID, value)
	self.Q[stateID] = self.Q[stateID] or {}
	self.Q[stateID][actionID] = value
end


--Retrieve Q table for dataStore
function Agent:getQTable()
	return self.Q
end


--Load Q table back in from data store
function Agent:setQTable(Q)
	self.Q = Q or {}
end


function Agent:getReverseActionMap(actionID)
	return self.reverseActionMap[actionID]
end



--get dynamically generated states and store them inside 
--StateMap and ReverseStateMap
function Agent:getStateMapID(state)
	
	--If we haven't seen this state before then generate a new ID for it
	if not self.stateMap[state] then
		self.stateMap[state] = self.nextStateId
		self.reverseStateMap[self.nextStateId] = state
		self.nextStateId += 1
	end
	
	return self.stateMap[state]
end


--Implement an epsilon greedy policy
function Agent:chooseAction(state)
	
	--Convert state to ID
	local stateID, _ = self:getStateMapID(state)

	--math.random() will return a random number between 0 and 1 which we compare against epsilon
	--if returned number is less than epsilon then we explore (ε)
	if math.random() < self.epsilon then
		--50% chance of exploring and picking to do a random action
		local actionIDs = {}
		
		for _, id in pairs(self.actionMap) do
			table.insert(actionIDs, id)
		end
		
		local randomActionId = actionIDs[math.random(#actionIDs)]
		return self:getReverseActionMap(randomActionId)
	end

	--else if returned number is greater than ε we exploit (1 - ε); use what we have learned

	--These Q-values estimate the expected future return if we were to take action a in state s
	--We store state-action values
	--The optimal action is not stored directly but it is derived by comparing Q-values
	--So the policy is the decision rule we derive from the state-action values (Q-values)
	
	--Exploitation, access state-action value and pick one with highest reward
	local bestActionID, bestQ = nil, - math.huge
	
	for actionName, actionID in pairs(self.actionMap) do
		local q = self:getQ(stateID, actionID)
		
		if q > bestQ then
			bestQ = q
			bestActionID = actionID
		end
	end
	
	--Convert states to give to enviroment back to strings
	return self:getReverseActionMap(bestActionID)
	
end


function Agent:update(state, action, reward, nextState)
	
	-- Get IDs for current state and next state
	local stateID = self:getStateMapID(state)
	local nextStateID = self:getStateMapID(nextState)
	
	--Get ID for action we just took
	local actionID = self.actionMap[action]
	
	local bestNextQ = -math.huge
	
	for nextActionName, nextActionID in pairs(self.actionMap) do
		local q = self:getQ(nextStateID, nextActionID)
		if q > bestNextQ then
			bestNextQ = q
		end
	end
	
	-- Last time I was in this state and did chose this action I thought it was worth X
	-- However after seeing what happend and what could come next
	-- It is probably worth more or less
	local oldQ = self:getQ(stateID, actionID)
	--The greater the error the less the reward
	local newQ = oldQ + self.alpha * (reward + self.gamma * bestNextQ - oldQ)
	
	self:setQ(stateID, actionID, newQ)
	
end


return Agent