-- generate map
local generate_map = require "algorithm.cellular_automata"
local map = generate_map(MAPWIDTH, MAPHEIGHT)

-- TODO find a place to insert player instead of hardcoding
object_add("player", {x=math.floor(MAPWIDTH/2),y=math.floor(MAPHEIGHT/2)})

-- insert map tiles after player so they move later
for i=1,#map do
    for j=1,#map[1] do
        if map[i][j] == 1 then
            if i == 1 or j == 1 or i == #map or j == #map[1] then
                object_add("wall_border", {x=j-1,y=i-1})
            else
                object_add("wall", {x=j-1,y=i-1})
            end
        else
            if math.random() < 0.02 then
                object_add("enemy_dumb", {x=j-1,y=i-1})
            end
        end
    end
end
