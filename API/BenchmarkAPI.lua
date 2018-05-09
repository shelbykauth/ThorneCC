function BenchmarkFunction(func, argsList, count)
    --argsList should be a multidimensional numbered array, containing combination
    --possibilities.  All arguments should work with all the arguments on each list.
    --argsList[parameterNumber][cycleIndex]
    if (count == nil) then
        count = 1000
    end --if
    local startTime = os.clock()
    for i=1,count do
        args = {}
        for k,v in ipairs(argsList) do
            args[k] = v[(i % table.getn(v)) + 1]
        end --for
        func(table.unpack(args))
    end --for
    local overheadTime = os.clock() - startTime
    startTime = os.clock()
    for i=1,count do
        args = {}
        for k,v in ipairs(argsList) do
            args[k] = v[(i % table.getn(v)) + 1]
        end --for
        func(table.unpack(args))
    end --for
    local totalTime = os.clock() - startTime
    return totalTime, overheadTime
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
    local str = "Test '"..name.."' ran "..count.." times in "..result.."ms.\n"
    str = str .. "Compare to "..overhead.."ms for overhead.(without function)"
    return str
end --function
