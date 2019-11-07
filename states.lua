State = nil

function state_default()
    State = {}
end

function state_programming(target)
    State = {
        paused = true,
        programmed = target,
        code = {text = "", forcefocus = true}, -- used by UI
    }
    effect_cancel(target)
    effect_add("glitch", target)
end

state_default()
