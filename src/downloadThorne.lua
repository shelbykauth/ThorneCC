-- v0.0.0
local ThorneVersion = "0.0.0"
function download(path, options)
    local url, localPath, file, response, fileVersion
    url = "https://shelbykauth.github.io/ThorneCC/src/"..path
    localPath = "/ThorneCC/"..path
    -- Check current file version
    file = fs.open(localPath, "r")
    if (file) then
        fileVersion = file:readLine():gsub("-- v","")
        file:close()
        if (ThorneVersion == fileVersion) then
            print("Already have up-to-date file "..localPath)
            return true
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
        file:write("-- v"..ThorneVersion.."\n")
        file:write(response.readAll())
        file:close()
        response:close()
        print("Success")
        return true
    end --if
end --func

local success = download("/apis/ThorneAPI.lua")
success = success and download("/apis/GUI.lua")
download("images/logo.nfp", {"noVersion"})
download("images/logo.1.nfp", {"noVersion"})

if (not success) then
    print("I'm sorry.  We can't seem to download the necessary files to get you started.")
    print("Please try again in a few minutes or contact Dartania Thorne by posting an issue on the github repository.")
    return false
end --if

os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
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
        "/config/music",
        "/data/music/songs/HotCrossBuns.txt"
    },
    Robots = {
        "/apis/ThorneBot.lua",
        "/programs/ThorneBot.lua"
    },
}

local lines = {}
for k,v in pairs(modules) do
    table.insert(lines, k)
end --for

--GUI.Display(lines, 0, {1,2})