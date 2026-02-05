local debugEvent = game:GetService("ReplicatedStorage").Agent.AIDebug

local frame = script.Parent:WaitForChild("Frame")
warn(frame)

print("RUNNING")

debugEvent.OnClientEvent:Connect(function(data)
	
	frame.State.Text = "State: ".. tostring(data.state or "N/A")
	frame.StateID.Text = "StateID: " .. tostring(data.stateID or "N/A")
	frame.Action.Text = "Action: " .. tostring(data.action or "N/A")
	frame.Reward.Text = "Reward: " .. string.format("%2f", data.reward or 0)
	frame.EpisodeReward.Text = "Episode Reward: " .. string.format("%2f", data.episodeReward or 0)
	frame.Episode.Text = "Episode: " .. tostring(data.episode or 0)
	frame.Epsilon.Text = "Epsilon: " .. string.format("%3f", data.epsilon or 0)
	
	if data.reward > 0 then
		frame.Reward.TextColor3 = Color3.fromRGB(0,255,0)
		
	elseif data.reward < 0 then
		frame.Reward.TextColor3 = Color3.fromRGB(255,0,0)
		
	else
		frame.Reward.TextColor3 = Color3.fromRGB(255,255,255)
	end
	
	
	
	
end)