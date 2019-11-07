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
            local player = object_get_player()
            if self.y == player.y then
                return Action.move(self, math.sign(player.x - self.x), 0)
            else
                return Action.move(self, 0, math.sign(player.y - self.y))
            end            
        end
    } end,
}

function object_find_one(pred)
    for _,o in ipairs(Objects) do
        if pred(o) then
            return o
        end
    end
end

function object_add(type, opts)
    local object = O[type](opts)
    object.type = type
    table.insert(Objects, object)
    return object
end

function object_get_player()
    return object_find_one(function (o) return o.type == "player" end)
end