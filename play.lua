----------------------------------------------------------------------
-- PLAY.lua
----------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require "widget"

local doorA
local doorR
local classicBtn
local arcadeBtn
local backBtn

local function delayMenuStoryboard( event )
	storyboard.gotoScene("menu")
	return true
end

local function onBackBtnRelease( event )
<<<<<<< HEAD
	transition.to(classicBtn, { x=240, time=1000 } )
	transition.to(arcadeBtn, { x=480, time=1000 } )
	timer.performWithDelay( 1000, delayMenuStoryboard, 1 )
=======
	transition.to(doorR, { x=240, time=700 } )
	transition.to(doorA, { x=480, time=700 } )
	timer.performWithDelay( 700, delayMenuStoryboard, 1)
>>>>>>> four doors
	backBtn.onRelease = nil
	return true
end

local function delayClassicStoryboard( event )
	storyboard.gotoScene("classic")
end

local function onClassicBtnRelease( event )

	transition.to(doorR, { x=240, time=700 } )
	transition.to(doorA, { x=480, time=700 } )
	timer.performWithDelay( 700, delayClassicStoryboard, 1)
	classicBtn.onRelease = nil
	return true
end

local function onArcadeBtnRelease( event )
	transition.to(doorR, { x=240, time=700 } )
	transition.to(doorA, { x=480, time=700 } )
	timer.performWithDelay( 700, delayClassicStoryboard, 1)
	arcadeBtn.onRelease = nil
	return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

<<<<<<< HEAD
	local function openDoors()
		transition.to(classicBtn, {x=22, time=1000 } )
		transition.to(arcadeBtn, {x=698, time=1000 } )
=======
	local function openDoors( event )
		transition.to(doorR, {x=22, time=700 } )
		transition.to(doorA, {x=698, time=700 } )
>>>>>>> four doors
		return true
	end

	backBtn = widget.newButton{
<<<<<<< HEAD
		default="backsmall.png",
		over="backsmall.png",
		width=50,
		height=50,
=======
		default="BackButton.png",
		over="BackButton.png",
>>>>>>> four doors
		onRelease = onBackBtnRelease
	}
	backBtn:setReferencePoint(display.CenterReferencePoint)
	backBtn.x = display.contentWidth/2
	backBtn.y = display.contentHeight/2

	doorA = display.newImage("DoorA.png")
	doorA:setReferencePoint(display.TopRightReferencePoint)
	doorA.x = 480

	doorR = display.newImage("DoorR.png")
	doorR:setReferencePoint(display.TopRightReferencePoint)
	doorR.x =  240

	classicBtn = widget.newButton{
<<<<<<< HEAD
		default="DoorR.png",
		over="DoorR.png",
		width=240, height=320,
=======
		default="ClassicButton.png",
		over="ClassicButton.png",
>>>>>>> four doors
		onRelease = onClassicBtnRelease
	}
	classicBtn:setReferencePoint(display.TopLeftReferencePoint)
	classicBtn.x = 22

	arcadeBtn = widget.newButton{
<<<<<<< HEAD
		default="DoorA.png",
		over="DoorA.png",
		width=240, height=320,
=======
		default="ArcadeButton.png",
		over="ArcadeButton.png",
>>>>>>> four doors
		onRelease = onArcadeBtnRelease
	}
	arcadeBtn:setReferencePoint(display.TopRightReferencePoint)
	arcadeBtn.x = 480-22
	arcadeBtn.y = 0

	timer.performWithDelay( 100, openDoors, 1 )

	group:insert(backBtn)
	group:insert(arcadeBtn)
	group:insert(classicBtn)
	group:insert(doorR)
	group:insert(doorA)
	
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