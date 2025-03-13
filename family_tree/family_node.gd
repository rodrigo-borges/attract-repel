extends StaticBody2D
class_name FamilyNode

const scene_path:String = "res://family_tree/family_node.tscn"
static var radius:float = 12.

@onready var dead_icon:Sprite2D = find_child("DeadIcon")
var creature:CreatureData
var light_color:bool


func _ready() -> void:
	if light_color:
		dead_icon.set_modulate(Color.BLACK)
	else:
		dead_icon.set_modulate(Color.WHITE)
	if creature.vessel != null:
		creature.vessel.died.connect(update)
	update()

func _process(_delta:float) -> void:
	pass

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, creature.color)
	draw_circle(Vector2.ZERO, radius, Color.BLACK, false)

func update() -> void:
	if creature != null:
		if dead_icon != null:
			dead_icon.set_visible(creature.vessel == null)

static func create(_creature:CreatureData) -> FamilyNode:
	var family_node:FamilyNode = load(scene_path).instantiate()
	family_node.creature = _creature
	family_node.light_color = _creature.color.get_luminance() > .5
	return family_node