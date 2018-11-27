os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
os.loadAPI("/ThorneCC/apis/GUI.lua")
--[[
    Author: Dartania Thorne
    Functionality:
        - Choose Music
        - Play Music
            - Play Song Once
            - Play Song Loop
            - Shuffle Songs
            - Play All Songs
            - Reorder songs?
        - Interrupt Music
        - Setup Speakers
]]--

local screen = ""

function setupScreen()
    local lines = {
        "Go Back",
        "Change Mode",
        "Setup Speakers",
        "Exit Program",
    }
    selection = ThorneAPI.SimpleSelectionScreen(lines)
end --func
function modeScreen()
    local lines = {
        "Play Once",
        "Play Loop",
        "Shuffle Songs",
    }
    selection = ThorneAPI.SimpleSelectionScreen(lines)
end --func
function selectSongScreen()
    local lines = {"   Exit Program   "}
    local songs = {false}
    local files = fs.list(MusicAPI.config.datapath)
    for i, path in ipairs(files) do
        local song = MusicAPI.loadSong(path)
        if (song) then
            table.insert(songs, song)
            table.insert(lines, i.." - "..song.title)
        end --if
    end --for
    selection = GUI.SimpleSelectionScreen(lines, 1)
    if (songs[selection]) then
        songs[selection]:play()
    elseif (selection == 1) then
        screen = "end"
    end --if
end --func

    
actions = {
    select = selectSongScreen,
    setup = setupScreen,
    mode = modeScreen,
}
screen = "select"
repeat
    actions[screen]()
until (screen == "end" or not actions[screen])