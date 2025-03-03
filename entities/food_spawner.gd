extends Node2D
class_name FoodSpawner

signal created_food(food:Food, pos:Vector2)

@export var area:Rect2
@export var spawn_rate:float = 1.
@export var color:Color = Color.WHITE
@export var energy_provided:float = 10.
@export var decay_time:float = 60.
var timer:Timer

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(spawn)
	timer.start(1./spawn_rate)

func _draw() -> void:
	draw_rect(area, color*Color(1.,1.,1.,.05))
	draw_rect(area, color, false)

func spawn() -> void:
	var food:Food = Food.create(color, energy_provided, decay_time)
	var pos:Vector2 = Vector2(randf()*area.size.x+area.position.x, randf()*area.size.y+area.position.y)
	created_food.emit(food, pos)

static func create(_area:Rect2, _spawn_rate:float, _color:Color, _energy_provided:float, _decay_time:float) -> FoodSpawner:
	var spawner = FoodSpawner.new()
	spawner.area = _area
	spawner.spawn_rate = _spawn_rate
	spawner.color = _color
	spawner.energy_provided = _energy_provided
	spawner.decay_time = _decay_time
	spawner.set_z_index(-2)
	return spawner