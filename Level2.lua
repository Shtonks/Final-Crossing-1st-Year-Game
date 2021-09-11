
local composer = require( "composer" )

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
local livesCount = composer.getVariable( "livesCount")
local livesText
local feathersText
local featherCount = composer.getVariable( "featherCount")
-- local batteryCount = composer.getVariable( "batteryCount ")
local characterJumping = 0
local turnCount = 0
local keyPressed = 0
local died = false
local paused = false
local backgroundMusic = audio.loadStream( "shrine.wav" )
local walkSound = audio.loadSound( "walk.mp3" )
local featherSound = audio.loadSound( "feather.mp3" )
local heartSound = audio.loadSound( "heart.mp3" )
-- local batterySound = audio.loadSound( "battery.mp3" )
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
local feather
local lives
local spawnPoint = false


local function updateText()
    livesText.text = "x " .. livesCount
end


function scene:resumeGame()
    -- Code to resume game
    audio.resume()
    keyPressed = 0
    physics.start()
end


local function pauseScreen(event)
  if (event.phase == "down" and keyPressed == 0) then
      if (event.keyName == "escape") then
        audio.pause()
        keyPressed = 1
        physics.pause()
        composer.showOverlay( "pause", {isModal=true, effect="slideDown"}  )
      end
  end
end


local function gotoDeathScreen()
    audio.pause()
    composer.setVariable( "livesCount", livesCount )
    composer.setVariable( "featherCount", featherCount )
    composer.gotoScene("gameOver", { time=1000, effect="slideLeft" })
end

local function gotoLevel3(self, event)
    if(event.selfElement == 1 and event.other.myName == "character") then
      if(event.phase == "began") then
        composer.setVariable( "livesCount", livesCount )
        composer.setVariable( "featherCount", featherCount )
        -- composer.setVariable( "batteryCount", batteryCount )
        composer.setVariable( "nextScene", "Level3" )
        composer.gotoScene("loading", { time=20, effect="slideLeft" })
      end
    end
  end

  local function gotoLevel5(self, event)
      if(event.selfElement == 1 and event.other.myName == "character") then
        if(event.phase == "began") then
          physics.pause()
          composer.setVariable( "livesCount", livesCount )
          composer.setVariable( "featherCount", featherCount )
          composer.setVariable( "nextScene", "Level5" )
          composer.gotoScene("loading", { time=20, effect="slideLeft" })
        end
      end
    end

    local function gotoLevel7(self, event)
        if(event.selfElement == 1 and event.other.myName == "character") then
          if(event.phase == "began") then
            composer.setVariable( "livesCount", livesCount )
            composer.setVariable( "featherCount", featherCount )
            -- composer.setVariable( "batteryCount", batteryCount )
            composer.setVariable( "nextScene", "Level7" )
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
    character.y = display.contentCenterY + 336
  else
    character.x = display.contentCenterX - 64
    character.y = display.contentCenterY - 256
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

-- local function batteryCheck()
--   if (batteryCount == 2 ) then
--     display.remove("batteryDoor")
--   end
-- end

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
        end
      end
end


local function sensorCollideSpikes1( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(sensorSpikes1, { time = 200, y = (sensorSpikes1.y + 32), iterations=1, transition = easing.continuousLoop  })
        end
    end
end

local function sensorCollideSpikes2( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(sensorSpikes2, { time = 200, y = (sensorSpikes2.y + 32), iterations=1, transition = easing.continuousLoop  })
        end
    end
end

local function sensorCollideSpikes3( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(sensorSpikes3, { time = 200, x = (sensorSpikes3.x - 32), iterations=1, transition = easing.continuousLoop  })
        end
    end
end

local function sensorCollideSpikes4( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(sensorSpikes4, { time = 200, x = (sensorSpikes4.x - 32), iterations=1, transition = easing.continuousLoop  })
        end
    end
end

local function sensorCollideSpikes5( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(sensorSpikes5, { time = 200, x = (sensorSpikes5.x + 32), iterations=1, transition = easing.continuousLoop  })
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

local function sensorCollideTrigger( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          display.remove(wall1)
        end
    end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()

  luaObjects = display.newGroup()
  sceneGroup:insert( luaObjects )

  local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1} )
  audio.setVolume( 0.03, { channel=1 } )
  audio.setVolume( 0.05, { channel=2 } )
  audio.setVolume( 0.07, { channel=3 } )


  mapData = require "objects.Screen2" -- load from lua export
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

  feather = map:findObject("feather")
  physics.addBody(feather, "static", { box={ halfWidth=16, halfHeight=16, x=0, y=0 }, isSensor=true })

  feather.collision = triggerCollisionFeather

  heart = map:findObject("heart")
  physics.addBody(heart, "static", { box={ halfWidth=16, halfHeight=16, x=0, y=0 }, isSensor=true })

  heart.collision = triggerCollisionHeart




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

  spikes6 = map:findObject("spikes6")
  spikes6.collision = triggerCollisionDeath

  spikes7 = map:findObject("spikes7")
  spikes7.collision = triggerCollisionDeath

  spikes8 = map:findObject("spikes8")
  spikes8.collision = triggerCollisionDeath

  spikes9 = map:findObject("spikes9")
  spikes9.collision = triggerCollisionDeath

  spikes10 = map:findObject("spikes10")
  spikes10.collision = triggerCollisionDeath

  spikes11 = map:findObject("spikes11")
  spikes11.myName = "spikes11"
  spikes11.collision = triggerCollisionDeath


  sensorSpikes1 = map:findObject("sensorSpikes1")
  sensorSpikes1.collision = triggerCollisionDeath

  sensor1 = map:findObject("sensor1")
  physics.addBody(sensor1, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor1.collision = sensorCollideSpikes1

  sensorSpikes2 = map:findObject("sensorSpikes2")
  sensorSpikes2.collision = triggerCollisionDeath

  sensor2 = map:findObject("sensor2")
  physics.addBody(sensor2, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor2.collision = sensorCollideSpikes2

  sensorSpikes3 = map:findObject("sensorSpikes3")
  sensorSpikes3.collision = triggerCollisionDeath

  sensor3 = map:findObject("sensor3")
  physics.addBody(sensor3, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor3.collision = sensorCollideSpikes3

  sensorSpikes4 = map:findObject("sensorSpikes4")
  sensorSpikes4.collision = triggerCollisionDeath

  sensor4 = map:findObject("sensor4")
  physics.addBody(sensor4, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor4.collision = sensorCollideSpikes4

  sensorSpikes5 = map:findObject("sensorSpikes5")
  sensorSpikes5.collision = triggerCollisionDeath

  sensor5 = map:findObject("sensor5")
  physics.addBody(sensor5, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor5.collision = sensorCollideSpikes5


  timedSpikes1 = map:findObject("timedSpikes1")
  transition.to(timedSpikes1, { time = 2000, y = (timedSpikes1.y + 52), iterations=0, transition = easing.continuousLoop, delay = 200  })
  timedSpikes1.collision = triggerCollisionDeath

  timedSpikes2 = map:findObject("timedSpikes2")
  transition.to(timedSpikes2, { time = 2000, y = (timedSpikes2.y + 52), iterations=0, transition = easing.continuousLoop, delay = 400  })
  timedSpikes2.collision = triggerCollisionDeath

  timedSpikes3 = map:findObject("timedSpikes3")
  transition.to(timedSpikes3, { time = 2000, y = (timedSpikes3.y + 52), iterations=0, transition = easing.continuousLoop })
  timedSpikes3.collision = triggerCollisionDeath

  timedSpikes4 = map:findObject("timedSpikes4")
  transition.to(timedSpikes4, { time = 2000, y = (timedSpikes4.y + 52), iterations=0, transition = easing.continuousLoop, delay = 700  })
  timedSpikes4.collision = triggerCollisionDeath

  timedSpikes5 = map:findObject("timedSpikes5")
  transition.to(timedSpikes5, { time = 2000, y = (timedSpikes5.y + 52), iterations=0, transition = easing.continuousLoop, delay = 1600  })
  timedSpikes5.collision = triggerCollisionDeath


  timedSpikes6 = map:findObject("timedSpikes6")
  transition.to(timedSpikes6, { time = 2000, y = (timedSpikes6.y - 64), iterations=0, transition = easing.continuousLoop, delay = 200  })
  timedSpikes6.collision = triggerCollisionDeath

  timedSpikes7 = map:findObject("timedSpikes7")
  transition.to(timedSpikes7, { time = 1800, y = (timedSpikes7.y - 64), iterations=0, transition = easing.continuousLoop, delay = 200  })
  timedSpikes7.collision = triggerCollisionDeath


  saw = map:findObject("saw")
  transition.to(saw, {rotation = 360, iterations = -1})
  saw.collision = triggerCollisionDeath

  bullet1 = map:findObject("bullet1")
  transition.to(bullet1, { time = 2200, y = (bullet1.y + 532), iterations=0, transition = easing.linear  })
  bullet1.collision = triggerCollisionDeath


  flagNo = map:findObject("flagNo")
  physics.addBody(flagNo, "static", { box={ halfWidth = 16, halfHeight=48, x=-8, y=0 }, isSensor=true })
  flagNo.collision = spawnCollision

  flagYes = map:findObject("flagYes")

  flagNo.isVisible = true
  flagYes.isVisible = false


  trigger = map:findObject("trigger")
  physics.addBody(trigger, "static", { box={ halfWidth=8, halfHeight=8, x=0, y=0 }, isSensor=true })
  wall1 = map:findObject("wall1")

  trigger.collision = sensorCollideTrigger



  exit1 = map:findObject("exit1")
  physics.addBody(exit1, "static", { box={ halfWidth=32, halfHeight=43, x=0, y=0 }, isSensor=true })
  exit1.collision = gotoLevel3

  exit2 = map:findObject("exit2")
  physics.addBody(exit2, "static", { box={ halfWidth=32, halfHeight=43, x=0, y=0 }, isSensor=true })
  exit2.collision = gotoLevel5

  exit3 = map:findObject("exit3")
  physics.addBody(exit3, "static", { box={ halfWidth=32, halfHeight=43, x=0, y=0 }, isSensor=true })
  exit3.collision = gotoLevel7

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
    spikes6:addEventListener("collision")
    spikes7:addEventListener("collision")
    spikes8:addEventListener("collision")
    spikes9:addEventListener("collision")
    spikes10:addEventListener("collision")
    spikes11:addEventListener("collision")
    saw:addEventListener("collision")
    sensor1:addEventListener( "collision" )
    sensorSpikes1:addEventListener( "collision" )
    sensor2:addEventListener( "collision" )
    sensorSpikes2:addEventListener( "collision" )
    sensor3:addEventListener( "collision" )
    sensorSpikes3:addEventListener( "collision" )
    sensor4:addEventListener( "collision" )
    sensorSpikes4:addEventListener( "collision" )
    sensor5:addEventListener( "collision" )
    sensorSpikes5:addEventListener( "collision" )
    timedSpikes1:addEventListener( "collision" )
    timedSpikes2:addEventListener( "collision" )
    timedSpikes3:addEventListener( "collision" )
    timedSpikes4:addEventListener( "collision" )
    timedSpikes5:addEventListener( "collision" )
    timedSpikes6:addEventListener( "collision" )
    timedSpikes7:addEventListener( "collision" )
    trigger:addEventListener( "collision" )
    bullet1:addEventListener( "collision" )
    heart:addEventListener( "collision" )
    feather:addEventListener( "collision" )
    flagNo:addEventListener( "collision" )
    exit1:addEventListener( "collision" )
    exit2:addEventListener( "collision" )
    exit3:addEventListener( "collision" )


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
    -- character.angularVelocity = 0
    Runtime:removeEventListener( "key", pauseScreen)
    Runtime:removeEventListener( "key", key)
    Runtime:removeEventListener( "key", jump )
    Runtime:removeEventListener( "enterFrame", enterFrame )
    Runtime:removeEventListener("key", invis)
    -- spikes1:removeEventListener("collision")
    -- spikes2:removeEventListener("collision")
    -- spikes3:removeEventListener("collision")
    -- spikes4:removeEventListener("collision")
    -- spikes5:removeEventListener("collision")
    -- spikes6:removeEventListener("collision")
    -- spikes7:removeEventListener("collision")
    -- spikes8:removeEventListener("collision")
    -- spikes9:removeEventListener("collision")
    -- spikes10:removeEventListener("collision")
    -- spikes11:removeEventListener("collision")
    -- saw:removeEventListener("collision")
    -- sensor1:removeEventListener( "collision" )
    -- sensorSpikes1:removeEventListener( "collision" )
    -- sensor2:removeEventListener( "collision" )
    -- sensorSpikes2:removeEventListener( "collision" )
    -- sensor3:removeEventListener( "collision" )
    -- sensorSpikes3:removeEventListener( "collision" )
    -- sensor4:removeEventListener( "collision" )
    -- sensorSpikes4:removeEventListener( "collision" )
    -- sensor5:removeEventListener( "collision" )
    -- sensorSpikes5:removeEventListener( "collision" )
    -- timedSpikes1:removeEventListener( "collision" )
    -- timedSpikes2:removeEventListener( "collision" )
    -- timedSpikes3:removeEventListener( "collision" )
    -- timedSpikes4:removeEventListener( "collision" )
    -- timedSpikes5:removeEventListener( "collision" )
    -- timedSpikes6:removeEventListener( "collision" )
    -- timedSpikes7:removeEventListener( "collision" )
    -- flagNo:removeEventListener( "collision" )
    -- exit1:removeEventListener( "collision" )
    -- exit2:removeEventListener( "collision" )
    -- exit3:removeEventListener( "collision" )


    physics.pause()
		composer.removeScene( "Level2" )
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
