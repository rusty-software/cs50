PauseState = Class { __includes = BaseState }

function PauseState:enter()
  print('entering pause state')
  isPaused = true
end

function PauseState:exit()
  print('exiting pause state')
  isPaused = false
end

function PauseState:update(dt)
  if love.keyboard.wasPressed('p') then
    gStateMachine:change('play')
  end
end
