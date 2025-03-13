extends Control
class_name CreatureCard

@export var creature:CreatureData
@onready var color_ui:ColorUI = find_child("Color")
@onready var attraction:Vector3UI = find_child("Attraction")
@onready var intensity:ValueUI = find_child("Intensity")
@onready var sense_radius:ValueUI = find_child("SenseRadius")
@onready var brake:ValueUI = find_child("Brake")
@onready var repr_threshold:ValueUI = find_child("ReprThresh")
@onready var repr_cooldown:ValueUI = find_child("ReprCooldown")
@onready var energy:ValueUI = find_child("Energy")
@onready var repr_cooldown_time:ValueUI = find_child("ReprCooldownTime")
@onready var children:ValueUI = find_child("Children")
@onready var descendents:ValueUI = find_child("Descendents")
@onready var lifespan:ValueUI = find_child("Lifespan")
@onready var parent_bt:Button = find_child("ParentBt")
@onready var marker_selector:MarkerButton = find_child("MarkerButton")
@onready var mark_desc_bt:BaseButton = find_child("MarkDescBt")
@onready var follow_button:BaseButton = find_child("FollowButton")


func _ready() -> void:
	marker_selector.marker_selected.connect(_on_marker_selected)
	mark_desc_bt.toggled.connect(_on_mark_desc_toggled)

func _process(_delta:float) -> void:
	update_life()

func set_creature(new:CreatureData) -> void:
	creature = new
	update_parent_bt()
	update()

func update() -> void:
	if creature != null:
		color_ui.color = creature.color
		attraction.vec = creature.attraction
		intensity.value = creature.intensity
		sense_radius.value = creature.sense_radius
		brake.value = creature.brake
		repr_threshold.value = creature.reproduction_energy_threshold
		repr_cooldown.value = creature.reproduction_cooldown
		update_life()
		if creature.vessel != null:
			marker_selector.update_marker_from_creature(creature.vessel)

func update_life() -> void:
	if creature != null:
		lifespan.value = creature.lifespan
		children.value = creature.children.size()
		descendents.value = creature.get_descendents().size()
		if creature.vessel != null:
			energy.value = creature.vessel.energy
			repr_cooldown_time.value = creature.vessel.reproduction_cooldowm_timer.time_left
		else:
			energy.value = 0.
			repr_cooldown_time.value = 0.

func _on_marker_selected(marker:Marker) -> void:
	mark(marker)

func _on_mark_desc_toggled(toggled_on:bool) -> void:
	if toggled_on:
		mark(marker_selector.get_selected_marker())

func mark(marker:Marker) -> void:
	if creature != null and creature.vessel != null:
		creature.vessel.marker = marker
		if mark_desc_bt.button_pressed:
			var desc:Array[CreatureVessel] = creature.vessel.get_descendents_vessels()
			for d in desc:
				d.marker = marker

func update_parent_bt() -> void:
	if creature != null:
		parent_bt.set_disabled(creature.parent == null)
		var text:String = "Inexistente" if creature.parent == null else ("%x" % creature.parent.get_instance_id()).substr(8)
		parent_bt.set_text(text)