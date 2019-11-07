-- This code is stolen and modified
-- https://github.com/RhiannonMichelmore/lua-cave-gen

function generate(mapwidth, mapheight)
  --creates global "map" (eventually will be the equivalent of 2D array)
  local map = {}

  --the function that creates the starting map, takes x as map width, y as map height
  function initialise(x,y)
    --this is the percentage chance of a cell being "alive" at first, can be tweaked but I find this to be ideal
    local chance = 0.38
    --until you get to your desired size, this adds a row, then the second for loop adds the correct amount of columns to your row, then onto the next row until map height is reached
    for a=1,y do
      table.insert(map,{})
      for b=1,x do
        --cell is a 1 (1=wall or "alive") 41/100 times
        if math.random() < chance then
          table.insert(map[a],1)
        else
          table.insert(map[a],0)
        end
      end
    end
  end

  --the simulation step that actually implements the cellular automata part
  --(0 = PASSAGE, 1 = WALL)
  function simstep()
    --the birth limit
    local birth = 4
    --the death limit
    local death = 3
    --iterates through every cell in the map
    for a=1,#map do
      for b=1,#map[1] do
        --gets the current amount of cells around it (including diagonals)
        local newval = countNeighbours(b,a)
        --if its a wall ("alive") then we need to see if it is lonely, and will "die"
        if map[a][b]==1 then
          --it "dies" if there are less than the death limit of "alive" cells around it
          if newval < death then
            map[a][b] = 0
          else
            --otherwise it stays the same
            map[a][b] = 1
          end
        else
          --if its a "dead" square, it can be "born" if it has enough "alive" squares around it, ie if the neighbours are higher than the birth limit
          if newval > birth then
            map[a][b] = 1
          else
            --otherwise it stays "dead"
            map[a][b] = 0
          end
        end
      end
    end
  end

  --function that counts the number of alive neighbours around a cell, takes the x and y coordinates of that cell
  function countNeighbours(x,y)
    --initialises the number of alive neighbours
    local count = 0
    --iterates through every cell around our target
    for i=-1,1 do
      for j=-1,1 do
        --the current neighbour cell's x coordinate
        local n_X = x+i
        --the current neighbour cell's y coordinate
        local n_Y = y+j
        --if i and j are 0, then we are on our original cell
        if i==0 and j==0 then
          --so do nothing here
          --this next line makes sure we aren't going to check an invalid index of our map table to stop errors, and instead, if it's out of bounds, we just count it as alive
        elseif n_X<1 or n_Y<1 or n_X>#map[1] or n_Y>#map then
          count = count + 1
          --if its a wall, then its alive so add to our count
        elseif map[n_Y][n_X]==1 then
          count = count + 1
        end
      end
    end
    --finally, return the number of alive neighbours for our given cell
    return count
  end

  --runs function to populate map so it is your desired size and sets up alive/dead cells
  initialise(mapwidth,mapheight)

  --repeats the simulation step 4 times (what I find optimal, can be changed to more or less)
  for s=1,1 do
    simstep()
  end

  --make the borders into walls (so player can't leave map)
  for t=1,#map do
    map[t][1] = 1
    map[t][#map[1]] = 1
  end
  for t=1,#map[1] do
    map[1][t] = 1
    map[#map][t] = 1
  end
  return map
end

return generate