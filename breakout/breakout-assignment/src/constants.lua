--[[
    GD50 2018
    Breakout Remake

    -- constants --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Some global constants for our application.
]]

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

--[[
  Ball constants
]]
BALL_COLORS_MAX = 7
BALL_WIDTH = 8
BALL_HEIGHT = 8

--[[
  PowerUp constants
]]
POWERUP_WIDTH = 16
POWERUP_HEIGHT = 16
POWERUP_DESCENT_RATE = 60
-- PowerUp types
POWERUP_MULTIBALL = 9
POWERUP_KEY = 10
