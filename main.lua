require "conf" -- import constants
require "util"
require "objects"
require "states"
require "effects"
require "actions"
require "code"
require "ui"
local palette = require("palette")

local suit = require 'SUIT'
local generate_map = require "algorithms.cellular_automata"

function love.load()
    -- use custom font
    local font = love.graphics.newFont("assets/Inconsolata-Regular.ttf", 18)
    love.graphics.setFont(font)

    -- dark background
    love.graphics.setBackgroundColor(palette[palette.default_bg])

    -- generate map
    local map = generate_map(MAPWIDTH, MAPHEIGHT)

    -- TODO find a place to insert player instead of hardcoding
    object_add("player", {x=math.floor(MAPWIDTH/2),y=math.floor(MAPHEIGHT/2)})

    -- insert map tiles after player so they move later
    for i=1,#map do
        for j=1,#map[1] do
            if map[i][j] == 1 then
                if i == 1 or j == 1 or i == #map or j == #map[1] then
                    object_add("wall_border", {x=j-1,y=i-1})
                else
                    object_add("wall", {x=j-1,y=i-1})
                end
            else
                if math.random() < 0.02 then
                    object_add("enemy_bline", {x=j-1,y=i-1})
                end
            end
        end
    end
end

function step()
    -- clear effects
    local effect_lasted = {}
    local effects_count_orig = #Effects
    local i = 1
    while i <= #Effects do
        local o = Effects[i]
        -- if the effect is newly added, it will preserve
        -- same for effects who can successfully `step`
        if i > effects_count_orig or o.step and o:step() then
            table.insert(effect_lasted, o)
        end
        i = i + 1
    end
    Effects = effect_lasted

    -- update objects
    for _,o in ipairs(Objects) do
        if o.step then
            o:step()
        end
    end
end

local keybinds = {
    normal = {
        h = to_move_player(-1, 0),
        l = to_move_player( 1, 0),
        k = to_move_player( 0,-1),
        j = to_move_player( 0, 1),
        ["."] = to_move_player(0,0), -- wait
    }
}

function love.keypressed(key, ...)
    -- UI
    if State.paused then
        suit.keypressed(key, ...)
        return
    end

    -- movement logic
    local player_actions = {}
    player_actions = keybinds.normal
    if player_actions[key] then
        player_actions[key](key, ...)
    end
end

function love.textinput(...)
	-- forward text input to SUIT
	suit.textinput(...)
end

function love.update()
    -- update effects (newly added once won't be updated)
    -- and remove expired effects at the same time
    effect_system_update()
    local effect_lasted = {}
    local effects_count_orig = #Effects
    local i = 1
    while i <= #Effects do
        local o = Effects[i]
        -- if the effect is newly added, it will preserve
        -- same for effects with no `update` function
        if i > effects_count_orig or (not o.update) or o:update() then
            table.insert(effect_lasted, o)
        end
        i = i + 1
    end
    Effects = effect_lasted
    if State.programmed then
        ui_show()
    end
end

function love.draw()
    -- draw objects
    for _,o in ipairs(Objects) do
        if o.x and o.y and o.char then
            local char_len =  utf8.len(o.char)
            if char_len < 0 or char_len > 3 then
                error("Invalid glyph/char length: `"..o.char.."`")
            end
            local foreground = "8"
            local background = nil
            if char_len >= 2 then
                foreground = utf8.charat(o.char,2)
            end
            if char_len >= 3 then
                background = utf8.charat(o.char,3)
            end
            if background then
                love.graphics.setColor(palette[background])
                local x, y = tile_to_screen(o.x, o.y)
                love.graphics.rectangle("fill", x, y, TILEWIDTH, TILEHEIGHT)
            end
            love.graphics.setColor(palette[foreground])
            love.graphics.print(utf8.charat(o.char,1), tile_to_screen(o.x, o.y))
        end
    end
    love.graphics.setColor(1, 1, 1) -- restore tint to white
    -- draw UI on top
    suit.draw()

end
