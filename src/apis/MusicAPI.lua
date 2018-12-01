os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
os.loadAPI("/ThorneCC/apis/GUI.lua")

-- Clases
local Song = {}
local Track = {}
local Note = {}

-- Song Class

function Song:new(o) 
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.tracks = o.tracks or {}
    o.length = o.length or 0
    o.title = o.title or "Unnamed"
    o.notation = o.notation or config.notation
    o.notation.notes = o.notation.notes or config.notation.notes
    o.notation.delim = o.notation.delim or config.notation.delim
    o.notation.rest = o.notation.rest or config.notation.rest
    o.notation.bar = o.notation.bar or config.notation.bar
    return o
end --func

function Song:load(path)
    local file = io.open(path, "r")
    if (file == nil) then
        file = io.open(config.datapath..path, "r")
    end --if
    if (file == nil) then
        return false, "Filepath cannot be read"
    end --if
    o = Song:new()
    local currentItem = ""
    for a in file:lines() do
        print(a)
        if (a:lower() == "#title") then currentItem = "title"
        elseif (a:lower() == "#delim") then currentItem = "delim"
        elseif (a:lower() == "#rest") then currentItem = "rest"
        elseif (a:lower() == "#notes") then currentItem = "notes"
        elseif (a:lower() == "#tracks") then currentItem = "tracks"
        elseif (currentItem == "title") then 
            o.title = a 
            currentItem = ""
        elseif (currentItem == "delim") then
            o.notation.delim = a
            currentItem = ""
        elseif (currentItem == "rest") then
            o.notation.rest = a
            currentItem = ""
        elseif (currentItem == "notes") then
            o.notation.notes = a
            currentItem = ""
        elseif (currentItem == "tracks") then 
            table.insert(o.tracks, Track:fromString(a, o.notation))
        end --if
    end --for

    file:close()
    return o
end --func

function Song:save(path)
    ThorneAPI.SaveObject(self, config.dataPath..path)
end --func

function Song:removeTrack(track)

end --func

function Song:play(options)
    local timePerEighth = .25
    if (type(options) ~= 'table') then
        options = {}
    end --if
    if (type(options.idle) ~= 'function') then
        options.idle = function() return true end
    end --if
    local allNotes = {}
    for _, tr in pairs(self.tracks) do
        for i = 0,tr.length do
            allNotes[i] = allNotes[i] or {}
            if (tr.notes[i]) then
                table.insert(allNotes[i], tr.notes[i])
            end --if
        end --for
    end --for
    for i, notes in ipairs(allNotes) do
        for _,n in pairs(notes) do
            n:play()
        end --for
        ThorneEvents.sleep(timePerEighth)
    end --for
end --func

-- Track Class
function Track:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.instrument = getInstrument(o.instrument)
    o.notes = o.notes or {}
    o.length = o.length or 0
    return o
end --func

function Track:fromString(str, notation)
    notation = notation or config.notation
    local tr = Track:new()
    _,_,ins = str:find("(%w*)")
    tr.instrument = getInstrument(ins)
    tr.notation = notation
    local i = str:find(notation.bar)
    if (not i) then return tr end
    str = str:sub(i + 1)
    pos = 1
    while (str:len() > 0) do
        local pString = ""
        local n = str:sub(1,1)
        if (n:find("["..notation.rest.."]")) then
            pos = pos + 1
        elseif (n:find("["..notation.bar.."]")) then
            pos = pos - (pos-2)%8 + 7
        elseif (notation.notes:find(n)) then
            tr:addNote(n, pos)
            pos = pos + 1
        end --if
        str = str:sub(2)
    end --while
    return tr
end --func

function Track:addNote(char, pos)
    local charList = self.notation.notes
    pos = pos or self.length + 2
    note = {
        pitch = (charList:find(char) or 7) - 1,
        instrument = self.instrument,
    }
    note = Note:new(note)
    self.notes[pos] = note
    self.length = math.max(self.length, pos)
end --func

-- Note Class
function Note:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.instrument = getInstrument(o.instrument)
    o.pitch = o.pitch or 6
    return o
end --func

function Note:play()
    local ao = config.audioOut
    if (ao:find("CCTweakedSpeaker")) then
        for i, peri in ipairs(instance.speakers) do
            --print(self.instrument, self.volume, self.pitch)
            peri.playNote(self.instrument, self.volume or config.volume or 1, self.pitch)
        end --for
    end --if
end --func

-- Outward Pieces

function getInstrument(str)
    str = str or ""
    str = str:lower()
    if (not str) then return config.instruments[1] end
    for k,ins in pairs(config.instruments) do
        if (ins == str) then
            return ins
        end --if
    end --for
    for k,ins in pairs(config.instruments) do
        if (ins:find("^"..str)) then
            return ins
        end --if
    end --for
    for k,ins in pairs(config.instruments) do
        if (ins:find(str)) then
            return ins
        end --if
    end --for
    return "harp"
end --func

function loadSong(song)
    return Song:load(config.datapath..song)
end --func

function saveSong(song, overwrite)

end --func

function newSong()

end --func

function playSong(song, options)
    if (type(song) == "string") then
        song = loadSong(song)
    end --if
    song:play(options)
end --func

function playNote(str, instrument, volume)
    --print(str, instrument, volume)
    --os.sleep(.3)
    local n
    if (type(str) == 'string') then
        n = {
            instrument = getInstrument(instrument),
            pitch = config.notation.notes:find(str),
            volume = volume,
        }
    elseif (type(str) == 'number') then
        n = {
            instrument = getInstrument(instrument),
            pitch = str,
            volume = volume,
        }
    end --if
    note = Note:new(n)
    note:play()
end --func

function runSetup(full)
    if (full) then
        if (config.audioOut:find("CCTweakedSpeaker")) then
            local options = config.audioOut:gsub("CCTweakedSpeaker/", "")
            config.speakers = {}
            local names = peripheral.getNames()
            for k,name in pairs(names) do
                if(peripheral.getType(name) == "speaker") then
                    local peri = peripheral.wrap(name)
                    if (peri.playNote) then
                        table.insert(config.speakers, name)
                    end --if
                end --if
            end --for
        end --if
    end --if
    
    instance = {
        speakers = {}
    }
    for i,name in ipairs(config.speakers) do
        table.insert(instance.speakers, peripheral.wrap(name))
    end --for
end --func

config = ThorneAPI.LoadObject("/ThorneCC/config/music", {
    datapath = "/ThorneCC/data/music/songs/",
    minPitch = 0,
    maxPitch = 24,
    volume = 1,
    audioOut = "CCTweakedSpeaker/all",
    audioOutOptions = {
        "CCTweakedSpeaker/first",
        "CCTweakedSpeaker/all",
        "CCTweakedSpeaker/name/",
    },
    notation = {
        notes = "0123456789abcdefghijklmno",
        delim = " ,",
        rest = "_",
        bar = "|",
    },
    instruments={
        "harp",
        "bass",
        "snare",
        "hat",
        "basedrum",
        "bell",
        "flute",
        "chime",
        "guitar",
        "xylophone",
        "pling",
    },
    speakers = {}
}, false)

local instance = {}

runSetup()
