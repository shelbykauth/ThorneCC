--[[
    Author: Dartania Thorne
    Part of ThorneCC, ThorneAPI
]]--

local shift = false
local alt = false
local ctrl = false

function shiftHeld()
    return shift
end
function altHeld()
    return alt
end
function ctrlHeld()
    return ctrl
end

function shiftDown()
    shift = true
end
function altDown()
    alt = true
end
function ctrlDown()
    ctrl = true
end
function shiftUp()
    shift = false
end
function altUp()
    alt = false
end
function ctrlUp()
    ctrl = false
end
