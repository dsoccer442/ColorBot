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
require("sprite")

local scene = storyboard.newScene()

local botGroup = display.newGroup()
local regionGroup = display.newGroup()
local botDragGroup = display.newGroup()
local blueGroup = display.newGroup()
local greenGroup = display.newGroup()
local redGroup = display.newGroup()
local yellowGroup = display.newGroup()

local BOT_WIDTH = 32
local BOT_HEIGHT = 32
local OFFSET_X = BOT_WIDTH / 2
local OFFSET_Y = BOT_HEIGHT / 2
local ANIMATION_SPEED = 100
local MIN_CREATURES = 1
local MAX_CREATURES = 3
local REGION_WIDTH = 128
local REGION_HEIGHT = 86
local time = 3000
local gameState = true
local livesLeft = 3

local background = display.newImage("images/BackgroundBoundaries.png")
local lives = display.newImage("images/lives 3.png", 20, 295)
local score = display.newText("0", 415, 295,"Helvetica",20)

local random = math.random

local comboDrag
local createBots
local createRectangle
local refreshLives
local regionBounce

local redBotSheet = sprite.newSpriteSheet("images/Robot4Walking.png", BOT_WIDTH, BOT_WIDTH)
local redBotSet = sprite.newSpriteSet(redBotSheet, 1, 10)
local greenBotSheet = sprite.newSpriteSheet("images/Robot1Walking.png", BOT_WIDTH, BOT_WIDTH)
local greenBotSet = sprite.newSpriteSet(greenBotSheet, 1, 10)

local yellowBotSheet = sprite.newSpriteSheet("images/Robot3Walking.png", BOT_WIDTH, BOT_WIDTH)
local yellowBotSet = sprite.newSpriteSet(yellowBotSheet, 1, 10)
local blueBotSheet = sprite.newSpriteSheet("images/Robot2Walking.png", BOT_WIDTH, BOT_WIDTH)
local blueBotSet = sprite.newSpriteSet(blueBotSheet, 1, 10)
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

--local rectangleBoundary = display.newRect(0,0,REGION_WIDTH,REGION_HEIGHT)
--rectangleBoundary:setFillColor(0,0,0,0)
--rectangleBoundary.strokeWidth = 3

createRectangle = function(left,top,width,height,thickness)
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
createRectangle(0,0,REGION_WIDTH,REGION_HEIGHT,3)
createRectangle(480-REGION_WIDTH,0,REGION_WIDTH,REGION_HEIGHT,3)
createRectangle(0,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT,3)
createRectangle(480-REGION_WIDTH,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT,3)

--physics.addBody(rectangleBoundary,"static",{bounce = .5})

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
--#TODO finger offscreen, don't lose

regionBounce = function()
	for i = 1, #botGroup do
		if (botGroup[i].placed and botGroup[i]) then
			local region = regionGroup[botGroup[i].color]
			local bot = botGroup[i]
			vx, vy = botGroup[i]:getLinearVelocity()
			if bot.changedFilter == false then
				bot.changedFilter = true
				physics.removeBody(botGroup[i])
		     	physics.addBody(botGroup[i],{filter = {categoryBits = 4, maskBits = 1}})
		     	botGroup[i].isFixedRotation = true
		     	botGroup[i]:setLinearVelocity(random(-50, 50), random(-50, 50))
		     end
		end
	end
end

function botTouch( event )
	local bot = event.target  

    local phase = event.phase  
    if "began" == phase then  
    	--Runtime:addEventListener("enterFrame", comboListener)
    	event.target:pickup(event.x, event.y)
    	bot.collision = comboDrag
    	bot:addEventListener("collision", bot)
    	table.insert(botDragGroup, bot)
    	physics.removeBody(bot)
      	physics.addBody(bot,{isSensor = true, filter = {categoryBits = 8, maskBits = 2}})
      	bot.isFixedRotation = true
    else  
        if "moved" == phase  then  
        	--Runtime:removeEventListener("enterFrame", comboListener)
            -- bot:move(event.x, event.y)
            for i = 1, #botDragGroup do
            	-- if botDragGroup[i].xScale == 1 then 
            	-- 	botDragGroup[i]:pickup(botDragGroup[i].x,botDragGroup[i].x)
            	-- end
            	botDragGroup[i]:move(event.x, event.y)
            end
            --Runtime:addEventListener("enterFrame", comboListener)
        elseif "ended" == phase or "cancelled" == phase then  
        	--Runtime:removeEventListener("enterFrame", comboListener)
        	-- bot:release()
        	for i = #botDragGroup, 1, -1 do
        		--print("a")
        		if botDragGroup[i] then
	        		
	        		 physics.removeBody(botDragGroup[i])
				    physics.addBody(botDragGroup[i],{bounce = .5, density = 50, filter = {categoryBits = 2, maskBits = 2}})
				    botDragGroup[i].isFixedRotation = true
	        		botDragGroup[i]:release()
	        		botDragGroup[i]:removeEventListener("collision", comboDrag)
	        		table.remove(botDragGroup, i)
        		end
        	end
        end  
    end  
  
    return true  
end

createBots = function()

	local botNumber = random(MIN_CREATURES, MAX_CREATURES)

	for i = 1, botNumber do
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
		--bot.bodyType = "kinematic"  
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

local function offScreen()
	for i = 1, #botGroup do
		if (botGroup[i] and botGroup[i].x and botGroup[i].y) then
			if botGroup[i].x + OFFSET_X < 0 or botGroup[i].x - OFFSET_X > 480 or 
				botGroup[i].y + OFFSET_Y < 0 or botGroup[i].y - OFFSET_Y > 320 then
				botGroup[i]:removeSelf()
				table.remove(botGroup, i)
				refreshLives()
			end
		end
	end
end

--bot:setLinearVelocity( 5, 5 )   

-- local region = display.newImage("images/green.png", 70,70)
-- Region.create(region)
local blueRegion, greenRegion, redRegion, yellowRegion = Region.create()

table.insert(regionGroup,blueRegion)
table.insert(regionGroup,greenRegion)
table.insert(regionGroup,redRegion)
table.insert(regionGroup,yellowRegion)

physics.addBody(blueRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 10}})
physics.addBody(greenRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 10}})
physics.addBody(redRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 10}})
physics.addBody(yellowRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 10}})

local function testCollisions(self, event)
	if (event.other.myName == "bot")  then
		if event.other.drag == false and (event.other.placed == false) then
			if  self.color == event.other.color then
		     	--print(event.other.placed)
		     	
		     	event.other.placed = true

		     	self.alpha = 0
		     	
		     	--event.other.isSensor = true #TODO

		        event.other:removeEventListener("touch", botTouch)
		        transition.to(event.other, {time = 200, x = self.x, y = self.y})
		        timer.performWithDelay(1,regionBounce,1)
		        botGroup:remove(event.other)

		        if event.other.color == 1 then
		        	table.insert(blueGroup, event.other)
		        elseif event.other.color == 2 then
		        	table.insert(greenGroup, event.other)
		        elseif event.other.color == 3 then
		        	table.insert(redGroup, event.other)
		        elseif event.other.color == 4 then
		        	table.insert(yellowGroup, event.other)
		       	end

		       	print(#blueGroup)
		       	if #blueGroup >= 5 then

		       		for i = #blueGroup, 1, -1 do
		       			transition.to(blueGroup[i], {time = 200, x = -16})
		       			livesLeft = livesLeft + #blueGroup
		       		end
		       	elseif #greenGroup >= 5 then
		       		for i = #greenGroup, 1, -1 do
		       			-- greenGroup[i]:removeSelf()
		       			transition.to(greenGroup[i], {time = 200, x = -16})
		       			livesLeft = livesLeft + #greenGroup
		       		end
		       	elseif #redGroup >= 5 then
		       		for i = #redGroup, 1, -1 do
		       			-- redGroup[i]:removeSelf()
		       			transition.to(redGroup[i], {time = 200, x = -16})
		       			livesLeft = livesLeft + #redGroup
		       		end
		       	elseif #yellowGroup >= 5 then
		       		for i = #yellowGroup, 1, -1 do
		       			-- yellowGroup[i]:removeSelf()
		       			transition.to(yellowGroup[i], {time = 200, x = -16})
		       			livesLeft = livesLeft + #yellowGroup
		       		end
		       	end
		    else
		    	refreshLives()
		    	event.other:removeSelf()	
		    	botGroup[event.other] = nil
		    	
		    	--timer.performWithDelay(1,regionBounce,1)
		    	-- table.remove(botGroup, )
		   --  	 local function removeAfterDelay()
			    --     display.remove(event.other)
			    -- end
			 
			    -- timer.performWithDelay(2, removeAfterDelay)
			end
		elseif event.phase == "began" then
			self.alpha = 1
		elseif event.phase == "ended" or event.other.placed then
			self.alpha = 0
		end
	    -- if math.abs(self.x - event.other.x) <= math.abs(self.y -event.other.y) then
	    -- 	transition.to(event.other, {time = 200, x = self.x, y = self.y})
	    -- else
	    -- 	transition.to(event.other, {time = 200, x = self.x, y = self.y})
	    -- end
	end
end

comboDrag = function(self, event )
	-- print("whatever2")
	local bot = event.other
	if event.other.myName == "bot" and bot.drag == false and self.drag == true then
		if self.color == bot.color then
			--if bot.placed == false then
					-- botGroup[j]:setLinearVelocity(0, 0)
					bot.drag = true

					
					bot:pickup(bot.x, bot.y)
					bot.collision = comboDrag
					bot:addEventListener("collision", bot)
					table.insert(botDragGroup, bot)
					--timer.performWithDelay(1,pickupBot,1)
			--end						
		end
	end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	group:insert(background)
	background:toBack()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	createBotsTimer = timer.performWithDelay( time, createBots, 0 )
	changeTimeTimer = timer.performWithDelay( 10000, changeCreateBotsTime, 0 )

	
	for i = 1, #regionGroup do
		group:insert(regionGroup[i])
	end
	
	for i = 1, #regionGroup do
		regionGroup[i].collision = testCollisions
		regionGroup[i]:addEventListener("collision", regionGroup[i])
	end

	Runtime:addEventListener("enterFrame", offScreen)
	--Runtime:addEventListener("enterFrame", comboDrag)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	for i = 1, #regionGroup do
		regionGroup[i]:removeEventListener("collision", regionGroup[i])
	end
	Runtime:removeEventListener("enterFrame", offScreen)
	--Runtime:removeEventListener("enterFrame", comboDrag)
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