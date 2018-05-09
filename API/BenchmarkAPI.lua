function BenchmarkFunction(func, argsList, count)
    --argsList should be a multidimensional numbered array, containing combination
    --possibilities.  All arguments should work with all the arguments on each list.
    --argsList[parameterNumber][cycleIndex]
    if (count == nil) then
        count = 1000
    end --if
    local startTime1 = os.clock()
    local startTime2 = os.time()
    for i=1,count do
        args = {}
        for k,v in ipairs(argsList) do
            args[k] = v[(i % table.getn(v)) + 1]
        end --for
    end --for
    local overheadTime1 = os.clock() - startTime1
    local overheadTime2 = os.time() - startTime2
    startTime1 = os.clock()
    startTime2 = os.time()
    for i=1,count do
        args = {}
        for k,v in ipairs(argsList) do
            args[k] = v[(i % table.getn(v)) + 1]
        end --for
        func(table.unpack(args))
    end --for
    local totalTime1 = os.clock() - startTime1
    local totalTime2 = os.time() - startTime2
    result = {
        totalComputerTime = totalTime1
        totalSystemTime = totalTime2
        overheadComputerTime = overheadTime1
        overheadSystemTime = overheadTime2
    }
    return result
end --function

function BenchmarkProgram(path, argsList, count)
    local func = function(...)
        os.run({}, path, table.unpack(arg))
    end --function
    return BenchmarkFunction(func, argsList, count)
end --function

function FormatBenchmarkFunction(name, func, argsList, count)
    if (count == nil) then
        count = 1000
    end --if
    result, overhead = BenchmarkFunction (func, argsList, count)
    local str = "Test '"..name.."' ran "..count.." times.\n"
    str = str .. "Time took: "..result.totalComputerTime.."computer seconds, "..result.totalSystemTime.."Minecraft Time.\n"
    str = str .. "Overhead: "..result.overheadComputerTime.."computer seconds, "..result.overheadSystemTime.."Minecraft Time."
    return str
end --function
