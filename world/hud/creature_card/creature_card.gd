extends Control
class_name CreatureCard

@export var creature:CreatureData
@onready var generation:ValueUI = find_child("Generation")
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
@onready var alive_descendents:ValueUI = find_child("AliveDescendents")
@onready var lifespan:ValueUI = find_child("Lifespan")
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
	update()

func update() -> void:
	if creature != null:
		generation.value = creature.generation
		color_ui.color = creature.color
		attraction.vec = creature.attraction
		intensity.value = creature.intensity
		sense_radius.value = creature.sense_radius
		brake.value = creature.brake
		repr_threshold.value = creature.reproduction_energy_threshold
		repr_cooldown.value = creature.reproduction_cooldown
		update_life()
		marker_selector.update_marker_from_creature(creature)

func update_life() -> void:
	if creature != null:
		lifespan.value = creature.lifespan
		children.value = creature.children.size()
		var desc_stats:Array[int] = creature.get_descendents_stats()
		descendents.value = desc_stats[0]
		alive_descendents.value = desc_stats[1]
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
	if creature != null:
		mark_creature(creature, marker)
		if mark_desc_bt.button_pressed:
			var desc:Array[CreatureData] = creature.get_descendents()
			for d in desc:
				mark_creature(d, marker)

func mark_creature(_creature:CreatureData, marker:Marker) -> void:
	_creature.marker = marker
	if _creature.vessel != null:
		_creature.vessel.update_marker()