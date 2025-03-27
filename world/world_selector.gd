extends Control
class_name WorldSelector

signal toggled(toggled_on:bool)
signal deleted()

static var scene_path:String = "res://world/world_selector.tscn"

@onready var select_button:Button = find_child("Button")
@onready var del_button:Button = find_child("Delete")

var world_data:WorldData


func _ready() -> void:
	select_button.toggled.connect(func(toggled_on:bool): toggled.emit(toggled_on))
	del_button.pressed.connect(func(): deleted.emit())
	update()

func update() -> void:
	if world_data != null:
		select_button.set_text(world_data.resource_name)

static func create(_world_data:WorldData) -> WorldSelector:
	var selector:WorldSelector = load(scene_path).instantiate()
	selector.world_data = _world_data
	return selector
