----------------------------------------------------------------------
-- PLAY.lua
----------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require "widget"


local classicBtn
local arcadeBtn
local backBtn

local function delayMenuStoryboard( event )
	storyboard.gotoScene("menu")
	return true
end

local function onBackBtnRelease( event )
	transition.to(classicBtn, { x=240, time=1000 } )
	transition.to(arcadeBtn, { x=480, time=1000 } )
	timer.performWithDelay( 1000, delayMenuStoryboard, 1 )
	return true
end

local function delayClassicStoryboard( event )
	storyboard.gotoScene("classic")
end

local function onClassicBtnRelease( event )
	transition.to(classicBtn, { x=240, time=1000})
	transition.to(arcadeBtn, { x=480, time=1000})
	timer.performWithDelay( 1000, delayClassicStoryboard, 1)
	return true
end

local function onArcadeBtnRelease( event )
	transition.to(classicBtn, { x=240, time=1000})
	transition.to(arcadeBtn, { x=480, time=1000})
	timer.performWithDelay( 1000, delayClassicStoryboard, 1)
	return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	local function openDoors()
		transition.to(classicBtn, {x=100, time=1000 } )
		transition.to(arcadeBtn, {x=620, time=1000 } )
		return true
	end

	backBtn = widget.newButton{
		label="back",
		default="backsmall.png",
		over="backsmall.png",
		width=50,
		height=50,
		onRelease = onBackBtnRelease
	}
	backBtn.x = 200
	backBtn.y = 120

	classicBtn = widget.newButton{
		label="classic",
		xOffset=70,
		default="classic.png",
		over="classic.png",
		width=240, height=320,
		onRelease = onClassicBtnRelease
	}
	classicBtn:setReferencePoint(display.TopRightReferencePoint)
	classicBtn.x = 240
	classicBtn.y = 0

	arcadeBtn = widget.newButton{
		label="arcade",
		xOffset=-70,
		default="arcade.png",
		over="arcade.png",
		width=240, height=320,
		onRelease = onArcadeBtnRelease
	}
	arcadeBtn:setReferencePoint(display.TopRightReferencePoint)
	arcadeBtn.x = 480
	arcadeBtn.y = 0

	timer.performWithDelay( 100, openDoors, 1 )

	group:insert(backBtn)
	group:insert(arcadeBtn)
	group:insert(classicBtn)
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.removeAll()
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

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