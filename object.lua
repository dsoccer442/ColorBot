module(..., package.seeall)
local vx, vy
function create(obj)
	obj.drag = false
	obj:setReferencePoint(display.centerReferencePoint)
	function obj:touch( event )

		local ball = event.target  
      
	    local phase = event.phase  
	    if "began" == phase then  
	    	obj.drag = true
	        display.getCurrentStage():setFocus( ball )  
	  
	        -- Store initial position  
	        ball.x0 = event.x - ball.x  
	        ball.y0 = event.y - ball.y  
	          
	        -- -- Avoid gravitational forces  
	         -- event.target.bodyType = "kinematic"  
	          
	        -- -- Stop current motion, if any  
	        vx, vy = event.target:getLinearVelocity()
	        event.target:setLinearVelocity( 0, 0 )  
	        --event.target.angularVelocity = 0  
	  
	    else  
	        if "moved" == phase and obj.drag == true then  
	            ball.x = event.x - ball.x0  
	            ball.y = event.y - ball.y0  
	        elseif "ended" == phase or "cancelled" == phase then  
	        	obj.drag = false
	            display.getCurrentStage():setFocus( nil )  
	             -- event.target.bodyType = "dynamic"  
	             event.target:setLinearVelocity( -vx, -vy ) 
	        end  
	    end  
	  
	    return true  
	end
end