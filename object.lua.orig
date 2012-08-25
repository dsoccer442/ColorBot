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
  obj.x0 = x - obj.x  
  obj.y0 = y - obj.y  
    
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
  		obj.x = x - obj.x0  
            obj.y = y - obj.y0  
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