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

function SimpleSelectionScreen(lines, selected, options)
    local oSelected = selected
    local scroll = 0
    local width, height = term.getSize()
    height = height - options.before - options.after
    local n = table.getn(lines)
    local ev, key, held
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
    until key == keys.backspace or key == keys.enter
    if (key == keys.enter) then
        return selected
    else
        return oSelected
    end --if
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

function Load(path, default, writeDefault)
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
