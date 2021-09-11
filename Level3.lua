
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
 local backGroup
 local bulletGroup
local livesCount = composer.getVariable( "livesCount")
local livesText
local feathersText
local featherCount = composer.getVariable( "featherCount")
-- local batteryCount = composer.getVariable( "batteryCount")
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
local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1} )
audio.setVolume( 0.03, { channel=1 } )
audio.setVolume( 0.05, { channel=2 } )
audio.setVolume( 0.07, { channel=3 } )

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
    paused = false
    laser1.isVisible = true
    laser2.isVisible = true
    laser3.isVisible = true
    laser5.isVisible = true
    laser6.isVisible = true
    laser7.isVisible = true
    laser8.isVisible = true
    laser9.isVisible = true
    laser10.isVisible = true
    laser11.isVisible = true
    laser12.isVisible = true
    laser13.isVisible = true
    laser14.isVisible = true
    laser15.isVisible = true
    timer.resume(turretShoot1)
    timer.resume(turretShoot2)
    timer.resume(turretShoot3)
    audio.resume()
    keyPressed = 0
    physics.start()
end


local function pauseScreen(event)
  if (event.phase == "down" and keyPressed == 0) then
      if (event.keyName == "escape") then
        paused = true
        laser1.isVisible = false
        laser2.isVisible = false
        laser3.isVisible = false
        laser5.isVisible = false
        laser6.isVisible = false
        laser7.isVisible = false
        laser8.isVisible = false
        laser9.isVisible = false
        laser10.isVisible = false
        laser11.isVisible = false
        laser12.isVisible = false
        laser13.isVisible = false
        laser14.isVisible = false
        laser15.isVisible = false
        timer.pause(turretShoot1)
        timer.pause(turretShoot2)
        timer.pause(turretShoot3)
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
    composer.gotoScene("gameOver", { time=500, effect="slideLeft" })
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
    character.x = display.contentCenterX - 784
    character.y = display.contentCenterY + 336
  else
    character.x = display.contentCenterX + 16
    character.y = display.contentCenterY -  432
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

local function fireTurret1()

      laser1 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser1 )
      physics.addBody( laser1, "static")
      laser1.gravityScale = 0
      laser1.isBullet = applyTorque

      laser4 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser4 )
      physics.addBody( laser4,  "static")
      laser4.gravityScale = 0
      laser4.isBullet = applyTorque

      laser6 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser6 )
      physics.addBody( laser6,  "static")
      laser6.gravityScale = 0
      laser6.isBullet = applyTorque

      laser12 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser12 )
      physics.addBody( laser12, "static")
      laser12.gravityScale = 0
      laser12.isBullet = applyTorque

      laser9 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser9 )
      physics.addBody( laser9,  "static")
      laser9.gravityScale = 0
      laser9.isBullet = applyTorque

      laser1.x = turret1.x
      laser1.y = turret1.y
      laser4.x = turret4.x
      laser4.y = turret4.y
      laser6.x = turret6.x
      laser6.y = turret6.y
      laser12.x = turret12.x
      laser12.y = turret12.y
      laser9.x = turret9.x
      laser9.y = turret9.y

      transition.to( laser1, { y=700, time=500, onComplete = function() display.remove( laser1 ) end} )
      transition.to( laser4,  { x=585, time=450, onComplete = function() display.remove( laser4 ) end} )
      transition.to( laser6,  { y=670, time=800, onComplete = function() display.remove( laser6 ) end} )
      transition.to( laser12,  { x=950, time=800, onComplete = function() display.remove( laser12 ) end} )
      transition.to( laser9,  { x=1750, time=1000, onComplete = function() display.remove( laser9 ) end} )

      laser1.myName = "laser"
      laser4.myName = "laser"
      laser6.myName = "laser"
      laser12.myName = "laser"
      laser9.myName = "laser"

end

local function fireTurret2()

      laser3 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser3 )
      physics.addBody( laser3,  "static")
      laser3.gravityScale = 0
      laser3.isBullet = applyTorque

      laser10 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser10 )
      physics.addBody( laser10,  "static")
      laser10.gravityScale = 0
      laser10.isBullet = applyTorque

      laser13 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser13 )
      physics.addBody( laser13,  "static")
      laser13.gravityScale = 0
      laser13.isBullet = applyTorque

      laser3.x = turret3.x
      laser3.y = turret3.y
      laser10.x = turret10.x
      laser10.y = turret10.y
      laser13.x = turret13.x
      laser13.y = turret13.y

      transition.to( laser3, { y=1000, time=600, onComplete = function() display.remove( laser3 ) end} )
      transition.to( laser10,  { y=1000, time=350, onComplete = function() display.remove( laser10 ) end} )
      transition.to( laser13,  { x=950, time=900, onComplete = function() display.remove( laser13 ) end} )

      laser3.myName = "laser"
      laser10.myName = "laser"
      laser13.myName = "laser"

end

local function fireTurret3()

      laser2 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser2 )
      physics.addBody( laser2,  "static")
      laser2.gravityScale = 0
      laser2.isBullet = applyTorque


      laser7 = display.newImageRect("laser.png", 10, 20 )
      bulletGroup:insert( laser7 )
      physics.addBody( laser7,  "static")
      laser7.gravityScale = 0
      laser7.isBullet = applyTorque

      laser11 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser11 )
      physics.addBody( laser11,  "static")
      laser11.gravityScale = 0
      laser11.isBullet = applyTorque

      laser14 = display.newImageRect("laser.png", 20, 10 )
      bulletGroup:insert( laser14 )
      physics.addBody( laser14, "static")
      laser14.gravityScale = 0
      laser14.isBullet = applyTorque


      laser2.x = turret2.x
      laser2.y = turret2.y
      laser7.x = turret7.x
      laser7.y = turret7.y
      laser11.x = turret11.x
      laser11.y = turret11.y
      laser14.x = turret14.x
      laser14.y = turret14.y

      transition.to( laser2, { y=20, time=1000, onComplete = function() display.remove( laser2 ) end} )
      transition.to( laser7,  { y=200, time=650, onComplete = function() display.remove( laser7 ) end} )
      transition.to( laser11,  { x=1000, time=1400, onComplete = function() display.remove( laser11 ) end} )
      transition.to( laser14,  { x=1700, time=700, onComplete = function() display.remove( laser14 ) end} )

      laser2.myName = "laser"
      laser7.myName = "laser"
      laser11.myName = "laser"
      laser14.myName = "laser"

end

local function laserCollision( event )
     if( event.phase == "began" ) then

       local obj1 = event.object1
       local obj2 = event.object2

         if ( obj1.myName == "character" and obj2.myName == "laser") then
                 died = true

                 if( livesCount > 1 )then
                   livesCount = livesCount - 1
                   livesText.text = "x " .. livesCount
                   character.alpha = 0
                   timer.performWithDelay( 100, restoreChar )
                 elseif( livesCount == 1 )then
                   livesCount = livesCount - 1
                   character.alpha = 0
                   timer.performWithDelay( 2000, gotoDeathScreen )
                 end
           elseif( obj1.myName == "laser" and obj2.myName == "character" ) then
               died = true

               if( livesCount > 1 )then
                 livesCount = livesCount - 1
                 livesText.text = "x " .. livesCount
                 character.alpha = 0
                 timer.performWithDelay( 100, restoreChar )
               elseif( livesCount == 1 )then
                 livesCount = livesCount - 1
                 character.alpha = 0
                 timer.performWithDelay( 2000, gotoDeathScreen )
               end
            end
         end
      end

  local function groundCollisionLaser(event)
    if( event.phase == "began" ) then

      local obj1 = event.object1
      local obj2 = event.object2

        if ( obj1.myName == "ground" and obj2.myName == "laser") then
                event.object2:removeSelf()
          elseif( obj1.myName == "laser" and obj2.myName == "ground" ) then
              event.object1:removeSelf()
           end
        end
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
      if(event.other.myName == "feather" or event.other.myName == "character") then
        if(event.phase == "began") then
          collectablesChannel =  audio.play( featherSound, { channel=3} )
					featherCount = featherCount + 1
					feathersText.text = "x " .. featherCount
          display.remove(feather)
        end
      end
end


local function triggerCollisionHeart(self, event)
      if(event.other.myName == "heart" or event.other.myName == "character") then
        if(event.phase == "began") then
          collectablesChannel =  audio.play( heartSound, { channel=3} )
					livesCount = livesCount + 5
					livesText.text = "x " .. livesCount
          display.remove(heart)
        end
      end
end

--   ----- battery collision----
-- local function triggerCollisionaddd(self, event)
--         if(event.other.myName == "battery" or event.other.myName == "character") then
--           if( event.phase == "began" ) then
--               collectablesChannel =  audio.play( batterySound, { channel=3} )
--               batteryCount = batteryCount + 1
--               display.remove(battery)
--           end
--         end
-- end


local function sensorCollideSpikes1( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(sensorSpikes1, { time = 200, y = (sensorSpikes1.y + 40), iterations=1, transition = easing.continuousLoop  })
          transition.to(sensorSpikes2, { time = 200, y = (sensorSpikes2.y + 40), iterations=1, transition = easing.continuousLoop  })
          transition.to(sensorSpikes3, { time = 200, y = (sensorSpikes3.y + 40), iterations=1, transition = easing.continuousLoop  })
          transition.to(sensorSpikes4, { time = 200, y = (sensorSpikes4.y + 40), iterations=1, transition = easing.continuousLoop  })
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

local function sensorCollideSpikes5( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          transition.to(sensorSpikes5, { time = 200, x = (sensorSpikes5.x - 32), iterations=1, transition = easing.continuousLoop  })
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

  bulletGroup = display.newGroup()


  mapData = require "objects.Screen3" -- load from lua export
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
  spikes1.myName = "spikes1"
  spikes1.collision = triggerCollisionDeath

  spikes2 = map:findObject("spikes2")
  spikes2.myName = "spikes2"
  spikes2.collision = triggerCollisionDeath

  spikes3 = map:findObject("spikes3")
  spikes3.myName = "spikes3"
  spikes3.collision = triggerCollisionDeath

  spikes4 = map:findObject("spikes4")
  spikes4.myName = "spikes4"

  spikes4.collision = triggerCollisionDeath

  spikes5 = map:findObject("spikes5")
  spikes5.myName = "spikes5"
  spikes5.collision = triggerCollisionDeath

  spikes6 = map:findObject("spikes6")
  spikes6.myName = "spikes6"
  spikes6.collision = triggerCollisionDeath

  sensorSpikes1 = map:findObject("spikes7")
  sensorSpikes1.myName = "sensorSpikes1"
  sensorSpikes1.collision = triggerCollisionDeath

  sensorSpikes2 = map:findObject("spikes8")
  sensorSpikes2.myName = "sensorSpikes2"
  sensorSpikes2.collision = triggerCollisionDeath

  sensorSpikes3 = map:findObject("spikes9")
  sensorSpikes3.myName = "sensorSpikes3"
  sensorSpikes3.collision = triggerCollisionDeath

  sensorSpikes4 = map:findObject("spikesSens")
  sensorSpikes4.collision = triggerCollisionDeath

  timedSpikes1 = map:findObject("timedSpikes1")
  transition.to(timedSpikes1, { time = 2000, y = (timedSpikes1.y - 112), iterations=0, transition = easing.continuousLoop  } )
  timedSpikes1.collision = triggerCollisionDeath

  sensorSpikes5 = map:findObject("sensorSpikes5")
  sensorSpikes5.collision = triggerCollisionDeath

  sensor2 = map:findObject("sensor2")
  physics.addBody(sensor2, "static", { box={ halfWidth=64, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor2.collision = sensorCollideSpikes1


  sensor1 = map:findObject("sensor1")
  physics.addBody(sensor1, "static", { box={ halfWidth=320, halfHeight=16, x=0, y=0 }, isSensor=true })

  sensor1.collision = sensorCollideSpikes1

    turret1 = map:findObject("turret1")
    turret1.myName = "turret1"

    turret2 = map:findObject("turret2")
    turret2.myName = "turret2"

    turret3 = map:findObject("turret3")
    turret3.myName = "turret3"

    turret4 = map:findObject("turret4")
    turret4.myName = "turret4"

    turret6 = map:findObject("turret6")
    turret6.myName = "turret6"

    turret7 = map:findObject("turret7")
    turret7.myName = "turret7"

    turret9 = map:findObject("turret9")
    turret9.myName = "turret9"

    turret10 = map:findObject("turret10")
    turret10.myName = "turret10"

    turret11 = map:findObject("turret11")
    turret11.myName = "turret11"

    turret12 = map:findObject("turret12")
    turret12.myName = "turret12"

    turret13 = map:findObject("turret13")
    turret13.myName = "turret13"

    turret14 = map:findObject("turret14")
    turret14.myName = "turret14"

  feather = map:findObject("feather")
  feather.myName = "feather"

  feather.collision = triggerCollisionFeather

  heart = map:findObject("heart")
  heart.myName = "heart"

  heart.collision = triggerCollisionHeart

  -- battery = map:findObject("battery")
  -- battery.myName = "battery"
  --
  -- battery.collision = triggerCollisionBattery

  exit = map:findObject("exit")
  physics.addBody(exit, "static", { box={ halfWidth=32, halfHeight=43, x=0, y=0 }, isSensor=true })
  exit.collision = gotoLevel2

  button = map:findObject("button")
  physics.addBody(button, "static", { box={ halfWidth=8, halfHeight=8, x=0, y=0 }, isSensor=true })
  wall1 = map:findObject("wall1")

  button.collision = sensorCollideTrigger

  flagNo = map:findObject("flagNo")
physics.addBody(flagNo, "static", { box={ halfWidth = 16, halfHeight=16, x=-8, y=0 }, isSensor=true })
flagNo.collision = spawnCollision

flagYes = map:findObject("flagYes")

flagNo.isVisible = true
flagYes.isVisible = false


	lives = display.newImageRect(sceneGroup, "heart.png",45,45)
	lives.x = display.contentCenterX-900
	lives.y = display.contentCenterY-500

	livesText = display.newText("x " .. livesCount, 120, 35, native.systemFont, 40 )
	livesText:setFillColor( 1, 1, 1 )

	feathers = display.newImageRect(sceneGroup, "feather.png",45,45)
	feathers.x = display.contentCenterX-900
	feathers.y = display.contentCenterY-440

	feathersText = display.newText("x " .. featherCount, 120, 100, native.systemFont, 40 )
	feathersText:setFillColor( 1, 1, 1 )

  spikes1:addEventListener("collision")
  spikes2:addEventListener("collision")
  spikes3:addEventListener("collision")
  spikes4:addEventListener("collision")
  spikes5:addEventListener("collision")
  spikes6:addEventListener("collision")
  sensor1:addEventListener( "collision" )
  sensorSpikes1:addEventListener( "collision" )
  sensorSpikes2:addEventListener( "collision" )
  sensorSpikes3:addEventListener( "collision" )
  feather:addEventListener( "collision")
  heart:addEventListener( "collision" )
  -- battery:addEventListener( "collision")
  exit:addEventListener( "collision" )
  timedSpikes1:addEventListener( "collision" )
  flagNo:addEventListener( "collision" )



    sceneGroup:insert( map )
    sceneGroup:insert( character )
  	sceneGroup:insert( livesText )
    sceneGroup:insert( feathersText )
  	sceneGroup:insert( lives )
  	sceneGroup:insert( feathers )
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
    Runtime:addEventListener( "timer", fireTurret1 )
    Runtime:addEventListener( "timer", fireTurret2 )
    Runtime:addEventListener( "timer", fireTurret3 )
    Runtime:addEventListener( "collision", groundCollisionLaser )
    Runtime:addEventListener( "collision", laserCollision )
    turretShoot1 = timer.performWithDelay( 1500  , fireTurret1, -1 )
    turretShoot2 = timer.performWithDelay( 1000  , fireTurret2, -1 )
    turretShoot3 = timer.performWithDelay( 2200  , fireTurret3, -1 )

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
    timer.cancel(turretShoot1)
    timer.cancel(turretShoot2)
    timer.cancel(turretShoot3)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    Runtime:removeEventListener( "key", pauseScreen)
    Runtime:removeEventListener( "key", key)
    Runtime:removeEventListener( "key", jump )
    Runtime:removeEventListener( "enterFrame", enterFrame )
    Runtime:removeEventListener("key", invis)
    Runtime:removeEventListener( "timer", fireTurret1)
    Runtime:removeEventListener( "timer", fireTurret2)
    Runtime:removeEventListener( "timer", fireTurret3)
    Runtime:removeEventListener( "collision", groundCollisionLaser )
    Runtime:removeEventListener( "collision", laserCollision )
		physics.pause()
		composer.removeScene( "Level3" )
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
