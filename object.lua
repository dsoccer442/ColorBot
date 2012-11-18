module(..., package.seeall)
local physics = require("physics")
local vx, vy
function create(obj)
  obj.drag = false
  obj.changedFilter = false
  obj:setReferencePoint(display.centerReferencePoint)
  function obj:pickup(x,y)
  obj.drag = true
  display.getCurrentStage():setFocus( obj )  
  -- Store initial position  
  -- if x < 0 or x > 480 then
  -- obj.x0 = obj.x
  -- print "x is out of view"
  -- else
  obj.x0 = x - obj.x   
-- end
-- if y < 0 or y > 320 then
  -- obj.y0 = obj.y
  -- else
obj.y0 = y - obj.y  
-- end
  -- -- Avoid gravitational forces  
   obj.bodyType = "kinematic"  
    
  -- -- Stop current motion, if any  
  vx, vy = obj:getLinearVelocity()
  obj:setLinearVelocity( 0, 0 )  

  obj.isSensor = true
  obj:toFront()
  obj:prepare("drag")
  obj.xScale, obj.yScale = 1.25, 1.25
  obj:play()
  end
  function obj:move(x,y)
  	if obj.drag == true then
      if (x - obj.x0)  > 0 and (x - obj.x0) < 480 then
  		obj.x = x - obj.x0  
    end
      if  y - obj.y0 > 0 and y - obj.y0 < 320 then
            obj.y = y - obj.y0  
          end
  	end
  end
  function obj:release()
    obj.isSensor = false
    obj.drag = false
    display.getCurrentStage():setFocus( nil )  
    obj.bodyType = "dynamic"  
   obj:setLinearVelocity( -vx, -vy ) 
   obj:prepare("walking")
   obj.xScale, obj.yScale = 1, 1
    obj:play()
  end
end