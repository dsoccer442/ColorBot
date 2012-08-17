module(..., package.seeall)
local Object = require "object"

function create(obj)
	Object.create(obj)
	obj:addEventListener("touch", obj)

	
end