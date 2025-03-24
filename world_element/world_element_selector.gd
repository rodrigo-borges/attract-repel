extends Control
class_name WorldElementSelector

signal toggled(toggled_on:bool)
signal deleted()

static var scene_path:String = "res://world_element/world_element_selector.tscn"

@export var text:String = "":
	set(value):
		text = value
		update()
@onready var select_button:Button = find_child("Button")
@onready var del_button:Button = find_child("Delete")

var data:Resource


func _ready() -> void:
	select_button.toggled.connect(func(toggled_on:bool): toggled.emit(toggled_on))
	del_button.pressed.connect(func(): deleted.emit())
	update()

func update() -> void:
	if select_button != null:
		select_button.set_text(text)

static func create(_data:Resource) -> WorldElementSelector:
	var selector:WorldElementSelector = load(scene_path).instantiate()
	selector.data = _data
	return selector
