--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class { __includes = BaseState }

local medals = {
  ['gold'] = {
    ['image'] = love.graphics.newImage('gold.png'),
    ['drawn'] = false
  },
  ['silver'] = {
    ['image'] = love.graphics.newImage('silver.png'),
    ['drawn'] = false
  },
  ['bronze'] = {
    ['image'] = love.graphics.newImage('bronze.png'),
    ['drawn'] = false
  }
}

function ScoreState:hideMedals()
  for _, medal in pairs(medals) do
    if medal['drawn'] then
      medal['image'].visible = false
    end
  end
end

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
  self.score = params.score
end

function ScoreState:update(dt)
  -- go back to play if enter is pressed
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then

    gStateMachine:change('countdown')
  end
end

local function showOrDrawMedal(medal)
  if medal['drawn'] then
    medal['image'].visible = true
  else
    love.graphics.draw(medal['image'], VIRTUAL_WIDTH / 2 - 20, 120)
  end
end

function ScoreState:render()
  -- simply render the score to the middle of the screen
  love.graphics.setFont(flappyFont)
  love.graphics.printf('Ouch! You\'ve flapped your last!', 0, 64, VIRTUAL_WIDTH, 'center')

  love.graphics.setFont(mediumFont)
  love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

  if self.score >= 8 then
    showOrDrawMedal(medals['gold'])
  elseif self.score >= 5 then
    showOrDrawMedal(medals['silver'])
  elseif self.score >= 3 then
    showOrDrawMedal(medals['bronze'])
  end

  love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
end
