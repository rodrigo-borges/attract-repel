extends Control
class_name CreatureCard

@export var creature:Creature:
	set(value):
		creature = value
		update()
@onready var color_sliders:ColorUI = find_child("Color")
@onready var attraction_sliders:Vector3UI = find_child("Attraction")


func _ready() -> void:
	pass

func _process(_delta:float) -> void:
	pass

func update() -> void:
	if creature != null:
		color_sliders.color = creature.color
		attraction_sliders.vec = creature.attraction