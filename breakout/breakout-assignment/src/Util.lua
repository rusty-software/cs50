--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions for writing games.
]]

--[[
    Utility function for slicing tables, a la Python.

    https://stackoverflow.com/questions/24821045/does-lua-have-something-like-pythons-slice
]]
function table.slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced + 1] = tbl[i]
  end

  return sliced
end

--[[
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
]]
function GenerateQuads(atlas, tilewidth, tileheight)
  local sheetWidth = atlas:getWidth() / tilewidth
  local sheetHeight = atlas:getHeight() / tileheight

  local sheetCounter = 1
  local spritesheet = {}

  for y = 0, sheetHeight - 1 do
    for x = 0, sheetWidth - 1 do
      spritesheet[sheetCounter] =
      love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
        tileheight, atlas:getDimensions())
      sheetCounter = sheetCounter + 1
    end
  end

  return spritesheet
end

--[[
    This function is specifically made to piece out the bricks from the
    sprite sheet. Since the sprite sheet has non-uniform sprites within,
    we have to return a subset of GenerateQuads.
]]
function GenerateQuadsBricks(atlas)
  return table.slice(GenerateQuads(atlas, 32, 16), 1, 21)
end

--[[
    This function is specifically made to piece out the paddles from the
    sprite sheet. For this, we have to piece out the paddles a little more
    manually, since they are all different sizes.
]]
function GenerateQuadsPaddles(atlas)
  local x = 0
  local y = 64

  local counter = 1
  local quads = {}

  for i = 0, 3 do
    -- smallest
    quads[counter] = love.graphics.newQuad(x, y, 32, 16,
      atlas:getDimensions())
    counter = counter + 1
    -- medium
    quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16,
      atlas:getDimensions())
    counter = counter + 1
    -- large
    quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16,
      atlas:getDimensions())
    counter = counter + 1
    -- huge
    quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16,
      atlas:getDimensions())
    counter = counter + 1

    -- prepare X and Y for the next set of paddles
    x = 0
    y = y + 32
  end

  return quads
end

--[[
    This function is specifically made to piece out the balls from the
    sprite sheet. For this, we have to piece out the balls a little more
    manually, since they are in an awkward part of the sheet and small.
]]
function GenerateQuadsBalls(atlas)
  local x = 96
  local y = 48

  local counter = 1
  local quads = {}

  for i = 0, 3 do
    quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
    x = x + 8
    counter = counter + 1
  end

  x = 96
  y = 56

  for i = 0, 2 do
    quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
    x = x + 8
    counter = counter + 1
  end

  return quads
end

--[[
  Given a breakout sprite sheet, returns a table filled with the quads representing the PowerUps.

  Indexes for the interesting PowerUps include:
  * 9: extra balls
  * 10: key
]]
function GenerateQuadsPowerUps(breakoutSpiteSheet)
  local blockHeight = 16
  local paddleHeight = 16

  -- power ups are located beneath the block and paddles sprites
  local powerUpX = 0
  local powerUpY = (4 * blockHeight) + (8 * paddleHeight)
  local powerUpQuads = {}

  -- there are 10 power ups, and tables are 1-indexed
  for i = 1, 10 do
    powerUpQuads[i] = love.graphics.newQuad(
      powerUpX,
      powerUpY,
      POWERUP_WIDTH,
      POWERUP_HEIGHT,
      breakoutSpiteSheet:getDimensions())

    powerUpX = powerUpX + POWERUP_WIDTH
  end

  return powerUpQuads
end

local function leftOf(source, target)
  return source.x + source.width < target.x
end

local function rightOf(source, target)
  return source.x > target.x + target.width
end

local function above(source, target)
  return source.y + source.height < target.y
end

local function below(source, target)
  return source.y > target.y + target.height
end

--[[
  Given a source and target, returns true if the source is within the bounds 
  of the targeting, otherwise false.
]]
function AABBCollides(source, target)
  if leftOf(source, target)
      or rightOf(source, target)
      or above(source, target)
      or below(source, target) then
    return false
  end

  return true
end
