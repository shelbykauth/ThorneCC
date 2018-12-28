function LoadAPIs()
    os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
    os.loadAPI("/ThorneCC/apis/GUI.lua")
    os.loadAPI("/ThorneCC/apis/MidiAPI_Blargh.lua")
    os.loadAPI("/ThorneCC/apis/SoundAPI.lua")
    
    MidiAPI = MidiAPI_Blargh
    speakers = SoundAPI.FindSpeakers()
    MidiAPI.AttachHandler(eventHandler, "NotePitchIndicator")
    GUI.DisplayImage("logo")    
    MidiAPI.LoadAllSongs("/")
end --func
LoadAPIs()
-- GUI.LookAtObject(speakers)

x,y = term.getSize()
p = x / 128
function eventHandler(event, track, song)
    if (event.type == "Midi") then
        if (event.midiType == "9") then
            print(event.channel)
            local chan = track.channels[event.channel]
            --term.setCursorPos(p*event.data[1], y)
            --print("#")
            SoundAPI.MidiNoteOn(chan.instrument, event.data[1], event.data[2])
        end --if
    end --if
end --func

local songList = MidiAPI.GetLoadedSongs()
local songIds = {}
local menuItems = {
    [1] = {
        text = "Stop Music",
        action = MidiAPI.Stop,
    },
    [2] = {
        text = "Reset APIS",
        action = LoadAPIs
    }
}
for k,v in pairs(songList) do
    table.insert(menuItems, {
        text=v,
        action=function()
            MidiAPI.Play(k)
        end,
        suspension = "continue",
    })
end --for

GUI.Menu(menuItems)