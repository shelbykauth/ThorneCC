local dataPath = "/ThorneCC/data/inventory/"
local settingsPath = dataPath.."settings.dat"
local stockPath = dataPath.."stock/"
local chestListPath = dataPath.."chestList.dat"
local itemListPath = dataPath.."itemList.dat"
local mySettings = {}
local myChestList = {}
local myItemList = {}
local availableChests = {}
os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")


function start ()
    loadSettings ()
    loadChests()
    loadItemList()
    resetChestList()
end --function

function reset (andRestart)
    fs.delete(dataPath)
    if (andRestart) then start() end
end --function

function loadSettings ()
    defaultSettings = {
        RetrievalChest = "",
        DumpDelay = .1,
        StartMode = "retrieve",
        CurrentMode = "retrieve",
        Password = "",
        AllowAccess = true,
        LockDelay = 1,
    }
    savedSettings = ThorneAPI.Load(settingsPath, defaultSettings, true)
    for k,v in pairs(defaultSettings) do
        if (savedSettings[k] == nil) then
            savedSettings[k] = v
        end --if
    end --for
    saveSettings(savedSettings)
end --function

function loadItemList ()
    myItemList = ThorneAPI.Load(itemListPath, {}, true)
end --function

function loadChests ()
    myChestList = ThorneAPI.Load(chestListPath, nil, false)
    if (myChestList == nil) then
        resetChestList()
        myChestList = ThorneAPI.Load(chestListPath, {}, true)
    end --if
end --function

function saveSettings(newSettings)
    for k,v in pairs(newSettings) do
        mySettings[k] = v
    end --for
    saveObject(mySettings, settingsPath)
end --function

function saveObject(obj, path)
    local file = fs.open(path, "w")
    file.write(textutils.serialize(obj))
    file.close()
end --function

function loadItem (rawName)
    return ThorneAPI.Load(stockPath .. rawName .. ".dat", nil, false)
end --function

function recordItemAt (chestName, slot)
    local meta = peripheral.call(chestName, "getItemMeta", slot)
    local stored = loadItem(meta.rawName)
    local file
    if (stored == nil) then
        stored = {
            name = meta.name,
            rawName = meta.rawName,
            displayName = meta.displayName,
            maxCount = meta.maxCount,
            ores = meta.ores,
            locations = {
                --chest, slot, count, extraInfo
            }
        }
        file = fs.open(itemListPath, "a")
        file.writeLine(meta.rawName)
    end --if
    if (meta.maxCount == 1) then
        -- Each thing needs its own information
        stored.locations[chestName .. "_Slot_" .. slot] = {
            chest = chestName,
            slot = slot,
            count = meta.count,
            extraInfo = meta,
        }
    else
        -- Store everything together
        stored.locations[chestName .. "_Slot_" .. slot] = {
            chest = chestName,
            slot = slot,
            count = meta.count,
        }
    end --if
    local f = fs.open(stockPath .. meta.rawName .. ".dat", "w")
    f.write(textutils.serialize(stored))
    f.close()
end --function

function getChestAndSlot(locationName)
    return string.match(locationName, "(.+)_Slot_(.+)")
    -- chestName, slot = getChestAndSlot(locationName)
end --function

function getFirstAvailableSpot(itemName)
    for chest,v in ipairs(myChestList) do
        local c = peripheral.wrap(chest)
        local size = c.size()
        for i = 1,size do
            local item = c.getItemMeta(i)
            if (item.count < item.maxCount) then

            end --if
        end --for
    end --for
end --function

function getNextAvailableSpot(startChestName, startSlot, itemName)
    local found = (chestName == nil)
    for k,chest in ipairs(myChestList) do
        local i1 = 1
        if (chestName == startChestName) then
            i1 = startSlot + 1
            found = true
        end --if
        if (found) then
            local c = peripheral.wrap(chest)
            local size = c.size()
            for i=i1, size do
                local item = c.getItemMeta(i)
                if (item.count < item.maxCount) then

                end --if
            end --for
        end --if
    end --for
end --function

function checkRetrieve ()

end --function

function checkDump()

end --function

function dump(chest, slot)

end --function

function retrieve(item, count, chest, slot)

end --function

function resetItemLocations()
    local list = fs.list(stockPath)
    for k,v in ipairs(list) do
        local f = fs.open(stockPath .. v, "r")
        local info = textutils.unserialize(f.readAll())
        f.close()
        info.locations = {}
        f = fs.open(stockPath .. v, "w")
        f.write(textutils.serialize(info))
        f.close()
    end --for
end --function

function resetChestList()
    -- It qualifies as a chest if it is on the peripheral.getNames chestList
        -- and has the methods "getTransferLocations"
    -- It is hidden if it's not on the list of mainChest.getTransferLocations
    local allPeripherals = peripheral.getNames()
    local transferLocations = {}
    local allChests = {}
    local openChests = {}
    local mainChest = peripheral.wrap(mySettings.RetrievalChest or "")
    if (mainChest) then
        loc = mainChest.getTransferLocations()
        for k,v in ipairs(loc) do
            transferLocations[v] = true
        end --for
    end --if
    for k,v in ipairs(allPeripherals) do
        if (peripheral.wrap(v)).getTransferLocations then
            allChests[v] = true
            if (transferLocations[v] or not mainChest) then
                table.insert(openChests, v)
            end --if
        end --if
    end --for
    local f = fs.open(chestListPath, "w")
    f.write(textutils.serialize(openChests))
    f.close()
    loadChests()
end --function

function chooseRetrievalChest ()
    local peris = peripheral.getNames()
    local chests = {}
    local lines = {}
    local scroll = 0
    local selection = 1
    local options = {
        before = 1,
        after = 1,
    }
    for k,v in ipairs(peris) do
        local p = peripheral.wrap(v)
        if (p.getTransferLocations) then
            table.insert(chests, v)
            table.insert(lines, v .. "("..peripheral.getType(v)..")")
            if (mySettings.RetrievalChest == v) then
                selection = table.getn(chests)
            end --if
        end --if
    end --for
    selection = ThorneAPI.SimpleSelectionScreen(lines, selection, options)
    local newSettings = {RetrievalChest = chests[selection]}
    saveSettings(newSettings)
    resetChestList()
end --function

function recountEverything()
    resetItemLocations()
    resetChestList()
    for k,chestName in ipairs(chestList) do
        local c = peripheral.wrap(chestName)
        local size = c.size()
        for slot = 1,size do
            recordItemAt(chestName, slot)
        end --for
    end --for
end --function
