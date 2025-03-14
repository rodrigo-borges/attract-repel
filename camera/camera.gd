extends Camera2D
class_name Camera

@export var zoom_enabled:bool = true
@export var zoom_intensity:float = 1.3
@export var zoom_duration:float = .1
@export var drag_enabled:bool = true
@export var keyboard_enabled:bool = true
@export var move_speed:float = 300.

var moving:bool = false
var previous_mouse_position:Vector2

func _ready() -> void:
	pass

func _process(delta:float) -> void:
	if drag_enabled:
		if Input.is_action_just_released("middle_click"):
			moving = false
		if moving:
			var mouse_position:Vector2 = get_viewport().get_mouse_position()
			global_position -= (mouse_position - previous_mouse_position) / zoom
	if keyboard_enabled:
		var input_direction:Vector2 = Input.get_vector("left", "right", "up", "down")
		global_position += input_direction * delta * move_speed

	previous_mouse_position = get_viewport().get_mouse_position()

func _unhandled_input(event:InputEvent) -> void:
	if zoom_enabled:
		if event.is_action_pressed("zoom_in"):
			if Engine.time_scale > 0.:
				var tween:Tween = get_tree().create_tween()
				tween.tween_property(self, "zoom", zoom*zoom_intensity, zoom_duration).set_trans(Tween.TRANS_CUBIC)
			else:
				zoom *= zoom_intensity
		elif event.is_action_pressed("zoom_out"):
			if Engine.time_scale > 0.:
				var tween:Tween = get_tree().create_tween()
				tween.tween_property(self, "zoom", zoom/zoom_intensity, zoom_duration).set_trans(Tween.TRANS_CUBIC)
			else:
				zoom /= zoom_intensity
	if drag_enabled:
		if event.is_action_pressed("middle_click"):
			moving = true