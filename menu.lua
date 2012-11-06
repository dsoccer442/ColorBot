-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn
local optionsBtn
local playText
local optionsText
local background
local conveyorBelt
local conveyorBot
local doorA
local doorR

local function delayPlayStoryboard( event )
	storyboard.gotoScene( "play" )
end

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	transition.to(doorR, { x=240, time=700 } )
	transition.to(doorA, { x=480, time=700 } )
	timer.performWithDelay( 700, delayPlayStoryboard, 1)

	playBtn.onRelease = nil	

	playBtn.onRelease = nil

	return true	-- indicates successful touch
end

local function delayOptionsStoryboard( event )
	storyboard.gotoScene("options")
end

local function onOptionButtonRelease()
	transition.to(doorR, { x=240, time=700 } )
	transition.to(doorA, { x=480, time=700 } )
	timer.performWithDelay( 700, delayOptionsStoryboard, 1)
	optionsBtn.onRelease = nil
	return true
end
-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view



	-- create a widget button (which will loads level1.lua on release)
	
	doorA = display.newImage("DoorA.png")
	doorA:setReferencePoint(display.TopRightReferencePoint)
	doorA.x = 480

	doorR = display.newImage("DoorR.png")
	doorR:setReferencePoint(display.TopRightReferencePoint)
	doorR.x =  240


	playBtn = widget.newButton{
		default="PlayButton.png",
		over="PlayButton.png",
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = 420

	optionsBtn = widget.newButton{
		default = "OptionsButton.png",
		over="OptionsButton.png",
		onRelease = onOptionButtonRelease
	}
	optionsBtn.x = 60
	
	-- create/position logo/title image on upper-half of the screen
	
	local conveyorBelt = display.newImage("conveyor belt.png")

	local conveyorBot = display.newImage("conveyor bot.png")
	conveyorBot.x = 0
	conveyorBot.y = 195

	-- all display objects must be inserted into group
	group:insert( conveyorBelt )
	group:insert( conveyorBot )
	group:insert( playBtn )
	group:insert( optionsBtn )
	group:insert( doorR )
	group:insert( doorA )
	
	local function openDoors( event )
		transition.to(doorR, {x=22, time=700 } )
		transition.to(doorA, {x=698, time=700 } )
		return true
	end

	local function moveConveyorBot()
		transition.to(conveyorBot, { x=190, time = 2000 })
		print("conveyorBot")
	end

	timer.performWithDelay(100, openDoors, 1)
	timer.performWithDelay(200, moveConveyorBot, 1)	
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.removeAll()
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	group:removeSelf()
	group = nil

	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
		optionsBtn:removeSelf()
		optionsBtn = nil
	end
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "purgeScene", scene )

-----------------------------------------------------------------------------------------

return scene