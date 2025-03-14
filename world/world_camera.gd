extends Camera
class_name WorldCamera

const LEAK_TOLERANCE:float = 500.

var followed_node:Node2D = null


func _ready() -> void:
	pass

func _process(_delta:float) -> void:
	super._process(_delta)
	if followed_node != null:
		global_position = followed_node.global_position
	var size:Vector2 = get_viewport().get_visible_rect().size
	if size.x/zoom.x > World.area.size.x + LEAK_TOLERANCE*2.:
		global_position.x = World.area.size.x/2. + World.area.position.x
	else:
		global_position.x = clampf(global_position.x, World.area.position.x+size.x/2./zoom.x-LEAK_TOLERANCE, World.area.end.x-size.x/2./zoom.x+LEAK_TOLERANCE)
	if size.y/zoom.y > World.area.size.y + LEAK_TOLERANCE*2.:
		global_position.y = World.area.size.y/2. + World.area.position.y
	else:
		global_position.y = clampf(global_position.y, World.area.position.y+size.y/2./zoom.y-LEAK_TOLERANCE, World.area.end.y-size.y/2./zoom.y+LEAK_TOLERANCE)