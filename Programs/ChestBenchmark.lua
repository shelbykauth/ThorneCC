os.loadAPI("/ThorneCC/API/BenchmarkAPI.lua")

local tArgs = {...}
local chestName = tArgs[1]

function Wrapping ()
    c = peripheral.wrap(chestName)
end --function
