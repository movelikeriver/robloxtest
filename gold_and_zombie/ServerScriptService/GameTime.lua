--ServerScriptService/GameTime.lua

local gamerunning = game.ServerStorage.GameRunning
gamerunning = false
local gametime = game.ServerStorage.GameTime

while gamerunning == true do
	if gamerunning < 120 then
		gametime += 1
		wait(1)
	else 
		gamerunning = false
		gametime = 0
	end
end
