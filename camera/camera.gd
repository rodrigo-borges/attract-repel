extends Camera2D
class_name Camera

signal zoom_changed()

@export var zoom_enabled:bool = true
@export var zoom_intensity:float = 1.3
@export var zoom_duration:float = .1
@export var drag_enabled:bool = true
@export var keyboard_enabled:bool = true
@export var move_speed:float = 300.
@export var area:Rect2 = Rect2()
@export var leak_tolerance:float = 100.

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

	if area.size > Vector2.ZERO:
		var size:Vector2 = get_viewport().get_visible_rect().size
		if size.x/zoom.x > area.size.x + leak_tolerance*2.:
			global_position.x = area.size.x/2. + area.position.x
		else:
			global_position.x = clampf(global_position.x, area.position.x+size.x/2./zoom.x-leak_tolerance, area.end.x-size.x/2./zoom.x+leak_tolerance)
		if size.y/zoom.y > area.size.y + leak_tolerance*2.:
			global_position.y = area.size.y/2. + area.position.y
		else:
			global_position.y = clampf(global_position.y, area.position.y+size.y/2./zoom.y-leak_tolerance, area.end.y-size.y/2./zoom.y+leak_tolerance)

	previous_mouse_position = get_viewport().get_mouse_position()

func _unhandled_input(event:InputEvent) -> void:
	if zoom_enabled:
		if event.is_action_pressed("zoom_in"):
			if Engine.time_scale > 0.:
				var tween:Tween = get_tree().create_tween()
				tween.tween_property(self, "zoom", zoom*zoom_intensity, zoom_duration).set_trans(Tween.TRANS_CUBIC)
			else:
				zoom *= zoom_intensity
			zoom_changed.emit()
		elif event.is_action_pressed("zoom_out"):
			if Engine.time_scale > 0.:
				var tween:Tween = get_tree().create_tween()
				tween.tween_property(self, "zoom", zoom/zoom_intensity, zoom_duration).set_trans(Tween.TRANS_CUBIC)
			else:
				zoom /= zoom_intensity
			zoom_changed.emit()
	if drag_enabled:
		if event.is_action_pressed("middle_click"):
			moving = true