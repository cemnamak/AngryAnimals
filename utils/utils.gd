class_name Utils

static func vec2_to_str(vec: Vector2)-> String:
	var s: String = "(%.1f,%.1f)" % [
		vec.x,vec.y
	]
	
	s += ""
	return s
