--[[
    Author: Dartania Thorne, except where otherwise stated
    General Purpose Functions that make a nice, simple GUI in computercraft.
]]--

function Display (lines, scroll, highlight, options)
    --[[
        Author: Dartania
        Display a large amount of text at a specific scroll height
        Individual Lines should not be longer than the screen width.
        Highlight will highlight one line
        Number of lines before and after can be set in 'options'
    ]]--
    local width,height = term.getSize()
    if (type(lines) ~= 'table') then
        return false
    end --if
    if (type(highlight) ~= 'number') then
        highlight = -1
    end --if
    if (type(scroll) ~= 'number') then
        scroll = 1
    end --if
    if (type(options) ~= 'table') then
        options = {
            before = 0,
            after = 0,
        }
    end --if
    for i=options.before + 1,height-options.after do
        l = i + scroll - options.before
        term.setCursorPos(1,i)
        term.clearLine()
        if (lines[l] ~= nil) then
            if (highlight == l) then
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
                term.write(lines[l])
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
            else
                term.write(lines[l])
            end --if
        end --if
    end --for
end --function

function LoadingScreen(text, currentCount, finalCount)
    if (type(text) ~= 'string') then text = "Loading..." end
    if (type(currentCount) ~= 'number') then currentCount = 0 end
    if (type(finalCount) ~= 'number') then finalCount = 100 end
    local percentage = string.format("(%.2f %%)", currentCount / finalCount * 100)
    local divider = "------------------"
    local progress = currentCount.."/"..finalCount.." Completed "..percentage
    --TODO: Loading Bar
    term.clear()
    CenterPrint({text, divider, progress})
end --function

function CenterPrint(lines, y)
    local width,height = term.getSize()
    if (type(lines) == 'string') then lines = {lines} end
    for i = 1, table.getn(lines) do
        if (string.len(lines[i]) > width) then
            local lineWidth = string.len(lines[i]) / width
            local newLines = {}
            local newLine = ""
            local newLineAdded = false
            for word in string.gmatch(lines[i], " ") do
                if (string.len(word) < lineWidth - string.len(newLine)) then
                    newLine = newLine .. word .. " "
                    newLineAdded = false
                else
                    newLine = string.sub(newLine, 1, string.len(newLine) - 1)
                    table.insert(newLines, newLine)
                    newLine = ""
                    newLineAdded = true
                end --if
            end --for
            if (not newLineAdded) then
                newLine = string.sub(newLine, 1, string.len(newLine) - 1)
                table.insert(newLines, newLine)
                newLine = ""
                newLineAdded = true
            end --if
            for k,v in ipairs(newLines) do
                table.insert(lines, i + k, v)
            end --for
            table.remove(lines, i)
        end --if
    end --if
    if (type(y) ~= "number") then
        y = height / 2 - table.getn(lines) / 2
    end --if
    for k,v in ipairs(lines) do
        local x = width / 2 - string.len(v) / 2
        term.setCursorPos(x, y)
        term.clearLine()
        term.write(v)
        y = y + 1
    end --for

end --function
function SimpleSelectionScreen(lines, selected, options)
    local width,height = term.getSize()
    if (type(options) ~= 'table') then options = {} end
    if (not options.before) then options.before = 0 end
    if (not options.after) then
        options.after = 1
    else
        options.after = options.after + 1
    end --if
    if (options.title) then
        options.before = options.before + 1
        CenterPrint(options.title, 1)
    end --if
    CenterPrint(textutils.serialize(options), height - 5)
    CenterPrint("'Enter' to select, 'Backspace' to quit.", height)
    local result = ComplexSelectionScreen(lines, selected, options, {})
    term.clear()
    term.setCursorPos(1,1)
    return result
end --function

function ComplexSelectionScreen(lines, selected, options, controls)
    local oSelected = selected
    local scroll = 0
    local width, height = term.getSize()
    height = height - options.before - options.after
    local n = table.getn(lines)
    local ev, key, held
    controls[keys.up] = nil
    controls[keys.down] = nil
    controls[keys.backspace] = nil
    controls[keys.enter] = nil
    repeat
        if (selected < 1) then selected = 1 end
        if (selected > n) then selected = n end
        if (scroll > selected) then scroll = selected end
        if (scroll < selected - height) then scroll = selected - height end
        Display(lines, scroll, selected, options)
        ev, key, held = os.pullEvent("key")
        if (key == keys.up) then
            selected = selected - 1
        end --if
        if (key == keys.down) then
            selected = selected + 1
        end --if
        if (controls[key]) then
            controls[key]()
        end --if
    until key == keys.backspace or key == keys.enter
    if (key == keys.enter) then
        return selected
    else
        return oSelected
    end --if
end --function

function ConfirmBox (Question, YesF, NoF)
    lines = {GetCenteredString("No"), GetCenteredString("Yes")}
    options = {title=Question}
    selection = 1
    if (type(YesF) ~= 'function') then
        YesF = function() end
    end --if
    if (type(NoF) ~= 'function') then
        NoF = function() end
    end --if
    if (SimpleSelectionScreen(lines,selection,options) == 2) then
        YesF()
        return true
    else
        NoF()
        return false
    end --if
end --function

function GetCenteredString(str)
    width,height = term.getSize()
    while (string.len(str) < width - 1) do
        str = " " .. str .. " "
    end --while
    if (string.len(str) < width) then
        str = str .. " "
    end --if
    return str
end --function

function LoadObject(path, default, writeDefault)
    --[[
        Author: Dartania
        Returns the object contained at the given path
            or the default if not available.
        Writes the default object to the path if the object is not available
            and the writeDefault flag is true.
    ]]--
    local file
    local data
    local exists = fs.exists(path)
    if (fs.exists(path)) then
        file = fs.open(path, "r")
        data = textutils.unserialize(file.readAll())
        file.close()
    else
        data = default
        if (writeDefault) then
            file = fs.open(path, "w")
            file.write(textutils.serialize(data))
            file.close()
        end --if
    end --if
    return data
end --function

function SaveObject(obj, path)
    local file = fs.open(path, "w")
    file.write(textutils.serialize(obj))
    file.close()
end --function

function Hash(str)
    --[[
        Author: gnush
        A simple string encoder / hasher.
        This is NOT SAFE, so don't user your real world passwords with this.
    ]]--
    local s = 0
    local p = ""

    for c in str:gmatch(".") do
        s = s + string.byte(c)
    end

    s = bit.bxor(65432895, s)

    while s > 0 do
        p = p .. string.char(s % 94 + 33)
        s = bit.brshift(s, 1)
    end

    return string.sub(p, 1, p:len() - 1)
end
