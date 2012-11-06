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

splashTimer = timer.performWithDelay(1000, main, 1)
splash:addEventListener("touch", main)