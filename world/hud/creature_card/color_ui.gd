@tool
extends Control
class_name ColorUI

@export var color:Color = Color.WHITE:
	set(value): color = value; update_color()
@export var title:String = "Vec":
	set(value): title = value; update()
@export var title_width:float = 12.:
	set(value): title_width = value; update()
@export var value_width:float = 12.:
	set(value): value_width = value; update()
@onready var title_label:Label = find_child("Title")
@onready var rect:ColorRect = find_child("ColorRect")
@onready var r:ValueUI = find_child("ColorR")
@onready var g:ValueUI = find_child("ColorG")
@onready var b:ValueUI = find_child("ColorB") 


func _ready() -> void:
	update_color()

func update_color() -> void:
	if r != null and g != null and b != null:
		r.value = color.r
		g.value = color.g
		b.value = color.b
	if rect != null:
		rect.set_color(color)

func update() -> void:
	if r != null and g != null and b != null:
		update_ui(r)
		update_ui(g)
		update_ui(b)
	if title_label != null:
		title_label.set_text(title)

func update_ui(ui:ValueUI) -> void:
	ui.title_min_width = title_width
	ui.value_min_width = value_width