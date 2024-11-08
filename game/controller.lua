function Controller()
	return {
		delegate = ControllerDelegate(),
		joystick = nil,
		state = ControllerState()
	}
end

function ControllerState()
	return {
		up 		= 0.0,
		down 	= 0.0,
		left 	= 0.0,
		right 	= 0.0,

		jump	= 0.0,
		run 	= 0.0,

		mine 	= 0.0,
		use 	= 0.0
	}
end

function ControllerDelegate()
	return {
		press_up    	 = function() end,
		press_down  	 = function() end,
		press_x     	 = function() end,
		press_start 	 = function() end,
		press_left  	 = function() end,
		press_right 	 = function() end,
		press_function_1 = function() end,
		press_function_2 = function() end,
		press_number     = function() end
	}
end


-- function Controller:init(joystick)
-- 	self.down = { }

-- 	self.joystick = joystick
	
-- 	self.lastButton = 0
-- end

-- function Controller:isExitDown()
-- 	local backdown = self.down["back"]
	
-- 	local startdown = self.down["start"]

-- 	return backdown and startdown
-- end

-- function Controller:leftAxes()
-- 	local tolerance = 0.1

-- 	local x_axis = self.joystick:getAxis(1)

-- 	local y_axis = self.joystick:getAxis(2)

-- 	if math.abs(x_axis) < tolerance then
-- 		x_axis = 0
-- 	end

-- 	if math.abs(y_axis) < tolerance then
-- 		y_axis = 0
-- 	end

-- 	return {x=x_axis, y=y_axis}
-- end

-- function Controller:rightAxes()
-- 	local tolerance = 0.1

-- 	local x_axis = self.joystick:getAxis(3)

-- 	local y_axis = self.joystick:getAxis(4)

-- 	if math.abs(x_axis) < tolerance then
-- 		x_axis = 0
-- 	end

-- 	if math.abs(y_axis) < tolerance then
-- 		y_axis = 0
-- 	end
-- end
