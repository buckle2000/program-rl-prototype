local suit = require 'SUIT'

function ui_show()
    local programmed = State.programmed -- the object ot be programmed
        
    local x, y = tile_to_screen(programmed.x+1, programmed.y+1)
    if x + UIWIDTH >= love.graphics.getWidth() then
        x = x - TILEWIDTH - UIWIDTH
    end
    suit.layout:reset(x, y)
    
    local code_input = suit.Input(State.code, suit.layout:row(UIWIDTH, 30))
    if State.code.last_text == nil then
        State.code.text = "" -- hack to ignore the first keystroke
    end
    if State.code.text ~= State.code.last_text then

        State.code.last_text = State.code.text
        State.code.result = code_try_compile(programmed, State.code.text)
    end
    local indicator_text
    if State.code.result then
        indicator_text = State.code.result.description
    else
        indicator_text = "Invalid"
    end
    if (suit.Button(indicator_text, suit.layout:row()).hit
            or code_input.submitted) and State.code.result then
        State.programmed.step = State.code.result.get_action()
        -- TODO deal with state.code.text seriously
        -- TODO better movement code that never intersects two objects
        state_default()
    end
end