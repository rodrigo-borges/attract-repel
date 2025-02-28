extends Control
class_name MapView

var world_rect:Rect2
var camera_rect:Rect2
var creatures:PackedVector2Array

func _ready() -> void:
	pass

func _process(_delta:float) -> void:
	pass

func _draw() -> void:
	draw_rect(world_rect, Color.BLACK, false, 1.)
	draw_rect(camera_rect, Color.WHITE, false, 1.)
	for c in creatures:
		draw_circle(c, 1., Color.WHITE)