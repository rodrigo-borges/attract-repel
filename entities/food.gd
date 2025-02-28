extends ColoredEntity
class_name Food

signal consumed()

const BASE_SIZE:float = 8.

var energy_provided:float


func _ready() -> void:
	self.set_collision_layer(0b0010)
	self.set_collision_mask(0b0000)
	var coll_shape = CollisionShape2D.new()
	var coll_rect = RectangleShape2D.new()
	coll_rect.set_size(Vector2(BASE_SIZE, BASE_SIZE))
	coll_shape.set_shape(coll_rect)
	add_child(coll_shape)

func consume() -> void:
	consumed.emit()
	queue_free()

func _draw() -> void:
	var rect = Rect2(Vector2(-BASE_SIZE/2., -BASE_SIZE/2.), Vector2(BASE_SIZE, BASE_SIZE))
	draw_rect(rect, self.color)
	draw_rect(rect, Color.BLACK, false)

static func create(
		_color:Color, _energy_provided:float):
	var food:Food = Food.new()
	food.color = _color
	food.energy_provided = _energy_provided
	return food
