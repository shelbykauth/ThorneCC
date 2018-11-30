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
    if (not __isRunning) then run() end
    return index
end --func

function UnSubscribe(index)
    if (not index) then return false end
    local co = __functions[index]
    __functions[index] = nil
    return true
end --func

function SubscribeOnce(action, index)
    if (type(action) ~= "function") then
        return false
    end --if
    index = index or (table.getn(__functions) + 1)
    local co = coroutine.create(action)
    __functions[index] = {action=action, co=co, times="one"}
    if (not __isRunning) then run() end
    return index
end --func

function Reset()
    __isRunning = false
end --func

function run()
    __isRunning = true
    print("Start Round Robin")
    repeat
        local keysToRemove = {}
        local count = 0
        local stuff = table.pack(coroutine.yield())
        for k,v in pairs(__functions) do
            count = count + 1
            local co = v.co
            --print(k, coroutine.status(co))
            --print(k, coroutine.status(co))
            if (coroutine.status(co) == "dead") then
                if (__functions[k].times == "one") then
                    keysToRemove[k] = true
                else
                    v.co = coroutine.create(v.action)
                end --if
            else
                coroutine.resume(co, table.unpack(stuff))
            end --if
        end --for
        for k,v in pairs(keysToRemove) do
            __functions[k] = nil
        end --for
        __isRunning = __isRunning and count > 0
    until not __isRunning
    __functions = {}
end --func