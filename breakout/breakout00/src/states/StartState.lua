--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state the game is in when we've just started; should
    simply display "Breakout" in large text, as well as a message to press
    Enter to begin.
]]

-- the "__includes" bit here means we're going to inherit all of the methods
-- that BaseState has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves; handy to avoid superfluous code!
StartState = Class { __includes = BaseState }

-- whether we're highlighting "Start" or "High Scores"
local startHighlighted = true

function StartState:update(dt)
  -- toggle highlighted option if we press an arrow key up or down
  if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
    startHighlighted = not startHighlighted
    gSounds['paddle-hit']:play()
  end

  -- we no longer have this globally, so include here
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

local function printMenuOption(text, position, isHightlighted)
  love.graphics.setColor(1, 1, 1, 1)

  if isHightlighted then
    love.graphics.setColor(103 / 255, 1, 1, 1)
  end
  love.graphics.printf(text, 0, VIRTUAL_HEIGHT / 2 + position, VIRTUAL_WIDTH, 'center')

  love.graphics.setColor(1, 1, 1, 1)
end

function StartState:render()
  -- title
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3,
    VIRTUAL_WIDTH, 'center')

  -- instructions
  love.graphics.setFont(gFonts['medium'])

  -- menu options
  printMenuOption("START", 70, startHighlighted)
  printMenuOption("HIGH SCORES", 90, not startHighlighted)
end
