local dataPath = "/ThorneCC/data/inventory/"
local settingsPath = dataPath.."settings.dat"
local stockPath = dataPath.."stock/"
local chestListPath = dataPath.."chestList.dat"
local itemListPath = dataPath.."itemList.dat"
local locationListPath = dataPath.."locationList.dat"
local mySettings = {}
local myChestList = {}
local myItemList = {} -- complete array of all rawNames
local displayedItemList = {} -- partial array of displayed items, as rawNames
local displayedItemLines = {} -- partial array of displayed items, as formatted lines
local availableChests = {}
local myLocationList = {}
local myDisplayFilters = {}
local myDisplaySort = ""
os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")


function start ()
    resetChestList()
    loadStoredData()
end --function

function loadStoredData()
    loadSettings()
    loadChests()
    loadItemList()
    loadLocations()
end --function

function saveStoredData()
    saveSettings({})
    ThorneAPI.SaveObject(myChestList, chestListPath)
    ThorneAPI.SaveObject(myItemList, itemListPath)
    ThorneAPI.SaveObject(myLocationList, locationListPath)
end --function

function reset (andRestart)
    fs.delete(dataPath)
    fs.makeDir(dataPath)
    fs.makeDir(stockPath)
    if (andRestart) then start() end
end --function

function loadSettings ()
    defaultSettings = {
        RetrievalChest = "",
        DumpDelay = .1,
        StartMode = "retrieve",
        CurrentMode = "retrieve",
        SortBy = "",
        FilterBy = {},
        Password = "",
        AllowAccess = true,
        LockDelay = 1,
    }
    savedSettings = ThorneAPI.LoadObject(settingsPath, defaultSettings, true)
    for k,v in pairs(defaultSettings) do
        if (savedSettings[k] == nil) then
            savedSettings[k] = v
        end --if
    end --for
    saveSettings(savedSettings)
end --function

function loadItemList ()
    myItemList = ThorneAPI.LoadObject(itemListPath, {}, true)
end --function

function loadChests ()
    myChestList = ThorneAPI.LoadObject(chestListPath, nil, false)
    if (myChestList == nil) then
        resetChestList()
    end --if
end --function

function loadLocations()
    myLocationList = ThorneAPI.LoadObject(locationListPath, nil, false)
    if (myLocationList == nil) then
        myLocationList = {}
        for k,v in pairs(myChestList) do
            myLocationList[v] = {}
            s = peripheral.call(v, "size")
            for i=1,s do
                myLocationList[v][i] = "nil"
            end --for
        end --for
    end --if
    ThorneAPI.SaveObject(myLocationList, locationListPath)
end --function

function saveSettings(newSettings)
    for k,v in pairs(newSettings) do
        mySettings[k] = v
    end --for
    ThorneAPI.SaveObject(mySettings, settingsPath)
end --function

function loadItem (rawName)
    if (not rawName) then return false end
    local item = ThorneAPI.LoadObject(stockPath .. rawName .. ".dat", nil, false)
    if (item == nil) then return nil end
    local rCount = 0
    local sCount = 0
    for k,v in pairs(item.locations) do
        if (v.chest == mySettings.RetrievalChest) then
            rCount = rCount + v.count
        else
            sCount = sCount + v.count
        end --if
    end --for
    item.rCount = rCount
    item.sCount = sCount
    return item
end --function

function saveItem (item, identifier)
    if (item == nil) then
        error("expecting itemMeta object, argument 1", 2)
    end --if
    if (identifier == nil) then
        identifier = item.nbtHash or item.rawName
    end --if
    ThorneAPI.SaveObject(item, stockPath .. identifier .. ".dat")
end --function

function recordItemAt (chestName, slot)
    if (type(chestName) ~= 'string') then
        error ("bad argument #1, (chestName expected, got "..type(chestName)..")", 2)
    end --if
    if (type(slot) ~= 'number') then
        error ("bad argument #2, (slotNumber expected, got "..type(slot)..")", 2)
    end --if
    local meta = peripheral.call(chestName, "getItemMeta", slot)
    local former = myLocationList[chestName][slot]
    local identifier
    local storedItem
    if (meta == nil) then
        myLocationList[chestName][slot] = "nil"
        if (former ~= "nil") then removeItemLocation(former, chestName, slot) end
        return false
    end --if
    if (former ~= nil and former ~= "nil" and former ~= meta.rawName and former ~= meta.nbtHash) then
        local oldItem = loadItem(former)
        removeItemLocation(former, chestName, slot)
    end --if
    if (meta.nbtHash) then
        identifier = meta.nbtHash
    else
        identifier = meta.rawName
    end --if
    myLocationList[chestName][slot] = identifier
    storedItem = loadItem(identifier)
    if (storedItem == nil) then
        storedItem = {
            identifier = identifier,
            name = meta.name,
            rawName = meta.rawName,
            displayName = meta.displayName,
            maxCount = meta.maxCount,
            locations = {
                --{chest, slot, count, extraInfo},
            },
            meta = meta,
        }
        myItemList = ThorneAPI.LoadObject(itemListPath, {}, true)
        table.insert(myItemList, identifier)
        ThorneAPI.SaveObject(myItemList, itemListPath)
    end --if
    storedItem.locations[chestName .. "_Slot_" .. slot] = {
        chest = chestName,
        slot = slot,
        count = meta.count,
    }
    saveItem(storedItem, identifier)
    saveStoredData()
    --myItemList[identifier] = true
end --function

function removeItemLocation(identifier, chest, slot)
    myLocationList[chest][slot] = "nil"
    local item = loadItem(identifier)
    if (not item) then return end
    item.locations[chest .. "_Slot_" .. slot] = nil
    saveItem(item, identifier)
end --function

function verifyItemLocations (identifier)
    local item = loadItem(identifier)
    if (not item) then return false end
    for k,v in pairs(item.locations) do
        actualItem = peripheral.wrap(v.chest).getItemMeta(v.slot)
        if (actualItem == nil or (actualItem.rawName ~= identifier) or (actualItem.nbtHash ~= identifier)) then
            item.locations[k] = nil
            myLocationList[v.chest][v.slot] = "nil"
            recordItemAt(v.chest, v.slot)
        end --if
    end --for
    saveItem(item, identifier)
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
    loadLocations()
    found = (startChestName == nil)
    for name,slots in pairs(myLocationList) do
        found = found or (name == startChestName)
        for slot,item in ipairs(slots) do
            if (found and item == "nil" and name ~= mySettings.RetrievalChest) then
                return name, slot
            end --if
            if ((startChestName == name and slot == startSlot)) then
                found = true
            end --if
        end --for
    end --for
end --function

function getNextAvailableSpotIn(chestName, startSlot, identifier)
    loadLocations()
    for slot,item in ipairs(myLocationList[chestName]) do
        if (item == "nil") then
            return chestName, slot
        end --if
    end --for
end --function

function checkRetrieve ()

end --function

function checkDump()

end --function

function dumpFrom(fChest, fSlot)
    local tChest, tSlot = getNextAvailableSpot()
    from = peripheral.wrap(fChest)
    if (not from) then
        error ("fromChest not a valid peripheral", 2)
    end --if
    if (not tChest or not tSlot) then
        error ("getNextAvailableSpot() not returning valid results")
    end --if
    success = from.pushItems(tChest, fSlot, 64, tSlot)
    if (success) then
        recordItemAt(fChest, fSlot)
        recordItemAt(tChest, tSlot)
    end --if
    return success
end --function

function dumpAll()
    loadSettings()
    c = mySettings.RetrievalChest
    s = peripheral.call(c, 'size')
    fail = false
    for i=1,s do
        ThorneAPI.LoadingScreen("Dumping Inventory", (i-1) * 3, s * 3)
        if (not dumpFrom(c, i)) then
            fail = true
        end
    end --for
    if (fail) then
        os.pullEvent("key")
    end
    refreshItemLines()
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
    for k,v in pairs(myLocationList) do
        myLocationList[k] = {}
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
    if (not myLocationList) then
        myLocationList = {}
    end --if
    if (mainChest) then
        loc = mainChest.getTransferLocations()
        for k,v in ipairs(loc) do
            transferLocations[v] = true
        end --for
    end --if
    for k,v in ipairs(allPeripherals) do
        if (peripheral.wrap(v)).getTransferLocations then
            allChests[v] = true
            myLocationList[v] = {}
            if (transferLocations[v] or not mainChest) then
                table.insert(openChests, v)
            end --if
        end --if
    end --for
    ThorneAPI.SaveObject(openChests, chestListPath)
    loadChests()
end --function

function chooseRetrievalChest ()
    local peris = peripheral.getNames()
    local chests = {}
    local lines = {}
    local scroll = 0
    local selection = 1
    local options = {
        title = "Choose Which Chest To Retrieve Items From"
    }
    loadSettings()
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
    term.clear()
    selection = ThorneAPI.SimpleSelectionScreen(lines, selection, options)
    local newSettings = {RetrievalChest = chests[selection]}
    saveSettings(newSettings)
    resetChestList()
end --function

function getDisplayLine(identifier)
    local width, height = term.getSize()
    item = loadItem(identifier)
    local name = " " .. item.displayName
    local count = "("..item.sCount.."/"..item.rCount..")"
    if (string.len(name) < width - string.len(count)) then
        name = name .. string.rep(" ", width - string.len(count) - string.len(name))
    end --if
    if (string.len(name) > width - string.len(count)) then
        name = string.sub(name, 1, width - string.len(count) - 3) .. "..."
    end --if
    local line = name .. count
    return line
end --function

function listItems ()
    term.clear()
    loadItemList()
    displayedItemList = {}
    displayedItemLines = {}
    refreshItemLines()
    local controls = {
        key = {
            [keys.s] = sortScreen,
            [keys.i] = itemInfoScreen,
            [keys.d] = dumpAll,
            [keys.h] = helpScreen,
            [keys.r] = refreshRetrievalChest,
            [keys.up] = 'stepUp',
            [keys.down] = 'stepDown',
            [keys.enter] = itemInfoScreen,
            [keys.backspace] = 'escape',
            [keys.left] = dumpLine,
            [keys.right] = retrieveLine,
        },
    }
    local options = {
        title = "Item List: "..table.getn(displayedItemList).." items available (stored/retrieved)",
        footer = {"(D)ump (I)nfo (F)ind (S)ort (H)elp (R)efresh"},
        before = 0,
        after = 0,
    }
    ThorneAPI.ComplexSelectionScreen(displayedItemLines, 1, options, controls)
    term.clear()
    term.setCursorPos(1,1)
end --function

function itemInfoScreen(selected)
    local item = loadItem(displayedItemList[selected])
    local info = {}
    local match = string.gmatch(textutils.serialize(item), "[^\r\n]+")
    for l in match do
        table.insert(info, l)
    end --for
    ThorneAPI.SimpleSelectionScreen(info)
end --function

function dumpLine(selection)
    local item = loadItem(displayedItemList[selection])
    for k,v in pairs(item.locations) do
        if (v.chest == mySettings.RetrievalChest) then
            dumpFrom(v.chest, v.slot)
        end --if
    end --for
    refreshItemLines()
end --function

function retrieveLine(selection)
    retrieveItem(displayedItemList[selection], 1)
    refreshItemLines()
end --function

function retrieveItem(identifier, count)
    item = loadItem(identifier)
    if (not item) then
        error("valid identifier expected, got "..type(identifier).." "..identifer, 2)
    end --if
    if (not count) then count = 64 end
    for k,v in pairs(item.locations) do
        if (v.chest ~= mySettings.RetrievalChest) then
            retrieveFrom(v.chest, v.slot, count)
            break
        end --if
    end --for
    refreshItemLines()
end --function

function retrieveFrom(fChest, fSlot, count)
    if (not count) then count = 64 end
    local tChest, tSlot = getNextAvailableSpotIn(mySettings.RetrievalChest)
    from = peripheral.wrap(fChest)
    if (not from) then
        error ("fromChest not a valid peripheral", 2)
    end --if
    if (not tChest or not tSlot) then
        error ("getNextAvailableSpot() not returning valid results")
    end --if
    success = from.pushItems(tChest, fSlot, count, tSlot)
    if (success) then
        recordItemAt(fChest, fSlot)
        recordItemAt(tChest, tSlot)
    end --if
    return success
end --function

function refreshRetrievalChest()
    loadLocations()
    local size = table.getn(myLocationList[mySettings.RetrievalChest])
    for i=1,size do
        ThorneAPI.LoadingScreen("Rechecking Retrieval Chest", i, size)
        recordItemAt(mySettings.RetrievalChest, i)
    end --for
    refreshItemLines()
end --function

function refreshItemLines()
    loadItemList()
    for k,v in pairs(displayedItemList) do
        displayedItemList[k] = nil
    end --for
    for k,v in pairs(displayedItemLines) do
        displayedItemLines[k] = nil
    end --for
    for k,v in ipairs(myItemList) do
        table.insert(displayedItemList, v)
    end --for
    for k,v in ipairs(myDisplayFilters) do
        filterBy(v)
    end --for
    sortBy(mySettings.SortBy)
    for k,v in ipairs(displayedItemList) do
        table.insert(displayedItemLines, getDisplayLine(v))
    end --for
end --function

function helpScreen()

end --function

function sortScreen()
    --TODO: Make choice screen for all the sorting methods.
    --      It will call sortBy(key)
    local lines = {
        "Nevermind",
        "Display Name",
        "Id Name",
        "Raw Name",
        "OreDictionary",
    }
    local options = {
        title = "Choose a field to sort by."
    }
    local selection = 1
    selection = ThorneAPI.SimpleSelectionScreen(lines, selection, options)
    saveSettings({SortBy=lines[selection]})
    refreshItemLines()
end --function

function sortBy(key)
    --TODO: Make sortBy function
    --      It will mutate the actual myItemList table, the displayedItems table,
    --      and the table that links displayedItems to the rawNames.
    --table.sort(displayedItemList)
    --
    if (not key) then key = mySettings["SortBy"] end
    saveSettings({SortBy=key})
    sortFunctions = {
        ["Display Name"] = function(a, b)
            local itemA = loadItem(a)
            local itemB = loadItem(b)
            return string.lower(itemA.displayName) < string.lower(itemB.displayName)
        end, -- function
        ["Id Name"] = function(a, b)
            local itemA = loadItem(a)
            local itemB = loadItem(b)
            return string.lower(itemA.name) < string.lower(itemB.name)
        end, -- function
        ["Raw Name"] = function(a, b)
            local itemA = loadItem(a)
            local itemB = loadItem(b)
            return string.lower(itemA.rawName) < string.lower(itemB.rawName)
        end, -- function
        ["OreDictionary"] = function(a, b)
            local itemA = loadItem(a)
            local itemB = loadItem(b)
            return string.lower(itemA.meta.ores and itemA.ores[1] or "") < string.lower(itemB.ores and itemB.ores[1] or "")
        end, -- function
    }
    if (not sortFunctions[key]) then
        return false
    end --if
    ThorneAPI.LoadingScreen("Sorting Inventory List")
    table.sort(displayedItemList, sortFunctions[key])
end --function

function filterBy(filter)
    -- filter is {key, action, string}
    --TODO: Make filterBy Function
end --function

function filterScreen()
    --TODO: Make filterScreen
end --function

function recountEverything()
    resetItemLocations()
    resetChestList()
    totalSlots = 0
    currentSlots = 0
    for k,chestName in ipairs(myChestList) do
        local c = peripheral.wrap(chestName)
        local size = c.size()
        totalSlots = totalSlots + size
    end --for
    for k,chestName in ipairs(myChestList) do
        local c = peripheral.wrap(chestName)
        local size = c.size()
        for slot = 1,size do
            ThorneAPI.LoadingScreen("Recording Inventory Slots", currentSlots, totalSlots)
            recordItemAt(chestName, slot)
            currentSlots = currentSlots + 1
        end --for
    end --for
    ThorneAPI.LoadingScreen("Recording Inventory Slots", currentSlots, totalSlots)
    ThorneAPI.Alert()
end --function
