-- StarterPlayer/StarterPlayerScripts/LocalScript.lua

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local rs = game:GetService("ReplicatedStorage")
local clickEvent = rs:WaitForChild("ClickEvent")

game.StarterPack.MetalRod.Activated:Connect(function()
	
	mouse.Button1Down:Connect(function()
		local model = mouse.Target:FindFirstAncestorOfClass("Model")
	
		if model then
			local clickedPlayer = game.Players:GetPlayerFromCharacter(model)
		
			if clickedPlayer then
				clickEvent:FireServer(clickedPlayer)
			end	
		end
	end)
end)
