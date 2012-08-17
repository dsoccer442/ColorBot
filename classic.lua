----------------------------------------------------------------------------------
--
-- classic.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local Bot = require("bot")
local Region = require("region")
local physics = require("physics")
local scene = storyboard.newScene()

local time = 3000
local gameState = true
local botGroup = display.newGroup()

local BOT_WIDTH = 30
local BOT_HEIGHT = 16
local OFFSET_X = BOT_WIDTH / 2
local OFFSET_Y = BOT_HEIGHT / 2

physics.start()

-- rectangle based
local function hasCollided(obj1, obj2)
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

local function createCreatures()
	local creature
	local color = math.random(1, 4)
	
	if color == 1 then
		creature = display.newImage( "images/blue creature.png", 240, 160 )
		creature.color = 1
		--table.insert( creatureGroup, creature )
	elseif color == 2 then
		creature = display.newImage( "images/green creature.png", 240, 160 )
		creature.color = 2
		--table.insert( creatureGroup, creature )
	elseif	color == 3 then
		creature = display.newImage( "images/purple creature.png", 240, 160 )
		creature.color = 3
		--table.insert( creatureGroup, creature )
	elseif color == 4 then
		creature = display.newImage( "images/yellow creature.png", 240, 160 )
		creature.color = 4
		--table.insert( creatureGroup, creature )
	end

	table.insert(botGroup, creature)
	physics.addBody(creature, {density=.8, friction=.3, bounce=.6, radius=10})
	creature.bodyType = "kinematic"  
	Bot.create(creature)
	creature:setLinearVelocity(math.random(-40, 40), math.random(-40, 40 ))
	creature.myName = creature
end
 
local function changeCreateCreaturesTime()
	if time > 1000 then 
		time = time - 50
	elseif time > 500 then
		time = time * .9
	end
	timer.pause(createCreaturesTimer)
	createCreaturesTimer = timer.performWithDelay(time, createCreatures, 0)
	print(time)
end

local function offScreen()
	for i = 1, #botGroup do
		if botGroup[i].x + OFFSET_X < 0 or botGroup[i].x - OFFSET_X > 480 or 
			botGroup[i].y + OFFSET_Y < 0 or botGroup[i].y - OFFSET_Y > 320 then
			botGroup:remove(botGroup[i])
			botGroup[i]:removeSelf()
			--botGroup[i]:removeSelf()
			print("test")
		end
	end
end
-- local bot = display.newImage("images/blue.png")
-- physics.addBody(bot, {density=.8, friction=.3, bounce=.6, radius=10})
-- bot.bodyType = "kinematic"  
-- Bot.create(bot)

--bot:setLinearVelocity( 5, 5 )   

local region = display.newImage("images/green.png", 70,70)
Region.create(region)


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	createCreaturesTimer = timer.performWithDelay( time, createCreatures, 0 )
	changeTimeTimer = timer.performWithDelay( 10000, changeCreateCreaturesTime, 0 )

	--group:insert(bot)
	--group:insert(region)

	local function testCollisions()
	    for i=1, #objects do
	         if hasCollided(bot, region) then
	         	if bot.drag == false then
	             --print("collision")
	             Runtime:removeEventListener("enterFrame", testCollisions)
	             bot:removeEventListener("touch", bot)
	             transition.to(bot, {time = 1000, x = region.x, y = region.y})
	             -- transition.to(bot, {time = 1000, x = 0, y = 0})
	             -- do what you need to do if they hit each other
	            end
	         end
	    end
	end
	--Runtime:addEventListener("enterFrame", testCollisions)
	Runtime:addEventListener("enterFrame", offScreen)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
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