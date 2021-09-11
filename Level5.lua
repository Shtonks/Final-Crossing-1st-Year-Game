
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
local characterJumping = 0
local turnCount = 0
local batteryCount = composer.getVariable( "batteryCount ")
local keyPressed = 0
local died = false
local paused = false
local backgroundMusic = audio.loadStream( "shrine.wav" )
local walkSound = audio.loadSound( "walk.mp3" )
local featherSound = audio.loadSound( "feather.mp3" )
local heartSound = audio.loadSound( "heart.mp3" )
local batterySound = audio.loadSound( "battery.mp3" )
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

-- local function gotoLevel2(self, event)
--     if(event.other.myName == "character") then
--       if(event.phase == "began") then
--         composer.setVariable( "livesCount", livesCount )
--         composer.setVariable( "featherCount", featherCount )
--         composer.setVariable( "batteryCount", batteryCount )
--         composer.setVariable( "nextScene", "Level2" )
--         composer.gotoScene("loading", { time=20, effect="slideLeft" })
--       end
--     end
--   end

  local function gotoSurface(self, event)
      if(event.selfElement == 1 and event.other.myName == "character") then
        if(event.phase == "began") then
          composer.setVariable( "livesCount", livesCount )
          composer.setVariable( "featherCount", featherCount )
          composer.setVariable( "nextScene", "Level8" )
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
    character.y = display.contentCenterY - 432
  else
    character.x = display.contentCenterX + 32
    character.y = display.contentCenterY - 400
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
          display.remove(wall1)
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

local function sensorCollideTrigger( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          display.remove(wall2)
          display.remove(wall3)
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


  mapData = require "objects.Screen5" -- load from lua export
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

  character = display.newSprite (luaObjects, walkCharacter, walking)
  character.xScale = 79/108
  character.yScale = 107/200
  character.myName = "character"
  spawn()
  smallRect = {39,-43, 39,54, -25,54, -25,-43}
  physics.addBody( character, "dynamic", { density=1.0, bounce=0.0, friction =0.5, shape = smallRect})
  character.isFixedRotation = true

  feather = map:findObject("feather")
  physics.addBody(feather, "static", { box={ halfWidth=16, halfHeight=16, x=0, y=0 }, isSensor=true })
  wall1 = map:findObject("wall1")

  feather.collision = triggerCollisionFeather

  heart = map:findObject("heart")
  physics.addBody(heart, "static", { box={ halfWidth=16, halfHeight=16, x=0, y=0 }, isSensor=true })

  heart.collision = triggerCollisionHeart


  blades = map:listTypes("blades")

  for count = 1, 8, 1 do
    transition.to(blades[count], {rotation = 360, iterations = -1})
  end

  saw0 = map:findObject("saw0")
  saw0.collision = triggerCollisionDeath

  saw1 = map:findObject("saw1")
  saw1.collision = triggerCollisionDeath

  saw2 = map:findObject("saw2")
  saw2.collision = triggerCollisionDeath

  saw3 = map:findObject("saw3")
  transition.to(saw3, { time = 3500, y = (saw3.y - 256), iterations=0, transition = easing.continuousLoop  })
  saw3.collision = triggerCollisionDeath

  saw4 = map:findObject("saw4")
  saw4.collision = triggerCollisionDeath

  saw5 = map:findObject("saw5")
  saw5.collision = triggerCollisionDeath

  saw6 = map:findObject("saw6")
  saw6.collision = triggerCollisionDeath

  saw7 = map:findObject("saw7")
  transition.to(saw7, { time = 4000, x = (saw7.x + 128), y = (saw7.y - 160), iterations=0, transition = easing.continuousLoop  })
  saw7.collision = triggerCollisionDeath


  mov1 = map:findObject("mov1")
  transition.to(mov1, { time = 6000, y = (mov1.y - 352), iterations=0, transition = easing.continuousLoop  })

  mov2 = map:findObject("mov2")
  transition.to(mov2, { time = 4000, y = (mov2.y + 224), iterations=0, transition = easing.continuousLoop  })

  mov3 = map:findObject("mov3")
  transition.to(mov3, { time = 4000, y = (mov3.y + 352), iterations=0, transition = easing.continuousLoop  })

  mov4 = map:findObject("mov4")
  transition.to(mov4, { time = 3000, y = (mov4.y - 192), iterations=0, transition = easing.continuousLoop  })

  mov5 = map:findObject("mov5")
  transition.to(mov5, { time = 7000, x = (mov5.x + 416), iterations=0, transition = easing.continuousLoop  })

  mov6 = map:findObject("mov6")
  transition.to(mov6, { time = 4000, x = (mov6.x - 288), y = (mov6.y - 128), iterations=0, transition = easing.continuousLoop  })

--feather area

  bullet1 = map:findObject("bullet1")
  transition.to(bullet1, { time = 1800, x = (bullet1.x + 920), iterations=0, transition = easing.linear  })
  bullet1.collision = triggerCollisionDeath

  bullet2 = map:findObject("bullet2")
  transition.to(bullet2, { time = 1800, x = (bullet2.x + 920), iterations=0, transition = easing.linear, delay = 200  })
  bullet2.collision = triggerCollisionDeath

  timedSpikes1 = map:findObject("timedSpikes1")
  transition.to(timedSpikes1, { time = 1800, y = (timedSpikes1.y + 64), iterations=0, transition = easing.continuousLoop, delay = 200  })
  timedSpikes1.collision = triggerCollisionDeath


  bullet3 = map:findObject("bullet3")
  transition.to(bullet3, { time = 2400, x = (bullet3.x + 1216), iterations=0, transition = easing.linear})
  bullet3.collision = triggerCollisionDeath


  bullet4 = map:findObject("bullet4")
  transition.to(bullet4, { time = 1800, x = (bullet4.x + 832), iterations=0, transition = easing.linear, delay = 1500  })
  bullet4.collision = triggerCollisionDeath

  bullet5 = map:findObject("bullet5")
  transition.to(bullet5, { time = 1800, y = (bullet5.y - 352), iterations=0, transition = easing.linear})
  bullet5.collision = triggerCollisionDeath


  timedSpikes2 = map:findObject("timedSpikes2")
  transition.to(timedSpikes2, { time = 1500, y = (timedSpikes2.y - 64), iterations=0, transition = easing.continuousLoop  })
  timedSpikes2.collision = triggerCollisionDeath

  sensorSpikes = map:findObject("sensorSpikes")
  sensorSpikes.collision = triggerCollisionDeath

  sensor1 = map:findObject("sensor1")
  physics.addBody(sensor1, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor1.collision = sensorCollideSpikes

  trigger = map:findObject("trigger")
  physics.addBody(trigger, "static", { box={ halfWidth=16, halfHeight=16, x=0, y=0 }, isSensor=true })

  trigger.collision = sensorCollideTrigger

  wall2 = map:findObject("wall2")
  wall3 = map:findObject("wall3")

  -- exit = map:findObject("exit")
  -- exit.collision = gotoLevel2


  exitSurface = map:findObject("exitSurface")
  physics.addBody(exitSurface, "static", { box={ halfWidth=32, halfHeight=64, x=0, y=0 }, isSensor=true })
  exitSurface.collision = gotoSurface



  staticSpikes1 = map:findObject("staticSpikes1")
  staticSpikes1.collision = triggerCollisionDeath

  staticSpikes2 = map:findObject("staticSpikes2")
  staticSpikes2.collision = triggerCollisionDeath

  staticSpikes3 = map:findObject("staticSpikes3")
  staticSpikes3.collision = triggerCollisionDeath

  staticSpikes4 = map:findObject("staticSpikes4")
  staticSpikes4.collision = triggerCollisionDeath

  staticSpikes5 = map:findObject("staticSpikes5")
  staticSpikes5.collision = triggerCollisionDeath

  staticSpikes6 = map:findObject("staticSpikes6")
  staticSpikes6.collision = triggerCollisionDeath

  staticSpikes7 = map:findObject("staticSpikes7")
  staticSpikes7.collision = triggerCollisionDeath

  staticSpikes8 = map:findObject("staticSpikes8")
  staticSpikes8.collision = triggerCollisionDeath


  flagNo = map:findObject("flagNo")
  physics.addBody(flagNo, "static", { box={ halfWidth = 16, halfHeight=48, x=-8, y=0 }, isSensor=true })
  flagNo.collision = spawnCollision

  flagYes = map:findObject("flagYes")

  flagNo.isVisible = true
  flagYes.isVisible = false

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

    turrets = map:findLayer("turrets")
    sceneGroup:insert( turrets )

    bullets = map:findLayer("bullets")
    sceneGroup:insert( bullets )

    blades = map:findLayer("blades")
    sceneGroup:insert( blades )

    movingPlatforms = map:findLayer("movingPlatforms")
    sceneGroup:insert( movingPlatforms )

    rails = map:findLayer("rails")
    sceneGroup:insert( rails )

    brickwork = map:findLayer("brickwork")
    sceneGroup:insert( brickwork )

    decals = map:findLayer("decals")
    sceneGroup:insert( decals )

    spikes = map:findLayer("spikes")
    sceneGroup:insert( spikes )

    sensors = map:findLayer("sensors")
sceneGroup:insert( sensors )

sensors:toFront()

    decals:toFront()
    spikes:toFront()
    brickwork:toFront()
    rails:toFront()
    movingPlatforms:toFront()
    blades:toFront()
    bullets:toFront()
    turrets:toFront()
    interactable:toFront()
    luaObjects:toFront()


end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		physics.start()
    Runtime:addEventListener( "key", pauseScreen)
    Runtime:addEventListener( "key", key)
    Runtime:addEventListener( "key", jump )
    Runtime:addEventListener( "enterFrame", enterFrame )
    Runtime:addEventListener("key", invis)
    feather:addEventListener( "collision" )
    heart:addEventListener( "collision" )
    saw0:addEventListener( "collision" )
    saw1:addEventListener( "collision" )
    saw2:addEventListener( "collision" )
    saw3:addEventListener( "collision" )
    saw4:addEventListener( "collision" )
    saw5:addEventListener( "collision" )
    saw6:addEventListener( "collision" )
    saw7:addEventListener( "collision" )
    bullet1:addEventListener( "collision" )
    bullet2:addEventListener( "collision" )
    timedSpikes1:addEventListener( "collision" )
    flagNo:addEventListener( "collision" )
    bullet3:addEventListener( "collision" )
    -- bullet3half:addEventListener( "collision" )
    staticSpikes1:addEventListener( "collision" )
    staticSpikes2:addEventListener( "collision" )
    staticSpikes3:addEventListener( "collision" )
    staticSpikes4:addEventListener( "collision" )
    staticSpikes5:addEventListener( "collision" )
    staticSpikes6:addEventListener( "collision" )
    staticSpikes7:addEventListener( "collision" )
    staticSpikes8:addEventListener( "collision" )
    sensor1:addEventListener( "collision" )
    sensorSpikes:addEventListener( "collision" )
    trigger:addEventListener( "collision" )
    bullet4:addEventListener( "collision" )
    bullet5:addEventListener( "collision" )
    exitSurface:addEventListener( "collision" )



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
    -- feather:removeEventListener( "collision" )
    -- heart:removeEventListener( "collision" )
    -- saw0:removeEventListener( "collision" )
    -- saw1:removeEventListener( "collision" )
    -- saw2:removeEventListener( "collision" )
    -- saw3:removeEventListener( "collision" )
    -- saw4:removeEventListener( "collision" )
    -- saw5:removeEventListener( "collision" )
    -- saw6:removeEventListener( "collision" )
    -- saw7:removeEventListener( "collision" )
    -- bullet1:removeEventListener( "collision" )
    -- bullet2:removeEventListener( "collision" )
    -- timedSpikes1:removeEventListener( "collision" )
    -- flagNo:removeEventListener( "collision" )
    -- bullet3:removeEventListener( "collision" )
    -- bullet3half:removeEventListener( "collision" )
    -- staticSpikes1:removeEventListener( "collision" )
    -- staticSpikes2:removeEventListener( "collision" )
    -- staticSpikes3:removeEventListener( "collision" )
    -- staticSpikes4:removeEventListener( "collision" )
    -- staticSpikes5:removeEventListener( "collision" )
    -- staticSpikes6:removeEventListener( "collision" )
    -- staticSpikes7:removeEventListener( "collision" )
    -- staticSpikes8:removeEventListener( "collision" )
    -- sensor1:removeEventListener( "collision" )
    -- sensorSpikes:removeEventListener( "collision" )
    -- trigger:removeEventListener( "collision" )
    -- bullet4:removeEventListener( "collision" )
    -- bullet5:removeEventListener( "collision" )


		physics.pause()
		composer.removeScene( "Level5" )
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
