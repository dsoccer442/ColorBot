module(..., package.seeall)
local addFunctions
local transparency = 100
local REGION_WIDTH = 125
local REGION_HEIGHT = 83
RegionGroup = {}

function create()
	local blueRegion = display.newRect(0,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT)
	local greenRegion = display.newRect( 480-REGION_WIDTH,320-REGION_HEIGHT,REGION_WIDTH,REGION_HEIGHT)
	local redRegion = display.newRect( 0,0,REGION_WIDTH,REGION_HEIGHT)
	local yellowRegion = display.newRect( 480-REGION_WIDTH,0,REGION_WIDTH,REGION_HEIGHT)

	blueRegion:setFillColor(31,150,250,transparency)
	greenRegion:setFillColor(14,174,93,transparency)
	redRegion:setFillColor(255,0,0,transparency)
	yellowRegion:setFillColor(255,204,0,transparency)


if #RegionGroup == 4 then
		for i = 1, #RegionGroup do
			table.remove(RegionGroup, i)
		end
		print("ASDFSDFASDF")
	end
	table.insert(RegionGroup, 1,blueRegion)
	table.insert(RegionGroup, 2,greenRegion)
	table.insert(RegionGroup, 3,redRegion)
	table.insert(RegionGroup, 4,yellowRegion)

	
	for i = 1, #RegionGroup do
		RegionGroup[i].strokeWidth = 0
		RegionGroup[i].color = i
		addFunctions(RegionGroup[i])
		RegionGroup[i].myName = "region"
		RegionGroup[i].alpha = 0
	end

	return blueRegion,greenRegion,redRegion,yellowRegion
end

addFunctions = function(obj)
	function obj:purge()

	end
	function obj:lightUp()
		obj:setFillColor(255,255,255,255)
		local function fadeOut()
			transition.to( obj, { alpha=0, time=500 } )
			if obj.color == 1 then
				obj:setFillColor(31,150,250,transparency)
			elseif obj.color == 2 then
				obj:setFillColor(14,174,93,transparency)
			elseif obj.color == 3 then
				obj:setFillColor(255,0,0,transparency)
			elseif obj.color == 4 then
				obj:setFillColor(255,204,0,transparency)
			end
		end
		transition.to( obj, { alpha=1, time=100, onComplete = fadeOut} )

		-- 
		-- transition.to( r, { alpha=0, time=1000 } )
	end
end