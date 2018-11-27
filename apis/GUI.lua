os.loadAPI("/ThorneCC/apis/ThorneKeys.lua")
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
    -- Edited 2018/08/31 to allow multi-highlighting
    if (type(highlight) ~= 'table') then
        -- convert 4 to {nil, nil, nil, true}
        highlight = {[highlight]=true}
    else
        -- convert {3,5,2} to {nil, true, true, nil, true}
        local newTable = {}
        for k,v in pairs(highlight) do
            newTable[k] = v
        end --for
        for k,v in pairs(highlight) do
            if (type(v) == 'boolean' or not v) then
                newTable[k] = v
            else
                newTable[v] = true
            end --if
        end --for
        highlight = newTable
    end --if
    if (type(scroll) ~= 'number') then
        scroll = 1
    end --if
    if (type(options) ~= 'table') then
        options = {
            before = 0,
            after = 0,
            center = false,
        }
    end --if
    for i=options.before + 1,height-options.after do
        l = i + scroll - options.before
        term.setCursorPos(1,i)
        term.clearLine()
        if (lines[l] ~= nil) then
            if (highlight[l]) then
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
                if (options.center) then
                    CenterPrint(lines[l], i)
                else
                    term.write(lines[l])
                end --if
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
            else
                if (options.center) then
                    CenterPrint(lines[l], i)
                else
                    term.write(lines[l])
                end --if
            end --if
        end --if
    end --for
end --function

function LoadingScreen(text, currentCount, finalCount)
    if (type(text) ~= 'string') then text = "Loading..." end
    if (type(currentCount) ~= 'number') then currentCount = 0 end
    if (type(finalCount) ~= 'number') then finalCount = 100 end
    local percentage = string.format("(%.2f %%)", currentCount / finalCount * 100)
    local divider = string.rep("-", string.len(text) + 4)
    local progress = currentCount.."/"..finalCount.." Completed "..percentage
    --TODO: Loading Bar
    term.clear()
    CenterPrint({text, divider, progress})
end --function

function CenterPrint(lines, y, noClear)
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
        local x = width / 2 - string.len(v) / 2 + 1
        term.setCursorPos(x, y)
        if (not noClear) then
            term.clearLine()
        end --if
        term.write(v)
        y = y + 1
    end --for
end --function

function LookAtObject(obj)
    local lines = {}
    local matches = string.gmatch(textutils.serialize(obj), "[^\n\r]+")
    for s in matches do
        table.insert(lines, s)
    end --for
    SimpleSelectionScreen(lines, 1)
end --function

function SimpleSelectionScreen(lines, selected, options)
    local width,height = term.getSize()
    if (type(options) ~= 'table') then options = {} end
    if (not options.before) then options.before = 0 end
    if (not options.after) then options.after = 0 end
    options.footer = "'Enter' to select, 'Backspace' to quit."
    local controls = {
        key = {
            [keys.up] = "stepUp",
            [keys.down] = "stepDown",
            [keys.backspace] = "escape",
            [keys.enter] = "enter",
        }
    }
    local result = ComplexSelectionScreen(lines, selected, options, controls)
    term.clear()
    term.setCursorPos(1,1)
    return result
end --function

function ComplexSelectionScreen(lines, selected, options, controls)
    --[[
        string[] lines represents the list of selectable items.
        int selected represents the currently selected item.
        {} options represents the various options that can be applied,
            currently using the 'before' and 'after' values to limit the height
        {{{}}} controls represents what happens at each step.  This is a tree
            controls[event][p1][p2][p3][p4][p5], which can stop at any point and
            the value is a function that is executed or a string to represent
            the action to be taken (where it needs to affect local variables)
    ]]--
    if (not lines) then return false end
    if (not selected) then selected = 1 end
    if (not options) then options = {} end
    if (not controls) then controls = {} end
    controls['key'] = controls['key'] or {}
    controls['key'][keys.backspace] = 'escape'
    local oSelected = selected
    local scroll = 0
    local width, height = term.getSize()
    if (options.title) then
        options.before = options.before + 1
    end --if
    if (options.footer) then
        options.after = options.after + 1
    end --if
    local displayHeight = height - options.before - options.after
    local n = table.getn(lines)
    local ended = false
    repeat
        if (selected < 1) then selected = 1 end
        if (selected > n) then selected = n end
        if (scroll > selected - 1) then scroll = selected - 1 end
        if (scroll < selected - displayHeight) then scroll = selected - displayHeight end
        if (options.title) then
            CenterPrint(options.title, 1)
        end --if
        if (options.footer) then
            CenterPrint(options.footer, height)
        end --if
        Display(lines, scroll, selected, options)
        local ev, p1, p2, p3, p4, p5 = os.pullEvent()
        local action = followTree({ev, p1, p2, p3, p4, p5}, controls)
        if (type(action) == 'function') then action(selected) end
        if (type(action) == 'string') then
            if action == 'stepUp' then
                selected = selected - (ThorneKeys.shiftHeld() and displayHeight or 1)
            elseif action == 'stepDown' then
                selected = selected + (ThorneKeys.shiftHeld() and displayHeight or 1)
            elseif action == 'escape' then
                return false
            elseif action == 'enter' then
                ended = true
            else
                --Unrecognized Action
            end --if
        end --if
    until ended
    return selected
end --function

function MenuTree(tree, title)
    -- tree should be a tree with all leaves being functions (except for title leaves).
    -- Try not to make circular trees, please.
    if (type(tree) == "function") then
        tree()
        return
    end --if
    CatchTypeError(tree, 'table', '#1', 'tree')
    local lines = {}
    local options = {
        center = true,
        footer = 'Backspace to go back.  Enter to select.',
        title = title or "Menu",
    }
    for k,v in pairs(tree) do
        if (k == 'title') then
            options.title = v
        else
            table.insert(lines, k)
        end --if
    end --for

    repeat
        local selected = SimpleSelectionScreen(lines, 1, {})
        if (selected) then
            MenuTree (tree[lines[selected]])
        end --if
    until selected == false
end --function

function followTree(path, tree, findingType)
    if (tree == nil or table.getn(path) == 0) then
        return tree
    end --if
    if (type(tree) == 'table') then
        tree = tree[path[1]]
        table.remove(path, 1)
        return followTree(path, tree, findingType)
    end --if
    if (type(tree) == findingType or findingType == nil) then
        return tree
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

function WaitForEnter()
    repeat
        local event, key, held = os.pullEvent("key")
    until key == 28
end --function