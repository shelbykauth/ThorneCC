os.loadAPI("/ThorneCC/API/BenchmarkAPI.lua")

--local tArgs = {...}
--local chestName = tArgs[1]
local chestName, chest, speaker
if (chestName == nil) then
    for k,name in peripheral.getNames() do
        local peri = peripheral.wrap(name)
        if (peri.getTransferLocations) then
            chest = peri
            chestName = name
        end --if
        if (peri.playNote) then
            speaker = peri
        end --if
    end --for
end --if

function Wrapping (chest)
    local c = peripheral.wrap(chest)
end --function
function WrapAndGetItemMeta (chest, slot)
    local item = peripheral.wrap(chest).getItemMeta(slot)
end --function
function GetItemMeta (wrapped, slot)
    local item = wrapped.getItemMeta(slot)
end --function
function MoveItem (chest, a, b)
    chest.pullItem("self", a, 1, b)
end --function

local argsList = {}

argsList["wrapping"] = {{chestName}}
argsList["nameAndSlots"] = {{chestName}, {}}
argsList["wrapAndSlots"] = {{peripheral.wrap(chestName)}, {}}
for i = 1,27 do
    argsList["nameAndSlots"][2][i] = i
    argsList["wrapAndSlots"][2][i] = i
end --for
argsList["MoveItems"] = {{"self"}, {1,2,3,4,5,6,7,8,9}, 1, {1,2,3,4,5,6,7,8,9,10}}


print(BenchmarkAPI.FormatBenchmarkFunction("Chest Peripheral Wrapping", Wrapping, argsList["wrapping"]))
if (speaker) then speaker.playNote("Harp", 10, 15) end
print(BenchmarkAPI.FormatBenchmarkFunction("Wrap and getItemMeta", WrapAndGetItemMeta, argsList["nameAndSlots"], 100))
if (speaker) then speaker.playNote("Harp", 10, 15) end
print(BenchmarkAPI.FormatBenchmarkFunction("Wrap once and getItemMeta", GetItemMeta, argsList["wrapAndSlots"], 100))
if (speaker) then speaker.playNote("Harp", 10, 15) end
print(BenchmarkAPI.FormatBenchmarkFunction("MoveItems 1", MoveItem, argsList["moveItems"], 100))
if (speaker) then speaker.playNote("Harp", 10, 15) end
