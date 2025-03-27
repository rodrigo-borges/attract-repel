@tool
extends Control
class_name CreatureSpawnerCard

signal value_changed()
signal spawn_pressed(amount:int)

@export var data:CreatureSpawnerData

@onready var color_mean:ColorUI = find_child("Color")
@onready var color_std:ValueUI = find_child("ColorSTD")
@onready var size_radius_mean:ValueUI = find_child("SizeRadius")
@onready var size_radius_std:ValueUI = find_child("SizeRadiusSTD")
@onready var sense_radius_mean:ValueUI = find_child("SenseRadius")
@onready var sense_radius_std:ValueUI = find_child("SenseRadiusSTD")
@onready var attraction_mean:Vector3UI = find_child("Attraction")
@onready var attraction_std:ValueUI = find_child("AttractionSTD")
@onready var intensity_mean:ValueUI = find_child("Intensity")
@onready var intensity_std:ValueUI = find_child("IntensitySTD")
@onready var aggression_mean:Vector3UI = find_child("Aggression")
@onready var aggression_std:ValueUI = find_child("AggrSTD")
@onready var aggression_intensity_mean:ValueUI = find_child("AggrIntensity")
@onready var aggression_intensity_std:ValueUI = find_child("AggrIntensitySTD")
@onready var aggression_energy_threshold_mean:ValueUI = find_child("AggrThresh")
@onready var aggression_energy_threshold_std:ValueUI = find_child("AggrThreshSTD")
@onready var reproduction_energy_threshold_mean:ValueUI = find_child("ReprThresh")
@onready var reproduction_energy_threshold_std:ValueUI = find_child("ReprThreshSTD")
@onready var reproduction_cooldown_mean:ValueUI = find_child("ReprCooldown")
@onready var reproduction_cooldown_std:ValueUI = find_child("ReprCooldownSTD")
@onready var brake_mean:ValueUI = find_child("Brake")
@onready var brake_std:ValueUI = find_child("BrakeSTD")
@onready var incubation_time_mean:ValueUI = find_child("IncubationTime")
@onready var incubation_time_std:ValueUI = find_child("IncubationTimeSTD")

@onready var spawn_amount:Range = find_child("SpawnAmount")
@onready var spawn_bt:Button = find_child("SpawnBt")


func _ready() -> void:
	color_mean.value_changed.connect(_on_value_changed)
	color_std.value_changed.connect(_on_value_changed)
	size_radius_mean.value_changed.connect(_on_value_changed)
	size_radius_std.value_changed.connect(_on_value_changed)
	sense_radius_mean.value_changed.connect(_on_value_changed)
	sense_radius_std.value_changed.connect(_on_value_changed)
	attraction_mean.value_changed.connect(_on_value_changed)
	attraction_std.value_changed.connect(_on_value_changed)
	intensity_mean.value_changed.connect(_on_value_changed)
	intensity_std.value_changed.connect(_on_value_changed)
	aggression_mean.value_changed.connect(_on_value_changed)
	aggression_std.value_changed.connect(_on_value_changed)
	aggression_intensity_mean.value_changed.connect(_on_value_changed)
	aggression_intensity_std.value_changed.connect(_on_value_changed)
	aggression_energy_threshold_mean.value_changed.connect(_on_value_changed)
	aggression_energy_threshold_std.value_changed.connect(_on_value_changed)
	reproduction_energy_threshold_mean.value_changed.connect(_on_value_changed)
	reproduction_energy_threshold_std.value_changed.connect(_on_value_changed)
	reproduction_cooldown_mean.value_changed.connect(_on_value_changed)
	reproduction_cooldown_std.value_changed.connect(_on_value_changed)
	brake_mean.value_changed.connect(_on_value_changed)
	brake_std.value_changed.connect(_on_value_changed)
	incubation_time_mean.value_changed.connect(_on_value_changed)
	incubation_time_std.value_changed.connect(_on_value_changed)
	spawn_bt.pressed.connect(func(): spawn_pressed.emit(int(spawn_amount.value)))

func set_data(new:CreatureSpawnerData) -> void:
	data = new
	update()

func update() -> void:
	if data != null:
		color_mean.color = data.color_mean
		color_std.value = data.color_std
		size_radius_mean.value = data.size_radius_mean
		size_radius_std.value = data.size_radius_std
		sense_radius_mean.value = data.sense_radius_mean
		sense_radius_std.value = data.sense_radius_std
		attraction_mean.vec = data.attraction_mean
		attraction_std.value = data.attraction_std
		intensity_mean.value = data.intensity_mean
		intensity_std.value = data.intensity_std
		aggression_mean.vec = data.aggression_mean
		aggression_std.value = data.aggression_std
		aggression_intensity_mean.value = data.aggression_intensity_mean
		aggression_intensity_std.value = data.aggression_intensity_std
		aggression_energy_threshold_mean.value = data.aggression_energy_threshold_mean
		aggression_energy_threshold_std.value = data.aggression_energy_threshold_std
		reproduction_energy_threshold_mean.value = data.reproduction_energy_threshold_mean
		reproduction_energy_threshold_std.value = data.reproduction_energy_threshold_std
		reproduction_cooldown_mean.value = data.reproduction_cooldown_mean
		reproduction_cooldown_std.value = data.reproduction_cooldown_std
		brake_mean.value = data.brake_mean
		brake_std.value = data.brake_std
		incubation_time_mean.value = data.incubation_time_mean
		incubation_time_std.value = data.incubation_time_std

func update_data() -> void:
	if data != null:
		data.color_mean = color_mean.color
		data.color_std = color_std.value
		data.size_radius_mean = size_radius_mean.value
		data.size_radius_std = size_radius_std.value
		data.sense_radius_mean = sense_radius_mean.value
		data.sense_radius_std = sense_radius_std.value
		data.attraction_mean = attraction_mean.vec
		data.attraction_std = attraction_std.value
		data.intensity_mean = intensity_mean.value
		data.intensity_std = intensity_std.value
		data.aggression_mean = aggression_mean.vec
		data.aggression_std = aggression_std.value
		data.aggression_intensity_mean = aggression_intensity_mean.value
		data.aggression_intensity_std = aggression_intensity_std.value
		data.aggression_energy_threshold_mean = aggression_energy_threshold_mean.value
		data.aggression_energy_threshold_std = aggression_energy_threshold_std.value
		data.reproduction_energy_threshold_mean = reproduction_energy_threshold_mean.value
		data.reproduction_energy_threshold_std = reproduction_energy_threshold_std.value
		data.reproduction_cooldown_mean = reproduction_cooldown_mean.value
		data.reproduction_cooldown_std = reproduction_cooldown_std.value
		data.brake_mean = brake_mean.value
		data.brake_std = brake_std.value
		data.incubation_time_mean = incubation_time_mean.value
		data.incubation_time_std = incubation_time_std.value

func _on_value_changed() -> void:
	update_data()
	value_changed.emit()
