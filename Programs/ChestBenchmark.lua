os.loadAPI("/ThorneCC/API/BenchmarkAPI.lua")

local tArgs = {...}
local chestName = tArgs[1]

function Wrapping (chest)
    local c = peripheral.wrap(chest)
end --function
function WrapAndGetItemMeta (chest, slot)
    local item = peripheral.wrap(chest).getItemMeta(slot)
end --function
function GetItemMeta (wrapped, slot)
    local item = wrapped.getItemMeta(slot)
end --function

local argsList = {}

argsList["wrapping"] = {{chestName}}
argsList["nameAndSlots"] = {{chestName}, {}}
argsList["wrapAndSlots"] = {{peripheral.wrap(chestName)}, {}}
for i = 1,27 do
    argsList["nameAndSlots"][2][i] = i
    argsList["wrapAndSlots"][2][i] = i
end --for

print(BenchmarkAPI.FormatBenchmarkFunction("Chest Peripheral Wrapping", Wrapping, argsList["wrapping"]))
print(BenchmarkAPI.FormatBenchmarkFunction("Wrap and getItemMeta", WrapAndGetItemMeta, argsList["nameAndSlots"], 100))
print(BenchmarkAPI.FormatBenchmarkFunction("Wrap once and getItemMeta", GetItemMeta, argsList["wrapAndSlots"], 100))
