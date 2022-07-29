--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class {}

function Tile:init(x, y, color, variety)

  -- board positions
  self.gridX = x
  self.gridY = y

  self.width = 32
  self.height = 32

  -- coordinate positions
  self.x = (self.gridX - 1) * self.width
  self.y = (self.gridY - 1) * self.height

  self.containerX = 0
  self.containerY = 0

  -- tile appearance/points
  self.color = color
  self.variety = variety

  self.shiny = math.random(100) == 100
end

function Tile:render(x, y)
  self.containerX = x
  self.containerY = y

  -- draw shadow
  love.graphics.setColor(34, 32, 52, 255)
  love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
    self.x + x + 2, self.y + y + 2)

  -- draw tile itself
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(
    gTextures['main'],
    gFrames['tiles'][self.color][self.variety],
    self.x + x,
    self.y + y)

  if self.shiny then
    local preLineWidth = love.graphics.getLineWidth()
    local preLineStyle = love.graphics.getLineStyle()

    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("rough")
    love.graphics.setColor(1, 1, 1, 112 / 255)
    love.graphics.rectangle(
      'line',
      self.x + x,
      self.y + y,
      32,
      32,
      4)

    love.graphics.setLineStyle(preLineStyle)
    love.graphics.setLineWidth(preLineWidth)
    love.graphics.setColor(255, 255, 255, 255)
  end
end

--[[
  Given a self ref and a clicked x and y, returns true if the tile was clicked.
]]
function Tile:wasClicked(x, y)
  return x >= self.containerX + self.x
      and x <= self.containerX + self.x + self.width
      and y >= self.containerY + self.y
      and y <= self.containerY + self.y + self.height
end
