os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
os.loadAPI("/ThorneCC/apis/GUI.lua")
os.loadAPI("/ThorneCC/apis/MusicAPI.lua")
os.loadAPI("/ThorneCC/apis/ThorneEvents.lua")

local soundEventIndex = "music"
local menuEventIndex = "TranceMenu"

local config = {
    bars = {
        "|....._._|",
        "|.___._._|",
        "|._._._._|",
        "|_._._._.|",
        "|.___.___|",
        "|__.___._|",
        "|..__..__|",
        "|__..__..|",
        "|________|",
    },
    notesMain = {1,3,8,10,13,15,20,22}, --D,E,G,A
    notesAlt = {
        {0,5,7,12,17,19,24}, --C#,F#,B
        {4,6,11,16,18,23}, --C,F,Bb
    },
    numMainTracks = 3,
    numAltTracks = 3,
    instrumentsAvailable = {table.unpack(MusicAPI.config.instruments)},
    minVol = .5,
    maxVol = 1,
}

local tracks = {}

function newTrack(isAlt, altSet)
    local o = {
        instrument="harp",
        measure = {},
        repeatsLeft = 0,
        isAlt = isAlt
    }
    local n = table.getn(config.instrumentsAvailable)
    local m = table.getn(config.bars)
    o.instrument = config.instrumentsAvailable[math.random(1,n)]
    o.repeatsLeft = math.random(2,8)

    local baseBar = config.bars[math.random(1,m)]
    local i = 0
    for char in baseBar:gmatch(".") do
        if (char == ".") then
            local notesAvailable = {table.unpack(config.notesMain)}
            if (isAlt) then
                table.insert(notesAvailable, table.unpack(config.notesAlt[altSet or 1]))
            end --if
            local n = math.random(1,table.getn(notesAvailable))
            o.measure[i] = {
                instrument = o.instrument,
                pitch = notesAvailable[n],
                volume = math.random(config.minVol*100,config.maxVol*100) / 100
            }
        end --if
        i = i + 1
    end --for
    return o
end --func

function tranceRoutine()
    repeat
        local i = 1
        for _=1,config.numMainTracks do
            if (not tracks[i] or tracks[i].repeatsLeft == 0) then
                tracks[i] = newTrack(false)
            end --if
            tracks[i].repeatsLeft = tracks[i].repeatsLeft - 1
            i = i + 1
        end --for
        for _=1,config.numAltTracks do
            if (not tracks[i] or tracks[i].repeatsLeft == 0) then
                tracks[i] = newTrack(true, 1)
            end --if
            tracks[i].repeatsLeft = tracks[i].repeatsLeft - 1
            i = i + 1
        end --for
        for pos = 1,8 do
            for i=1,(config.numMainTracks+config.numAltTracks) do
                if (tracks[i].measure[pos]) then
                    MusicAPI.playNote(tracks[i].measure[pos].pitch,tracks[i].measure[pos].instrument,tracks[i].measure[pos].volume)
                end --if
            end  --for
            ThorneEvents.sleep(.25)
        end --for
    until false
end --func

function menuRoutine()
    lines = {
        "Exit Program",
        "Start Trance",
        "Stop Trance",
    }
    selection = GUI.SimpleSelectionScreen(lines, 1)
    if (selection == 1) then
        ThorneEvents.UnSubscribe(menuEventIndex)
        ThorneEvents.UnSubscribe(soundEventIndex)
    end --if
    if (selection == 2) then
        ThorneEvents.UnSubscribe(soundEventIndex)
        ThorneEvents.SubscribeOnce(tranceRoutine, soundEventIndex)
    end --if
    if (selection == 3) then
        ThorneEvents.UnSubscribe(soundEventIndex)
    end --if
end --func

MusicAPI.runSetup(true)
screen = "select"
GUI.DisplayImage("logo")
os.startTimer(2)
GUI.WaitForEvent({'key', 'timer'})
term.clear()
ThorneEvents.Subscribe(menuRoutine, menuEventIndex)

-- local tracks = {}
-- for i=1,20 do
--     table.insert(tracks, newTrack())
-- end --for
-- GUI.LookAtObject(tracks)