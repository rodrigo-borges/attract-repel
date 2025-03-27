extends Control
class_name SaveLoadScreen

signal closed()
signal world_loaded(world_data:WorldData)

@export var worlds_dir:String = "user://save/worlds/"
@onready var screen_title:Label = find_child("ScreenTitle")
@onready var exit_bt:Button = find_child("ExitBt")
@onready var world_selectors:Control = find_child("WorldList")
@onready var save_bar:Control = find_child("SaveBar")
@onready var load_bar:Control = find_child("LoadBar")
@onready var save_name_edit:LineEdit = find_child("SaveNameEdit")
@onready var save_bt:Button = find_child("SaveBt")
@onready var load_bt:Button = find_child("LoadBt")
var current_selector:WorldSelector
var world_data:WorldData


func _ready() -> void:    
	create_worlds_dir()
	list_worlds()
	exit_bt.pressed.connect(func():set_visible(false); closed.emit())
	save_name_edit.text_changed.connect(_on_name_edit_text_changed.unbind(1))
	save_bt.pressed.connect(save_world)
	load_bt.pressed.connect(load_world)

func toggle_save_mode() -> void:
	screen_title.set_text("Salvar cenário")
	load_bar.set_visible(false)
	save_bar.set_visible(true)

func toggle_load_mode() -> void:
	screen_title.set_text("Carregar cenário")
	save_bar.set_visible(false)
	load_bar.set_visible(true)

func _on_name_edit_text_changed() -> void:
	save_bt.set_disabled(save_name_edit.text.is_empty())

func create_worlds_dir() -> void:
	if not DirAccess.dir_exists_absolute(worlds_dir):
		DirAccess.make_dir_recursive_absolute(worlds_dir)

func list_worlds() -> void:
	var world_files:PackedStringArray = DirAccess.get_files_at(worlds_dir)
	for file_name in world_files:
		var file:FileAccess = FileAccess.open("%s%s" % [worlds_dir, file_name], FileAccess.READ)
		var file_text:String = file.get_as_text()
		var json:JSON = JSON.new()
		json.parse(file_text)
		var world_dict:Dictionary = json.data
		var data:WorldData = WorldData.from_dict(world_dict)
		data.resource_name = file_name.left(-5)
		create_selector(data)

func save_world() -> void:
	if world_data != null:
		world_data.resource_name = save_name_edit.text
		var world_dict:Dictionary = world_data.to_dict()
		var file_name:String = save_name_edit.text + ".json"
		var file_text:String = JSON.stringify(world_dict)
		var file:FileAccess = FileAccess.open("%s%s" % [worlds_dir, file_name], FileAccess.WRITE)
		file.store_string(file_text)
		create_selector(world_data)

func load_world() -> void:
	if is_instance_valid(current_selector):
		var data:WorldData = current_selector.world_data
		world_loaded.emit(data)

func create_selector(data:WorldData) -> void:
	var selector = WorldSelector.create(data)
	world_selectors.add_child(selector)
	selector.toggled.connect(_on_selector_toggled.bind(selector))

func _on_selector_toggled(toggled_on:bool, selector:WorldSelector) -> void:
	if toggled_on:
		current_selector = selector
	load_bt.set_disabled(!is_instance_valid(current_selector))
