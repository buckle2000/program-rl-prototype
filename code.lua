local grammar = {
    {
        description = "Cancel",
        pattern = "",
        apply = function(ctx)
            return nil
        end
    },
    {
        description = "Expire",
        pattern = "expire",
        apply = function(ctx)
            effect_add("blink", ctx.target, "X")
            return Action.die
        end
    }
}

for dir_name,dir in pairs(DIRECTIONS) do
    table.insert(grammar, {
        description = "Move "..dir_name,
        pattern = "move%s+"..dir_name,
        apply = function(ctx)
            effect_add("blink", ctx.target, dir.glyph)
            return to_move(dir.x, dir.y)
        end
    })
end

local function validate_rule(rule, text)
    text = text:trim():lower()
    return text:find("^"..rule.pattern.."$") -- only full match will be accepted
end

function code_try_compile(target, text)
    local ctx = { target = target }
    for _,rule in ipairs(grammar) do
        if validate_rule(rule, text) then
            return {
                description = rule.description,
                get_action = function () return rule.apply(ctx) end,
            }
            -- TODO compile multiline code
            -- local terminal = rule.apply(ctx)
            -- if terminal then
            --     return terminal
            -- end
        end
    end
end
