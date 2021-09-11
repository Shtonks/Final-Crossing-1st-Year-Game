
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local mainMusic = audio.loadStream( "titleScreen.mp3" )
local titleScreenMusicChannel
local audioLevel
local function gotoGame()
		audio.stop()
		composer.gotoScene("Level1", { time=1000, effect="crossFade" })
end

local function gotoArea1()
		audio.stop()
		composer.gotoScene("Level1", { time=1000, effect="crossFade" })
end

local function gotoArea2()
		audio.stop()
		composer.gotoScene("directToLev8", { time=1000, effect="crossFade" })
end

local function gotoArea3()
		audio.stop()
		composer.gotoScene("directToLev4", { time=1000, effect="crossFade" })
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
  titleScreenMusicChannel = audio.play( mainMusic, { channel=1, loops=-1} )
	audioLevel = audio.setVolume( 0.03, { channel=1 } )

	local menu = display.newImageRect( sceneGroup, "MainMenu.png", 1920, 1080)
	menu.x = display.contentCenterX
  menu.y = display.contentCenterY

	local playButton = display.newImageRect( sceneGroup, "play.png", 300, 150)
	playButton.x = display.contentCenterX
  playButton.y = display.contentCenterY

	local Area1 = display.newImageRect( sceneGroup, "Area1.png", 300, 150)
	Area1.x = display.contentCenterX-600
	Area1.y = display.contentCenterY + 300

	local Area2 = display.newImageRect( sceneGroup, "Area2.png", 300, 150)
	Area2.x = display.contentCenterX
	Area2.y = display.contentCenterY + 300

	local Area3 = display.newImageRect( sceneGroup, "Area3.png", 300, 150)
	Area3.x = display.contentCenterX + 600
	Area3.y = display.contentCenterY + 300


	playButton:addEventListener( "tap", gotoGame )
	Area1:addEventListener( "tap", gotoArea1 )
	Area2:addEventListener( "tap", gotoArea2 )
	Area3:addEventListener( "tap", gotoArea3 )

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

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

		composer.removeScene( "menu" )
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
