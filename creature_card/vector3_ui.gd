@tool
extends Control
class_name Vector3UI

signal value_changed()

@export var vec:Vector3:
	set(value): vec = value; update_sliders()
@export var title:String = "Vec":
	set(value): title = value; update()
@export var x_title:String = "x":
	set(value): x_title = value; update()
@export var y_title:String = "y":
	set(value): y_title = value; update()
@export var z_title:String = "z":
	set(value): z_title = value; update()
@export var title_width:float = 12.:
	set(value): title_width = value; update()
@export var value_width:float = 12.:
	set(value): value_width = value; update()
@export var central_tick:bool = false:
	set(value): central_tick = value; update()
@export var min_value:float = -1.:
	set(value): min_value = value; update()
@export var max_value:float = 1.:
	set(value): max_value = value; update()
@export var editable:bool = false:
	set(value): editable = value; update()
@onready var title_label:Label = find_child("VectorName")
@onready var x:ValueUI = find_child("VectorX")
@onready var y:ValueUI = find_child("VectorY")
@onready var z:ValueUI = find_child("VectorZ")


func _ready() -> void:
	x.value_changed.connect(_on_value_changed)
	y.value_changed.connect(_on_value_changed)
	z.value_changed.connect(_on_value_changed)
	update_sliders()
	update()

func update_sliders() -> void:
	if x != null and y != null and z != null:
		x.value = vec.x
		y.value = vec.y
		z.value = vec.z

func update() -> void:
	if x != null and y != null and z != null:
		update_ui(x, x_title)
		update_ui(y, y_title)
		update_ui(z, z_title)
	if title_label != null:
		title_label.set_text(title)

func update_ui(ui:ValueUI, ui_title:String) -> void:
	ui.title = ui_title
	ui.title_min_width = title_width
	ui.value_min_width = value_width
	ui.min_value = min_value
	ui.max_value = max_value
	ui.central_tick = central_tick
	ui.editable = editable

func _on_value_changed() -> void:
	vec = Vector3(x.value, y.value, z.value)
	value_changed.emit()