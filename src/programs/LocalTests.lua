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
    print("=== Testing Midi ===")
    MidiAPI.loadMidiWithGUI("/ThorneCC/data/music/songs/HotelCalifornia.mid")
    print("Not Failing")
end --func



os.loadAPI("/ThorneCC/apis/GUI.lua")
-- SELECT TEST --
lines = {
    "Character Print Test",
    "ThorneEvents Test",
    "Midi Tests",
}
actions = {
    CharacterTest,
    EventsTest,
    MidiTest,
}
local selection = GUI.SimpleSelectionScreen(lines)
if(actions[selection]) then
    actions[selection]()
end --if