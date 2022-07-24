PowerUp = Class {}

function PowerUp:init(powerUpType)
  self.powerUpType = powerUpType
  self.width = POWERUP_WIDTH
  self.height = POWERUP_HEIGHT
  self.x = math.random(VIRTUAL_WIDTH - POWERUP_WIDTH)
  self.y = 0
  self.dy = POWERUP_DESCENT_RATE
  self.inPlay = true
end

function PowerUp:update(dt)
  self.y = self.y + (self.dy * dt)
end

function PowerUp:render()
  if self.inPlay then
    love.graphics.draw(
      gTextures['main'],
      gFrames['powerups'][self.powerUpType],
      self.x,
      self.y)
  end
end

--[[
  Given a self reference and a target, returns true if the instance's hit box 
  overlaps with the target's, false otherwise.
]]
function PowerUp:collides(target)
  if self.inPlay then
    return AABBCollides(self, target)
  end
  return false
end
