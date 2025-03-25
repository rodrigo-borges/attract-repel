@tool
extends Control
class_name FoodSpawnerCard

signal value_changed()

@export var data:FoodSpawnerData

@onready var color:ColorUI = find_child("Color")
@onready var color_std:ValueUI = find_child("ColorSTD")
@onready var spawn_rate:ValueUI = find_child("SpawnRate")
@onready var energy_provided:ValueUI = find_child("EnergyProvided")
@onready var decay_time:ValueUI = find_child("DecayTime")


func _ready() -> void:
    color.value_changed.connect(_on_value_changed)
    color_std.value_changed.connect(_on_value_changed)
    spawn_rate.value_changed.connect(_on_value_changed)
    energy_provided.value_changed.connect(_on_value_changed)
    decay_time.value_changed.connect(_on_value_changed)

func set_data(new:FoodSpawnerData) -> void:
    data = new
    update()

func update() -> void:
    if data != null:
        color.color = data.color
        color_std.value = data.color_std
        spawn_rate.value = data.spawn_rate
        energy_provided.value = data.energy_provided
        decay_time.value = data.decay_time

func update_data() -> void:
    if data != null:
        data.color = color.color
        data.color_std = color_std.value
        data.spawn_rate = spawn_rate.value
        data.energy_provided = energy_provided.value
        data.decay_time = decay_time.value

func _on_value_changed() -> void:
    update_data()
    value_changed.emit()