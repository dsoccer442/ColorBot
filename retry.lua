----------------------------------------------------------------------------------
--
-- retry.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require("widget")
local scene = storyboard.newScene()

-- local background = display.newImage("images/BackgroundBoundaries.png")
local scoreText = display.newText(storyboard.score, 240, 150, native.systemFontBold, 40)
local retryButton = widget.newButton{
	label = "RETRY",
	onRelease = function() storyboard.gotoScene("classic") end
}
----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local menuBtn
local retryBtn
local scoreDisplay
local scoreText
local scoreNumber


local function delayRetryStoryboard( event )
	storyboard.gotoScene( "classic" )
end

local function delayMenuStoryboard( event )
	storyboard.gotoScene( "menu" )
end

local function onRetryButtonRelease()
	transition.to(menuBtn, {})
	transition.to(retryBtn, {})
	timer.performWithDelay( 1000, delayRetryStoryboard, 1 )
	retryBtn.onRelease = nil
	return true
end

local function onMenuButtonRelease()
	transition.to(menuBtn, {})
	transition.to(retryBtn, {})
	timer.performWithDelay( 1000, delayMenuStoryboard, 1 )
	menuBtn.onRelease = nil
	return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
<<<<<<< HEAD

	menuBtn = widget.newButton{
	default="DoorR.png",
	over="DoorR.png",
	width=240, height=320,
	onRelease = onMenuButtonRelease
	}

	retryBtn = widget.newButton{
	default="DoorA.png",
	default="DoorA.png",
	width=240, height=320,
	onRelease=onRetryButtonRelease
	}

	scoreDisplay = display.newRect(0, 0, 480, 320)

	scoreNumber = 4

	scoreText = display.newRetinaText("score:"..scoreNumber, 0, 0, native.systemFont, 36)

=======
	-- group:insert(background)
	group:insert(scoreText)
	group:inert(retryButton)
>>>>>>> four doors
	-----------------------------------------------------------------------------
		
	--	CREATE display objects and add them to 'group' here.
	--	Example use-case: Restore 'group' from previously saved state.
	
	-----------------------------------------------------------------------------
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
		storyboard.removeScene("classic")
	
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