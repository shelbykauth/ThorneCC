local songs = {}
local currentSong = nil
local state = {
    currentSong = nil,
    running = "stopped",
}

local errors = {}
local error = function (err)
    if (type(err) == "string") then
        err = {
            type="unknown",
            message=err,
        }
    end --if
    table.insert(errors, err)
end --func

function toHex(num)
    if (type(num) == 'number') then
        if (num < 16) then
            return "0"..string.format("%x", num):upper()
        end --if
        return string.format("%x", num):upper()
    end --if
    return nil
end --func
function fromHex(x)
    if (type(x) == 'string') then
        return tonumber(x, 16)
    end --if
    return nil
end --func
function readVariableInt(file)
    --file should be opened in binary
    local num = 0
    repeat
        local byte = file.read()
        if byte >= 128 then byte = byte - 128 end
        num = num * 128
        num = num + byte
    until byte < 128
    return num
end --func
function readFixedInt(file, length)
    --file should be opened in binary
    local num = 0
    for i=1,length do
        local byte = file.read()
        num = num * 256
        num = num + byte
    end --for
    return num
end --func
function burn(file, length)
    local arr = {}
    print(length)
    for i=1,length do
        arr[i] = file.read()
    end --for
    return arr
end --func
function readText(file, length)
    local arr = burn(file, length)
    for i = 1,length do
        if (arr[i] == nil) then
            error({type="normal",message="Reached End Of File"})
        end --if
        arr[i] = string.char(arr[i])
    end --for
    return table.concat(arr, "")
end --func

function parseEvent(chunk, file)
    if (file.seek() >= chunk._dataEnd) then return nil end
    local event = {
        type="[type]",
        name="[name]",
        value="[value]",
        length=0,
        delay=0,
    }
    event.delay = readVariableInt(file)
    chunk.time = chunk.time + event.delay
    event.time = chunk.time
    local typeKey = toHex(file.read())
    event.typeKey = typeKey
    if (typeKey == "FF") then
        event.type = "Meta"
        event.metaType = file.read()
        event.length = readVariableInt(file)
        event._dataStart = file.seek()
        event.data = burn(file, event.length)
        event._dataEnd = file.seek()
        local t = toHex(event.metaType)
        file.seek("set", event._dataStart)
        if (t == "00") then
            event.name = "Sequence Number"
            event.value = readFixedInt(file, 2)
        elseif (t == "01") then
            event.name = "Text Event"
            event.value = readText(file, event.length)
        elseif (t == "02") then
            event.name = "Copyright Notice"
            event.value = readText(file, event.length)
        elseif (t == "03") then
            event.name = "Sequence/Track Name"
            event.value = readText(file, event.length)
        elseif (t == "04") then
            event.name = "Instrument Name"
            event.value = readText(file, event.length)
        elseif (t == "05") then
            event.name = "Lyric"
            event.value = readText(file, event.length)
        elseif (t == "06") then
            event.name = "Marker"
            event.value = readText(file, event.length)
        elseif (t == "07") then
            event.name = "Cue Point"
            event.value = readText(file, event.length)
        elseif (t == "2F") then
            event.name = "End Of Track"
        elseif (t == "20") then
            event.name = "Midi Channel Prefix"
            event.value = file.read()
        elseif (t == "21") then
            event.name = "Midi Port Prefix"
            event.value = file.read()
        elseif (t == "51") then
            event.name = "Set Tempo"
            event.value = readFixedInt(file, 3)
        elseif (t == "54") then
            event.name = "SMTPE Offset"
            event.value = {
                hh=file.read(),
                mm=file.read(),
                ss=file.read(),
                fr=file.read(),
                ff=file.read(),
            }
        elseif (t == "58") then
            event.name = "Time Signature"
            event.value = {
                nn=file.read(),
                dd=file.read(),
                cc=file.read(),
                bb=file.read(),
            }
        elseif (t == "59") then
            event.name = "Key Signature"
            event.value = {
                sf=file.read(),
                mi=file.read(),
            }
        elseif (t == "7F") then
            event.name = "Sequencer-Specific Meta-Event"
            event.data = burn(file, event.length)
        else
            event.name = "Unknown:"..t
            event.data = burn(file, event.length)
        end --if
        file.seek("set", event._dataEnd)
    elseif (typeKey == "F0" or typeKey == "F7") then
        event.type = "Sysex"
        event.length = readVariableInt(file)
        event.data = burn(file, length)
    else
        event.type = "Midi"
        event.data = {}
        if (fromHex(typeKey) < 128) then
            typeKey = chunk.runningStatus
            file.seek("set", file.seek()-1)
        end --if
        chunk.runningStatus = typeKey
        event.midiType = string.sub(typeKey, 1, 1)
        print(typeKey)
        event.channel = tonumber(string.sub(typeKey, 2, 2)) + 1
        if (event.midiType == "8") then
            event.name = "Note Off"
            event.data = burn(file, 2)
        elseif (event.midiType == "9") then
            event.name = "Note On"
            event.data = burn(file, 2)
        elseif (event.midiType == "A") then
            event.name = "AfterTouch"
            event.data = burn(file, 2)
        elseif (event.midiType == "B") then
            event.name = "Controller Change"
            event.data = burn(file, 2)
        elseif (event.midiType == "C") then
            event.name = "Program Change"
            event.data = burn(file, 1)
        elseif (event.midiType == "D") then
            event.name = "AfterTouch"
            event.data = burn(file, 1)
        elseif (event.midiType == "E") then
            event.name = "AfterTouch"
            event.data = burn(file, 2)
        else
            event.name = "unknown"..typeKey
            event.data = burn(file, 2)
        end --if
    end --if
    table.insert(chunk.events, event)
end --func

function parseTrack(chunk, file)
    chunk.runningStatus = "90"
    file.seek("set", chunk._dataStart)
    chunk.data = burn(file, chunk.length)
    file.seek("set", chunk._dataStart)
    chunk.events = {}
    chunk.pointer = 1
    chunk.channels = {}
    for i = 1,16 do
        chunk.channels[i] = {
            instrument = 0
        }
    end --for
    local lastSeek = 0
    repeat
        if (file.seek() < lastSeek) then
            error("Event Parser did not reset itself.")
        end --if
        lastSeek = file.seek()
        parseEvent(chunk, file)
    until file.seek() >= chunk._dataEnd
end --func

function parseHead(chunk, file)
    chunk.format = readFixedInt(file, 2)
    chunk.trackCount = readFixedInt(file, 2)
    local b1 = file.read()
    local b2 = file.read()
    if (b1 < 128) then
        chunk.deltaPerQuarterNote = b1 * 256 + b2
    else
        error({type="fatal", message="Cannot Handle SMTPE Frame divisions"})
    end --if
end --func

function readChunk(file)
    local chunk = {}
    chunk.time = 0
    chunk._start = file.seek()
    chunk.type = readText(file, 4)
    chunk.length = readFixedInt(file, 4)
    chunk._dataStart = file.seek()
    chunk.data = burn(file, chunk.length)
    chunk._dataEnd = file.seek()
    file.seek("set", chunk._dataStart)
    if (chunk.type == "MThd") then
        parseHead(chunk, file)
    elseif (chunk.type == "MTrk") then
        parseTrack(chunk, file)
    end --if
    file.seek("set", chunk._dataEnd)
    return chunk
end --func

function LoadSong(path, id)
    if (not string.find(path, ".mid$")) then
        return false
    end
    local file = fs.open(path, "rb")
    if (not file) then
        return false
    end --if
    if (not id) then
        _,_,id = string.find(path, "(%w*).mid")
    end --if
    local totalSize = file.seek("end")
    file.seek("set", 0)
    local success, err
    local errors = {}
    local song = {
        time = 0,
        tracks = {},
    }
    local chunks = {}
    while (totalSize > file.seek()) do
        success, err = pcall(function()
            local chunk = readChunk(file)
            table.insert( chunks, chunk )
            if (chunk.type == "MThd") then
                song.head = chunk
            elseif (chunk.type == "MTrk") then
                table.insert(song.tracks, chunk)
            end --if
        end)
        table.insert(errors, err)
    end --while
    file.close()
    for k,v in ipairs(errors) do
        print("Error: "..(v.message or v))
    end --for
    songs[id] = song
end --func

function LoadAllSongs(path)
    if (not path) then path = "/" end --if
    for _,p in ipairs(fs.list(path)) do
        p = path.."/"..p
        if (fs.isDir(p)) then
            LoadAllSongs(p)
        else
            LoadSong(p)
        end --if
    end --for
end --func

function UnloadSongs(ids)
    for _,id in ipairs(ids) do
        songs[id] = nil
    end --for
end --func

function GetLoadedSongs()
    local list = {}
    for id,song in pairs(songs) do
        list[id] = id
    end --for
    return list
end --func

local eventHandlers = {
    default = function(event, track, song)
        if (event.type == "Meta") then
            if (toHex(event.metaType) == "2F") then
                track.ended = true
            end --if
            --print("Meta: "..toHex(event.metaType).." "..event.name)
        elseif (event.type == "Midi") then
            if (event.midiType ~= "8") then
                --print("Midi: "..event.name)
            end
            if (event.midiType == "C") then
                track.channels[event.channel].instrument = event.data[1]
            end --if
        end --if
    end, --func
}
local function looper()
    state.running = "playing"
    local startTime = os.clock()
    repeat
        local song = currentSong
        local newTime = os.clock()
        local secondsAdded = newTime - startTime
        local ticksAdded = secondsAdded * song.tps
        song.time = song.time + ticksAdded
        startTime = newTime
        local tracksStopped = true
        local count = 0
        local closestDelay = 1/0 --infinity
        for i,track in ipairs(song.tracks) do
            local moveOn = false
            if (track.ended) then
                moveOn = true
            end --if
            while (not moveOn) do
                local event = track.events[track.pointer]
                if (not event) then break end
                print("Track", i, ", Event", track.pointer, ", Time:",event.time)
                if (song.time > event.time) then
                    -- do Event
                    for _,action in pairs(eventHandlers) do
                        action(event, track, song)
                    end --for
                    track.pointer = track.pointer + 1
                else
                    local ticksTilEvent = event.time - song.time
                    local secsTilEvent = ticksTilEvent / song.tps
                    closestDelay = math.min(closestDelay, secsTilEvent)
                    moveOn = true
                    print(secsTilEvent,"Secs til event. ", closestDelay, "to closest event")
                end --if
                if (track.pointer > table.getn(track.events)) then
                    track.ended = true
                    moveOn = true
                end --if
                if (track.ended) then

                    print("End Track", i)
                end --if
            end --while
        end --for
        print(closestDelay)
        if tracksStopped or closestDelay == 1/0 then
            state.running = "stopped"
        else
            ThorneEvents.sleep(closestDelay)
        end
    until state.running ~= "playing"
end --func
function playSong(id)
    os.loadAPI("/ThorneCC/apis/ThorneEvents.lua")
    
    if (not songs[id]) then return end --if
    Stop()
    local song = songs[id]
    song.time = 0
    song.tps = 1000000 * song.head.deltaPerQuarterNote / 500000 -- ticks per second
    for i,t in ipairs(song.tracks) do
        t.pointer = 1
        t.ended = false
    end --for
    currentSong = song
    ThorneEvents.SubscribeOnce(looper, "MidiLoop")
    end --func
function Stop()
    if (currentSong) then
        currentSong.time = 0
    end --if
    state.running = "stopped"
    --ThorneEvents.UnSubscribe("MidiLoop")
end --func
function Play(id)
    if (id) then
        playSong(id)
    else
        ThorneEvents.SubscribeOnce(looper, "MidiLoop")
    end --if
end --func
function Pause()
    state.running = "paused"
end --func
function AttachHandler(action, id)
    if (id == "default") then return false end
    eventHandlers[id] = action
end --func
function DetachHandler(id)
    if (id == "default") then return false end
    eventHandlers[id] = nil
end --func