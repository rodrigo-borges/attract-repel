extends Node2D
class_name FoodSpawner

signal created_food(food:Food, pos:Vector2)

@export var data:FoodSpawnerData
var spawn_timer:Timer

func _ready() -> void:
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn)
	spawn_timer.start(1./data.spawn_rate)

	set_z_index(-2)

func _draw() -> void:
	draw_rect(data.area, data.color*Color(1.,1.,1.,.05))
	draw_rect(data.area, data.color, false)

func update() -> void:
	if data != null:
		spawn_timer.set_wait_time(1./data.spawn_rate)
		queue_redraw()

func spawn() -> void:
	var color:Color = data.color + Color(randfn(0., data.color_std), randfn(0., data.color_std), randfn(0., data.color_std))
	var food:Food = Food.create(color, data.energy_provided, data.decay_time)
	var pos:Vector2 = Vector2(randf()*data.area.size.x+data.area.position.x, randf()*data.area.size.y+data.area.position.y)
	created_food.emit(food, pos)

static func create(_data:FoodSpawnerData) -> FoodSpawner:
	var spawner = FoodSpawner.new()
	spawner.data = _data
	return spawner