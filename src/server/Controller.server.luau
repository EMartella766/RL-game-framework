math.randomseed(os.clock())

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local serverScriptService = game:GetService("ServerScriptService")
local players = game:GetService("Players")

local environment = require(rs.Agent.Environment)
local agent = require(rs.Agent.Agent)
local persistence = require(rs.Agent.DataStore)

local debugEvent = game:GetService("ReplicatedStorage").Agent.AIDebug

local monster = agent:new()
local env
local totalReward = 0
local episodeCount = 0
local monsterId = "Monster1"

local timeSinceSave = 0
local saveCooldown = 5

--Retrieve Q table from data store
local Q = persistence.load(monsterId)
monster:setQTable(Q)


-- Function to setup monster and environment
local function setupEnvironment(player)
	if not player.Character then
		player.CharacterAdded:Wait()
	end

	local monster1 = rs.Agent.Monster:Clone()
	monster1.Parent = workspace.Agent
	monster1:PivotTo(CFrame.new(0,2,0))

	-- Instantiate the environment
	env = environment:new(monster1, player)

	print("Environment created for player:", player.Name)
end


for _, player in pairs(players:GetPlayers()) do
	setupEnvironment(player)
end


runService.Heartbeat:Connect(function(dt)
	
	if not env then return end
	timeSinceSave += dt
	
	--Update environment perception
	env:update(dt)
	
	--Observe current state
	local state = env:getState()
	
	-- Convert to stateID ONCE
	local stateID = monster:getStateMapID(state)
	
	--Choose action
	local actionID = monster:chooseAction(state)
	
	-- Convert actionID → string (for Environment)
	local actionName = monster.reverseActionMap[actionID]

	
	--Apply action and observe reward
	local reward, done = env:step(actionName)
	totalReward += reward
	
	--Fire debug event
	debugEvent:FireAllClients({
		state = state,
		stateID = monster:getStateMapID(state), 
		action = actionID,
		reward = reward,
		episodeReward = totalReward,
		episode = episodeCount,
		epsilon = monster.epsilon
		})
	
	--Observe next state after the world has updated
	env:update(dt)
	local nextState = env:getState()
	local nextStateID = monster:getStateMapID(nextState)
	
	--Update the agent (Learn)
	monster:update(state, actionID, reward, nextState)
	
	--Include save cooldown to prevent dateStore throttling
	if done and timeSinceSave >= saveCooldown then
		warn("Saving Q-table")
		totalReward = 0
		episodeCount += 1
		timeSinceSave = 0
		
		
		--Save agent data
		persistence.save(monsterId, monster:getQTable())
	end
end)
