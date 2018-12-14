-- MidiAPI.lua
-- A Midi Parser (and maybe player?  I don't know yet)
os.loadAPI("/ThorneCC/apis/GUI.lua")
os.loadAPI("/ThorneCC/apis/MusicAPI.lua")

function hex(x)
    if (type(x) == 'string') then
        return tonumber(x, 16)
    elseif (type(x) == 'number') then
        if (x < 16) then
            return "0"..string.format("%x", x):upper()
        end --if
        return string.format("%x", x):upper()
    end --if
    return nil
end --func

function getNibbles(bytes)
    if type(bytes) ~= "table" then
        bytes = {bytes}
    end --if
    local nibbles = {}
    for i,by in pairs(bytes) do
        if type(by) == 'string' then by = hex(by) end
        local small = by%16
        local big   = by-small
        nibbles[i*2 - 1] = big
        nibbles[i*2] = small
    end --for
    return nibbles
end --func

function getStringFromBytes(bytes, m,n)
    if (not m) then m = 1 end
    if (not n) then n = table.getn(bytes) end
    return table.concat(bytes, "", m, n)
end --func

function getFixedWidthInt(bytes, i, s)
    if not i then i = 1 end
    if not s or s < i then s = i end
    local total = 0
    for n = i,s do
        total = total * 256 + bytes[n]
    end --for
    i = s + 1
    return total, i
end --func

function getVarWidthInt(bytes, i)
    if not i then i = 1 end
    local total = 0
    local stop = true
    repeat
        local b = bytes[i]
        if (type(bytes[i]) ~= 'number') then
            error("Incorrect Format.  Expected Byte Integer")
        end --if
        if (b > 127) then
            b = b - 128
            stop = false
        else
            stop = true
        end --if
        total = total * 128 + b
        i = i + 1
    until stop
    return total, i
end --func

function grabChunk(file)
    local chunk = {}
    chunk._type = ""
    chunk._length = 0
    chunk.bytes = {}
    for i=1,4 do
        local byte = file.read()
        if (not byte) then
            --file.close()
            return false
        end --if
        chunk._type = chunk._type .. string.char(byte)
    end --for
    for i=1,4 do
        chunk._length = chunk._length * 256 + file.read()
    end --for
    for i=1,chunk._length do
        chunk.bytes[i] = file.read()
    end --for
    return chunk
end --func

function applyMidiEvent(event, trackInstance, songInstance)
    --print(table.concat(event._data, ", "))
    local choice = event._subtype:sub(1,1)
    if (choice == "8") then
        print("Note Off.  Key:", event._data[1], " Velocity: ", event._data[2])
    elseif (choice == "9") then
        print("Note On.   Key:", event._data[1], " Velocity: ", event._data[2])
    elseif (choice == "A") then
        print("Midi Event...After Touch")
    elseif (choice == "B") then
        print("Midi Event...Controller Change")
    elseif (choice == "C") then
        print("Midi Event...Program Change")
    elseif (choice == "D") then
        print("Midi Event...Channel Key Pressure")
    elseif (choice == "E") then
        print("Midi Event...Pitch Bend")
    else
        print("Midi Event...Big ErRoR")
        print(textutils.serialize(event._allBytes))
        --os.pullEvent("key")
        return false, "OutOfSequence"
    end --if
    print(textutils.serialize(event._allBytes))
end --func

function applyMetaEvent(event, trackInstance, songInstance)
    local choice = event._subtype
    if (choice == "00x") then
        print("Sequence Number:", getFixedWidthInt(event._data, 1,2))
    elseif (choice == "01x") then
        print("Text Event:", string.char(table.unpack(event._data)))
    elseif (choice == "02x") then
        print("Copyright Notice:", string.char(table.unpack(event._data)))
    elseif (choice == "03x") then
        print("Track Name:", string.char(table.unpack(event._data)))
    elseif (choice == "04x") then
        print("Instrument Name:", string.char(table.unpack(event._data)))
    elseif (choice == "05x") then
        print("Lyric:", string.char(table.unpack(event._data)))
    elseif (choice == "06x") then
        print("Marker:", string.char(table.unpack(event._data)))
    elseif (choice == "07x") then
        print("Cue:", string.char(table.unpack(event._data)))
    elseif (choice == "20x") then
        local channelPrefix = event._data[1]
        print("Channel Prefix: channel", channelPrefix)
        -- trackInstance.channel = ""
    elseif (choice == "21x") then
        local portPrefix = event._data[1]
        print("Port Prefix: channel", channelPrefix)
        -- trackInstance.port = ""
    elseif (choice == "2Fx") then
        print("End Of Track")
        -- trackInstance.end()
    elseif (choice == "51x") then
        local msPerBeat = getFixedWidthInt(event._data, 1, 3)
        print("Set Tempo to:", msPerBeat)
        -- songInstance.tempo = msPerBeat
    elseif (choice == "54x") then
        print("SMTPE Offset:")
    elseif (choice == "58x") then
        local num = event._data[1]
        local den = math.pow(2, event._data[2])
        print("Time Signature:", num.."/"..den)
        print("    - MidiClocks per quarter note:", event._data[3])
    elseif (choice == "59x") then
        local keys = {
            [-7]="B",
            [-6]="Gb",
            [-5]="Db",
            [-4]="Ab",
            [-3]="Eb",
            [-2]="Bb",
            [-1]="F",
            [0]="C",
            [1]="G",
            [2]="D",
            [3]="A",
            [4]="E",
            [5]="B",
            [6]="F#",
            [7]="C#",
        }
        local key = "C"
        local majorMinor = "M"
        if (event._data[2] == 0) then
            key = keys[event._data[1]]
        else
            key = keys[event._data[1]+3] .. "m"
        end --if
        print("Key Signature:", key)
    elseif (choice == "7Fx") then
        print("Sequencer-Specific Meta-event")
    else
        print("Unknown Subtype "..choice)
        return false, "Unknown Subtype"
    end --if
    return true
end --func

function applySysexEvent(event, trackInstance, songInstance)
    print("Cannot Handle Sysex Events")
    return false, "Sysex Event"
end --func

function applyEvent(event, trackInstance, songInstance)
    if event._type == "Meta" then
        return applyMetaEvent(event, trackInstance, songInstance)
    elseif event._type == "Midi" then
        return applyMidiEvent(event, trackInstance, songInstance)
    elseif event._type == "Sysex" then
        return applySysexEvent(event, trackInstance, songInstance)
    end --if
end --func

function getEvent(bytes, start_index)
    local i = start_index
    if i >= table.getn(bytes) then
        return nil
    end --if
    local event = {
        deltaTime = 0,
        _type = "",
        _subtype = "",
        _byteLength = 0,
        _data = {},
        _allBytes = "",
        _dataString = "",
    }
    event.deltaTime, i = getVarWidthInt(bytes, i)
    event._firstByte = hex(bytes[i]):upper()
    i = i + 1
    if (event._firstByte == "FF") then
        event._type = "Meta"
        event._subtype = hex(bytes[i]) .. "x"
        event._byteLength, i = getVarWidthInt(bytes, i + 1)
    elseif (event._firstByte == "F0") then
        event._type = "Sysex"
        event._subtype = "F0x(SoE)"
        event._byteLength, i = getVarWidthInt(bytes, i)
    elseif (event._firstByte == "F7") then
        event._type = "Sysex"
        event._subtype = "F7x(Escape)"
        event._byteLength, i = getVarWidthInt(bytes, i)
    else
        event._type = "Midi"
        event._subtype = event._firstByte .. "x"
        if (event._subtype:find("^[CD]")) then
            event._byteLength = 1
        else
            event._byteLength = 2
        end --if
    end --if
    local end_index = i + event._byteLength - 1
    for j = i,end_index do
        if (not bytes[j]) then
            return event, j
        end --if
        table.insert(event._data, bytes[j])
    end --for
    for j = start_index, end_index do
        event._allBytes = event._allBytes .. hex(bytes[j]) .."x "
    end --for
    event._dataString = string.char(table.unpack(event._data))
    event.start_index = start_index
    event.end_index = end_index
    --event._allBytes = table.concat(bytes, ", ", start_index, end_index)
    return event, end_index + 1
end --func
local trackNumber = 0

function parseChunk(chunk, header)
    if (chunk._type == "MThd") then
        chunk.format = getFixedWidthInt(chunk.bytes, 1, 2)
        chunk.numTracks = getFixedWidthInt(chunk.bytes, 3, 4)
        -- division
        if (chunk.bytes[5] > 127) then
            error("Trouble Reading Midi File: File uses SMTPE division values.  Contact Dartania Thorne if you want this file supported.")
        else
            chunk.ticksPerQuarterNote = getFixedWidthInt(chunk.bytes, 5, 6)
        end --if
    end --if
    if (chunk._type == "MTrk") then
        chunk.events = {}
        local i = 1
        while (i < table.getn(chunk.bytes)) do
            event, i = getEvent(chunk.bytes, i)
            table.insert(chunk.events, event)
            --applyEvent(event)
            --GUI.LookAtObject(event)
        end --while
    end --if
    return chunk
end --func

function DebugTrack(track)
    print("==Debug==")
    --GUI.LookAtObject(track)
    local i = 1
    while (i < table.getn(track.events)) do
        event = track.events[i]
        applyEvent(event)
        local ev,key = os.pullEvent("key")
        if (key == 28) then -- enter key
            i = table.getn(track.events)
        end --if
        i = i + 1
    end --while
    i = 1
    while (i < table.getn(track.bytes)) do
        local x = 1
        local str = ""
        while (x < 50) do
            byte = hex(track.bytes[i])
            str = str .. byte .. "x "
            i = i + 1
            x = x + 4
        end --while
        print(str)
        local ev,key = os.pullEvent("key")
        if (key == 28) then -- enter key
            i = table.getn(track.bytes)
        end --if
    end --while
end --func

function loadMidiWithGUI(path)
    local file = fs.open(path, "rb")
    local song = {}
    song.header = parseChunk(grabChunk(file))
    GUI.LookAtObject(song.header)
    tracks = {}
    repeat
        local track = grabChunk(file)
        if (track and track._type == "MTrk") then
            --GUI.LookAtObject(track)
            table.insert(tracks,track)
            trackNumber = table.getn(tracks)
        end --if
    until not track
    for i, t in pairs(tracks) do
        parseChunk(t);
        DebugTrack(t);
    end --for
    print (table.getn(tracks).." Tracks")


    song.tracks = tracks
    pcall(file.close)
    return song
end --func