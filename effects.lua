Effects = {} -- active effects

local E = {} -- all effects
local frames_since_start = 0

function effect_system_update()
    frames_since_start = frames_since_start + 1
end

function effect_add(type, target, ...)
    local effect = E[type](target, ...)
    target["effect_"..type] = effect
    table.insert(Effects, effect)
    return effect
end

function effect_cancel(target)
    for type,_ in ipairs(E) do
        target["effect_"..type] = nil
    end
end

local GLITCH_CHARSET = {"&","(",")","=","+","-","_","<",">"}
-- permutate glyph of target object rapidly; hacking trope
function E.glitch(target)
    target.char_original = target.char
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
        step = function (self) return true end, -- always survive between turns
        update = function (self)
            -- there can only be one effect_blink per object
            if target.effect_blink ~= self then
                target.char = target.char_original
                return false
            end
            -- disappear with the object
            if not object_find_one(function (o) return o == target end) then
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
