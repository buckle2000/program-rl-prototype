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

function love.load()
    -- reset seed
    math.randomseed(love.timer.getTime())

    -- use custom font
    local font = love.graphics.newFont("assets/Inconsolata-Regular.ttf", 18)
    love.graphics.setFont(font)

    -- dark background
    love.graphics.setBackgroundColor(palette[palette.default_bg])
    require("setup."..SETUP)
end

function step()
    -- step and remove effects
    effect_system_step()

    -- same with objects
    object_system_step()
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
    -- update and remove effects
    effect_system_update()
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
