@tool
extends Control
class_name ValueUI

@export var title:String = "X":
	set(value): title = value; update()
@export var format_string:String = "%.2f":
	set(value): format_string = value; update_value()
@export var value:float = 0.:
	set(_value): value = _value; update_value()
@export var min_value:float = -1.:
	set(value): min_value = value; update()
@export var max_value:float = 1.:
	set(value): max_value = value; update()
@export var show_slider:bool = true:
	set(value): show_slider = value; update()
@export var editable:bool = false:
	set(value): editable = value; update()
@export var central_tick:bool = false:
	set(value): central_tick = value; update()
@export var title_min_width:float = 0.:
	set(value): title_min_width = value; update()
@export var slider_min_width:float = 0.:
	set(value): slider_min_width = value; update()
@export var value_min_width:float = 0.:
	set(value): value_min_width = value; update()
@onready var title_label:Label = find_child("Title")
@onready var slider:Slider = find_child("Slider")
@onready var value_label:Label = find_child("Value")


func _ready() -> void:
	update()

func update_value() -> void:
	if slider != null:
		slider.set_value(value)
	if value_label != null:
		value_label.set_text(format_string % value)

func update() -> void:
	if title_label != null:
		title_label.set_text(title)
		title_label.set_custom_minimum_size(Vector2(title_min_width, 0.))
	if slider != null:
		slider.set_min(min_value)
		slider.set_max(max_value)
		slider.set_visible(show_slider)
		slider.set_editable(editable)
		slider.set_ticks(3*int(central_tick))
		slider.set_custom_minimum_size(Vector2(slider_min_width, 0.))
	if value_label != null:
		value_label.set_custom_minimum_size(Vector2(value_min_width, 0.))
		value_label.set_h_size_flags(
			SizeFlags.SIZE_SHRINK_END + SizeFlags.SIZE_EXPAND*int(!show_slider))