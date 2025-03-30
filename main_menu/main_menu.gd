@tool
extends Control
class_name MainMenu

@onready var start_bt:Button = find_child("Start")
@onready var exit_bt:Button = find_child("Exit")
@onready var version_label:Label = find_child("Version")
@onready var save_load_screen:SaveLoadScreen = find_child("SaveLoadScreen")
@onready var center_content:Control = find_child("CenterContent")


func _ready() -> void:
    start_bt.pressed.connect(_on_start_pressed)
    exit_bt.pressed.connect(_on_exit_pressed)
    version_label.set_text("v%s" % ProjectSettings.get_setting("application/config/version"))
    save_load_screen.closed.connect(_on_save_load_closed)
    save_load_screen.world_loaded.connect(_on_world_loaded)
    save_load_screen.set_visible(false)
    save_load_screen.toggle_load_mode()

func _on_start_pressed() -> void:
    center_content.set_visible(false)
    save_load_screen.set_visible(true)

func _on_exit_pressed() -> void:
    get_tree().quit()

func _on_save_load_closed() -> void:
    save_load_screen.set_visible(false)
    center_content.set_visible(true)

func _on_world_loaded(world_data:WorldData) -> void:
    var world = World.create(world_data)
    get_tree().root.add_child(world)
    queue_free()