extends Camera2D

const MOVE_SPEED:float = 300.

var moving:bool = false
var previous_mouse_position:Vector2


func _ready() -> void:
	pass

func _process(_delta:float) -> void:
	if Input.is_action_just_released("middle_click"):
		moving = false
	if moving:
		var mouse_position:Vector2 = get_viewport().get_mouse_position()
		global_position -= (mouse_position - previous_mouse_position) / zoom

	previous_mouse_position = get_viewport().get_mouse_position()

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("middle_click"):
		moving = true