
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
-- local batteryCount = composer.getVariable( "batteryCount ")
local keyPressed = 0
local turnCount = 0
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
    -- composer.setVariable( "batteryCount", batteryCount )
    composer.gotoScene("gameOver", { time=1000, effect="slideLeft" })
end

local function gotoLevel2(self, event)
    if(event.selfElement == 1 and event.other.myName == "character") then
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
    character.x = display.contentCenterX + 750
    character.y = display.contentCenterY - 370
  else
    character.x = display.contentCenterX - 50
    character.y = display.contentCenterY
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
            display.remove(wall2)
          end
        end
  end

  -- local function triggerCollisionBattery(self, event)
  --       if(event.selfElement == 1 and event.other.myName == "character") then
  --         if(event.phase == "began") then
  --           collectablesChannel =  audio.play( batterySound, { channel=3} )
  --           batteryCount = batteryCount + 1
  --           display.remove(battery)
  --         end
  --       end
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

local function sensorCollideSpikes1( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(spikes1, { time = 200, x = (spikes1.x + 32), iterations=1, transition = easing.continuousLoop  })
        end
    end
end

local function sensorCollideSpikes2( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(spikes2, { time = 200, x = (spikes2.x + 32), iterations=1, transition = easing.continuousLoop  })
        end
    end
end

local function sensorCollideSpikes3( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(spikes3, { time = 200, x = (spikes3.x + 32), iterations=1, transition = easing.continuousLoop  })
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


  mapData = require "objects.Screen7" -- load from lua export
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
  wall2 = map:findObject("wall2")

  heart.collision = triggerCollisionHeart

  -- battery = map:findObject("battery")
  -- physics.addBody(battery, "static", { box={ halfWidth=16, halfHeight=16, x=0, y=0 }, isSensor=true })
  --
  -- battery.collision = triggerCollisionBattery


  blades = map:listTypes("blades")

  for count = 1, 15, 1 do
    transition.to(blades[count], {rotation = 360, iterations = -1})
  end

    saw0 = map:findObject("saw0")
    transition.to(saw0, { time = 2200, y = (saw0.y + 160), iterations=0, transition = easing.continuousLoop  })
    saw0.collision = triggerCollisionDeath

    saw1 = map:findObject("saw1")
    transition.to(saw1, { time = 4000, x = (saw1.x - 448), iterations=0, transition = easing.continuousLoop  })
    saw1.collision = triggerCollisionDeath

    saw2 = map:findObject("saw2")
    transition.to(saw2, { time = 2300, y = (saw2.y + 316), iterations=0, transition = easing.continuousLoop  })
    saw2.collision = triggerCollisionDeath

    saw3 = map:findObject("saw3")
    transition.to(saw3, { time = 3500, y = (saw3.y + 576), iterations=0, transition = easing.continuousLoop  })
    saw3.collision = triggerCollisionDeath

    saw4 = map:findObject("saw4")
    transition.to(saw4, { time = 6000, x = (saw4.x - 448), iterations=0, transition = easing.continuousLoop  })
    saw4.collision = triggerCollisionDeath

    saw5 = map:findObject("saw5")
    transition.to(saw5, { time = 2500, y = (saw5.y - 480), iterations=0, transition = easing.continuousLoop  })
    saw5.collision = triggerCollisionDeath

    saw6 = map:findObject("saw6")
    transition.to(saw6, { time = 2500, y = (saw6.y + 192), iterations=0, transition = easing.continuousLoop  })
    saw6.collision = triggerCollisionDeath

    saw8 = map:findObject("saw8")
    saw8.myName = "saw8"
    transition.to(saw8, { time = 4000, x = (saw8.x - 352), y = (saw8.y + 352), iterations=0, transition = easing.continuousLoop  })
    saw8.collision = triggerCollisionDeath

    saw9 = map:findObject("saw9")
    transition.to(saw9, { time = 2800, y = (saw9.y + 416), iterations=0, transition = easing.continuousLoop  })
    saw9.collision = triggerCollisionDeath

    saw10 = map:findObject("saw10")
    saw10.collision = triggerCollisionDeath

    saw11 = map:findObject("saw11")
    saw11.collision = triggerCollisionDeath


    timedSpikes = map:findObject("timedSpikes")
    transition.to(timedSpikes, { time = 600, x = (timedSpikes.x - 32), iterations=0, transition = easing.continuousLoop  })
    timedSpikes.collision = triggerCollisionDeath

    spikes1 = map:findObject("spikes1")

    spikes1.collision = triggerCollisionDeath

    sensor1 = map:findObject("sensor1")
    physics.addBody(sensor1, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

    sensor1.collision = sensorCollideSpikes1

    spikes2 = map:findObject("spikes2")

    spikes2.collision = triggerCollisionDeath

    sensor2 = map:findObject("sensor2")
    physics.addBody(sensor2, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

    sensor2.collision = sensorCollideSpikes2

    spikes3 = map:findObject("spikes3")

    spikes3.collision = triggerCollisionDeath

    sensor3 = map:findObject("sensor3")
    physics.addBody(sensor3, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

    sensor3.collision = sensorCollideSpikes3

    staticSpikes1 = map:findObject("staticSpikes1")
    staticSpikes1.collision = triggerCollisionDeath

    staticSpikes2 = map:findObject("staticSpikes2")
    staticSpikes2.collision = triggerCollisionDeath

    exit = map:findObject("exit")
    physics.addBody(exit, "static", { box={ halfWidth=32, halfHeight=43, x=0, y=0 }, isSensor=true })
    exit.collision = gotoLevel2

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

    blades = map:findLayer("blades")
    sceneGroup:insert( blades )

    rails = map:findLayer("rails")
    sceneGroup:insert( rails )

brickwork = map:findLayer("brickwork")
sceneGroup:insert( brickwork )

spikes = map:findLayer("spikes")
sceneGroup:insert( spikes )

sensors = map:findLayer("sensors")
sceneGroup:insert( sensors )

sensors:toFront()
spikes:toFront()
brickwork:toFront()
rails:toFront()
blades:toFront()
interactable:toFront()
luaObjects:toFront()

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		physics.start()
    Runtime:addEventListener( "key", key)
    Runtime:addEventListener( "key", jump )
    Runtime:addEventListener( "enterFrame", enterFrame )
    Runtime:addEventListener("key", invis)
    feather:addEventListener( "collision" )
    heart:addEventListener( "collision" )
    -- battery:addEventListener( "collision" )
    saw0:addEventListener( "collision" )
    saw10:addEventListener( "collision" )
    saw11:addEventListener( "collision" )
    saw1:addEventListener( "collision" )
    saw2:addEventListener( "collision" )
    saw3:addEventListener( "collision" )
    saw4:addEventListener( "collision" )
    saw5:addEventListener( "collision" )
    saw6:addEventListener( "collision" )
    -- saw7:addEventListener( "collision" )
    saw8:addEventListener( "collision" )
    saw9:addEventListener( "collision" )
    sensor1:addEventListener( "collision" )
    spikes1:addEventListener( "collision" )
    sensor2:addEventListener( "collision" )
    spikes2:addEventListener( "collision" )
    sensor3:addEventListener( "collision" )
    spikes3:addEventListener( "collision" )
    staticSpikes1:addEventListener( "collision" )
    staticSpikes2:addEventListener( "collision" )
    flagNo:addEventListener( "collision" )
    exit:addEventListener( "collision" )



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
		--character:removeEventListener( "collision" )
    Runtime:removeEventListener( "key", key)
    Runtime:removeEventListener( "key", jump )
    Runtime:removeEventListener( "enterFrame", enterFrame )
    Runtime:removeEventListener("key", invis)
    -- feather:removeEventListener( "collision" )
    -- heart:removeEventListener( "collision" )
    -- battery:removeEventListener( "collision" )
    -- saw0:removeEventListener( "collision" )
    -- saw10:removeEventListener( "collision" )
    -- saw11:removeEventListener( "collision" )
    -- saw1:removeEventListener( "collision" )
    -- saw2:removeEventListener( "collision" )
    -- saw3:removeEventListener( "collision" )
    -- saw4:removeEventListener( "collision" )
    -- saw5:removeEventListener( "collision" )
    -- saw6:removeEventListener( "collision" )
    -- -- saw7:removeEventListener( "collision" )
    -- saw8:removeEventListener( "collision" )
    -- saw9:removeEventListener( "collision" )
    -- sensor1:removeEventListener( "collision" )
    -- spikes1:removeEventListener( "collision" )
    -- sensor2:removeEventListener( "collision" )
    -- spikes2:removeEventListener( "collision" )
    -- sensor3:removeEventListener( "collision" )
    -- spikes3:removeEventListener( "collision" )
    -- staticSpikes1:removeEventListener( "collision" )
    -- staticSpikes2:removeEventListener( "collision" )
    -- flagNo:removeEventListener("collision")
    -- exit:removeEventListener( "collision" )

		physics.pause()
		composer.removeScene( "Level7" )
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
