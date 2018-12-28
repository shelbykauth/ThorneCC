function CharacterTest()
    print("===Character Test===")
    local sq = 16
    for i=0,sq-1 do
        local line = ""
        for j=0,sq-1 do
            line = line..string.char(i*sq+j)
        end --for
        print(line)
    end --for
end --func

function EventsTest()
    os.loadAPI("ThorneCC/apis/ThorneEvents.lua")
    local speaker
    for _,name in ipairs(peripheral.getNames()) do
        if (peripheral.getType(name)) then
            speaker = peripheral.wrap(name)
        end --if
    end --for
    function a()
        -- local myID = os.startTimer(.2)
        -- repeat
        --     _,id = os.pullEvent("timer")
        -- until id == myID
        ThorneEvents.sleep(.2)
        speaker.playNote("harp", 10, math.random(0,24))
    end --func
    function b()
        -- local myID = os.startTimer(.5)
        -- repeat
        --     _,id = os.pullEvent("timer")
        -- until id == myID
        ThorneEvents.sleep(.5)
        print(math.random(0,100000000))
    end --func
    function c()
        -- local myID = os.startTimer(10)
        -- repeat
        --     _,id = os.pullEvent("timer")
        -- until id == myID
        ThorneEvents.sleep(10)
        ThorneEvents.Reset()
    end --func
    function d()
        -- local myID = os.startTimer(.5)
        -- repeat
        --     _,id = os.pullEvent("timer")
        -- until id == myID
        ThorneEvents.sleep(.6)
        print(redstone.getInput("right"))
    end --func
    function start()
        iA = ThorneEvents.Subscribe(a, "alpha")
        iB = ThorneEvents.Subscribe(b, "beta")
        iC = ThorneEvents.Subscribe(c, "gamma")
        iD = ThorneEvents.Subscribe(d, "delta")
        print("All Started - ", iA, iB, iC)
    end --func
    ThorneEvents.SubscribeOnce(start)
end --func

function MidiTest()
    os.loadAPI("/ThorneCC/apis/MidiAPI.lua")
    os.loadAPI("/ThorneCC/apis/SoundAPI.lua")
    SoundAPI.FindSpeakers()
    
    print("=== Testing Midi ===")
    print("First Song: Ring Of Fire")
    song1 = MidiAPI.LoadSong("/ThorneCC/data/music/songs/RingOfFire.mid")
    --MidiAPI.DebugTrack(song1.tracks[12], song1)
    MidiAPI.preprocessSong(song1)    
    
    print("=== Testing Midi ===")
    print("Second Song: Hotel California")
    song2 = MidiAPI.LoadSong("/ThorneCC/data/music/songs/HotelCalifornia.mid")
    MidiAPI.preprocessSong(song2)

    print("=== Playing Songs ===")
    MidiAPI.PlaySong(song2)
    -- lines = {'1','2','3','4','5','6','7','8','9','10','11','12'}
    -- sel = GUI.SimpleSelectionScreen(lines)
    -- if (sel) then
    --     print ("Track",sel)
    --     MidiAPI.DebugTrack(song1.tracks[sel])
    -- end --if
end --func



os.loadAPI("/ThorneCC/apis/GUI.lua")
-- SELECT TEST --
lines = {
    "Midi Tests",
    "Character Print Test",
    "ThorneEvents Test",
}
actions = {
    MidiTest,
    CharacterTest,
    EventsTest,
}
local selection = GUI.SimpleSelectionScreen(lines)
if(actions[selection]) then
    actions[selection]()
end --if