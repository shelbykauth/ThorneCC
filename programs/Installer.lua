os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
os.loadAPI("/ThorneCC/apis/ThorneKeys.lua")

local lines = {
    "Inventory",
    "Shop",
    "Nevermind"
}
local selection = 2
local options = {
    title="What would you like to install on this computer?"
}
selection = ThorneAPI.SimpleSelectionScreen(lines, selection, options)
if (selection == 1) then
    fs.copy("/ThorneCC/programs/startup/just-inventory.lua", "startup")
end --if

os.reboot()
