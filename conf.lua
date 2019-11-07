-- SETUP = "one_cave_with_enemies"
SETUP = "map_generation_test"
TILEWIDTH = 10; TILEHEIGHT = 18
MAPWIDTH = 40; MAPHEIGHT = 20
UIWIDTH = 120

DIRECTIONS = {
    left = {
        glyph = "←b",
        x = -1,
        y =  0,
    },
    right = {
        glyph = "→b",
        x =  1,
        y =  0,
    },
    up = {
        glyph = "↑b",
        x =  0,
        y = -1,
    },
    down = {
        glyph = "↓b",
        x =  0,
        y =  1,
    },
}

function love.conf(t)
    t.version = "11.3"
    -- resize window and move to top left corner
    t.window.width = TILEWIDTH * MAPWIDTH
    t.window.height = TILEHEIGHT * MAPHEIGHT
    t.window.x = 0
    t.window.y = 9
end
