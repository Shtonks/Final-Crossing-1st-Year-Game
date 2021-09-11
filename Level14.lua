
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
physics.setGravity(0, 30)
-- physics.setDrawMode( "hybrid" )



-- map.x,map.y = display.contentCenterX - map.designedWidth/2, display.contentCenterY - map.designedHeight/2


--Declare variables
local speakingGroup
local prevTime = 0
local livesCount = composer.getVariable( "livesCount")
local livesText
local feathersText
local featherCount = composer.getVariable( "featherCount")
local gooseCount = 3
local characterJumping = 0
local keyPressed = 0
local died = false
local paused = false
local turnCount = 0
local shotCount = 0
local gun = true
local backgroundMusic = audio.loadStream( "shrine.wav" )
local walkSound = audio.loadSound( "walk.mp3" )
local featherSound = audio.loadSound( "feather.mp3" )
local heartSound = audio.loadSound( "heart.mp3" )
local batterySound = audio.loadSound( "battery.mp3" )
local flySound = audio.loadSound( "wings.mp3" )
local biteSound = audio.loadSound( "bite.mp3" )
local honkSound = audio.loadSound( "honk.mp3" )
local audioLevel
local backgroundMusicChannel
local walkChannel
local collectablesChannel
local honkChannel
local flyChannel
local nextScene
local sheetOptions
local walkCharacter
local walking
local gameLoopTimer
local wherefrom
local honkish
local human
local clearText1
local clearText2

local upPressed = false
local downPressed = false
local leftPressed = false
local rightPressed = false

local mapData
local map
local character
local feathers
local lives
local kingGoose
local goose

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
    -- character:pause()
    physics.pause()
    composer.setVariable( "livesCount", livesCount )
    composer.setVariable( "featherCount", featherCount )
    composer.gotoScene("gameOver", { time=700, effect="slideLeft" })
end

local function gameOver(self, event)
    if(event.other.myName == "kingGoose" or event.other.myName == "character") then
      if(event.phase == "began") then
        if(shotCount >= 10)then
          gotoDeathScreen()
        elseif(shotCount < 10)then
          audio.pause()
          physics.pause()
          composer.setVariable( "livesCount", livesCount )
          composer.setVariable( "featherCount", featherCount )
          composer.setVariable( "nextScene", "congrats" )
          composer.gotoScene("loading", { time=20, effect="slideLeft" })
      end
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
      elseif(upPressed and leftPressed and characterJumping < 2) then
          -- rightPressed = false
          leftPressed = true
              character:applyLinearImpulse( -10, -60, character.x, character.y )
              characterJumping = characterJumping + 1
        elseif(upPressed and rightPressed and characterJumping < 2) then
          rightPressed = true
          -- leftPressed = true
              character:applyLinearImpulse( 10, -60, character.x, character.y )
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
    character.x = display.contentCenterX - 800
    character.y = display.contentCenterY + 250
  end
end

-- After loss of life
local function restoreChar()

    character.isBodyActive = false
    spawn()

-- Fade in the character
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
             livesText.text = "x" .. livesCount
             character.alpha = 0
             timer.performWithDelay( 100, restoreChar )
           elseif( livesCount == 1 )then
             livesCount = livesCount - 1
             character.alpha = 0
             timer.performWithDelay( 500, gotoDeathScreen )
           end
       end
     end
  end
end

local function triggerCollisionHeart(self, event)
      if(event.other.myName == "heart" or event.other.myName == "character") then
        if(event.phase == "began") then
          collectablesChannel =  audio.play( heartSound, { channel=3} )
					livesCount = livesCount + 5
					livesText.text = "x" .. livesCount
          display.remove(heart)
        end
      end
end


local function fireGun(event)

if gun==true then
   if( event.keyName == "space" and characterJumping == 0 ) then
     if (event.phase == "down") then
     local gunLaser = display.newImageRect("laser.png", 10, 10 ) --this is laser size
     physics.addBody( gunLaser, "dynamic", {isSensor=true} )
     gunLaser.myName = "gunlaser"
     gunLaser.gravityScale = 0

     gunLaser.x = character.x
     gunLaser.y = character.y
     transition.to( gunLaser, { x=2000, time=1500,  -- x is lasers destination, time is how fast it goes
     onComplete = function() display.remove( gunLaser ) end
     } )
     if(turnCount == 0)then
       transition.to( gunLaser, { x=2000, time=1500,  -- x is lasers destination, time is how fast it goes
       onComplete = function() display.remove( gunLaser ) end
       } )
     elseif(turnCount == 1)then
        transition.to( gunLaser, { x=-2000, time=1500,  -- x is lasers destination, time is how fast it goes
        onComplete = function() display.remove( gunLaser ) end
        } )
        end
      end
    end
  end
end

 local function gunlaserCollision( event )
    if( event.phase == "began" ) then

        local obj1 = event.object1
        local obj2 = event.object2
          if ( obj1.myName == "goose" and obj2.myName == "gunlaser") then
              -- gooseCount = gooseCount - 1
              event.object1:removeSelf()
              event.object2:removeSelf()
              audio.stop(4)
          elseif( obj1.myName == "gunlaser" and obj2.myName == "goose" ) then
              -- gooseCount = gooseCount - 1
              event.object1:removeSelf()
              event.object2:removeSelf()
              audio.stop(4)
          end
     end
 end

 local function kingGooseCollision(event)
    if( event.phase == "began" ) then
      if(character.x < kingGoose.x)then
        kingGoose.xScale = 1
      elseif(character.x > kingGoose.x)then
        kingGoose.xScale = -1
      end
        local obj1 = event.object1
        local obj2 = event.object2
          if ( obj1.myName == "kingGoose" and obj2.myName == "gunlaser") then
              shotCount = shotCount + 1
              event.object2:removeSelf()
              audio.play( honkSound, { channel=3})
          elseif( obj1.myName == "gunlaser" and obj2.myName == "kingGoose" ) then
              shotCount = shotCount + 1
              event.object1:removeSelf()
              audio.play( honkSound, { channel=3})
          end
     end
 end

local function finalWords()
  clearText1 = display.remove(honkish)
  clearText2 = display.remove(human)
    if(shotCount == 1)then
      honkish = display.newText("'Honk', a hOoMaN? what in honking hell are you doing here?", 1000, 300, native.systemFont, 50 )
      human = display.newText("Did that goose just speak?", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount == 2)then
      -- display.remove(honkish)
      honkish = display.newText("'Honk', you can hear me?", 1000, 300, native.systemFont, 50 )
      human = display.newText("Uhhh yeahh this can't be happening, right?", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount == 3)then
      honkish = display.newText("'Honk', I imagine you've had quite the honking journey", 1000, 300, native.systemFont, 50 )
      human = display.newText("You think?... what happend here?", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount == 4)then
      honkish = display.newText("'Honk', the rebellion was long and difficult, we won but at what cost?", 1000, 300, native.systemFont, 50 )
      human = display.newText("...", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount == 5)then
      honkish = display.newText("'Honk', you wouldn't understand", 1000, 300, native.systemFont, 50 )
      human = display.newText("(Wait... is that goose crying?)", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount == 6)then
      honkish = display.newText("'Honk', *goose tears* Ple...Please don't hurt me, this life has become lonely", 1000, 300, native.systemFont, 50 )
      human = display.newText("Oh... um it's okay?", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount == 7)then
      honkish = display.newText("'Honk', ...", 1000, 300, native.systemFont, 50 )
      human = display.newText("(He looks like he needs a hug)", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount == 8)then
      honkish = display.newText("'Honk', ouchie, stop shooting me", 1000, 300, native.systemFont, 50 )
      human = display.newText("(He looks like he needs a hug)", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount == 9)then
      honkish = display.newText("'Honk', seriously dude, i'm crying over here", 1000, 300, native.systemFont, 50 )
      human = display.newText("(He looks like he needs a hug)", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    elseif(shotCount >= 10)then
      honkish = display.newText("'Honk', I said stop itttt!!!", 1000, 300, native.systemFont, 50 )
      human = display.newText("(He looks like he needs a hug)", honkish.x, honkish.y+70, native.systemFont, 30 )
      timer.performWithDelay(800, clearText1)
      timer.performWithDelay(800, clearText2)
      speakingGroup:insert( honkish )
      speakingGroup:insert( human )
    end
end

 local function movingGeese()
  local function goose1_1()
    goose1.xScale = 1
    transition.to(goose1,{ time = 1500, x = (goose1.x - 300), onComplete=goose1_2  })
  end
  local function goose2_1()
    goose2.xScale = 1
    transition.to(goose2,{ time = 1500, x = (goose2.x + 300), onComplete=goose2_2  })
  end
  goose1_2 = function ()
    goose1.xScale = -1
    transition.to(goose1,{ time = 1500, x = (goose1.x + 300), onComplete=goose1_1  })
  end

  goose2_2  = function ()
    goose2.xScale = -1
    transition.to(goose2,{ time = 1500, x = (goose2.x - 300), onComplete=goose2_1  })
  end
 goose1_1()
 goose2_1()
 end


local function spawnCollision( self, event )
    if ( event.selfElement == 1 and event.other.myName == "character" ) then
        if ( event.phase == "began" ) then
          spawnPoint = true
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

  background = display.newImageRect(sceneGroup, "plain.png", 1920, 1080)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

speakingGroup = display.newGroup()
backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1} )
honkChannel =  audio.play( honkSound, { channel=3})
flyChannel = audio.play( flySound, { channel=4, loops=-1} )
audioLevel = audio.setVolume( 0.03, { channel=1 } )
audio.setVolume( 0.05, { channel=2 } )
audio.setVolume( 0.1, { channel=3 } )
audio.setVolume( 0.1, { channel=4 } )

  mapData = require "objects.Screen14" -- load from lua export
  map = tiled.new(mapData, "objects")

  sheetOptions =
  {
      width = 159,
      height = 202,
      numFrames = 9
  }

  walkCharacter = graphics.newImageSheet( "gunWalkies.png", sheetOptions )

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

  heart = map:findObject("heart")
  heart.myName = "heart"

  heart.collision = triggerCollisionHeart

    spikes1 = map:findObject("spikes1")
    spikes1.myName = "spikes1"
    spikes1.collision = triggerCollisionDeath

    spikes2 = map:findObject("spikes2")
    spikes2.myName = "spikes2"
    spikes2.collision = triggerCollisionDeath

    spikes3 = map:findObject("spikes3")
    spikes3.myName = "spikes3"
    spikes3.collision = triggerCollisionDeath

    kingGoose = map:findObject("kingGoose")
    kingGoose.collision = gameOver
    kingGoose.myName = "kingGoose"

  goose2 = map:findObject("goose2")
  goose2.collision = triggerCollisionDeath
  goose2.myName = "goose"

  goose1 = map:findObject("goose1")
  goose1.collision = triggerCollisionDeath
  goose1.myName = "goose"

  goose3 = map:findObject("goose3")
  goose3.collision = triggerCollisionDeath
  goose3.myName = "goose"

  goose4 = map:findObject("goose4")
  goose4.collision = triggerCollisionDeath
  goose4.myName = "goose"

  goose5 = map:findObject("goose5")
  goose5.collision = triggerCollisionDeath
  goose5.myName = "goose"

  goose6 = map:findObject("goose6")
  goose6.collision = triggerCollisionDeath
  goose6.myName = "goose"

  goose7 = map:findObject("goose7")
  goose7.collision = triggerCollisionDeath
  goose7.myName = "goose"

  goose8 = map:findObject("goose8")
  goose8.collision = triggerCollisionDeath
  goose8.myName = "goose"

	lives = display.newImageRect("heart.png",45,45)
	lives.x = display.contentCenterX-900
	lives.y = display.contentCenterY-500

	livesText = display.newText("x" .. livesCount, 120, 35, native.systemFont, 40 )
	livesText:setFillColor( 1, 1, 1 )

	feathers = display.newImageRect("feather.png",45,45)
	feathers.x = display.contentCenterX-900
	feathers.y = display.contentCenterY-440

	feathersText = display.newText("x" .. featherCount, 120, 100, native.systemFont, 40 )
	feathersText:setFillColor( 1, 1, 1 )

  movingGeese()
  gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )

  spikes1:addEventListener("collision")
  spikes2:addEventListener("collision")
  spikes3:addEventListener("collision")
  goose1:addEventListener( "collision" )
  goose2:addEventListener( "collision" )
  goose3:addEventListener( "collision" )
  goose4:addEventListener( "collision" )
  goose5:addEventListener( "collision" )
  goose6:addEventListener( "collision" )
  goose7:addEventListener( "collision" )
  goose8:addEventListener( "collision" )
  kingGoose:addEventListener( "collision" )
  heart:addEventListener( "collision" )

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
    Runtime:addEventListener( "key", fireGun )
    Runtime:addEventListener( "enterFrame", finalWords )
    Runtime:addEventListener( "collision", gunlaserCollision )
    Runtime:addEventListener( "collision", kingGooseCollision )


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
    display.remove(honkish)
    display.remove(human)
    Runtime:removeEventListener( "key", pauseScreen)
    Runtime:removeEventListener( "key", key)
    Runtime:removeEventListener( "key", jump )
    Runtime:removeEventListener( "enterFrame", enterFrame )
    Runtime:removeEventListener( "enterFrame", finalWords )
    Runtime:removeEventListener("key", invis)
    Runtime:removeEventListener( "key", fireGun )
    Runtime:removeEventListener( "collision", gunlaserCollision )
    Runtime:removeEventListener( "collision", kingGooseCollision )
		physics.pause()
		composer.removeScene( "Level14" )
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
