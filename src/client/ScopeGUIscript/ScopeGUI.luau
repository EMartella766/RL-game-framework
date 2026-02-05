local framework = require(game.ReplicatedStorage.Weapons.Framework)

local userInput = game:GetService("UserInputService")
local gui = script.Parent
local scopeImage = gui.Crosshair

gui.IgnoreGuiInset = true

function hasScope()
	
	if framework.module.hasScope == true then
		return true
	end
end


userInput.InputBegan:Connect(function(input)
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 and hasScope() then

		scopeImage.Visible = true
		print("Scoped in")

		--For recoil take change in x and y of camera.CFrame and then use it to offset position
	end

end)

userInput.InputEnded:Connect(function(input)
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 and hasScope() then

		scopeImage.Visible = false
		print("Scoped Out")

		
	end
end)