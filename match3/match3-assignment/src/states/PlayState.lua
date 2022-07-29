--[[
    GD50
    Match-3 Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    State in which we can actually play, moving around a grid cursor that
    can swap two tiles; when two tiles make a legal swap (a swap that results
    in a valid match), perform the swap and destroy all matched tiles, adding
    their values to the player's point score. The player can continue playing
    until they exceed the number of points needed to get to the next level
    or until the time runs out, at which point they are brought back to the
    main menu or the score entry menu if they made the top 10.
]]

PlayState = Class { __includes = BaseState }

function PlayState:init()

  -- start our transition alpha at full, so we fade in
  self.transitionAlpha = 1

  -- position in the grid which we're highlighting
  self.boardHighlightX = 0
  self.boardHighlightY = 0

  -- timer used to switch the highlight rect's color
  self.rectHighlighted = false

  -- flag to show whether we're able to process input (not swapping or clearing)
  self.canInput = true

  -- tile we're currently highlighting (preparing to swap)
  self.highlightedTile = nil

  self.score = 0
  self.timer = 60

  self.moreMatches = true

  -- set our Timer class to turn cursor highlight on and off
  Timer.every(0.5, function()
    self.rectHighlighted = not self.rectHighlighted
  end)

  -- subtract 1 from timer every second
  Timer.every(1, function()
    self.timer = self.timer - 1

    -- play warning sound on timer if we get low
    if self.timer <= 5 then
      gSounds['clock']:play()
    end
  end)
end

function PlayState:enter(params)

  -- grab level # from the params we're passed
  self.level = params.level

  -- spawn a board and place it toward the right
  self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16)

  -- grab score from params if it was passed
  self.score = params.score or 0

  -- score we have to reach to get to the next level
  self.scoreGoal = self.level * 1.25 * 1000
end

function PlayState:swapTiles(tile1, tile2, tweening, reverting)
  reverting = reverting or false

  -- swap grid positions
  local tempX = tile1.gridX
  local tempY = tile1.gridY

  tile1.gridX = tile2.gridX
  tile1.gridY = tile2.gridY

  tile2.gridX = tempX
  tile2.gridY = tempY

  -- swap tile table positions
  self.board.tiles[tile1.gridY][tile1.gridX] = tile1
  self.board.tiles[tile2.gridY][tile2.gridX] = tile2

  if tweening then
    Timer.tween(0.2, {
      [tile1] = { x = tile2.x, y = tile2.y },
      [tile2] = { x = tile1.x, y = tile1.y }
    }):finish(function()
      if not reverting then
        if not self.board:calculateMatches() then
          self:swapTiles(tile2, tile1, true, true)
        end
      end
      self:calculateMatches()
      if not self:boardHasPotentialMatches() then
        self.moreMatches = false
      end
    end)
  end
end

function PlayState:swapWithMatchCheck(tile1, tile2)
  self:swapTiles(tile1, tile2, false, false)
  local match = self.board:hasMatch()
  self:swapTiles(tile1, tile2, false, false)
  return match
end

function PlayState:boardHasPotentialMatches()
  local match = false
  for y = 2, 7 do
    for x = 2, 7 do
      local currentTile = self.board.tiles[y][x]
      local leftNeighbor = self.board.tiles[y][x - 1]
      local rightNeighbor = self.board.tiles[y][x + 1]
      local bottomNeighbor = self.board.tiles[y + 1][x]
      local topNeighbor = self.board.tiles[y - 1][x]
      match = self:swapWithMatchCheck(currentTile, leftNeighbor)
          or self:swapWithMatchCheck(currentTile, rightNeighbor)
          or self:swapWithMatchCheck(currentTile, bottomNeighbor)
          or self:swapWithMatchCheck(currentTile, topNeighbor)
      if match then
        return true
      end
    end
  end
  return false
end

local next = next
function PlayState:update(dt)
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end

  -- go back to start if time runs out
  if self.timer <= 0 then

    -- clear timers from prior PlayStates
    Timer.clear()

    gSounds['game-over']:play()

    gStateMachine:change('game-over', {
      score = self.score
    })
  end

  if not self.moreMatches then
    -- clear timers from prior PlayStates
    Timer.clear()

    gSounds['game-over']:play()

    gStateMachine:change('game-over', {
      score = self.score,
      message = "No more matches!"
    })
  end

  -- go to next level if we surpass score goal
  if self.score >= self.scoreGoal then

    -- clear timers from prior PlayStates
    -- always clear before you change state, else next state's timers
    -- will also clear!
    Timer.clear()

    gSounds['next-level']:play()

    -- change to begin game state with new level (incremented)
    gStateMachine:change('begin-game', {
      level = self.level + 1,
      score = self.score
    })
  end

  if self.canInput then
    if next(love.mouse.buttonClicked) ~= nil then
      local x = love.mouse.buttonClicked[1][1]
      local y = love.mouse.buttonClicked[1][2]
      for _, tileTable in pairs(self.board.tiles) do
        for _, tile in pairs(tileTable) do
          if tile:wasClicked(x, y) then
            if not self.highlightedTile then
              self.highlightedTile = tile
            elseif self.highlightedTile == tile then
              self.highlightedTile = nil
            else
              if self.board:adjacentTo(self.highlightedTile, tile) then
                self:swapTiles(self.highlightedTile, tile, true)
                self.highlightedTile = nil
              else
                self.highlightedTile = tile
              end
            end
          end
        end
      end
    end

    -- move cursor around based on bounds of grid, playing sounds
    if love.keyboard.wasPressed('up') then
      self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
      gSounds['select']:play()
    elseif love.keyboard.wasPressed('down') then
      self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
      gSounds['select']:play()
    elseif love.keyboard.wasPressed('left') then
      self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
      gSounds['select']:play()
    elseif love.keyboard.wasPressed('right') then
      self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
      gSounds['select']:play()
    end

    -- if we've pressed enter, to select or deselect a tile...
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

      -- if same tile as currently highlighted, deselect
      local x = self.boardHighlightX + 1
      local y = self.boardHighlightY + 1

      -- if nothing is highlighted, highlight current tile
      if not self.highlightedTile then
        self.highlightedTile = self.board.tiles[y][x]

        -- if we select the position already highlighted, remove highlight
      elseif self.highlightedTile == self.board.tiles[y][x] then
        self.highlightedTile = nil

        -- if the difference between X and Y combined of this highlighted tile
        -- vs the previous is not equal to 1, also remove highlight
      elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
        gSounds['error']:play()
        self.highlightedTile = nil
      else
        self:swapTiles(self.highlightedTile, self.board.tiles[y][x], true)
      end
    end
  end

  Timer.update(dt)
end

--[[
    Calculates whether any matches were found on the board and tweens the needed
    tiles to their new destinations if so. Also removes tiles from the board that
    have matched and replaces them with new randomized tiles, deferring most of this
    to the Board class.
]]
function PlayState:calculateMatches()
  self.highlightedTile = nil

  -- if we have any matches, remove them and tween the falling blocks that result
  local matches = self.board:calculateMatches()

  if matches then
    gSounds['match']:stop()
    gSounds['match']:play()

    -- add score for each match
    for _, match in pairs(matches) do
      for _, tile in pairs(match) do
        self.score = self.score + (tile.variety * 50)
      end

      self.timer = self.timer + #match
    end

    -- remove any tiles that matched from the board, making empty spaces
    self.board:removeMatches()

    -- gets a table with tween values for tiles that should now fall
    local tilesToFall = self.board:getFallingTiles()

    -- tween new tiles that spawn from the ceiling over 0.25s to fill in
    -- the new upper gaps that exist
    Timer.tween(0.25, tilesToFall):finish(function()

      -- recursively call function in case new matches have been created
      -- as a result of falling blocks once new blocks have finished falling
      self:calculateMatches()
    end)

    -- if no matches, we can continue playing
  else
    self.canInput = true
  end
end

function PlayState:render()
  -- render board of tiles
  self.board:render()

  -- render highlighted tile if it exists
  if self.highlightedTile then

    -- multiply so drawing white rect makes it brighter
    love.graphics.setBlendMode('add')

    love.graphics.setColor(1, 1, 1, 96 / 255)
    love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
      (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)

    -- back to alpha
    love.graphics.setBlendMode('alpha')
  end

  -- render highlight rect color based on timer
  if self.rectHighlighted then
    love.graphics.setColor(217 / 255, 87 / 255, 99 / 255, 1)
  else
    love.graphics.setColor(172 / 255, 50 / 255, 50 / 255, 1)
  end

  -- draw actual cursor rect
  love.graphics.setLineWidth(4)
  love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272),
    self.boardHighlightY * 32 + 16, 32, 32, 4)

  -- GUI text
  love.graphics.setColor(56 / 255, 56 / 255, 56 / 255, 234 / 255)
  love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

  love.graphics.setColor(99 / 255, 155 / 255, 1, 1)
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
  love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
  love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
  love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end
