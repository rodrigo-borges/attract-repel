extends Control
class_name Clock

@onready var clock_label:Label = find_child("ClockLabel")
@onready var pause_button:BaseButton = find_child("PauseButton")
@onready var gen_label:Label = find_child("Generation")
var elapsed_time:float = 0.

func _ready() -> void:
	pause_button.toggled.connect(toggle_pause)

func _process(delta:float) -> void:
	if Input.is_action_just_pressed("pause"):
		if Engine.time_scale > 0.:
			toggle_pause(true)
		else:
			toggle_pause(false)
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
	if pause:
		Engine.set_time_scale(0.)
	else:
		Engine.set_time_scale(1.)
	pause_button.set_pressed_no_signal(pause)