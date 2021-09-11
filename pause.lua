
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local sound
local soundButton
local muted = false
local function gotoMenu()
		audio.stop()
		composer.gotoScene("menu")
end

function resumeGame()
    -- Code to resume game
		audio.resume()
    composer.hideOverlay( "fade", 400 )
end

function quitGame()
	audio.resume()
	native.requestExit()
end

function muteVolume()
	if(muted == false)then
		soundButton:setSequence( "off" )
		soundButton:play()
		audio.setVolume(0.0, { channel=1 })
		muted = true
	elseif(muted == true)then
		soundButton:setSequence( "on" )
		soundButton:play()
		audio.setVolume(0.03, { channel=1 })
		-- audio.pause()
		muted = false
	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, "MainMenu.png", 1920, 1080)
	background.x = display.contentCenterX
  background.y = display.contentCenterY

	local resume = display.newImageRect( sceneGroup, "resume.png", 300, 150)
	resume.x = display.contentCenterX- 450
  resume.y = display.contentCenterY+200

	resume:addEventListener( "tap", resumeGame )

	local menu = display.newImageRect( sceneGroup, "menu.png", 300, 150)
	menu.x = display.contentCenterX+ 350
  menu.y = display.contentCenterY+200

	menu:addEventListener( "tap", gotoMenu )

	local quit = display.newImageRect( sceneGroup, "QUIT.png", 300, 150)
	quit.x = display.contentCenterX-50
	quit.y = display.contentCenterY+200

	quit:addEventListener( "tap", quitGame )

	sheetOptions =
  {
      width = 64,
      height = 64,
      numFrames = 2
  }

	local soundSheet = {
    -- non-consecutive frames sequence
    {
        name = "on",
        frames={2},
        time = 1000,
        loopCount = 1
    },
    {
			name = "off",
			frames={1},
			time = 1000,
			loopCount = 1
    }
}

  sound = graphics.newImageSheet( "mute.png", sheetOptions )
	soundButton = display.newSprite (sceneGroup, sound, soundSheet)
	-- sound.myName = "sound"
	soundButton.x = display.contentCenterX - 800
	soundButton.y = display.contentCenterY - 500


	soundButton:addEventListener( "tap", muteVolume )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase
	local parent = event.parent  -- Reference to the parent scene object

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		-- -- Call the "resumeGame()" function in the parent scene
		parent:resumeGame()
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "pause" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
