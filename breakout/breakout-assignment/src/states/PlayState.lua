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

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.highScores = params.highScores
  self.ball = params.ball
  self.level = params.level

  self.recoverPoints = params.recoverPoints or 5000
  self.enlargePoints = params.enlargePoints or 2500

  -- give ball random starting velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)

  self.powerUps = {}
  -- manage ball via a collection, since a power up can add to the ball count
  self.balls = { self.ball }

  self:setNextPowerupTime()
end

--[[
  Given a self ref, sets the next powerup time to a random value between 10 
  and 15 seconds in the future. 
]]
function PlayState:setNextPowerupTime()
  self.nextPowerupTime = os.time() + math.random(10, 15)
end

--[[
  Given a self reference and some optional input, returns true if a PowerUp 
  should be spawned, false otherwise.
]]
function PlayState:shouldSpawnPowerUp(params)
  -- TODO: hard-coded extra balls power up
  local ballCount = 0
  for _, ball in pairs(self.balls) do
    if ball.inPlay then
      ballCount = ballCount + 1
    end
  end
  return self.powerUps[POWERUP_MULTIBALL] == nil
      and ballCount <= 1
      and os.time() > self.nextPowerupTime
end

--[[
  Given a self reference and some optional input, instantiates a PowerUp and 
  adds it to the powerUps collection.
]]
function PlayState:spawnPowerUp(params)
  -- TODO: hard-coded extra balls power up
  self.powerUps[POWERUP_MULTIBALL] = PowerUp(POWERUP_MULTIBALL)
end

function PlayState:createBall()
  local ball = Ball(math.random(BALL_COLORS_MAX))
  ball.x = self.paddle.x + (self.paddle.width / 2) - (BALL_WIDTH / 2)
  ball.y = self.paddle.y - BALL_HEIGHT
  ball.dx = math.random(-200, 200)
  ball.dy = math.random(-50, -60)
  return ball
end

function PlayState:enactPowerUp(powerUpType)
  -- TODO: hard-coded extra balls power up
  table.insert(self.balls, self:createBall())
  table.insert(self.balls, self:createBall())
end

local function handleBallPaddleCollision(ball, paddle)
  if ball.inPlay and ball:collides(paddle) then
    -- raise ball above paddle in case it goes below it, then reverse dy
    ball.y = paddle.y - BALL_HEIGHT
    ball.dy = -ball.dy

    --
    -- tweak angle of bounce based on where it hits the paddle
    --

    -- if we hit the paddle on its left side while moving left...
    if ball.x < paddle.x + (paddle.width / 2) and paddle.dx < 0 then
      ball.dx = -50 + -(8 * (paddle.x + paddle.width / 2 - ball.x))

      -- else if we hit the paddle on its right side while moving right...
    elseif ball.x > paddle.x + (paddle.width / 2) and paddle.dx > 0 then
      ball.dx = 50 + (8 * math.abs(paddle.x + paddle.width / 2 - ball.x))
    end

    gSounds['paddle-hit']:play()
  end
end

local function handleBallBrickCollision(ball, brick)
  if not ball.inPlay then
    return
  end

  --
  -- collision code for bricks
  --
  -- we check to see if the opposite side of our velocity is outside of the brick;
  -- if it is, we trigger a collision on that side. else we're within the X + width of
  -- the brick and should check to see if the top or bottom edge is outside of the brick,
  -- colliding on the top or bottom accordingly
  --

  -- left edge; only check if we're moving right, and offset the check by a couple of pixels
  -- so that flush corner hits register as Y flips, not X flips
  if ball.x + 2 < brick.x and ball.dx > 0 then

    -- flip x velocity and reset position outside of brick
    ball.dx = -ball.dx
    ball.x = brick.x - 8

    -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
    -- so that flush corner hits register as Y flips, not X flips
  elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

    -- flip x velocity and reset position outside of brick
    ball.dx = -ball.dx
    ball.x = brick.x + 32

    -- top edge if no X collisions, always check
  elseif ball.y < brick.y then

    -- flip y velocity and reset position outside of brick
    ball.dy = -ball.dy
    ball.y = brick.y - 8

    -- bottom edge if no X collisions or top collision, last possibility
  else

    -- flip y velocity and reset position outside of brick
    ball.dy = -ball.dy
    ball.y = brick.y + 16
  end

  -- slightly scale the y velocity to speed up the game, capping at +- 150
  if math.abs(ball.dy) < 150 then
    ball.dy = ball.dy * 1.02
  end
end

--[[
  Given a self reference, iterates through the balls collection. If the ball
  is in play and below the boundary, plays a hurt sound and marks the ball as 
  out.
]]
function PlayState:updateBallsInPlay()
  local inPlayCount = 0
  for _, ball in pairs(self.balls) do
    if ball.inPlay and ball.y >= VIRTUAL_HEIGHT then
      gSounds['hurt']:play()
      ball.inPlay = false
    elseif ball.inPlay then
      inPlayCount = inPlayCount + 1
    end
  end
  if inPlayCount == 1 and self.nextPowerupTime < os.time() then
    self:setNextPowerupTime()
  end
end

--[[
  Given a self reference, returns true if any balls from the balls collection 
  are in play, false otherwise.
]]
function PlayState:anyBallsInPlay()
  for _, ball in pairs(self.balls) do
    if ball.inPlay then
      return true
    end
  end
  return false
end

function PlayState:update(dt)
  -- handle quit (short circuit)
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end

  -- handle pause
  if love.keyboard.wasPressed('space') then
    self.paused = not self.paused
    gSounds['pause']:play()
  end
  if self.paused then
    return
  end

  if self:shouldSpawnPowerUp(nil) then
    self:spawnPowerUp(nil)
  end

  -- update positions based on velocity
  self.paddle:update(dt)
  for _, ball in pairs(self.balls) do
    ball:update(dt)
  end
  for k, powerup in pairs(self.powerUps) do
    powerup:update(dt)
    if powerup:collides(self.paddle) then
      powerup.inPlay = false
      self.powerUps[k] = nil
      self:enactPowerUp(powerup.powerUpType)
    elseif powerup.y > VIRTUAL_HEIGHT then
      powerup.inPlay = false
      self.powerUps[k] = nil
      self:setNextPowerupTime()
    end
  end

  for _, ball in pairs(self.balls) do
    handleBallPaddleCollision(ball, self.paddle)
  end

  -- detect collision across all bricks with the ball
  for k, brick in pairs(self.bricks) do

    -- only check collision if we're in play
    if brick.inPlay then
      for _, ball in pairs(self.balls) do
        if ball.inPlay then
          if ball:collides(brick) then

            -- add to score
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            -- trigger the brick's hit function, which removes it from play
            brick:hit()

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
              gSounds['victory']:play()

              gStateMachine:change('victory', {
                level = self.level,
                paddle = self.paddle,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                ball = self.ball,
                recoverPoints = self.recoverPoints,
                enlargePoints = self.enlargePoints
              })
            end

            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then
              if self.health < 3 then
                self.health = self.health + 1
                -- play recover sound effect
                gSounds['recover']:play()
              end

              -- multiply recover points by 2
              self.recoverPoints = math.min(100000, self.recoverPoints * 2)
            end

            if self.score > self.enlargePoints then
              self.paddle:enlargeSize()
              self.enlargePoints = math.min(25000, self.enlargePoints * 2)
            end

            handleBallBrickCollision(ball, brick)

            break
          end
        end
      end
      -- all the balls can hit the same brick, but disallow balls hitting more
      -- than one simultaneously
      -- break
    end
  end

  self:updateBallsInPlay()

  if not self:anyBallsInPlay() then
    self.health = self.health - 1
    if self.health == 0 then
      gStateMachine:change('game-over', {
        score = self.score,
        highScores = self.highScores
      })
    else
      self.paddle:reduceSize()
      gStateMachine:change('serve', {
        paddle = self.paddle,
        bricks = self.bricks,
        health = self.health,
        score = self.score,
        highScores = self.highScores,
        level = self.level,
        recoverPoints = self.recoverPoints,
        enlargePoints = self.enlargePoints
      })
    end
  end

  -- for rendering particle systems
  for k, brick in pairs(self.bricks) do
    brick:update(dt)
  end
end

function PlayState:render()
  -- render bricks
  for k, brick in pairs(self.bricks) do
    brick:render()
  end

  -- render all particle systems
  for k, brick in pairs(self.bricks) do
    brick:renderParticles()
  end

  for _, powerup in pairs(self.powerUps) do
    powerup:render()
  end

  self.paddle:render()

  for _, ball in pairs(self.balls) do
    ball:render()
  end

  renderScore(self.score)
  renderHealth(self.health)

  -- pause text, if paused
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end

function PlayState:checkVictory()
  for k, brick in pairs(self.bricks) do
    if brick.inPlay then
      return false
    end
  end

  return true
end
