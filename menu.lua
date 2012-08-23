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

local function delayPlayStoryboard( event )
	storyboard.gotoScene( "play" )
end

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	transition.to(playBtn, { x= 480, time=1000 })
	transition.to(optionsBtn, {x = 240, time=1000 })
	timer.performWithDelay( 1000, delayPlayStoryboard, 1)	
	return true	-- indicates successful touch
end

local function delayOptionsStoryboard( event )
	storyboard.gotoScene("options")
end

local function onOptionButtonRelease()
	transition.to(playBtn, { x= 480, time=1000, alpha=1 })
	transition.to(optionsBtn, {x = 240, time=1000, alpha=1 })
	timer.performWithDelay( 1000, delayOptionsStoryboard, 1)

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
	playBtn = widget.newButton{
		label="play",
		xOffset=-70,
		default="button.png",
		over="button.png",
		width=240, height=320,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn:setReferencePoint(display.TopRightReferencePoint)
	playBtn.x = 480
	playBtn.y = 0

	optionsBtn = widget.newButton{
		label="options",
		xOffset=70,
		default = "options.png",
		over="options.png",
		width=240, height=320,
		onRelease = onOptionButtonRelease
	}
	optionsBtn:setReferencePoint(display.TopRightReferencePoint)
	optionsBtn.x = 240
	optionsBtn.y = 0

	-- display a background image
	local background = display.newImageRect( "images/BackgroundBoundaries.png", display.contentWidth, display.contentHeight )
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0
	
	-- create/position logo/title image on upper-half of the screen
	
	local conveyorBelt = display.newImage("conveyor belt.png")
	conveyorBelt.x = 100
	conveyorBelt.y = 260

	local conveyorBot = display.newImage("conveyor bot.png")
	conveyorBot.x = 0
	conveyorBot.y = 213

	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( conveyorBot )
	group:insert( conveyorBelt )
	group:insert( playBtn )
	group:insert( optionsBtn )
	
	local function openDoors( event )
		transition.to(optionsBtn, {x=100, time=1000})
		transition.to(playBtn, {x=620, time=1000})
	end

	local function moveConveyorBot()
		transition.to(conveyorBot, { x=220, time = 2000 })
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