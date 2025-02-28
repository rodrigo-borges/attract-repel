extends Control
class_name ColorUI

@export var color:Color:
	set(value):
		color = value
		update_sliders()
@onready var r:Slider = find_child("ColorR")
@onready var g:Slider = find_child("ColorG")
@onready var b:Slider = find_child("ColorB") 


func _ready() -> void:
	update_sliders()

func update_sliders() -> void:
	if color == null:
		return
	if r != null and g != null and b != null:
		r.set_value(color.r)
		g.set_value(color.g)
		b.set_value(color.b)