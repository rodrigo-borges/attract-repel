extends Node2D
class_name CreatureHighlight

@export var color:Color = Color.WHITE
@export var highlight_width:float = 2.
var creature:CreatureVessel

func _ready() -> void:
	set_z_index(-1)

func _process(_delta:float) -> void:
	if creature != null:
		set_global_position(creature.global_position)

func _draw() -> void:
	if creature != null:
		draw_circle(Vector2.ZERO, creature.size_radius+highlight_width, color)