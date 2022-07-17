--[[
    GD50 2018

    Pong Remake

    pong-0
    "The Day-0 Update"

    -- Main Program --

    Lecturer (original author): Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.
    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--[[
  Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
  love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })
end

--[[
  Called after update by LOVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
  love.graphics.printf(
    'Hello, Pong!', -- text to render
    0, -- starting X (0 since we will center it based on width)
    WINDOW_HEIGHT / 2 - 6, -- starting Y (halfway down the screen; font height 12)
    WINDOW_WIDTH, -- number of pixels within which to center (the entire screen)
    'center'-- alignment mode: may be 'center', 'left', or 'right'
  )
end
