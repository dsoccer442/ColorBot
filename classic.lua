----------------------------------------------------------------------------------
--
-- classic.lua
--
----------------------------------------------------------------------------------

display.setDefault( "background", 255, 255, 255 )

local storyboard = require( "storyboard" )
local Bot = require("bot")
local Region = require("region")
local physics = require("physics")
local sprite = require("sprite")
local widget = require("widget")
-- local graphics = require("graphics")

local scene = storyboard.newScene()

local botGroup = {}
local regionGroup = display.newGroup()
local headerGroup = display.newGroup()
local botDragGroup = {}
local blueGroup = {}
local greenGroup = {}
local redGroup = {}
local yellowGroup = {}

local BOT_WIDTH = 48
local BOT_HEIGHT = 48
local OFFSET_X = BOT_WIDTH * 0.5
local OFFSET_Y = BOT_HEIGHT * 0.5
local ANIMATION_SPEED = 100
local EXPLOSION_SPEED = 200
local MIN_CREATURES = 1
local MAX_CREATURES = 3
local REGION_WIDTH = 128
local REGION_HEIGHT = 86
local time = 3000
local gameState = true
local lives = 3
local score = 0
local waves = 0
-- Slash line properties (line that shows up when you move finger across the screen)
local maxPoints = 5
local lineThickness = 15
local lineFadeTime = 250
local endPoints = {}

local background = display.newImage("images/BackgroundBoundaries.png")

local livesImage = display.newImage("images/lives 3.png")
local scoreText = display.newText("0", 415, 0,"Helvetica",20)
local pauseButton

local random = math.random

local comboDrag
local createBots
local createBoundary
local createHeader
local pauseGame
local refreshLives
local regionBounce
local resumeGame
local updateScore

local blueRegion, greenRegion, redRegion, yellowRegion = Region.create()

local redBotSheet = sprite.newSpriteSheet("images/Robot4Walking.png", BOT_WIDTH, BOT_WIDTH)
local redBotSet = sprite.newSpriteSet(redBotSheet, 1, 10)
local greenBotSheet = sprite.newSpriteSheet("images/Robot1Walking.png", BOT_WIDTH, BOT_WIDTH)
local greenBotSet = sprite.newSpriteSet(greenBotSheet, 1, 10)
local yellowBotSheet = sprite.newSpriteSheet("images/Robot3Walking.png", BOT_WIDTH, BOT_WIDTH)
local yellowBotSet = sprite.newSpriteSet(yellowBotSheet, 1, 10)
local blueBotSheet = sprite.newSpriteSheet("images/Robot2Walking.png", BOT_WIDTH, BOT_WIDTH)
local blueBotSet = sprite.newSpriteSet(blueBotSheet, 1, 10)
local explosionSheet = sprite.newSpriteSheet("images/ExplosionSheet.png", BOT_WIDTH, BOT_WIDTH)
local explosionSet = sprite.newSpriteSet(explosionSheet, 1, 5)

local doorR
local doorA

pauseGame = function()
	physics.pause()
	timer.pause(createBotsTimer)
	timer.pause(changeTimeTimer)
	for i = 1, #botGroup do
		botGroup[i]:removeEventListener("touch", botTouch)
	end
end

resumeGame = function()
	physics.resume()
	timer.resume(createBotsTimer)
	timer.resume(changeTimeTimer)
	for i = 1, #botGroup do
		botGroup[i]:addEventListener("touch", botTouch)
	end
end

createHeader = function()
	pauseButton = widget.newButton{
		default="images/pause button.png",
		onRelease = pauseGame
	}
	pauseButton.x = 450
	headerGroup:insert(pauseButton)
	headerGroup:insert(livesImage)
	headerGroup:insert(scoreText)
	scoreText:setReferencePoint(display.topRightReferencePoint)
end

createBoundary = function(left,top,width,height,thickness)
	local upSide = display.newRect(left,top,width,thickness)
	local leftSide = display.newRect(left,top,thickness,height)
	local rightSide = display.newRect(left+width,top,thickness,height)
	local downSide = display.newRect(left,top+height,width,thickness)
	local boundsFilter = {categoryBits = 1, maskBits = 5}
	physics.addBody(upSide,"static",{bounce = 1, filter = boundsFilter})
	physics.addBody(leftSide,"static",{bounce = 1, filter = boundsFilter})
	physics.addBody(rightSide,"static",{bounce = 1, filter = boundsFilter})
	physics.addBody(downSide,"static",{bounce = 1, filter = boundsFilter})
	upSide.isVisible = false
	downSide.isVisible = false
	leftSide.isVisible = false
	rightSide.isVisible = false
end

refreshLives = function()
	lives = lives - 1
	livesImage:removeSelf()
	if lives > 0 then
		if lives == 2 then
			livesImage = display.newImage("images/lives 2.png")
		elseif lives == 1 then
			livesImage = display.newImage("images/lives 1.png")
		end
	else
		livesImage = display.newImage("images/lives 0.png")
		storyboard.score = score
		storyboard.gotoScene("retry", "fade", 800)
	end
end

regionBounce = function()
	for i = 1, #botGroup do
		local bot = botGroup[i]
		if bot and bot.placed then
			local region = regionGroup[bot.color]
			vx, vy = bot:getLinearVelocity()
			if bot.changedFilter == false then
				bot.changedFilter = true
				physics.removeBody(bot)
		     	physics.addBody(bot,{filter = {categoryBits = 4, maskBits = 1}})
		     	bot.isFixedRotation = true
		     	bot:setLinearVelocity(random(-50, 50), random(-50, 50))
		     	table.remove(botGroup, i)
		     end
		end
	end
end

function botTouch( event )
	local bot = event.target  

	 -- -- Play a slash sound
	 -- if(endPoints ~= nil and endPoints[1] ~= nil) then
	 --  local distance = math.sqrt(math.pow(event.x - endPoints[1].x, 2) + math.pow(event.y - endPoints[1].y, 2))
	 --  if(distance > minDistanceForSlashSound and slashSoundEnabled == true) then 
	 --   playRandomSlashSound();  
	 --   slashSoundEnabled = false
	 --   timer.performWithDelay(minTimeBetweenSlashes, function(event) slashSoundEnabled = true end)
	 --  end
	 -- end
	 
	 table.insert(endPoints, 1, {x = event.x, y = event.y, line= nil}) 

	 -- Remove any excessed points
	 if(#endPoints > maxPoints) then 
	  table.remove(endPoints)
	 end

	if #endPoints > 1 then
	 for i,v in ipairs(endPoints) do
	  local line = display.newLine(v.x, v.y, event.x, event.y)
	
	local color = bot.color
	  if color == 1 then
	  	line:setColor(31,150,250,255)
	  elseif color == 2 then 
		line:setColor(14,174,93,255)
	  elseif color == 3 then 
		line:setColor(255,0,0,255)
	  elseif color == 4 then 
		line:setColor(255,204,0,255)
	  end
	  line.width = lineThickness
	  transition.to(line, {time = lineFadeTime, alpha = 0, width = 0, onComplete = function(event) line:removeSelf() end})  
	 end
	end
	 --- end slash code

    local phase = event.phase  
    if "began" == phase then  
    	bot:pickup(event.x, event.y)
    	--#TODObot.collision = comboDrag
    	bot:addEventListener("collision", bot)
    	table.insert(botDragGroup, bot)
    	physics.removeBody(bot)
      	physics.addBody(bot,{isSensor = true, filter = {categoryBits = 8, maskBits = 2}})
      	bot.isFixedRotation = true
    elseif "moved" == phase  then  
            for i = 1, #botDragGroup do
            	botDragGroup[i]:move(event.x, event.y)
            end
    elseif "ended" == phase or "cancelled" == phase then  
    	while(#endPoints > 0) do
   			table.remove(endPoints)
  		end
  		if #botDragGroup > 1 then
  			if regionGroup[botDragGroup[1].color].alpha == 1 then --and regionGroup[botDragGroup[1].color].color == botDragGroup[1].color then
	  			-- local colorSum = 0
	  			-- for i = 1, #botDragGroup do
	  			-- 	colorSum = colorSum + botDragGroup[i].color 
	  			--end
		  		--if colorSum == #botDragGroup * botDragGroup[1].color then
		  			local comboGroup = display.newGroup()
		  			display.newText(comboGroup,"COMBO", botDragGroup[1].x, botDragGroup[1].y, native.systemFontBold, 15)
		  			display.newText(comboGroup,"+"..#botDragGroup, botDragGroup[1].x+15, botDragGroup[1].y+15, native.systemFontBold, 15)
		  			transition.to(comboGroup, {time = 1500, alpha = 0, y = comboGroup.y - 20, onComplete = function() display.remove(comboGroup) end})
		  			updateScore(#botDragGroup)
		  		--end
  			end
  		end
    	for i = #botDragGroup, 1, -1 do
    		local dragBot = botDragGroup[i]
    		if dragBot then
        		physics.removeBody(dragBot)
			    physics.addBody(dragBot,{bounce = .5, density = 50, filter = {categoryBits = 4, maskBits = 3}})
			    dragBot:removeEventListener("collision", dragBot)
			    dragBot.isFixedRotation = true
        		dragBot:release()
        		table.remove(botDragGroup, i)
        		--#TODO need to figure out what to do when the bot is deleted because the touch went offscreen. cancel touch event? (if so edit this elseif clause.)
    		end
    	end
    end   
end
--#todo reset finger swipe when bot leaves screen.

gameOver = function()
local loser = display.newText("GAME OVER", 30, 100,"Helvetica",70)
	for i = 1, #botGroup do
			botGroup[i]:removeEventListener("touch", botTouch)
	end
end

createBots = function()
	--#TODOfor i = 1, random(MIN_CREATURES, MAX_CREATURES) do
	if #botGroup > 20 then
	gameOver()
	return
	end
	for i = 1, 1 do
		local bot
		
		local color = random(1, 4)
		
		if color == 1 then
			bot = sprite.newSprite(blueBotSet)
			bot:prepare("walking")
			bot.color = color
		elseif color == 2 then
			bot = sprite.newSprite(greenBotSet)
			bot:prepare("walking")
			bot.color = color
		elseif	color == 3 then
			bot = sprite.newSprite(redBotSet)
			bot:prepare("walking")
			bot.color = color
		elseif color == 4 then
			bot = sprite.newSprite(yellowBotSet)
			bot:prepare("walking")
			bot.color = color
		end
		bot:addEventListener("touch", botTouch)
		bot:play()

		local spawn = random(1,4)
		if spawn == 1 then
			bot.x, bot.y = 240, BOT_HEIGHT/2
		elseif spawn == 2 then
			bot.x, bot.y = BOT_WIDTH/2, 160
		elseif spawn == 3 then
			bot.x, bot.y = 240, 320 - BOT_HEIGHT/2
		else
			bot.x, bot.y = 480 - BOT_WIDTH/2, 160
		end
		--bot:toBack()
		--background:toBack() --FIX THIS YOU IDIOT #TODO

		table.insert(botGroup, bot)

		physics.addBody(bot,{bounce = .5, density = 50, filter = {categoryBits = 4, maskBits = 1}})
		bot.isFixedRotation = true
		Bot.create(bot)

		local verticalVelocity = random(-70, 70)
		if verticalVelocity < 20 and verticalVelocity > 0 then
			verticalVelocity = verticalVelocity + 50
		elseif verticalVelocity > -20 and verticalVelocity < 0 then
			verticalVelocity = verticalVelocity - 50
		end
		local horizontalVelocity = random(-70, 70)
		if horizontalVelocity < 20 and horizontalVelocity > 0 then
			horizontalVelocity = horizontalVelocity + 50
		elseif horizontalVelocity > -20 and horizontalVelocity < 0 then
			horizontalVelocity = horizontalVelocity - 50
		end
		bot:setLinearVelocity(horizontalVelocity, verticalVelocity)

		bot.myName = "bot"
	end
end
 
local function changeCreateBotsTime()
	-- if time > 1000 then 
	-- 	time = time - 500
	-- else
	-- 	time = time * .
	-- end
	time = time * .75
	timer.pause(createBotsTimer)
	createBotsTimer = timer.performWithDelay(time, createBots, 0)
	print(time) --#TODO

	--big waves
	waves = waves + 10
	if waves >= 30 then

	end
end

local function offScreen()
	for i = 1, #botGroup do
		local bot = botGroup[i]
		if (bot and bot.x and bot.y) then
			if bot.x + OFFSET_X < 0 or bot.x - OFFSET_X > 480 or 
				bot.y + OFFSET_Y < 0 or bot.y - OFFSET_Y > 320 then
				if bot.placed == false then
					refreshLives()
					if bot.drag == true then
						while(#endPoints > 0) do
							table.remove(endPoints)
						end
						for i = 1, #botDragGroup do
							table.remove(botDragGroup, i)
						end
					end
				end
				bot:removeSelf()
				table.remove(botGroup, i)
				return
			end
		end
	end
end

updateScore = function(points)
	score = score + points
	scoreText.text = score
end

local function testCollisions(self, event)
	local bot = event.other
	if (bot.myName == "bot")  then
		if bot.drag == false and (bot.placed == false) then
			if  self.color == bot.color then
		     	
		     	bot.placed = true
		     	updateScore(1)
		     	self:lightUp()

		        bot:removeEventListener("touch", botTouch)
		        transition.to(bot, {time = 200, x = self.x, y = self.y})
		        timer.performWithDelay(1,regionBounce,1)

		        if bot.color == 1 then
		        	table.insert(blueGroup, bot)
		        	print("blue")
		        elseif bot.color == 2 then
		        	table.insert(greenGroup, bot)
		        	print("green")
		        elseif bot.color == 3 then
		        	table.insert(redGroup, bot)
		        elseif bot.color == 4 then
		        	table.insert(yellowGroup, bot)
		       	end

		       	if #blueGroup >= 5 then
		       		for i = #blueGroup, 1, -1 do
		       			transition.to(blueGroup[i], {time = 200, x = -16})
		       			table.remove(blueGroup, i)
		       			-- local screen = display.captureScreen()
		       			-- local mask = graphics.newMask("images/mask.png")
		       			-- screen:setMask(mask)
		       			-- screen.maskX = self.x
		       			-- screen.maskY = self.y
		       			-- transition.to(screen, {time = 1000, yScale = .1 })
		       		end
		       	elseif #greenGroup >= 5 then
		       		for i = #greenGroup, 1, -1 do
		       			transition.to(greenGroup[i], {time = 200, x = 496})
		       			table.remove(greenGroup, i)
		       		end
		       	elseif #redGroup >= 5 then
		       		for i = #redGroup, 1, -1 do
		       			transition.to(redGroup[i], {time = 200, x = -16})
		       			table.remove(redGroup, i)
		       		end
		       	elseif #yellowGroup >= 5 then
		       		for i = #yellowGroup, 1, -1 do
		       			transition.to(yellowGroup[i], {time = 200, x = 496})
		       			table.remove(yellowGroup, i)
		       		end
		       	end
		    else
		    	local explosion = sprite.newSprite(explosionSet)
		    	explosion.x, explosion.y = bot.x, bot.y
		    	explosion:prepare("explode")
		    	explosion:play()

		    	local function removeExplosion()
					explosion:removeSelf()
				end
				timer.performWithDelay(EXPLOSION_SPEED, removeExplosion, 1)

				print("?")
		    	refreshLives()
		    	bot:removeSelf()	
		    	self.alpha = 0
			end
		elseif event.phase == "began" then
			self.alpha = 1
		elseif event.phase == "ended"then
			self.alpha = 0
		end
	end
end

local dragTimeLimit = function()
	while(#endPoints > 0) do
		table.remove(endPoints)
	end
	for i = #botDragGroup, 1, -1 do
		local dragBot = botDragGroup[i]
		if dragBot then
    		physics.removeBody(dragBot)
		    physics.addBody(dragBot,{bounce = .5, density = 50, filter = {categoryBits = 4, maskBits = 1}})
		    dragBot:removeEventListener("collision", dragBot)
		    dragBot.isFixedRotation = true
    		dragBot:release()
    		table.remove(botDragGroup, i)
    		--#TODO need to figure out what to do when the bot is deleted because the touch went offscreen. cancel touch event? (if so edit this elseif clause.)
		end
	end
end

comboDrag = function(self, event )
	local bot = event.other
	if bot.myName == "bot" and bot.drag == false and self.drag == true then
		if self.color == bot.color then
			bot:pickup(bot.x, bot.y)
			bot.collision = comboDrag
			bot:addEventListener("collision", bot)
			table.insert(botDragGroup, bot)	
			timer.performWithDelay(500, dragTimeLimit, 1)
		end
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	group:insert(background)
	background:toBack()

	doorA = display.newImage("DoorA.png", 240, 0)
	doorR = display.newImage("DoorR.png")
	group:insert(doorA)
	group:insert(doorR)

	local function openDoors( event )
		transition.to(doorA, { x=680, time=1000 })
		transition.to(doorR, { x=-240, time=1000 })
		print("openDoors")
		return true
	end

	openDoorsTimer = timer.performWithDelay(1, openDoors, 1)

	sprite.add(redBotSet, "walking", 1,3,ANIMATION_SPEED,0)
	sprite.add(greenBotSet, "walking", 1,3,ANIMATION_SPEED,0)
	sprite.add(yellowBotSet, "walking", 1,3,ANIMATION_SPEED,0)
	sprite.add(blueBotSet, "walking", 1,3,ANIMATION_SPEED,0)

	sprite.add(redBotSet, "drag", 6,5,ANIMATION_SPEED,0)
	sprite.add(greenBotSet, "drag", 6,5,ANIMATION_SPEED,0)
	sprite.add(yellowBotSet, "drag", 6,5,ANIMATION_SPEED,0)
	sprite.add(blueBotSet, "drag", 6,5,ANIMATION_SPEED,0)

	sprite.add(explosionSet,"explode", 1, 5, EXPLOSION_SPEED,1)

	physics.start()
	physics.setGravity(0,0)

	createBoundary(0,0,REGION_WIDTH,REGION_HEIGHT,3)
	createBoundary(480-REGION_WIDTH,0,REGION_WIDTH,REGION_HEIGHT,3)
	createBoundary(0,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT,3)
	createBoundary(480-REGION_WIDTH,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT,3)
	createBoundary(0,0,480,320,3)

	table.insert(regionGroup,blueRegion)
	table.insert(regionGroup,greenRegion)
	table.insert(regionGroup,redRegion)
	table.insert(regionGroup,yellowRegion)

	physics.addBody(blueRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 14}})
	physics.addBody(greenRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 14}})
	physics.addBody(redRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 14}})
	physics.addBody(yellowRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 14}})
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	group:insert(scoreText)
	createHeader()

	createBotsTimer = timer.performWithDelay( time, createBots, 0 )
	changeTimeTimer = timer.performWithDelay( 1000, changeCreateBotsTime, 0 )

	for i = 1, #regionGroup do
		group:insert(regionGroup[i])
		regionGroup[i].collision = testCollisions
		regionGroup[i]:addEventListener("collision", regionGroup[i])
	end

	Runtime:addEventListener("enterFrame", offScreen)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	for i = 1, #regionGroup do
		regionGroup[i]:removeEventListener("collision", regionGroup[i])
		group:insert(regionGroup[i])
	end
	for i = 1, #blueGroup do
		group:insert(blueGroup[i])
		-- blueGroup[i]:removeSelf()
	end
	for i = 1, #greenGroup do
		greenGroup[i]:removeSelf()
	end
	for i = 1, #redGroup do
		redGroup[i]:removeSelf()
	end
	for i = 1, #yellowGroup do
		yellowGroup[i]:removeSelf()
	end
	for i = 1, #botGroup do
		-- group:insert(botGroup[i])
		botGroup[i]:removeSelf()
	end
	Runtime:removeEventListener("enterFrame", offScreen)
	timer.cancel(createBotsTimer)
	timer.cancel(changeTimeTimer)
	timer.cancel(openDoorsTimer)
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
end


-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene