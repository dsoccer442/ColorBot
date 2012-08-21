module(..., package.seeall)
local Object = require "object"

function create(obj)
	Object.create(obj)
	
	obj.placed = false
	
end