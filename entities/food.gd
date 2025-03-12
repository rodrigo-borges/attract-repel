extends CharacterBody2D
class_name Food

signal consumed()
signal decayed()

const BASE_SIZE:float = 8.

var color:Color
var energy_provided:float
var decay_time:float
var decay_timer:Timer


func _ready() -> void:
	self.set_collision_layer(0b0010)
	self.set_collision_mask(0b0000)
	var coll_shape = CollisionShape2D.new()
	var coll_rect = RectangleShape2D.new()
	coll_rect.set_size(Vector2(BASE_SIZE, BASE_SIZE))
	coll_shape.set_shape(coll_rect)
	add_child(coll_shape)

	if decay_time > 0.:
		decay_timer = Timer.new()
		add_child(decay_timer)
		decay_timer.timeout.connect(func(): decayed.emit(); queue_free())
		decay_timer.start(decay_time)

func consume() -> void:
	consumed.emit()
	queue_free()

func _draw() -> void:
	var rect = Rect2(Vector2(-BASE_SIZE/2., -BASE_SIZE/2.), Vector2(BASE_SIZE, BASE_SIZE))
	draw_rect(rect, self.color)
	draw_rect(rect, Color.BLACK, false)

static func create(
		_color:Color, _energy_provided:float, _decay_time:float):
	var food:Food = Food.new()
	food.color = _color
	food.energy_provided = _energy_provided
	food.decay_time = _decay_time
	return food
