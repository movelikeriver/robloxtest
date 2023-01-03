-- ServerScriptService/DamageTaking.lua

local rs = game:GetService("ReplicatedStorage")
local clickEvent = rs:WaitForChild("ClickEvent")

local damageamount = 10

clickEvent.OnServerEvent:Connect(function(player, clickedPlayer)
	clickedPlayer.Character.Humanoids:TakeDamage(damageamount)
	
end)