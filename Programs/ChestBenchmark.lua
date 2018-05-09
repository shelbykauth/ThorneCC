os.loadAPI("/ThorneCC/API/BenchmarkAPI.lua")

local tArgs = {...}
local chestName = tArgs[1]

function Wrapping ()
    c = peripheral.wrap(chestName)
end --function

local argsList = {}

argsList["wrapping"] = {{}}
for i = 1,27 do
    argsList["wrapping"][1][i] = i
end --for
BenchmarkAPI.FormatBenchmarkFunction("Chest Peripheral Wrapping", Wrapping, argsList["wrapping"])
