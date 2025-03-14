extends StaticBody2D
class_name FamilyNode

const scene_path:String = "res://family_tree/family_node.tscn"
static var radius:float = 12.

@onready var dead_icon:Sprite2D = find_child("DeadIcon")
@onready var marker_sprite:Sprite2D = find_child("Marker")
@onready var desc_label:Label = find_child("Descendents")
var creature:CreatureData
var light_color:bool
var always_show:bool


func _ready() -> void:
	if light_color:
		dead_icon.set_modulate(Color.BLACK)
	else:
		dead_icon.set_modulate(Color.WHITE)
	if creature.vessel != null:
		creature.vessel.died.connect(update_dead_icon)
	update()

func _process(_delta:float) -> void:
	var desc_stats:Array[int] = creature.get_descendents_stats()
	desc_label.set_text("%d\n%d" % desc_stats)
	update_marker()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, creature.color)
	draw_circle(Vector2.ZERO, radius, Color.BLACK, false)

func update() -> void:
	update_dead_icon()
	update_marker()

func update_dead_icon() -> void:
	if creature != null:
		dead_icon.set_visible(creature.vessel == null)

func update_marker() -> void:
	if creature != null:
		var new_texture:Texture2D = null if creature.marker == null else creature.marker.texture
		marker_sprite.set_texture(new_texture)
		marker_sprite.set_visible(creature.marker != null)

static func create(_creature:CreatureData) -> FamilyNode:
	var family_node:FamilyNode = load(scene_path).instantiate()
	family_node.creature = _creature
	family_node.light_color = _creature.color.get_luminance() > .5
	return family_node