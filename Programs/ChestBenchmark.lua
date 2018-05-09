os.loadAPI("/thorne/BenchmarkAPI.lua")

local tArgs = {...}
local chestName = tArgs[1]

function Wrapping ()
    c = peripheral.wrap(chestName)
end --function
