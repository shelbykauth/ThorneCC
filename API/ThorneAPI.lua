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
                term.write(l..": "..lines[l])
            end --if
        end --if
    end --for
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
