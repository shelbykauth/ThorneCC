os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")

local defaultConfig = {
    speakers = {
        -- speaker_1 = {active = true, volume=1}
    },
    availableInstruments = {
        bass =      {range={018,042}}, --F#1-F#3
        snare =     {range={042,066}}, --F#3-F#5
        hat =       {range={066,090}}, --F#5-F#7
        basedrum =  {range={018,042}}, --F#1-F#3
        bell =      {range={066,090}}, --F#5-F#7
        flute =     {range={054,078}}, --F#4-F#6
        chime =     {range={066,090}}, --F#5-F#7
        guitar =    {range={030,054}}, --F#2-F#4
        xylophone = {range={066,090}}, --F#5-F#7
        harp =      {range={042,066}}, --F#3-F#5
        pling =     {range={042,066}}, --F#3-F#5
    },
    octaves = {
        {018,030},
        {030,042},
        {042,054},
        {054,066},
        {066,078},
        {078,090},
    },
    groups = {
        -- instr = {1-2, 2-3, 3-4, 4-5, 5-6, 6-7},
        drums = {"basedrum","basedrum","snare","snare","hat","hat"},
        strings={"bass","bass","harp","harp","bell","bell",},
        guitar ={"bass","guitar","guitar","pling","pling","pling"},
        mallet ={"snare","snare","xylophone","xylophone","chimes","chimes"}, --bass and snare are backup
        --synthStrings = {"pling", "guitar", "bass"},
        --synthMallet = {""}
    },
    mapping = {
        -- Piano:
        [1] = {name="Acoustic Grand Piano", group="strings"},
        [2] = {name="Bright Acoustic Piano", group="strings"},
        [3] = {name="Electric Grand Piano", group="strings"},
        [4] = {name="Honky-tonk Piano", group="strings"},
        [5] = {name="Electric Piano 1", group="strings"},
        [6] = {name="Electric Piano 2", group="strings"},
        [7] = {name="Harpsichord", group="strings"},
        [8] = {name="Clavinet", group="strings"},
        -- Chromatic Percussion:
        [9] = {name="Celesta", group="mallet"},
        [10] = {name="Glockenspiel", group="mallet"},
        [11] = {name="Music Box", group="mallet"},
        [12] = {name="Vibraphone", group="mallet"},
        [13] = {name="Marimba", group="mallet"},
        [14] = {name="Xylophone", group="mallet"},
        [15] = {name="Tubular Bells", group="mallet"},
        [16] = {name="Dulcimer", group="mallet"},
        -- Organ:
        [17] = {name="Drawbar Organ", group="strings"},
        [18] = {name="Percussive Organ", group="strings"},
        [19] = {name="Rock Organ", group="strings"},
        [20] = {name="Church Organ", group="strings"},
        [21] = {name="Reed Organ", group="strings"},
        [22] = {name="Accordion", group="strings"},
        [23] = {name="Harmonica", group="strings"},
        [24] = {name="Tango Accordion", group="strings"},
        -- Guitar:
        [25] = {name="Acoustic Guitar (nylon)", group="guitar"},
        [26] = {name="Acoustic Guitar (steel)", group="guitar"},
        [27] = {name="Electric Guitar (jazz)", group="guitar"},
        [28] = {name="Electric Guitar (clean)", group="guitar"},
        [29] = {name="Electric Guitar (muted)", group="guitar"},
        [30] = {name="Overdriven Guitar", group="guitar"},
        [31] = {name="Distortion Guitar", group="guitar"},
        [32] = {name="Guitar harmonics", group="guitar"},
        -- Bass:
        [33] = {name="Acoustic Bass", group="guitar"},
        [34] = {name="Electric Bass (finger)", group="guitar"},
        [35] = {name="Electric Bass (pick)", group="guitar"},
        [36] = {name="Fretless Bass", group="guitar"},
        [37] = {name="Slap Bass 1", group="guitar"},
        [38] = {name="Slap Bass 2", group="guitar"},
        [39] = {name="Synth Bass 1", group="guitar"},
        [40] = {name="Synth Bass 2", group="guitar"},
        -- Strings:
        [41] = {name="Violin", group="strings"},
        [42] = {name="Viola", group="strings"},
        [43] = {name="Cello", group="strings"},
        [44] = {name="Contrabass", group="strings"},
        [45] = {name="Tremolo Strings", group="strings"},
        [46] = {name="Pizzicato Strings", group="strings"},
        [47] = {name="Orchestral Harp", group="strings"},
        [48] = {name="Timpani", group="strings"},
        -- Strings (continued):
        [49] = {name="String Ensemble 1", group="strings"},
        [50] = {name="String Ensemble 2", group="strings"},
        [51] = {name="Synth Strings 1", group="strings"},
        [52] = {name="Synth Strings 2", group="strings"},
        [53] = {name="Choir Aahs", group="strings"},
        [54] = {name="Voice Oohs", group="strings"},
        [55] = {name="Synth Voice", group="strings"},
        [56] = {name="Orchestra Hit", group="strings"},
        -- Brass:
        [57] = {name="Trumpet", group="strings"},
        [58] = {name="Trombone", group="strings"},
        [59] = {name="Tuba", group="strings"},
        [60] = {name="Muted Trumpet", group="strings"},
        [61] = {name="French Horn", group="strings"},
        [62] = {name="Brass Section", group="strings"},
        [63] = {name="Synth Brass 1", group="strings"},
        [64] = {name="Synth Brass 2", group="strings"},
        -- Reed:
        [65] = {name="Soprano Sax", group="strings"},
        [66] = {name="Alto Sax", group="strings"},
        [67] = {name="Tenor Sax", group="strings"},
        [68] = {name="Baritone Sax", group="strings"},
        [69] = {name="Oboe", group="strings"},
        [70] = {name="English Horn", group="strings"},
        [71] = {name="Bassoon", group="strings"},
        [72] = {name="Clarinet", group="strings"},
        -- Pipe:
        [73] = {name="Piccolo", group="strings"},
        [74] = {name="Flute", group="strings"},
        [75] = {name="Recorder", group="strings"},
        [76] = {name="Pan Flute", group="strings"},
        [77] = {name="Blown Bottle", group="strings"},
        [78] = {name="Shakuhachi", group="strings"},
        [79] = {name="Whistle", group="strings"},
        [80] = {name="Ocarina", group="strings"},
        -- Synth Lead:
        [81] = {name="Lead 1 (square)", group="guitar"},
        [82] = {name="Lead 2 (sawtooth)", group="guitar"},
        [83] = {name="Lead 3 (calliope)", group="guitar"},
        [84] = {name="Lead 4 (chiff)", group="guitar"},
        [85] = {name="Lead 5 (charang)", group="guitar"},
        [86] = {name="Lead 6 (voice)", group="guitar"},
        [87] = {name="Lead 7 (fifths)", group="guitar"},
        [88] = {name="Lead 8 (bass + lead)", group="guitar"},
        -- Synth Pad:
        [89] = {name="Pad 1 (new age)", group="drums"},
        [90] = {name="Pad 2 (warm)", group="drums"},
        [91] = {name="Pad 3 (polysynth)", group="drums"},
        [92] = {name="Pad 4 (choir)", group="drums"},
        [93] = {name="Pad 5 (bowed)", group="drums"},
        [94] = {name="Pad 6 (metallic)", group="drums"},
        [95] = {name="Pad 7 (halo)", group="drums"},
        [96] = {name="Pad 8 (sweep)", group="drums"},
        -- Synth Effects:
        [97] = {name="FX 1 (rain)", group="guitar"},
        [98] = {name="FX 2 (soundtrack)", group="guitar"},
        [99] = {name="FX 3 (crystal)", group="guitar"},
        [100] = {name="FX 4 (atmosphere)", group="guitar"},
        [101] = {name="FX 5 (brightness)", group="guitar"},
        [102] = {name="FX 6 (goblins)", group="guitar"},
        [103] = {name="FX 7 (echoes)", group="guitar"},
        [104] = {name="FX 8 (sci-fi)", group="guitar"},
        -- Ethnic:
        [105] = {name="Sitar", group="strings"},
        [106] = {name="Banjo", group="strings"},
        [107] = {name="Shamisen", group="strings"},
        [108] = {name="Koto", group="strings"},
        [109] = {name="Kalimba", group="strings"},
        [110] = {name="Bag pipe", group="strings"},
        [111] = {name="Fiddle", group="strings"},
        [112] = {name="Shanai", group="strings"},
        -- Percussive:
        [113] = {name="Tinkle Bell", group="drums"},
        [114] = {name="Agogo", group="drums"},
        [115] = {name="Steel Drums", group="drums"},
        [116] = {name="Woodblock", group="drums"},
        [117] = {name="Taiko Drum", group="drums"},
        [118] = {name="Melodic Tom", group="drums"},
        [119] = {name="Synth Drum", group="drums"},
        -- Sound effects:
        [120] = {name="Reverse Cymbal", group="drums"},
        [121] = {name="Guitar Fret Noise", group="drums"},
        [122] = {name="Breath Noise", group="drums"},
        [123] = {name="Seashore", group="drums"},
        [124] = {name="Bird Tweet", group="drums"},
        [125] = {name="Telephone Ring", group="drums"},
        [126] = {name="Helicopter", group="drums"},
        [127] = {name="Applause", group="drums"},
        [128] = {name="Gunshot", group="drums"},
    }
}

local config = textutils.unserialize(textutils.serialize(defaultConfig))
local speakers = {}

function Boot()
    speakers = {}
    for name,s in pairs(config.speakers) do
        if (s.active) then
            speakers[name] = peripheral.wrap(name)
        end --if
    end --for
end --func

function GetInfo(infoType, ...)
    if (infoType == "Instrument Name") then
        return config.mapping[arg[1]+1].name
    end --if
    return "Sorry, can't find info for "..infoType.."."
end --func
function pickPitch(midiPitch, range)
    -- Returns the minecraft pitch and the number of octaves off.
    if (type(range) == "string") then
        range = config.availableInstruments[range].range
    end --if
    if (not range or not range[1] or not range[2]) then
        -- range should be min and max
        range = {42,66} -- F#3-F#5
    end --if
    offset = 0
    while (midiPitch < range[1]) do
        midiPitch = midiPitch + 12
        offset = offset + 1
    end
    while (midiPitch > range[2]) do
        midiPitch = midiPitch - 12
        offset = offset - 1
    end
    return midiPitch - range[1], offset
end --func

function pickInstrument(midiInstrument, pitch)
    if (pitch == nil) then pitch = 54 end
    local group = config.groups[config.mapping[midiInstrument].group]
    local octave = math.floor((pitch - 6) / 12)
    if (octave < 1) then octave = 1 end
    if (octave > 6) then octave = 6 end
    instrument = group[octave]
    return instrument
end --func

function playNote(instrument, volume, pitch)
    for name,s in pairs(speakers) do
        s.playNote(instrument, volume*config.speakers[name].volume, pitch)
    end --for
end --func

function MidiNoteOn(instrumentId, pitch, velocity)
    if (velocity == 0) then return end
    local sound = pickInstrument(instrumentId + 1, pitch)
    local pitch = pickPitch(pitch, sound)
    local volume = velocity / 127
    playNote(sound, volume, pitch)
end --func


function ResetConfig()
    config = ThorneAPI.CopyObject(defaultConfig)
    Boot()
end --func
function LoadConfig()
    config = ThorneAPI.LoadObject("/ThorneCC/config/SoundAPI", defaultConfig, true)
    Boot()
end --func
function SaveConfig()
    ThorneAPI.SaveObject(config, "/ThorneCC/config/SoundAPI")
    Boot()
end --func

function AddSpeaker(name, obj)
    config.speakers[name] = obj
    Boot()
end --func
function DisableSpeaker(name)
    if (name == "all") then
        for n,v in pairs(config.speakers) do
            disableSpeaker(n)
        end --for
        return
    end --if
    if (config.speakers[name]) then
        config.speakers[name].active = false
    end --if
    Boot()
end --func
function EnableSpeaker(name)
    if (name == "all") then
        for n,v in pairs(config.speakers) do
            enableSpeaker(n)
        end --for
        return
    end --if
    if (config.speakers[name]) then
        config.speakers[name].active = true
    else
        config.speakers[name] = {
            active = true,
            volume = 1
        }
    end --if
    Boot()
end --func
function SetVolume(name, volume)
    if (name == "all") then
        for n,v in pairs(config.speakers) do
            setVolume(n, amount)
        end --for
        return
    end --if
    local speaker = config.speakers[name]
    if (speaker) then
        speaker.volume = volume
    end --if
end --func
function ChangeVolume(name, amount)
    if (name == "all") then
        for n,v in pairs(config.speakers) do
            changeVolume(n, amount)
        end --for
        return
    end --if
    local speaker = config.speakers[name]
    if (speaker) then
        speaker.volume = speaker.volume or 1
        if (type(amount) == 'string' and string.find(amount, '%')) then
            amount = tonumber(amount) * speaker.volume / 100
        else
            amount = tonumber(amount)
        end --if
        speaker.volume = speaker.volume + amount
        if (speaker.volume < 0) then
            speaker.volume = 0
        end --if
    end --if
end --func
function FindSpeakers()
    local list = peripheral.getNames()
    for _,n in ipairs(list) do
        if (peripheral.wrap(n).playNote) then
            config.speakers[n] = config.speakers[n] or {
                active = true,
                volume = 1,
            }
        end --if
    end --for
    Boot()
    return ThorneAPI.CopyObject(config.speakers)
end --func

Boot()