extends Resource
class_name FoodSpawnerData

@export var area:Rect2
@export var spawn_rate:float
@export var color:Color
@export var color_std:float
@export var energy_provided:float
@export var decay_time:float


static func create(
		_area:Rect2, _spawn_rate:float, _color:Color, _color_std:float,
		_energy_provided:float, _decay_time:float) -> FoodSpawnerData:
	var spawner = FoodSpawnerData.new()
	spawner.area = _area
	spawner.spawn_rate = _spawn_rate
	spawner.color = _color
	spawner.energy_provided = _energy_provided
	spawner.decay_time = _decay_time
	return spawner