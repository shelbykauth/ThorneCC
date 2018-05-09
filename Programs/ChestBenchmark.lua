os.loadAPI("/ThorneCC/API/BenchmarkAPI.lua")

local tArgs = {...}
local chestName = tArgs[1]

function Wrapping (chest)
    c = peripheral.wrap(chest)
end --function

local argsList = {}

argsList["wrapping"] = {{chestName}}
argsList["slots"] = {{chestName}, {}}
for i = 1,27 do
    argsList["wrapping"][2][i] = i
end --for

print(BenchmarkAPI.FormatBenchmarkFunction("Chest Peripheral Wrapping", Wrapping, argsList["wrapping"]))
