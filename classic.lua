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

local refreshLives
local regionBounce
local regionVisible
local botBounce
local hasCollided

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

local function createRectangle(left,top,width,height,thickness)
	local upSide = display.newRect(left,top,width,thickness)
	local leftSide = display.newRect(left,top,thickness,height)
	local rightSide = display.newRect(left+width,top,thickness,height)
	local downSide = display.newRect(left,top+height,width,thickness)
	boundsFilter = {categoryBits = 1, maskBits = 5}
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

regionVisible = function(event)
	for j = 1, #regionGroup do
		for i = 1, #botGroup do
			if botGroup[i] and botGroup[i].x and botGroup[i].y then
			-- if (botGroup[i].drag) then
				--print(hasCollided(botGroup[i], regionGroup[j]))
			-- end
				if hasCollided(botGroup[i], regionGroup[j]) and botGroup[i].drag == true  then
					regionGroup[j].alpha = 1
					break		
				end
				regionGroup[j].alpha = 0
			end
		end
	end
end

regionBounce = function()
	for i = 1, #botGroup do
		if (botGroup[i] and botGroup and botGroup[i].placed) then
			local region = regionGroup[botGroup[i].color]
			vx, vy = botGroup[i]:getLinearVelocity()
			if botGroup[i].placed and botGroup[i].changedFilter == false then
				botGroup[i].changedFilter = true
				physics.removeBody(botGroup[i])
		     	physics.addBody(botGroup[i],{filter = {categoryBits = 4, maskBits = 3}})
		     	botGroup[i].isFixedRotation = true
		     	botGroup[i]:setLinearVelocity( math.random(-50, 50), math.random(-50, 50))
		     end
		end
	end
end

-- rectangle based
hasCollided = function(obj1, obj2)
    if obj1 == nil then
        return false
    end
    if obj2 == nil then
        return false
    end
    local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
    local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
    local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
    local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax
    return (left or right) and (up or down)
end

hasFullyCollided = function(obj1, obj2)
    --obj1 = smaller
    if obj1 == nil then
        return false
    end
    if obj2 == nil then
        return false
    end
   
    local x = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMax <= obj2.contentBounds.xMax
    local y = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMax
    return (x and y)
end

-- circle based
local function hasCollidedCircle(obj1, obj2)
    if obj1 == nil then
        return false
    end
    if obj2 == nil then
        return false
    end
    local sqrt = math.sqrt

    local dx =  obj1.x - obj2.x;
    local dy =  obj1.y - obj2.y;

    local distance = sqrt(dx*dx + dy*dy);
    local objectSize = (obj2.contentWidth/2) + (obj1.contentWidth/2)
    if distance < objectSize then
        return true
    end
    return false
end

local function virtualPointCreator(x,y)
	return display.newRect(x,y,0,0)
end

function botTouch( event )
		
	local bot = event.target  

    local phase = event.phase  
    if "began" == phase then  
    	--Runtime:addEventListener("enterFrame", comboListener)
    	event.target:pickup(event.x, event.y)
    	table.insert(botDragGroup, bot)
    else  
        if "moved" == phase  then  
        	--Runtime:removeEventListener("enterFrame", comboListener)
            -- bot:move(event.x, event.y)
            for i = 1, #botDragGroup do
            	botDragGroup[i]:move(event.x, event.y)
            end
            --Runtime:addEventListener("enterFrame", comboListener)
        elseif "ended" == phase or "cancelled" == phase then  
        	--Runtime:removeEventListener("enterFrame", comboListener)
        	-- bot:release()
        	for i = 1, #botDragGroup do
        		botDragGroup[i]:release()
        	end
        end  
    end  
  
    return true  
end

local function createBots()

	local botNumber = math.random(MIN_CREATURES, MAX_CREATURES)

	for i = 1, botNumber do
		local bot
		
		local color = math.random(1, 4)
		
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
		physics.addBody(bot,{bounce = .5, density = 50, filter = {categoryBits = 2, maskBits = 2}})
		bot.isFixedRotation = true
		--bot.bodyType = "kinematic"  
		Bot.create(bot)
		bot:setLinearVelocity(math.random(-70, 70), math.random(-70, 70 ))

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

physics.addBody(blueRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 2}})
physics.addBody(greenRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 2}})
physics.addBody(redRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 2}})
physics.addBody(yellowRegion,{isSensor = true, filter = {categoryBits = 2, maskBits = 2}})

local function testCollisions(self, event)
	if (event.other.myName == "bot") and (self.myName == "region") and (event.other.placed == false) and event.other.drag == false then
		if  self.color == event.other.color then
	     	--print("hallelujah")
	     	
	     	event.other.placed = true
	     	
	     	--event.other.isSensor = true #TODO
	        event.other:removeEventListener("touch", event.other)
	        transition.to(event.other, {time = 200, x = self.x, y = self.y})
	    else
	    	refreshLives()
	    	event.other:removeSelf()	
	    	botGroup[event.other] = nil
	    	
	    	--timer.performWithDelay(1000,listener)
	    	-- table.remove(botGroup, )
	   --  	 local function removeAfterDelay()
    --     display.remove(event.other)
    -- end
 
    -- timer.performWithDelay(2, removeAfterDelay)

	    end
	    -- if math.abs(self.x - event.other.x) <= math.abs(self.y -event.other.y) then
	    -- 	transition.to(event.other, {time = 200, x = self.x, y = self.y})
	    -- else
	    -- 	transition.to(event.other, {time = 200, x = self.x, y = self.y})
	    -- end
	end
end

local function comboDrag()
	for i = 1, #botGroup do
		for j = 1, #botGroup do
			if botGroup[i] and botGroup[j] and botGroup[i].x and botGroup[j].x then
				if hasCollided(botGroup[i], botGroup[j]) and ( (botGroup[i] == botGroup[j]) == false ) then
					if botGroup[i].color == botGroup[j].color then
						if botGroup[i].placed == false and botGroup[j].placed == false then
							if botGroup[i].drag == true and botGroup[j].drag == false then
								-- botGroup[j]:setLinearVelocity(0, 0)
								botGroup[j].drag = true
								botGroup[j]:pickup(botGroup[j].x, botGroup[j].y)
								table.insert(botDragGroup, botGroup[j])
							end
							if botGroup[j].drag == true and botGroup[i].drag == false then
								-- botGroup[i]:setLinearVelocity(0, 0)
								botGroup[i].drag = true
								botGroup[i]:pickup(botGroup[i].x, botGroup[i].y)
								table.insert(botDragGroup, botGroup[i])
							end
						end						
					end
				end
			end
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

	-- local function testCollisions(self,event)
 --         if event.other.myName == "bot" then
 --         	--print(hasCollided(event.other, self))
 --         end
 --         if (event.other.myName == "bot") and (event.other.placed == false) and (event.other.drag == false and hasFullyCollided(self, event.other)) then
 --         	print("hallelujah")
 --         	event.other.placed = true
 --            event.other:removeEventListener("touch", event.other)
 --        end
	-- end
	
	for i = 1, #regionGroup do
		regionGroup[i].collision = testCollisions
		-- regionGroup[i].touch = regionVisible
		regionGroup[i]:addEventListener("collision", regionGroup[i])
		-- Runtime:addEventListener("touch", regionVisible)
	end
	--  for i = 1, #botGroup do

	-- botGroup[i]:addEventListener("touch", regionVisible)
	-- end
	--Runtime:addEventListener("collision",testCollisions)
	Runtime:addEventListener("enterFrame", offScreen)
	Runtime:addEventListener("enterFrame", regionBounce)
	Runtime:addEventListener("enterFrame",regionVisible)
	Runtime:addEventListener("enterFrame", comboDrag)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	for i = 1, #regionGroup do
		regionGroup[i]:removeEventListener("collision", regionGroup[i])
	end
	-- for i = #botGroup, 1 do
	-- 	group:insert(botGroup[i])
	-- end
	Runtime:removeEventListener("enterFrame", offScreen)
	Runtime:removeEventListener("enterFrame", regionBounce)
	Runtime:removeEventListener("enterFrame", comboDrag)
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