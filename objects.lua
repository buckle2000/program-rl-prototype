Objects = {}

-- all objects
local O = {
    player = function (opts) return {
        char = "@", x = opts.x, y = opts.y,
        attack = 1,
    } end,
    wall = function (opts) return {
        char = "#", x = opts.x, y = opts.y,
        is_programmable = true,
        attack = 1,
        health = 10,
    } end,
    wall_border = function (opts) return {
        char = "#", x = opts.x, y = opts.y,
    } end,
    enemy_bline = function (opts) return {
        char = "Tg", x = opts.x, y = opts.y,
        health = 3,
        step = function (self)
            local player = object_select_player()
            if self.y == player.y then
                return Action.move(self, math.sign(player.x - self.x), 0)
            else
                return Action.move(self, 0, math.sign(player.y - self.y))
            end            
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
