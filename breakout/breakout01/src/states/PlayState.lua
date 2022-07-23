--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class { __includes = BaseState }

function PlayState:init()
  self.paddle = Paddle()
  self.paused = false
end

function PlayState:update(dt)
  -- rb: allow quitting, even in the paused state
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end

  if love.keyboard.wasPressed('space') then
    self.paused = not self.paused
    gSounds['pause']:play()
  end
  if self.paused then
    return
  end

  -- update positions based on velocity
  self.paddle:update(dt)

end

function PlayState:render()
  self.paddle:render()

  -- pause text, if paused
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end
