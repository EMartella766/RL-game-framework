--Environment
--State --> describes where you are

--Responsible for applying action to the world
--Advancing the world by one step
--Computing the reward
--Telling us when the episode is over

--Store shared behaviour
--Represent multiple instances
local pathFindingService = game:GetService("PathfindingService")

local Environment = {}
Environment.__index = Environment


--constructor
function Environment:new(agent, player)
	
	--self table stores attributes
	--self refers to the agent instance
	--Each agent by default has these values (later updated in the methods below)
	local self = {
		
		agent = agent,
		player = player,
		
		playerPosition = nil,
		agentPosition = nil,
		--distance = infinite
		--if we used 0 then it's like saying both agent and player are at the same position
		distance = math.huge,
		
		playerSeen = false,
		--Same with distance, if this were 0 then it's like saying the agent has already seen the player
		timeLastSeen = math.huge,
		
		playerSpeed = 0,
		playerNoise = 0,
	}
	
	setmetatable(self, Environment)
	return self
end


function Environment:update(dt)
	self:updatePositions()
	self:updateDistance()
	self:updateLineOfSight()
	self:updateTimers(dt)
end


--State abstraction
--State: A compact summary of everything the agent needs to know to decide what to do next
--instead of relying on messy and complex values

-- If you were to use something like:
-- Q[distance = 17.38][angle = 42.1][velocity = 6.2][action]
-- We would have infinite states which would make it really difficult to learn
-- We would need a lot of memory to store all of these states and their values (Q table grows in side really quick)
-- Overfitting: The agent would only know how to act in situations it has seen exactly before so no generalization
-- This type of overfitting is also a lot worse compared to ML since you would usually have:
-- Finite datasets
-- Repeated samples
-- However in RL we have continous states:
-- Infinite states
-- never see the same one twice
-- State abstraction groups many similar world situations into one concept
-- Bias/ Variance trade off

-- Too little abstraction
-- High variance
-- Overfitting
-- No generalization

-- Too much abstraction
-- High bias
-- Agent cannot distinguish between different situations

-- So the goal is to have enough to generalize but not so much that meaning is lost#
-- For instance if we just had a state saying "player exists", this is too little information for the agent
-- Is the player far away or close by? Was the player seen or is he hidden?
-- Was he recently seen? Or did we lose sight of the player?
function Environment:getState(dt)
	
	local distanceState = 
		self.distance < 10 and "near" or
		self.distance < 30 and "mid" or
		"far"
	
	local visibilityState = self.playerSeen and "seen" or "hidden"
	
	local memoryState = 
		self.timeLastSeen < 2 and "recent" or
		self.timeLastSeen < 6 and "old" or
		"lost"
	
	return visibilityState .. "_" .. distanceState .. "_" .. memoryState
	
	--Example of how Q table will store different combination of state-action values Q(s,a)
	--Q["seen_near_recent"]["chase"] = 4.2
	--Q["hidden_mid_old"]["search"] = 1.1
	--Q["hidden_far_lost"]["wait"] = -0.6

end


function Environment:updatePositions()
	self.agentPosition = self.agent.PrimaryPart.Position
	self.playerPosition = self.player.Character.Torso.Position
end


function Environment:updateDistance()
	self.distance = (self.playerPosition - self.agentPosition).Magnitude
end


function Environment:updateLineOfSight()
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {self.agent}
	
	local direction = (self.playerPosition - self.agentPosition)
	local result = workspace:Raycast(self.agentPosition, direction.Unit * direction.Magnitude, params)
	
	if result and result.Instance:IsDescendantOf(self.player) then
		self.playerSeen = true
		self.timeLastSeen = 0
	else
		self.playerSeen = false
	end
	
end


function Environment:updateTimers(dt)
	if not self.playerSeen then
		self.timeLastSeen += dt
	end
end


function Environment:chasePlayer()
	
	local humanoid = self.agent:WaitForChild("Humanoid")
	local path = pathFindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true
	})
	
	local success, errorMessage = pcall(function()
		path:ComputeAsync(self.agent.PrimaryPart.Position, self.playerPosition)
	end)
	
	if success and path.Status == Enum.PathStatus.Success then
		for _,waypoint in pairs(path:GetWaypoints()) do
			--local part = Instance.new("Part")
			--part.Material = "Neon"
			--part.Anchored = true
			--part.CanCollide = false
			--part.Shape = "Ball"
			--part.Position = waypoint.Position
			--part.Parent = self.agent
			
			humanoid:MoveTo(waypoint.Position)
			
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end
			humanoid.MoveToFinished:Wait()
		end
	else
		warn(errorMessage)
		warn("The path was not created correctly")
	end
end


--Apply action to environment and return reward along with termination flag
function Environment:step(action)
	
	local reward = 0
	local episodeDone = false

	if action == "chase" then
		--Apply pathfinding service
		self:chasePlayer()
		
	elseif action == "search" then
		--Wandering, looking for players
		reward -= 0.05
		
	elseif action == "wait" then
		reward -= 0.1
	end
	
	--If agent sees player, reward it
	if self.playerSeen then
		reward += 0.5
	end
	
	--If agent catches player then reward it
	if self.distance < 3 then
		reward += 10
		episodeDone = true
	end
	
	return reward, episodeDone
	
	
end

return Environment