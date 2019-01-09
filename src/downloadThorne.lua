-- v0.0.1
local ThorneVersion = "0.0.1"
function download(path, options)
    options = options or {}
    if (type(path) ~= "string") then
        error("Bad argument #1, expected string path, got "..type(path), 2)
    end --if
    local url, localPath, file, response, fileVersion
    url = "https://shelbykauth.github.io/ThorneCC/src/"..path
    localPath = options.localPath or "/ThorneCC/"..path
    -- Check current file version
    print(localPath)
    file = fs.open(localPath, "r")
    if (file) then
        fileVersion = file.readLine()
        print(fileVersion)
        fileVersion = fileVersion:gsub("-- v","")
        file:close()
        if (ThorneVersion == fileVersion) then
            return true, {didChange = true, msg="Already have up-to-date file "..localPath}
        end --if
    end --if
    -- Get Url
    print("Getting "..url)
    response = http.get(url)
    if (not response) then
        print("Download Failed")
        return false
    else
        print("Saving to "..localPath)
        file = io.open(localPath, "w")
        if (not options.noVersion) then
            file:write("-- v"..ThorneVersion.."\n")
        end --if
        file:write(response.readAll())
        file:close()
        response:close()
        print("Success")
        return true
    end --if
end --func

success, msg = download("/downloadThorne.lua", {localPath="/downloadThorne.lua"})
if (msg == "didChange") then
    shell.run("downloadThorne")
    return
end --if

local success = download("/apis/ThorneAPI.lua")
success = success and download("/apis/GUI.lua")
success = success and download("/apis/ThorneEvents.lua")
success = success and download("/apis/ThorneKeys.lua")
download("images/logo.nfp", {noVersion=true})
download("images/logo.bw.nfp", {noVersion=true})

if (not success) then
    print("I'm sorry.  We can't seem to download the necessary files to get you started.")
    print("Please try again in a few minutes or contact Dartania Thorne by posting an issue on the github repository.")
    print("(for github, go to https://shelbykauth.github.io/ThorneCC/).")
    return false
end --if

os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
os.loadAPI("/ThorneCC/apis/ThorneEvents.lua")
os.loadAPI("/ThorneCC/apis/ThorneKeys.lua")
os.loadAPI("/ThorneCC/apis/GUI.lua")

local modules = {
    Storage = {
        "/programs/SimpleStorage.lua",
        "/apis/StorageAPI.lua",
        "/config/storage",
    },
    Music = {
        "/apis/MusicAPI.lua",
        "/programs/MusicPlayer.lua",
        "/programs/Trance.lua",
        "/config/music",
        "/data/music/songs/HotCrossBuns.txt",
        "/data/music/songs/Notify.txt",
        "/data/music/songs/Sampler.txt",
        "/data/music/songs/Screech.txt",
    },
    Robots = {
        "/apis/ThorneBot.lua",
        "/programs/ThorneBot.lua"
    },
}


local list = http.get("https://shelbykauth.github.io/ThorneCC/src/ThorneCC_Filemap.txt")
repeat
    local line = list.readLine()
    if (line) then
        if (line ~= "/downloadThorne.lua") then
            print("Downloading", line)
            success, msg = download(line)
            if (not success) then
                print("Download Failed!")
            end --if
        end --if
    end --if
until not line

local writeStartup = GUI.ConfirmBox("Write Startup File?")
if (writeStartup) then
    local file = fs.open("startup.lua", "w")
    file.write("shell.setPath(shell.path()..':/ThorneCC/programs')")
    file.flush()
    file.close()
end --if

GUI.DisplayImage("logo")
os.startTimer(2)
GUI.WaitForEvent({'key', 'timer'})
os.reboot()
--GUI.Display(lines, 0, {1,2})