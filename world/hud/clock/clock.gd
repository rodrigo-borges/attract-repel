extends Control
class_name Clock

signal pause_bt_toggled(toggled_on:bool)

@onready var clock_label:Label = find_child("ClockLabel")
@onready var pause_button:BaseButton = find_child("PauseButton")
@onready var gen_label:Label = find_child("Generation")
var elapsed_time:float = 0.

func _ready() -> void:
	pause_button.toggled.connect(pause_bt_toggled.emit)

func _process(delta:float) -> void:
	if Engine.time_scale > 0.:
		elapsed_time += delta
		update()

func update() -> void:
	var residue:float = elapsed_time
	var hours:int = floori(residue/3600.)
	residue -= hours*3600.
	var minutes:int = floori(residue/60.)
	residue -= minutes*60.
	var seconds:int = floori(residue)
	if clock_label != null:
		clock_label.set_text("%02d:%02d:%02d" % [hours, minutes, seconds])

func toggle_pause(pause:bool) -> void:
	pause_button.set_pressed_no_signal(pause)