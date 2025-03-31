extends Control
class_name PauseMenu

signal resume_pressed()
signal save_pressed()
signal load_pressed()
signal exit_pressed()

@onready var resume_bt:Button = find_child("Resume")
@onready var save_bt:Button = find_child("Save")
@onready var load_bt:Button = find_child("Load")
@onready var exit_bt:Button = find_child("Exit")


func _ready() -> void:
    resume_bt.pressed.connect(resume_pressed.emit)
    save_bt.pressed.connect(save_pressed.emit)
    load_bt.pressed.connect(load_pressed.emit)
    exit_bt.pressed.connect(exit_pressed.emit)

func open() -> void:
    set_visible(true)

func close() -> void:
    set_visible(false)