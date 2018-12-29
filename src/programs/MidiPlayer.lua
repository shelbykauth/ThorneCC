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
        {text = "Load Songs", action = loadSongs},
        {text = "Pick Song", action = showSongs},
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

GUI.DisplayImage("logo")
displayMenu()
-- GUI.DisplayImage("logo")
-- os.pullEvent("key")
-- term.clear()
-- term.setCursorPos(1,1)