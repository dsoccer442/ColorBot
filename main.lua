-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
display.setStatusBar(display.HiddenStatusBar)

local storyboard = require "storyboard"

splash = display.newImage("splash.png")

local function main()
	timer.pause(splashTimer)
   splash:removeEventListener("touch", main)
   splash:removeSelf()
   splash = nil
   storyboard.gotoScene( "menu" )
end

<<<<<<< HEAD
splashTimer = timer.performWithDelay(2500, main, 1)
=======
splashTimer = timer.performWithDelay(1000, main, 1)
>>>>>>> four doors
splash:addEventListener("touch", main)