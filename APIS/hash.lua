--[[
    Author: gnush
    A simple string encoder / hasher.
    This is NOT SAFE, so don't user your real world passwords with this.
]]--

function Hash(str)
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

-- Edit: Don't make an actual effect in an API file.
