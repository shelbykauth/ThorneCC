os.loadAPI("/ThorneCC/apis/GUI.lua")
os.loadAPI("/ThorneCC/apis/StorageAPI.lua")

function displayMenu()
    local lines = {
        "Load Data",
        "Save Data",
        "List Locations",
        "List Items",
        "Recount",
        "Find Locations",
        "Quit",
    }
    local selection = 5
    local options = {
        title="SimpleStorage | Menu"
    }
    selection = GUI.SimpleSelectionScreen(lines, selection, options)
    print(selection)
    print(actions[selection])
    actions[selection]()
end --func

function listLocations()
    local lines = StorageAPI.getLocationList()
    local options = {
        title = "Locations"
    }
    selection = GUI.SimpleSelectionScreen(lines, selection, options)
    GUI.LookAtObject(StorageAPI.getLocationDetails(lines[selection]))
end

function listItems()

end

actions = {
    StorageAPI.loadData,
    StorageAPI.saveData,
    listLocations,
    listItems,
    StorageAPI.Recount,
    StorageAPI.FindLocations,
    error,
}

local selection = 1

repeat displayMenu() until false