Objects = {}

-- all objects
local O = {
    -- indestructable player
    player = function (opts) return {
        char = "@", x = opts.x, y = opts.y,
        attack = 1,
    } end,
    -- programmable wall
    wall = function (opts) return {
        char = "#", x = opts.x, y = opts.y,
        is_programmable = true,
        attack = 1,
        health = 10,
    } end,
    -- indestructable wall
    wall_border = function (opts) return {
        char = "#", x = opts.x, y = opts.y,
    } end,
    -- dumb enemy that always moves closer to you
    enemy_dumb = function (opts) return {
        char = "Tg", x = opts.x, y = opts.y,
        attack = 1,
        health = 3,
        step = function (self)
            local player = object_select_player()
            return Action.move_closer_dumb(self, player)
        end
    } end,
}

-- each object takes an action
function object_system_step()
    -- TODO FIX objects can't be removed while doing this step
    for _,o in ipairs(Objects) do
        if o.step then
            o:step()
        end
    end
end

function object_add(type, opts)
    local object = O[type](opts)
    object.type = type
    table.insert(Objects, object)
    return object
end

-- return one object (or nil) that satisfies a certain condition
function object_select_first(condition)
    for _,o in ipairs(Objects) do
        if condition(o) then
            return o
        end
    end
end

function object_select_player()
    return object_select_first(function (o) return o.type == "player" end)
end
