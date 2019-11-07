utf8 = require("utf8")

function utf8.sub(s,i,j)
    i=utf8.offset(s,i)
    j=utf8.offset(s,j+1)
    i,j = i or -1,j or -1
    j=j-1
    return string.sub(s,i,j)
end

function utf8.charat(s,i)
    return utf8.sub(s,i,i)
end

function table.drop(t, e)
    for key, value in pairs(t) do
        if e == value then
            table.remove(t, key)
            return key
        end
    end
end

function table.choice(t)
    return t[math.random(#t)]
end

function string.trim(s)
    return s:match "^%s*(.-)%s*$"
end

function math.sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

-- calculate screen coordinate of (the top left corner of) a certain tile
function tile_to_screen(x, y)
    return x * TILEWIDTH, y * TILEHEIGHT
end
