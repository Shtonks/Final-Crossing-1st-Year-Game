
local composer = require( "composer" )
-- local physics = require( "physics" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local tiled = require "com.ponywolf.ponytiled"
local physics = require( "physics" )

physics.start()
physics.setGravity(0, 40)
-- physics.setDrawMode( "hybrid" )



-- map.x,map.y = display.contentCenterX - map.designedWidth/2, display.contentCenterY - map.designedHeight/2


--Declare variables
local livesCount = 40
local livesText
local feathersText
local featherCount = 0
-- local batteryCount = 0
local characterJumping = 0
local turnCount = 0
local keyPressed = 0
local died = false
local paused = false
local backgroundMusic = audio.loadStream( "shrine.wav" )
local walkSound = audio.loadSound( "walk.mp3" )
local featherSound = audio.loadSound( "feather.mp3" )
local heartSound = audio.loadSound( "heart.mp3" )
local batterySound = audio.loadSound( "battery.mp3" )
local audioLevel
local walkChannel
local collectablesChannel
local nextScene
local sheetOptions
local walkCharacter
local walking

local upPressed = false
local downPressed = false
local leftPressed = false
local rightPressed = false

local mapData
local map
local character
local feathers
local lives
local spawnPoint = false

local function updateText()
    livesText.text = "x " .. livesCount
end

function scene:resumeGame()
    -- Code to resume game
    audioLevel = composer.getVariable( "audioLevel" )
    audio.resume()
    keyPressed = 0
    physics.start()
end


local function pauseScreen(event)
  if (event.phase == "down" and keyPressed == 0) then
      if (event.keyName == "escape") then
        composer.setVariable( "audioLevel", audioLevel )
        keyPressed = 1
        physics.pause()
        composer.showOverlay( "pause", {isModal=true, effect="slideDown"}  )
      end
  end
end

local function gotoDeathScreen()
    audio.pause()
    physics.pause()
    composer.setVariable( "livesCount", livesCount )
    composer.setVariable( "featherCount", featherCount )
    composer.gotoScene("gameOver", { time=700, effect="slideLeft" })
end

local function gotoLevel2(self, event)
    if(event.other.myName == "exit" or event.other.myName == "character") then
      if(event.phase == "began") then
        composer.setVariable( "livesCount", livesCount )
        composer.setVariable( "featherCount", featherCount )
        -- composer.setVariable( "batteryCount", batteryCount )
        composer.setVariable( "nextScene", "Level2" )
        composer.gotoScene("loading", { time=20, effect="slideLeft" })
      end
    end
  end

  local function key( event)
    if(paused == false) then
      if (event.phase == "down") then
          if (event.keyName == "w") then
              upPressed = true
          elseif (event.keyName == "s") then
              downPressed = true
          elseif (event.keyName == "a") then
            if(turnCount == 1)then
              character:setSequence( "walk" )
              character:scale(1,1)
              character:play()
              turnCount = 1
            elseif(turnCount == 0)then
              character:setSequence( "walk" )
              character:scale(-1,1)
              character:play()
              turnCount = 1
            end
              leftPressed = true
          elseif (event.keyName == "d") then
            if(turnCount == 1)then
              character:setSequence( "walk" )
              character:scale(-1,1)
              character:play()
              turnCount = 0
            elseif(turnCount == 0)then
              character:setSequence( "walk" )
              character:scale(1,1)
              character:play()
              turnCount = 0
            end
              rightPressed = true
          end
      elseif (event.phase == "up") then
          if (event.keyName == "w") then
              upPressed = false
          elseif (event.keyName == "s") then
              downPressed = false
          elseif (event.keyName == "a") then
              audio.stop(2)
              leftPressed = false
          elseif (event.keyName == "d") then
              audio.stop(2)
              rightPressed = false
          end
          character:setSequence( "idle" )
          character:scale(1,1)
          character:play()
      end
    end
  end


local function jump(event)
  if(upPressed and characterJumping < 2) then
        character:applyLinearImpulse( 0, -80, character.x, character.y )
        characterJumping = characterJumping + 1
  end
  local function onCollision( self, event )
      if ( event.phase == "began" ) then
          characterJumping = 0
          character:setLinearVelocity( 0, 0 )
      end
  end
      character.collision = onCollision
      character:addEventListener( "collision" )
end


local function invis(event)
  if (downPressed) then
    leftPressed = false
    rightPressed = false
    upPressed = false
    character.isBodyActive = false
    character.alpha = 0.5
  else
    character.alpha = 1
    character.isBodyActive = true

  end
end


local function enterFrame(event)
    if (leftPressed) then
       walkChannel =  audio.play( walkSound, { channel=2} )
       character.x = character.x - 8
    end
    if (rightPressed) then
        walkChannel = audio.play( walkSound, { channel=2} )
        character.x = character.x + 8
    end
end


local function spawn()
  if(spawnPoint == false) then
    character.x = display.contentCenterX - 864
    character.y = display.contentCenterY + 370
  else
    character.x = display.contentCenterX + 576
    character.y = display.contentCenterY + 80
  end
end


-- After loss of life
local function restoreChar()

    character.isBodyActive = false
    spawn()
    transition.to( character, { alpha=1, time=100, onComplete = function()
        character.isBodyActive = true
            died = false
        end
    } )
end


local function triggerCollisionDeath(self, event)
  if(event.other.myName == "character") then
     if(event.phase == "began") then
       if( died == false ) then
         died = true
           if( livesCount > 1 )then
             livesCount = livesCount - 1
             livesText.text = "x " .. livesCount
             character.alpha = 0
             timer.performWithDelay( 100, restoreChar )
           elseif( livesCount == 1 )then
             livesCount = livesCount - 1
             character.alpha = 0
             timer.performWithDelay( 50, gotoDeathScreen )
           end
       end
     end
  end
end


local function triggerCollisionFeather(self, event)
      if(event.selfElement == 1 and event.other.myName == "character") then
        if(event.phase == "began") then
          collectablesChannel =  audio.play( featherSound, { channel=3} )
					featherCount = featherCount + 1
					feathersText.text = "x " .. featherCount
          display.remove(feather)
          -- feather = nil
        end
      end
end


local function triggerCollisionHeart(self, event)
      if(event.selfElement == 1 and event.other.myName == "character") then
        if(event.phase == "began") then
          collectablesChannel =  audio.play( heartSound, { channel=3} )
					livesCount = livesCount + 5
					livesText.text = "x " .. livesCount
          display.remove(heart)
          -- heart = nil
        end
      end
end


local function spawnCollision( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          spawnPoint = true
          flagNo.isVisible = false
          flagYes.isVisible = true
        end
    end
end

local function sensorCollideSpikes( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(sensorSpikes, { time = 200, x = (sensorSpikes.x + 32), iterations=1, transition = easing.continuousLoop  })
        end
    end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view

	physics.pause()

  luaObjects = display.newGroup()
  sceneGroup:insert( luaObjects )

local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1} )
audio.setVolume( 0.03, { channel=1 } )
audio.setVolume( 0.05, { channel=2 } )
audio.setVolume( 0.07, { channel=3 } )


  mapData = require "objects.Screen1" -- load from lua export
  map = tiled.new(mapData, "objects")

  display.setDefault("background", 0.478, 0.478, 0.478)

  sheetOptions =
  {
      width = 108,
      height = 200,
      numFrames = 9
  }

  walkCharacter = graphics.newImageSheet( "9Walkies.png", sheetOptions )

  walking = {
    -- non-consecutive frames sequence
    {
        name = "idle",
        frames={1},
        time = 1000,
        loopCount = 1
    },
    {
        name = "walk",
        start = 1,
        count = 9,
        time = 200,
        loopCount = 0,
        loopDirection = "bounce"
    }
}

  character = display.newSprite (sceneGroup, walkCharacter, walking)
  character.xScale = 79/108
  character.yScale = 107/200
  character.myName = "character"
  character.x = display.contentCenterX - 800
  character.y = display.contentCenterY + 250
  smallRect = {39,-43, 39,54, -25,54, -25,-43}
  physics.addBody( character, "dynamic", { density=1.0, bounce=0.0, friction =0.5, shape = smallRect})
  character.isFixedRotation = true

  spikes1 = map:findObject("spikes1")
  spikes1.collision = triggerCollisionDeath

  spikes2 = map:findObject("spikes2")
  spikes2.collision = triggerCollisionDeath

  spikes3 = map:findObject("spikes3")
  spikes3.collision = triggerCollisionDeath

  spikes4 = map:findObject("spikes4")
  spikes4.collision = triggerCollisionDeath

  spikes5 = map:findObject("spikes5")
  spikes5.collision = triggerCollisionDeath

  timedSpikes = map:findObject("timedSpikes")
  transition.to(timedSpikes, { time = 2000, y = (timedSpikes.y - 64), iterations=0, transition = easing.continuousLoop})
  timedSpikes.collision = triggerCollisionDeath

  sensorSpikes = map:findObject("sensorSpikes")
  sensorSpikes.collision = triggerCollisionDeath

  sensor1 = map:findObject("sensor1")
  physics.addBody(sensor1, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor1.collision = sensorCollideSpikes

  mov1 = map:findObject("mov1")
  transition.to(mov1, { time = 6000, x = (mov1.x - 384), y = (mov1.y - 64), iterations=0, transition = easing.continuousLoop  })

  flagNo = map:findObject("flagNo")
  physics.addBody(flagNo, "static", { box={ halfWidth = 16, halfHeight=48, x=-8, y=0 }, isSensor=true })
  flagNo.collision = spawnCollision

  flagYes = map:findObject("flagYes")

  flagNo.isVisible = true
  flagYes.isVisible = false

  feather = map:findObject("feather")
  physics.addBody(feather, "static", { box={ halfWidth=16, halfHeight=16, x=0, y=0 }, isSensor=true })
  feather.collision = triggerCollisionFeather

  heart = map:findObject("heart")
  physics.addBody(heart, "static", { box={ halfWidth=16, halfHeight=16, x=0, y=0 }, isSensor=true })
  heart.collision = triggerCollisionHeart

  exit = map:findObject("exit")
  exit.myName = "exit"
  exit.collision = gotoLevel2

  lives = display.newImageRect(luaObjects, "heart.png",45,45)
  lives.x = display.contentCenterX-900
  lives.y = display.contentCenterY-500

	livesText = display.newText(luaObjects, "x " .. livesCount, 120, 35, native.systemFont, 40 )
	livesText:setFillColor( 1, 1, 1 )

  feathers = display.newImageRect(luaObjects, "feather.png",45,45)
  feathers.x = display.contentCenterX-900
  feathers.y = display.contentCenterY-440

	feathersText = display.newText(luaObjects, "x " .. featherCount, 120, 100, native.systemFont, 40 )
	feathersText:setFillColor( 1, 1, 1 )

  interactable = map:findLayer("interactable")
  sceneGroup:insert( interactable )

  brickwork = map:findLayer("brickwork")
  sceneGroup:insert( brickwork )

  spikes = map:findLayer("spikes")
  sceneGroup:insert( spikes )

  sensors = map:findLayer("sensors")
  sceneGroup:insert( sensors )

  sensors:toFront()
  spikes:toFront()
  brickwork:toFront()
  interactable:toFront()
  luaObjects:toFront()
  character:toFront()

end



-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		physics.start()
    Runtime:addEventListener( "key", pauseScreen)
    Runtime:addEventListener( "key", key)
    Runtime:addEventListener( "key", jump )
    Runtime:addEventListener( "enterFrame", enterFrame )
    Runtime:addEventListener("key", invis)
    spikes1:addEventListener("collision")
    spikes2:addEventListener("collision")
    spikes3:addEventListener("collision")
    spikes4:addEventListener("collision")
    spikes5:addEventListener("collision")
    feather:addEventListener( "collision")
    heart:addEventListener( "collision" )
    exit:addEventListener( "collision" )
    flagNo:addEventListener( "collision" )
    timedSpikes:addEventListener( "collision" )
    sensor1:addEventListener( "collision" )
    sensorSpikes:addEventListener( "collision" )


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
    Runtime:removeEventListener( "key", pauseScreen)
    Runtime:removeEventListener( "key", key)
    Runtime:removeEventListener( "key", jump )
    Runtime:removeEventListener( "enterFrame", enterFrame )
    Runtime:removeEventListener("key", invis)
    spikes1:removeEventListener("collision")
    spikes2:removeEventListener("collision")
    spikes3:removeEventListener("collision")
    spikes4:removeEventListener("collision")
    spikes5:removeEventListener("collision")
    exit:removeEventListener( "collision" )
    flagNo:removeEventListener( "collision" )
    timedSpikes:removeEventListener( "collision" )
    sensor1:removeEventListener( "collision" )
    sensorSpikes:removeEventListener( "collision" )

		physics.pause()
		composer.removeScene( "Level1" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  -- character:removeSelf()
  -- character = nil

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
