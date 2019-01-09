os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
os.loadAPI("/ThorneCC/apis/ThorneEvents.lua")
os.loadAPI("/ThorneCC/apis/GUI.lua")
os.loadAPI("/ThorneCC/apis/MidiAPI.lua")
os.loadAPI("/ThorneCC/apis/SoundAPI.lua")

local displayMenu, showSongs, loadSongs
local menu_main_items = {}
local menu_main_options = {}
local menu_song_items = {}
local menu_song_options = {}

function eventHandler (e, song)
    SoundAPI.ApplyMidiEvent(e, song)
end --func
function displayMenu ()
    local items = {
        {text = "== Stop Music ==", action = MidiAPI.Stop},
        {text = "== Pause Music ==", action = MidiAPI.Pause},
        {text = "== Play Music ==", action = MidiAPI.Play},
        {text = "Find Songs Online", action = searchMenu},
        {text = "Pick Song", action = showSongs},
        {text = "Delete Songs (to save room)", action = deleteMenu},
    }
    local options = {header = "Main Menu", center = true}
    GUI.Menu(items, options)
end --func
function showSongs()
    local items = {
        {text = "== Return ==", suspension = "stop", action = displayMenu},
        {text = "== Stop Music ==", action = MidiAPI.Stop},
        {text = "== Pause Music ==", action = MidiAPI.Pause},
        {text = "== Play Music ==", action = MidiAPI.Play},
    }
    local songs = MidiAPI.GetSongList()
    for k,v in pairs(songs) do
        table.insert(items, {
            text = v,
            action = function()
                ThorneEvents.Subscribe(keyWatcher, "keyWatcherMidi")
                MidiAPI.PlaySong(k, eventHandler)
            end,
            suspension = "continue"
        })
    end --for
    local options = {header = "Song List"}
    GUI.Menu(items, options)
end --func
function keyWatcher()
    repeat
        ev, key = os.pullEvent("key")
    until key == 14
    MidiAPI.Stop()
end --func
function loadSongs()
    MidiAPI.LoadAllSongs()
end --func

function makeASearch()
    while true do
        print("Type Quit to quit")
        print("Search Terms:")
        term.write("search> ")
        local input = read()
        if (string.lower(input) == "quit") then return end
        local url = ("http://www.midiworld.com/search/?q="..string.gsub(input, " ","+"))
        handle = http.get(url)
        fullText = handle.readAll()
        handle.close()

        local nameList = {}
        local urlList = {}
        local sel = false
        for name,url in string.gmatch(fullText, "<li>\n(.-) %- <a href=\"(.-)\".->download</a>\n") do
            name = string.gsub(name, " ", "_")
            if (not fs.exists("/ThorneCC/data/music/midi/"..name..".mid")) then
                name = string.gsub(name, "_", " ")
                table.insert(nameList, name)
                table.insert(urlList, url)
                sel = true
            end --if
        end
        if (not sel) then
            print("No songs with that search term.")
        else
            while (sel) do
                local options = {
                    title = "=== Pick Some Songs ==="
                }
                sel = GUI.SimpleSelectionScreen(nameList, 1, options)
                if (sel) then
                    local name = table.remove(nameList, sel)
                    local url = table.remove(urlList, sel)
                    name = string.gsub(name," ","_")
                    shell.run("wget", url, "/ThorneCC/data/music/midi/"..name..".mid")
                    print("Loading song")
                    loadSongs()
                    print("Loaded")
                    os.pullEvent("key")
                end --if
            end --while
            term.clear()
        end --if
    end --while
end --func

function searchMenu()
    term.clear()
    term.setCursorPos(1,1)
    print("Hello.  Welcome to the Midi Downloader.")
    print("Here's how it works.")
    print("You'll enter a search term, and I'll look for songs online and try to download the ones you chose.")
    print("On the song list, hit backspace to refuse them.")
    print("Here's a few examples.")
    print(">")
    print("> Wish")
    print("> video game")
    print("> Rap")
    print("> anthem")
    
    makeASearch()
end --func

function deleteMenu()
    local arr = {}
    for i,name in ipairs(fs.list("/ThorneCC/data/music/midi/")) do
        table.insert(arr, name)
    end --for
    repeat
        local options = {
            title = "Delete Songs (to save room)",
        }
        local sel = GUI.SimpleSelectionScreen(arr, 1, options)
        if (sel) then
            local name = table.remove(arr, sel)
            fs.delete("/ThorneCC/data/music/midi/"..name)

        end --if
    until not sel
end --func

GUI.DisplayImage("logo")
print("Loading Songs")
loadSongs()
displayMenu()
-- GUI.DisplayImage("logo")
-- os.pullEvent("key")
-- term.clear()
-- term.setCursorPos(1,1)