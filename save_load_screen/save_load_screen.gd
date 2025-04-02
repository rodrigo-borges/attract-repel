extends Control
class_name SaveLoadScreen

signal close_pressed()
signal world_loaded(world_data:WorldData)

@export var worlds_dir:String = "user://save/worlds/"
@export var default_worlds_dir:String = "res://default_worlds/"
@onready var world_preview:WorldPreview = find_child("WorldPreview")
@onready var screen_title:Label = find_child("ScreenTitle")
@onready var exit_bt:Button = find_child("ExitBt")
@onready var default_selectors:Control = find_child("DefaultWorldList")
@onready var custom_selectors:Control = find_child("CustomWorldList")
@onready var save_bar:Control = find_child("SaveBar")
@onready var load_bar:Control = find_child("LoadBar")
@onready var save_name_edit:LineEdit = find_child("SaveNameEdit")
@onready var save_bt:Button = find_child("SaveBt")
@onready var load_bt:Button = find_child("LoadBt")
@onready var tabs:TabContainer = find_child("WorldListTabs")
var current_selector:WorldSelector
var world_data:WorldData


func _ready() -> void:    
	create_worlds_dir()
	tabs.set_tab_title(0, "Padrão")
	tabs.set_tab_title(1, "Personalizados")
	list_default_worlds()
	list_custom_worlds()
	exit_bt.pressed.connect(close_pressed.emit)
	save_name_edit.text_changed.connect(_on_name_edit_text_changed.unbind(1))
	save_bt.pressed.connect(save_world)
	load_bt.pressed.connect(load_world)

func open(mode:String) -> void:
	if mode == "save":
		toggle_save_mode()
	elif mode == "load":
		toggle_load_mode()
	set_visible(true)

func close() -> void:
	set_visible(false)
	deselect()

func toggle_save_mode() -> void:
	screen_title.set_text("Salvar cenário")
	load_bar.set_visible(false)
	save_bar.set_visible(true)
	tabs.set_current_tab(1)
	tabs.set_tabs_visible(false)

func toggle_load_mode() -> void:
	screen_title.set_text("Carregar cenário")
	save_bar.set_visible(false)
	load_bar.set_visible(true)
	tabs.set_current_tab(0)
	tabs.set_tabs_visible(true)

func _on_name_edit_text_changed() -> void:
	save_bt.set_disabled(save_name_edit.text.is_empty())

func create_worlds_dir() -> void:
	if not DirAccess.dir_exists_absolute(worlds_dir):
		DirAccess.make_dir_recursive_absolute(worlds_dir)

func list_default_worlds() -> void:
	var default_world_files:PackedStringArray = DirAccess.get_files_at(default_worlds_dir)
	for file_name in default_world_files:
		var data:WorldData = ResourceLoader.load(default_worlds_dir+file_name, "WorldData")
		data.resource_name = file_name.left(-5)
		create_default_selector(data)

func list_custom_worlds() -> void:
	var custom_world_files:PackedStringArray = DirAccess.get_files_at(worlds_dir)
	for file_name in custom_world_files:
		var file:FileAccess = FileAccess.open("%s%s" % [worlds_dir, file_name], FileAccess.READ)
		var file_text:String = file.get_as_text()
		var json:JSON = JSON.new()
		json.parse(file_text)
		var world_dict:Dictionary = json.data
		var data:WorldData = WorldData.from_dict(world_dict)
		data.resource_name = file_name.left(-5)
		create_custom_selector(data)

func save_world() -> void:
	if world_data != null:
		world_data.resource_name = save_name_edit.text
		var world_dict:Dictionary = world_data.to_dict()
		var world_name:String = save_name_edit.text
		var file_name:String = world_name + ".json"
		var file_exists:bool = FileAccess.file_exists(worlds_dir + file_name)
		if file_exists:
			delete_world(custom_selectors.find_child(world_name))
		var file_text:String = JSON.stringify(world_dict)
		var file:FileAccess = FileAccess.open("%s%s" % [worlds_dir, file_name], FileAccess.WRITE)
		file.store_string(file_text)
		var selector:WorldSelector = create_custom_selector(world_data)
		selector.toggle(true)

func load_world() -> void:
	if is_instance_valid(current_selector):
		var data:WorldData = current_selector.world_data
		world_loaded.emit(data)

func create_default_selector(data:WorldData) -> WorldSelector:
	var selector = WorldSelector.create(data, false)
	selector.name = data.resource_name
	default_selectors.add_child(selector)
	selector.set_owner(default_selectors)
	selector.toggled.connect(_on_selector_toggled.bind(selector))
	return selector

func create_custom_selector(data:WorldData) -> WorldSelector:
	var selector = WorldSelector.create(data, true)
	selector.name = data.resource_name
	custom_selectors.add_child(selector)
	selector.set_owner(custom_selectors)
	selector.toggled.connect(_on_selector_toggled.bind(selector))
	selector.deleted.connect(delete_world.bind(selector))
	return selector

func _on_selector_toggled(toggled_on:bool, selector:WorldSelector) -> void:
	if toggled_on:
		current_selector = selector
		world_preview.set_data(selector.world_data)
		save_name_edit.set_text(selector.name)
	elif current_selector == selector:
		current_selector = null
		world_preview.set_data(null)
		save_name_edit.set_text("")
	load_bt.set_disabled(!is_instance_valid(current_selector))

func deselect() -> void:
	if is_instance_valid(current_selector):
		current_selector.toggle(false)

func delete_world(selector:WorldSelector) -> void:
	selector.set_name("Deleted")
	selector.toggle(false)
	var file_name:String = selector.world_data.resource_name + ".json"
	DirAccess.remove_absolute("%s%s" % [worlds_dir, file_name])
	selector.queue_free()
