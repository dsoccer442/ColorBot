module(..., package.seeall)
local addFunctions
local transparency = 100
local REGION_WIDTH = 128
local REGION_HEIGHT = 86
RegionGroup = display.newGroup()

function create()
	local blueRegion = display.newRect(0,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT)
	local greenRegion = display.newRect( 480-REGION_WIDTH,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT)
	local redRegion = display.newRect( 0,0,REGION_WIDTH,REGION_HEIGHT)
	local yellowRegion = display.newRect( 480-REGION_WIDTH,0,REGION_WIDTH,REGION_HEIGHT)

	blueRegion:setFillColor(31,150,250,transparency)
	greenRegion:setFillColor(14,174,93,transparency)
	redRegion:setFillColor(255,0,0,transparency)
	yellowRegion:setFillColor(255,204,0,transparency)

	table.insert(RegionGroup, blueRegion)
	table.insert(RegionGroup, greenRegion)
	table.insert(RegionGroup, redRegion)
	table.insert(RegionGroup, yellowRegion)

	for i = 1, #RegionGroup do
		RegionGroup[i].strokeWidth = 0
		RegionGroup[i].color = i
		addFunctions(RegionGroup[i])
		RegionGroup[i].myName = "region"
		RegionGroup[i].alpha = .01
		-- RegionGroup[i]:addEventListener("touch", RegionGroup[i])
		--RegionGroup[i]:setReferencePoint(display.topLeftReferencePoint)
		--RegionGroup[i].isVisible = false
	end

	return blueRegion,greenRegion,redRegion,yellowRegion
end

addFunctions = function(obj)
	function obj:purge()

	end
	-- function RegionGroup[i]:touch(event)
	-- 	print("meanie")
	-- 	if event.phase == "began" then
	-- 		RegionGroup[i].alpha = transparency
	-- 	elseif event.phase == "ended" or "canceled" then
	-- 		RegionGroup[i].alpha = transparency
	-- 	end
	-- end	
end