----------------------------------------------------------------------------------
-- OPTIONS.LUA
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require "widget"

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local sfxBtn
local sfxBtnOff
local musicBtn
local musicBtnOff
local backBtn
local doorA
local doorR
local sfxLabel
local musicLabel
local backBtn

local function delayMenuStoryboard( event )
	storyboard.gotoScene("menu")
end

local function onBackBtnRelease( event )
	transition.to(doorR, { x=240, time=700 } )
	transition.to(doorA, { x=480, time=700 } )
	timer.performWithDelay( 700, delayMenuStoryboard, 1 )
	backBtn.onRelease = nil
	return true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	local function openDoors()
		transition.to(doorR, {x=22, time=700 } )
		transition.to(doorA, {x=698, time=700 } )
		return true
	end

	sfxBtn = display.newImage("on button.png", 0, 0)
	sfxBtn.x = display.contentWidth/2
	sfxBtn.y = 80
	sfxBtn:setReferencePoint(display.CenterReferencePoint)

	sfxBtnOff = display.newImage("off button.png")
	sfxBtnOff.x = display.contentWidth/2
	sfxBtnOff.y = 80
	sfxBtnOff:setReferencePoint(display.CenterReferencePoint)
	sfxBtnOff.isVisible = false

	sfxLabel = display.newRetinaText("SFX", 140, 60, native.systemFont, 36)

	musicBtn = display.newImage("on button.png", 0, 0)
	musicBtn.x = display.contentWidth/2
	musicBtn.y = 140
	musicBtn:setReferencePoint(display.CenterReferencePoint)

	musicBtnOff = display.newImage("off button.png")
	musicBtnOff.x = display.contentWidth/2
	musicBtnOff.y = 140
	musicBtnOff:setReferencePoint(display.CenterReferencePoint)
	musicBtnOff.isVisible = false

	musicLabel = display.newRetinaText("Music", 100, 120, native.systemFont, 36)

	backBtn = widget.newButton{
		default="BackButton.png",
		over="BackButton.png",
		onRelease = onBackBtnRelease
	}
	backBtn.x = 130

	doorA = display.newImage("DoorA.png")
	doorA:setReferencePoint(display.TopRightReferencePoint)
	doorA.x = 480

	doorR = display.newImage("DoorR.png")
	doorR:setReferencePoint(display.TopRightReferencePoint)
	doorR.x =  240


	timer.performWithDelay( 100, openDoors, 1 )

	group:insert(sfxBtn)
	group:insert(sfxBtnOff)
	group:insert(musicBtn)
	group:insert(musicBtnOff)
	group:insert(sfxLabel)
	group:insert(musicLabel)
	group:insert(backBtn)
	group:insert(doorA)
	group:insert(doorR)

	local function changeSfx( event )
		if sfxBtn.isVisible == true then
			sfxBtnOff.isVisible = true
			sfxBtn.isVisible = false
		elseif sfxBtnOff.isVisible == true then
			sfxBtnOff.isVisible = false
			sfxBtn.isVisible = true		
		end
	end

	sfxBtn:addEventListener( "tap", changeSfx )
	sfxBtnOff:addEventListener( "tap", changeSfx )

	local function changeMusic( event )
		if musicBtn.isVisible == true then
			musicBtnOff.isVisible = true
			musicBtn.isVisible = false
		elseif musicBtnOff.isVisible == true then
			musicBtnOff.isVisible = false
			musicBtn.isVisible = true		
		end
	end

	musicBtn:addEventListener( "tap", changeMusic )
	musicBtnOff:addEventListener( "tap", changeMusic )
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