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

local scene = storyboard.newScene()

local botGroup = {}
local regionGroup = display.newGroup()
local botDragGroup = {}
local blueGroup = {}
local greenGroup = {}
local redGroup = {}
local yellowGroup = {}

local BOT_WIDTH = 32
local BOT_HEIGHT = 32
local OFFSET_X = BOT_WIDTH * 0.5
local OFFSET_Y = BOT_HEIGHT * 0.5
local ANIMATION_SPEED = 100
local MIN_CREATURES = 1
local MAX_CREATURES = 3
local REGION_WIDTH = 128
local REGION_HEIGHT = 86
local time = 3000
local gameState = true
local livesLeft = 3
-- Slash line properties (line that shows up when you move finger across the screen)
local maxPoints = 5
local lineThickness = 15
local lineFadeTime = 250
local endPoints = {}

local background = display.newImage("images/BackgroundBoundaries.png")
local lives = display.newImage("images/lives 3.png", 20, 295)
local score = display.newText("0", 415, 295,"Helvetica",20)

local random = math.random

local comboDrag
local createBots
local createBoundary
local refreshLives
local regionBounce

local blueRegion, greenRegion, redRegion, yellowRegion = Region.create()

local redBotSheet = sprite.newSpriteSheet("images/Robot4Walking.png", BOT_WIDTH, BOT_WIDTH)
local redBotSet = sprite.newSpriteSet(redBotSheet, 1, 10)
local greenBotSheet = sprite.newSpriteSheet("images/Robot1Walking.png", BOT_WIDTH, BOT_WIDTH)
local greenBotSet = sprite.newSpriteSet(greenBotSheet, 1, 10)

local yellowBotSheet = sprite.newSpriteSheet("images/Robot3Walking.png", BOT_WIDTH, BOT_WIDTH)
local yellowBotSet = sprite.newSpriteSet(yellowBotSheet, 1, 10)
local blueBotSheet = sprite.newSpriteSheet("images/Robot2Walking.png", BOT_WIDTH, BOT_WIDTH)
local blueBotSet = sprite.newSpriteSet(blueBotSheet, 1, 10)

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
	livesLeft = livesLeft - 1
	lives:removeSelf()
	if livesLeft > 0 then
		if livesLeft == 2 then
			lives = display.newImage("images/lives 2.png")
		elseif livesLeft == 1 then
			lives = display.newImage("images/lives 1.png")
		end
	else
		lives = display.newImage("images/lives 0.png")
		storyboard.gotoScene("retry", "fade", 800)
	end
end

regionBounce = function()
	for i = 1, #botGroup do
		local bot = botGroup[i]
		if bot then
			if bot.placed then
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
    	bot.collision = comboDrag
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
  			if regionGroup[botDragGroup[1].color].alpha == 1 then
	  			local comboGroup = display.newGroup()
	  			display.newText(comboGroup,"COMBO", botDragGroup[1].x, botDragGroup[1].y, native.systemFontBold, 15)
	  			display.newText(comboGroup,"+"..#botDragGroup, botDragGroup[1].x+15, botDragGroup[1].y+15, native.systemFontBold, 15)
	  			transition.to(comboGroup, {time = 200, x = self.x, y = self.y})
  			end
  		end
    	for i = #botDragGroup, 1, -1 do
    		local dragBot = botDragGroup[i]
    		if dragBot then
        		physics.removeBody(dragBot)
			    physics.addBody(dragBot,{bounce = .5, density = 50, filter = {categoryBits = 2, maskBits = 10}})
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

createBots = function()

	--local botNumber = random(MIN_CREATURES, MAX_CREATURES)

	for i = 1, random(MIN_CREATURES, MAX_CREATURES) do
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
		bot.x, bot.y = 240, 160
		--bot:toBack()
		--background:toBack() --FIX THIS YOU IDIOT #TODO

		table.insert(botGroup, bot)
		physics.addBody(bot,{bounce = .5, density = 50, filter = {categoryBits = 2, maskBits = 10}})
		bot.isFixedRotation = true
		Bot.create(bot)
		bot:setLinearVelocity(random(-70, 70), random(-70, 70 ))

		bot.myName = "bot"
	end
end
 
local function changeCreateBotsTime()
	if time > 1000 then 
		time = time - 50
	elseif time > 500 then
		time = time * .9
	end
	timer.pause(createBotsTimer)
	createBotsTimer = timer.performWithDelay(time, createBots, 0)
	print(time) --#TODO
end

local group2 = display.newGroup()
local function offScreen()
	for i = 1, #botGroup do
		local bot = botGroup[i]
		if (bot and bot.x and bot.y) then
			if bot.x + OFFSET_X < 0 or bot.x - OFFSET_X > 480 or 
				bot.y + OFFSET_Y < 0 or bot.y - OFFSET_Y > 320 then
				if bot.placed == false then
					refreshLives()
				end
				bot:removeSelf()
				table.remove(botGroup, i)
				return
			end
			-- if bot.placed then
			-- 	print(#botGroup)
			-- 	table.remove(botGroup, i)
			-- 	print(#botGroup)
			-- end
		end
	end
end

local function testCollisions(self, event)
	local bot = event.other
	if (bot.myName == "bot")  then
		if bot.drag == false and (bot.placed == false) then
			if  self.color == bot.color then
		     	
		     	bot.placed = true
		     	self:lightUp()

		        bot:removeEventListener("touch", botTouch)
		        transition.to(bot, {time = 200, x = self.x, y = self.y})
		        timer.performWithDelay(1,regionBounce,1)

		        if bot.color == 1 then
		        	-- print(#botGroup)
		        	table.insert(blueGroup, bot)
		        	-- print(#botGroup)
		        elseif bot.color == 2 then
		        	table.insert(greenGroup, bot)
		        elseif bot.color == 3 then
		        	table.insert(redGroup, bot)
		        elseif bot.color == 4 then
		        	table.insert(yellowGroup, bot)
		       	end

		       	if #blueGroup >= 5 then
		       		
		       		for i = #blueGroup, 1, -1 do
		       			transition.to(blueGroup[i], {time = 200, x = -16})
		       			table.remove(blueGroup, i)

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

		       	-- botGroup:remove(bot)
		    else
		    	-- botGroup:remove(bot)
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

comboDrag = function(self, event )
	local bot = event.other
	if bot.myName == "bot" and bot.drag == false and self.drag == true then
		if self.color == bot.color then
			bot:pickup(bot.x, bot.y)
			bot.collision = comboDrag
			bot:addEventListener("collision", bot)
			table.insert(botDragGroup, bot)	
		end
	end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	group:insert(background)
	background:toBack()

	sprite.add(redBotSet, "walking", 1,3,ANIMATION_SPEED,0)
	sprite.add(greenBotSet, "walking", 1,3,ANIMATION_SPEED,0)
	sprite.add(yellowBotSet, "walking", 1,3,ANIMATION_SPEED,0)
	sprite.add(blueBotSet, "walking", 1,3,ANIMATION_SPEED,0)

	sprite.add(redBotSet, "drag", 6,5,ANIMATION_SPEED,0)
	sprite.add(greenBotSet, "drag", 6,5,ANIMATION_SPEED,0)
	sprite.add(yellowBotSet, "drag", 6,5,ANIMATION_SPEED,0)
	sprite.add(blueBotSet, "drag", 6,5,ANIMATION_SPEED,0)

	physics.start()
	physics.setGravity(0,0)

	createBoundary(0,0,REGION_WIDTH,REGION_HEIGHT,3)
	createBoundary(480-REGION_WIDTH,0,REGION_WIDTH,REGION_HEIGHT,3)
	createBoundary(0,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT,3)
	createBoundary(480-REGION_WIDTH,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT,3)

	table.insert(regionGroup,blueRegion)
	table.insert(regionGroup,greenRegion)
	table.insert(regionGroup,redRegion)
	table.insert(regionGroup,yellowRegion)

	physics.addBody(blueRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 10}})
	physics.addBody(greenRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 10}})
	physics.addBody(redRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 10}})
	physics.addBody(yellowRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 10}})
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	createBotsTimer = timer.performWithDelay( time, createBots, 0 )
	changeTimeTimer = timer.performWithDelay( 10000, changeCreateBotsTime, 0 )

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
	end
	Runtime:removeEventListener("enterFrame", offScreen)
	timer.cancel(createBotsTimer)
	timer.cancel(createBotsTimer)
	timer.cancel(changeTimeTimer)
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