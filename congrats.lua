
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local featherCount = composer.getVariable( "featherCount")
local livesCount = composer.getVariable( "livesCount")

local function gotoMenu()

		composer.gotoScene("menu", { time=1000, effect="crossFade" })
end

local function collectables()
	  feathers = display.newText("You collected: " .. featherCount .. " feathers", 920, 490, native.systemFont, 50 )
		lives = display.newText("You finished with: " .. livesCount .. " lives", 920, 560, native.systemFont, 50 )
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

	local replay = display.newImageRect( sceneGroup, "menu.png", 300, 150)
	replay.x = display.contentCenterX-45
  replay.y = display.contentCenterY+300


	replay:addEventListener( "tap", gotoMenu )

	collectables()

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
		display.remove(feathers)
		display.remove(lives)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "congrats" )
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
