extends Camera2D
class_name WorldCamera

const ZOOM_INTENSITY:float = 1.3
const ZOOM_DURATION:float = .1
const MOVE_SPEED:float = 300.
const LEAK_TOLERANCE:float = 500.

var input_enabled:bool = true
var previous_mouse_position:Vector2


func _ready() -> void:
	pass

func _process(delta:float) -> void:
	if input_enabled:
		
		if Input.is_action_just_pressed("zoom_in"):
			var tween:Tween = get_tree().create_tween()
			tween.tween_property(self, "zoom", zoom*ZOOM_INTENSITY, ZOOM_DURATION).set_trans(Tween.TRANS_CUBIC)
		elif Input.is_action_just_pressed("zoom_out"):
			var tween:Tween = get_tree().create_tween()
			tween.tween_property(self, "zoom", zoom/ZOOM_INTENSITY, ZOOM_DURATION).set_trans(Tween.TRANS_CUBIC)
		
		var input_direction:Vector2 = Input.get_vector("left", "right", "up", "down")
		global_position +=input_direction * delta * MOVE_SPEED

		if Input.is_action_pressed("middle_click"):
			var mouse_position:Vector2 = get_viewport().get_mouse_position()
			global_position -= (mouse_position - previous_mouse_position) / zoom

	var size:Vector2 = get_viewport().get_visible_rect().size
	if size.x/zoom.x > World.area.size.x + LEAK_TOLERANCE*2.:
		global_position.x = World.area.size.x/2. + World.area.position.x
	else:
		global_position.x = clampf(global_position.x, World.area.position.x+size.x/2./zoom.x-LEAK_TOLERANCE, World.area.end.x-size.x/2./zoom.x+LEAK_TOLERANCE)
	if size.y/zoom.y > World.area.size.y + LEAK_TOLERANCE*2.:
		global_position.y = World.area.size.y/2. + World.area.position.y
	else:
		global_position.y = clampf(global_position.y, World.area.position.y+size.y/2./zoom.y-LEAK_TOLERANCE, World.area.end.y-size.y/2./zoom.y+LEAK_TOLERANCE)

	previous_mouse_position = get_viewport().get_mouse_position()