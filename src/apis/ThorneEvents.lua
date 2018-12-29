os.loadAPI("/ThorneCC/apis/ThorneAPI.lua")
local cycleTime = .05
__functions = ThorneEvents and ThorneEvents.__repeatFunctions or {}
__isRunning = false

function sleep(x)
    local myID = os.startTimer(x)
    repeat
        _,id = os.pullEvent("timer")
    until id == myID
end --function

function Subscribe(action, index)
    if (type(action) ~= "function") then
        return false
    end --if
    index = index or (table.getn(__functions) + 1)
    local co = coroutine.create(action)
    __functions[index] = {action=action, co=co, times="many"}
    run()
    os.startTimer(0)
    return index
end --func

function UnSubscribe(index)
    if (not index) then return false end
    local co = __functions[index]
    __functions[index] = {}
    os.startTimer(0)
    return true
end --func

function SubscribeOnce(action, index)
    if (type(action) ~= "function") then
        return false
    end --if
    index = index or (table.getn(__functions) + 1)
    local co = coroutine.create(action)
    __functions[index] = {action=action, co=co, times="one"}
    run()
    os.startTimer(0)
    return index
end --func

function Reset()
    __isRunning = false
end --func

function run()
    if (__isRunning) then return false end
    __isRunning = true
    print("Start Round Robin")
    os.startTimer(0)
    repeat
        local keysToRemove = {}
        local count = 0
        local stuff = table.pack(coroutine.yield())
        for k,v in pairs(__functions) do
            count = count + 1
            local co = v.co
            if (not v.co or coroutine.status(co) == "dead") then
                if (v.times == "one" or not v.co) then
                    keysToRemove[k] = true
                else
                    v.co = coroutine.create(v.action)
                end --if
            else
                local success, value = coroutine.resume(co, table.unpack(stuff))
                if (not success) then
                    print(value)
                    UnSubscribe(k)
                    ThorneAPI.LogError(value)
                end --if
            end --if
        end --for
        for k,v in pairs(keysToRemove) do
            __functions[k] = nil
        end --for
        __isRunning = __isRunning and count > 0
    until not __isRunning
    __functions = {}
end --func