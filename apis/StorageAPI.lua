os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")

local dataPath = "/ThorneCC/data/storage/"
local configPath = "/ThorneCC/config/storage"


local ItemList = {}
local ChestList = {}
local TagList = {chests={},items={}}
local Config = ThorneAPI.LoadObject(configPath, {invalidTypes={},defaultTags={}}, true)

function saveData()
    ThorneAPI.SaveObject(ItemList, dataPath.."/items")
    ThorneAPI.SaveObject(ChestList, dataPath.."/locations")
    ThorneAPI.SaveObject(TagList, dataPath.."/tags")
end --func

function loadData()
    ItemList = ThorneAPI.LoadObject(dataPath.."/items", ItemList, true)
    ChestList = ThorneAPI.LoadObject(dataPath.."/locations", ChestList, true)
    TagList = ThorneAPI.LoadObject(dataPath.."/tags", TagList, true)
end --func

function getItemList(itemFilter)
    local list = {}
    if (itemFilter == nil) then itemFilter = {} end
    if (typeof(itemFilter) == 'string') then itemFilter = {name={itemFilter}} end
    for name,item in pairs(ItemList) do
        if (true) then
            table.insert(list, name)
        end --if
    end --for
    return list
end --func

function getLocationList(locationFilter)
    local list = {}
    for name,chest in pairs(ChestList) do
        if (true) then
            table.insert(list, name)
        end --if
    end --for
    return list
end --func

function getCountItems(itemFilter, locationFilter)

end --func

function getCountSpaces(locationFilter)

end --func

function setLocationTag(chestName, tag)

end --func

function getItemDetails(itemName)
    return ItemList[itemName]
end --func

function getLocationDetails(chestName)
    return ChestList[chestName]
end --func

function SetItemLocation(item, chestName, slot)
    ChestList[chestName][slot] = {
        name=item.name,
        damage=item.damage,
        nbtHash=item.nbtHash,
        count=item.count,
    }
    ItemList[item.name] = ItemList[item.name] or item
    local locations = ItemList[item.name].locations or {}
    local locale = item.nbtHash or "default"
        
    ItemList[item.name].locations = locations
end --func

function RecordItemAt(chestName, slot)

end --func

function Recount(locationFilter, newDetails)
    for chestName,chest in pairs(ChestList) do
        local oldItems = {}
        for i,item in pairs(chest.items) do
            oldItems[item.name] = true
        end --for
        local items = peripheral.call(chestName, "list")
        chest.items = items
        for i,item in pairs(items) do
            thisItem = ItemList[item.name] or {
                name=item.name
            }
        end --for
    end --for
end --func

function FindLocations()
    local peris = peripheral.getNames()
    for k,name in pairs(peris) do
        local type = peripheral.getType(name)
        local peri = peripheral.wrap(name)
        local valid = true
        if (not peri.size) then
            valid = false
        end --if
        for k,pat in pairs(Config.invalidTypes) do
            if valid and string.match(type, pat) then
                valid = false
            end --if
        end --for
        if (valid) then
            local tags={}
            for tag,pats in pairs(Config.defaultTags) do
                for i,pat in pairs(pats) do
                    if string.match(type, pat) then
                        tags[tag] = true
                    end --if
                end --if
            end --for
            ChestList[name] = ChestList[name] or {}
            ChestList[name].name = name
            ChestList[name].size = peri.size()
            ChestList[name].items = peri.list()
            ChestList[name].tags = tags
        end --if
    end --for
    saveData();
end --func

function Move(moveFilter)

end --func

function Store(chestName, itemFilter, count)

end --func

function Retrieve(chestName, itemFilter, count)

end --func

-- ITEM FILTER --
--[[
  - operation <and|or>
  - nbtHash
  - name
  - rawName
  - displayName
  - damage
  - metadata
  - itemTag
  - etc etc etc
]]--


-- LOCATION FILTER --
--[[
  - operation <and|or>
  - locationTag
  - chestName
]]


-- MOVE FILTER --
--[[
  - fromChest - Mandatory
  - toChest - Mandatory
  - itemFilter
  - fromSlot
  - toSlot
  - minCount - returns false if not enough
  - maxCount - only does a certain amount
  - multipleOf - ie multipleOf=7, maxCount=23, it will move 21 items 
  - maxStack - if there are two stacks of 32, maxCount=64, maxStack=1, it will only move one of the two stacks.
]]


-- Do stuff --
loadData();