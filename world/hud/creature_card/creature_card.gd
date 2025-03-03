extends Control
class_name CreatureCard

@export var creature:Creature:
	set(value):
		creature = value
		update()
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
@onready var lifespan:ValueUI = find_child("Lifespan")


func _ready() -> void:
	pass

func _process(_delta:float) -> void:
	update_life()

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

func update_life() -> void:
	if creature != null:
		energy.value = creature.energy
		repr_cooldown_time.value = creature.reproduction_cooldowm_timer.time_left
		children.value = creature.children
		lifespan.value = creature.lifespan