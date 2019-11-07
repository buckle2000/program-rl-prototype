Action = {}

function Action:die()
    table.drop(Objects, self)
end

function Action:hurt(attacker)
    if self.health and attacker.attack then
        local damage = attacker.attack
        effect_add("hurt", self, damage)
        self.health = self.health - damage
        if self.health < 0 then
            return Action.die(self)
        end
    end
end

function Action:move(dx, dy)
    local newx, newy = self.x + dx, self.y + dy
    local occupied = object_select_one(function (o) return o.x == newx and o.y == newy end)
    -- if the place is empty, move there
    if not occupied then
        self.x = newx; self.y = newy
        return
    end
    -- attack enemy and walls
    return Action.hurt(occupied, self, 1) -- TODO better damage code
end

function to_move(dx, dy)
    return function(self)
        return Action.move(self, dx, dy)
    end
end

-- handle special cases of movement (that only player can do)
function to_move_player(dx, dy)
    return function()
        -- find player
        local player = object_select_player()
        player.step = nil
        local newx, newy = player.x + dx, player.y + dy
        local occupied = object_select_one(function (o) return o.x == newx and o.y == newy end)
        if occupied then
            if occupied == player then
                -- do nothing (wait a turn)
            elseif occupied.is_programmable then
                -- do if bump into wall, program it
                state_programming(occupied)
                return
            end
        end
        player.step = to_move(dx, dy)
        step()
    end
end
