--
--
-- local tiled = require "com.ponywolf.ponytiled"
-- local mapData = require"Images.Level"
-- local map = tiled.new(mapData, "Images")
local composer = require( "composer" )

-- Hide status bar
--display.setStatusBar( display.HiddenStatusBar )

-- Seed the random number generator
math.randomseed( os.time() )

-- Go to the menu screen

local options = {
    effect = "fade",
    time = 1000,
    --params = {someKey = "someValue",someOtherKey = 10}
}
composer.gotoScene( "menu" )
