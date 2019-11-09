Effects = {} -- active effects

local E = {} -- all effects
local frames_since_start = 0

-- update effects (newly added once won't be updated)
-- and remove expired effects at the same time
-- deafault (no `o.update`): do nothing (don't remove)
function effect_system_update()
    frames_since_start = frames_since_start + 1
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
end

-- same as effect_system_update()
-- except that the default is to remove the object
function effect_system_step()
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
end

function effect_add(type, target, ...)
    local effect = E[type](target, ...)
    target["effect_"..type] = effect
    table.insert(Effects, effect)
    return effect
end

function effect_cancel(target)
    for type,_ in pairs(E) do
        target["effect_"..type] = nil
    end
end

local GLITCH_CHARSET = {"&","(",")","=","+","-","_","<",">"}
-- permutate glyph of target object rapidly; hacking trope
function E.glitch(target)
    target.char_original = target.char_original or target.char
    return {
        update = function (self)
            target.char = palette_recolor(table.choice(GLITCH_CHARSET), nil, "3")
            local survive = State.programmed
            if not survive then
                target.char = target.char_original
            end
            return survive
        end
    }
end

local BLINK_DURATION = 20 -- in frames
-- this tile will soon disappear, so blink it
function E.blink(target, char_alternate)
    target.char_original = target.char_original or target.char
    return {
        validate = function (self)
            -- this type of effects survive in-between turns
            if target.effect_blink == nil then
                target.char = target.char_original
            end
            -- there can only be one effect_blink per object
            -- expire if the latest blinking effect is not self
            return target.effect_blink == self
        end,
        step = function (self)
            return self:validate()
        end,
        update = function (self)
            if not self:validate() then return false end
            -- disappear with the object
            if not object_select_first(function (o) return o == target end) then
                return false
            end
            if frames_since_start % (BLINK_DURATION * 2) < BLINK_DURATION then
                target.char = char_alternate
            else
                target.char = target.char_original
            end
            return true
        end
    }
end

local HURT_DURATION = 10
function E.hurt(target, damage)
    target.char_original = target.char_original or target.char
    local effect = {
        start = frames_since_start,
        step = function (self) target.char = target.char_original end,
        update = function (self)
            if frames_since_start - self.start > HURT_DURATION then
                return self:step()
            end
            target.char = self.char_damage .. "8r"
            return true
        end
    }
    if damage < 0 then
        effect.char_damage = "✝"
    elseif damage < 10 then
        effect.char_damage = tostring(damage)
    else
        effect.char_damage = "☆"
    end
    return effect
end

return E
