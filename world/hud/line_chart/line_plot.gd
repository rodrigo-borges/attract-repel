extends Control
class_name LinePlot

var points:PackedVector2Array
var line_color:Color
var line_width:float

func _ready() -> void:
	pass

func _draw() -> void:
	if points.size() > 2:
		draw_polyline(points, line_color, line_width, true)