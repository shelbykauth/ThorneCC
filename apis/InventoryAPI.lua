local dataPath = "/ThorneCC/data/inventory/"
local settingsPath = dataPath.."settings.dat"
local stockPath = dataPath.."stock/"
local chestListPath = dataPath.."chestList.dat"
local itemListPath = dataPath.."itemList.dat"
local mySettings = {}
local myChestList = {}
local myItemList = {} -- complete array of all rawNames
local displayedItemList = {} -- partial array of displayed items, as rawNames
local displayedItemLines = {} -- partial array of displayed items, as formatted lines
local availableChests = {}
local locationsList = {}
os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")


function start ()
    loadSettings ()
    loadChests()
    loadItemList()
    resetChestList()
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
        myChestList = ThorneAPI.LoadObject(chestListPath, {}, true)
    end --if
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

function recordItemAt (chestName, slot)
    local meta = peripheral.call(chestName, "getItemMeta", slot)
    if (meta == nil) then
        locationsList[chestName][slot] = nil
        return false
    end --if
    if (locationsList[chestName][slot] ~= meta.rawName) then
        verifyItemLocatons(locationsList[chestName][slot])
        locationsList[chestName][slot] = meta.rawName
    end --if
    local stored = loadItem(meta.rawName)
    if (stored == nil) then
        stored = {
            name = meta.name,
            rawName = meta.rawName,
            displayName = meta.displayName,
            maxCount = meta.maxCount,
            ores = meta.ores,
            locations = {
                --{chest, slot, count, extraInfo},
            }
        }
        myItemList = ThorneAPI.LoadObject(itemListPath, {}, true)
        table.insert(myItemList, meta.rawName)
        ThorneAPI.SaveObject(myItemList, itemListPath)
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
    ThorneAPI.SaveObject(stored, stockPath..meta.rawName..".dat")
    myItemList[meta.rawName] = true
end --function

function verifyItemLocatons (rawName)
    local item = loadItem(rawName)
    if (not item) then return false end
    for k,v in pairs(item.locations) do
        actualItem = peripheral.wrap(v.chest).getItemMeta(v.slot)
        if (actualItem == nil) then
            item.locations[k] = nil
        elseif (actualItem.rawName ~= rawName) then
            item.locations[k] = nil
            recordItemAt(v.chest, v.slot)
        end --if
    end --for
    ThorneAPI.SaveObject(item, stockPath..rawName..".dat")
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
    found = (startChestName == nil)
    for name,slots in locationsList do
        found = found or (name == startChestName)
        for slot,item in slots do
            if (found and item == nil and name ~= mySettings.RetrievalChest) then
                return name, slot
            end --if
            if ((startChestName == name and slot == startSlot)) then
                found = true
            end --if
        end --for
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
    for k,v in pairs(locationsList) do
        locationsList[k] = {}
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
            locationsList[v] = {}
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

function getDisplayLine(rawName)
    local width, height = term.getSize()
    item = loadItem(rawName)
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
    for k,v in pairs(myItemList) do
        table.insert(displayedItemList, v)
        table.insert(displayedItemLines, getDisplayLine(v))
    end --for
    local controls = {
        key = {
            [keys.s] = sortScreen,
            [keys.i] = itemInfoScreen,
            [keys.up] = 'stepUp',
            [keys.down] = 'stepDown',
            [keys.enter] = itemInfoScreen,
            [keys.backspace] = 'escape',
            [keys.left] = dumpItem,
            [keys.right] = retrieveItem
        },
    }
    local options = {
        title = "Item List: "..table.getn(displayedItemList).." items available (stored/retrieved)",
        footer = {"(I)nfo (F)ind (S)ort (H)elp"},
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

function dumpItem(selection)
    local item = loadItem(displayedItemList[selected])
    for k,v in item.locations do
        if (v.chest == mySettings.RetrievalChest) then

        end --if
    end --for
end --function

function retrieveItem(selection)

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
    sortBy(lines[selection])
end --function

function sortBy(key)
    --TODO: Make sortBy function
    --      It will mutate the actual myItemList table, the displayedItems table,
    --      and the table that links displayedItems to the rawNames.
    --table.sort(displayedItemList)
    --
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
            return a < b
        end, -- function
        ["OreDictionary"] = function(a, b)
            local itemA = loadItem(a)
            local itemB = loadItem(b)
            return string.lower(itemA.ores and itemA.ores[1] or "") < string.lower(itemB.ores and itemB.ores[1] or "")
        end, -- function
    }
    if (not sortFunctions[key]) then
        return false
    end --if
    ThorneAPI.LoadingScreen("Sorting Inventory List")
    table.sort(displayedItemList, sortFunctions[key])
    for k in pairs(displayedItemLines) do
        displayedItemLines[k] = nil
    end --for
    for k,v in ipairs(displayedItemList) do
        displayedItemLines[k] = getDisplayLine(v)
    end --for
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
