extends Node2D
class_name FamilyNodeHighlight

@export var color:Color = Color.WHITE
@export var highlight_width:float = 2.

func _ready() -> void:
	set_z_index(-1)

func _process(_delta:float) -> void:
	pass

func _draw() -> void:
	draw_circle(Vector2.ZERO, FamilyNode.radius+highlight_width, color)
